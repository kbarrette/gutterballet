" Vim gutterballet - show diff add/delete/change signs in the gutter
"
" https://github.com/kbarrette/gutterballet
"

if exists('g:gutterballet') || !has('python')
  finish
endif
let g:gutterballet = 1

" Load Python module
python << EOF
import sys, vim
sys.path.append(vim.eval("expand('<sfile>:h')"))
import gutterballet
gutterballet.init()
EOF

" Set a variable unless it exists
function! s:set(name, value)
  if !exists(a:name)
    exec 'let' a:name '=' string(a:value)
  endif
endfunction

" Highlight defaults
call s:set('g:gutterballet_add_highlight', 'DiffAdd')
call s:set('g:gutterballet_delete_highlight', 'DiffDelete')
call s:set('g:gutterballet_change_highlight', 'DiffChange')
call s:set('g:gutterballet_add_text', '+')
call s:set('g:gutterballet_delete_text', '-')
call s:set('g:gutterballet_change_text', '~')
call s:set('g:gutterballet_diff_command', 'git --no-pager diff')

" Define signs
function! s:GutterBalletDefineSigns()
  exec 'sign define gutterballet_add text=' . g:gutterballet_add_text . ' texthl=' . g:gutterballet_add_highlight
  exec 'sign define gutterballet_delete text=' . g:gutterballet_delete_text . ' texthl=' . g:gutterballet_delete_highlight
  exec 'sign define gutterballet_change text=' . g:gutterballet_change_text . ' texthl=' . g:gutterballet_change_highlight
  sign define gutterballet_dummy
endfunction

" Set signs on BufWrite, etc
function! s:GutterBalletSetAutoCommands()
  augroup GutterBallet
    autocmd!
    autocmd BufRead,BufWritePost,FileChangedShellPost * call <SID>GutterBalletUpdateSigns(expand('<afile>:p'))
    autocmd BufDelete * call <SID>GutterBalletCleanup('<afile>:p')
  augroup END
endfunction

" Clean up
function! s:GutterBalletCleanup(file)
  exec 'python gutterballet.cleanup("' . a:file . '")'
endfunction

" Update signs
function! s:GutterBalletUpdateSigns(file)
  exec 'python gutterballet.update_signs("' . a:file . '")'
endfunction


function s:GutterBalletInit()
  call s:GutterBalletDefineSigns()
  call s:GutterBalletSetAutoCommands()
endfunction

call s:GutterBalletInit()
command! -nargs=0 GutterBalletUpdateSigns call s:GutterBalletUpdateSigns()
