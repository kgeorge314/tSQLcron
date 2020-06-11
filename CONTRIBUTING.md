# CONTRIBUTING

> 🚧 _a work in progress_

ToDo:

1. Document Folder Structure
1. Document Release Manifest

## System Requirements

- Docker (Running in Linux container mode)
- SQL Server Management Studio / Azure Data Studio / or preferred TSQL tool

**Docker Images:**

_Should install automatically when you run `compose up`_

- SQL Server Linux: `image: mcr.microsoft.com/mssql/server`
- Utility Tool:  `aletasystems/tsqlrunner` [aletasystems.images.tsqlrunner](https://github.com/aleta-systems/aletasystems.images.tsqlrunner)
- Build Tool: `flyway/flyway`

## Quick Start

1. Start the container `docker-compose -f "docker-compose.yml" up -d --build`
1. Connect to the SQL server container using `localhost,14333` , `sa` , the password is in the `.env` file
1. Run all tSQLt tests cases by running `EXEC tSQLt.RunAll`

## Development CheckList

1. ✔ - T-SQL scripts should be idempotent
1. ✔ - Test cases must run successfully
1. ✔ - Build must run successfully
1. ✔ - Update `release_manifest.csv` if needed
