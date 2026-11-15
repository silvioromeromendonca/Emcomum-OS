# Identidade visual Emcomum-OS 2.0

Arquivos SVG vetoriais da distribuição:

- `wallpaper.svg`: papel de parede GNOME vermelho/preto com tema espacial.
- `logo.svg`: logotipo redondo do Emcomum-OS.
- `splash.svg`: arte de apresentação e imagem usada na inicialização Plymouth.

Para instalar em um Debian já inicializado, com `librsvg2-bin` e Plymouth instalados:

```bash
sudo bash scripts/emcomum-branding.sh
```

Também é possível indicar outros arquivos como argumentos: `bash scripts/emcomum-branding.sh wallpaper.svg logo.svg splash.svg`.
