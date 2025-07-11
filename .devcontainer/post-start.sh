#!/bin/bash

source /workspaces/$RepositoryName/.devcontainer/util/functions.sh

#TODO: BeforeGoLive comment this so the Mkdocs are not exposed in the container.
# we want to monitor all interactions of the users in the live github pages.
exposeLabguide

printInfoSection "Your dev.container finished creating"