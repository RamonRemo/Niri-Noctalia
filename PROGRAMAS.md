# Programas do desktop

Levantamento de 17/10/2026, feito com o contador do launcher da noctalia, os apps abertos nos últimos 10 dias e o histórico do fish.

## Já vem no CachyOS Niri (+Noctalia)

Escolhendo "Niri" no instalador, o pacote `cachyos-niri-noctalia` já traz:

- niri, noctalia, xwayland-satellite, gnome-keyring
- Nautilus (vem como dependência do `xdg-desktop-portal-gnome`)
- Alacritty com a config do CachyOS, tema adw-gtk, ponteiro capitaine-cursors

## Lista

| Programa | Pacote | Origem | Uso |
|---|---|---|---|
| Zen | `app.zen_browser.zen` | flatpak | navegador principal (Mod+B) |
| Chrome | `google-chrome` | AUR | Mod+G |
| Whatsie | `com.ktechpit.whatsie` | flatpak | WhatsApp (Mod+Shift+B) |
| Vesktop | `vesktop-bin` | repo | Discord, 56 aberturas |
| Fluxer canary | `fluxer-canary-bin` | AUR | 41 aberturas |
| Discord | `discord` | repo | 25 aberturas |
| kitty | `kitty` | repo | terminal (Mod+Return) |
| Ghostty | `ghostty` | repo | terminal secundário |
| Sushi | `sushi` | repo | preview do Nautilus (Espaço) |
| Loupe | `loupe` | repo | imagens |
| mpv | `mpv` | repo | vídeo |
| Apostrophe | `org.gnome.gitlab.somas.Apostrophe` | flatpak | txt e md |
| Bitwarden | `bitwarden` | repo | senhas |
| VSCode | `visual-studio-code-bin` | AUR | editor |
| Claude Code | instalador nativo | script | `claude` |
| Godot | `godot` | repo | 42 aberturas |
| Flutter | `flutter-bin` | AUR | |
| Android Studio | `android-studio` | AUR | JDK do Flutter |
| Node + pnpm | `nodejs`, `pnpm` | repo | aqui o pnpm é standalone em `~/.local/bin` |
| Docker | `docker` | repo | |
| Seahorse | `seahorse` | repo | keyring sem senha, ver `AUTOLOGIN.md` |
| LocalSend | `localsend` | repo | mandar arquivo entre PC e celular |
| nirimod | `nirimod-git` | AUR | configurações do niri por interface |
| pacseek | `pacseek` | AUR | busca de pacotes (repo e AUR) no terminal |
| Omacalc | binário em `extras/omacalc/` | Omarchy | calculadora; precisa do `qt6-declarative` |

## Usados pelo config do niri

| Programa | Pacote | Origem | Quem usa |
|---|---|---|---|
| udiskie | `udiskie` | repo | automount (`cfg/autostart.kdl`) |
| gammastep | `gammastep` | repo | `nightlight-mono` (Mod+N) |
| gpu-screen-recorder | `gpu-screen-recorder` | repo | `grava-tui` (Mod+Print) |
| mpvpaper | `mpvpaper` | repo | screensaver |
| swayidle | `swayidle` | repo | screensaver com caffeine |
| Papirus | `papirus-icon-theme` | repo | ícones |
| papirus-folders | `papirus-folders` | AUR | cor das pastas segue o acento |
| Bibata-Modern-Ice | `bibata-cursor-theme-bin` | AUR | ponteiro (aqui foi copiado na mão pra `~/.local/share/icons`) |

Vários atalhos chamam scripts de `~/.local/bin` que não estão neste repo: `chrome-janela`, `niri-float-toggle`, `niri-float-daemon`, `nightlight-mono`, `audio-toggle`, `oled-refresh`, `omarchy-reminder`, `grava-tui`, `niri-sushi-center`, `niri-noctalia-reload`. Sem eles, esses atalhos não fazem nada.

## Terminal

`ripgrep`, `fd`, `jq`, `github-cli`, `btop`, `micro`, `just`, `fastfetch` (todos do repo).

## Opcional

- Jogos: `steam`, `faugus-launcher` (repo).
- `ollama`: aqui foi instalado por script, fora do pacman. Só vale com GPU decente.

## Instalação

Um comando por bloco.

```sh
sudo pacman -S kitty ghostty sushi loupe mpv bitwarden discord vesktop-bin godot nodejs pnpm docker seahorse localsend udiskie gammastep gpu-screen-recorder mpvpaper swayidle papirus-icon-theme qt6-declarative ripgrep fd jq github-cli btop micro just fastfetch
```

```sh
yay -S google-chrome fluxer-canary-bin visual-studio-code-bin flutter-bin android-studio papirus-folders bibata-cursor-theme-bin nirimod-git pacseek
```

Para instalar no notebook, siga o `INSTALL.md`: ele tem o script com fallbacks e o que muda em relação ao desktop.

```sh
flatpak install flathub app.zen_browser.zen com.ktechpit.whatsie org.gnome.gitlab.somas.Apostrophe
```

```sh
curl -fsSL https://claude.ai/install.sh | bash
```
