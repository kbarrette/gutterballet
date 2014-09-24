" Vim gutterballet - show git add/delete/change signs in the gutter
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
call s:set('g:gutterballet_highlight_add', 'DiffAdd')
call s:set('g:gutterballet_highlight_delete', 'DiffDelete')
call s:set('g:gutterballet_highlight_change', 'DiffChange')

" Define signs
function! s:GutterBalletDefineSigns()
  exec 'sign define gutterballet_add text=+ texthl=' . g:gutterballet_highlight_add
  exec 'sign define gutterballet_delete text=- texthl=' . g:gutterballet_highlight_delete
  exec 'sign define gutterballet_change text=~ texthl=' . g:gutterballet_highlight_change
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
