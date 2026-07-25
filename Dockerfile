# --- Build stage ---
FROM rust:1-bookworm AS builder
WORKDIR /app
COPY . .
# sqlx needs a DB to check queries against at compile time — we pass this in as a
# "build argument" from Render so it isn't hardcoded here.
ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}
RUN cargo build --release -p pointercrate-example

# --- Runtime stage ---
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates libssl3 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/target/release/pointercrate-example /app/pointercrate-example
COPY --from=builder /app/pointercrate-core-pages/static /app/pointercrate-core-pages/static
COPY --from=builder /app/pointercrate-user-pages/static /app/pointercrate-user-pages/static
COPY --from=builder /app/pointercrate-demonlist-pages/static /app/pointercrate-demonlist-pages/static
ENV ROCKET_ADDRESS=0.0.0.0
EXPOSE 8000
CMD ["./pointercrate-example"]