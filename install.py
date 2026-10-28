#!/usr/bin/env python3
"""eclipsecalis installer (single entry point) with rich live UI."""
import argparse
import os
import shutil
import subprocess
import sys

HOME = os.path.expanduser("~")
CONFIG = os.path.join(HOME, ".config")
INSTALL_DIR = os.path.expanduser("~/.local/share/eclipsecalis")
STATE = os.path.expanduser("~/.local/state/eclipsecalis")

def bootstrap_rich():
    try:
        import rich
        return True
    except ImportError:
        pass
    if shutil.which("pacman"):
        subprocess.run(["sudo", "pacman", "-S", "--needed", "--noconfirm", "python-rich"], check=False)
        try:
            import rich  # noqa: F401
            return True
        except ImportError:
            pass
    return False

HAS_RICH = bootstrap_rich()

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

    if HAS_RICH:
        from rich.console import Console
        from rich.panel import Panel
        from rich.table import Table
        console = Console()
        console.print(Panel.fit("[bold cyan]ECLIPSECALIS[/bold cyan]\nArch + Hyprland daily-driver", border_style="cyan"))
        # preflight table
        t = Table(title="Preflight")
        t.add_column("Check"); t.add_column("Status")
        t.add_row("Arch Linux", "OK" if os.path.exists("/etc/arch-release") else "FAIL")
        t.add_row("Not root", "OK")
        t.add_row("Internet", "checking...")
        console.print(t)
    else:
        print("ECLIPSECALIS installer (rich unavailable, plain mode)")

    if args.dry_run:
        print("dry-run: would install. exiting."); return

    os.makedirs(STATE, exist_ok=True)
    log = open(os.path.join(STATE, "install.log"), "w")  # noqa: SIM115
    def L(msg):
        log.write(msg + "\n"); log.flush()
        if HAS_RICH: console.print(msg)
        else: print(msg)

    # clone
    here = os.path.dirname(os.path.abspath(__file__))
    if not os.path.exists(os.path.join(here, "config")):
        os.makedirs(os.path.dirname(INSTALL_DIR), exist_ok=True)
        if not os.path.exists(INSTALL_DIR):
            subprocess.run(["git", "clone", "https://github.com/subhan634/eclipsecalis", INSTALL_DIR], check=True)
        os.chdir(INSTALL_DIR)
    else:
        if os.path.abspath(here) != os.path.abspath(INSTALL_DIR):
            os.makedirs(os.path.dirname(INSTALL_DIR), exist_ok=True)
            if os.path.exists(INSTALL_DIR): shutil.rmtree(INSTALL_DIR)
            shutil.copytree(here, INSTALL_DIR)

    # deploy configs with timestamped backup
    src_config = os.path.join(INSTALL_DIR, "config")
    for name in os.listdir(src_config):
        s = os.path.join(src_config, name)
        d = os.path.join(CONFIG, name)
        if os.path.exists(d) and not os.path.islink(d):
            import time as _t
            bak = d + ".bak." + str(int(_t.time()))
            shutil.move(d, bak)
            L(f"backed up {d} -> {bak}")
        if os.path.islink(d) or os.path.exists(d):
            try: os.remove(d)
            except IsADirectoryError: shutil.rmtree(d)
        os.symlink(s, d)
        L(f"linked {s} -> {d}")

    # bin
    bin_dir = os.path.join(HOME, ".local/bin")
    os.makedirs(bin_dir, exist_ok=True)
    cli = os.path.join(bin_dir, "eclipsecalis")
    if os.path.exists(cli) or os.path.islink(cli):
        os.remove(cli)
    os.symlink(os.path.join(INSTALL_DIR, "bin/eclipsecalis"), cli)
    L(f"installed CLI -> {cli}")
    L("\nDone. Log out and back in, or start Hyprland.")

if __name__ == "__main__":
    main()
