# Emcomum-OS 2.0

Projeto de uma ISO live instalável baseada em Debian, com ambiente GNOME puro e identidade visual Emcomum-OS 2.0.

## O que está incluído

- GNOME (`task-gnome-desktop`) com GDM e NetworkManager.
- Imagem híbrida ISO para amd64, inicializável por USB/BIOS/UEFI.
- Instalador Debian na imagem live.
- Papel de parede espacial em vermelho e preto, logotipo e arte da tela inicial.
- Scripts e fontes da identidade visual versionados neste repositório.

## Gerar a ISO

A compilação deve ser feita em uma máquina Debian amd64 com acesso à internet. Instale as ferramentas necessárias:

```bash
sudo apt update
sudo apt install live-build debootstrap squashfs-tools xorriso
```

Clone o projeto e execute o script como root (o live-build precisa de privilégios):

```bash
git clone https://github.com/silvioromeromendonca/Emcomum-OS.git
cd Emcomum-OS
sudo bash scripts/build-iso.sh
```

A ISO será gravada em `build/live-image-amd64.hybrid.iso`. O script usa Debian `trixie` por padrão. Para selecionar outra distribuição Debian suportada pelo live-build:

```bash
sudo LB_DISTRIBUTION=bookworm bash scripts/build-iso.sh
```

A primeira compilação baixa os pacotes Debian e pode levar bastante tempo e espaço em disco. Para limpar a configuração/artefatos do live-build antes de compilar novamente:

```bash
sudo bash scripts/build-iso.sh --clean
```

> Teste a ISO em uma máquina virtual antes de gravá-la em um dispositivo. A gravação de uma imagem em disco/USB pode apagar os dados do dispositivo selecionado.

## Identidade visual

- `branding/wallpaper.svg`: papel de parede GNOME.
- `branding/logo.svg`: logotipo do sistema.
- `branding/splash.svg`: arte de apresentação/tela inicial.
- `scripts/emcomum-branding.sh`: instala os recursos visuais e configura GNOME, dconf e Plymouth.
- `scripts/build-iso.sh`: configura e compila a imagem live instalável.

As imagens SVG são fontes vetoriais editáveis. Para aplicar o tema manualmente em um Debian já instalado, use `sudo bash scripts/emcomum-branding.sh` (requer `librsvg2-bin` e Plymouth).

## Observações

Esta é uma configuração comunitária sobre Debian; não é uma distribuição oficial do Debian. Os pacotes continuam sendo obtidos dos repositórios Debian configurados no live-build.
