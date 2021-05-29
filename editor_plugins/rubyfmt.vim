let s:cpo_save = &cpo
set cpo&vim

let g:rubyfmt_path = '/Users/penelope/dev/rubyfmt/target/release/rubyfmt-main'

function! rubyfmt#format() abort
  let l:bin_args = [g:rubyfmt_path, '-i']
  let l:curw = winsaveview()
  let l:tmpname = "/tmp/bees.rb"
  call writefile(rubyfmt#get_lines(), l:tmpname)

  let current_col = col('.')
  let [l:out, l:err] = rubyfmt#run(l:bin_args, l:tmpname, expand('%'))
  let line_offset = len(readfile(l:tmpname)) - line('$')
  let l:orig_line = getline('.')
  if l:err == 0
    call rubyfmt#update_file(l:tmpname, expand('%'))
  else
  endif

  call delete(l:tmpname)
  call winrestview(l:curw)
  let l:lineno = ('.') + line_offset
  call cursor(l:lineno, current_col + (len(getline(l:lineno)) - len(l:orig_line)))
  syntax sync fromstart
endfunction

function! rubyfmt#update_file(source, target) abort
  try | silent undojoin | catch | endtry

  let old_fileformat = &fileformat
  if exists("*getfperm")
    let original_fperm = getfperm(a:target)
  endif

  call rename(a:source, a:target)
  if exists("*setfperm") && original_fperm != ''
    call setfperm(a:target, original_fperm)
  endif

  silent edit!
  let &fileformat = old_fileformat
  let &syntax = &syntax
endfunction

function! rubyfmt#run(bin_args, source, target) abort
  if a:source == ''
    return
  endif
  if a:target == ''
    return
  endif

  let s:res = system(join(a:bin_args + [a:source], " "))

  return [s:res, v:shell_error]
endfunction

function! rubyfmt#get_lines() abort
  let buf = getline(1, '$')
  return buf
endfunction

function! rubyfmt#exec(cmd, ...) abort
  if len(a:cmd) == 0
endfunction

function! rubyfmt#show_errors(errors) abort
  echom a:errors
endfunction

if !exists("s:rubyfmt_ac_set")
  let s:rubyfmt_ac_set=1
  autocmd FileType ruby autocmd! BufWritePre <buffer> call rubyfmt#format()
endif

let &cpo = s:cpo_save
unlet s:cpo_save
