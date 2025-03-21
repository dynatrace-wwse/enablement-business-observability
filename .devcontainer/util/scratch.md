# Scratch commands


curl -O https://raw.githubusercontent.com/dynatrace-wwse/kubernetes-playground/master/cluster-setup/k8splay-install.sh

chmod +x k8splay-install.sh

sudo bash -c './k8splay-install.sh &'

kubectl -n todoapp port-forward svc/todoapp 8888:8080 --address="0.0.0.0"

port-on-localhost:svc-port


# Install DT
helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator --create-namespace --namespace dynatrace --atomic


# Configutration on the k8s-play file

# Setting the environment variables
TENANT=https://iid1110h.sprint.dynatracelabs.com
APITOKEN=dt0c01.yy.xx
INGESTTOKEN=dt0c01.yy.xx

DT_OTEL_API_TOKEN=dt0c01.xx.yy
DT_OTEL_ENDPOINT=https://iid1110h.sprint.dynatracelabs.com/api/v2/otlp


# ==================================================
#  ----- CUSTOM INSTALLATION -----      #
# ==================================================


#k9s_install=true
resources_clone=true
setup_aliases=true
certmanager_install=true
certmanager_enable=true
dynatrace_deploy_cloudnative=true

#doInstallation
# call specific functions
setupAliases
resourcesCloneq
certmanagerInstall
certmanagerEnable
dynatraceEvalReadSaveCredentials
dynatraceDeployOperator

bashas "cd $K8S_PLAY_DIR/apps/astroshop && bash deploy-astroshop.sh"
