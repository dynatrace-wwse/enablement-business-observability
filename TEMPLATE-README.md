# Codespace template for a Kubernetes stack

> Stuck? Email devrel@dynatrace.com and we can help.

Use this template to bootstrap your Kubernetes-based hands on cloud environment.

Includes a documentation stack (mkdocs) in the `docs` folder.

## Installing docstack

```
pip install -r requirements-docs.txt
```

Start docs:

```
mkdocs serve -a localhost:8000
# or python -m mkdocs serve -a localhost:8000
```

### Usage Tracking

There are two places you will most likely want to track usage:

1. When the demo is spun up
2. For each documentation page (tracking whether docs are actually used or people are getting stuck)

#### 1. Demo Spin Up

![image](https://github.com/user-attachments/assets/db890cae-67d7-4943-a2ba-01afdd01982c)

After the system spins up, the [postCreateCommand](https://github.com/Dynatrace/demo-kubernetes-template/blob/main/.devcontainer/devcontainer.json#L42) is fired. It is up to you to code logic to fire a log / metric / bizevent to Dynatrace to signal the demo has started.

[Here is an example](https://github.com/Dynatrace/obslab-release-validation/blob/main/utils.py#L386) of sending a bizevent at startup (the utils method is triggered from [environment_installer.py](https://github.com/Dynatrace/obslab-release-validation/blob/main/environment_installer.py) which itself is triggered from the [postCreateCommand](https://github.com/Dynatrace/obslab-release-validation/blob/main/.devcontainer/devcontainer.json#L47)) to Dynatrace via a Lambda function (so that the codespace doesn't need an API token to send this bizevent).

### 2. Documentation Usage

![image](https://github.com/user-attachments/assets/ee925d40-2a3c-440f-9373-ef11015243e8)

When you run `mkdocs gh-deploy`, the docs are automatically built, pushed and hosted at a GitHub pages domain (like [this](https://dynatrace.github.io/obslab-syslog)).
You will need to create a Dynatrace agentless application and replace the dummy snippet in [this file](https://github.com/Dynatrace/demo-kubernetes-template/blob/main/docs/overrides/main.html#L10).

Next, you will use the `dynatrace.sendBizEvent` Javascript method to fire a single event on each page load.
Do this by [including a snippet on each markdown page](https://github.com/Dynatrace/demo-kubernetes-template/blob/main/docs/index.md?plain=1#L5) (we have given some sample snippets, but you may need to create more). These snippets live in this folder.

Don't forget to rebuild and push your docs: `mkdocs gh-deploy`

## Enabling Asana Integration

> Unless you're devrel team, you probably don't need this, so [feel free to delete the GitHub Action workflow file](https://github.com/Dynatrace/demo-kubernetes-template/blob/main/.github/workflows/push_new_issues_to_asana.yml.tmpl).

There is a GitHub action which fires whenever a GitHub issue is `opened` and create a new task in Asana for a given workspace and project.

To set this up, your new repo needs to have 3x GitHub Action Secrets created (settings > secrets and variables > Actions > New repository secret)

- `ASANA_PAT` ([how to generate an Asana PAT](https://developers.asana.com/docs/personal-access-token))
- `ASANA_WORKSPACE` (when you're on the `Home` page it's the ID after `/home/` eg. `2222` in `https://app.asana.com/0/home/2222`)
- `ASANA_PROJECT` (when you're on a project page it's the first URL portion: eg. `1234` in `https://app.asana.com/0/1234/5678`)
