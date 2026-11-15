#!/usr/bin/env bash
set -Eeuo pipefail

# Install Emcomum-OS artwork and configure GNOME defaults and Plymouth.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BRANDING_DIR="${BRANDING_DIR:-$REPO_ROOT/branding}"
WALLPAPER_SRC="${1:-$BRANDING_DIR/wallpaper.svg}"
LOGO_SRC="${2:-$BRANDING_DIR/logo.svg}"
SPLASH_SRC="${3:-$BRANDING_DIR/splash.svg}"
WALLPAPER_DST="/usr/share/backgrounds/emcomum-os-wallpaper.png"
LOGO_DST="/usr/share/pixmaps/emcomum-os-logo.png"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/emcomum-os"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute como root: sudo bash scripts/emcomum-branding.sh" >&2
  exit 1
fi
for src in "$WALLPAPER_SRC" "$LOGO_SRC" "$SPLASH_SRC"; do
  if [[ ! -f "$src" ]]; then
    echo "Arquivo de identidade visual não encontrado: $src" >&2
    exit 1
  fi
done
if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "Instale librsvg2-bin para converter os arquivos SVG: apt install librsvg2-bin" >&2
  exit 1
fi

install -d -m 0755 /usr/share/backgrounds /usr/share/pixmaps "$PLYMOUTH_THEME_DIR"
rsvg-convert -w 1920 -h 1080 "$WALLPAPER_SRC" -o "$WALLPAPER_DST"
rsvg-convert -w 1024 -h 1024 "$LOGO_SRC" -o "$LOGO_DST"
rsvg-convert -w 1920 -h 1080 "$SPLASH_SRC" -o "$PLYMOUTH_THEME_DIR/emcomum-os-splash.png"
chmod 0644 "$WALLPAPER_DST" "$LOGO_DST" "$PLYMOUTH_THEME_DIR/emcomum-os-splash.png"

# Set system-wide GNOME defaults; users may still change their own wallpaper.
install -d -m 0755 /etc/dconf/profile /etc/dconf/db/local.d
if [[ ! -f /etc/dconf/profile/user ]]; then
  cat > /etc/dconf/profile/user <<'PROFILE'
user-db:user
system-db:local
PROFILE
fi
cat > /etc/dconf/db/local.d/00-emcomum-os <<'DCONF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/emcomum-os-wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/emcomum-os-wallpaper.png'
picture-options='zoom'
DCONF
if command -v dconf >/dev/null 2>&1; then
  dconf update
fi

cat > "$PLYMOUTH_THEME_DIR/emcomum-os.plymouth" <<'PLYMOUTH'
[Plymouth Theme]
Name=Emcomum-OS 2.0
Description=Emcomum-OS 2.0 startup screen
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/emcomum-os
ScriptFile=/usr/share/plymouth/themes/emcomum-os/emcomum-os.script
PLYMOUTH
cat > "$PLYMOUTH_THEME_DIR/emcomum-os.script" <<'SCRIPT'
wall_width = Window.GetWidth();
wall_height = Window.GetHeight();
image = Image("emcomum-os-splash.png");
scaled = image.Scale(wall_width, wall_height);
sprite = Sprite(scaled);
sprite.SetX((wall_width - scaled.GetWidth()) / 2);
sprite.SetY((wall_height - scaled.GetHeight()) / 2);
SCRIPT

if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme -R emcomum-os
elif command -v update-initramfs >/dev/null 2>&1; then
  update-initramfs -u
fi

echo "Identidade visual do Emcomum-OS 2.0 instalada."
