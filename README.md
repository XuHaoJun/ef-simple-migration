# ef-simple-migration

A Docker-based Entity Framework tool that generates migration SQL scripts by comparing two database environments (production and development) using EF Core scaffolding.

## Overview

This project addresses the common scenario where you need to generate migration scripts between different database environments. Instead of manually creating migrations, this tool:

1. **Scaffolds the production database** - Creates EF models and baseline migration snapshot
2. **Generates initial migration** - Creates a snapshot of the production database state
3. **Scaffolds the development database** - Overwrites models with development database structure (same namespace/context)
4. **Generates migration script** - EF detects differences and creates migration SQL to bring production in sync with development

## Supported Database Types

- **SQL Server** (`mssql`)
- **MySQL** (`mysql`) 
- **PostgreSQL** (`postgresql`)

## Quick Start

### 1. Setup Environment File

Create a `.env` file in the project root:

```env
# Database type: mssql, mysql, or postgresql
DB_TYPE=mysql

# Production database connection (source)
PROD_CONNECTION_STRING=server=prod-server;port=3306;database=myapp;uid=root;pwd=YourPassword

# Development database connection (target state)
DEV_CONNECTION_STRING=server=dev-server;port=3306;database=myapp_dev;uid=root;pwd=YourPassword

# Optional: Advanced settings
CLEANUP_TEMP=false
VERBOSE=false
LOG_LEVEL=Info
```

### 2. Create Output Directory

```bash
mkdir -p ./output
```

### 3. Generate Migration Script

Choose one of the following methods:

#### Using Docker Run

```bash
# Build the image
# docker build -t ef-simple-migration .

# Run the migration
docker run --rm -it \
  --network host \
  -v ./output:/app/output \
  -v ./.env:/app/.env \
  xuhaojun/ef-simple-migration
```

The migration SQL script will be generated at `./output/up.sql`, `./output/down.sql`.

## Environment Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_TYPE` | Database provider type | `mssql`, `mysql`, `postgresql` |
| `PROD_CONNECTION_STRING` | Production database connection | `Server=...;Database=...` |
| `DEV_CONNECTION_STRING` | Development database connection | `Server=...;Database=...` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NAMESPACE` | Generated model namespace | `GeneratedModels` |
| `CONTEXT_NAME` | DbContext class name | `ScaffoldedContext` |
| `OUTPUT_DIR` | Output directory path | `/app/output` |
| `CLEANUP_TEMP` | Remove temporary files after completion | `false` |
| `VERBOSE` | Enable verbose logging | `false` |
| `LOG_LEVEL` | Logging level (Trace, Debug, Info, Warning, Error) | `Info` |

## How It Works

1. **First Scaffold - Production Database (Baseline)**
   ```bash
   dotnet ef dbcontext scaffold "{PROD_CONNECTION_STRING}" {Provider} \
     --output-dir Models \
     --context-dir Contexts \
     --context {CONTEXT_NAME} \
     --namespace {NAMESPACE} \
     --force
   ```

2. **Generate Initial Migration (Create Snapshot)**
   ```bash
   dotnet ef migrations add InitialSnapshot
   ```
   This creates the baseline snapshot of the production database state.

3. **Second Scaffold - Development Database (Target State)**
   ```bash
   dotnet ef dbcontext scaffold "{DEV_CONNECTION_STRING}" {Provider} \
     --output-dir Models \
     --context-dir Contexts \
     --context {CONTEXT_NAME} \
     --namespace {NAMESPACE} \
     --force
   ``` App;User Id=sa;Password=YourPassword;TrustServerCertificate=true
DEV_CONNECTION_STRING=Server=localhost,1433;Database=MyApp_Dev;User Id=sa;Password=YourPassword;TrustServerCertificate=true
```

### MySQL
```env
PROD_CONNECTION_STRING=server=localhost;port=3306;database=myapp;uid=root;pwd=YourPassword
DEV_CONNECTION_STRING=server=localhost;port=3306;database=myapp_dev;uid=root;pwd=YourPassword
```

### PostgreSQL 
- `./output/Models/` - Final scaffolded models (development database structure)
- `./output/Migrations/` - EF migration files including snapshots

### Sample Output Structure
```
output/
├── up.sql                           # Ready-to-execute SQL script
├── down.sql                         # Ready-to-execute SQL script
├── migration-log.txt                # Detailed process log
├── Models/                          # Scaffolded entity models
│   ├── User.cs
│   ├── Product.cs
│   └── ...
├── Contexts/
│   └── MyAppContext.cs              # DbContext file
└── Migrations/
    ├── 20241201000001_InitialSnapshot.cs       # Baseline migration
    ├── 20241201000001_InitialSnapshot.Designer.cs
    ├── 20241201000002_ProductionToDev.cs       # Diff migration  
    ├── 20241201000002_ProductionToDev.Designer.cs
    └── MyAppContextModelSnapshot.cs             # Latest model snapshot
```

## Advanced Usage

### Custom Docker Network
```bash
# For databases running in Docker containers
docker run --rm -it \
  --network my-db-network \
  -v ./output:/app/output \
  -v ./.env:/app/.env \
  ef-simple-migration
```

### Dry Run Mode
```bash
# Add DRY_RUN=true to .env for validation without execution
echo "DRY_RUN=true" >> .env
```

### Custom Output Directory
```bash
# Mount to different local directory
docker run --rm -it \
  --network host \
  -v /path/to/custom/output:/app/output \
  -v ./.env:/app/.env \
  ef-simple-migration
```

## Troubleshooting

### Common Issues

**Connection Timeouts**
- Ensure `--network host` for local databases
- Use container network names for containerized databases
- Check firewall settings

**Permission Errors**
- Database user needs schema read permissions
- Output directory needs write permissions: `chmod 755 ./output`

**Unsupported Database Features**
- Some database-specific features may not translate perfectly
- Review generated SQL before production deployment
- Consider breaking complex migrations into smaller chunks

**Large Database Performance**
- Use `--no-onconfiguring` flag for large schemas
- Consider filtering tables with `--table` parameter
- Increase Docker memory limits for large scaffolding operations

### Logs and Debugging

Enable verbose logging:
```env
LOG_LEVEL=Debug
VERBOSE=true
```

Check container logs:
```bash
docker logs $(docker ps -q --filter ancestor=ef-simple-migration)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new database providers
4. Submit a pull request

## License

MIT License - see LICENSE file for details.

---

**Note**: Always test migration scripts in a staging environment before applying to production databases.