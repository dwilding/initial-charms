This repo contains tools for maintaining the `kubernetes` and `machine` profiles of [Charmcraft](https://github.com/canonical/charmcraft). The tools are primarily intended to be used by the Charm Tech team at Canonical.

In the Charmcraft source, profiles are stored as .j2 template files. For example, [charm.py.j2](https://github.com/canonical/charmcraft/blob/main/charmcraft/templates/init-kubernetes/src/charm.py.j2). This makes it possible for `charmcraft init` to fill in details such as the charm name, but testing the profiles can be awkward.

## Generate charms for testing

You'll need:

  - The Charmcraft source. We'll assume this is located at `~/charmcraft`.

  - A virtual environment in the Charmcraft source. To create a virtual environment:

    ```text
    cd ~/charmcraft
    make setup
    ```

  - [just](https://github.com/casey/just)

After editing .j2 files in the Charmcraft source, run the following command in this repo:

```text
CHARMCRAFT_DIR=~/charmcraft just init
```

This initializes a Kubernetes charm in the `kubernetes` directory and a machine charm in the `machine` directory. If you only want to initialize one of the charms, use `just kubernetes` or `just machine` instead of `just init`.

You can test the charms as normal using tox. Alternatively, initialize the charms and immediately test them:

```text
CHARMCRAFT_DIR=~/charmcraft just init lint,unit
```

The list of environments after `just init` is passed to `tox -e <environments>` for each charm. This also works with `just kubernetes` and `just machine`.

### Integration tests

Don't run integration tests using `just ... integration`. Instead, in each charm directory, run `charmcraft pack` followed by `tox -e integration`.

The machine charm's integration tests should pass. The charm goes active without starting or installing a workload.

The Kubernetes charm's integration tests should fail because Juju tries to deploy the charm alongside a placeholder container image. To generate a Kubernetes charm that passes integration tests, see the next section.

### kubernetes-extra

To generate a Kubernetes charm that passes integration tests, make sure you've initialized a Kubernetes charm (as above), then run:

```text
just kubernetes-extra
```

This copies `kubernetes` to a directory called `kubernetes-extra`, then replaces the placeholder parts of the charm by real configuration/code. For details, see [.implement/kubernetes-extra.py](.implement/kubernetes-extra.py).

To generate the charm and immediately test it:

```text
just kubernetes-extra lint,unit
```

To run the charm's integration tests:

```text
cd kubernetes-extra
charmcraft pack
tox -e integration
```

## Update the uv.lock templates

