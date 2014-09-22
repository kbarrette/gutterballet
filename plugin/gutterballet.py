"""
Vim gutterballet - show git add/delete/change signs in the gutter

https://github.com/kbarrette/gutterballet
"""

import os
import subprocess
from collections import defaultdict

import git_diff_parser

try:
    import vim
except ImportError:
    pass

def _get_diff(filename):
    gitdir = os.path.dirname(os.path.realpath(filename))
    cmd = "git --no-pager diff --word-diff=porcelain --unified=0 %(filename)s" % locals()

    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, cwd=gitdir)
    diff = p.communicate()[0]

    if p.returncode != 0:
        return ""

    return diff

def _set_sign(line_number, sign_name, filename):
    vimcmd = "sign place %(line_number)s line=%(line_number)s name=%(sign_name)s file=%(filename)s" % locals()
    vim.command(vimcmd)

def _remove_sign(line_number):
    vimcmd = "sign unplace %(line_number)s" % locals()
    vim.command(vimcmd)

def _update_lines(lines, sign_name):
    for line_number in lines:
        _update_sign(line_number, sign_name)
        state[line_number] = sign_name

def update_signs(filename):
    """
    Update signs for the given filename
    """
    global sign_state

    # Get diff
    diff = _get_diff(filename)
    add, delete, change = git_diff_parser.parse(diff)

    # Compute desired signs
    new_file_state = {}
    for line_number in add:
        new_file_state[line_number] = "gutterballet_add"
    for line_number in delete:
        new_file_state[line_number] = "gutterballet_delete"
    for line_number in change:
        new_file_state[line_number] = "gutterballet_change"

    # Update signs
    for line_number in new_file_state:
        if line_number not in sign_state[filename] or sign_state[filename][line_number] != new_file_state[line_number]:
            _set_sign(line_number, new_file_state[line_number], filename)

    # Delete any signs no longer in use
    for line_number in sign_state[filename]:
        if line_number not in new_file_state:
            _remove_sign(line_number)

    sign_state[filename] = new_file_state

def cleanup(filename):
    global sign_state
    sign_state.pop(filename, None)

def init():
    global sign_state
    sign_state = defaultdict(dict)

