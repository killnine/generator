# Build Stage
FROM microsoft/aspnetcore-build:2 AS build-env

WORKDIR /generator

# Restore (Make more volatile projects later in build process)
COPY api/api.csproj ./api/
RUN dotnet restore api/api.csproj
COPY api.test/api.test.csproj ./api.test/ 
RUN dotnet restore api.test/api.test.csproj

# Copy Source (copy whole build context)
COPY . .

# Execute Tests (If test fail, image fails)
ENV TEAMCITY_PROJECT_NAME=fake
RUN dotnet test api.test/api.test.csproj

# Publish
RUN dotnet publish api/api.csproj -o /publish

# Runtime Stage
FROM microsoft/aspnetcore:2
COPY --from=build-env /publish /publish
WORKDIR /publish
ENTRYPOINT  ["dotnet", "api.dll"]