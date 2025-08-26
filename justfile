[no-cd]
init:
    #!/usr/bin/env bash
    if [ -n "$(find . -mindepth 1 -maxdepth 1)" ]; then
        echo "The current directory isn't empty"
        exit 1
    fi
    dir=$(basename "$PWD")
    profile="${dir%%-*}"  # For example, 'kubernetes' from 'kubernetes-dev'
    CHARMCRAFT_DEVELOPER=1 charmcraft init --profile "$profile" --name my-application

[no-cd]
lock:
    #!/usr/bin/env bash
    if [ -z "$(find . -mindepth 1 -maxdepth 1)" ]; then
        echo "The current directory is empty"
        exit 1
    fi
    uv lock
    dir=$(basename "$PWD")
    profile="${dir%%-*}"  # For example, 'kubernetes' from 'kubernetes-dev'
    mkdir -p "../.templates/init-$profile"
    sed 's/my-application/{{{{ name }}/g' uv.lock > "../.templates/init-$profile/uv.lock.j2"

[no-cd]
rm:
    #!/usr/bin/env bash
    shopt -s dotglob
    rm -rf *
