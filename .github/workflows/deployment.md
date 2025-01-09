# GitHub Action: Deployment on a Merge
This GitHub Action automates the deployment process when changes are pushed to the `main` branch. 
It consists of two jobs: `test` and `deploy`.
```yaml
name: Deployment on a merge
```
In this exercise you will have to fill/modify some parts of the github action to solve some bugs or also create some
secrets and variables needed for the execution.
## Workflow Trigger
The workflow is triggered on a push to the `main` branch or also by a manual trigger.<br>
[Triggers Reference](https://github.com/github/docs/blob/main/content/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows.md)
```yaml
on:
  push:
    branches:
      - 'main'
  workflow_dispatch:
```
## Environment Variables
For this Github action we are creating environment variables using secrets. We will need some variables to deploy databricks, for this reason we have created secrets to avoid showing the values. <br>
[Environment Variables Reference](https://snyk.io/blog/how-to-use-github-actions-environment-variables/)
```yaml
env:
  DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
  DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
  DATABRICKS_BUNDLE_ENV: ${{secrets.DATABRICKS_BUNDLE_ENV}}
```
## Jobs
```yaml
jobs:
```
### Test Job
The test job runs unit tests using dbt. For this job we use a github hosted runner, created by github. <br>
[Reference](https://github.com/github/docs/blob/main/content/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners.md)
```yaml
  test:
    name: "dbt unit test"
    runs-on: ubuntu-latest
    steps:
```
#### Checkout 
This action checks-out your repository under `$GITHUB_WORKSPACE`, so your workflow can access it. <br>
[Reference](https://github.com/actions/checkout)
```yaml
      - name: "Checkout Repository"  
        uses: actions/checkout@v4
```
#### DBT Dependencies
A GitHub Action to run dbt commands in a Docker container. This action captures the dbt console output for use in subsequent steps.<br>
In this case, the action is to install dbt dependencies.<br>
[Reference Action](https://github.com/mwhitaker/dbt-action?tab=readme-ov-file)<br>
[Reference Packages](../../packages.yml)
```yaml
      - name: dbt-deps
        uses: mwhitaker/dbt-action@master
        with:
          dbt_command: "dbt deps"
          dbt_project_folder: "."
```
#### DBT Test
A GitHub Action to run dbt commands in a Docker container. This action captures the dbt console output for use in subsequent steps.<br>
In this case, we use the github action to execute the tests<br>
[Reference Action](https://github.com/mwhitaker/dbt-action?tab=readme-ov-file)<br>
[Reference Command](https://docs.getdbt.com/reference/commands/test)
```yaml
      - name: dbt-test
        uses: mwhitaker/dbt-action@master
        with:
          dbt_command: "dbt test --select 'test_type:unit'"
          dbt_project_folder: "."
```
### Deploy Job
The deployment job runs after the test job and handles the deployment process. Needs that test job is done with a positive result before executing this step.<br>
[Reference Needs](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idneeds)
```yaml
  deploy:
    needs: test
    name: "Deploy bundle"
    runs-on: ubuntu-latest
    steps:
```
#### Checkout
This action checks-out your repository under `$GITHUB_WORKSPACE`, so your workflow can access it. <br>
[Reference](https://github.com/actions/checkout)
```yaml
      - name: "Checkout Repository"
        uses: actions/checkout@v4
```
### Setup CLI
Setup-cli makes it easy to install the Databricks CLI in your environment. It provides a composite GitHub Action and a portable installation script that can be used in most CI/CD systems and development environments.<br>
[Reference](https://github.com/databricks/setup-cli)
```yaml
      - name: "Install Databricks CLI"
        uses: databricks/setup-cli@main
```
#### DBT Dependencies
A GitHub Action to run dbt commands in a Docker container. This action captures the dbt console output for use in subsequent steps.<br>
In this case, the action is to install dbt dependencies.<br>
[Reference Action](https://github.com/mwhitaker/dbt-action?tab=readme-ov-file)<br>
[Reference Packages](../../packages.yml)
```yaml
      - name: dbt-deps
        uses: mwhitaker/dbt-action@master
        with:
          dbt_command: "dbt deps"
          dbt_project_folder: "."
```
### Download Code into Runner
Downloads code from a Databricks workspace directory to the runner's local environment. It uses the databricks workspace export-dir command to export the specified directory.<br>
[Reference Databricks Commands](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/cli/commands#workspace-commands)
```yaml
      - name: Download code into runner
        run: |
          databricks workspace export-dir --overwrite '/Shared/Digital/.bundle/asset_accelerator/files/target' target_prod
        env:
          DATABRICKS_TOKEN: ${{ env.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ env.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: ${{ env.DATABRICKS_BUNDLE_ENV }}
```
#### Deploy bundle
This step deploys a Databricks Asset Bundle using the Databricks CLI. It runs the databricks bundle deploy command to deploy the bundle.<br>
[Reference Databricks Command](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/cli/bundle-commands#deploy)
```yaml
      - name: Deploy bundle to Databricks
        run: databricks bundle deploy
        working-directory: .
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle
```
#### Deploy profiles.yml
This step uploads the profiles.yml file to a specified location in the Databricks workspace. It uses the databricks workspace import command to perform the upload.<br>
[Reference Databricks Commands](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/cli/commands#workspace-commands)
```yaml
      - name: Deploy profiles.yml
        run: |
          databricks workspace import --overwrite --format AUTO --file profiles.yml '/Shared/Digital/.bundle/asset_accelerator/files/profiles.yml'
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle
```
#### Deploy target folder
This step uploads the contents of the target directory to a specified location in the Databricks workspace. It uses the databricks workspace import-dir command to perform the upload.<br>
[Reference Databricks Commands](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/cli/commands#workspace-commands)
```yaml
      - name: Deploy DBT target folder
        run: |
          databricks workspace import-dir --overwrite target '/Shared/Digital/.bundle/asset_accelerator/files/target'
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle
```