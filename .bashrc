# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# -----------------------------------------------------------------------------
# ## 1. ENVIRONMENT VARIABLES
# -----------------------------------------------------------------------------
# Set these early, as other tools may rely on them.
# Make sure $EDITOR is set (e.g., export EDITOR="nvim")
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# -----------------------------------------------------------------------------
# ## 2. BASH SHELL SETTINGS
# -----------------------------------------------------------------------------

# History control
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Autocompletion
if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# Ensure command hashing is off for mise
set +h

# -----------------------------------------------------------------------------
# ## 3. TOOL INITIALIZATION
# -----------------------------------------------------------------------------
# Activate modern tools. This is done before aliases and functions
# that might depend on them.

if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

if command -v fzf &>/dev/null; then
  if [[ -f /usr/share/fzf/completion.bash ]]; then
    source /usr/share/fzf/completion.bash
  fi
  if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
  fi
fi

# -----------------------------------------------------------------------------
# ## 4. ALIASES
# -----------------------------------------------------------------------------

# File System (Use `eza` if installed, otherwise fallback to `ls`)
if command -v eza &>/dev/null; then
  alias ls='eza -lha --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
else
  alias ls='ls --color=auto -F'
  alias lsa='ls -la'
fi

# Tools
alias grep='grep --color=auto'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias d='docker'
alias r='rails'
alias decompress="tar -xzf"

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias e='exit'
alias c='clear'

# -----------------------------------------------------------------------------
# ## 5. FUNCTIONS
# -----------------------------------------------------------------------------

# After 'zoxide init', add this:
if command -v zoxide &>/dev/null; then
  # Alias 'cd' to our new "z-and-ls" function
  alias cd="__z_and_ls"

  __z_and_ls() {
    # Call zoxide's hook. It will handle all cases:
    # - `cd` (no args) -> home
    # - `cd /path`     -> /path
    # - `cd project`   -> fuzzy jump
    if z "$@"; then
      # If 'z' was successful, run 'ls'
      ls
    else
      # If 'z' failed, return an error
      return 1
    fi
  }
fi

# Open file with default GUI app in the background
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Open nvim in current directory or on specified files
n() {
  if [ "$#" -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

# Create a compressed archive
compress() {
  tar -czf "${1%/}.tar.gz" "${1%}"
}

### Media Transcoding
transcode-video-1080p() {
  ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

transcode-video-4K() {
  ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

img2jpg() {
  magick $1 -quality 95 -strip ${1%.*}.jpg
}

img2jpg-small() {
  magick $1 -resize 1080x\> -quality 95 -strip ${1%.*}.jpg
}

img2png() {
  magick "$1" -strip -define png:compression-filter=5 \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${1%.*}.png"
}

### ⚠️ DANGEROUS DISK UTILITIES ⚠️
iso2sd() {
  if [ $# -ne 2 ]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
    echo -e "\nAvailable SD cards:"
    lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
  else
    sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
    sudo eject $2
  fi
}

format-drive() {
  if [ $# -ne 2 ]; then
    echo "Usage: format-drive <device> <name>"
    echo "Example: format-drive /dev/sda 'My Stuff'"
    echo -e "\nAvailable drives:"
    lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
  else
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -rp "Are you sure you want to continue? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo wipefs -a "$1"
      sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
      sudo parted -s "$1" mklabel gpt
      sudo parted -s "$1" mkpart primary ext4 1MiB 100%
      sudo mkfs.ext4 -L "$2" "$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
      sudo chmod -R 777 "/run/media/$USER/$2"
      echo "Drive $1 formatted and labeled '$2'."
    fi
  fi
}

# -----------------------------------------------------------------------------
# ## 6. FALLBACK PROMPT
# -----------------------------------------------------------------------------
# This will be used if `starship` is not installed or fails to load.

force_color_prompt=yes
color_prompt=yes

# Set window title to current directory and prompt to an icon
# Requires a Nerd Font to see the icon.
_prompt_icon=$'\uf0a9 ' # 📥 icon
PS1="\[\e]0;\w\a\]${_prompt_icon}"

# Enable Kitty Shell Integration
if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="enabled"
  source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi

# Alias for icat
alias icat="kitten icat"
