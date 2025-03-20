## OpenPipeline: Logs Pipeline

Use OpenPipeline to transform log data on ingest prior to being stored in Grail.

### Query Existing Log Data

Use the `Logs` App to explore the existing log data for the IDP and the deployed applications.  Note that Dynatrace is deployed with `Application Monitoring` Dynakube and Kubernetes Observability.  Logs are collected using an OpenTelemetry Collector that ships the logs to Dynatrace.

![Logs App](../../../assets/images/04_01_logs_app_viewer.png)

From the Logs App, try to locate logs that are relevant to a specific application team (i.e. team01 or team02).

Import the [IDP OpenPipeline Notebook](https://github.com/dynatrace-wwse/enablement-openpipeline-segments-iam/blob/main/lab-guide/assets/dynatrace/IDP_%20OpenPipeline_Notebook.json) Notebook into the Dynatrace environment.

![Existing Logs](../../../assets/images/04_01_notebook_query_existing_logs.png)

Execute the first DQL query, which retrieves the logs from the `SimpleNodeService` pods.  Take notice of the `dt.security_context`, `idp_project`, `idp_team`, and `idp_stage` attributes.  We want to use OpenPipeline to modify/add these fields to the log records.

DQL:
```sql
fetch logs
| filter k8s.container.name == "frauddetectionservice"
| filter matchesPhrase(content, "Consumed record with orderId:")
| fields timestamp, content, k8s.container.name
| sort timestamp desc
```
