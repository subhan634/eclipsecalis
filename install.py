#!/usr/bin/env python3
"""eclipsecalis installer (single entry point)."""
import argparse
import os
import shutil
import subprocess
import sys

HOME = os.path.expanduser("~")
CONFIG = os.path.join(HOME, ".config")
INSTALL_DIR = os.path.join(HOME, ".local/share/eclipsecalis")
STATE = os.path.join(HOME, ".local/state/eclipsecalis")

def bootstrap_rich():
    try:
        import rich
        return True
    except ImportError:
        pass
    # try pacman
    if shutil.which("pacman"):
        subprocess.run(["sudo", "pacman", "-S", "--needed", "--noconfirm", "python-rich"], check=False)
        try:
            import rich  # noqa
            return True
        except ImportError:
            pass
    # vendored fallback: minimal (no color)
    return False

def preflight():
    print("=== eclipsecalis preflight ===")
    print(f"Arch: {os.path.exists('/etc/arch-release')}")
    print(f"Root check: {os.geteuid() != 0}")
    print("Internet: ", end="")
    import urllib.request
    try:
        urllib.request.urlopen("https://archlinux.org", timeout=5)
        print("ok")
    except Exception as e:  # noqa: BLE001
        print(f"FAIL ({e})")
    print(f"Install dir: {INSTALL_DIR}")

def clone_or_use():
    # one-liner path: clone if not already in repo
    here = os.path.dirname(os.path.abspath(__file__))
    if not os.path.exists(os.path.join(here, "config")):
        os.makedirs(os.path.dirname(INSTALL_DIR), exist_ok=True)
        if not os.path.exists(INSTALL_DIR):
            subprocess.run(["git", "clone", "https://github.com/subhan634/eclipsecalis", INSTALL_DIR], check=True)
        os.chdir(INSTALL_DIR)
    else:
        # manual: copy self to install dir
        if os.path.abspath(here) != os.path.abspath(INSTALL_DIR):
            os.makedirs(os.path.dirname(INSTALL_DIR), exist_ok=True)
            if os.path.exists(INSTALL_DIR):
                shutil.rmtree(INSTALL_DIR)
            shutil.copytree(here, INSTALL_DIR)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--yes", action="store_true")
    ap.add_argument("--no-aur", action="store_true")
    ap.add_argument("--minimal", action="store_true")
    ap.add_argument("--full", action="store_true")
    ap.add_argument("--only")
    ap.add_argument("--uninstall", action="store_true")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()

    if os.geteuid() == 0:
        print("Do not run as root."); sys.exit(1)
    bootstrap_rich()
    preflight()
    if args.dry_run:
        print("dry-run: would install. exiting."); return
    clone_or_use()
    os.makedirs(STATE, exist_ok=True)
    # deploy configs (symlink)
    src_config = os.path.join(INSTALL_DIR, "config")
    for name in os.listdir(src_config):
        s = os.path.join(src_config, name)
        d = os.path.join(CONFIG, name if name != "hypr" else "hypr")
        # backup
        if os.path.exists(d) and not os.path.islink(d):
            bak = d + ".bak." + str(int(__import__("time").time()))
            shutil.move(d, bak)
            print(f"backed up {d} -> {bak}")
        if os.path.islink(d) or os.path.exists(d):
            try: os.remove(d)
            except IsADirectoryError: shutil.rmtree(d)
        os.symlink(s, d)
        print(f"linked {s} -> {d}")
    # install bin
    bin_dir = os.path.join(HOME, ".local/bin")
    os.makedirs(bin_dir, exist_ok=True)
    cli = os.path.join(bin_dir, "eclipsecalis")
    if os.path.exists(cli) or os.path.islink(cli):
        os.remove(cli)
    os.symlink(os.path.join(INSTALL_DIR, "bin/eclipsecalis"), cli)
    print(f"installed CLI -> {cli}")
    print("\nDone. Log out and back in, or start Hyprland.")

if __name__ == "__main__":
    main()
