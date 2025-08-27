[no-cd]
init: _before-init
    #!/usr/bin/env bash
    dir=$(basename "$PWD")
    profile="${dir%%-*}"  # For example, 'kubernetes' from 'kubernetes-dev'
    CHARMCRAFT_DEVELOPER=1 charmcraft init --profile "$profile" --name my-application

[no-cd]
check: _after-init
    #!/usr/bin/env bash
    tox -e lint
    tox -e unit

[no-cd]
lock: _after-init
    #!/usr/bin/env bash
    uv lock
    dir=$(basename "$PWD")
    profile="${dir%%-*}"  # For example, 'kubernetes' from 'kubernetes-dev'
    mkdir -p "../.templates/init-$profile"
    sed 's/my-application/{{{{ name }}/g' uv.lock > "../.templates/init-$profile/uv.lock.j2"

[no-cd]
implement: _after-init _before-implement
    #!/usr/bin/env bash
    dir=$(basename "$PWD")
    shopt -s dotglob
    echo "Copying the charm to ../implemented/$dir"
    cp -r * "../implemented/$dir"
    cd "../implemented/$dir"
    rm -rf .ruff_cache .tox .coverage
    echo "Patching the code in ../implemented/$dir"
    "../implement-$dir.py"

[no-cd]
check-implemented: _after-implement
    #!/usr/bin/env bash
    dir=$(basename "$PWD")
    cd "../implemented/$dir"
    tox -e lint
    tox -e unit

[no-cd]
rm:
    #!/usr/bin/env bash
    shopt -s dotglob
    rm -rf *

[no-cd]
rm-implemented:
    #!/usr/bin/env bash
    dir=$(basename "$PWD")
    rm -rf "../implemented/$dir"

[no-cd]
_before-init:
    #!/usr/bin/env bash
    if [ -n "$(find . -mindepth 1 -maxdepth 1)" ]; then
        echo "The current directory isn't empty"
        exit 1
    fi

[no-cd]
_after-init:
    #!/usr/bin/env bash
    if [ -z "$(find . -mindepth 1 -maxdepth 1)" ]; then
        echo "The current directory is empty"
        exit 1
    fi

[no-cd]
_before-implement:
    #!/usr/bin/env bash
    dir=$(basename "$PWD")
    if [ ! -f "../implemented/implement-$dir.py" ]; then
        echo "The implementation script doesn't exist"
        exit 1
    fi
    if [ ! -d "../implemented/$dir" ]; then
        mkdir -p "../implemented/$dir"
    elif [ -n "$(find "../implemented/$dir" -mindepth 1 -maxdepth 1)" ]; then
        echo "The implemented directory isn't empty"
        exit 1
    fi

[no-cd]
_after-implement:
    #!/usr/bin/env bash
    dir=$(basename "$PWD")
    if [ ! -d "../implemented/$dir" ]; then
        echo "The implemented directory doesn't exist"
        exit 1
    fi
    if [ -z "$(find "../implemented/$dir" -mindepth 1 -maxdepth 1)" ]; then
        echo "The implemented directory is empty"
        exit 1
    fi
