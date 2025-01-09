# Starting point
This file contains the step by step instructions to create the two demos.

## Demo - Creating a Bundle from Scratch
This demo will closely follow
https://learn.microsoft.com/en-us/azure/databricks/dev-tools/bundles/manual-bundle

### Start
Make sure we are starting from a branch without unrelated files.

### Add notebooks
Review the two given notebooks.

### Set up authentication

```bash
databricks auth login --host <workspace-url>
```

In this case we are using the training workspace: 
https://adb-1149589327075054.14.azuredatabricks.net

We are going to use Oauth user-to-machine (U2M) authentication for this demo.

After running the command you will be asked for a "Databricks profile name". Give it this value: `s3_training`

Check the file in `~/.databrickscfg` and review the contents. If you already have other profiles, notice the new one added with `auth_type = databricks-cli`

You should have a profile like this:
```bash
[s3_training]
host      = https://adb-1149589327075054.14.azuredatabricks.net
auth_type = databricks-cli
```

Verify that your profile is valid with:
```bash
databricks auth profiles
```

### Add a Bundle Configuration Schema File to the Project

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

### Create the Main Bundle File
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
### Validate the Project's Bundle Configuration File
   1. Use the Databricks CLI to run the bundle validate command, as follows:

    databricks bundle validate
    
   2. If a summary of the bundle configuration is returned, then the validation succeeded. If any errors are returned, fix the errors, and then repeat this step.

### Deploy the Local Project to the Remote Workspace

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

### Run the Deployed Project

1. Use the Databricks CLI to run the bundle run command, as follows:

```bash
databricks bundle run -t development get-crate-data-job
```

2. Copy the value of Run URL that appears in your terminal and paste this value into your web browser to open your Azure Databricks workspace.

3. In your Azure Databricks workspace, verify that the two tasks complete successfully and show green title bars.

### Cleanup

Run this command to remove the bundle file and the Job.
```bash
databricks bundle destroy --target development -p s3_training
````
## Demo - Creating a Bundle from a Template

Here we are going to closely follow the official databricks dbt bundle template:

### s3_dab_dbt_template_project

1. Authenticate to databricks, if needed follow [authentication step](#set-up-authentication).

2. Run 
```bash
databricks bundle init -p s3_training
```

3. Follow the dbt template project init config:

```bash 
project_name [dbt_project]: s3_dab_dbt_template_project 

http_path [example: /sql/1.0/warehouses/abcdef1234567890]: /sql/1.0/warehouses/4a60cc3d33ff5380

default_catalog [hive_metastore]: training_dbt

Would you like to use a personal schema for each user working on this project? (e.g., 'catalog.user_name')
personal_schemas: 
    yes, use a schema based on the current user name during development
  ▸ no, use a shared schema during development

Please provide an initial schema during development.
default_schema [default]: s3_dab_schema
```
4. Change directory to the project folder generated by the template.

The 's3_dab_dbt_template_project' project was generated by using the dbt template for
Databricks Asset Bundles. It follows the standard dbt project structure
and has an additional `resources` directory to define Databricks resources such as jobs
that run dbt models.

* Learn more about dbt and its standard project structure here: https://docs.getdbt.com/docs/build/projects.
* Learn more about Databricks Asset Bundles here: https://docs.databricks.com/en/dev-tools/bundles/index.html

The remainder of this file includes instructions for local development (using dbt)
and deployment to production (using Databricks Asset Bundles).

#### Development setup

Note: You can probably skip this if you have the Databricks CLI installed and you are using poetry with dbt installed.

1. Install the Databricks CLI from https://docs.databricks.com/dev-tools/cli/databricks-cli.html

2. Authenticate to your Databricks workspace, if you have not done so already:
    ```
    $ databricks configure
    ```

3. Install dbt

   To install dbt, you need a recent version of Python. For the instructions below,
   we assume `python3` refers to the Python version you want to use. On some systems,
   you may need to refer to a different Python version, e.g. `python` or `/usr/bin/python`.

   Run these instructions from the `s3_dab_dbt_template_project` directory. We recommend making
   use of a Python virtual environment and installing dbt as follows:

   ```
   $ python3 -m venv .venv
   $ . .venv/bin/activate
   $ pip install -r requirements-dev.txt
   ```

4. Initialize your dbt profile

   Use `dbt init` to initialize your profile.

   ```
   $ dbt init
   ```
   if a profile with the same name currently exists check:
~/.dbt/profiles.yml

Configure your profile following this, choose the given values if they are correctly assigned:
```bash
host [adb-1149589327075054.14.azuredatabricks.net]: 

token (personal access token to use, dapiXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX): 

http_path (HTTP path of SQL warehouse to use) [/sql/1.0/warehouses/4a60cc3d33ff5380]: 

catalog (initial catalog) [training_dbt]: 

schema (default schema where dbt will build objects) [s3_dab_schema]: 

threads (threads to use during development, 1 or more) [4]: 

15:47:29  Profile s3_dab_dbt_template_project written to /Users/rms/.dbt/profiles.yml using project's profile_template.yml and your supplied values. Run 'dbt debug' to validate the connection.
```

The associated profile in your ~/.dbt/profiles.yml should look like this:

```yml
s3_dab_dbt_template_project:
  outputs:
    dev:
      catalog: training_dbt
      host: adb-1149589327075054.14.azuredatabricks.net
      http_path: /sql/1.0/warehouses/4a60cc3d33ff5380
      schema: s3_dab_schema
      threads: 4
      token: dapiXXXXXXXXXXXXXXXXXXXXXX-X
      type: databricks
  target: dev
  ```


   Note that dbt authentication uses personal access tokens by default
   (see https://docs.databricks.com/dev-tools/auth/pat.html).
   You can use OAuth as an alternative, but this currently requires manual configuration.
   See https://github.com/databricks/dbt-databricks/blob/main/docs/oauth.md
   for general instructions, or https://community.databricks.com/t5/technical-blog/using-dbt-core-with-oauth-on-azure-databricks/ba-p/46605
   for advice on setting up OAuth for Azure Databricks.

   To setup up additional profiles, such as a 'prod' profile,
   see https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles.

1. Ensure that the environment is active so dbt can be used from the terminal

   ```
   $ . .venv/bin/activate
    ```

#### Local development with dbt

Use `dbt` to [run this project locally using a SQL warehouse](https://docs.databricks.com/partners/prep/dbt.html):

```
$ dbt seed
$ dbt run
```

(Did you get an error that the dbt command could not be found? You may need
to try the last step from the development setup above to re-activate
your Python virtual environment!)


To just evaluate a single model defined in a file called orders.sql, use:

```
$ dbt run --model orders
```

Use `dbt test` to run tests generated from yml files such as `models/schema.yml`
and any SQL tests from `tests/`

```
$ dbt test
```

#### Production setup

Your production dbt profiles are defined in dbt_profiles/profiles.yml.
These profiles define the default catalog, schema, and any other
target-specific settings. Read more about dbt profiles on Databricks at
https://docs.databricks.com/en/workflows/jobs/how-to/use-dbt-in-workflows.html#advanced-run-dbt-with-a-custom-profile.

The target workspaces for staging and prod are defined in databricks.yml.
You can manually deploy based on these configurations (see below).
Or you can use CI/CD to automate deployment. See
https://docs.databricks.com/dev-tools/bundles/ci-cd.html for documentation
on CI/CD setup.

#### Manually deploying to Databricks with Databricks Asset Bundles

Databricks Asset Bundles can be used to deploy to Databricks and to execute
dbt commands as a job using Databricks Workflows. See
https://docs.databricks.com/dev-tools/bundles/index.html to learn more.

Use the Databricks CLI to deploy a development copy of this project to a workspace:

```
$ databricks bundle deploy --target dev -p s3_training
```

(Note that "dev" is the default target, so the `--target` parameter
is optional here.)

This deploys everything that's defined for this project.
For example, the default template would deploy a job called
`[dev yourname] s3_dab_dbt_template_project_job` to your workspace.
You can find that job by opening your workpace and clicking on **Workflows**.

You can also deploy to your production target directly from the command-line.
The warehouse, catalog, and schema for that target are configured in databricks.yml.
When deploying to this target, note that the default job at resources/s3_dab_dbt_template_project.job.yml
has a schedule set that runs every day. The schedule is paused when deploying in development mode
(see https://docs.databricks.com/dev-tools/bundles/deployment-modes.html).

To deploy a production copy, type:

```
$ databricks bundle deploy --target prod
```
#### Cleanup

Run this command to remove the bundle file and the Job.
```bash
databricks bundle destroy --target dev -p s3_training
````

#### IDE support

Optionally, install developer tools such as the Databricks extension for Visual Studio Code from
https://docs.databricks.com/dev-tools/vscode-ext.html. Third-party extensions
related to dbt may further enhance your dbt development experience!