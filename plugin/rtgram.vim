vim9script noclear
# SPDX-License-Identifier: GPL-3.0-only

if (exists('g:loaded_rtgram') && g:loaded_rtgram) || &cp
	finish
endif

command! -nargs=0 -bar RTGramCheck call rtgram#Check()
command! -nargs=0 -bar RTGramReset call rtgram#Reset()

nnoremap <silent><Plug>(rtgram-check) :<C-u>call rtgram#Check()<CR>
nnoremap <silent><Plug>(rtgram-reset) :<C-u>call rtgram#Reset()<CR>

g:loaded_rtgram = 1
