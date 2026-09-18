# Blair Arch

A reproducible, Omarchy-inspired Arch Linux setup built around Hyprland + Dank Material Shell (Quickshell), with a terminal-first development environment.

## Assumptions

This is a **post-install** setup. It does not partition disks, install a bootloader, create users, or configure sudo.

Start with a working Arch installation, internet access, and a normal user with sudo privileges.

## Install

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/blair-arch.git
cd blair-arch
./install.sh
```

Reboot and choose Hyprland from SDDM.

The installer is designed to be rerunnable. `pacman --needed` skips packages already present and GNU Stow owns the managed dotfiles.

## Updating this repo from a configured machine

When you add/remove explicitly installed packages:

```bash
cd ~/path/to/blair-arch
./sync.sh
git diff
git add .
git commit -m "Update Arch setup"
git push
```

Dotfiles under `dotfiles/` are symlinked into your home directory with GNU Stow. Editing `~/.config/hypr/hyprland.lua`, for example, edits the file in this repository directly, so normal `git status` will see it without a sync step.

## Applying repo changes to a machine

```bash
cd ~/path/to/blair-arch
./update.sh
```

That performs a fast-forward `git pull` and reruns the idempotent installer.

## What is deliberately not versioned

Do not put secrets in this repo. In particular, keep these out of dotfiles:

- `~/.ssh/`
- `~/.aws/`
- API tokens
- browser profiles
- passwords / private keys
- machine-specific VPN credentials

The installer also does not automatically choose an NVIDIA driver. NVIDIA driver selection can depend on GPU generation and kernel/module choice.

## Main keybindings

| Key | Action |
| --- | --- |
| `SUPER + Return` | Kitty terminal |
| `SUPER + E` | Thunar |
| `SUPER + Space` | DMS launcher |
| `SUPER + V` | Clipboard |
| `SUPER + ,` | DMS settings |
| `SUPER + X` | Power menu |
| `SUPER + Q` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + H/J/K/L` | Vim-style focus |
| `SUPER + 1..9` | Workspace |
| `SUPER + SHIFT + 1..9` | Move window |
| `SUPER + mouse-left` | Move window |
| `SUPER + mouse-right` | Resize window |
| 3-finger horizontal swipe | Switch workspace |

### A note about `sync.sh`

`sync.sh` records all explicitly installed repository/AUR packages. Review the diff before committing because a particular machine may have hardware-specific packages (for example CPU microcode or GPU drivers) that you may not want on every computer.
