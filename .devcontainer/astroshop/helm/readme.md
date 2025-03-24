

# modificar el hostname de values (parametrizar xcon el dominio) y en el frontendproxy
ingressHostUrl -> dt-otel-demo-helm values.yaml

ingressHostUrl -> dt-otel-demo-helm-deployments values.yaml

#  build dependencies?
helm dependency build ./dt-otel-demo-helm/


helm upgrade --install astroshop -f ./dt-otel-demo-helm-deployments/values.yaml --set collector_tenant_endpoint=$DT_ENDPOINT --set collector_tenant_token=$DT_API_TOKEN -n astroshop ./dt-otel-demo-helm --create-namespace --set default.image.repository=docker.io/shinojosa/astroshop --set default.image.tag=1.12.1


