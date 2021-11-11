# cmp-zsh

Zsh completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

## Requirements

* [Neovim](https://github.com/neovim/neovim/)
* [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
* zsh/zpty module

```zsh
zmodload zsh/zpty
```

## Installation

```vim
Plug 'hrsh7th/nvim-cmp'
Plug 'tamago324/cmp-zsh'
Plug 'Shougo/deol.nvim'      " recommended to use together.

lua << EOF
require'cmp'.setup {
  -- ...
  sources = {
    { name = 'zsh' }
  }
}
EOF
```

## Configuration

It saves compdump file in `$COMPE_ZSH_CACHE_DIR` or `$XDG_CACHE_HOME` or
`$HOME/.cache` directory.

In order to show completions defined in your zshrc you can setup cmp zsh like this.
*Note*: This feature is experimental. If you enable it and don't get any
results try disabling it.

```lua
require'cmp_zsh'.setup {
  zshrc = true -- Source the zshrc (adding all custom completions)
}
```

Alternatively you can use this trick (if sourcing your zshrc is very slow):
Add the directory of the complete function to `$FPATH` in `~/.zshenv`.

```zsh
# completions
if [ -d $HOME/.zsh/comp ]; then
    export FPATH="$HOME/.zsh/comp:$FPATH"
fi
```


## Credit

* [deoplete-zsh](https://github.com/deoplete-plugins/deoplete-zsh)
* [zsh-capture-completion](https://github.com/Valodim/zsh-capture-completion)

## License

MIT
