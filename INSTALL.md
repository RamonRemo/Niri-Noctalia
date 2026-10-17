# Guia de instalação: notebook com o setup do desktop

Guia pro Claude Code do notebook deixar o CachyOS Niri (+Noctalia) com a cara e a praticidade do desktop do Remo. Escrito em 17/10/2026.

**O notebook é da namorada do Remo, não dele.** O objetivo é trazer o que deixa o sistema gostoso e prático (visual, atalhos, apps do dia a dia como o Apostrophe), e não o que é pessoal dele: jogos, programação, engines, Discord e afins. Quem conduz a instalação é o Remo.

Arquivos de apoio neste repo:

- `cfg/`, `config.kdl`: config do niri do desktop.
- `bin/`: scripts que os atalhos e o autostart chamam.
- `systemd/user/`: unidade que faz o prompt do terminal seguir o tema.
- `dotfiles/`: kitty, fish, recorte das configs da noctalia e bookmarks.
- `extras/omacalc/`: calculadora (binário, atalho e ícone).
- `AUTOLOGIN.md`: o porquê do autologin e do keyring sem senha.

## Regras pro Claude

Leia antes de executar qualquer coisa.

1. **Não rode `sudo`.** Tudo que precisa de root vira um script por fase em `~/setup/`. Mostre o script, peça pro Remo rodar num terminal à parte (kitty ou Alacritty, não pelo `!` do Claude, porque o sudo pede senha) e leia o log que o script grava em `~/setup/*.log`.
2. **O que não precisa de root, faça você mesmo:** copiar arquivos, editar config do usuário, `systemctl --user`, `xdg-mime`, `gsettings`.
3. **Antes de sobrescrever qualquer arquivo, faça backup** com o sufixo `.bak-cachyos`.
4. **Comandos avulsos pro Remo:** um por bloco, nunca encadeados com `&&`.
5. **Não fique em loop com erro.** Tentou duas vezes e falhou, anote e siga para o próximo passo que não depende dele.
6. **No fim de cada fase, entregue um relatório nesta ordem:**
   1. O que funcionou.
   2. O que falhou, com a linha exata do erro.
   3. O que o Remo precisa fazer (instalar, logar, clicar), numerado.
   4. Decisões que só o Remo pode tomar.
7. **Git:** neste repo, nada de commit ou push sem OK do Remo na hora. Nunca adicione o trailer `Co-Authored-By`.
8. **Idioma:** pt-BR, curto e direto.
9. **Na dúvida se algo é "do Remo" ou "do sistema", pergunte** em vez de instalar.

O que o Remo chama de "ninja" é o **Sushi**, o preview do Nautilus na tecla Espaço. O pacote `ninja` é um build system e não tem nada a ver.

## Fase 0: perguntas e checagem

### Perguntas pro Remo (de uma vez só, antes de tudo)

1. Ela usa WhatsApp no computador? Se sim, entra o Whatsie (Super+Shift+B).
2. Quer o Chrome além do Zen?
3. Quer o Bitwarden (gerenciador de senhas)?
4. Quer o autologin direto na tela de bloqueio da noctalia (`AUTOLOGIN.md`)?
5. Wallpapers: os do Remo (copiados do desktop por LocalSend ou pendrive) ou os dela?
6. Gif animado na abertura do terminal (o `giffetch`)? Precisa do arquivo `giphy.gif` do desktop.

### Checagem (só leitura, você faz)

| O quê | Comando | Por quê |
|---|---|---|
| Usuário | `id -un` e `echo $HOME` | Os arquivos do repo têm `/home/remo` escrito. Na fase 2 você troca pelo `$HOME` do notebook. |
| Disco criptografado | `lsblk -f` | Procure `crypto_LUKS`. Sem LUKS, o keyring **não** pode ficar sem senha (fase 5). |
| Tela | `niri msg outputs` | Nome (`eDP-1`?), resolução e escala. Serve pra fase 6. |
| Internet | `ping -c1 archlinux.org` | Se não responder, o Remo conecta o Wi-Fi pelo painel da noctalia ou pelo `nmtui`. |
| AUR helper | `command -v yay paru` | O script da fase 1 usa o `yay`; se não houver, ele instala pelo repo `cachyos`. |
| Zen | `pacman -Q zen-browser-bin` e `flatpak list --app` | No desktop é flatpak. No notebook o Zen foi pelo pacman. O atalho e o navegador padrão mudam conforme a versão. |
| Pastas do usuário | `xdg-user-dir DESKTOP` e `xdg-user-dir PICTURES` | O atalho Super+E abre a Área de trabalho. Capturas vão pra `Imagens/Capturas`. Se as pastas tiverem nome em inglês, ajuste. |
| Teclado | `localectl status` | O desktop é `br-abnt2` e o niri não força layout. Se ela digitar e sair caractere errado, pergunte ao Remo qual é o teclado. |

Clone o repo fora do `~/.config/niri`:

```
git clone https://github.com/RamonRemo/Niri-Noctalia.git ~/Niri-Noctalia
```

## Fase 1: pacotes (script, o Remo roda)

O que entra e por quê:

| Pacote | Pra quê |
|---|---|
| `kitty`, `ttf-meslo-nerd`, `starship`, `fastfetch` | Terminal do Super+Enter, fonte com ícones, prompt colorido seguindo o tema. |
| `sushi` | Preview do Nautilus na tecla Espaço. |
| `loupe`, `mpv` | Imagens e vídeos. |
| `apostrophe` | Editor de txt e md, padrão pra esses arquivos. |
| `zen-browser-bin` | Navegador padrão. |
| `localsend` | Mandar arquivo entre celular e computador sem cabo. |
| `udiskie` | Monta pendrive e HD externo sozinho. |
| `papirus-icon-theme`, `papirus-folders`, `bibata-cursor-theme-bin` | Ícones, pastas na cor do tema e o ponteiro do desktop. |
| `nirimod-git` | Configurar o niri por interface, sem editar arquivo. |
| `pacseek` | Procurar e instalar programas pelo terminal. |
| `qt6-declarative` | Necessário pra calculadora (omacalc). |
| `libnotify`, `jq` | Usados pelos scripts dos atalhos. |
| `btop`, `micro` | Monitor do sistema e editor simples no terminal. |

Monte `~/setup/fase-1.sh` com base no modelo abaixo. Ligue as variáveis conforme as respostas da fase 0. Se a checagem mostrou erro de mirror, ligue `MIRRORS=sim`.

```bash
#!/usr/bin/env bash
# Fase 1: pacotes. Rodar como usuário normal; pede a senha do sudo.
set -u
MIRRORS=nao     # sim = reordena os mirrors antes (erro 404/timeout)
WHATSAPP=nao    # sim = Whatsie (flatpak)
CHROME=nao      # sim = Google Chrome (AUR)
BITWARDEN=nao   # sim = Bitwarden
AUTOLOGIN=nao   # sim = Seahorse, pra deixar o keyring sem senha (fase 5)
GIF=nao         # sim = imagemagick, usado pelo giffetch

mkdir -p ~/setup
LOG=~/setup/fase-1.log
exec > >(tee -a "$LOG") 2>&1
falhas=()

passo() {
  local nome=$1; shift
  echo; echo "==> $nome"
  "$@" || falhas+=("$nome")
}

# Um nome inexistente derruba a transação inteira do pacman. Por isso só
# entram os pacotes que o repo conhece; os outros viram falha no relatório.
repo() {
  local nome=$1; shift
  local ok=() p
  for p in "$@"; do
    if pacman -Si "$p" >/dev/null 2>&1; then ok+=("$p"); else falhas+=("ausente:$p"); fi
  done
  [ ${#ok[@]} -gt 0 ] && passo "$nome" sudo pacman -S --needed --noconfirm "${ok[@]}"
}

# No AUR, um por vez pelo mesmo motivo.
aur() {
  local p
  for p in "$@"; do passo "AUR $p" yay -S --needed --noconfirm "$p"; done
}

[ "$MIRRORS" = sim ] && passo "Mirrors" sudo cachyos-rate-mirrors

passo "Atualizar sistema" sudo pacman -Syu --noconfirm

repo "Base" \
  kitty ttf-meslo-nerd starship fastfetch \
  sushi loupe mpv apostrophe zen-browser-bin localsend \
  udiskie papirus-icon-theme libnotify qt6-declarative \
  jq btop micro yay

aur papirus-folders bibata-cursor-theme-bin nirimod-git pacseek

[ "$BITWARDEN" = sim ] && repo "Bitwarden" bitwarden
[ "$AUTOLOGIN" = sim ] && repo "Seahorse" seahorse
[ "$GIF" = sim ] && repo "imagemagick" imagemagick
[ "$CHROME" = sim ] && aur google-chrome

if [ "$WHATSAPP" = sim ]; then
  repo "Flatpak" flatpak
  passo "Flathub" sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  passo "Whatsie" sudo flatpak install -y flathub com.ktechpit.whatsie
fi

echo
if [ ${#falhas[@]} -eq 0 ]; then
  echo "== FASE 1 OK =="
else
  echo "== FASE 1 COM FALHAS: ${falhas[*]} =="
fi
```

Peça pro Remo rodar num terminal à parte:

```
bash ~/setup/fase-1.sh
```

Depois leia `~/setup/fase-1.log`.

Fallbacks:

| Falha | O que fazer |
|---|---|
| `failed retrieving file ... 404` | Base desatualizada. Rodar de novo com `MIRRORS=sim`. |
| `signature is unknown trust` | Script curto com `sudo pacman -Sy archlinux-keyring cachyos-keyring` seguido de `sudo pacman -Syu`. Nunca `-Sy` sozinho seguido de `-S`. |
| Conflito de pacote (`are in conflict`) | O `--noconfirm` recusa. Mostre o conflito ao Remo e deixe ele escolher. |
| Flatpak falhou | Plano B do WhatsApp: abrir `web.whatsapp.com` no navegador e fixar. |
| AUR falhou num pacote | Siga sem ele e reporte. Sem o `bibata-cursor-theme-bin`, o ponteiro fica no padrão. |

## Fase 2: arquivos do usuário (você faz)

### Niri

```
cp -a ~/.config/niri ~/.config/niri.bak-cachyos
```

Copie `config.kdl` e `cfg/animation.kdl`, `autostart.kdl`, `input.kdl`, `keybinds.kdl`, `layout.kdl`, `misc.kdl` e `rules.kdl` do repo para `~/.config/niri/`. **Não copie o `cfg/display.kdl`**: ele descreve os dois monitores do desktop. Mantenha o do notebook.

O `config.kdl` inclui `noctalia.kdl`, que a noctalia gera e está no `.gitignore`. Crie vazio pra o niri não falhar até a noctalia gerar:

```
touch ~/.config/niri/noctalia.kdl
```

Ajustes obrigatórios no notebook:

| Arquivo | Linha do desktop | No notebook |
|---|---|---|
| `keybinds.kdl` | `Mod+B ... spawn "flatpak" "run" "app.zen_browser.zen"` | Se o Zen for do pacman: `spawn "zen-browser"`. Confirme o binário com `pacman -Ql zen-browser-bin \| rg bin/`. |
| `keybinds.kdl` | `Mod+N` e `Mod+Shift+N` (`nightlight-mono`, um por monitor) | Um só: `Mod+N repeat=false hotkey-overlay-title="Luz noturna" { spawn-sh "noctalia msg nightlight-force-toggle"; }`. Apague o `Mod+Shift+N`. |
| `keybinds.kdl` | `Mod+Shift+B` (Whatsie) | Apagar se ela não quis o WhatsApp. |
| `keybinds.kdl` | `Mod+G` e `Mod+Shift+G` (Chrome) | Apagar se ela não quis o Chrome. |
| `keybinds.kdl` | `Mod+M`, `Mod+Shift+O`, `Mod+Shift+S`, `Mod+Print` | Apagar. São de fone, OLED, screensaver e gravação de tela do desktop. |
| `keybinds.kdl` | `Mod+E ... "/home/remo/Área de trabalho"` | Usar o caminho que `xdg-user-dir DESKTOP` devolveu. |
| `autostart.kdl` | `niri msg action focus-monitor DP-1` | Apagar. |

Troque o caminho do Remo pelo do notebook em tudo que foi copiado (fase 2 inteira e fase 3):

```
rg -l '/home/remo' ~/.config/niri ~/.local/bin ~/.config/kitty ~/.config/fish
```

Em cada arquivo listado: `sed -i "s|/home/remo|$HOME|g" <arquivo>`.

Por último, confira se algum atalho ainda chama programa que não existe. Liste os `spawn` do `keybinds.kdl` e teste cada binário com `command -v`. O que não existir, apague o atalho.

Valide e recarregue. O niri não observa arquivos incluídos, então salvar não basta:

```
niri validate
```

```
niri msg action load-config-file
```

### Scripts e unidades

- Copie `bin/*` pra `~/.local/bin/` e dê `chmod +x`. Sem Chrome, pode pular o `chrome-janela`. Sem o gif, pode pular o `giffetch`.
- Copie `systemd/user/*` pra `~/.config/systemd/user/`, depois rode `systemctl --user daemon-reload` e `systemctl --user enable --now noctalia-starship.path`.

O que cada script faz:

| Script | Quem chama | Função |
|---|---|---|
| `niri-float-toggle`, `niri-float-daemon` | Super+Shift+T, autostart | Modo "janela nova abre flutuante" por monitor. |
| `niri-sushi-center` | autostart | Mantém o preview do Sushi centralizado. |
| `niri-noctalia-reload` | autostart | Recarrega o niri quando a noctalia regenera as cores e reinjeta o Alt+Tab. |
| `omarchy-reminder`, `omarchy-notification-send` | Super+F12 | Lembrete rápido: "me avisa em X minutos". |
| `noctalia-papirus-folders` | hook da noctalia | Cor das pastas segue o tema. |
| `noctalia-starship` | `noctalia-starship.path` | Prompt do terminal segue o tema. |
| `reiniciar-noctalia` | bookmark | Reinicia a noctalia se ela travar. |
| `chrome-janela` | Super+G | Nova janela do Chrome (só com Chrome). |
| `giffetch` | fish no kitty | Gif animado + infos na abertura do terminal (só com o gif). |

### Calculadora (omacalc)

Portada do Omarchy (licença MIT). Não existe no AUR: o binário está em `extras/omacalc/`. A regra que abre ela flutuante já está no `cfg/rules.kdl`.

- `extras/omacalc/omacalc` → `~/.local/bin/omacalc` (`chmod +x`).
- `extras/omacalc/omacalc.desktop` → `~/.local/share/applications/`.
- `extras/omacalc/omacalc.svg` → `~/.local/share/icons/hicolor/scalable/apps/`.

Se não abrir, `ldd ~/.local/bin/omacalc | rg 'not found'` mostra qual biblioteca falta.

### Terminal

- `dotfiles/kitty/kitty.conf` → `~/.config/kitty/kitty.conf`. Fonte MesloLGS Nerd Font 13, 85% de opacidade, tema da noctalia.
- `dotfiles/fish/config.fish` → `~/.config/fish/config.fish`. O bloco do autologin é inofensivo sem o autologin: só age em login no tty1.
- Gif do `giffetch`: se o Remo trouxer, vai em `~/Downloads/giphy.gif`. Sem ele, o terminal mostra o fastfetch normal.

### Apostrophe, Loupe e Zen como padrão

```
xdg-mime default org.gnome.gitlab.somas.Apostrophe.desktop text/plain text/markdown text/x-markdown application/x-zerosize
```

```
xdg-mime default org.gnome.Loupe.desktop image/png image/jpeg image/gif image/webp image/bmp image/tiff image/svg+xml image/avif image/heif image/x-icon
```

Pro Zen, descubra o `.desktop` primeiro (`ls /usr/share/applications | rg -i zen` no pacman, `app.zen_browser.zen.desktop` no flatpak) e use o nome nos dois comandos:

```
xdg-settings set default-web-browser zen.desktop
```

```
xdg-mime default zen.desktop text/html x-scheme-handler/http x-scheme-handler/https x-scheme-handler/about x-scheme-handler/unknown
```

Confira com `xdg-mime query default text/markdown` e `xdg-settings get default-web-browser`.

### Cursor, ícones e tema GTK

O cursor precisa estar em quatro lugares. Mudar um só não pega em todo app.

1. `~/.config/niri/cfg/misc.kdl`: já vem do repo com `xcursor-theme "Bibata-Modern-Ice"` e tamanho 24.
2. `~/.config/gtk-3.0/settings.ini` e `~/.config/gtk-4.0/settings.ini`, na seção `[Settings]`:
   ```ini
   gtk-application-prefer-dark-theme=true
   gtk-cursor-theme-name=Bibata-Modern-Ice
   gtk-font-name=Noto Sans 10
   gtk-icon-theme-name=Papirus-Dark
   gtk-theme-name=adw-gtk3
   ```
3. gsettings:
   ```
   gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
   ```
   ```
   gsettings set org.gnome.desktop.interface cursor-size 24
   ```
   ```
   gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
   ```
   ```
   gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
   ```
   ```
   gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
   ```
4. `~/.icons/default/index.theme`, fallback pra apps X11:
   ```ini
   [Icon Theme]
   Name=Default
   Comment=Default cursor theme
   Inherits=Bibata-Modern-Ice
   ```

## Fase 3: noctalia (você faz)

A noctalia reescreve o `~/.local/state/noctalia/settings.toml` enquanto roda. **Edição com ela viva se perde.**

1. Pare a noctalia:
   ```
   pkill -x noctalia
   ```
2. Faça backup do `settings.toml`.
3. Mescle `dotfiles/noctalia/settings-notebook.toml` no `settings.toml`. Seção que existe nos dois: a do repo vence. Seção que só existe no notebook: fica. O topo do arquivo do repo explica o que ficou de fora e por quê. Troque `/home/remo` pelo `$HOME` do notebook.
4. Valide. Chave errada derruba a shell inteira:
   ```
   noctalia config validate ~/.local/state/noctalia/settings.toml
   ```
5. Suba de novo:
   ```
   niri msg action spawn -- noctalia
   ```
6. Plugins. O `settings.toml` já lista as fontes (official e community) e os três habilitados: **notes** (anotações, Super+A), **bookmarks** (atalhos de comando na barra) e **noctes** (post-it na área de trabalho). Atualize as fontes e confira:
   ```
   noctalia msg plugins update community
   ```
   ```
   noctalia msg plugins update official
   ```
   ```
   noctalia msg plugins list
   ```
   Se algum não estiver habilitado: `noctalia msg plugins enable <autor/plugin>`.
7. Bookmarks. Depois que o plugin subiu uma vez, copie `dotfiles/noctalia/bookmarks.json` pra `~/.local/state/noctalia/plugins/data/dunarand/bookmarks/data.json`, troque o `/home/remo` e reinicie a noctalia. Esse arquivo é legível por qualquer usuário: nunca coloque senha nele.
8. Gere os temas (kitty, GTK, borda do niri):
   ```
   noctalia msg templates-apply
   ```
   Confira se apareceram `~/.config/kitty/themes/noctalia.conf`, `~/.config/gtk-4.0/noctalia.css` e o `~/.config/niri/noctalia.kdl` preenchido. Depois rode `~/.local/bin/noctalia-starship` uma vez pra gerar o prompt.
9. Post-its: ela cria pelo botão "Nova" no painel do noctes.

Pra ver erro da noctalia (ela manda o log pro /dev/null):

```
pkill -x noctalia; nohup noctalia >/tmp/noctalia.log 2>&1 &
```

## Fase 4: root (script, o Remo roda)

Monte `~/setup/fase-4.sh`. Ligue o `AUTOLOGIN` conforme a fase 0. **Só ligue o autologin depois que o `config.fish` da fase 2 estiver no lugar.** Sem ele, o boot cai num prompt do fish no tty1. Nesse caso, digitar `niri-session` resolve.

```bash
#!/usr/bin/env bash
# Fase 4: configuração de sistema. Rodar como usuário normal; pede a senha do sudo.
set -u
AUTOLOGIN=nao   # sim = autologin no tty1 e desliga o display manager

mkdir -p ~/setup
LOG=~/setup/fase-4.log
exec > >(tee -a "$LOG") 2>&1
falhas=()
USUARIO=$(id -un)

echo "==> papirus-folders sem senha (cor das pastas segue o tema)"
printf '%s ALL=(root) NOPASSWD: /usr/bin/papirus-folders\n' "$USUARIO" \
  | sudo tee /etc/sudoers.d/papirus-folders >/dev/null \
  && sudo chmod 440 /etc/sudoers.d/papirus-folders \
  && sudo visudo -cf /etc/sudoers.d/papirus-folders \
  || falhas+=("sudoers")

if [ "$AUTOLOGIN" = sim ]; then
  echo "==> Autologin no tty1"
  sudo mkdir -p /etc/systemd/system/getty@tty1.service.d \
    && printf '[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin %s --noclear %%I $TERM\n' "$USUARIO" \
      | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null \
    || falhas+=("autologin")

  dm=$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)" .service)
  if [ -n "$dm" ] && [ "$dm" != "display-manager" ]; then
    echo "==> Desligando o display manager: $dm"
    sudo systemctl disable "$dm" || falhas+=("disable $dm")
  fi
fi

echo
if [ ${#falhas[@]} -eq 0 ]; then
  echo "== FASE 4 OK (reinicie pra valer o autologin) =="
else
  echo "== FASE 4 COM FALHAS: ${falhas[*]} =="
fi
```

```
bash ~/setup/fase-4.sh
```

## Fase 5: com o Remo (interface gráfica e logins)

Entregue esta lista numerada, só com os itens que se aplicam:

1. **Keyring "Login" sem senha**, só com autologin e só se a fase 0 achou LUKS (`AUTOLOGIN.md`, passo 5). Seahorse, seção "Senhas", botão direito em "Login", "Alterar senha", nova senha vazia. Sem LUKS, não fazer. Nesse caso o histórico do Super+V só grava depois de destravar o keyring.
2. **Logins dela:** Zen (conta Firefox, se ela tiver), Chrome, Bitwarden, Whatsie (QR code).
3. **Noctalia pela UI:** foto de perfil, conta do Google no calendário (se ela quiser), wallpaper.
4. **Wallpapers** em `~/Imagens/Wallpapers`. A troca automática a cada 15 minutos depende de ter imagem lá.

## Fase 6: só no notebook, só se precisar

Aplique apenas se aparecer janela cortando ou estourando, como na tela de configurações da noctalia. Um ajuste por vez, testando entre eles. No desktop nada disso existe.

O niri entrega a altura certa: o corte acontece dentro do app quando sobra pouca altura lógica (altura da tela ÷ escala, menos a barra e os gaps).

1. **Escala menor.** É o que mais resolve. No `cfg/display.kdl` do notebook, com o nome que o `niri msg outputs` mostrou:
   ```kdl
   output "eDP-1" {
       scale 1.25
   }
   ```
   Use 1.25 em telas acima de 1080p e 1 em 1080p.
2. **Coluna na largura toda e gaps menores.** No `layout` que já existe em `cfg/layout.kdl`, troque o valor de `gaps` e acrescente uma linha, sem criar outro bloco:
   ```kdl
   gaps 8
   default-column-width { proportion 1.0; }
   ```
3. **Paliativo:** Super+F na janela (tela cheia) ou barra mais fina ou com `auto_hide = true` na noctalia.

Depois de cada um: `niri msg action load-config-file`.

## Não levar

Coisas do Remo, não do sistema:

- Jogos (Steam, Faugus), programação (VSCode, Flutter, Android Studio, Godot, Docker, Node), Discord, Vesktop, Fluxer, Ghostty, GitHub CLI.
- Plugin gamer-mode da noctalia e os templates de tema do VSCode, Godot e Discord.
- Config e plugins do Claude Code do desktop.
- Projetos dele: grava-tela, netgraph, screensaver-oled.

Coisas que só fazem sentido no hardware do desktop:

- `cfg/display.kdl` (OLED no DP-1 e ultrawide no DP-2).
- `nightlight-mono`, `audio-toggle`, `oled-refresh`, `screensaver-agora` e o `[idle]` do screensaver.
- Serviços `mic-guard`, `oled-audio-guard`, `screensaver-oled-caffeine` e `amdgpu-pin-mclk`.
- Bookmarks de backup no SSD e de monitor replica/estende.

## Problemas conhecidos

| Sintoma | Causa | Saída |
|---|---|---|
| Niri não pega a mudança no `cfg/*.kdl` | O niri só observa o `config.kdl` | `niri msg action load-config-file` |
| Niri reclama de include | `noctalia.kdl` ausente | `touch ~/.config/niri/noctalia.kdl` |
| Edição no `settings.toml` sumiu | Noctalia estava rodando | `pkill -x noctalia`, editar, validar, subir |
| Noctalia diz "não instalado" logo depois de instalar | Ela checa binários só no start | Reiniciar a noctalia |
| Histórico do Super+V não persiste | Keyring "Login" travado | Fase 5 item 1, ou destravar e reiniciar a noctalia |
| Plugin não aparece e não dá erro | Log vai pro /dev/null | Subir a noctalia com log (fim da fase 3) |
| Kitty com cores padrão | Tema ainda não gerado | `noctalia msg templates-apply` |
| Prompt sem cor | `starship.toml` ainda não gerado | `~/.local/bin/noctalia-starship` |
| Nautilus não muda de cor ou de ícone | Nautilus fica rodando em segundo plano | `nautilus -q` e reabrir |
| Pastas do Papirus não mudam de cor | Falta a regra do sudoers, ou o acento é azul (parece igual ao padrão) | Conferir `/etc/sudoers.d/papirus-folders`; testar com wallpaper de cor forte |
| Atalho não faz nada | Script com `/home/remo` errado, ou programa não instalado | `niri msg action spawn -- <comando>` mostra o erro |
| Tela de configuração cortada | Pouca altura lógica | Fase 6 |
