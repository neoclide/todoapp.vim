let s:save_cpo = &cpo
set cpo&vim
let s:file = expand('~').'/.todo/todo.sqlite'

let s:source = {
            \ 'name': 'todo',
            \ 'description' : 'manage your todo list',
            \  "default_action" : "toggle",
            \ 'hooks' : {},
            \ 'action_table': {},
            \ 'syntax' : 'uniteSource__todo',
            \ }

let s:source.action_table.toggle = {
            \ 'description' : 'toggle todo',
            \ 'is_selectable': 1,
            \ 'is_quit' : 0,
            \ }

let s:source.action_table.edit = {
            \ 'description' : 'edit todo',
            \ 'is_quit' : 0,
            \ }

let s:source.action_table.delete = {
            \ 'description' : 'delete todo',
            \ 'is_quit' : 0,
            \ }

let s:source.action_table.new = {
            \ 'description' : 'new todo',
            \ 'is_quit' : 0,
            \ }

function! s:source.action_table.new.func(candidate)
  let content = input('Add todo: ')
  if empty(content)
    echohl ErrorMsg | echon 'canceled' | echohl None
    return
  endif
  silent call todoapp#add(content)
  call unite#force_redraw()
endfunction

function! s:source.action_table.toggle.func(candidates) abort
  for candidate in a:candidates
    let id = candidate.source__id
    let status = candidate.source__type ==# 'pending' ? 'done' : 'pending'
    let cmd = 'sqlite '.s:file.' "UPDATE todo SET '
            \.'modified='.localtime().', status='.s:quote(status).' WHERE id='.id.'"'
    let res = s:system(cmd)
    if res == -1 | return | endif
  endfor
  call unite#force_redraw()
endfunction

function! s:source.action_table.delete.func(candidate) abort
  if input('Delete '.a:candidate.abbr.'[y/n]? ', 'y') =~? 'y'
    let id = a:candidate.source__id
    let cmd = 'sqlite '.s:file.' "DELETE from todo where id = '.id.'"'
    let res = s:system(cmd)
    if res == -1 | return | endif
    call unite#force_redraw()
  else
    echohl ErrorMsg | echon 'canceled' | echohl None
  endif
endfunction

function! s:source.action_table.edit.func(candidate) abort
  execute '1split todo://' . a:candidate.source__id
endfunction

function! s:source.hooks.on_init(args, context) abort
  let a:context.source__type = get(a:args, 0 ,'pending')
endfunction

function! s:source.hooks.on_close(args, context) abort
  let a:context.source__type = ''
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  syntax match uniteSource__todo_desc /\s\+\zs[A-Z0-9 -]\+/
              \ contained containedin=uniteSource__todo
              \ contains=uniteCandidateInputKeyword
  highlight default link uniteSource__todo_desc Statement
endfunction

function! s:source.gather_candidates(args, context) abort
  let type = a:context.source__type

  let cmd = 'sqlite '.s:file.' "SELECT id,content from todo where status='.s:quote(type)
            \.' order by modified desc"'
  let output = s:system(cmd)
  if output == -1 | return | endif
  let todos = split(output, "\n")
  return map( todos,
              \ '{"word": substitute(v:val,''\v\d+\|'', "", ""),
              \ "abbr": substitute(v:val,''\v\d+\|'', "", ""),
              \ "kind": "word",
              \ "source": "todo",
              \ "source__type": type,
              \ "source__id": matchstr(v:val, ''\v^\d+''),
              \ }')
endfunction

function! unite#sources#todo#define()
  return s:source
endfunction

function! s:system(cmd)
  let output = system(a:cmd)
  if v:shell_error && output !=# ""
    echohl Error | echon output | echohl None
    return -1
  endif
  return output
endfunction

function! s:quote(val)
  return "'".escape(a:val, "'\"")."'"
endfunction

function! s:values(...)
  let args = deepcopy(a:000)
  return join(args, ',')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
