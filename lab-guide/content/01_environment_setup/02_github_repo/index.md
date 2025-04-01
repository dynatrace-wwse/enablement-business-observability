## GitHub Repository Setup

You will need a GitHub account.

The source repository for this lab is: 

[enablement-business-observability](https://github.com/dynatrace-wwse/enablement-business-observability)

Open the link above in your browser.

## Codespaces Cluster Set Up

Click on `Code`.  Click on `Codespaces`.  Click on `New with options`.

![github cluster repo](../../../assets/images/prereq-github_cluster_repo.png)

Choose the Branch `main`.  

Choose the Dev Container Configuration `Enablement Business Observability`.

Choose a region close to your Dynatrace tenant. If you run into issues with spinning up your codespaces instance, try selecting a different region.

Choose Machine Type `4-core`.

![github new codespaces](../../../assets/images/prereq-github_cluster_new_codespaces.png)

Fill in recommend secrets sections for the following that you have in your saved notepad:

```txt
* DT_TENANT

* DT_OPERATOR_TOKEN

* DT_INGEST_TOKEN
```
When done select the Create codespace button.

![github new codespaces secrets](../../../assets/images/prereq-github_cluster_new_secrets.png)

If you have already defined the environment variables in your repository, you'll see a screen asking you to associate those secrets with this repository. 

You can either update or delete those existing secrets.  If you delete the secretes, you will need to start over.

If you want to update those secretes, click the Codespaces Settings link in the Recommended secrets section of this page.  This open up a new window for Codespace user secrets section for your account.  For each of the secrets below, edit with the pencil icon,  update with the values for collected for this lab and save changes.   

```txt
* DT_TENANT

* DT_OPERATOR_TOKEN

* DT_INGEST_TOKEN
```
Then code back to you codespace setup page you have open and boxes as shown below.

When done select the Create codespace button.

![github new codespaces secrets](../../../assets/images/prereq-github_cluster_new_secrets_2.png)

## Codespaces Codespace Instance

Your browser tab will change to the Codespace initialize screen.

Allow the Codespace instance to fully initialize.  It is not ready yet.

It will take about 10 minutes to fully finish.

During the initialize phase you will see:

![github codespace launch 1](../../../assets/images/prereq-github_codespace_launch_1.png)

The Codespace instance will run the post initialization scripts.

![github codespace launch 2](../../../assets/images/prereq-github_codespace_launch_2.png)

Again, it will take about 10 minutes to fully finish...give it time!

When fully finished you see below.

![github codespace ready](../../../assets/images/prereq-github_codespace_ready.png)

## Astroshop Validation

In the Codespace window,  you will see a section called: 

```txt
This devcontainer is exposing the following processes
```
In the  `Astroshop UI` section,  cmd + click the url or copy and paste the url in a new browser tab.  This will launch `Astroshop UI`.

![Astroshop UI 1](../../../assets/images/prereq-github_codespace_ready_astroshop_1.png)

If you caught in time you could also select the Open in Browser pop up at the very bottom right of the screen to Launch Astroshop.   Either approach works!

![Astroshop UI 1](../../../assets/images/prereq-github_codespace_ready_astroshop_1_b.png)

Take a minute to navigate around.

![Astroshop UI 2](../../../assets/images/prereq-github_codespace_ready_astroshop_2.png)

## Dynatrace Data Validation - Distributed Traces

Open the `Distributed Tracing` app.

In the filter section copy and paste this below:

```txt
Service = frontend AND Endpoint = "/api/checkout"
```

Select the `Update` button.

![Dynatrace Distributed Tracing 1](../../../assets/images/prereq-github_codespace_ready_dynatrace_distributed_tracing_1.png)

Validate you see traces for "/api/checkout".

![Dynatrace Distributed Tracing 2](../../../assets/images/prereq-github_codespace_ready_dynatrace_distributed_tracing_2.png)

Select a single trace to see the single trace details.

![Dynatrace Distributed Tracing 3](../../../assets/images/prereq-github_codespace_ready_dynatrace_distributed_tracing_3.png)

## Dynatrace Data Validation - Logs

Open the `Logs` app.

In the filter section copy and paste this below:

```txt
content = "*frauddetectionservice - Consumed record with orderId*" AND Endpoint = "/api/checkout"
```

Select the `Run query` button.

![Dynatrace Logs 1](../../../assets/images/prereq-github_codespace_ready_dynatrace_logs_1.png)

Validate you see log lines for "frauddetectionservice - Consumed record with orderId:".

![Dynatrace Logs 2](../../../assets/images/prereq-github_codespace_ready_dynatrace_logs_2.png)

### Conclusion

We have completed the step of Codespaces setup,  verified Astroshop is running,  verified the Distributed traces and Log lines needed are being consumed.  We are ready to move to the Hands on Labs!!