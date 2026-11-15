# Emcomum-OS Branding

Este repositório público contém apenas o release do ISO e não os arquivos de construção do sistema live (`live-build`, `cubic`, `debian-live`, etc.).

Para inserir imagens no ISO de forma correta, o ajuste precisa ser aplicado no sistema live antes da geração do ISO final.

Estrutura sugerida:

- `branding/` -> arquivos finais do tema
- `scripts/emcomum-branding.sh` -> script para instalar wallpaper, logo e splash

Uso:

1. Copie suas imagens para a pasta `branding/`:
   - `wallpaper.png`
   - `logo.png`
   - `splash.png`
2. Rode o script dentro do chroot do live system ou do sistema destino:
   - `sudo bash scripts/emcomum-branding.sh`
3. Gere o ISO final com o seu processo de build.

Observação:

- A tela de inicialização (splash) normalmente é configurada via Plymouth.
- O fundo do GNOME é configurado via `gsettings`.
- O logotipo pode ser usado em `/usr/share/pixmaps` e em aplicativos/branding do sistema.
