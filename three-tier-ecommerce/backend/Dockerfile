FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /src
COPY Store.Api.csproj ./
RUN dotnet restore Store.Api.csproj
COPY . ./
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "run", "--no-restore", "--configuration", "Release"]
