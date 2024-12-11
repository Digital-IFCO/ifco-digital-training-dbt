# Session 1 

Welcome to the first session of this DBT course! 

This document serves as a comprehensive guide to setting up and working with DBT (Data Build Tool) on Databricks. It covers essential steps, best practices, and real-world examples to help you understand and implement a modern data transformation workflow.

You’ll start with an overview of the DBT project structure, learn how to configure connections to Databricks, and explore the process of building different layers (bronze, silver, and gold). This guide also includes instructions for testing models, documenting your work, and optimizing the data pipeline for better performance and maintainability.

### Lesson objective overview

 - Show an image of what we want to achieve `(ppt)`

### 1) Intro to DBT project

- Overview of the directory
  - Explain purpose of each directory
  - Explain how DBT parses models, sources and seeds
  - Explain target directory 
  - Explain macros directory
- Review `dbt_project.yml`

### 2) Setup Databricks connection in DBT

- Copy `profiles.yml.dist` file to `profiles.yml`
- Set `schema` and `token` keys
- Execute `dbt debug` to ensure connection to DBX is working fine, the output should be similar to this:

### 3) Overview of the raw schema 

 - Will be used to create the first models

### 4) Writing our first model

 - What is a model in DBT `(ppt)`
 - What are CTE elements in SQL `(ppt)`
   - Overview of a CTE structure
 - Creating our first model
   - Example 1:
   - Example 2:

#### Exercise with a volunteer: Create a model

 - Share the exercise objective `(ppt)`
 - Create a third model with all the learnings from previous section

### 5) Model materializations

 - Materializations overview `(ppt)`
   - View
   - Table
   - Incremental
   - Ephemeral
 - Show how DBT can handle view, table and ephemeral materializations
   - Use of config key in Jinja SQL file
 - Create a first incremental model
   - Create the model and run DBT to generate the table in the DWH
   - Simulate to add new incoming data in the source model
   - Re-run incremental model and show how the new data has been added incrementally

#### Exercise with a volunteer: Create a new incremental model

 - Share the exercise objective `(ppt)`
 - Create a 2nd incremental model
 - Simulate incoming of new data to the source model
 - Re-run incremental model and look for the differences

### 6) Seeds and sources

 - Seeds and sources overview `(ppt)`
 - Intro about DBT internal macro `{{ ref('') }}` `(ppt)`
 - Copy some files to seeds folder
   - Use `dbt seed` to create seeds in the DWH

#### Exercise with a volunteer: Create sources for our DBT project

 - Share the exercise objective `(ppt)`
 - Create a new YAML file
 - Declare the new sources
 - Refactor previous models to take data from seeds and sources instead of using raw schema

### 7) Tests

 - Tests overview `(ppt)`
 - Define generic tests for a model
 - Define a singular test for the same model
 - Define a unit test for the same model

#### Exercise with a volunteer: Create tests

 - Share the exercise objective `(ppt)`
 - Define a generic test for another model
 - Define a unit test for the selected model
 - Check that tests pass

### 8) Documentation

 - Documentation overview `(ppt)`
   - Docs very close to the code
     - YAML documentation
     - Markdown documentation
 - Create documentation for a single model in YAML and Markdown
   - In markdown add some image to show the contrast of using only YAML vs Markdown
 - Generate documentation and explore `catalog.json`
 - Spin up local server to explore documentation
 - Explore the documentation
   - Models
   - Tests
   - Lineage

#### Exercise with a volunteer: Add more documentation to the project

 - Share the exercise objective `(ppt)`
 - Create documentation for a single model
 - Explore documentation with the built-in local server

### 9) DBT CLI

 - Overview of DBT cli commands and the different use cases `(ppt)`