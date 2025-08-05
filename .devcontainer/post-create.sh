#!/bin/bash

# Install RunMe
# RunMe makes markdown files runnable
# Used during end2end testing to execute the code snippets
source /workspaces/$RepositoryName/.devcontainer/util/functions.sh


bindFunctionsInShell

setupAliases

installRunme

startKindCluster

installK9s

certmanagerInstall

certmanagerEnable

dynatraceDeployOperator

deployCloudNative

deployAstroshop

# If the Codespace was created via Workflow end2end test will be done, otherwise
# it'll verify if there are error in the logs and will show them in the greeting as well a monitoring 
# notification will be sent on the instantiation details
finalizePostCreation

printInfoSection "Your dev container finished creating"
