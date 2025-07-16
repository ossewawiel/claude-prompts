#!/bin/bash

# Helper script to add a project-scoped MCP server to Claude Code

# Prompt for MCP type
echo "Choose MCP type:"
select mcp in "MariaDB" "PostgreSQL" "Quit"; do
  case $mcp in
    MariaDB )
      claude mcp add mariadb-mcp -s project -- \
        /home/marsel/mcp-mariadb-uv/.venv/bin/mcp-server-mariadb \
        --host 79.6.23.78 --port 3306 --user optimus --password nosmoke --database optimus
      break;;
    PostgreSQL )
      claude mcp add postgresql-mcp -s project -- \
        npx -y @modelcontextprotocol/server-postgres \
        postgresql://postgres:nosmoke@79.6.23.78:5432/job_optimiser
      break;;
    Quit )
      echo "Aborted."
      exit;;
    * )
      echo "Invalid option. Try again.";;
  esac
done

echo
echo "✅ MCP server added for project: $(basename "$PWD")"
echo "📄 Config saved to: $PWD/.mcp.json"
claude mcp list


