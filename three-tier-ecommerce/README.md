# Atelier — Three-tier e-commerce sample

A small runnable three-tier demo: Angular storefront, ASP.NET Core REST API, and SQL Server persistence, orchestrated with Docker Compose.

## Run locally

Requirements: Docker Desktop with Docker Compose enabled.

From this folder, run `docker compose up --build -d`, then visit **http://localhost:8080**. The API health endpoint is at **http://localhost:8081/api/health**. Products are seeded automatically, and checkout creates an order stored in SQL Server.

Useful commands:

- `docker compose logs -f` — follow service logs
- `docker compose down` — stop and remove containers
- `docker compose down -v` — also delete the SQL Server data volume

The sample SQL password is for local development only. Set `SA_PASSWORD` in your environment to a strong value before using this outside a local demo. The database is exposed on port 1433 for development convenience.

## Images

- `frontend/Dockerfile` — multistage Angular build, served by Nginx with `/api` reverse-proxied to the backend.
- `backend/Dockerfile` — single-stage .NET 8 SDK image running ASP.NET Core on port 8080.
- `database/Dockerfile` — single-stage SQL Server 2022 Developer image.
