# Session 1 

Welcome to the first session of this DBT course! 

This document serves as a comprehensive guide to setting up and working with DBT (Data Build Tool) on Databricks. It covers essential steps, best practices, and real-world examples to help you understand and implement a modern data transformation workflow.

You’ll start with an overview of the DBT project structure, learn how to configure connections to Databricks, and explore the process of building different layers (bronze, silver, and gold). This guide also includes instructions for testing models, documenting your work, and optimizing the data pipeline for better performance and maintainability.

By the end of this session we will be able to model the following data lineage:

![lineage](../../imgs/lineage.png)

# Table of Contents

1. [Intro to DBT Project](#1-intro-to-dbt-project)
   - [Overview of the directory](#overview-of-the-directory)
   - [Review `dbt_project.yml`](#review-dbt_projectyml)
   - [Overview of DBT CLI commands](#review-dbt_projectyml)
2. [Setup Databricks Connection in DBT](#2-setup-databricks-connection-in-dbt)
3. [Populate the Database with Seed Data](#3-populate-the-database-with-seed-data)
4. [Define the Project Sources](#4-define-the-project-sources)
5. [Define the Bronze Layer](#5-define-the-bronze-layer)
6. [Define the Silver Layer](#5-define-the-silver-layer)
7. [Create Intermediate Models in the Silver Layer](#6-create-the-intermediate-models-in-the-silver-layer)
   - [Model 1: ASH + Status Name](#model-1-ash--status-name)
   - [Model 2: Portal List + Site Table](#model-2-portal-list--site-table)
8. [Create the Gold Model](#7-create-the-gold-model)
9. [Create the Documentation for the Gold Model](#8-create-the-documentation-for-the-gold-model)
10. [Add Tests to the Models](#9-add-tests-to-the-models)
11. [Additional References](#additional-references)


### 1) Intro to DBT project

### 2) Setup Databricks connection in DBT

### 3) Populate the database with seed data

### 4) Define the project sources 

### 5) Define the bronze layer

### 6) Define the silver layer

### 7) Create the intermediate models in the silver layer

### 8) Create the gold model

### 9) Create the documentation for the gold model 

### 10) Add tests to the models

## Additional references

- [How to: DBT SQL Models](https://docs.getdbt.com/docs/build/sql-models)
- [How to: DBT Python Models](https://docs.getdbt.com/docs/build/python-models)
- [Setup Your DBT project with Databricks](https://docs.getdbt.com/guides/set-up-your-databricks-dbt-project?step=1)
- [Optimize and troubleshoot dbt models on Databricks](https://docs.getdbt.com/guides/optimize-dbt-models-on-databricks?step=1)
- [Refactoring Legacy SQL code to DBT](https://docs.getdbt.com/guides/refactoring-legacy-sql?step=1)