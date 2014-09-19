"""
Parse a git diff and return a tuple of (added_line_numbers, deleted_line_numbers, changed_line_numbers)

Works with a single file at a time

Usage:
    git_diff_parser.parse(diff)
    -> ([add], [delete], [change])
"""

import re
import sets

def _extract_hunk_stats(hunk_stats):
    """
    Given a line of git output with hunk stats, extract stats
    http://en.wikipedia.org/wiki/Diff#Unified_format
    """
    stats = {}

    # @@ -60,0 +61,5 @@
    match = re.match(r"^@@ -(\d+),?(\d*) \+(\d+),?(\d*) @@", hunk_stats)
    original_start, original_count, new_start, new_count = match.groups()

    original_start = int(original_start)
    new_start = int(new_start)

    # No count means 1
    original_count = 1 if original_count == "" else int(original_count)
    new_count = 1 if new_count == "" else int(new_count)

    # Line lists
    change_lines = []
    delete_lines = []
    add_lines = []

    # If only added
    if original_count == 0 and new_count > 0:
        add_lines = range(new_start, new_start + new_count)

    # If only deleted
    elif original_count > 0 and new_count == 0:
        delete_lines = range(original_start, original_start + original_count)

    # If perfectly modified
    elif original_count > 0 and new_count > 0 and original_count == new_count:
        change_lines = range(new_start, new_start + new_count)

    # If added and changed
    elif original_count > 0 and new_count > 0 and original_count < new_count:
        change_lines = range(new_start, new_start + original_count)
        add_lines = range(new_start + original_count, new_start + new_count - original_count + 1)

    # If deleted and changed
    elif original_count > 0 and new_count > 0 and original_count > new_count:
        change_lines = range(new_start, new_start + new_count)
        delete_lines = [new_start + new_count - 1]

    return (add_lines, delete_lines, change_lines)

def _get_stat_lines(diff):
    """
    Given a git diff, extract stat lines for each hunk
    """

    lines = diff.split("\n")
    stat_lines = filter(lambda l: l.startswith("@@"), lines)
    return stat_lines

def parse(diff):
    add = sets.Set([])
    delete = sets.Set([])
    change = sets.Set([])

    stat_lines = _get_stat_lines(diff)
    for line in stat_lines:
        hunk_add, hunk_delete, hunk_change = _extract_hunk_stats(line)
        add.update(hunk_add)
        delete.update(hunk_delete)
        change.update(hunk_change)

    change.update(add.intersection(delete))
    add.difference_update(change)
    delete.difference_update(change)

    return (add, delete, change)

if __name__ == '__main__':
    """
    For debugging and testing purposes
    """
    import sys
    diff = sys.stdin.read()
    print parse(diff)
