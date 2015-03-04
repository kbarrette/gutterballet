"""
Parse a diff and return a tuple of (added_line_numbers, removed_line_numbers, changed_line_numbers)

Works with a single file at a time

Usage:
    diff_parser.parse(diff)
    -> ([added], [removed], [changed])
"""

from unidiff import PatchSet
from sets import Set
import StringIO

def parse(diff):
    added = Set()
    removed = Set()

    diff_stream = StringIO.StringIO(diff)
    patch = PatchSet(diff_stream)
    if len(patch) > 0:
        for hunk in patch[0]:
            offset = 0
            for line in hunk:
                if line.is_added:
                    added.add(line.target_line_no)
                    offset += 1
                elif line.is_removed:
                    removed.add(line.source_line_no + offset)
                    offset -= 1

    diff_stream.close

    # Changed lines are in both the added and removed sets
    changed = Set(added.intersection(removed))
    added.difference_update(changed)
    removed.difference_update(changed)

    return (added, removed, changed)


if __name__ == '__main__':
    """
    For debugging and testing purposes
    """
    import sys
    diff = sys.stdin.read()
    print parse(diff)
