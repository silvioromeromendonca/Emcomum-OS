#!/bin/bash
set -euo pipefail

# Emcomum-OS branding installer
# Usa os arquivos do diretório branding/ do repositório ou arquivos passados por argumento.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BRANDING_DIR="${BRANDING_DIR:-$REPO_ROOT/branding}"

WALLPAPER_SRC="${1:-$BRANDING_DIR/wallpaper.svg}"
LOGO_SRC="${2:-$BRANDING_DIR/logo.svg}"
SPLASH_SRC="${3:-$BRANDING_DIR/splash.svg}"

WALLPAPER_DST="/usr/share/backgrounds/emcomum-os-wallpaper.png"
LOGO_DST="/usr/share/pixmaps/emcomum-os-logo.png"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/emcomum-os"

ensure_png() {
  local src="$1"
  local dst="$2"

  if [[ "$src" == *.svg ]]; then
    if command -v rsvg-convert >/dev/null 2>&1; then
      rsvg-convert -w 1920 -h 1080 "$src" -o "$dst"
    elif command -v convert >/dev/null 2>&1; then
      convert "$src" -resize 1920x1080 "$dst"
    else
      echo "Nenhuma ferramenta de conversão SVG para PNG foi encontrada (rsvg-convert ou ImageMagick)."
      echo "Instale: sudo apt install librsvg2-bin imagemagick"
      exit 1
    fi
  else
    install -m 0644 "$src" "$dst"
  fi
}

if [ ! -f "$WALLPAPER_SRC" ] || [ ! -f "$LOGO_SRC" ] || [ ! -f "$SPLASH_SRC" ]; then
  echo "Arquivos de branding não encontrados."
  echo "Procure em: $BRANDING_DIR"
  echo "Arquivos esperados:"
  echo "  wallpaper.svg ou wallpaper.png"
  echo "  logo.svg ou logo.png"
  echo "  splash.svg ou splash.png"
  exit 1
fi

mkdir -p /usr/share/backgrounds /usr/share/pixmaps "$PLYMOUTH_THEME_DIR"

ensure_png "$WALLPAPER_SRC" "$WALLPAPER_DST"
ensure_png "$LOGO_SRC" "$LOGO_DST"
ensure_png "$SPLASH_SRC" "$PLYMOUTH_THEME_DIR/emcomum-os-splash.png"

# Configurar wallpaper do GNOME
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_DST" || true
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_DST" || true
fi

# Configurar um tema simples do Plymouth
cat > "$PLYMOUTH_THEME_DIR/emcomum-os.plymouth" <<'EOF'
[Plymouth Theme]
Name=Emcomum-OS
Description=Tema de inicialização do Emcomum-OS 1.0.1
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/emcomum-os
ScriptFile=/usr/share/plymouth/themes/emcomum-os/emcomum-os.script
EOF

cat > "$PLYMOUTH_THEME_DIR/emcomum-os.script" <<'EOF'
wall_width = Window.GetWidth();
wall_height = Window.GetHeight();

image = Image("emcomum-os-splash.png");
scaled = image.Scale(wall_width, wall_height);

sprite = Sprite(scaled);
sprite.SetX((wall_width - scaled.GetWidth()) / 2);
sprite.SetY((wall_height - scaled.GetHeight()) / 2);

fun refresh_callback() {
  if (status == "normal") {
    sprite.SetOpacity(1);
  }
}

Plymouth.SetRefreshFunction(refresh_callback);
EOF

if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme -R emcomum-os || true
fi

if command -v update-initramfs >/dev/null 2>&1; then
  update-initramfs -u || true
fi

echo "Branding do Emcomum-OS aplicada com sucesso."
