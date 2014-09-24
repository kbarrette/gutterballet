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
    autocmd BufRead,BufWritePost,FileChangedShellPost * call <SID>GutterBalletUpdateSigns()
    autocmd BufDelete * call <SID>GutterBalletCleanup()
  augroup END
endfunction

" Place a dummy sign to ensure the sign column is always visible
function! s:GutterBalletInsertDummySign()
  exec 'sign place 9999 line=1 name=gutterballet_dummy file=' . expand('%:p')
endfunction

" Clean up
function! s:GutterBalletCleanup()
	exec 'python gutterballet.cleanup("' . expand('%:p') . '")'
endfunction

" Update signs
function! s:GutterBalletUpdateSigns()
	if !exists('b:gutterballet_dummy_sign_created')
	  call s:GutterBalletInsertDummySign()
	  let b:gutterballet_dummy_sign_created = 1
  endif
	exec 'python gutterballet.update_signs("' . expand('%:p') . '")'
endfunction


function s:GutterBalletInit()
  call s:GutterBalletSetAutoCommands()
  call s:GutterBalletDefineSigns()
endfunction

call s:GutterBalletInit()
command! -nargs=0 GutterBalletUpdateSigns call s:GutterBalletUpdateSigns()
