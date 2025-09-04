# Copyright 2025 david.wilding@canonical.com
# See LICENSE file for licensing details.
#
# The integration tests use the Jubilant library. See https://documentation.ubuntu.com/jubilant/
# To learn more about testing, see https://documentation.ubuntu.com/ops/latest/explanation/testing/

import logging
import pathlib

import jubilant
import pytest

logger = logging.getLogger(__name__)


def test_deploy(charm: pathlib.Path, juju: jubilant.Juju):
    """Deploy the charm under test."""
    juju.deploy(charm.resolve(), app="my-application")
    juju.wait(jubilant.all_active)


# If you implement my_application.get_version in the charm source,
# remove the @pytest.mark.skip line to enable this test.
# Alternatively, remove this test if you don't need it.
@pytest.mark.skip(reason="my_application.get_version is not implemented")
def test_workload_version_is_set(charm: pathlib.Path,, juju: jubilant.Juju):
    """Check that the correct version of the workload is running."""
    version = juju.status().apps["my-application"].version
    assert version == "3.14"  # Replace 3.14 by the expected version of the workload.
