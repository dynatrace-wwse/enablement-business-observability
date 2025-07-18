--8<-- "snippets/send-bizevent/bizevent-05-bizevents-logs.js"

# Business Events Capture - Logs

Organizations in today’s data-driven world often struggle with fragmented data sources that hinder comprehensive business insights. With Dynatrace OpenPipeline, you can ingest logs from any system and extract relevant business data to get a cohesive end-to-end view of your business processes.

This approach is useful if logs contain business-relevant information or no other ingest path for business events is available.

[Log to Business events documentation](https://docs.dynatrace.com/docs/shortlink/ba-business-events-capturing#logs)

This lab will utilize logs lines ingested by the OneAgent.  The log lines will be converted to business events for the `Fraud Check` step for the Astroshop `Order to Shipped` business process.

* Use `OpenPipeline` to convert incoming logs to business events
* Validate Business Event data with a Notebook

![FlowStepTwo](./img/03_bizevents_log_flow.png)

## Fraud Check

In this section of the lab we will use OpenPipeline to convert incoming logs to business events for the `Fraud Detection` step of the `Order to Shipped` business process. 

### Logs - Fraud Check

Using a Notebook execute the below DQL query which retrieves the log lines that will be converted into business events for the `Fraud Check` step of the `Order to Shipped` business process.

DQL:
```sql
fetch logs
| filter k8s.container.name == "frauddetectionservice"
| filter matchesPhrase(content, "Consumed record with orderId:")
| filter matchesPhrase(content, "orderId")
| fields timestamp, content
| sort timestamp desc
```

Result:

![DQL Query 1](./img/03_bizevents_logs_fraudcheck_dql_1.png)

## Logs - Fraud Check orderID Extraction

Using a Notebook execute the below DQL query which retrieves the log lines that will be converted into business events for the `Fraud Check` step of the `Order to Shipped` business process.  We will parse the logs lines to extract the orderId. 

DQL:
```sql
fetch logs
| filter k8s.container.name == "frauddetectionservice"
| filter matchesPhrase(content, "Consumed record with orderId:")
| parse content, """DATA 'Consumed record with orderId: ' ld:orderId ','"""
| fields timestamp, orderId, content
| sort timestamp desc
```
Result:

![DQL Query 2](./img/03_bizevents_logs_fraudcheck_dql_2.png)

## Business Event - OpenPipeline - Fraud Check

Launch the OpenPipeline app.

Select Logs in the tree. 

Select the Pipelines tab.

Select the + Pipeline button.

![Launch OpenPipeline](./img/03_bizevents_logs_fraudcheck_openpipline_launch.png)

## Business Event - OpenPipeline Processing - Fraud Check

Name your OpenPipeline rule using the following name: 

```text
Astroshop_Fraud_Check
```

Select the `Processing` tab

Select the `+ Processor` button (left side of the screen), then select DQL

![Pipeline Processing Rule Part 1](./img/03_bizevents_logs_fraudcheck_openpipline_rule_1.png)

Fill out the fields with the following data:

Name: 

```text
FraudCheckBizEventFromLog
```

Matching condition: 

```text
k8s.container.name == "frauddetectionservice" AND matchesPhrase(content, "Consumed record with orderId:")
```

DQL processor definition: 

```text
parse content, """DATA 'Consumed record with orderId: ' ld:orderId ','"""
| fieldsAdd add1second = toTimestamp(toLong(timestamp) + 1000000000)
| fieldsAdd timestamp = add1second
```

In the sample data section use the following:

```json
{
      "timestamp": "2025-03-19T13:41:16.000000000-04:00",
      "content": "2025-03-19 17:41:16 - frauddetectionservice - Consumed record with orderId: 5ba0f19d-04e9-11f0-895b-0e326b3139ca, and updated total count to: 1126 trace_id=6cd0e9c60fd10799c66eb344f916d7e6 span_id=3173a5d07a507a1d trace_flags=01 ",
      "k8s.container.name": "frauddetectionservice"
}
```
Select the `Run sample data` button and Preview the results.  

Validate the orderId field exists in the results.

![Pipeline Processing Rule Part 2](./img/03_bizevents_logs_fraudcheck_openpipline_rule_2.png)

## Business Event - OpenPipeline Data extraction - Fraud Check

Select the `Data extraction` tab.

Select the `+ Processor` button (left side of the screen), then select Business event.

![Pipeline Data Extraction Rule Part 1](./img/03_bizevents_logs_fraudcheck_openpipline_rule_3.png)

Fill out the fields with the following data:

Name:

```text
orderId
```

Matching condition:

```text
k8s.container.name == "frauddetectionservice" AND matchesPhrase(content, "Consumed record with orderId:") and isNotNull(orderId)
```

Event type:

Select the Static string radio button and use the following:

```text
astroshop.fraudcheck.success
```

Event provider:

Select the Static string radio button and use the following:

```text
astroshop
```

Field extraction: 

Select the Fields to extract radio button.  We will add 3 fields to extract (keep).  The fields need to be added independently.

Click the Add button for:

```text
timestamp
```

Click the Add button for:

```text
orderId
```
Click the Add button for:

```text
trace_id
```

Select the Save Button at the top right of the screen.

![Pipeline Data Extraction Rule Part 2](./img/03_bizevents_logs_fraudcheck_openpipline_rule_4.png)

## Business Event - OpenPipeline Dynamic Route - Fraud Check

Now we need to create a Dynamic route for the `Astroshop_Fraud_Check` pipeline. 

Dynamic routes give you the option to route your ingested data into a pipeline with a matching condition.

In the OpenPipeline App, select Logs in the tree.

Select the Dynamic routing tab.

Select `+ Dynamic route` button.

![Pipeline Dynamic Route Part 1](./img/03_bizevents_logs_fraudcheck_openpipline_rule_5.png)

Configure the Dynamic route with the following:

Name:

```text
Astroshop_Fraud_Check
```

Matching condition:

```text
k8s.container.name == "frauddetectionservice" AND matchesPhrase(content, "Consumed record with orderId:")
```

Pipeline:

In the dropdown list select the following

```text
Astroshop_Fraud_Check
```

Select Add button.

![Pipeline Dynamic Route Part 1](./img/03_bizevents_logs_fraudcheck_openpipline_rule_6.png)

Select Save button.

A warning icon with this message will appear "Do you want to save your changes to this table?" 

Select the Save button.

![Pipeline Dynamic Route Part 2](./img/03_bizevents_logs_fraudcheck_openpipline_rule_7.png)

### Conclusion

We have completed the Business Event capture using log lines and OpenPipeline for `Fraud Check` step of the `Order to Shipped` business process.  The next section will validate the data.

## Data Validation

In this section of the lab we will validate the data for the `Fraud Check` step of the `Order to Shipped` business process.

### Query Business Events in Dynatrace

Using a Notebook execute the below DQL query which retrieves the business events for `astroshop.fraudcheck.success` step.  Note, this may take 3-5 minutes for new data to appear.

DQL:
```sql
fetch bizevents
| filter event.provider == "astroshop" and event.type == "astroshop.fraudcheck.success"
| fields timestamp, event.provider, event.type, orderId, trace_id
| sort timestamp desc
```

Result:

![DQL Query](./img/03_bizevents_logs_fraudcheck_data_validation_dql.png)

### Conclusion

We have completed data validation for the for the `Fraud Check` step of the `Order to Shipped` business process.

## Continue

In the next section, we'll capture Business Events with the Dynatrace API.

<div class="grid cards" markdown>
- [Continue to Business Event Capture with API:octicons-arrow-right-24:](06_bizevents_api.md)
</div>