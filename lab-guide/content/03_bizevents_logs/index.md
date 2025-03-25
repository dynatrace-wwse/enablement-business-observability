## Business Events Capture - Logs

Organizations in today’s data-driven world often struggle with fragmented data sources that hinder comprehensive business insights. With Dynatrace OpenPipeline, you can ingest logs from any system and extract relevant business data to get a cohesive end-to-end view of your business processes.

This approach is useful if logs contain business-relevant information or no other ingest path for business events is available.

This lab will utilize logs lines ingested by the OneAgent.  The log lines will be converted to business events for the `Fraud Check` step for the Astroshop `Order to Shipped` business process.

* Use `OpenPipeline` to convert incoming logs to business events
* Validate the data using a Notebook

![FlowStepTwo](../../assets/images/03_bizevents_log_flow.png)