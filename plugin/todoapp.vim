if exists('did_todoapp_loaded') || v:version < 700
  finish
endif
let did_todoapp_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:restore(path)
  for wnr in range(1, winnr('$'))
    let name = bufname(winbufnr(wnr))
    if name =~# '\v\[unite\].*todo'
      execute wnr.'wincmd w'
      resize 8
      setl winfixheight
      call unite#force_redraw(wnr)
    endif
  endfor
endfunction

function! s:import(file)
  if !filereadable(a:file)
    echohl ErrorMsg | echon a:file.' not readable' | echohl None
    return
  endif
  for line in readfile(a:file)
    call todoapp#add(line)
  endfor
endfunction

command! -nargs=* TodoAdd :call todoapp#add(<q-args>)
command! -nargs=0 TodoInit :call todoapp#init()
command! -nargs=1 -complete=file TodoImport :call s:import(<q-args>)

augroup todo
  autocmd BufReadCmd todo://* exe "sil doau BufReadPre ".fnameescape(expand("<amatch>"))|call todoapp#read(expand("<amatch>"))|exe "sil doau BufReadPost ".fnameescape(expand("<amatch>"))
  autocmd BufWriteCmd todo://* exe "sil doau BufWritePre ".fnameescape(expand("<amatch>"))|call todoapp#save(fnameescape(expand("<amatch>")))|exe "sil doau BufWritePost ".fnameescape(expand("<amatch>"))
  autocmd FileWriteCmd todo://* exe "sil doau FileWritePre ".fnameescape(expand("<amatch>"))|call todoapp#save(fnameescape(expand("<amatch>")))|exe "sil doau FileWritePost ".fnameescape(expand("<amatch>"))
  autocmd BufUnload todo://* call s:restore(+expand("<amatch>"))
augroup end

let &cpo = s:save_cpo
unlet s:save_cpo
