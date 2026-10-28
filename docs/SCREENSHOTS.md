# Screenshots checklist
- [ ] overview (full desktop)
- [ ] bar close-up
- [ ] launcher (apps mode)
- [ ] launcher clipboard
- [ ] launcher emoji
- [ ] launcher math
- [ ] left panel settings
- [ ] left panel keybinds
- [ ] right panel calendar
- [ ] right panel resources
- [ ] wallpaper switcher
- [ ] lock screen
- [ ] light/dark toggle
EOF
# migrations example
cat > /home/hell/eclipsecalis/migrations/001_init.py <<'EOF'
print("migration 001: init")
EOF
echo done