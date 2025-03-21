#!/bin/bash
# =========================================================
#      -------- Kubernetes-Playground -------             #
# Script for installing Keptn in an Ubuntu Server LTS     #
# (20 or 18). Installed components are but not limited to:#
# Microk8s, Keptn, Istio, Helm, Docker, Docker Registry   #
# Jenkins, Dynatrace OneAgent, Dynatrace ActiveGate,      #
# Unleash, KeptnExamples                                  #
#                                                         #
# This file is the main installation process. In here you #
# define the installationBundles and its functions.       #
# The definition of variables and different versions are  #
# defined here.                                           #
#                                                         #
# 'functions.sh' is where the functions are defined and   #
# will be loaded into this shell upon execution.          #
# controlled via boolean flags.                           #
#                                                         #
# An installationBundle contains a set of multiple ins-   #
# tallation functions.                                    #
# Recommend to run the script like this:                  #
#      sudo bash -c './k8s-install.sh &'               #
# =========================================================

# ==================================================
#      ----- Variables Definitions -----           #
# ==================================================
LOGFILE='/tmp/k8splay-install.log'
touch $LOGFILE
chmod 775 $LOGFILE
pipe_log=true

# - The installation will look for this file locally, if not found it will pull it form github.
FUNCTIONS_FILE='functions.sh'

# ---- Workshop User  ----
# The flag 'create_workshop_user'=true is per default set to false. If it's set to to it'll clone the home directory from USER and allow SSH login with the given text password )
NEWUSER="k8splay"
NEWPWD="secr3t"

# ---- Define Dynatrace Environment ----
# Sample: https://{your-domain}/e/{your-environment-id} for managed or https://{your-environment-id}.live.dynatrace.com for SaaS

# Set your custom domain e.g for an internal machine like 192.168.0.1.nip.io
# So Keptn and all other services are routed and exposed properly via the Ingress Gateway
# if no DOMAIN is setted, the public IP of the machine will be converted to a magic nip.io domain
# ---- Define your Domain ----
DOMAIN=

# ---- The Email Account for the Certmanager ClusterIssuer with Let's encrypt ----
# ---- By not providing an Email and letting certificates get generated will end up in
# face Email accounts Enabling certificates with lets encrypt and not changing for your email will end up in cert rate limits for: nip.io: see https://letsencrypt.org/docs/rate-limits/
#CERTMANAGER_EMAIL=

# ==================================================
#      ----- Functions Location -----              #
# ==================================================
# - Kubernetes Playground release
PLAY_RELEASE="main"
# - Functions file location
FUNCTIONS_FILE_REPO="https://raw.githubusercontent.com/dynatrace-wwse/kubernetes-playground/${PLAY_RELEASE}/cluster-setup/functions.sh"

## ----  Write all output to the logfile ----
if [ "$pipe_log" = true ]; then
  echo "Piping all output to logfile $LOGFILE"
  echo "Type 'less +F $LOGFILE' for viewing the output of installation on realtime"
  echo ""
  # Saves file descriptors so they can be restored to whatever they were before redirection or used
  # themselves to output to whatever they were before the following redirect.
  exec 3>&1 4>&2
  # Restore file descriptors for particular signals. Not generally necessary since they should be restored when the sub-shell exits.
  trap 'exec 2>&4 1>&3' 0 1 2 3
  # Redirect stdout to file log.out then redirect stderr to stdout. Note that the order is important when you
  # want them going to the same file. stdout must be redirected before stderr is redirected to stdout.
  exec 1>$LOGFILE 2>&1
else
  echo "Not piping stdout stderr to the logfile, writing the installation to the console"
fi

# Load functions after defining the variables & versions
if [ -f "$FUNCTIONS_FILE" ]; then
  echo "The functions file $FUNCTIONS_FILE exists locally, loading functions from it. (dev)"
else
  echo "The functions file $FUNCTIONS_FILE does not exist, getting it from github."
  curl -o functions.sh $FUNCTIONS_FILE_REPO
fi

# Comfortable function for setting the sudo user.
if [ -n "${SUDO_USER}" ]; then
  USER=$SUDO_USER
fi
echo "running sudo commands as $USER"

# Wrapper for runnig commands for the real owner and not as root
alias bashas="sudo -H -u ${USER} bash -c"
# Expand aliases for non-interactive shell
shopt -s expand_aliases

# --- Loading the functions in the current shell
source $FUNCTIONS_FILE

# Setting the environment variables
TENANT=https://iid1110h.sprint.dynatracelabs.com
APITOKEN=dt0c01.yy.xx
INGESTTOKEN=dt0c01.yy.xx

DT_OTEL_API_TOKEN=dt0c01.xx.yy
DT_OTEL_ENDPOINT=https://iid1110h.sprint.dynatracelabs.com/api/v2/otlp

CERTMANAGER_EMAIL=welovedynatrace@dynatrace.ai

# ==================================================
# ---- Installation Bundle to enable        -----  #
# ==================================================
installationBundleK8sBasic

# ==================================================
# ---- Enable or Disable specific functions -----  #
# ==================================================
certmanager_install=true
certmanager_enable=true
dynatrace_deploy_cloudnative=true

# ==================================================
#  ----- Call the Installation Function -----      #
# ==================================================
doInstallation

bashas "cd $K8S_PLAY_DIR/apps/astroshop && bash deploy-astroshop.sh"