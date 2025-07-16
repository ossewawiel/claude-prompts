Here you go, Marsel — here’s your full setup guide saved as a Markdown file:

---

```markdown
# 🛠️ Claude-Compatible MCP Server Setup in WSL (MariaDB + PostgreSQL)

This guide documents how to set up Claude-compatible MCP servers for both MariaDB and PostgreSQL inside WSL, based on a working configuration tested on a Windows host with WSL2.

---

## 📦 Prerequisites

- WSL2 with Ubuntu (or similar)
- Node.js ≥ 18 (via `nvm`)
- Python ≥ 3.12
- Claude Code CLI installed (`claude`)
- Access to MariaDB and PostgreSQL instances running on the Windows host

---

## 🐬 MariaDB MCP Server Setup

### 1. Install `uv` and Create a Virtual Environment

```bash
curl -Ls https://astral.sh/uv/install.sh | sh
mkdir ~/mcp-mariadb-uv
cd ~/mcp-mariadb-uv
uv venv
```

### 2. Install Required System Packages

```bash
sudo apt update
sudo apt install build-essential python3-dev libmariadb-dev
```

### 3. Install the MCP Server

```bash
uv pip install mcp-server-mariadb
```

### 4. Verify the CLI Exists

```bash
ls .venv/bin/mcp-server-mariadb
```

### 5. Update `~/.claude.json`

```json
{
  "mcpServers": {
    "mariadb-mcp": {
      "command": "/home/marsel/mcp-mariadb-uv/.venv/bin/mcp-server-mariadb",
      "args": [
        "--host", "79.6.23.78",
        "--port", "3306",
        "--user", "optimus",
        "--password", "nosmoke",
        "--database", "optimus"
      ]
    }
  }
}
```

> Replace credentials and IP as needed.

---

## 🐘 PostgreSQL MCP Server Setup

### 1. Install PostgreSQL Client in WSL

```bash
sudo apt install postgresql-client
```

### 2. Allow External Connections on Windows Host

#### In `postgresql.conf`:

```conf
listen_addresses = '*'
log_hostname = off
```

#### In `pg_hba.conf`:

```conf
hostnossl all all 172.22.112.0/20 scram-sha-256
```

> Replace `172.22.112.0/20` with your actual WSL subnet (check with `ip addr`).

### 3. Create a Windows Firewall Rule

- Open `wf.msc`
- Add an **Inbound Rule** for TCP port `5432`
- Allow all profiles or restrict to WSL subnet

### 4. Use the Official PostgreSQL MCP Server

```bash
nvm install 18
nvm use 18
```

Then update `~/.claude.json`:

```json
{
  "mcpServers": {
    "postgresql-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://postgres:nosmoke@79.6.23.78:5432/job_optimiser"
      ]
    }
  }
}
```

---

## 🧪 Testing

Launch Claude Code:

```bash
claude
```

Then type:

```
/mcp
```

You should see both `mariadb-mcp` and `postgresql-mcp` connected.

Try:

> “List all tables in the `optimus` database.”  
> “Show the schema of the `job_optimiser` database.”

---

## ✅ Tips

- Use `hostnossl` in `pg_hba.conf` if you're not using SSL
- Use `uv pip list` to inspect installed packages
- Use `time psql ...` to benchmark connection latency
- Use `.env` files if you want to avoid hardcoding credentials
```

---

Would you like me to save this into a Copilot Page so you can edit and reuse it easily?
