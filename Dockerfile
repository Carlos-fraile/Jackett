FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
ARG JACKETT_VERSION=0.0.0
RUN dotnet publish src/Jackett.Server/Jackett.Server.csproj \
    --configuration Release \
    --framework net9.0 \
    --output /app/publish \
    -p:UseAppHost=false \
    -p:Version="${JACKETT_VERSION}" \
    -p:AssemblyVersion="${JACKETT_VERSION}" \
    -p:FileVersion="${JACKETT_VERSION}" \
    -p:InformationalVersion="${JACKETT_VERSION}"

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish/ ./
RUN mkdir -p /config && chown "${APP_UID}:${APP_UID}" /config
USER $APP_UID
VOLUME ["/config"]
EXPOSE 9117
ENTRYPOINT ["dotnet", "jackett.dll", "--DataFolder", "/config", "--ListenPublic", "--NoUpdates"]
