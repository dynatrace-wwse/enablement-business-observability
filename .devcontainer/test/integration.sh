#!/bin/bash
# Load framework
source .devcontainer/util/source_framework.sh

printInfoSection "Running integration Tests for $RepositoryName"

assertRunningPod dynatrace activegate

assertRunningPod astroshop ad

assertRunningPod astroshop cart

assertRunningPod astroshop checkout

assertRunningApp astroshop
