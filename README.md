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
zk.nvim comes with these global functions:
zkSnap
Telescope

For lsp we have:
zkNew
zkAsk
zkIndex


## Todo
- [ ] Telescope stuff
- [ ] Make it feel like 1 plugin and not 2 in 1
