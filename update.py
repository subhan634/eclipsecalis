#!/usr/bin/env python3
"""eclipsecalis updater."""
import argparse
import json
import os
import subprocess
import sys

INSTALL_DIR = os.path.expanduser("~/.local/share/eclipsecalis")
STATE = os.path.expanduser("~/.local/state/eclipsecalis")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--rollback")
    args = ap.parse_args()

    os.chdir(INSTALL_DIR)
    if args.check:
        subprocess.run(["git", "fetch", "--quiet"], check=False)
        r = subprocess.run(["git", "rev-list", "HEAD..origin/main", "--count"], capture_output=True, text=True, check=False)
        print(f"updates available: {r.stdout.strip()}")
        return
    if args.rollback:
        subprocess.run(["git", "reset", "--hard", args.rollback], check=True)
        print("rolled back"); return
    subprocess.run(["git", "pull", "--ff-only"], check=True)
    # run migrations
    mig_dir = os.path.join(INSTALL_DIR, "migrations")
    done = set()
    mig_state = os.path.join(STATE, "migrations.json")
    if os.path.exists(mig_state):
        with open(mig_state) as _f:
            done = set(json.load(_f))
    if os.path.isdir(mig_dir):
        for f in sorted(os.listdir(mig_dir)):
            if f.endswith(".py") and f not in done:
                subprocess.run([sys.executable, os.path.join(mig_dir, f)], check=True)
                done.add(f)
    os.makedirs(STATE, exist_ok=True)
    with open(mig_state, "w") as _f:
        json.dump(sorted(done), _f)
    # re-apply theme
    wp = os.path.expanduser("~/.cache/eclipsecalis/last_wallpaper")
    if os.path.exists(wp):
        with open(wp) as _f:
            _wall = _f.read().strip()
        subprocess.run(["bash", os.path.expanduser("~/.config/eclipsecalis/scripts/theme-apply.sh"), _wall], check=False)
    subprocess.run(["hyprctl", "reload"], check=False)
    print("eclipsecalis updated successfully.")

if __name__ == "__main__":
    main()
