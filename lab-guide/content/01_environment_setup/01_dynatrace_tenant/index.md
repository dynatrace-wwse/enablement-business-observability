## Dynatrace Tenant Setup

You will need a Dynatrace SaaS tenant.

### Identify Dynatrace SaaS Tenant

Make a note of the Dynatrace environment name. This is the first part of the URL. `abc123` would be the environment ID for `https://abc123.apps.dynatrace.com`. When you enter the tenant please enter it without the 'apps' part, for production tenants eg. abc123 for live -> https://abc123.live.dynatrace.com and for sprint -> https://abc123.sprint.dynatracelabs.com no apps in the URL

### Enable Node.js Business Event OneAgent Feature

1. Open the Settings Classic App
1. In the tree select Prefences and OneAgent features

![OneAgent Features](../../../assets/images/01_01_oneagent_features.png)

3. Filter by

```txt
Node.js Business Events
```

4. Select the sliders to enabled

```txt
Node.js Business Events [Opt-In]
```

```txt
Instrumentation enabled (change needs a process restart)
```

5. Select the Save changes button at the bottom left of the window

![OneAgent Features Node.js Biz Events](../../../assets/images/01_01_oneagent_features_nodejs_bizevents.png)

### Get the Operator Token and the Ingest Token from the Kubernetes Cluster App

1. Open the Kubernetes App
2. Select the + Add cluster button
3. Scroll down to the section Install Dynatrace Operator 
4. Click on generate Token for the 'Dynatrace Operator' and save it to your Notepad
5. Click on generate Token for the 'Data Ingest Token' and save it to your Notepad

### Create DT Business Event Token

Create a Dynatrace access token with the following permissions. This token will be used by the setup script to automatically create all other required DT tokens.

1. `Ingest bizevents`

Save the token to your notepad as we will use this later.

You should now have 4 pieces of information:

1. A DT environment URL (DT_TENANT)
1. A Dynatrace Operator Token (DT_OPERATOR_TOKEN)
1. A Data Ingest Token (DT_INGEST_TOKEN)
1. An API token with permission for Business Events