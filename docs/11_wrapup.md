--8<-- "snippets/send-bizevent/file.js"

* Key Takeaways
* Codespaces Cleanup

## Key Takeaways

1. Dynatrace Business Analytics is powered by business events, a special class of events in Dynatrace.
1. Business events deliver real-time business data from anywhere, empowering business and IT teams
with the reporting, analytics, optimization, and automation capabilities required to improve business
outcomes.
1. Dynatrace automatically enriches business events with Smartscape topology metadata,
providing the IT context needed to analyze anomalies and optimize business processes.
1. Business events capture business data from anywhere, including OneAgent, log files, real user
monitoring (RUM) sessions, and external tools and data sources.
1. Dynatrace OneAgent uniquely captures business events from in-flight application payloads –
without requiring any code changes. OneAgent prioritizes business events over infrastructure
and application monitoring to ensure the lossless precision many business use cases demand.
1. Teams can leverage business events across the Dynatrace platform -- including visualizing real-
time data with interactive Dashboards, drilling down and analyzing data in Notebooks,
optimizing business processes with purpose-built apps like Business Flow, and automating tasks
with Workflows -- to access precise, real-time business data all in context of IT to unlock and
enhance critical business use cases.

## Codespaces Cleanup

Delete your codespaces instance when you are finished.

Navigate to the GitHub Codespaces page at [https://github.com/codespaces/](https://github.com/codespaces/)

![Codespaces Cleanup](././img/09_02_codespaces_cleanup.png)

Locate your instance, click the `...` button, and click `Delete`.



### Subtopic

The demo application in this lab, AstroShop, contains OpenTelemetry instrumentation that can be picked up by OneAgent.

![OpenTelemetry OneAgent Features](./img/getting-started_dynatrace_oneagent_features_opentelemetry.png)

## Continue

In the next section, we'll launch our Codespaces instance.

<div class="grid cards" markdown>
- [Continue to Codespaces:octicons-arrow-right-24:](3-codespaces.md)
</div>