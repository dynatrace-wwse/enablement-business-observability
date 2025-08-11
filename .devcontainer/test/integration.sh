#!/bin/bash
# Load framework
source .devcontainer/util/source_framework.sh

# Load tests
source $REPO_PATH/.devcontainer/test/test_functions.sh

printInfoSection "Running integration Tests for the Enablement Framework"

assertRunningPod astroshop adservice

assertRunningPod astroshop cartservice

assertRunningPod astroshop checkoutservice

assertRunningPod cert-manager cainjector

assertRunningApp 30100
