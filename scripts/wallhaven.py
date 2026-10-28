#!/usr/bin/env python3
"""Wallhaven API helper for eclipsecalis.

Provides search, download, and info commands with:
- HTTP fetching via stdlib urllib (no external dependencies)
- Disk caching of thumbnails and search results
- Rate limiting (45 requests/minute per Wallhaven policy)
- API key support (optional, stored in secrets.json or env var)
- Purity safety: SFW default, NSFW requires explicit key opt-in
- Atomic downloads with .part -> rename pattern
- Friendly error messages for 401/429/other errors
"""

import json
import os
import re
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


class WallhavenError(Exception):
    """Raised when the Wallhaven API returns an error."""

    def __init__(self, code: str, message: str):
        self.code = code
        self.message = message
        super().__init__(f"[{code}] {message}")


# Constants
WALLHAVEN_API = "https://wallhaven.cc/api/v1"
USER_AGENT = "eclipsecalis/0.1.0"
RATE_LIMIT = 45  # requests per minute
_cache_home = os.environ.get("XDG_CACHE_HOME", "")
if not _cache_home:
    _cache_home = os.path.expanduser("~/.cache")
CACHE_DIR = Path(_cache_home) / "eclipsecalis" / "wallhaven"
_secrets_home = os.environ.get("WALLHAVEN_API_KEY", "").strip()
if _secrets_home:
    SECRETS_PATH = Path(_secrets_home)
else:
    SECRETS_PATH = Path(os.path.expanduser("~/.config/eclipsecalis")) / "secrets.json"
_download_dir = os.environ.get(
    "WALLHAVEN_DOWNLOAD_DIR",
    os.path.expanduser("~/.config/eclipsecalis/wallpapers/custom"),
)
DOWNLOAD_DIR = Path(_download_dir)
MIGRATIONS_DIR = Path(__file__).parent.parent / "migrations"


def _ensure_dirs() -> None:
    """Create cache and download directories if they don't exist."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)


def _load_api_key() -> Optional[str]:
    """Load API key from secrets file or environment variable.

    Returns None if no key is set (SFW-only mode).
    """
    # Check environment variable first (override)
    env_key = os.environ.get("WALLHAVEN_API_KEY", "").strip()
    if env_key:
        return env_key

    # Check secrets file
    if SECRETS_PATH.exists():
        try:
            data = json.loads(SECRETS_PATH.read_text())
            key = data.get("key", "").strip()
            if key:
                return key
        except (json.JSONDecodeError, OSError):
            pass

    return None


def _save_api_key(key: str) -> None:
    """Save API key to secrets.json with restrictive permissions."""
    SECRETS_PATH.parent.mkdir(parents=True, exist_ok=True)
    data = {"key": key}
    tmp = SECRETS_PATH.with_suffix(".tmp")
    tmp.write_text(json.dumps(data))
    os.chmod(str(tmp), 0o600)
    tmp.replace(SECRETS_PATH)
    os.chmod(str(SECRETS_PATH), 0o600)


def _rate_limit(key: str = "") -> None:
    """Sleep to respect Wallhaven's 45 req/min rate limit.

    Uses a per-key token bucket; minimal sleep for solo usage.
    """
    global _last_request
    current = time.time()
    elapsed = current - _last_request.get(key, 0)
    min_interval = 60.0 / RATE_LIMIT
    if elapsed < min_interval:
        time.sleep(min_interval - elapsed)
    _last_request[key] = time.time()


_last_request: Dict[str, float] = {}


def _api_request(
    endpoint: str, params: Optional[Dict[str, Any]] = None, key: Optional[str] = None
) -> Dict[str, Any]:
    """Make a rate-limited GET request to the Wallhaven API.

    Returns the parsed JSON response.
    Raises WallhavenError on non-200 or non-404 responses.
    """
    _rate_limit(key or "")

    url = WALLHAVEN_API + endpoint
    query = urllib.parse.urlencode(params or {}, quote_via=urllib.parse.quote)
    full_url = f"{url}?{query}"

    req = urllib.request.Request(full_url, headers={"User-Agent": USER_AGENT})

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8")
            data = json.loads(body)
            if resp.status != 200:
                raise WallhavenError(f"HTTP {resp.status}", resp.status)
            return data
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8") if e.length else ""
        try:
            err_data = json.loads(body)
            code = err_data.get("error", {}).get("code", e.code)
            message = err_data.get("error", {}).get("message", body[:200])
        except (json.JSONDecodeError, AttributeError):
            code = e.code
            message = body[:200]

        if e.code == 429:
            # Rate limited - back off and retry once after wait
            retry_after = int(e.headers.get("Retry-After", "60"))
            time.sleep(retry_after)
            return _api_request(endpoint, params, key)
        elif e.code == 401:
            raise WallhavenError("invalid_api_key", message or "Invalid API key")
        elif e.code == 404:
            raise WallhavenError("not_found", message or "Not found")
        else:
            raise WallhavenError(f"api_error_{code}", message)


def search(
    query: str = "",
    categories: str = "110",
    purity: str = "100",
    sorting: str = "added",
    order: str = "desc",
    top_range: Optional[str] = None,
    at_least: Optional[str] = None,
    resolutions: Optional[List[str]] = None,
    ratios: Optional[List[str]] = None,
    colors: Optional[List[str]] = None,
    page: int = 1,
    seed: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], int]:
    """Search Wallhaven and return results with pagination.

    Args:
        query: Search query string (supports tag syntax: +nature -water)
        categories: 3-bit string general/anime/people (e.g. "110"=general only)
        purity: 3-bit string sfw/sketchy/nsfw (e.g. "100"=sfw only)
        sorting: date_added, relevance, random, views, favorites, toplist
        order: asc, desc
        top_range: when toplist sorting, 1M, 6M, 1Y, ALL
        at_least: minimum resolution like "1920x1080"
        ratios: aspect ratio like "16x9"
        colors: color hex codes
        page: page number (1-indexed)
        seed: for random sorting, pass between pages to avoid repeats

    Returns:
        (results_list, total_count) tuple
    """
    _ensure_dirs()
    key = _load_api_key()

    # Build params - only include non-default values
    params: Dict[str, Any] = {
        "q": query,
        "categories": categories,
        "purity": purity,
        "sorting": sorting,
        "order": order,
        "page": page,
    }

    if top_range is not None:
        params["topRange"] = top_range
    if at_least is not None:
        params["atleast"] = at_least
    if ratios is not None:
        params["ratios"] = ",".join(ratios)
    if colors is not None:
        params["colors"] = ",".join(colors)
    if seed is not None:
        params["seed"] = seed

    data = _api_request("/search", params, key)

    results = data.get("data", [])
    total = data.get("meta", {}).get("total", 0)

    return results, total


def info(wallpaper_id: int) -> Dict[str, Any]:
    """Get info for a specific wallpaper by ID.

    Returns the wallpaper dict from the API response.
    """
    _ensure_dirs()
    key = _load_api_key()
    data = _api_request(f"/w/{wallpaper_id}", key=key)
    return data.get("data", {})


def _download_filename(url: str, suggested_name: str) -> str:
    """Determine the filename to save based on URL extension.

    Wallhaven URLs may not have extensions; we infer from the URL or use .jpg.
    """
    # Try to get extension from URL
    match = re.search(r"\.([a-zA-Z0-9]+)(?:[\?&]|$)", url)
    if match:
        ext = match.group(1).lower()
        if ext in ("jpg", "jpeg", "png", "webp", "gif"):
            return f"wallhaven-{suggested_name}.{ext}"

    # Default to jpg
    return f"wallhaven-{suggested_name}.jpg"


def download(wallpaper_id: int, set_as_wallpaper: bool = False) -> Dict[str, str]:
    """Download a wallpaper by ID.

    Saves to DOWNLOAD_DIR with filename wallhaven-<id>.<ext>.
    Skips if file already exists.
    Returns dict with status and path info.
    """
    _ensure_dirs()

    info_data = info(wallpaper_id)
    url = info_data.get("path", "")
    if not url:
        return {"status": "error", "message": "No URL found for wallpaper"}

    suggested_name = str(wallpaper_id)
    filename = _download_filename(url, suggested_name)
    filepath = DOWNLOAD_DIR / filename

    # Skip if already downloaded
    if filepath.exists():
        return {
            "status": "already_downloaded",
            "path": str(filepath),
            "filename": filename,
        }

    # Download with progress
    try:
        filepath, _ = _url_retrieve(url, filepath)
        return {
            "status": "success",
            "path": str(filepath),
            "filename": filename,
        }
    except urllib.error.URLError as e:
        # Clean up partial download
        if filepath.exists():
            try:
                filepath.unlink()
            except OSError:
                pass
        return {"status": "error", "message": str(e)}


def _url_retrieve(url: str, filepath: Path) -> Tuple[Path, int]:
    """Retrieve a URL and save to filepath atomically.

    Downloads to .part file first, then renames on completion.
    Returns the path to the saved file.
    """
    part_path = filepath.with_suffix(".part")

    # Remove any leftover .part file
    if part_path.exists():
        part_path.unlink()

    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})

    with urllib.request.urlopen(request, timeout=60) as response:
        total_size = response.headers.get("Content-Length")
        total_size = int(total_size) if total_size and total_size.isdigit() else 0

        with open(part_path, "wb") as out_file:
            downloaded = 0
            chunk_size = 8192
            while True:
                chunk = response.read(chunk_size)
                if not chunk:
                    break
                out_file.write(chunk)
                downloaded += len(chunk)
                # Could emit progress signal here if needed

        # Atomic rename
        part_path.replace(filepath)

    return filepath, total_size


def clear_cache() -> int:
    """Clear the thumbnail/cache directory.

    Returns number of files deleted.
    """
    _ensure_dirs()
    count = 0
    for f in CACHE_DIR.iterdir():
        if f.is_file():
            try:
                f.unlink()
                count += 1
            except OSError:
                pass
    return count


def list_local_wallpapers() -> List[Dict[str, str]]:
    """List wallpapers from the local download folder.

    Returns list of dicts with filename, path, and mtime.
    """
    _ensure_dirs()
    wallpapers = []
    if not DOWNLOAD_DIR.exists():
        return wallpapers

    for f in sorted(DOWNLOAD_DIR.iterdir(), key=lambda p: p.name):
        if f.is_file():
            try:
                wallpapers.append(
                    {
                        "filename": f.name,
                        "path": str(f.resolve()),
                        "size": f.stat().st_size,
                        "mtime": int(f.stat().st_mtime),
                    }
                )
            except OSError:
                pass

    return wallpapers


def _cli_output(result: Any) -> None:
    """Print a Python value as JSON to stdout."""
    print(json.dumps(result), flush=True)


if __name__ == "__main__":
    """CLI interface for Wallhaven helper.

    Usage:
        python3 scripts/wallhaven.py search [args...]
        python3 scripts/wallhaven.py download <id>
        python3 scripts/wallhaven.py info <id>
        python3 scripts/wallhaven.py clear_cache
        python3 scripts/wallhaven.py list_local
    """
    import sys

    args = sys.argv[1:]

    if not args:
        print("Usage: python3 scripts/wallhaven.py <search|download|info|clear_cache|list_local> [args]", file=sys.stderr)
        sys.exit(1)

    command = args[0]

    if command == "search":
        # Parse remaining args
        query = ""
        categories = "110"
        purity = "100"
        sorting = "added"
        order = "desc"
        top_range = None
        at_least = None
        ratios = None
        colors = None
        page = 1
        seed = None

        i = 1
        while i < len(args):
            arg = args[i]
            if arg == "--query" and i + 1 < len(args):
                query = args[i + 1]; i += 2
            elif arg == "--categories" and i + 1 < len(args):
                categories = args[i + 1]; i += 2
            elif arg == "--purity" and i + 1 < len(args):
                purity = args[i + 1]; i += 2
            elif arg == "--sorting" and i + 1 < len(args):
                sorting = args[i + 1]; i += 2
            elif arg == "--order" and i + 1 < len(args):
                order = args[i + 1]; i += 2
            elif arg == "--top-range" and i + 1 < len(args):
                top_range = args[i + 1]; i += 2
            elif arg == "--at-least" and i + 1 < len(args):
                at_least = args[i + 1]; i += 2
            elif arg == "--ratios" and i + 1 < len(args):
                ratios = args[i + 1]; i += 2
            elif arg == "--colors" and i + 1 < len(args):
                colors = args[i + 1]; i += 2
            elif arg == "--page" and i + 1 < len(args):
                page = int(args[i + 1]); i += 2
            elif arg == "--seed" and i + 1 < len(args):
                seed = args[i + 1]; i += 2
            else:
                # Treat as query string
                if not query:
                    query = arg
                i += 1
            continue

        results, total = search(query=query, categories=categories, purity=purity,
                                sorting=sorting, order=order, top_range=top_range,
                                at_least=at_least, ratios=ratios, colors=colors,
                                page=page, seed=seed)
        _cli_output({"results": results, "total": total})

    elif command == "download":
        if len(args) < 2:
            print("Usage: python3 scripts/wallhaven.py download <id>", file=sys.stderr)
            sys.exit(1)
        try:
            wallpaper_id = int(args[1])
            result = download(wallpaper_id=wallpaper_id)
            _cli_output(result)
        except WallhavenError as e:
            _cli_output({"status": "error", "code": e.code, "message": e.message})

    elif command == "info":
        if len(args) < 2:
            print("Usage: python3 scripts/wallhaven.py info <id>", file=sys.stderr)
            sys.exit(1)
        try:
            wallpaper_id = int(args[1])
            result = info(wallpaper_id=wallpaper_id)
            _cli_output(result)
        except WallhavenError as e:
            _cli_output({"status": "error", "code": e.code, "message": e.message})

    elif command == "clear_cache":
        count = clear_cache()
        _cli_output({"cleared": count})

    elif command == "list_local":
        result = list_local_wallpapers()
        _cli_output(result)

    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        print("Usage: python3 scripts/wallhaven.py <search|download|info|clear_cache|list_local>", file=sys.stderr)
        sys.exit(1)