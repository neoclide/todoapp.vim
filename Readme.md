# Todoapp.vim

Lightweight todo in vim, using [unite.vim](https://github.com/Shougo/unite.vim) and sqlite.

Sqlite is used so that you can build other application on top of it, like a web
service that could be accessed from your phone.

# Install

Take [vundle](https://github.com/VundleVim/Vundle.vim) for example:

    plugin 'Shougo/unite.vim'
    plugin 'chemzqm/todoapp.vim'

Install [sqlite](https://www.sqlite.org/) from it's website, or use brew on mac:

    brew install sqlite

Sqlite database is available at `~/.todo/todo.sqlite`

## Usage

* `:Todoadd [content]` add todo item.
* `Unite todo` show all todo that need to be done.
* `Unite todo:done` show todos that have been done.

Actions in the unite list:

* `toggle` for done and undone default action
* `rename`
* `delete`

# License

MIT
