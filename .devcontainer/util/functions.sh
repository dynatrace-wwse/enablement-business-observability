#!/bin/bash
# This file contains the functions for installing Kubernetes-Play.
# Each function contains a boolean flag so the installations
# can be highly customized.
# Original file located https://github.com/dynatrace-wwse/kubernetes-playground/blob/main/cluster-setup/functions.sh


# FUNCTIONS DECLARATIONS
timestamp() {
  date +"[%Y-%m-%d %H:%M:%S]"
}

printInfo() {
  echo -e '\e[38;5;198m'"[dev.container|INFO] $(timestamp) |>->-> $1 <-<-<|"
}

printInfoSection() {
  echo -e '\e[38;5;198m'"[dev.container|INFO] $(timestamp) |$thickline"
  echo -e '\e[38;5;198m'"[dev.container|INFO] $(timestamp) |$halfline $1 $halfline"
  echo -e '\e[38;5;198m'"[dev.container|INFO] $(timestamp) |$thinline"
}

printWarn() {
  echo  -e '\e[38;5;226m'"[dev.container|WARN] $(timestamp) |x-x-> $1 <-x-x|"
}

printError() {
  echo -e '\e[38;5;196m'"[dev.container|ERROR] $(timestamp) |x-x-> $1 <-x-x|"
}


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

installHelm(){
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

installHelmDashboard(){
  
  printInfoSection "Installing Helm Dashboard" 
  helm plugin install https://github.com/komodorio/helm-dashboard.git

   
  printInfoSection "Running Helm Dashboard" 
  helm dashboard --bind=0.0.0.0 --port 8002 --no-browser --no-analytics > /dev/null 2>&1 &

}

installKubernetesDashboard(){
    # https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/   
  printInfoSection " Installing Kubernetes dashboard"
   
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
  

  # In the functions you can specify the amount of retries and the NS
  waitForAllPods
  printInfoSection " kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8001:443 --address=\"0.0.0.0\", (${attempts}/${max_attempts}) sleep 10s"
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8001:443 --address="0.0.0.0" > /dev/null 2>&1 &
  # https://github.com/komodorio/helm-dashboard

  # Do we need this?
  printInfoSection "Create ServiceAccount and ClusterRoleBinding" 
  kubectl apply -f /app/.devcontainer/etc/k3s/dashboard-adminuser.yaml
  kubectl apply -f /app/.devcontainer/etc/k3s/dashboard-rolebind.yaml

   
  printInfoSection "Get admin-user token" 
  kubectl -n kube-system create token admin-user --duration=8760h
}
   
installK9s(){
  printInfoSection "Installing k9s CLI" 
  curl -sS https://webinstall.dev/k9s | bash
}
