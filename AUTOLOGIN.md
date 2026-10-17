# Autologin direto na tela de bloqueio do noctalia

Boot sem display manager: o tty1 loga sozinho, o fish sobe o niri e o autostart do niri trava a tela com o noctalia. A senha é digitada só na tela de bloqueio.

## Pré-requisito: disco criptografado (LUKS)

Este setup deixa o keyring "Login" sem senha (passo 5). Isso só é seguro com o disco criptografado, porque a senha do LUKS no boot vira a única barreira real. Sem LUKS, quem bootar um pendrive lê o keyring em texto puro (senhas do Chrome, tokens do VSCode e do GitHub). A tela de bloqueio não protege contra isso.

Ative a criptografia no instalador do CachyOS.

## 1. Autologin no tty1

`/etc/systemd/system/getty@tty1.service.d/autologin.conf`:

```ini
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin remo --noclear %I $TERM
```

Troque `remo` pelo usuário da máquina.

## 2. Desligar o display manager

Descobrir qual veio instalado:

```sh
systemctl status display-manager
```

Se for o SDDM:

```sh
sudo systemctl disable sddm
```

## 3. Subir o niri pelo fish

No `~/.config/fish/config.fish`:

```fish
# Sem `exec` de propósito: se o niri morrer, cai num prompt fish
# em vez de entrar em loop de login.
if status is-login; and test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
    # niri-session (não `niri --session`): sobe o niri via systemd e ativa o
    # graphical-session.target, que o xdg-desktop-portal-gnome exige pro
    # compartilhamento de tela. O -l evita que o script re-execute o shell de
    # login e caia em loop com este próprio bloco.
    niri-session -l
end
```

## 4. Travar a tela no start

Já está em `cfg/autostart.kdl`:

```kdl
spawn-at-startup "noctalia"
spawn-sh-at-startup "for i in $(seq 60); do noctalia msg session lock && break; sleep 0.5; done"
```

## 5. Keyring "Login" sem senha

**Problema:** no autologin ninguém digita senha no PAM, e é essa senha que destrava o keyring "Login" do gnome-keyring. A senha da tela do noctalia só vem depois que o noctalia já subiu. Com o keyring travado:

- o histórico do clipboard do noctalia (Super+V) não grava, porque a chave-mestra dele fica no keyring;
- Chrome, VSCode e Nautilus (senhas salvas) pedem pra destravar o keyring.

**Solução:** senha do keyring "Login" em branco. Ele destrava sozinho quando o daemon sobe, antes do noctalia checar a chave.

1. Instalar o Seahorse: `sudo pacman -S seahorse`
2. Abrir o Seahorse e ir na seção "Senhas" da lateral.
3. Botão direito em "Login", depois "Alterar senha".
4. Senha atual = senha da conta. Nova = vazia. Confirmar o aviso de que fica sem criptografia.

A senha da conta e a do sudo não mudam: a senha do keyring é separada.

Conferir:

```sh
busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked
```

Tem que responder `b false`.

O noctalia checa a chave do clipboard só no start. Se o keyring estava travado quando ele subiu, reinicie o noctalia depois de destravar:

```sh
kill -TERM (pgrep -x noctalia)
```

```sh
niri msg action spawn -- noctalia
```

### Opcional

No desktop também existe esta linha em `/etc/pam.d/login`, logo depois de `auth include system-local-login`:

```
auth       optional     pam_gnome_keyring.so
```

Ela faz a tela do noctalia destravar o keyring quando ele tem senha. Com o keyring em branco fica redundante, mas é inofensiva.
