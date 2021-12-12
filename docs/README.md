# How to profile vim

~~~bash
You can use built-in profiling support: after launching vim do

:profile start profile.log
:profile func *
:profile file *
" At this point do slow actions
:profile pause
:noautocmd qall!
~~~

### Open/Close debug

~~~bash
vim --cmd 'profile start profile.log' \
    --cmd 'profile func *' \
    --cmd 'profile file *' \
    -c 'profdel func *' \
    -c 'profdel file *' \
    -c 'qa!'
~~~bash

### Startup logs

~~~bash
vim --startuptime vim.log
~~~

### Check that the key is effectively mapped to what it should do

~~~bash
:map
~~~

As always the doc is your friend: :h map-listing

You can see in the first column the mode of the mapping (n for normal mode, v for visual mode, etc), the second column shows the keys mapped and the last column what the keys are mapped to. Note that before the mapped actions some additional characters may appear, it is important to understand them:

    * indicates that it is not remappable (i.e. it is not a recursive mapping, see know when to use nore later in this answer)
    & indicates that only script-local mappings are remappable
    @ indicates a buffer-local mapping

When asking for help about a mapping it is a good thing to add this information since it can help other people to understand the behavior of your mapping.

It is possible to restrict the prompt to a particular mode with the sister-commands of :map, like :vmap, :nmap, :omap, etc.

### Log all your vim bindings in single go ( jump to the end )
~~~bash
	vim -c "redir > /tmp/vim-shortcuts.log" -c "map" -c "redir END" -c "qa"
~~~bash
