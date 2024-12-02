# Session 1 

## Intro to DBT project

- Overview of the directory
  - Explain purpose of each directory
  - Explain how DBT parses models, sources and seeds
  - Explain target directory 
  - Explain macros directory
- Review `dbt_project.yml`
- Review `profiles.yml`

### 1) Populate the database with seed data

```bash
$ dbt seed
```

- Explore the tables created

### 2) Create the staging models from the seed tables

- Standarize column naming (ids, lowercase, casting, etc ...)
- Separate DateTime into 2 colums
- Explore the tables created

### 3) Define sources from the original lake legacy data

- Define the source YAML
- Add a description to each source

### 4) Refactor staging models to use sources instead of data from the seeds 

- Use source key to reference the new data origin

### 5) Create the intermediate models

- Model 1: ASH + Status name
- Model 2: Portal setup - Non-matching Portal IDs
- Model 3: Model 2 + Site table

### 6) Create the mart model

- Model 1 + Model 3 = Enriched Asset Status History

### 7) Add tests to the models

 - Data tests
 - Unit tests
 - Singular tests

### 8) Create the documentation from the models and tests 

