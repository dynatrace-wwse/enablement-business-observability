## GitHub Repository Setup

You will need a GitHub account.

The source repository for this lab is: 

[enablement-business-observability](https://github.com/dynatrace-wwse/enablement-business-observability)

Open the link above in your browser.

## Codespaces Cluster Set Up

Click on `Code`.  Click on `Codespaces`.  Click on `New with options`.

![github cluster repo](../../../assets/images/prereq-github_cluster_repo.png)

Choose the Branch `main`.  Choose the Dev Container Configuration `Enablement Business Observability`.

Choose a region close to your Dynatrace tenant. If you run into issues with spinning up your codespaces instance, try selecting a different region.

Choose Machine Type `4-core`.

![github new codespaces](../../../assets/images/prereq-github_cluster_new_codespaces.png)

Fill in recommend secrets sections for the following that you have in your saved notepad

* DT_TENANT
* DT_OPERATOR_TOKEN
* DT_INGEST_TOKEN

When done select the Create codespace button

![github new codespaces secrets](../../../assets/images/prereq-github_cluster_new_secrets.png)

If you have already defined the environment variables in your repository, you'll see a screen asking you to associate those secrets with this repository. 

You can either update or delete those existing secrets.  If you delete the secretes, you will need to start over.

If you want to update those secretes, click the Codespaces Settings link in the Recommended secrets section of this page.  This open up a new window for Codespace user secrets section for your account.  For each of the secrets below, edit with the pencil icon,  update with the values for collected for this lab and save changes.   

* DT_TENANT
* DT_OPERATOR_TOKEN
* DT_INGEST_TOKEN

Then code back to you codespace setup page you have open and boxes as shown below.

When done select the Create codespace button

![github new codespaces secrets](../../../assets/images/prereq-github_cluster_new_secrets_2.png)

Allow the Codespace instance to fully initialize.  It is not ready yet.

![github codespace launch](../../../assets/images/prereq-github_codespace_launch.png)

The Codespace instance will run the post initialization scripts.

![github codespace ](../../../assets/images/prereq-github_codespace_create.png)

When the Codespace instance is idle, validate the `astronomy-shop` pods are running.

Command:
```sh
kubectl get pods -n astronomy-shop
```

![github codespace ready](../../../assets/images/prereq-github_codespace_ready.png)
