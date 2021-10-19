if exists('g:loaded_nvim_zk') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_zk = 1

command! -nargs=? zkSnap lua require'nvim-zk'.zkSnap(<f-args>)
