"""checks module."""
import shutil

def has(cmd):
    return shutil.which(cmd) is not None

def arch():
    return __import__("os").path.exists("/etc/arch-release")

def internet():
    try:
        import urllib.request
        urllib.request.urlopen("https://archlinux.org", timeout=5)
        return True
    except Exception:
        return False
EOF