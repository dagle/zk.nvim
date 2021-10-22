# zk.nvim a neovim interface for zk
[zk](https://github.com/mickael-menu/zk) is a great tool to do Zettelkasten.
This is a neovim interface for it. It comes with some custom functions and ways
to speak to to the lsp.

## Install
First make sure to have [zk](https://github.com/mickael-menu/zk) installed.
Then t install I recommend using your favourite plugin manager. Here is an example
using packer:

```lua
	use 'dagle/zk.nvim'
```

## Usage
zk.nvim comes with these lua function:
zkSnap 

Telescope:
After registering the zk extension
Telescope zk {title, tag}

For lsp we have:
zkNew
zkAsk
zkIndex


and in vimL:
Zksnap
ZkNew
ZkIndex

I recommened binding the lsp functions in the attach function
