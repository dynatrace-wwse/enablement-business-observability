#!/bin/bash
# ======================================================================
#          ------- Util Functions -------                              #
#  A set of util functions for logging, validating and                 #
#  executing commands.                                                 #
# ======================================================================

# VARIABLES DECLARATION
#https://cert-manager.io/docs/release-notes/
CERTMANAGER_VERSION=1.15.3

# RUNME Version
RUNME_CLI_VERSION=3.10.2

# Setting up the variable since its not set when instantiating the vscode folder.
#CODESPACE_VSCODE_FOLDER="$REPO_PATH"
# Codespace Persisted share folder
CODESPACE_PSHARE_FOLDER="/workspaces/.codespaces/.persistedshare"

# Dynamic Variables between phases
ENV_FILE="$REPO_PATH/.devcontainer/util/.env"

if [ -e "$ENV_FILE" ]; then
  # file exists
  source $ENV_FILE
else
  # create .env file and add variables
  echo -e "DURATION=0\nERROR_COUNT=0" > $ENV_FILE
  source $ENV_FILE
fi

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