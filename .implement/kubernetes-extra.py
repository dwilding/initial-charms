import subprocess

import rewriter


def main():
    # Change the OCI image to the demo server from the K8s charm tutorial:
    # https://documentation.ubuntu.com/ops/latest/tutorial/from-zero-to-hero-write-your-first-kubernetes-charm/study-your-application/
    r = rewriter.Rewriter('charmcraft.yaml')
    r.next_p(
        prefix='    upstream-source: some-repo/some-image:some-tag',
        change='    upstream-source: ghcr.io/canonical/api_demo_server:1.0.1',
    )
    r.save()

    # Change the Pebble layer so that Pebble starts the server.
    r = rewriter.Rewriter('src/charm.py')
    r.set_indent(4)
    r.next_p('def _on_pebble_ready')
    r.next_p('    layer')
    r.insert(
        '    command = "uvicorn api_demo_server.app:app --host=0.0.0.0 --port=8000"',
        offset=-1,
    )
    r.set_indent(5 * 4)
    r.next_p(
        prefix='"command": "/bin/foo"',
        change='"command": command',
    )
    r.save()

    # Implement get_version() in src/my_application.py, by requesting the version over HTTP.
    subprocess.check_call(['uv', 'add', '--quiet', 'requests'])  # Add package to charm venv.
    r = rewriter.Rewriter('src/my_application.py')
    r.next_p('import logging')
    r.insert('')
    r.insert('import requests')
    r.next_p('def get_version()')
    r.next_p('    return', remove_line=True)
    r.insert("""\
    response = requests.get("http://localhost:8000/version")
    resonse_data = response.json()
    return resonse_data["version"]""")
    r.save()

    # Format the charm code (just in case)
    subprocess.check_call(['tox', '-e', 'format'])


if __name__ == '__main__':
    main()
