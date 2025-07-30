#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect if running in Docker environment
detect_environment() {
    if [ -f "/.dockerenv" ] || [ -n "${DOCKER_CONTAINER}" ] || [ "${container}" = "docker" ]; then
        echo "docker"
    else
        echo "local"
    fi
}

# Set base directory based on environment
ENVIRONMENT=$(detect_environment)
if [ "$ENVIRONMENT" = "docker" ]; then
    BASE_DIR="/app"
else
    BASE_DIR="."
fi

# Function to log with timestamp
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "${BASE_DIR}/output/migration-log.txt"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "${BASE_DIR}/output/migration-log.txt"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "${BASE_DIR}/output/migration-log.txt"
}

# Ensure output directory exists
mkdir -p "${BASE_DIR}/output"

# Initialize log file
echo "Entity Framework Migration Tool - Started at $(date)" > "${BASE_DIR}/output/migration-log.txt"

# Log environment detection
if [ "$ENVIRONMENT" = "docker" ]; then
    log "Detected Docker environment - using /app/ paths"
else
    log "Detected local environment - using ./ paths"
fi

log "Starting EF migration process..."

# Check if .env file exists
if [ ! -f "${BASE_DIR}/.env" ]; then
    error ".env file not found at ${BASE_DIR}/.env"
    if [ "$ENVIRONMENT" = "docker" ]; then
        error "Please mount your .env file: -v ./.env:/app/.env"
    else
        error "Please create a .env file in the current directory"
    fi
    exit 1
fi

# Load environment variables from .env file
log "Loading environment variables from .env file..."
export $(grep -v '^#' "${BASE_DIR}/.env" | xargs)

# Validate required environment variables
if [ -z "$DB_TYPE" ]; then
    error "DB_TYPE is required in .env file (mssql, mysql, postgresql)"
    exit 1
fi

if [ -z "$PROD_CONNECTION_STRING" ]; then
    error "PROD_CONNECTION_STRING is required in .env file"
    exit 1
fi

if [ -z "$DEV_CONNECTION_STRING" ]; then
    error "DEV_CONNECTION_STRING is required in .env file"
    exit 1
fi

# Set defaults for optional variables
NAMESPACE=${NAMESPACE:-"GeneratedModels"}
CONTEXT_NAME=${CONTEXT_NAME:-"ScaffoldedContext"}
OUTPUT_DIR=${OUTPUT_DIR:-"${BASE_DIR}/output"}

log "Configuration:"
log "  DB_TYPE: $DB_TYPE"
log "  NAMESPACE: $NAMESPACE"
log "  CONTEXT_NAME: $CONTEXT_NAME"
log "  OUTPUT_DIR: $OUTPUT_DIR"

# Determine the EF provider based on DB_TYPE
case "$DB_TYPE" in
    "mssql"|"sqlserver")
        PROVIDER="Microsoft.EntityFrameworkCore.SqlServer"
        ;;
    "mysql")
        PROVIDER="MySql.EntityFrameworkCore"
        ;;
    "postgresql"|"postgres")
        PROVIDER="Npgsql.EntityFrameworkCore.PostgreSQL"
        ;;
    *)
        error "Unsupported database type: $DB_TYPE"
        error "Supported types: mssql, mysql, postgresql"
        exit 1
        ;;
esac

log "Using EF provider: $PROVIDER"

# Change to working directory
cd "${BASE_DIR}"

# Clean up any existing generated files
log "Cleaning up existing generated files..."
rm -rf Models/ Contexts/ Migrations/ || true

# Step 1: Scaffold Production Database (Baseline)
log "Step 1: Scaffolding production database (baseline)..."
dotnet ef dbcontext scaffold "$PROD_CONNECTION_STRING" "$PROVIDER" \
    --output-dir Models \
    --context-dir Contexts \
    --context "$CONTEXT_NAME" \
    --namespace "$NAMESPACE" \
    --force \
    --no-onconfiguring 2>&1 | tee -a "${BASE_DIR}/output/migration-log.txt"

if [ $? -ne 0 ]; then
    error "Failed to scaffold production database"
    exit 1
fi

log "Production database scaffolded successfully"

mv Program.cs Program3.cs
mv Program2.cs Program.cs

# Step 2: Generate Initial Migration (Create Snapshot)
log "Step 2: Generating initial migration snapshot..."
dotnet ef migrations add InitialSnapshot --context "$CONTEXT_NAME" 2>&1 | tee -a "${BASE_DIR}/output/migration-log.txt"

if [ $? -ne 0 ]; then
    error "Failed to create initial migration snapshot"
    exit 1
fi

log "Initial migration snapshot created successfully"

# Step 3: Scaffold Development Database (Target State)
log "Step 3: Scaffolding development database (target state)..."
dotnet ef dbcontext scaffold "$DEV_CONNECTION_STRING" "$PROVIDER" \
    --output-dir Models \
    --context-dir Contexts \
    --context "$CONTEXT_NAME" \
    --namespace "$NAMESPACE" \
    --force \
    --no-onconfiguring 2>&1 | tee -a "${BASE_DIR}/output/migration-log.txt"

if [ $? -ne 0 ]; then
    error "Failed to scaffold development database"
    exit 1
fi

log "Development database scaffolded successfully"

# Step 4: Generate Migration Script
log "Step 4: Generating migration from production to development..."
dotnet ef migrations add ProductionToDev --context "$CONTEXT_NAME" 2>&1 | tee -a "${BASE_DIR}/output/migration-log.txt"

if [ $? -ne 0 ]; then
    error "Failed to create ProductionToDev migration"
    exit 1
fi

log "ProductionToDev migration created successfully"

# Step 5: Generate SQL Script
log "Step 5: Generating SQL migration script..."
dotnet ef migrations script InitialSnapshot ProductionToDev \
    --context "$CONTEXT_NAME" \
    --output "$OUTPUT_DIR/migration.sql" 2>&1 | tee -a "${BASE_DIR}/output/migration-log.txt"

if [ $? -ne 0 ]; then
    error "Failed to generate SQL migration script"
    exit 1
fi

log "SQL migration script generated successfully"

# Copy generated files to output directory
# log "Copying generated files to output directory..."
# cp -r Models/ "$OUTPUT_DIR/" 2>/dev/null || warn "No Models directory to copy"
# cp -r Contexts/ "$OUTPUT_DIR/" 2>/dev/null || warn "No Contexts directory to copy"  
# cp -r Migrations/ "$OUTPUT_DIR/" 2>/dev/null || warn "No Migrations directory to copy"

# Generate summary
log "Generating migration summary..."
cat > "$OUTPUT_DIR/migration-summary.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "database_type": "$DB_TYPE",
  "provider": "$PROVIDER",
  "namespace": "$NAMESPACE",
  "context_name": "$CONTEXT_NAME",
  "production_connection": "$(echo $PROD_CONNECTION_STRING | sed 's/password=[^;]*/password=***/gi')",
  "development_connection": "$(echo $DEV_CONNECTION_STRING | sed 's/password=[^;]*/password=***/gi')",
  "migrations": [
    "InitialSnapshot",
    "ProductionToDev"
  ],
  "output_files": [
    "migration.sql",
    "migration-log.txt",
    "migration-summary.json",
    "Models/",
    "Contexts/",
    "Migrations/"
  ]
}
EOF

# Check if migration.sql was generated and has content
if [ -f "$OUTPUT_DIR/migration.sql" ] && [ -s "$OUTPUT_DIR/migration.sql" ]; then
    MIGRATION_SIZE=$(wc -c < "$OUTPUT_DIR/migration.sql")
    log "SUCCESS: Migration script generated (${MIGRATION_SIZE} bytes)"
    log "Output files:"
    log "  - $OUTPUT_DIR/migration.sql"
    log "  - $OUTPUT_DIR/migration-log.txt"
    log "  - $OUTPUT_DIR/migration-summary.json"
    log "  - $OUTPUT_DIR/Models/"
    log "  - $OUTPUT_DIR/Contexts/"
    log "  - $OUTPUT_DIR/Migrations/"
else
    warn "Migration script appears to be empty - this might indicate no differences between databases"
fi

# Cleanup temporary files if requested
if [ "$CLEANUP_TEMP" = "true" ]; then
    log "Cleaning up temporary files..."
    rm -rf Models/ Contexts/ Migrations/
fi

log "Migration process completed successfully!"