[no-cd]
init: _dir _before-init
    #!/usr/bin/env bash
    profile=$(basename "$PWD")
    CHARMCRAFT_DEVELOPER=1 charmcraft init --profile "$profile" --name my-application

[no-cd]
check: _dir _after-init
    #!/usr/bin/env bash
    tox -e lint
    tox -e unit

[no-cd]
lock: _dir _after-init
    #!/usr/bin/env bash
    uv lock
    profile=$(basename "$PWD")
    mkdir -p "../.templates/init-$profile"
    sed 's/my-application/{{{{ name }}/g' uv.lock > "../.templates/init-$profile/uv.lock.j2"

[no-cd]
implement: _dir _after-init _before-implement
    #!/usr/bin/env bash
    profile=$(basename "$PWD")
    shopt -s dotglob
    echo "Copying the charm to <root>/implemented/$profile"
    cp -r * "../implemented/$profile"
    cd "../implemented/$profile"
    rm -rf .ruff_cache .tox .coverage
    echo "Patching the code in <root>/implemented/$profile"
    "../implement-$profile.py"

[no-cd]
check-implemented: _dir _after-implement
    #!/usr/bin/env bash
    profile=$(basename "$PWD")
    cd "../implemented/$profile"
    tox -e lint
    tox -e unit

[no-cd]
rm: _dir
    #!/usr/bin/env bash
    shopt -s dotglob
    rm -rf *

[no-cd]
rm-implemented: _dir
    #!/usr/bin/env bash
    profile=$(basename "$PWD")
    rm -rf "../implemented/$profile"

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
    profile=$(basename "$PWD")
    if [ ! -f "../implemented/implement-$profile.py" ]; then
        echo "<root>/implemented/implement-$profile.py doesn't exist"
        exit 1
    fi
    if [ ! -d "../implemented/$profile" ]; then
        mkdir -p "../implemented/$profile"
    elif [ -n "$(find "../implemented/$profile" -mindepth 1 -maxdepth 1)" ]; then
        echo "<root>/implemented/$profile isn't empty"
        exit 1
    fi

[no-cd]
_after-implement:
    #!/usr/bin/env bash
    profile=$(basename "$PWD")
    if [ ! -d "../implemented/$profile" ]; then
        echo "<root>/implemented/$profile doesn't exist"
        exit 1
    fi
    if [ -z "$(find "../implemented/$profile" -mindepth 1 -maxdepth 1)" ]; then
        echo "<root>/implemented/$profile is empty"
        exit 1
    fi

[no-cd]
_dir:
    #!/usr/bin/env bash
    profile=$(basename "$PWD")
    if [ ! "$profile" = "kubernetes" ] && [ ! "$profile" = "machine" ]; then
        echo "You must change to <root>/kubernetes or <root>/machine"
        exit 1
    fi
    if [ ! "{{justfile_directory()}}/$profile" = "$PWD" ]; then
        echo "You must change to <root>/kubernetes or <root>/machine"
        exit 1
    fi
