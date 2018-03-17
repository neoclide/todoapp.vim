# Todoapp.vim

[![](http://img.shields.io/github/issues/neoclide/todoapp.vim.svg)](https://github.com/neoclide/todoapp.vim/issues)
[![](http://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![](https://img.shields.io/badge/doc-%3Ah%20todoapp.txt-red.svg)](doc/todoapp.txt)

**Upgraded to use [denite.nvim](https://github.com/Shougo/denite.nvim),
[unite](https://github.com/Shougo/unite.vim) support would be dropped soon**

Lightweight and easy to use todo management in vim.

using [denite.nvim](https://github.com/Shougo/denite.nvim) and sqlite.

Sqlite is used so that you can build other application on top of it, like a web
service that could be accessed from your phone.

# Install

Take [vundle](https://github.com/VundleVim/Vundle.vim) for example:

    plugin 'Shougo/denite.nvim'
    plugin 'chemzqm/todoapp.vim'

Install [sqlite](https://www.sqlite.org/) from it's website, or use brew on mac:

    brew install sqlite

Sqlite database is available at `~/.todo/todo.sqlite`

After install plugin, you need to call `:TodoInit` once to create a todo table in database

## Usage

* `Denite todo` show all todo that need to be done.
* `Denite todo:done` show todos that have been done.

Actions in the unite list:

* `toggle` default action, press `<cr>`
* `edit` edit todo in split buffer
* `add` create new todo through prompt
* `delete` delete todo item

# License

MIT
