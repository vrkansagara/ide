# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overriden
if [ ! -a $HOME/.inputrc ]; then

echo '$include /etc/inputrc' > $HOME/.inputrc;
# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
echo "bind 'set completion-ignore-case on'" >> $HOME/.inputrc
fi

