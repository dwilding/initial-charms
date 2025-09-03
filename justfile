init: kubernetes machine

[working-directory: "kubernetes"]
kubernetes: _empty-kubernetes
    @echo "{{BOLD}}Generating charm: kubernetes{{NORMAL}}"
    CHARMCRAFT_DEVELOPER=1 charmcraft init --profile kubernetes --name my-application

_empty-kubernetes:
    @rm -rf kubernetes
    @mkdir kubernetes

[working-directory: "machine"]
machine: _empty-machine
    @echo "{{BOLD}}Generating charm: machine{{NORMAL}}"
    CHARMCRAFT_DEVELOPER=1 charmcraft init --profile machine --name my-application

_empty-machine:
    @rm -rf machine
    @mkdir machine

lock: lock-kubernetes lock-machine

[working-directory: "kubernetes"]
lock-kubernetes:
    @echo "{{BOLD}}Generating .templates/init-kubernetes/uv.lock.j2{{NORMAL}}"
    uv lock
    @mkdir -p "../.templates/init-kubernetes"
    @sed 's/my-application/{{{{ name }}/g' uv.lock > "../.templates/init-kubernetes/uv.lock.j2"

[working-directory: "machine"]
lock-machine:
    @echo "{{BOLD}}Generating .templates/init-machine/uv.lock.j2{{NORMAL}}"
    uv lock
    @mkdir -p "../.templates/init-machine"
    @sed 's/my-application/{{{{ name }}/g' uv.lock > "../.templates/init-machine/uv.lock.j2"

[working-directory: "kubernetes-extra"]
kubernetes-extra: _init-kubernetes-extra
    @echo "{{BOLD}}Implementing charm: kubernetes-extra{{NORMAL}}"
    @uv run --project ../.implement ../.implement/kubernetes-extra.py

_init-kubernetes-extra:
    @test -d kubernetes
    @rm -rf kubernetes-extra
    @cp -r kubernetes kubernetes-extra
