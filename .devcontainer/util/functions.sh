#!/bin/bash
# Functions file of the codespaces framework. Functions are loaded into the shell so the user can easily call them in a dynamic fashion.
# This file contains all core functions used for deploying applications, tools or dynatrace components. 
# Brief descrition of files:
#  - functions.sh - core functions
#  - greeting.sh -zsh/bash greeting (similar to MOTD)
#  - source_framework.sh helper file to load the framework from different places (Codespaces, VSCode Extention, plain Docker container)
#  - variables.sh - variable definitions

# ======================================================================
#          ------- Util Functions -------                              #
#  A set of util functions for logging, validating and                 #
#  executing commands.                                                 #
# ======================================================================
# THis is needed when opening a terminal and the variable is not set
if [ -z "$REPO_PATH" ]; then
  export REPO_PATH="$(pwd)"
  export RepositoryName=$(basename "$REPO_PATH")
fi

# VARIABLES DECLARATION
source "$REPO_PATH/.devcontainer/util/variables.sh"

# FUNCTIONS DECLARATIONS
timestamp() {
  date +"[%Y-%m-%d %H:%M:%S]"
}

printInfo() {
  # The second argument defines if the log should be printed out or not
  if [ "$2" = "false" ]; then
    return 0
  fi
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|${RESET} $1 ${LILA}|"
}

printInfoSection() {
  if [ "$2" = "false" ]; then
    return 0
  fi
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|$thickline"
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|$halfline ${RESET}$1${LILA} $halfline"
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|$thinline"
}

printWarn() {
  if [ "$2" = "false" ]; then
    return 0
  fi
  echo -e "${GREEN}[$LOGNAME| ${YELLOW}WARN${GREEN} |$(timestamp) ${LILA}| ${RESET}$1${LILA}  |"
}

printError() {
  if [ "$2" = "false" ]; then
    return 0
  fi
  echo -e "${GREEN}[$LOGNAME| ${RED}ERROR${GREEN} |$(timestamp) ${LILA}| ${RESET}$1${LILA}  |"
}

entrypoint(){
  printInfoSection "Making sure user permissions, host mapping and docker.sock are mapped correctly"
  if [ true ]; then
    USER=$(whoami)
    printInfo "PID is $$, running as $USER inside the container"
  
    printInfo "Adding containers Hosts to etc/hosts/ for network resolution and sharing"
    # Add hostname to docker container's /etc/hosts
    HOST_MAPPING="127.0.0.1  $(hostname)"
    # We pipe out the output since sudo at this points gives an error due the hostname not being resolvable
    sudo sh -c "echo \"$HOST_MAPPING\" >> /etc/hosts" > /dev/null 2>&1
    # Verify output (optional)
    printInfo "/etc/hosts content:"
    #cat /etc/hosts

    printInfo "Verifying the Hosts Docker.sock GID (DOCKER_SOCK_GID) vs Container Docker Group GID (DOCKER_GROUP_ID)"
    # Even if the user is in the same group (docker) since they are sharing the socket, the GID of the socket needs to match the GID of the docker group in the container.
    # GID from the socker stat
    DOCKER_SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
    # Group ID for docker group
    DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3)
    # Mapping docker groups of Host and Container
    if [ $DOCKER_SOCK_GID = $DOCKER_GROUP_ID ]; then
        printInfo "DOCKER_SOCK_GID[$DOCKER_SOCK_GID] matches DOCKER_GROUP_ID[$DOCKER_GROUP_ID]. No changes needed."
    else
        printInfo "DOCKER_SOCK_GID[$DOCKER_SOCK_GID] do NOT match DOCKER_GROUP_ID[$DOCKER_GROUP_ID]. Updating..."
        sudo groupmod -g $DOCKER_SOCK_GID docker && printInfo "Updated correctly..."

        printInfo "Adding '$USER' to the docker group to have access to the docker socket"
        sudo usermod -aG docker $USER

        printInfo "Changing shell with 'newgrp docker' to apply changes immediately of the docker group membership"
        
        printInfo "Executing following commands as Group docker: 0:$0 ,$1 ,$2, @:$@ , *:$*"
        #exec newgrp docker "$0 $*"
        #exec sg docker "$@"
        #exec sg docker "$0"
        exec sg docker "$*"
        
        # Construct an array which quotes all the command-line parameters.
        #arr=("${@/#/\"}")
        #arr=("${arr[*]/%/\"}")
        #exec sg docker "$0 ${arr[@]}"
        
        #exec newgrp docker "$@"
        printInfo "Replacing current shell process with the command and its arguments passed to the script or function since we are at entrypoint"
        exec "$@"
    fi
  else
    printInfo "PID is not 1, it is $$, nothing to verify, we are not at the entrypoint."
  fi
}

postCodespaceTracker(){
  
  printInfo "Sending bizevent for $RepositoryName with $ERROR_COUNT issues built in $DURATION seconds"

  curl -X POST $ENDPOINT_CODESPACES_TRACKER \
  -H "Content-Type: application/json" \
  -H "Authorization: $CODESPACES_TRACKER_TOKEN" \
  -d "{
  \"repository\": \"$GITHUB_REPOSITORY\",
  \"repository.name\": \"$RepositoryName\",
  \"codespace.errors\": \"$ERROR_COUNT\",
  \"codespace.creation\": \"$DURATION\",
  \"codespace.type\": \"$INSTANTIATION_TYPE\",
  \"codespace.arch\": \"$ARCH\",
  \"codespace.name\": \"$CODESPACE_NAME\",
  \"tenant\": \"$DT_TENANT\"
  }"
}

printGreeting(){
  bash $REPO_PATH/.devcontainer/util/greeting.sh
}

waitForPod() {
  # Function to filter by Namespace and POD string, default is ALL namespaces
  # If 2 parameters then the first is Namespace the second is Pod-String
  # If 1 parameters then Namespace == all-namespaces the first is Pod-String
  if [[ $# -eq 2 ]]; then
    namespace_filter="-n $1"
    pod_filter="$2"
  elif [[ $# -eq 1 ]]; then
    namespace_filter="--all-namespaces"
    pod_filter="$1"
  fi
  RETRY=0
  RETRY_MAX=60
  # Get all pods, count and invert the search for not running nor completed. Status is for deleting the last line of the output
  CMD="kubectl get pods $namespace_filter 2>&1 | grep -c -E '$pod_filter'"
  printInfo "Verifying that pods in \"$namespace_filter\" with name \"$pod_filter\" is scheduled in a workernode "
  while [[ $RETRY -lt $RETRY_MAX ]]; do
    pods_running=$(eval "$CMD")
    if [[ "$pods_running" != '0' ]]; then
      printInfo "\"$pods_running\" pods are running on \"$namespace_filter\" with name \"$pod_filter\" exiting loop."
      break
    fi
    RETRY=$(($RETRY + 1))
    printWarn "Retry: ${RETRY}/${RETRY_MAX} - No pods are running on  \"$namespace_filter\" with name \"$pod_filter\". Wait 10s for $pod_filter PoDs to be scheduled..."
    sleep 10
  done
  
  if [[ $RETRY == $RETRY_MAX ]]; then
    printError "No pods are running on  \"$namespace_filter\" with name \"$pod_filter\". Check their events. Exiting installation..."
    exit 1
  fi
}

# shellcheck disable=SC2120
waitForAllPods() {
  # Function to filter by Namespace, default is ALL
  if [[ $# -eq 1 ]]; then
    namespace_filter="-n $1"
  else
    namespace_filter="--all-namespaces"
  fi
  RETRY=0
  RETRY_MAX=60
  # Get all pods, count and invert the search for not running nor completed. Status is for deleting the last line of the output
  CMD="kubectl get pods $namespace_filter 2>&1 | grep -c -v -E '(Running|Completed|Terminating|STATUS)'"
  printInfo "Checking and wait for all pods in \"$namespace_filter\" to run."
  while [[ $RETRY -lt $RETRY_MAX ]]; do
    pods_not_ok=$(eval "$CMD")
    if [[ "$pods_not_ok" == '0' ]]; then
      printInfo "All pods are running."
      break
    fi
    RETRY=$(($RETRY + 1))
    printWarn "Retry: ${RETRY}/${RETRY_MAX} - Wait 10s for $pods_not_ok PoDs to finish or be in state Running ..."
    sleep 10
  done

  if [[ $RETRY == $RETRY_MAX ]]; then
    printError "Following pods are not still not running. Please check their events. Exiting installation..."
    kubectl get pods --field-selector=status.phase!=Running -A
    exit 1
  fi
}

waitForAllReadyPods() {
  # Function to filter by Namespace, default is ALL
  if [[ $# -eq 1 ]]; then
    namespace_filter="-n $1"
  else
    namespace_filter="--all-namespaces"
  fi
  RETRY=0
  RETRY_MAX=60
  # Get all pods, count and invert the search for not running nor completed. Status is for deleting the last line of the output
  CMD="kubectl get pods $namespace_filter 2>&1 | grep -c -v -E '(1\/1|2\/2|3\/3|4\/4|5\/5|6\/6|READY)'"
  printInfo "Checking and wait for all pods in \"$namespace_filter\" to be running and ready (max of 6 containers per pod)"
  while [[ $RETRY -lt $RETRY_MAX ]]; do
    pods_not_ok=$(eval "$CMD")
    if [[ "$pods_not_ok" == '0' ]]; then
      printInfo "All pods are running."
      break
    fi
    RETRY=$(($RETRY + 1))
    printWarn "Retry: ${RETRY}/${RETRY_MAX} - Wait 10s for $pods_not_ok PoDs to finish or be in state Ready & Running ..."
    sleep 10
  done

  if [[ $RETRY == $RETRY_MAX ]]; then
    printError "Following pods are not still not running. Please check their events. Exiting installation..."
    kubectl get pods --field-selector=status.phase!=Running -A
    exit 1
  fi
}

waitAppCanHandleRequests(){
  # Function to filter by Namespace, default is ALL
  if [[ $# -eq 1 ]]; then
    PORT="$1"
  else
    PORT="30100"
  fi
  
  RC="500"

  URL=http://localhost:$PORT
  RETRY=0
  RETRY_MAX=5
  # Get all pods, count and invert the search for not running nor completed. Status is for deleting the last line of the output
  CMD="curl --silent $URL > /dev/null"
  printInfo "Verifying that the app can handle HTTP requests on $URL"
  while [[ $RETRY -lt $RETRY_MAX ]]; do
    RESPONSE=$(eval "$CMD")
    RC=$?
    #Common RC from cURL
    #0: Success
    #6: Could not resolve host
    #7: Failed to connect to host
    #28: Operation timeout
    #35: SSL connect error
    #56:Failure with receiving network data
    if [[ "$RC" -eq 0 ]]; then
      printInfo "App is running on $URL"
      break
    fi
    RETRY=$(($RETRY + 1))
    printWarn "Retry: ${RETRY}/${RETRY_MAX} - App can't handle HTTP requests on $URL. [cURL RC:$RC] Waiting 10s..."
    sleep 10
  done

  if [[ $RETRY == $RETRY_MAX ]]; then
    printError "App is still not able to handle requests. Please check the events"
  fi
}

installHelm() {
  # https://helm.sh/docs/intro/install/#from-script
  printInfoSection " Installing Helm"
  cd /tmp
  sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  sudo chmod 700 get_helm.sh
  sudo /tmp/get_helm.sh

  printInfoSection "Helm version"
  helm version

  # https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository
  printInfoSection "Helm add Bitnami repo"
  printInfoSection "helm repo add bitnami https://charts.bitnami.com/bitnami"
  helm repo add bitnami https://charts.bitnami.com/bitnami

  printInfoSection "Helm repo update"
  helm repo update

  printInfoSection "Helm search repo bitnami"
  helm search repo bitnami
}

installHelmDashboard() {

  printInfoSection "Installing Helm Dashboard"
  helm plugin install https://github.com/komodorio/helm-dashboard.git

  printInfoSection "Running Helm Dashboard"
  helm dashboard --bind=0.0.0.0 --port 8002 --no-browser --no-analytics >/dev/null 2>&1 &

}

installKubernetesDashboard() {
  # https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
  printInfoSection " Installing Kubernetes dashboard"

  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

  # In the functions you can specify the amount of retries and the NS
  # shellcheck disable=SC2119
  waitForAllPods
  printInfoSection "kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8001:443 --address=\"0.0.0.0\", (${attempts}/${max_attempts}) sleep 10s"
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8001:443 --address="0.0.0.0" >/dev/null 2>&1 &
  # https://github.com/komodorio/helm-dashboard

  # Do we need this?
  printInfoSection "Create ServiceAccount and ClusterRoleBinding"
  kubectl apply -f /app/.devcontainer/etc/k3s/dashboard-adminuser.yaml
  kubectl apply -f /app/.devcontainer/etc/k3s/dashboard-rolebind.yaml

  printInfoSection "Get admin-user token"
  kubectl -n kube-system create token admin-user --duration=8760h
}

installK9s() {
  printInfoSection "Installing k9s CLI"
  curl -sS https://webinstall.dev/k9s | bash
}


setUpTerminal(){
  printInfoSection "Sourcing the DT-Enablement framework functions to the terminal, adding aliases, a Dynatrace greeting and installing power10k into .zshrc for user $USER "

  printInfoSection "Installing power10k into .zshrc for user $USER "
  
  #TODO: Verify if ohmyZsh is there so we can add this functionality to any server by loading the functions
  # source .devcontainer/util/source_framework.sh && setUpTerminal
  # or at least add ohmyzsh, power10k and no greeting
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  
  if [[ $CODESPACES == true ]]; then
    printInfoSection "Power10k configuration is limited on web. If you open the devcontainer on an IDE type 'p10k configure' to reconfigure it."
    cp $REPO_PATH/.devcontainer/p10k/.p10k.zsh.web $HOME/.p10k.zsh
  else 
    printInfoSection "Power10k configuration with many icons added."
    cp $REPO_PATH/.devcontainer/p10k/.p10k.zsh $HOME/.p10k.zsh
  fi
  
  cp $REPO_PATH/.devcontainer/p10k/.zshrc $HOME/.zshrc
  
  bindFunctionsInShell

  setupAliases
}


bindFunctionsInShell() {
  printInfo "Binding functions.sh and adding a Greeting in the .zshrc for user $USER "
  echo "
#Making sure the Locale is set properly
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Loading all this functions in CLI
source $REPO_PATH/.devcontainer/util/functions.sh

#print greeting everytime a Terminal is opened
printGreeting

#supress p10k instant prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
" >> /"$HOME"/.zshrc

}

setupAliases() {
  printInfo "Adding Bash and Kubectl Pro CLI aliases to the end of the .zshrc for user $USER "
  echo "
# Alias for ease of use of the CLI
alias las='ls -las' 
alias c='clear' 
alias hg='history | grep' 
alias h='history' 
alias gita='git add -A'
alias gitc='git commit -s -m'
alias gitp='git push'
alias gits='git status'
alias gith='git log --graph --pretty=\"%C(yellow)[%h] %C(reset)%s by %C(green)%an - %C(cyan)%ad %C(auto)%d\" --decorate --all --date=human'
alias vaml='vi -c \"set syntax:yaml\" -' 
alias vson='vi -c \"set syntax:json\" -' 
alias pg='ps -aux | grep' 
" >> /"$HOME"/.zshrc
}

installRunme() {
  printInfoSection "Installing Runme Version $RUNME_CLI_VERSION"
  mkdir runme_binary
  wget -O runme_binary/runme_linux_x86_64.tar.gz https://download.stateful.com/runme/${RUNME_CLI_VERSION}/runme_linux_x86_64.tar.gz
  tar -xvf runme_binary/runme_linux_x86_64.tar.gz --directory runme_binary
  sudo mv runme_binary/runme /usr/local/bin
  rm -rf runme_binary
}

stopKindCluster(){
  printInfoSection "Stopping Kubernetes Cluster (kind-control-plane)"
  docker stop kind-control-plane 
}

startKindCluster(){
  printInfoSection "Starting Kubernetes Cluster (kind-control-plane)"
  KINDIMAGE="kind-control-plane"
  KIND_STATUS=$(docker inspect -f '{{.State.Status}}' $KINDIMAGE 2>/dev/null)
  if [ "$KIND_STATUS" = "exited" ] || [ "$KIND_STATUS" = "dead" ]; then
    printWarn "There is a stopped $KINDIMAGE, starting it..."
    docker start $KINDIMAGE
    attachKindCluster
  elif  [ "$KIND_STATUS" = "running" ]; then
    printWarn "A $KINDIMAGE is already running, attaching to it..."
    attachKindCluster
  else
    printInfo "No $KINDIMAGE was found, creating a new one..."
    createKindCluster
  fi
  printInfo "Kind reachabe under:"
  kubectl cluster-info --context kind-kind
  printInfo "-----"
  printInfo "The following functions are available for you to maximize your K8s experience:"
  printInfo "startKindCluster - will start, create or attach to a running Cluster"
  printInfo "other useful functions: stopKindCluster createKindCluster deleteKindCluster"
  printInfo "attachKindCluster "
  printInfo "-----"
  printInfo "Setting the current context to 'kube-system' instead of 'default' you can change it by typing"
  printInfo "kubectl config set-context --current --namespace=<namespace-name>"
  kubectl config set-context --current --namespace=kube-system
}

attachKindCluster(){
  printInfoSection "Attaching to running Kubernetes Cluster (kind-control-plane)"
  local KUBEDIR="$HOME/.kube"
  if [ -d $KUBEDIR ]; then
    printWarn "Kuberconfig $KUBEDIR exists, overriding Kubernetes conection"
  else
    printInfo "Kubeconfig $KUBEDIR does not exist, creating a new one"
    mkdir -p $HOME/.kube
  fi
  kind get kubeconfig > $KUBEDIR/config && printInfo "Connection created" || printWarn "Issue creating connection"
}


createKindCluster() {
  printInfoSection "Creating Kubernetes Cluster (kind-control-plane)"
  # Create k8s cluster
  printInfo "Creating Kind cluster"
  kind create cluster --config "$REPO_PATH/.devcontainer/kind-cluster.yml" --wait 5m &&\
    printInfo "Kind cluster created successfully, reachabe under:" ||\
    printWarn "Kind cluster could not be created"
  kubectl cluster-info --context kind-kind
}

deleteKindCluster() {
  printInfoSection "Deleting Kubernetes Cluster (Kind)"
  kind delete cluster --name kind
  printInfo "Kind cluster deleted successfully."
}

certmanagerInstall() {
  printInfoSection "Install CertManager $CERTMANAGER_VERSION"
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v$CERTMANAGER_VERSION/cert-manager.yaml
  # shellcheck disable=SC2119
  waitForAllPods cert-manager
}

generateRandomEmail() {
  echo "email-$RANDOM-$RANDOM@dynatrace.ai"
}

certmanagerEnable() {
  printInfoSection "Installing ClusterIssuer with HTTP Letsencrypt "

  if [ -n "$CERTMANAGER_EMAIL" ]; then
    printInfo "Creating ClusterIssuer for $CERTMANAGER_EMAIL"
    # Simplecheck to check if the email address is valid
    if [[ $CERTMANAGER_EMAIL == *"@"* ]]; then
      echo "Email address is valid! - $CERTMANAGER_EMAIL"
      EMAIL=$CERTMANAGER_EMAIL
    else
      echo "Email address $CERTMANAGER_EMAIL is not valid. Email will be generated"
      EMAIL=$(generateRandomEmail)
    fi
  else
    echo "Email not passed.  Email will be generated"
    EMAIL=$(generateRandomEmail)
  fi

  printInfo "EmailAccount for ClusterIssuer $EMAIL, creating ClusterIssuer"
  cat $REPO_PATH/.devcontainer/yaml/clusterissuer.yaml | sed 's~email.placeholder~'"$EMAIL"'~' >$REPO_PATH/.devcontainer/yaml/gen/clusterissuer.yaml

  kubectl apply -f $REPO_PATH/.devcontainer/yaml/gen/clusterissuer.yaml

  printInfo "Let's Encrypt Process in kubectl for CertManager"
  printInfo " For observing the creation of the certificates: \n
              kubectl describe clusterissuers.cert-manager.io -A
              kubectl describe issuers.cert-manager.io -A
              kubectl describe certificates.cert-manager.io -A
              kubectl describe certificaterequests.cert-manager.io -A
              kubectl describe challenges.acme.cert-manager.io -A
              kubectl describe orders.acme.cert-manager.io -A
              kubectl get events
              "

  waitForAllPods cert-manager
  # Not needed
  #bashas "cd $K8S_PLAY_DIR/cluster-setup/resources/ingress && bash add-ssl-certificates.sh"
}

validateSaveCredentials() {
  if [[ $# -eq 3 ]]; then
    printInfo "Validating and saving Secrets DT_TENANT DT_OPERATOR_TOKEN DT_INGEST_TOKEN"
    DT_TENANT=$1
    DT_OPERATOR_TOKEN=$2
    DT_INGEST_TOKEN=$3
    verifyParseSecret $DT_TENANT true; [ $? -eq 1 ] && verifyParseSecret $DT_TENANT false || DT_TENANT=$(verifyParseSecret $DT_TENANT false)
    verifyParseSecret $DT_OPERATOR_TOKEN true; [ $? -eq 1 ] && verifyParseSecret $DT_OPERATOR_TOKEN false || DT_OPERATOR_TOKEN=$(verifyParseSecret $DT_OPERATOR_TOKEN false)
    verifyParseSecret $DT_INGEST_TOKEN true; [ $? -eq 1 ] && verifyParseSecret $DT_INGEST_TOKEN false || DT_INGEST_TOKEN=$(verifyParseSecret $DT_INGEST_TOKEN false)
    DT_OTEL_ENDPOINT=$DT_TENANT/api/v2/otlp

    kubectl delete configmap -n default dtcredentials 2>/dev/null

    kubectl create configmap -n default dtcredentials \
      --from-literal=tenant=${DT_TENANT} \
      --from-literal=apiToken=${DT_OPERATOR_TOKEN} \
      --from-literal=dataIngestToken=${DT_INGEST_TOKEN}
    # Exporting clean values
    export DT_TENANT=$DT_TENANT
    export DT_OPERATOR_TOKEN=$DT_OPERATOR_TOKEN
    export DT_INGEST_TOKEN=$DT_INGEST_TOKEN
    export DT_INGEST_TOKEN=$DT_INGEST_TOKEN
    export DT_OTEL_ENDPOINT=$DT_OTEL_ENDPOINT
    return 0
  else
    printError "validateSaveCredentials function should be used like saveCredentials DT_TENANT DT_OPERATOR_TOKEN DT_INGEST_TOKEN"
    return 1
  fi
}

verifyParseSecret(){
  # Function to verify and parse Dynatrace Tenants and tokens so they can be used more comfortably.
  # as first argument the tenant or token is passed, as second argument a boolean is passed for printing the logic. When print_log == true, then log is printed out but the 
  # variable is not echoed out, this way is not printed in the log. If print_log =0 false, then the variable is echoed out so the value can be catched as return vaue and stored.
  local secret="$1"

  local print_log="$2"
  if [ -z "$print_log" ]; then
    # As default no log is printed out. 
    print_log=false
  fi

  if [ -z "$secret" ]; then
    printError "Function to validate secrets was called but no secret was provided" $print_log
    return 1
  else 
    # Logic
    # convert apps to live
    # https://abc123.apps.dynatrace.com -> https://abc123.live.dynatrace.com 
    # remove apps from string
    # https://abc123.sprint.apps.dynatracelabs.com -> https://abc123.sprint.dynatracelabs.com 
    # https://abc123.dev.apps.dynatracelabs.com -> https://abc123.dev.dynatracelabs.com 
    # Verify if its a valid tenant
    if echo "$secret" | grep -E -q "^https:" && echo "$secret" | grep -E -q "\.dynatracelabs\.com|\.dynatrace\.com"; then
       printInfo "Valid: String starts with 'https' and contains dynatrace.com or dynatracelabs.com" $print_log
      
      # Parse Production tenants
      if echo "$secret" | grep -q "\.apps\.dynatrace\.com"; then
        printWarn "Production tenant invalid for API requests: changing apps for live" $print_log
        secret=$(echo "$secret" | sed 's/\.apps\.dynatrace\.com.*$/\.live.dynatrace\.com/g')
      fi
      
      # Parse for Sprint & DEV tenants
      if echo "$secret" | grep -q "\.apps\.dynatracelabs\.com"; then
        printWarn "Sprint tenant invalid for API requests: removing apps" $print_log
        secret=$(echo "$secret" | sed 's/\.apps\.dynatracelabs\.com.*$/\.dynatracelabs\.com/g')
      fi
      # remove anything after .com
      if echo "$secret" | grep -q "\.com/"; then
        printWarn "/ detected after .com, invalid for API requests: removing anything after .com" $print_log
        secret=$(echo "$secret" | sed 's/\.com.*$/\.com/')
      fi
      printInfo "Tenant URL valid for API requests: $secret" $print_log
      if [ "${print_log}" = "false" ]; then
        echo "$secret"
      fi
      return 0
    elif  [[ "$secret" == dt0c01.*  && ${#secret} -gt 60 ]];  then
      printInfo "Valid Dynatrace Token format. Starts with dt0c01.XXX and has the minimum lenght." $print_log
      if [ "${print_log}" = "false" ]; then
        echo "$secret"
      fi
      return 0
    else
      printError "Invalid secret, this is not a valid dynatrace tenant nor dynatrace token, please verify this: $secret" $print_log
    return 1
    fi
  fi

}

dynatraceEvalReadSaveCredentials() {
  printInfoSection "Dynatrace evaluating and reading/saving secrets. Defined order 1.-arguments, 2.- environment variables, finally load from configmap"
  if [ "${DT_EVAL_SECRETS}" = "true" ]; then 
    printInfo "Dynatrace secrets have been evaluated already in the session. If you want to override them unset DT_EVAL_SECRETS and call this function again."
    printInfo "For printing out the secrets call the function 'printSecrets' "
    return 0
  fi

  local found=1

  if [[ $# -eq 3 ]]; then
    DT_TENANT=$1
    DT_OPERATOR_TOKEN=$2
    DT_INGEST_TOKEN=$3
    # Passed as argument
    printInfo "Secrets passed as arguments"
    validateSaveCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN
    found=0

  elif [[ -n "${DT_TENANT}" && -n "${DT_OPERATOR_TOKEN}" && -n "${DT_INGEST_TOKEN}" ]]; then
    # Found in env 
    printInfo "Secrets found in environment variables"
    validateSaveCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN
    found=0
  elif [[ -n "${DT_TENANT}" && -z "${DT_OPERATOR_TOKEN}" && -z "${DT_INGEST_TOKEN}" ]]; then
    printWarn "Dynatrace Tenant defined but tokens are missing"
    validateSaveCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN
    found=0
  else
    printWarn "Dynatrace secrets not found as arguments nor env vars, reading from config map"
    kubectl get configmap -n default dtcredentials 2>/dev/null
    # Getting the data size
    data=$(kubectl get configmap -n default dtcredentials | awk '{print $2}')
    # parsing to number
    size=$(echo $data | grep -o '[0-9]*')
    printInfo "The Configmap has $size variables stored"
    if [[ $? -eq 0 ]]; then
      DT_TENANT=$(kubectl get configmap -n default dtcredentials -ojsonpath={.data.tenant})
      DT_OPERATOR_TOKEN=$(kubectl get configmap -n default dtcredentials -ojsonpath={.data.apiToken})
      DT_INGEST_TOKEN=$(kubectl get configmap -n default dtcredentials -ojsonpath={.data.dataIngestToken})
      found=0
    else
        printInfo "ConfigMap not found, resetting variables"
        unset DT_TENANT DT_OPERATOR_TOKEN DT_INGEST_TOKEN
    fi
  fi

  if [[ $found -eq 0 ]]; then

    export DT_TENANT=$DT_TENANT
    export DT_OPERATOR_TOKEN=$DT_OPERATOR_TOKEN
    export DT_INGEST_TOKEN=$DT_INGEST_TOKEN
    export DT_INGEST_TOKEN=$DT_INGEST_TOKEN
    export DT_OTEL_ENDPOINT=$DT_OTEL_ENDPOINT
    export DT_EVAL_SECRETS=true
    printSecrets
  else 
    printError "No Dynatrace secrets have been found in the environment and are needed for Dynatrace components."
    unset DT_EVAL_SECRETS
    exit 1
  fi

  return $found
}

printSecrets(){
    # Print all known vars
    printInfo "Dynatrace Tenant: $DT_TENANT"
    printInfo "Dynatrace API & PaaS Token: ${DT_OPERATOR_TOKEN:0:14}xxx..."
    printInfo "Dynatrace Ingest Token: ${DT_INGEST_TOKEN:0:14}xxx..."
    printInfo "Dynatrace Otel API Token: ${DT_INGEST_TOKEN:0:14}xxx..."
    printInfo "Dynatrace Otel Endpoint: $DT_OTEL_ENDPOINT"
}

deployCloudNative() {
  dynatraceEvalReadSaveCredentials "$@"

  printInfoSection "Deploying Dynatrace in CloudNativeFullStack mode for $DT_TENANT"
  if [ -n "${DT_TENANT}" ]; then
    # Check if the Webhook has been created and is ready
    kubectl -n dynatrace wait pod --for=condition=ready --selector=app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/component=webhook --timeout=300s

    kubectl -n dynatrace apply -f $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml

    printInfo "Log capturing will be handled by the Host agent."
    
    # we wait for the AG to be scheduled
    waitForPod dynatrace activegate
    
    waitForAllReadyPods dynatrace
  else
    printInfo "Not deploying the Dynatrace Operator, no credentials found"
  fi
}

deployApplicationMonitoring() { 

  dynatraceEvalReadSaveCredentials "$@"

  printInfoSection "Deploying Dynatrace in ApplicationMonitoring mode for $DT_TENANT"
  if [ -n "${DT_TENANT}" ]; then
    # Check if the Webhook has been created and is ready
    kubectl -n dynatrace wait pod --for=condition=ready --selector=app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/component=webhook --timeout=300s

    kubectl -n dynatrace apply -f $REPO_PATH/.devcontainer/yaml/gen/dynakube-apponly.yaml
    
    # we wait for the AG to be scheduled
    waitForPod dynatrace activegate

    #FIXME: When deploying in AppOnly we need to capture the logs, either with log module or FluentBit
    #FIXME: Get log module "latest" is it possible for prod and sprint? verify
    waitForAllReadyPods dynatrace
  else
    printInfo "Not deploying the Dynatrace Operator, no credentials found"
  fi
}

undeployDynakubes() {
    printInfoSection "Undeploying Dynakubes, OneAgent installation from Workernode if installed"

    kubectl -n dynatrace delete dynakube --all
    #FIXME: Test uninstalling Dynatracem good when changing monitoring modes. 
    #kubectl -n dynatrace wait pod --for=condition=delete --selector=app.kubernetes.io/name=oneagent,app.kubernetes.io/managed-by=dynatrace-operator --timeout=300s
    sudo bash /opt/dynatrace/oneagent/agent/uninstall.sh 2>/dev/null
}

uninstallDynatrace() {
    echo "Uninstalling Dynatrace"
    undeployDynakubes

    echo "Uninstalling Dynatrace"
    helm uninstall dynatrace-operator -n dynatrace

    kubectl delete namespace dynatrace
}

# shellcheck disable=SC2120
dynatraceDeployOperator() {

  printInfoSection "Deploying Dynatrace Operator"
  # posssibility to load functions.sh and call dynatraceDeployOperator A B C to save credentials and override
  # or just run in normal deployment
  dynatraceEvalReadSaveCredentials "$@"
  # new lines, needed for workflow-k8s-playground, cluster in dt needs to have the name k8s-playground-{requestuser} to be able to spin up multiple instances per tenant

  if [ -n "${DT_TENANT}" ]; then
    # Deploy Operator

    deployOperatorViaHelm

    waitForAllPods dynatrace

    #FIXME: Add Ingress Nginx instrumentation and always expose in a port so all apps have RUM regardless of technology
    #printInfoSection "Instrumenting NGINX Ingress"
    #bashas "cd $K8S_PLAY_DIR/apps/nginx && bash instrument-nginx.sh"

  else
    printInfo "Not deploying the Dynatrace Operator, no credentials found"
  fi
}


generateDynakube(){
    #FIXME: This code needs to be refactored. Generate a cleaner Dynakube for both architectures. 
    # SET API URL
    API="/api"
    DT_API_URL=$DT_TENANT$API
    
    # Read the actual hostname in case changed during instalation
    CLUSTERNAME=$(hostname)
    export CLUSTERNAME

    arch=$(uname -m)
    ARM=false

    if [[ "$arch" == "x86_64" ]]; then
      printInfo "Codespace is running in AMD (x86_64), Dynakube image is set as default to pull the latest from the tenant $DT_TENANT"
    elif [[ "$arch" == *"arm"* || "$arch" == *"aarch64"* ]]; then
      printWarn "Codespace is running in ARM architecture ($arch), Dynakube image will be set in Dynakube for AG and OneAgent."
      printWarn "ActiveGate image: $AG_IMAGE"
      printWarn "OneAgent image: $OA_IMAGE"
      ARM=true
    else
      printInfo "Codespace is running on an unkown architecture ($arch), Dynakube image will be set in Dynakube for AG and OneAgent."
      printInfo "ActiveGate image: $AG_IMAGE"
      printInfo "OneAgent image: $OA_IMAGE"
      ARM=true
    fi

    # Generate DynaKubeSkel with API URL
    sed -e 's~apiUrl: https://ENVIRONMENTID.live.dynatrace.com/api~apiUrl: '"$DT_API_URL"'~' $REPO_PATH/.devcontainer/yaml/dynakube-skel-head.yaml > $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml

    # ClusterName for API
    sed 's~feature.dynatrace.com/automatic-kubernetes-api-monitoring-cluster-name: "CLUSTERNAME"~feature.dynatrace.com/automatic-kubernetes-api-monitoring-cluster-name: "'"$CLUSTERNAME"'"~g' $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml > $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp 

    mv $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml 
    
    # Replace Networkzone
    sed 's~networkZone: CLUSTERNAME~networkZone: '$CLUSTERNAME'~g' $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml > $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp 
    
    mv $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml 
    
    # Add ActiveGate config (added first so its applied to both CNFS and AppOnly)
    cat $REPO_PATH/.devcontainer/yaml/dynakube-body-activegate.yaml >> $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml
    
    # Set ActiveGate Group 
    sed 's~group: CLUSTERNAME~group: '$CLUSTERNAME'~g' $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml > $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp
    mv $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml 

    if [[ $ARM == true  ]]; then
      sed 's~# image: ""~image: "'$AG_IMAGE'"~g' $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml > $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp
      mv $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml.tmp $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml 
    fi

    # Generate CloudNative Body (head + CNFS)
    cat $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml $REPO_PATH/.devcontainer/yaml/dynakube-body-cloudnative.yaml > $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml
    
    # Set CloudNative HostGroup
    sed 's~hostGroup: CLUSTERNAME~hostGroup: '$CLUSTERNAME'~g' $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml >  $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml.tmp
    mv  $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml.tmp $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml

    if [[ $ARM == true  ]]; then
      sed 's~# image: ""~image: "'$OA_IMAGE'"~g'  $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml >  $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml.tmp
      mv  $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml.tmp $REPO_PATH/.devcontainer/yaml/gen/dynakube-cloudnative.yaml
    fi
    # Generate AppOnly Body
    cat $REPO_PATH/.devcontainer/yaml/gen/dynakube-skel-head.yaml $REPO_PATH/.devcontainer/yaml/dynakube-body-apponly.yaml > $REPO_PATH/.devcontainer/yaml/gen/dynakube-apponly.yaml

}

deployOperatorViaKubectl(){

  printInfoSection "Deploying Operator via kubectl"

  kubectl create namespace dynatrace

  kubectl apply -f https://github.com/Dynatrace/dynatrace-operator/releases/download/v1.6.1/kubernetes-csi.yaml

  # Save Dynatrace Secret
  kubectl -n dynatrace create secret generic dev-container --from-literal="apiToken=$DT_OPERATOR_TOKEN" --from-literal="dataIngestToken=$DT_INGEST_TOKEN"

  generateDynakube

}

deployOperatorViaHelm(){

  helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator --create-namespace --namespace dynatrace --atomic

  # Save Dynatrace Secret
  kubectl -n dynatrace create secret generic dev-container --from-literal="apiToken=$DT_OPERATOR_TOKEN" --from-literal="dataIngestToken=$DT_INGEST_TOKEN"

  generateDynakube

}

undeployOperatorViaHelm(){

  helm uninstall dynatrace-operator --namespace dynatrace

}


deployAITravelAdvisorApp(){
  printInfoSection "Deploying AI Travel Advisor App & it's LLM"

  kubectl apply -f $REPO_PATH/.devcontainer/apps/ai-travel-advisor/k8s/namespace.yaml

  kubectl -n ai-travel-advisor create secret generic dynatrace --from-literal="token=$DT_TOKEN" --from-literal="endpoint=$DT_TENANT/api/v2/otlp"
  
  # Start OLLAMA
  printInfo "Deploying our LLM => Ollama"
  kubectl apply -f $REPO_PATH/.devcontainer/apps/ai-travel-advisor/k8s/ollama.yaml
  waitForPod ai-travel-advisor ollama
  printInfo "Waiting for Ollama to get ready"
  kubectl -n ai-travel-advisor wait --for=condition=Ready pod --all --timeout=10m
  printInfo "Ollama is ready"

  # Start Weaviate
  printInfo "Deploying our VectorDB => Weaviate"
  kubectl apply -f $REPO_PATH/.devcontainer/apps/ai-travel-advisor/k8s/weaviate.yaml

  waitForPod ai-travel-advisor weaviate
  printInfo "Waiting for Weaviate to get ready"
  kubectl -n ai-travel-advisor wait --for=condition=Ready pod --all --timeout=10m
  printInfo "Weaviate is ready"

  # Start AI Travel Advisor
  printInfo "Deploying AI App => AI Travel Advisor"
  kubectl apply -f $REPO_PATH/.devcontainer/apps/ai-travel-advisor/k8s/ai-travel-advisor.yaml
  
  waitForPod ai-travel-advisor ai-travel-advisor
  printInfo "Waiting for AI Travel Advisor to get ready"
  kubectl -n ai-travel-advisor wait --for=condition=Ready pod --all --timeout=10m
  printInfo "AI Travel Advisor is ready"

  # Define the NodePort to expose the app from the Cluster
  kubectl patch service ai-travel-advisor --namespace=ai-travel-advisor --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30100}]'

  waitAppCanHandleRequests 30100

  printInfo "AI Travel Advisor is available via NodePort=30100"

}

deployTodoApp(){
  printInfoSection "Deploying Todo App"

  kubectl create ns todoapp

  # Create deployment of todoApp
  kubectl -n todoapp create deploy todoapp --image=shinojosa/todoapp:1.0.1

  # Expose deployment of todoApp with a Service
  kubectl -n todoapp expose deployment todoapp --type=NodePort --name=todoapp --port=8080 --target-port=8080

  # Define the NodePort to expose the app from the Cluster
  kubectl patch service todoapp --namespace=todoapp --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30100}]'

  waitForAllReadyPods todoapp

  waitAppCanHandleRequests 30100

  printInfoSection "TodoApp is available via NodePort=30100"
}

exposeTodoApp(){
  printInfo "Exposing Todo App in your dev.container"
  nohup kubectl port-forward service/todoapp 8080:8080  -n todoapp --address="0.0.0.0" > /tmp/kubectl-port-forward.log 2>&1 &
}


_exposeAstroshop(){
  printInfo "Exposing Astroshop in your dev.container"
  nohup kubectl port-forward service/astroshop-frontendproxy 8080:8080  -n astroshop --address="0.0.0.0" > /tmp/kubectl-port-forward.log 2>&1 &
}


installMkdocs(){
  printInfoSection "Installing Mkdocs"
  printInfo "Installing Runme v $RUNME_CLI_VERSION"
  installRunme
  printInfo "Installing MKdocs"
  pip install --break-system-packages -r docs/requirements/requirements-mkdocs.txt
  printInfo "Exposing MKdocs 0.0.0.0:8000"
  exposeMkdocs
}


exposeMkdocs(){
  printInfo "Exposing Mkdocs in your dev.container"
  nohup mkdocs serve -a 0.0.0.0:8000 > /dev/null 2>&1 &
}


_exposeLabguide(){
  printInfo "Exposing Lab Guide in your dev.container"
  cd $REPO_PATH/lab-guide/
  nohup node bin/server.js --host 0.0.0.0 --port 3000 > /dev/null 2>&1 &
  cd -
}

_buildLabGuide(){
  printInfoSection "Building the Lab-guide in port 3000"
  cd $REPO_PATH/lab-guide/
  node bin/generator.js
  cd -
}

deployAstroshop(){
  printInfoSection "Deploying Astroshop"

  # To override the Dynatrace values call the function with the following order
  #saveReadCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN $DT_INGEST_TOKEN $DT_OTEL_ENDPOINT

  ###
  # Instructions to install Astroshop with Helm Chart from R&D and images built in shinojos repo (including code modifications from R&D)
  ####
  #sed -i 's~domain.placeholder~'"$DOMAIN"'~' $REPO_PATH/.devcontainer/apps/astroshop/helm/dt-otel-demo-helm/values.yaml
  #sed -i 's~domain.placeholder~'"$DOMAIN"'~' $REPO_PATH/.devcontainer/apps/astroshop/helm/dt-otel-demo-helm-deployments/values.yaml

  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

  helm dependency build $REPO_PATH/.devcontainer/apps/astroshop/helm/dt-otel-demo-helm

  kubectl create namespace astroshop

  DT_OTEL_ENDPOINT=$DT_TENANT/api/v2/otlp

  printInfo "OTEL Configuration URL $DT_OTEL_ENDPOINT and Ingest Token $DT_INGEST_TOKEN"  

  helm upgrade --install astroshop -f $REPO_PATH/.devcontainer/apps/astroshop/helm/dt-otel-demo-helm-deployments/values.yaml --set default.image.repository=docker.io/shinojosa/astroshop --set default.image.tag=1.12.0 --set collector_tenant_endpoint=$DT_OTEL_ENDPOINT --set collector_tenant_token=$DT_INGEST_TOKEN -n astroshop $REPO_PATH/.devcontainer/apps/astroshop/helm/dt-otel-demo-helm

  printInfo "Exposing Astroshop in your dev.container via NodePort 30100"

  printInfo "Change astroshop-frontendproxy service from LoadBalancer to NodePort"
  kubectl patch service astroshop-frontendproxy --namespace=astroshop --patch='{"spec": {"type": "NodePort"}}'

  printInfo "Exposing the astroshop-frontendproxy in NodePort 30100"
  kubectl patch service astroshop-frontendproxy --namespace=astroshop --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30100}]'

  printInfo "Stopping all cronjobs from Demo Live since they are not needed with this scenario"
  kubectl get cronjobs -n astroshop -o json | jq -r '.items[] | .metadata.name' | xargs -I {} kubectl patch cronjob {} -n astroshop --patch '{"spec": {"suspend": true}}'

  # Listing all cronjobs
  kubectl get cronjobs -n astroshop

  waitForAllPods astroshop

  waitAppCanHandleRequests 30100

  printInfo "Astroshop deployed succesfully"
}

deployBugZapperApp(){

  if [[ $# -eq 1 ]]; then
    PORT="$1"
  else
    PORT="30100"
  fi

  printInfoSection "Deploying BugZapper App on Port $PORT"

  kubectl create ns bugzapper

  # Create deployment of todoApp
  kubectl -n bugzapper create deploy bugzapper --image=jhendrick/bugzapper-game:latest

  # Expose deployment of todoApp with a Service
  kubectl -n bugzapper expose deployment bugzapper --type=NodePort --name=bugzapper --port=3000 --target-port=3000

  # Define the NodePort to expose the app from the Cluster
  kubectl patch service bugzapper --namespace=bugzapper --type='json' --patch="[{\"op\": \"replace\", \"path\": \"/spec/ports/0/nodePort\", \"value\":$PORT}]"

  waitForAllReadyPods bugzapper

  waitAppCanHandleRequests $PORT

  printInfoSection "Bugzapper is available via NodePort=$PORT"
}

deleteCodespace(){
  printWarn "Warning! Codespace $CODESPACE_NAME will be deleted, the connection will be lost in a sec... " 
  gh codespace delete --codespace "$CODESPACE_NAME" --force
}


showOpenPorts(){
  sudo netstat -tulnp
  # another alternative is 
  # sudo ss -tulnp
}

deployGhdocs(){
  mkdocs gh-deploy
}

getRunningDockerContainernameByImagePattern(){
  pattern=$1

  containername=$(docker ps --filter "status=running" --format "{{.Names}} {{.Image}}" | grep $pattern | awk '{print $1}')

  echo $containername

}

verifyCodespaceCreation(){
  printInfoSection "Verify Codespace creation"
  calculateTime
  if [[ $INSTANTIATION_TYPE == "github-codespaces" ]]; then
    CODESPACE_ERRORS=$(cat $CODESPACE_PSHARE_FOLDER/creation.log | grep -i -E 'error|failed')
  elif [[ $INSTANTIATION_TYPE == "remote-container" ]] || [[ $INSTANTIATION_TYPE == "github-workflow" ]]; then
    #FIXME: Verify instantiation of Github Actions & VS Code Remote containers
    containername=$(getRunningDockerContainernameByImagePattern "vsc")
    
    CODESPACE_ERRORS=$(docker logs $containername | grep -i -E 'error|failed')
    # Print logs of VSCode and cat grep them.
    printWarn "Container was created in a remote container, either VS Code or Github Actions. Verification of proper creation TBD"
  elif [[ $INSTANTIATION_TYPE == "local-docker-container" ]]; then
    containername=$(getRunningDockerContainernameByImagePattern "dt-enablement")
    CODESPACE_ERRORS=$(docker logs $containername | grep -i -E 'error|failed')
    # above method works only calling it the first time. Otherwise the erros will be multiplied. We could clean them like below:
    #awk '/Verify Codespace creation/ {exit} {print}' /tmp/dt-enablement.log > /tmp/dt-enablement-create.log
  else 
    printWarn "Container creation unknown."
  fi

  if [ -n "$CODESPACE_ERRORS" ]; then
      ERROR_COUNT=$(printf "%s" "$CODESPACE_ERRORS" | wc -l) 
  else
      ERROR_COUNT=0
  fi
  printInfo "$ERROR_COUNT issues detected in the creation of the codespace: $CODESPACE_ERRORS" 

  export CODESPACE_ERRORS
  updateEnvVariable ERROR_COUNT
 
}

calculateTime(){
  # Read from file
  if [ -e "$ENV_FILE" ]; then
    source $ENV_FILE
  fi
  # if equal 0 then set duration and update file
  if [ "$DURATION" -eq 0 ]; then 
    DURATION="$SECONDS"
    updateEnvVariable DURATION
  fi
  printInfo "It took $(($DURATION / 60)) minutes and $(($DURATION % 60)) seconds the post-creation of the codespace."
}

updateEnvVariable(){
  local variable="$1"
  # Checking the process name (zsh/bash)
  if [[ "$(ps -p $$ -o comm=)" == "zsh" ]]; then
    #printInfo "ZSH"
    #printInfo "update [$variable:${(P)variable}]"
    # indirect variable expansion in ZSH
    sed "s|^$variable=.*|$variable=${(P)variable}|" $ENV_FILE > $ENV_FILE.tmp
    mv $ENV_FILE.tmp $ENV_FILE
  else
    #printInfo "BASH"
    #printInfo "update [$variable:${!variable}]"
    # indirect variable expansion in BASH
    sed "s|^$variable=.*|$variable=${!variable}|" $ENV_FILE  > $ENV_FILE.tmp
    mv $ENV_FILE.tmp $ENV_FILE
  fi
  
  export $variable
}

finalizePostCreation(){
  # e2e testing
  # If the codespace is created (eg. via a Dynatrace workflow)
  # and hardcoded to have a name starting with dttest-bash b
  # Then run the e2e test harness
  # Otherwise, send the startup ping
  if [[ "$CODESPACE_NAME" == dttest-* ]]; then
      # Set default repository for gh CLI
      gh repo set-default "$GITHUB_REPOSITORY"

      # Set up a label, used if / when the e2e test fails
      # This may already be set, so catch error and always return true
      gh label create "e2e test failed" --force || true

      # Install required Python packages
      pip install -r "$REPO_PATH/.devcontainer/testing/requirements.txt" --break-system-packages

      # Run the test harness script
      python "$REPO_PATH/.devcontainer/testing/testharness.py"

      # Testing finished. Destroy the codespace
      gh codespace delete --codespace "$CODESPACE_NAME" --force
  else
      
      verifyCodespaceCreation
      postCodespaceTracker
  fi
}


runIntegrationTests(){
  #this function will trigger the integration Tests for this repo.
  bash "$REPO_PATH/.devcontainer/test/integration.sh"
}

# Custom functions for each repo can be added in my_functions.sh
source $REPO_PATH/.devcontainer/util/my_functions.sh
