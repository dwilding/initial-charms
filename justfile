_default:
    @just --list --unsorted

[doc("Initialize a K8s charm and a machine charm. CHARMCRAFT_DIR must be set")]
init: (_charmcraft-init "kubernetes" "machine")

[doc("Initialize a K8s charm. CHARMCRAFT_DIR must be set")]
kubernetes: (_charmcraft-init "kubernetes")

[doc("Implement a more complete version of the K8s charm")]
[working-directory: "kubernetes-extra"]
kubernetes-extra: _init-kubernetes-extra
    @echo "{{BOLD}}Implementing charm: kubernetes-extra{{NORMAL}}"
    @uv run --project ../.implement ../.implement/kubernetes-extra.py

[doc("Initialize a machine charm. CHARMCRAFT_DIR must be set")]
machine: (_charmcraft-init "machine")

[doc("Generate uv.lock templates for the K8s and machine charms")]
lock: lock-kubernetes lock-machine

[doc("Generate a uv.lock template for the K8s charm")]
[working-directory: "kubernetes"]
lock-kubernetes:
    @echo "{{BOLD}}Generating .templates/init-kubernetes/uv.lock.j2{{NORMAL}}"
    uv lock
    @mkdir -p "../.templates/init-kubernetes"
    @sed 's/my-application/{{{{ name }}/g' uv.lock > "../.templates/init-kubernetes/uv.lock.j2"

[doc("Generate a uv.lock template for the machine charm")]
[working-directory: "machine"]
lock-machine:
    @echo "{{BOLD}}Generating .templates/init-machine/uv.lock.j2{{NORMAL}}"
    uv lock
    @mkdir -p "../.templates/init-machine"
    @sed 's/my-application/{{{{ name }}/g' uv.lock > "../.templates/init-machine/uv.lock.j2"

_charmcraft-init +profiles:
    #!/bin/sh
    if [ -z "$CHARMCRAFT_DIR" ]; then
        echo "CHARMCRAFT_DIR is not set"
        exit 1
    fi
    if [ ! -d "$CHARMCRAFT_DIR/.venv" ]; then
        echo "Environment does not exist: $CHARMCRAFT_DIR/.venv"
        echo "Have you run 'make setup' in the Charmcraft directory?"
        exit 1
    fi
    echo "{{BOLD}}Activating environment: $CHARMCRAFT_DIR/.venv"
    . "$CHARMCRAFT_DIR/.venv/bin/activate"
    for profile in {{profiles}}; do
        echo "{{BOLD}}Generating charm: $profile{{NORMAL}}"
        rm -rf $profile
        mkdir $profile
        cd $profile
        echo "{{BOLD}}CHARMCRAFT_DEVELOPER=1 charmcraft init --profile $profile --name my-application{{NORMAL}}"
        CHARMCRAFT_DEVELOPER=1 charmcraft init --profile $profile --name my-application
        cd - > /dev/null
    done
    echo "{{BOLD}}Deactivating Charmcraft environment"
    deactivate

_init-kubernetes-extra:
    @test -d kubernetes
    @rm -rf kubernetes-extra
    @cp -r kubernetes kubernetes-extra
