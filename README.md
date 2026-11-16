# Emcomum-OS

Projeto de uma distribuição Linux baseada em Debian, com ambiente GNOME puro e identidade visual em vermelho, preto e espaço profundo.

## Visão geral

- Base: Debian stable (trixie por padrão)
- Desktop: GNOME puro com GDM
- Instalação: ISO live híbrida para amd64
- Branding: papel de parede, splash e logotipo temáticos em vermelho
- Repositório: aberto para futuras alterações e refinamentos

## Arquivos principais

- `branding/wallpaper.svg` — papel de parede do desktop
- `branding/logo.svg` — logotipo circular para sistema e ícones
- `branding/splash.svg` — tela inicial / Plymouth
- `scripts/emcomum-branding.sh` — instala a identidade visual no sistema
- `scripts/build-iso.sh` — gera a ISO de instalação

## Compilar a ISO

Em uma máquina Debian amd64 com acesso à internet e privilégios de root:

```bash
sudo apt update
sudo apt install live-build debootstrap squashfs-tools xorriso

git clone https://github.com/silvioromeromendonca/Emcomum-OS.git
cd Emcomum-OS
sudo bash scripts/build-iso.sh
```

A ISO será gerada em:

```bash
build/live-image-amd64.hybrid.iso
```

### Limpeza

```bash
sudo bash scripts/build-iso.sh --clean
```

## Status do projeto

Este repositório foi preparado para suportar a criação da distribuição Emcomum-OS com a identidade visual solicitada. A etapa de compilação da ISO é automatizada por script, mas a geração do arquivo `.iso` final precisa ser executada em um ambiente Debian real com `live-build`, porque a API do GitHub não oferece suporte para compilar imagens de sistema em tempo de execução.

O projeto está aberto para futuras mudanças e ajustes visuais e de infraestrutura.

## Observações

- A ISO é híbrida e pode ser gravada em USB ou testada em máquina virtual.
- O branding é implantado na imagem live e também pode ser reaplicado em um sistema Debian em execução.
- As artes são vetoriais SVG, editáveis e facilmente refináveis.
