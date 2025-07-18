--8<-- "snippets/send-bizevent/bizevent-index.js"
# Enablement Business Observability

--8<-- "snippets/disclaimer.md"
--8<-- "snippets/view-code.md"

## Lab Overview

During this hands-on training, we'll explore Business Observability powered by BizEvents. During this session we configure business events using OneAgent, Logs and API data sources in context of a single process flow. Additionally, we will use OpenPipeline to generate and enrich telemetry signals. Using the data generated, we'll run powerful analytics with Business Flows, Notebooks, and Dashboards.

The Astroshop `Order to Shipped` Business Process will be the target use case:

```txt
Steps:

Step 1: Place Order
Step 2: Fraud Check
Step 3: Order Shipped

Correlation Id:

orderId
```
![FlowRaw](./img/astroshop_flow_raw.png)

The training will start with:

1. Dynatrace Tenant Setup
1. Environment Setup using Github Codespaces

Then we will move to the hands on lab tasks:

1. Business Event Capture via the Dynatrace OneAgent - Place Order
1. Business Event Capture via Dynatrace ingested logs - Fraud Check
1. Business Event Capture via the events sent to the Dynatrace Business Events API - Order Shipped
1. Create a Metric from Business Events - Place Order
1. Create an Alert from Business Events - Place Order
1. Create a Business Flow and an Alert - Order to Shipped business process
1. Import and review sample Dashboards 

## Continue

In the next section, we'll review the prerequisites for this lab needed before launching our Codespaces instance.

<div class="grid cards" markdown>
- [Continue to getting started:octicons-arrow-right-24:](getting-started.md)
</div>