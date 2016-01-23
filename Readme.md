# Todoapp.vim

Lightweight and easy to use todo management in vim.

using [unite.vim](https://github.com/Shougo/unite.vim) and sqlite.

Sqlite is used so that you can build other application on top of it, like a web
service that could be accessed from your phone.

# Install

Take [vundle](https://github.com/VundleVim/Vundle.vim) for example:

    plugin 'Shougo/unite.vim'
    plugin 'chemzqm/todoapp.vim'

Install [sqlite](https://www.sqlite.org/) from it's website, or use brew on mac:

    brew install sqlite

Sqlite database is available at `~/.todo/todo.sqlite`

After install plugin, you need to call `:TodoInit` once to create database

## Usage

* `:Todoadd [content]` add todo item.
* `:TodoInit` init todo database
* `:TodoImport` import todos from a plain file
* `Unite todo` show all todo that need to be done.
* `Unite todo:done` show todos that have been done.

Actions in the unite list:

* `toggle` default action, press `<cr>`
* `edit` edit todo in split buffer, press `q` to save and quit
* `New` create new todo through prompt
* `delete`

# License

MIT
