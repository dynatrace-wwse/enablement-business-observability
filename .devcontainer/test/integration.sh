#!/bin/bash
# Load framework
source .devcontainer/util/source_framework.sh

printInfoSection "Running integration Tests for $RepositoryName"

assertRunningPod astroshop adservice

assertRunningPod astroshop cartservice

assertRunningPod astroshop checkoutservice

assertRunningPod cert-manager cainjector

assertRunningApp 30100
