## GitHub Repository Setup

You will need a GitHub account.  

Make sure you are logged in.

### Configure Codespaces Settings - Secrets

If you previously participated in a Dynatrace training using Codespaces, you may have existing secrets that will conflict with our training today.

Open the `GitHub Codespaces settings` link: [https://github.com/settings/codespaces](https://github.com/settings/codespaces) in a new tab in your browser.

Under the Secrets section,  Codespace user secrets,  check if these secrets exist.

```txt
DT_INGEST_TOKEN

DT_OPERATOR_TOKEN

DT_TENANT
```

If found, select the delete icon for each secret that exists.

![Codespaces Secrets Delete 1](../../../assets/images/00_01_readme_lab_guide_codespaces_secrets_1.png)

You will get a `Delete secret` prompt, select the `Yes, delete this secret` button.

![Codespaces Secrets Delete 2](../../../assets/images/00_01_readme_lab_guide_codespaces_secrets_2.png)

You may get a `Confirm access` prompt, enter your Github password and then select the `Confirm` button.

![Codespaces Secrets Delete 3](../../../assets/images/00_01_readme_lab_guide_codespaces_secrets_3.png)

Leave the `GitHub Codespaces settings` browser tab open. 

In next section of this lab we will be changing another setting.

### Configure Codespaces Settings - Default idle timeout

By default, codespaces instances will suspend after 30 minutes of inactivity.  This may cause problems with your lab.  

Scroll down GitHub Codespaces settings section and find the section called `Default idle timeout`.

Increase the `Default idle timeout` setting in the minutes section to use the following:

```txt
240
```
Select the `Save` button.

![Codespaces Settings Default idle timeout](../../../assets/images/00_01_readme_lab_guide_codespaces_default_idle_timeout.png)

When complete you can close the `GitHub Codespaces settings` browser tab.

### Codespaces Cluster Set Up

The source repository for this lab is: 

[enablement-business-observability](https://github.com/dynatrace-wwse/enablement-business-observability)

Open the link above in a new tab in your browser.

Click on `Code`.  Click on `Codespaces`.  Click on `New with options`.

![github cluster repo](../../../assets/images/prereq-github_cluster_repo.png)

Choose the Branch `main`.  

Choose the Dev Container Configuration `Enablement Business Observability`.

Choose a region close to your Dynatrace tenant. If you run into issues with spinning up your codespaces instance, try selecting a different region.

Choose Machine Type `4-core`.

![github new codespaces](../../../assets/images/prereq-github_cluster_new_codespaces.png)

Fill in recommend secrets sections for the following that you have in your saved notepad:

```txt
DT_TENANT

DT_OPERATOR_TOKEN

DT_INGEST_TOKEN
```
When done select the Create codespace button.

![github new codespaces secrets](../../../assets/images/prereq-github_cluster_new_secrets.png)

⚠️ If any of the secrets sections have a checkbox Associated with repository?, leave this browser tab open. 
Go back to Configure Codespaces Settings - Secrets section above in this lab and complete that section.
Refresh this browser tab and you should now be able to fill in the secrets. ⚠️

### Codespaces Codespace Instance

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

### Astroshop Validation

In the Codespace window,  you will see a section called: 

```txt
This devcontainer is exposing the following processes
```
In the  `Astroshop UI` section,  cmd + click the url or copy and paste the url in a new browser tab.  This will launch `Astroshop UI`.

![Astroshop UI 1](../../../assets/images/prereq-github_codespace_ready_astroshop_1.png)

If you caught in time you could also select the Open in Browser pop up at the very bottom right of the screen to Launch Astroshop.   Either approach works!

![Astroshop UI 1](../../../assets/images/prereq-github_codespace_ready_astroshop_1_b.png)

If for some reason Astroshop is not connecting when opening in new tab run the below command in the terminal.

```txt
exposeAstroshop
```
Then in the  `Astroshop UI` section,  cmd + click the url or copy and paste the url in a new browser tab.  This will launch `Astroshop UI`.

Take a minute to navigate around.

![Astroshop UI 2](../../../assets/images/prereq-github_codespace_ready_astroshop_2.png)

### Dynatrace Data Validation - Distributed Traces

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

### Dynatrace Data Validation - Logs

Open the `Logs` app.

In the filter section copy and paste this below:

```txt
content = "*frauddetectionservice - Consumed record with orderId*"
```

Select the `Run query` button.

![Dynatrace Logs 1](../../../assets/images/prereq-github_codespace_ready_dynatrace_logs_1.png)

Validate you see log lines for "frauddetectionservice - Consumed record with orderId:".

![Dynatrace Logs 2](../../../assets/images/prereq-github_codespace_ready_dynatrace_logs_2.png)

### Troubleshooting

If you don't see data for Distributed Traces and Logs data validation steps above do the following.

Environment Variables Validation:

In the Codespaces terminal run the following commands:

```txt

echo $DT_TENANT

echo $DT_OPERATOR_TOKEN

echo $DT_INGEST_TOKEN
```

Validate the variables output to what you configured in the `Configure Codespaces Settings - Secrets` section above in this training.   

Make sure to check for:

```txt
⚠️ No apps in the URL! ⚠️

⚠️ Make sure there is no trailing / at the end of the DT_TENANT ⚠️

⚠️ Make sure the $DT_OPERATOR_TOKEN & $DT_INGEST_TOKEN are not the same ⚠️
```

![Lab Guide Troubleshooting Variables](../../../assets/images/prereq-github_codespace_troubleshooting_variables.png)

If there are mistakes,  navigate to the GitHub Codespaces page at [https://github.com/codespaces/](https://github.com/codespaces/)

Locate your instance, click the `...` button, and click `Delete`.

![Codespaces Cleanup](../../../assets/images/09_02_codespaces_cleanup.png)

Then go back and collect the correct information needed for:

```txt
DT_INGEST_TOKEN

DT_OPERATOR_TOKEN

DT_TENANT
```

Then resume the lab starting at the `Codespaces Cluster Set Up` section above in this training.

If the variables are correct, we need to confirm Astroshop and Dynatrace are running correctly.

Astroshop Validation:

In the Codespaces terminal run the following commands:

```txt
kubectl get pods -n astroshop
```

![Lab Guide Troubleshooting Astroshop Running](../../../assets/images/prereq-github_codespace_troubleshooting_astroshop_running.png)

Dynatrace Validation:

In the Codespaces terminal run the following commands:

```txt
kubectl get pods -n dynatrace
```
![Lab Guide Troubleshooting Dynatrace Running](../../../assets/images/prereq-github_codespace_troubleshooting_dynatrace_running.png)

If any of the Astroshop or Dynatrace Pods are not in a STATUS of running it would be best to Delete this Codespace instance.

Navigate to the GitHub Codespaces page at [https://github.com/codespaces/](https://github.com/codespaces/)

Locate your instance, click the `...` button, and click `Delete`.

![Codespaces Cleanup](../../../assets/images/09_02_codespaces_cleanup.png)

Then resume the lab starting at the `Codespaces Cluster Set Up` section above in this training.

### Codespace Disconnected

When your Codespace for this training is up and running and you accidently close the Codespace browser tab, or network reconnection errors occur, don't worry, we can relaunch it.    

Navigate to the GitHub Codespaces page at [https://github.com/codespaces/](https://github.com/codespaces/)

At the bottom of the page under the `Owned by` section, you should see your Codespace instance in an `Active` state.

Select the `...` to the right of Active.

This will open a menu of items.  

Select `Open in Browser`.   

![Codespaces Disconnect 1](../../../assets/images/prereq-github_codespace_disconnect_1.png)

This launch your running Codespace instance in a new browser tab.

### Conclusion

We have completed the step of Codespaces setup,  verified Astroshop is running,  verified the Distributed traces and Log lines needed are being consumed.  We are ready to move to the Hands on Labs!!