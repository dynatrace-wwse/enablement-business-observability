#!/bin/bash +x
 # Read the domain from CM
#source ../util/loaddomain.sh

# Load the functions
# Read the variables
#source ../../cluster-setup/functions.sh
#source ../../cluster-setup/resources/dynatrace/credentials.sh

printInfoSection "Deploying Astroshop"

# read the credentials and variables
saveReadCredentials 

# To override the Dynatrace values call the function with the following order
#saveReadCredentials $DT_TENANT $DT_API_TOKEN $DT_INGEST_TOKEN $DT_OTEL_API_TOKEN $DT_OTEL_ENDPOINT

: <<'EOF'

# Dynatrace needs to be installed,
# achieved with this flag dynatrace_deploy_cloudnative=true
# DT_OTEL_API_TOKEN and DT_OTEL_ENDPOINT are exported

## Certmanager needs to be installed 
# enable the FF to install certmanager and call the functions
#certmanager_install=true; certmanager_enable=true
#certmanagerInstall && certmanagerEnable
EOF

###
# Instructions to install Astroshop with Helm Chart from R&D and images built in shinojos repo (including code modifications from R&D)
####
sed -i 's~domain.placeholder~'"$DOMAIN"'~' helm/dt-otel-demo-helm/values.yaml
sed -i 's~domain.placeholder~'"$DOMAIN"'~' helm/dt-otel-demo-helm-deployments/values.yaml

helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

helm dependency build ./helm/dt-otel-demo-helm

kubectl create namespace astroshop

echo "OTEL Configuration URL $DT_OTEL_ENDPOINT and Token $DT_OTEL_API_TOKEN"  

helm upgrade --install astroshop -f ./helm/dt-otel-demo-helm-deployments/values.yaml --set default.image.repository=docker.io/shinojosa/astroshop --set default.image.tag=1.12.0 --set collector_tenant_endpoint=$DT_OTEL_ENDPOINT --set collector_tenant_token=$DT_OTEL_API_TOKEN -n astroshop ./helm/dt-otel-demo-helm

printInfo "Stopping all cronjobs from Demo Live since they are not needed with this scenario"

kubectl get cronjobs -n astroshop -o json | jq -r '.items[] | .metadata.name' | xargs -I {} kubectl patch cronjob {} -n astroshop --patch '{"spec": {"suspend": true}}'

kubectl get cronjobs -n astroshop

printInfo "Astroshop available at: "

kubectl get ing -n astroshop