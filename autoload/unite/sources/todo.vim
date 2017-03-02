let s:save_cpo = &cpo
set cpo&vim
let s:file = expand('~').'/.todo/todo.sqlite'

let s:source = {
            \ 'name': 'todo',
            \ 'description' : 'manage your todo list',
            \  "default_action" : "toggle",
            \ 'hooks' : {},
            \ 'action_table': {},
            \ 'syntax' : 'uniteSource__Todo',
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
    let res = todoapp#setStatus(id, status)
    if res == -1 | return | endif
  endfor
  call unite#force_redraw()
endfunction

function! s:source.action_table.delete.func(candidate) abort
  if input('Delete '.a:candidate.abbr.'[y/n]? ', 'y') =~? 'y'
    let id = a:candidate.source__id
    let res = todoapp#delete(id)
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
  syntax case ignore
  syntax match uniteSource__TodoHeader /^.*$/
        \ containedin=uniteSource__Todo
  syntax match uniteSource__TodoId /\v^.*%7c/ contained
        \ containedin=uniteSource__TodoHeader
        \ nextgroup=uniteSource__TodoTitle
  syntax match uniteSource__TodoTime /(\(\w\|\s\)\{-}\sago)/ contained
        \ containedin=uniteSource__TodoHeader

  highlight default link uniteSource__TodoId Special
  highlight default link uniteSource__TodoHeader Statement
  highlight default link uniteSource__TodoTime Constant
endfunction

function! s:source.gather_candidates(args, context) abort
  let type = a:context.source__type

  let output = todoapp#find(type)
  if output == -1 | return | endif
  let todos = split(output, '\v\n\s*')
  let candidates = []
  for item in todos
    let time = s:relativeTime(matchstr(item, '\v^\d+\|\zs\d+'))
    let id = matchstr(item, '\v^\d+')
    let content = matchstr(item, '\v^\d+\|\d+\|\zs.*$')
    let word = printf(' %-4d %s (%s)', id, content, time)
    call add(candidates, {
          \ "word": content,
          \ "abbr": word,
          \ "kind": 'word',
          \ "source": "todo",
          \ "source__content": content,
          \ "source__type": type,
          \ "source__id": id,
          \ })
  endfor
  return candidates
endfunction

function! s:relativeTime(integer)
  let diff = localtime() - str2float(a:integer)
  if diff <=0
    return 'just now'
  elseif diff < 60
    return string(float2nr(diff)) . ' seconds ago'
  elseif diff/60 < 60
    return string(float2nr(diff/60)) . ' minutes ago'
  elseif float2nr(diff/3.6e+3) < 24
    return string(float2nr(diff/3.6e+3)) . ' hours ago'
  elseif float2nr(diff/8.64e+4) < 7
    return string(float2nr(diff/8.64e+4)) . ' days ago'
  elseif float2nr(diff/6.048e+5) < 4.34812
    return string(float2nr(diff/6.048e+5)) . ' weeks ago'
  elseif float2nr(diff/2.63e+6) < 12
    return string(float2nr(diff/2.63e+6)) . ' months ago'
  endif
  return string(float2nr(diff/3.156e+7)) . ' years ago'
endfunction

function! unite#sources#todo#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
