# Emcomum-OS Branding

Este diretório contém os arquivos visuais do tema do sistema para a ISO Debian + GNOME puro.

Arquivos esperados:
- `wallpaper.svg` ou `wallpaper.png`
- `logo.svg` ou `logo.png`
- `splash.svg` ou `splash.png`

O script principal está em `scripts/emcomum-branding.sh`.

Uso em um sistema live / destino:

```bash
sudo bash /caminho/para/scripts/emcomum-branding.sh
```

Ou explicitando os arquivos:

```bash
sudo bash /caminho/para/scripts/emcomum-branding.sh \
  /caminho/para/branding/wallpaper.svg \
  /caminho/para/branding/logo.svg \
  /caminho/para/branding/splash.svg
```

Notas:
- A imagem de fundo do GNOME é aplicada via `gsettings`.
- A tela de inicialização é configurada via Plymouth.
- O logotipo é instalado em `/usr/share/pixmaps`.
- Para gerar a ISO final, o script deve ser executado dentro do chroot do sistema live antes do build final.
