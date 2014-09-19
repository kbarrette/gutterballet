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

" Define signs
function! s:GutterBalletDefineSigns()
	sign define gutterballet_add text=+ texthl=DiffAdd
	sign define gutterballet_delete text=- texthl=DiffDelete
	sign define gutterballet_change text=~ texthl=DiffChange
  sign define gutterballet_dummy
endfunction

" Place a dummy sign to ensure the sign column is always visible
function! s:GutterBalletInsertDummySign()
  exec 'sign place 9999 line=1 name=gutterballet_dummy buffer=' . bufnr('')
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

" Set signs on BufWrite
augroup GutterBallet
  autocmd!
  autocmd BufRead,BufWritePost,FileChangedShellPost * call <SID>GutterBalletUpdateSigns()
  autocmd BufDelete * call <SID>GutterBalletCleanup()
augroup END

call s:GutterBalletDefineSigns()
command! -nargs=0 GutterBalletUpdateSigns call s:GutterBalletUpdateSigns()
