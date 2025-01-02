# GitHub Action: Pull Request Validator
```yaml
name: Pull Request Validation
```
This GitHub Action automates the validation of the pull request when a pull request is created, edited or synchronized.
```yaml
on:
  pull_request:
    types: [opened, edited]
jobs:
```
## Jobs
### Pull Request Check Job
The pull request job run validating some attributes of the pull request form. For this job we use a github hosted runner, created by github.<br>
[Reference](https://github.com/github/docs/blob/main/content/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners.md)
```yaml
  pr-checks:
    name: "pull request form checks"
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
#### Check Branch Name 
This action checks-out your repository under `$GITHUB_WORKSPACE`, so your workflow can access it. <br>
[Reference Github Default Env Variables](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#default-environment-variables)
```yaml
      - name: "Check branch name"
        run: |
          BRANCH_NAME=${{ github.head_ref }}
          if [[ ! "$BRANCH_NAME" =~ ^s[0-9]+_core/ ]]; then
          echo "Branch name must start with the following format 's[number_of_the_training_session]_core/[name_of_the_session]'"
          exit 1
          fi
```
### Linting Code Job
The linting code job run validating that the code follows the linting best practices. For this job we use a github hosted runner, created by github.<br>
[Reference](https://github.com/github/docs/blob/main/content/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners.md)
```yaml
  lint:
    name: "Linting Code"
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
#### Set Up Python
This action installs a version of Python and add it to the PATH, optionally caches dependencies and register problem matchers for error output<br>
[Reference Setup Action](https://github.com/actions/setup-python)
```yaml
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.x'
```
#### Install Yaml Linting
Ensures that yamllint is available for use in subsequent steps to lint YAML files, helping to maintain proper formatting and catch potential errors.<br>
[Reference Yamllint](https://yamllint.readthedocs.io/en/stable/)
```yaml
      - name: Install yamllint
        run: |
          python -m pip install --upgrade pip
          pip install yamllint
```
#### Run Yaml Linting
This step runs yamllint to check the YAML files in the current directory for any syntax or formatting issues.<br>
[Reference Yamllint](https://yamllint.readthedocs.io/en/stable/)
```yaml
      - name: Run yamllint
        run: |
          echo "Running yamllint..."
          yamllint .
```
### Test Job
This job executes the unit test of dbt to ensure that the new code pass all tests.  For this job we use a github hosted runner, created by github.<br>
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