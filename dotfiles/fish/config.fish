source /usr/share/cachyos-fish-config/cachyos-config.fish

fish_add_path ~/.local/bin

# autologin: sobe o niri automaticamente ao logar no tty1.
# Sem `exec` de proposito: se o niri morrer, voce cai num prompt fish
# em vez de entrar em loop de login.
if status is-login; and test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
    # niri-session (nao `niri --session`): sobe o niri via systemd, o que ativa
    # graphical-session.target, requisito do xdg-desktop-portal-gnome, que e
    # quem fornece o ScreenCast (compartilhar tela). O `-l` evita que o script
    # re-execute o shell de login e caia em loop com este proprio bloco.
    niri-session -l
end

# overwrite greeting: no kitty roda o giffetch (gif animado + infos) quando o
# gif existe; nos demais casos mantem o fastfetch normal.
function fish_greeting
    if set -q KITTY_WINDOW_ID; and test -f ~/Downloads/giphy.gif
        giffetch
    else
        fastfetch
    end
end

# Starship prompt (Powerline com triangulos). Roda por ultimo p/ sobrescrever o Pure.
if type -q starship
    starship init fish | source
end
