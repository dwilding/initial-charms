This repo contains tools for maintaing the `kubernetes` and `machine` profiles of [Charmcraft](https://github.com/canonical/charmcraft). The tools are primarily intended to be used by the Charm Tech team at Canonical.

In the Charmcraft source, profiles are stored as .j2 template files. For example, [charm.py.j2](https://github.com/canonical/charmcraft/blob/main/charmcraft/templates/init-kubernetes/src/charm.py.j2). This makes it possible for `charmcraft init` to fill in details such as the charm name, but testing the profiles can be awkward.

### Generate charms for testing

You'll need:

  - TODO

```
CHARMCRAFT_DIR=~/charmcraft just init lint,unit && just kubernetes-extra lint,unit
```

### Update the uv.lock templates
