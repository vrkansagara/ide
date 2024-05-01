# My editor my way :heart:

My every day editor for all kind of text interface work

This editor keep the philosophy of `unix`

## Do one thing and do it well

```bash
Linux User :- If there is terminal there is a way.
Developer User :- If there is vim there is geek.
```

## Basic Installation

`IDE` is installed by running one of the following commands in your terminal.
You can install this via the command-line with
either `curl`, `wget` or another similar tool.

| Method    | Command                                                                                     |
| :-------- | :------------------------------------------------------------------------------------------ |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/vrkansagara/ide/master/install.sh)"` |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/vrkansagara/ide/master/install.sh)"`   |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/vrkansagara/ide/master/install.sh)"` |

### How can I update this project

You can simply run bellow command to update, this project

```bash
 cd $HOME/.vim
 git stash
 git pull --rebase
 sh ./submodule.sh
```

#### Documents

[Docs](src/Docs/README.md)

#### Do's and don't

- Do not use `CTRL+S` this is standard terminal suspension
command (Press `CTRL+Q` will resume)
- vim -c "redir >> /tmp/vim-shortcuts.log" -c "map" -c "redir END" -c "qa" 

#### VIM Screen

![VimTerminal](src/Images/vim-terminal.png?raw=true "VimTerminal")
![Light](src/Images/light.png?raw=true "light")
![DarkVim](src/Images/dark-vim.png?raw=true "Dark VIM")
![Light](src/Images/light.png?raw=true "light")
![LightVim](src/Images/light-vim.png?raw=true "Light VIM")

#### You can

I would like take issue and pull request regarding this project and
love to answer if anything on this. I would be more happy if you have on this.

#### Reference(s)
- [VIM official help](!https://www.vim.org/docs.php)
- [VimL Script language](!https://en.wikibooks.org/wiki/Learning_the_vi_Editor/Vim/VimL_Script_language)
- [vimscript x in y minutes](!https://learnxinyminutes.com/docs/vimscript/)


## Made with :heart: in India
<img src="src/Images/India.svg" width="20" height="20">
