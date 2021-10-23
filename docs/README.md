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
