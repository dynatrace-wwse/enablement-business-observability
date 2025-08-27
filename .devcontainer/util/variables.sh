#!/bin/bash
# ======================================================================
#          ------- Util Functions -------                              #
#  A set of util functions for logging, validating and                 #
#  executing commands.                                                 #
# ======================================================================

# VARIABLES DECLARATION
# Active Gate Version - https://gallery.ecr.aws/dynatrace/dynatrace-activegate
AG_IMAGE="public.ecr.aws/dynatrace/dynatrace-activegate:1.319.40.20250825-155600"
export AG_IMAGE=$AG_IMAGE
# OneAgent Version - https://gallery.ecr.aws/dynatrace/dynatrace-oneagent
OA_IMAGE="public.ecr.aws/dynatrace/dynatrace-oneagent:1.319.68.20250813-080958"
export OA_IMAGE=$OA_IMAGE

ENDPOINT_CODESPACES_TRACKER=https://codespaces-tracker.whydevslovedynatrace.com/api/receive
CODESPACES_TRACKER_TOKEN_STRING="ilovedynatrace"

#https://cert-manager.io/docs/release-notes/
CERTMANAGER_VERSION=1.15.3

# RUNME Version
RUNME_CLI_VERSION=3.13.2

# Setting up the variable since its not set when instantiating the vscode folder.
#CODESPACE_VSCODE_FOLDER="$REPO_PATH"
# Codespace Persisted share folder
CODESPACE_PSHARE_FOLDER="/workspaces/.codespaces/.persistedshare"

# Dynamic Variables between phases
ENV_FILE="$REPO_PATH/.devcontainer/util/.env"

# Calculating GH Repository
if [ -z "$GITHUB_REPOSITORY" ]; then
  GITHUB_REPOSITORY=$(git remote get-url origin)
  export GITHUB_REPOSITORY=$GITHUB_REPOSITORY
fi

# Calculating instantiation type
if [[ $CODESPACES == true ]]; then
  INSTANTIATION_TYPE="github-codespaces"
elif [[ $REMOTE_CONTAINERS == true ]]; then
  INSTANTIATION_TYPE="remote-container"
elif [[ -n $GITHUB_WORKFLOW ]] || [[ -n $GITHUB_STEP_SUMMARY ]]; then
  INSTANTIATION_TYPE="github-workflow"
else 
  INSTANTIATION_TYPE="local-docker-container"
fi
export INSTANTIATION_TYPE=$INSTANTIATION_TYPE

if [ -e "$ENV_FILE" ]; then
  # file exists
  source $ENV_FILE
else
  # create .env file and add variables
  echo -e "DURATION=0\nERROR_COUNT=0" > $ENV_FILE
  source $ENV_FILE
fi

# Calculating architecture
ARCH=$(arch)
export ARCH=$ARCH

CODESPACES_TRACKER_TOKEN=$(echo -n $CODESPACES_TRACKER_TOKEN_STRING | base64)
export CODESPACES_TRACKER_TOKEN=$CODESPACES_TRACKER_TOKEN

# ColorCoding
GREEN="\e[32m"
BLUE="\e[34m"
LILA="\e[35m"
YELLOW="\e[38;5;226m"
RED="\e[38;5;196m"
CYAN="\033[36m"
MAGENTA="\033[35m"
WHITE="\033[37m"
RESET="\033[0m"

# Colorcoding
GREEN="\e[32m"
GREENL="\e[1;33m"
BLUE="\e[34m"
LILA="\e[35m"
YELLOW="\e[38;5;226m"
RED="\e[38;5;196m"
CYAN="\033[36m"
MAGENTA="\033[35m"
NORMAL="\033[37m"
WHITE="\033[37m"
RESET="\033[0m"
HEART="\u2665"

thickline="=========================================================================================="
halfline="=============="
thinline="___________________________________________________________________________________________"
LOGNAME="dynatrace.enablement"

# LabGuidePort
WEBAPPPORT=30100
if [[ $CODESPACES == true ]]; then
  PRINT_USER=$GITHUB_USER
  WEBAPP_URL="https://${CODESPACE_NAME}-$WEBAPPPORT.app.github.dev"
else
  PRINT_USER=$USER
  WEBAPP_URL="http://0.0.0.0:$WEBAPPPORT"
fi