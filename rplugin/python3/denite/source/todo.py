# ============================================================================
# FILE: todo.py
# AUTHOR: Qiming Zhao <chemzqm@gmail.com>
# License: MIT license
# ============================================================================
# pylint: disable=E0401,C0411
import os
import sqlite3
import time
from denite import util
from ..kind.base import Base as BaseKind
from .base import Base

def timeago(now, seconds):
    diff = now - seconds
    if diff <= 0:
        return 'just now'
    if diff < 60:
        return str(int(diff)) + ' seconds ago'
    if diff/60 < 60:
        return str(int(diff/60)) + ' minutes ago'
    if diff/3.6e+3 < 24:
        return str(int(diff/3.6e+3)) + ' hours ago'
    if diff/8.64e+4 < 24:
        return str(int(diff/8.64e+4)) + ' days ago'
    if diff/6.048e+5 < 4.34812:
        return str(int(diff/6.048e+5)) + ' weeks ago'
    if diff/2.63e+6 < 12:
        return str(int(diff/2.63e+6)) + ' months ago'
    return str(int(diff/3.156e+7)) + 'years ago'

class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'todo'
        self.matchers = ['matcher_regexp']
        self.kind = Kind(vim)

    def on_init(self, context):
        db = os.path.expanduser('~/.todo/todo.sqlite')
        context['__conn'] = sqlite3.connect(db)

    def on_close(self, context):
        context['__conn'].close()
        context['__conn'] = None

    def highlight(self):
        self.vim.command('highlight default link deniteSource__TodoHeader Statement')
        self.vim.command('highlight default link deniteSource__TodoId Special')
        self.vim.command('highlight default link deniteSource__TodoTime Constant')

    def define_syntax(self):
        self.vim.command('syntax case ignore')
        self.vim.command(r'syntax match deniteSource__TodoHeader /^.*$/ ' +
                         r'containedin=' + self.syntax_name)
        self.vim.command(r'syntax match deniteSource__TodoId /\v^.*%7c/ contained ' +
                         r'containedin=deniteSource__TodoHeader')
        self.vim.command(r'syntax match deniteSource__TodoTime /(\(\w\|\s\)\{-}\sago)/ ' +
                         r'contained containedin=deniteSource__TodoHeader')

    def gather_candidates(self, context):
        conn = context['__conn']
        c = conn.cursor()
        args = dict(enumerate(context['args']))
        status = str(args.get(0, 'pending'))

        candidates = []
        now = time.time()
        c.execute('SELECT * from todo where status = ? order by id desc', (status,))
        for row in c:
            candidates.append({
                'word': '%-4d %s (%s)' % (row[0], row[4], timeago(now, row[1])),
                'source__id': row[0],
                'source__conn': conn,
                'source__content': row[4],
                'source__status': status,
                })
        return candidates

class Kind(BaseKind):
    def __init__(self, vim):
        super().__init__(vim)

        self.default_action = 'toggle'
        self.persist_actions += ['toggle', 'edit', 'delete', 'add'] #pylint: disable=E1101
        self.redraw_actions += ['toggle', 'edit', 'delete', 'add'] #pylint: disable=E1101
        self.name = 'todo'

    def action_toggle(self, context):
        conn = context['targets'][0]['source__conn']
        c = conn.cursor()
        todos = []
        now = time.time()
        for target in context['targets']:
            status = 'done' if target['source__status'] == 'pending' else 'pending'
            todos.append((now, status, target['source__id']))
        c.executemany('UPDATE todo SET modified = ?, status = ? WHERE id = ?', todos)
        conn.commit()

    def action_edit(self, context):
        conn = context['targets'][0]['source__conn']
        c = conn.cursor()
        target = context['targets'][0]
        content = util.input(self.vim, context, 'Change to:', target['source__content'])
        if not len(content):
            return
        c.execute('UPDATE todo SET content = ? WHERE id = ?', (content, target['source__id']))
        conn.commit()

    def action_delete(self, context):
        conn = context['targets'][0]['source__conn']
        c = conn.cursor()
        c.executemany('DELETE FROM todo WHERE id = ?',
                      [(x['source__id'],) for x in context['targets']])
        conn.commit()

    def action_add(self, context):
        conn = context['targets'][0]['source__conn']
        content = util.input(self.vim, context, 'Add: ')
        if not len(content):
            return
        c = conn.cursor()
        now = int(time.time())
        c.execute('INSERT INTO todo (created, modified, status, content) VALUES (?,?,?,?)',
                  (now, now, 'pending', content))
        conn.commit()
