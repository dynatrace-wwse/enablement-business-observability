## Business Events Capture - API

Organizations in today’s data-driven world often struggle with fragmented data sources that hinder comprehensive business insights.  Using the Dynatrace Business Event API, external business or IT systems can be used as another data source to send for business events Dynatrace.

This approach is useful when business-relevant information needs to be used and no other ingest path for business events is available.

The Dyntrace Business Event API supports JSON, CloudEvents and CloudEvents batch payload formats.  

Supported Authentication Types: 

* Access token
* OAuth 

This lab will utilize sending event data to the Business Events API for the `Order Shipped` step of the Astroshop `Order to Shipped` business process.

* Use a workflow to send `Order Shipped` business events to the Business Events API 
* Validate the data using a Notebook

![FlowStepThree](../../assets/images/04_bizevents_api_flow.png)