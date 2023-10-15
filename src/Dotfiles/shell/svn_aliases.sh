# Aliases
# (sorted alphabetically)
#

alias s='svn'
alias sc='svn checkout'
alias sr='svn info |grep Revision: |cut -c11-'
alias sm="svn st -u"                  # svn status of my modified files
alias si="svn info"                   # info about local and remote state
alias su="svn up --ignore-externals"  # svn update ignore externals
alias sl="svn log --limit"            # svn log and specify a number to return a specific amount of revisions
alias sco="svn co --ignore-externals" # svn checkout and ignore externals
alias sd="svn diff -r"                # get a diff, pass in i.e.:168:169 index.xml (revisions to compare and file)
alias sci="svn ci -m"                 # svn check in with comment
alias saa="svn add * --force"         # svn add all unrevisioned files
alias slf="svn log --verbose | grep"  # search svn log for relevant info

# svn status --show-updates --depth infinity | awk '{print $NF}' | xargs -I '{}' svn revert  '{}'
alias s.HardReset='read -p "destroy all local changes?[y/N]" && [[ $REPLY =~ ^[yY] ]] && svn revert . -R && rm -rf $(awk -f <(echo "/^?/{print \$2}") <(svn status) ;)'
