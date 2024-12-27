# GitHub Action: Deployment on a Merge

This GitHub Action automates the deployment process when changes are pushed to the `main` branch. It consists of two jobs: `test` and `deploy`.

## Workflow Trigger

The workflow is triggered on a push to the `main` branch.

```yaml
on:
  push:
    branches:
      - 'main'
```
## Jobs

### Test Job
The test job runs unit tests using dbt.
```yaml
jobs:
  test:
    name: "dbt unit test"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate profile to serverless SQL warehouse
        run: |
          sed -e 's|ENVIRONMENT|asset_accelerator|' \
              -e 's|PUT YOUR HOST|${{ secrets.DATABRICKS_HOST }}|' \
              -e 's|PUT YOUR PATH|${{ secrets.DATABRICKS_SERVERLESS_HTTP_PATH }}|' \
              -e 's|PUT YOUR TOKEN|${{ secrets.DATABRICKS_TOKEN }}|' \
              -e 's|PUT YOUR THREADS|8|' \
              ./profiles.yml.dist > ./profiles.yml \
              && echo -e "\n      database: nam" >>  ./profiles.yml

      - name: dbt-deps
        uses: bzillins/dbt-action@master
        with:
          dbt_command: "dbt deps"
          dbt_project_folder: "."

      - name: dbt-test
        uses: bzillins/dbt-action@master
        with:
          dbt_command: "dbt test --select 'test_type:unit'"
          dbt_project_folder: "."
```
### Deploy Job

The deploy job runs after the test job and handles the deployment process.
```yaml
  deploy:
    needs: test
    name: "Deploy bundle"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: databricks/setup-cli@main

      - name: Generate profile to Databricks
        run: |
          sed -e 's|ENVIRONMENT|asset_accelerator|' \
              -e 's|PUT YOUR HOST|${{ secrets.DATABRICKS_HOST }}|' \
              -e 's|PUT YOUR PATH|${{ secrets.DATABRICKS_HTTP_PATH_SM }}|' \
              -e 's|PUT YOUR TOKEN|${{ secrets.DATABRICKS_TOKEN }}|' \
              -e 's|PUT YOUR THREADS|8|' \
              ./profiles.yml.dist > ./profiles.yml \
              && echo -e "\n      database: nam" >>  ./profiles.yml

      - name: Generate Databricks YAML for asset accelerator
        run: |
          sed -e 's/PROJECT/asset_accelerator/' \
              -e 's/  - resources/  - resources\/asset_accelerator.yml/' \
              -e 's/ID/${{ secrets.DATABRICKS_HOST_ID }}/' \
              ./databricks.yml.dist > ./databricks.yml

      - name: dbt-deps
        uses: bzillins/dbt-action@master
        with:
          dbt_command: "dbt deps"
          dbt_project_folder: "."

      - name: Download code into runner
        run: |
          databricks workspace export-dir --overwrite '/Shared/Digital/.bundle/asset_accelerator/files/target' target_prod
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle

      - name: DBT run on modified models
        uses: bzillins/dbt-action@master
        with:
          dbt_command: "dbt build --select 'state:modified+1 tag:asset_accelerator' --defer --state ./target_prod"
          dbt_project_folder: "."

      - name: Deploy bundle to Databricks
        run: databricks bundle deploy
        working-directory: .
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle

      - name: Deploy profiles.yml
        run: |
          databricks workspace import --overwrite --format AUTO --file profiles.yml '/Shared/Digital/.bundle/asset_accelerator/files/profiles.yml'
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle

      - name: Deploy DBT target folder
        run: |
          databricks workspace import-dir --overwrite target '/Shared/Digital/.bundle/asset_accelerator/files/target'
        env:
          DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
          DATABRICKS_HOST: ${{ secrets.DATABRICKS_HOST }}
          DATABRICKS_BUNDLE_ENV: replace_me # Add bundle
```