This repo contains tools for maintaining the `kubernetes` and `machine` profiles of [Charmcraft](https://github.com/canonical/charmcraft). The tools are primarily intended to be used by the Charm Tech team at Canonical.

In the Charmcraft source, profiles are stored as .j2 template files. For example, [charm.py.j2](https://github.com/canonical/charmcraft/blob/main/charmcraft/templates/init-kubernetes/src/charm.py.j2). This enables `charmcraft init` to fill in the charm name and other details, but testing the profiles can be awkward.

**In this README**

- [Generate charms for testing](#generate-charms-for-testing)
    - [Integration tests](#integration-tests)
    - [kubernetes-extra](#kubernetes-extra)
- [Update the uv.lock templates](#update-the-uvlock-templates)

## Generate charms for testing

You'll need:

- The Charmcraft source. We'll assume this is located at `~/charmcraft`.
- A virtual environment in the Charmcraft source. To create one, run `make setup` in the Charmcraft source.
- [just](https://just.systems/man/en/), [uv](https://docs.astral.sh/uv/), and [tox](https://tox.wiki/en/). To install tox, run `uv tool install tox --with tox-uv`.

After editing .j2 files in the Charmcraft source, run the following command in this repo:

```text
CHARMCRAFT_DIR=~/charmcraft just init
```

This initializes a Kubernetes charm in the `kubernetes` directory and a machine charm in the `machine` directory. If you only want one of the charms, use `just kubernetes` or `just machine` instead of `just init`.

You can test the charms as normal using tox. Alternatively, initialize the charms and immediately test them:

```text
CHARMCRAFT_DIR=~/charmcraft just init lint,unit
```

The list of environments after `just init` is passed to `tox -e <environments>` for each charm. This also works with `just kubernetes` and `just machine`.

### Integration tests

Integration tests require a Juju controller. You can use [Concierge](https://github.com/canonical/concierge) to bootstrap a Juju controller.

> [!IMPORTANT]
> Don't run integration tests using `just ... integration`. Instead, in each directory, run `charmcraft pack` followed by `tox -e integration`.

The machine charm's integration tests should pass. The charm goes active without installing a workload.

The Kubernetes charm's integration tests should fail because Juju tries to deploy the charm alongside a placeholder container image.

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

