command_exists() {
    # Check if sudo is installed
    # command_exists sudo || return 1
    command -v "$@" >/dev/null 2>&1
}

# Check current wirelless straingth
myWirelessF(){
    watch -n1 "awk 'NR==3 {print \"WiFi Signal Strength = \" \$3 \"00 %\"}''' /proc/net/wireless"
}

function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xvjf $1   ;;
            *.tar.gz)  tar xvzf $1   ;;
            *.bz2)     bunzip2 $1    ;;
            *.rar)     unrar x $1    ;;
            *.gz)      gunzip $1     ;;
            *.tar)     tar xvf $1    ;;
            *.tbz2)    tar xvjf $1   ;;
            *.tgz)     tar xvzf $1   ;;
            *.zip)     unzip $1      ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1       ;;
            *)         echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function f() { find * -name $1; }

function GET() {
    curl -i -X GET -H "X-Requested-With: XMLHttpRequest" $*
}

function POST() {
    curl -i -X POST -H "X-Requested-With: XMLHttpRequest" $*
    #-d "key=val"
}

function PUT() {
    curl -i -X PUT -H "X-Requested-With: XMLHttpRequest" $*
}

function DELETE() {
    curl -i -X DELETE -H "X-Requested-With: XMLHttpRequest" $*
}

function osx {
    [[ `uname -s` == 'Darwin' ]]
}

function prompt_bg_job() {
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        jobs | grep '+' | awk '{print $4}'
    else
        jobs | grep '+' | awk '{print $3}'
    fi
}

function user_at_host() {
    local str

    if [[ "$USER" != "bjeanes" ]]; then
        str="$USER"

        if [[ "$USER" == "root" ]]; then
            str="$pr_red$str$pr_reset"
        fi

        str="${str}@"
    fi

    if [[ -n "$SSH_TTY" ]]; then
        str="$str$pr_blue`hostname -s`$pr_reset"
    fi

    echo $str
}
