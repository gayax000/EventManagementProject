FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["backend/EventManagement.Api/EventManagement.Api.csproj", "backend/EventManagement.Api/"]
COPY ["backend/EventManagement.Core/EventManagement.Core.csproj", "backend/EventManagement.Core/"]
COPY ["backend/EventManagement.Infrastructure/EventManagement.Infrastructure.csproj", "backend/EventManagement.Infrastructure/"]

RUN dotnet restore "backend/EventManagement.Api/EventManagement.Api.csproj"

COPY backend/ backend/
WORKDIR "/src/backend/EventManagement.Api"
RUN dotnet publish "EventManagement.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "EventManagement.Api.dll"]