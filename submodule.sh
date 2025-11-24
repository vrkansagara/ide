#!/usr/bin/env bash
# ============================================================================
# Maintainer: Vallabhdas Kansagara <vrkansagara@gmail.com>
# Description: Automated setup of Vim dependencies using git submodules
# ============================================================================

set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------------------------------------------
# Options
# ----------------------------------------------------------------------------
[[ "${1:-}" == "-v" ]] && set -x

if [[ "$(id -u)" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

# ----------------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------------
CURRENT_DATE=$(date +'%Y-%m-%d %H:%M:%S')
VIM_DIRECTORY="$HOME/.vim"
CLONE_DIRECTORY="$VIM_DIRECTORY/pack/vendor/start"
LOG_FILE="/tmp/vim-install.log"

mkdir -p "$CLONE_DIRECTORY"

# ----------------------------------------------------------------------------
# Colorized output
# ----------------------------------------------------------------------------
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

log()   { echo -e "${CYAN}[*]${RESET} $*"; }
info()  { echo -e "${GREEN}[✔]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[✘]${RESET} $*" >&2; }

# ----------------------------------------------------------------------------
# Safe submodule add (idempotent)
# ----------------------------------------------------------------------------
add_submodule() {
  local repo_url=$1
  local dest_path=$2
  local name
  name=$(basename "$repo_url")

  if [[ -d "$VIM_DIRECTORY/$dest_path/.git" ]]; then
    warn "$name already exists, skipping..."
  else
    log "Installing $name..."
    git submodule add -f --depth=1 "$repo_url" "$dest_path" >>"$LOG_FILE" 2>&1 || {
      warn "Submodule $name failed, skipping."
    }
  fi
}

# ----------------------------------------------------------------------------
# Remove vendor modules
# ----------------------------------------------------------------------------
remove_vim_vendor_module() {
  read -r -p "Do you want to remove all Vim vendor modules? [y/N]: " input
  case "${input,,}" in
    y|yes)
      warn "Removing Vim vendors and submodules..."
      ${SUDO} rm -rf "$VIM_DIRECTORY/vendor"/* "$VIM_DIRECTORY/pack"/*
      ${SUDO} find "$VIM_DIRECTORY/.git/modules" -mindepth 1 -delete 2>/dev/null || true
      > "$VIM_DIRECTORY/.gitmodules"
      ;;
    *)
      info "Skipping removal of existing modules."
      ;;
  esac
}

# ----------------------------------------------------------------------------
# Main setup
# ----------------------------------------------------------------------------
main() {
  cd "$VIM_DIRECTORY" || { error "Vim directory not found."; exit 1; }

  echo "=========================================================="
  echo " Vim Submodule Installation started at $CURRENT_DATE"
  echo "=========================================================="

  remove_vim_vendor_module

  # Core plugins
  add_submodule https://github.com/junegunn/fzf.git                         pack/vendor/start/fzf
  add_submodule https://github.com/junegunn/fzf.vim.git                     pack/vendor/start/fzf.vim
  add_submodule https://github.com/tpope/vim-commentary.git                 pack/vendor/start/vim-commentary
  add_submodule https://github.com/mg979/vim-visual-multi.git               pack/vendor/start/vim-visual-multi
  add_submodule https://github.com/tpope/vim-surround.git                   pack/vendor/start/vim-surround
  add_submodule https://github.com/tpope/vim-fugitive.git                   pack/vendor/start/vim-fugitive
  add_submodule https://github.com/ctrlpvim/ctrlp.vim.git                   pack/vendor/start/ctrlp
  add_submodule https://github.com/mileszs/ack.vim.git                      pack/vendor/start/ack
  add_submodule https://github.com/airblade/vim-gitgutter.git               pack/vendor/start/vim-gitgutter
  add_submodule https://github.com/vim-airline/vim-airline.git              pack/vendor/start/vim-airline
  add_submodule https://github.com/vim-airline/vim-airline-themes.git       pack/vendor/start/vim-airline-themes
  add_submodule https://github.com/arnaud-lb/vim-php-namespace.git          pack/vendor/start/vim-php-namespace
  add_submodule https://github.com/preservim/nerdtree.git                   pack/vendor/start/nerdtree
  add_submodule https://github.com/mattn/emmet-vim.git                      pack/vendor/start/emmet-vim
  add_submodule https://github.com/tbknl/vimproject.git                     pack/vendor/start/vimproject
  add_submodule https://github.com/rust-lang/rust.vim.git                   pack/vendor/start/rust
  add_submodule https://github.com/kdheepak/JuliaFormatter.vim.git          pack/vendor/start/JuliaFormatter
  add_submodule https://github.com/skywind3000/vim-quickui.git              pack/vendor/start/vim-quickui

  # Color themes
  add_submodule https://github.com/NLKNguyen/papercolor-theme.git           pack/colors/start/papercolor-theme
  add_submodule https://github.com/gosukiwi/vim-atom-dark.git               pack/colors/start/vim-atom-dark
  add_submodule https://github.com/google/vim-colorscheme-primary.git       pack/colors/start/vim-colorscheme-primary
  add_submodule https://github.com/vim-scripts/peaksea.git                  pack/colors/start/peaksea
  add_submodule https://github.com/mattn/emmet-vim.git                     pack/vendor/start/emmnet-vim

  # Update all submodules
  log "Updating submodules recursively..."
  git submodule update --init --recursive --jobs 4 --remote --merge

  # Composer setup
  if [[ -x "$VIM_DIRECTORY/bin/composer" ]]; then
    log "Running composer install..."
    "$VIM_DIRECTORY/bin/composer" self-update
    "$VIM_DIRECTORY/bin/composer" install \
      --prefer-dist --no-scripts --no-progress --no-interaction --no-dev
  else
    warn "Composer binary not found under $VIM_DIRECTORY/bin/"
  fi

  info "Submodule installation completed successfully!"
  echo "See log file at $LOG_FILE"
}

main "$@"
