import pathlib


class Rewriter:
    """Modify a file one line at a time."""

    def __init__(self, file: pathlib.Path):
        self.file = pathlib.Path(file)
        self._lines = self.file.read_text().splitlines()
        self._first_line_index = 0

    def next_by_prefix(
        self, prefix: str, *, change: str | None = None, remove_line: bool = False
    ):
        """Set the current location to the next line that matches a prefix."""
        for line_index in range(self._first_line_index, len(self._lines)):
            line = self._lines[line_index]
            if line.startswith(prefix):
                if remove_line:
                    del self._lines[line_index]
                    self._first_line_index = line_index
                    return
                if change is not None:
                    self._lines[line_index] = change + line[len(prefix) :]
                self._first_line_index = line_index + 1
                return
        raise ValueError('no matching line')

    def insert(self, new: str, *, offset: int = 0):
        """Insert a line at the current location."""
        self._lines.insert(self._first_line_index + offset, new)
        self._first_line_index += 1

    def save(self):
        """Save the modified file."""
        lines = self._lines + ['']
        self.file.write_text('\n'.join(lines))
