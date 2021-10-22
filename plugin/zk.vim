if exists('g:loaded_nvim_zk') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_zk = 1

command! -nargs=? Zksnap lua require'zk'.zkSnap(<f-args>)

autocmd FileType markdown command! -nargs=? Zksnew lua require'zk'.zkSnap(<f-args>)
autocmd FileType markdown command! -nargs=0 ZkIndex lua require'zk'.zkIndex()
