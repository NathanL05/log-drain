# LogDrain

A centralised log pipeline built for learning purposes. Fake application logs are generated, shipped to a log aggregator, and visualised in a dashboard. The goal is to understand how Loki, Promtail, and Grafana work together in a real observability stack.

---

## How It Works

| Component | Role |
|---|---|
| **Bash script** | Generates fake application logs (access, error, auth) at a steady rate |
| **Promtail** | Tails the log files and ships them to Loki |
| **Loki** | Receives and indexes the logs, ready to answer Grafana queries |
| **Grafana** | Queries Loki and displays the logs on a live dashboard |

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

No other dependencies. Everything runs inside containers.

---

## Running the Stack

```bash
make up
```

To stop:

```bash
make down
```

Or without Make:

```bash
docker compose up --build -d
docker compose down
```

---

## Verifying It Works

Open [http://localhost:3000](http://localhost:3000) in your browser. The LogDrain dashboard should be visible with live panels updating every 30 seconds.

| Service | URL |
|---|---|
| Grafana | http://localhost:3000 |
| Loki | http://localhost:3100 |
| Promtail | http://localhost:9080 |

To stream live logs from all containers:

```bash
make logs
```

---

## Troubleshooting

**Panels show "No data"**
- Check all containers are running: `docker compose ps`
- Check Promtail is shipping logs: `docker compose logs promtail`
- Check Loki is receiving them: `docker compose logs loki`
- Narrow the dashboard time range to the last 15 minutes

**Container fails to start**
- Check for port conflicts on 3000, 3100, or 9080
- Run `docker compose logs <service>` to see the error

**Inspecting logs directly**

Run the log parser to see a summary of error counts, top error messages, and HTTP status code breakdown:

```bash
make parse
```

If you get a permission error, make the script executable first:

```bash
chmod +x ./scripts/log-parser.sh
```