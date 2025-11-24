" :norm {Vim}
" jk$diw w" Acts as if you ran {Vim} on every single line in the range. For example, g/regex/norm f dw will delete the first word after the first space on every line matching regex. This is often much easier than using a macro.
" : jk$diw w
" : jk$diw w" norm obeys all of your mappings. For example, if you mapped jk to <esc> in insert mode, norm I jk$diw will prepend a space to the beginning of the line, leave insert-mode, and then delete the last word on the line. I like this functionality a lot, but if you’d prefer it not to use your mappings, you can use norm! instead.
"
