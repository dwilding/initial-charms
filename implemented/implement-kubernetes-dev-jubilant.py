#!/usr/bin/env python

import pathlib
import subprocess

import rewriter

CHARM = pathlib.Path('kubernetes-dev-jubilant')


def main():
    r = rewriter.Rewriter(CHARM / 'charmcraft.yaml')
    r.next_by_prefix(
        prefix='    upstream-source: some-repo/some-image:some-tag',
        change='    upstream-source: ghcr.io/canonical/api_demo_server:1.0.1',
    )
    r.save()

    r = rewriter.Rewriter(CHARM / 'src/charm.py')
    r.next_by_prefix('    def _on_pebble_ready')
    r.insert(
        '        command = "uvicorn api_demo_server.app:app --host=0.0.0.0 --port=8000"'
    )
    r.next_by_prefix(
        prefix='                    "command": "/bin/foo"',
        change='                    "command": command',
    )
    r.save()

    r = rewriter.Rewriter(CHARM / 'src/my_application.py')
    r.next_by_prefix('import logging')
    r.insert('')
    r.insert('import requests')
    r.next_by_prefix('def get_version()')
    r.next_by_prefix('    return', remove_line=True)
    r.insert('    response = requests.get("http://localhost:8000/version")')
    r.insert('    resonse_data = response.json()')
    r.insert('    return resonse_data["version"]')
    r.save()

    r = rewriter.Rewriter(CHARM / 'tests/integration/test_charm.py')
    r.next_by_prefix(prefix='@pytest.mark.skip', change='# @pytest.mark.skip')
    r.next_by_prefix('    assert version', remove_line=True)
    r.insert(
        '    assert version == "1.0.0"  # (Bug) workload ought to return 1.0.1 instead.'
    )
    r.save()

    subprocess.check_call(['uv', 'add', 'requests'], cwd=CHARM)
    subprocess.check_call(['tox', '-e', 'format'], cwd=CHARM)
    subprocess.check_call(['tox', '-e', 'lint'], cwd=CHARM)
    subprocess.check_call(['tox', '-e', 'unit'], cwd=CHARM)


if __name__ == '__main__':
    main()
