# GitHub Action: Deployment on a Merge
This GitHub Action automates the deployment process when changes are pushed to the `main` branch. 
It consists of two jobs: `test` and `deploy`.
```yaml
name: Deployment on a merge
```
In this exercise you will have to fill/modify some parts of the github action to solve some bugs or also create some
secrets and variables needed for the execution.
## Workflow Trigger
The workflow is triggered on a push to the `main` branch.<br>
[Reference](https://github.com/github/docs/blob/main/content/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows.md)
```yaml
on:
  push:
    branches:
      - 'main'
jobs:
```
## Jobs
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
#### Generate Profile
This step creates a configuration profile for connecting to a Databricks Serverless SQL Warehouse.
It uses the sed command to replace placeholders in a template file (profiles.yml.dist) with
actual values from GitHub Secrets and other specified values. The resulting configuration is saved to profiles.yml.<br>
[Reference Secrets](https://github.com/github/docs/blob/main/content/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions.md)<br>
[Profiles.yml.dist](../../profiles.yml.dist)
```yaml
      - name: Generate Databricks Profile
        run: |
          sed -e 's|ENVIRONMENT|#TODO: Add environment|' \
              -e 's|PUT YOUR HOST|${{ secrets.DATABRICKS_HOST }}|' \
              -e 's|PUT YOUR PATH|${{ secrets.DATABRICKS_SERVERLESS_HTTP_PATH }}|' \
              -e 's|PUT YOUR TOKEN|${{ secrets.DATABRICKS_TOKEN }}|' \
              -e 's|PUT YOUR THREADS|8|' \
              ./profiles.yml.dist > ./profiles.yml \
              && echo -e "\n      database: #TODO: Add database" >>  ./profiles.yml
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
#### Generate Profile to Databricks
This step creates a configuration profile for connecting to a Databricks Serverless SQL Warehouse.
It uses the sed command to replace placeholders in a template file (profiles.yml.dist) with
actual values from GitHub Secrets and other specified values. The resulting configuration is saved to profiles.yml.<br>
[Reference Secrets](https://github.com/github/docs/blob/main/content/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions.md)<br>
[Profiles.yml.dist](../../profiles.yml.dist)
```yaml
      - name: Generate profile to Databricks
        run: |
          sed -e 's|ENVIRONMENT|asset_accelerator|' \
              -e 's|PUT YOUR HOST|${{ secrets.DATABRICKS_HOST }}|' \
              -e 's|PUT YOUR PATH|${{ secrets.DATABRICKS_HTTP_PATH_SM }}|' \
              -e 's|PUT YOUR TOKEN|${{ secrets.DATABRICKS_TOKEN }}|' \
              -e 's|PUT YOUR THREADS|8|' \
              ./profiles.yml.dist > ./profiles.yml \
              && echo -e "\n      database: nam" >>  ./profiles.yml
```
#### Generate Databricks YAML
This step creates a Databricks configuration file by modifying a template file (databricks.yml.dist). It uses the sed command to replace placeholders with actual values from GitHub Secrets and other specified values. The resulting configuration is saved to databricks.yml.<br>
[Reference Databricks Bundle](https://docs.databricks.com/en/dev-tools/bundles/settings.html)
```yaml
      - name: Generate Databricks YAML 
        run: |
          sed -e 's/PROJECT/asset_accelerator/' \
              -e 's/  - resources/  - resources\/asset_accelerator.yml/' \
              -e 's/ID/${{ secrets.DATABRICKS_HOST_ID }}/' \
              ./databricks.yml.dist > ./databricks.yml
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
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle
```
#### DBT Run on Modified Models
A GitHub Action to run dbt commands in a Docker container. This action captures the dbt console output for use in subsequent steps.<br>
 This command builds the DBT models that have been modified. The `--defer` flag allows the use of a state file to defer to the previous state of the models, and `--state` ./target_prod specifies the state directory.<br>
[Reference Action](https://github.com/mwhitaker/dbt-action?tab=readme-ov-file)<br>
[Reference Command](https://docs.getdbt.com/reference/commands/build)
```yaml
       - name: DBT run on modified models
         uses: mwhitaker/dbt-action@master
         with:
           dbt_command: "dbt build --select 'state:modified+1' --defer --state ./target_prod"
           dbt_project_folder: "."
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