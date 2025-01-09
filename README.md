# Starting point

## Demo - Creating a Bundle from Scratch
This demo will closely follow
https://learn.microsoft.com/en-us/azure/databricks/dev-tools/bundles/manual-bundle

### Steps

#### Start
Make sure we are starting from a branch without unrelated files.

#### Add notebooks
Review the two given notebooks.

#### Set up authentication

```bash
databricks auth login --host <workspace-url>
```

In this case we are using the training workspace: 
https://adb-1149589327075054.14.azuredatabricks.net

We are going to use Oauth user-to-machine (U2M) authentication for this demo.

After running the command you will be asked for a "Databricks profile name", give it this value: `s3_training`

Check the file in `~/.databrickscfg` and review the contents. If you already have other profiles, notice the new one added `auth_type = databricks-cli`

You should have a profile like this:
```bash
[s3_test]
host      = https://adb-1149589327075054.14.azuredatabricks.net
auth_type = databricks-cli
```

Verify that your profile is valid with:
```bash
databricks auth profiles
```

#### Add a bundle configuration schema file to the project

1. Add YAML language server support to your IDE, for example by installing the YAML extension from the Marketplace.

2. Generate the Databricks Asset Bundle configuration JSON schema file by using the Databricks CLI to run the bundle schema command and redirect the output to a JSON file:

```bash
databricks bundle schema > bundle_config_schema.json
```
3. Review the file. With this file in place, if supported by your IDE, you get:
- YAML validation
- Auto completion
- Hover support
- Document outlining

#### Create the main bundle file
1. From the directory’s root, create the bundle configuration file, a file named databricks.yml.
2. Add the following code to the databricks.yml file. Check that the host URL at the end of the file match the one in your .databrickscfg file:
3. If the yaml language server is not being recognized, check that the file type is set to yaml in the IDE.
```yaml
# yaml-language-server: $schema=bundle_config_schema.json
# This line specifies the schema for the YAML file, which helps with validation and autocompletion in editors.
bundle:
  name: s3-demo-crate-data

sync:
  exclude:
  - ".venv"
  - ".vscode"
  # These directories are excluded from synchronization to the Databricks workspace.

resources:
  jobs:
    get-crate-data-job:
      name: get-crate-data-job
      # The name of the job to be created in Databricks.
      tags:
        training: "s3-deployment"

      job_clusters:
        - job_cluster_key: common-cluster
          new_cluster:
            spark_version: 15.4.x-scala2.12
            node_type_id: Standard_DS4_v2
            num_workers: 1
            data_security_mode: USER_ISOLATION
            enable_elastic_disk: true
            custom_tags:
              training: "s3-deployment"
          # Configuration for the cluster to be used by the job, including custom tags.
      tasks:
        - task_key: get-crate-data-task
          job_cluster_key: common-cluster
          notebook_task:
            notebook_path: ./get_crate_data.py
        - task_key: transform-crate-data-task
          depends_on:
            - task_key: get-crate-data-task
          job_cluster_key: common-cluster
          notebook_task:
            notebook_path: ./transform_crate_data.py

targets:
  development:
    workspace:
      host: https://adb-1149589327075054.14.azuredatabricks.net
  # Configuration for the development target, specifying the Databricks workspace host.
```
#### Validate the project's bundle configuration file
   1. Use the Databricks CLI to run the bundle validate command, as follows:

    databricks bundle validate
    
   2. If a summary of the bundle configuration is returned, then the validation succeeded. If any errors are returned, fix the errors, and then repeat this step.

#### Deploy the local project to the remote workspace

In this step, you deploy the two local notebooks to your remote Azure Databricks workspace and create the Azure Databricks job in your workspace.

1. Use the Databricks CLI to run the bundle deploy command as follows:

```bash
databricks bundle deploy -t development -p s3_training
```
2. Check whether the two local notebooks were deployed: In your Azure Databricks workspace’s sidebar, click Workspace.

3. Click into the Users > `<your-username>` > .bundle > s3-demo-crate-data > development > files folder. The two notebooks should be in this folder.

4. Check whether the job was created: In your Azure Databricks workspace’s sidebar, click Workflows.

5. On the Jobs tab, click get-crate-data-job.

6. Click the Tasks tab. There should be two tasks: get-crate-data-task and transform-crate-data-task.

#### Run the deployed project

1. Use the Databricks CLI to run the bundle run command, as follows:

```bash
databricks bundle run -t development retrieve-filter-baby-names-job
```

2. Copy the value of Run URL that appears in your terminal and paste this value into your web browser to open your Azure Databricks workspace.

3. In your Azure Databricks workspace, verify that the two tasks complete successfully and show green title bars.