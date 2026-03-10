# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Vim IDE configuration and system dotfiles setup for Vallabhdas Kansagara (`@vrkansagara`). It manages:
- A full Vim configuration (plugins, keybindings, language settings)
- Shell dotfiles (aliases, functions, prompt, PATH)
- System bootstrap scripts
- Utility binaries in `bin/`
- Installation/setup scripts for various tools and languages

## Installation & Bootstrap

```bash
# Fresh install (clone + setup)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vrkansagara/ide/master/install.sh)"

# Update existing install
cd $HOME/.vim
git stash
git pull --rebase
sh ./submodule.sh

# Bootstrap system packages + Oh My Zsh + jq/jp binaries
bash init.sh [--minimal] [--dry-run] [--no-upgrade] [--skip-ohmyzsh]
```

## Common Tasks

```bash
# Clean vendor/node_modules/pack dirs
make clean

# Docker-based services
make node-install        # install node modules via Docker
make elasticsearch-up    # start Elasticsearch
make elasticsearch-down  # stop Elasticsearch

# Shell: reload shell config (alias defined in my.sh)
ss   # unsets guard and re-sources ~/.zshrc

# Vim: profile startup time
viml    # starts vim with --startuptime /tmp/vim-startup.log
timezsh # runs 10x shell startup timing (bash_functions.sh)
profzsh # profiles zsh startup with ZPROF=true
```

## Vim Configuration Architecture

The Vim config loads in strict priority order from `vimrc.vim`:

1. **Priority 1** — `src/main.vim`: Core settings (encoding, indentation, keybindings, mapleader `,`), Alt-key terminal mappings, and global functions.
2. **Priority 2** — `src/Config/Plugin/*.vim`: Plugin-specific configs, loaded alphanumerically (prefixed `001-`, `003-`, etc. to control order). Active plugins: NERDTree, ctrlp, fzf, vim-fugitive, vim-airline, vim-gitgutter, vim-surround, vim-visual-multi, vim-prettier, vdebug, vim-quickui.
3. **Priority 3** — `src/Config/Vim/*.vim`: Vim built-in overrides (search, tabs, window, clipboard, keybindings, folding, diff, sessions, terminal, etc.).
4. **Priority 4** — `src/Config/Language/*.vim`: Filetype-specific settings (PHP, Go, Rust, sh, HTML, JSON, etc.).

Plugin pack directory is `pack/vendor/start/` (Vim 8 native package loading). `src/` is added to `runtimepath`.

Key Vim settings: `mapleader = ","`, `kj` mapped to `<Esc>`, arrow keys resize splits, `<F2>` strips trailing whitespace, `<Ins>` toggles paste mode, textwidth=120.

## Shell Dotfiles Architecture

All shell extensions live in `src/Dotfiles/shell/` and are sourced from `src/Dotfiles/shell/my.sh`, which is the single file to source from `~/.zshrc` or `~/.bashrc`.

| File | Purpose |
|---|---|
| `my.sh` | Entry point: PATH, exports, aliases, sources all others |
| `bash_functions.sh` | General functions: `Day`, `Battery`, `timezsh`, `profzsh`, `tgz`, `ft`, `f`, `lt`, `mkcd`, `machine` |
| `bash_color.sh` | ANSI color variables for PS1 prompt customization |
| `bash_improvement.sh` | Seeds `~/.inputrc` with case-insensitive completion if missing |
| `administrator_aliases.sh` | System admin aliases: fzf, disk, network, process, public IP, hardware |
| `docker_aliases.sh` | Docker/Compose aliases: `d`, `dc`, `dce`, `dcb`, `dcu`, `dcdV`, `dcl`, `dIps` |
| `php_aliases.sh` | PHP dev server aliases and Composer runner |
| `aws_aliases.sh` | EC2 metadata aliases (IMDSv1 + IMDSv2) |
| `svn_aliases.sh` | SVN shortcuts |

`my.sh` uses `typeset -aU path` (zsh deduplication) and guards all `source` calls with `[ -f ]`. Each file has a double-source guard (`_LOADED_*` variable).

`$MACHINE_TYPE` (exported by `machine()` in `bash_functions.sh`) holds the detected OS: `linux`, `mac`, `cygwin`, `mingw`, or `git`.

## Bin Utilities (`bin/`)

Custom executables available after `init.sh` runs:
- `jq`, `JMESPath` — downloaded binaries
- `composer`, `composer1`, `composer2` — PHP Composer wrappers
- `git-*` (`git-abort`, `git-continue`, `git-info`, `git-last`, `git-lg`, `git-mash`, `git-plane`, `git-reset-submodules`) — custom git subcommands
- `phpstan`, `phpmd`, `psalm` — PHP static analysis
- `brightness`, `hosts`, `countdown`, `speed_test.sh`, `firewall.sh`, `uuid.php` — system utilities

## `src/Sh/` Scripts

Install scripts for tools/languages, organized by category. Top-level scripts install individual tools (`docker.sh`, `nodejs.sh`, `composer.sh`, etc.). Subdirs: `languages/` (Go), `PHP/`, `Python/`, `Ruby/`, `Rust/`, `Aws/`, `Git/`, `System/`, `Font/`.

## Snippets

- UltiSnips format: `src/UltiSnips/*.snippets` (c, cpp, html, make, php, sh, vim)
- Legacy snipmate format: `src/snippets/` (c, sh, php)

## Key Paths

| Path | Purpose |
|---|---|
| `~/.vim/vimrc.vim` | Vim entry point (symlink target for `~/.vimrc`) |
| `~/.vim/src/main.vim` | Core Vim config |
| `~/.vim/src/Dotfiles/shell/my.sh` | Shell entry point to source |
| `~/.vim/src/Dotfiles/profile` | Login shell profile (NVM, Flutter, 1Password SSH agent) |
| `~/.vim/bin/` | Custom executables; must be in `$PATH` |
| `~/.vim/data/cache/zsh` | Zsh history file location |
| `~/.vim/pack/vendor/start/` | Vim 8 native plugin directory |

## Commit Convention

Always use **Conventional Commits** (https://www.conventionalcommits.org/en/v1.0.0/) for all commits.

Format:
```
<type>(<scope>): <short description>

[optional body]

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

### Types
| Type       | When to use                           |
|------------|---------------------------------------|
| `fix`      | Bug fix or incorrect value correction |
| `feat`     | New feature                           |
| `refactor` | Code restructure, no behavior change  |
| `chore`    | Maintenance, deps, tooling            |
| `docs`     | Documentation only                    |
| `style`    | Formatting, whitespace                |
| `perf`     | Performance improvement               |
| `ci`       | CI/CD pipeline changes                |

### Scopes for this repo
| Scope     | Target                          |
|-----------|---------------------------------|
| `display` | `bin/display.sh`                |
| `vim`     | `vimrc.vim`, `src/main.vim`     |
| `shell`   | `src/Dotfiles/shell/*`          |
| `bin`     | `bin/*` utilities               |
| `plugin`  | `pack/vendor/start/*`           |
| `lang`    | `src/Config/Language/*`         |
| `snippet` | `src/UltiSnips/*`, `src/snippets/*` |
| `init`    | `init.sh`, `install.sh`         |
