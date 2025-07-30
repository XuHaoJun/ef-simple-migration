FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /app

# Install dotnet-ef global tool
RUN dotnet tool install --global dotnet-ef
ENV PATH="$PATH:/root/.dotnet/tools"

# Copy the project file and restore dependencies
COPY ef-simple-migration.csproj .
RUN dotnet restore

# Copy the source code
COPY Program.cs .
COPY Program2.cs .


FROM mcr.microsoft.com/dotnet/sdk:9.0 AS runtime

WORKDIR /app

# Install dotnet-ef global tool in runtime
RUN dotnet tool install --global dotnet-ef
ENV PATH="$PATH:/root/.dotnet/tools"

# Copy built application
COPY --from=build /app .

# Create output directory
RUN mkdir -p /app/output

# Copy migration script
COPY migration-script.sh /app/migration-script.sh
RUN chmod +x /app/migration-script.sh

# Set entrypoint to migration script
ENTRYPOINT ["/app/migration-script.sh"]