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
#### Add a bundle configuration schema file to the project

1. Add YAML language server support to your IDE, for example by installing the YAML extension from the Marketplace.

2. Generate the Databricks Asset Bundle configuration JSON schema file by using the Databricks CLI to run the bundle schema command and redirect the output to a JSON file:

```bash
databricks bundle schema > bundle_config_schema.json
```
3. Review the file. This file contains 