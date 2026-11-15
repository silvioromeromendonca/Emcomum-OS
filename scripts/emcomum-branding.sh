#!/bin/bash
set -euo pipefail

# Instalar o branding do Emcomum-OS no sistema live / sistema alvo.
# Este script assume que as imagens foram copiadas para os caminhos abaixo.
# Ajuste os caminhos conforme a sua estrutura.

WALLPAPER_SRC="/tmp/emcomum-os/wallpaper.png"
LOGO_SRC="/tmp/emcomum-os/logo.png"
SPLASH_SRC="/tmp/emcomum-os/splash.png"

WALLPAPER_DST="/usr/share/backgrounds/emcomum-os-wallpaper.png"
LOGO_DST="/usr/share/pixmaps/emcomum-os-logo.png"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/emcomum-os"

if [ ! -f "$WALLPAPER_SRC" ] || [ ! -f "$LOGO_SRC" ] || [ ! -f "$SPLASH_SRC" ]; then
  echo "Arquivos de branding não encontrados."
  echo "Coloque os arquivos em:"
  echo "  $WALLPAPER_SRC"
  echo "  $LOGO_SRC"
  echo "  $SPLASH_SRC"
  exit 1
fi

mkdir -p /usr/share/backgrounds /usr/share/pixmaps "$PLYMOUTH_THEME_DIR"

install -m 0644 "$WALLPAPER_SRC" "$WALLPAPER_DST"
install -m 0644 "$LOGO_SRC" "$LOGO_DST"
install -m 0644 "$SPLASH_SRC" "$PLYMOUTH_THEME_DIR/emcomum-os-splash.png"

# Configurar fundo do GNOME
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_DST" || true
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_DST" || true
fi

# Criar tema Plymouth básico
cat > "$PLYMOUTH_THEME_DIR/emcomum-os.plymouth" <<'EOF'
[Plymouth Theme]
Name=Emcomum-OS
Description=Tema de inicialização do Emcomum-OS
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

# Ativar tema do Plymouth
if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme -R emcomum-os || true
fi

# Atualizar initramfs em distribuições Debian/Ubuntu
if command -v update-initramfs >/dev/null 2>&1; then
  update-initramfs -u || true
fi

echo "Branding do Emcomum-OS aplicada com sucesso."
