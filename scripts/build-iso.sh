#!/usr/bin/env bash
set -Eeuo pipefail

# Build Emcomum-OS 2.0 as a Debian live/installable hybrid ISO.
# Usage: sudo bash scripts/build-iso.sh [--clean]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$REPO_ROOT/build}"
DISTRIBUTION="${LB_DISTRIBUTION:-trixie}"
ARCHITECTURE="${LB_ARCHITECTURE:-amd64}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute como root: sudo bash scripts/build-iso.sh" >&2
  exit 1
fi

for tool in lb debootstrap; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Ferramenta ausente: $tool. Instale live-build e debootstrap." >&2
    exit 1
  fi
done

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [[ "${1:-}" == "--clean" ]]; then
  lb clean --purge
  exit 0
elif [[ "$#" -gt 0 ]]; then
  echo "Opção desconhecida: $1" >&2
  echo "Uso: sudo bash scripts/build-iso.sh [--clean]" >&2
  exit 2
fi

# Debian's GNOME desktop task, installer, firmware and tools needed to apply branding.
mkdir -p config/package-lists config/includes.chroot/usr/local/share/emcomum-os \
  config/includes.chroot/usr/local/sbin config/hooks/normal
cat > config/package-lists/emcomum.list.chroot <<'PACKAGES'
task-gnome-desktop
gdm3
network-manager
sudo
live-boot
live-config
live-config-systemd
debian-installer-launcher
plymouth
plymouth-themes
librsvg2-bin
PACKAGES

install -m 0644 "$REPO_ROOT/branding/wallpaper.svg" \
  config/includes.chroot/usr/local/share/emcomum-os/wallpaper.svg
install -m 0644 "$REPO_ROOT/branding/logo.svg" \
  config/includes.chroot/usr/local/share/emcomum-os/logo.svg
install -m 0644 "$REPO_ROOT/branding/splash.svg" \
  config/includes.chroot/usr/local/share/emcomum-os/splash.svg
install -m 0644 "$REPO_ROOT/scripts/emcomum-branding.sh" \
  config/includes.chroot/usr/local/sbin/emcomum-branding.sh

cat > config/hooks/normal/0100-emcomum-branding.hook.chroot <<'HOOK'
#!/bin/sh
set -eu
bash /usr/local/sbin/emcomum-branding.sh \
  /usr/local/share/emcomum-os/wallpaper.svg \
  /usr/local/share/emcomum-os/logo.svg \
  /usr/local/share/emcomum-os/splash.svg
HOOK
chmod 0755 config/hooks/normal/0100-emcomum-branding.hook.chroot

lb config \
  --mode debian \
  --distribution "$DISTRIBUTION" \
  --architectures "$ARCHITECTURE" \
  --binary-images iso-hybrid \
  --debian-installer live \
  --archive-areas "main contrib non-free non-free-firmware" \
  --iso-application "Emcomum-OS 2.0" \
  --iso-volume "EMCOMUM_OS_2_0" \
  --bootappend-live "boot=live components username=emcomum hostname=emcomum-os locales=pt_BR.UTF-8 keyboard-layouts=br"

lb build
printf '\nCompilação concluída. ISO: %s/live-image-%s.hybrid.iso\n' "$BUILD_DIR" "$ARCHITECTURE"
