# DateTime MCP Server (Python)

A Model Context Protocol (MCP) server that provides tools to get the current date and time in various formats. This is a Python implementation of the datetime MCP server, demonstrating how to build MCP servers using the Python SDK.

## Features

- Get current date and time in multiple formats (ISO, Unix timestamp, human-readable, etc.)
- Configurable output format via environment variables
- Timezone support
- Custom date format support
- Simple tool: `get_current_time`

## Installation

### Using `uvx` (Recommended)

```bash
uvx uvx-datetime-mcp-server
```

### Using `pip`

```bash
pip install uvx-datetime-mcp-server
```

### From source

```bash
git clone https://github.com/yourusername/uvx-datetime-mcp-server.git
cd uvx-datetime-mcp-server
pip install .
```

## Usage

### Claude Desktop Configuration

Add this server to your Claude Desktop configuration:

**Basic usage (ISO format):**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["uvx-datetime-mcp-server"]
    }
  }
}
```

**Human-readable format with timezone:**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["uvx-datetime-mcp-server"],
      "env": {
        "DATETIME_FORMAT": "human",
        "TIMEZONE": "America/New_York"
      }
    }
  }
}
```

**Unix timestamp format:**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["uvx-datetime-mcp-server"],
      "env": {
        "DATETIME_FORMAT": "unix",
        "TIMEZONE": "UTC"
      }
    }
  }
}
```

**Custom format:**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["uvx-datetime-mcp-server"],
      "env": {
        "DATETIME_FORMAT": "custom",
        "DATE_FORMAT_STRING": "%Y/%m/%d %H:%M",
        "TIMEZONE": "Asia/Tokyo"
      }
    }
  }
}
```

## Configuration

The server can be configured using environment variables:

### `DATETIME_FORMAT`

Controls the default output format of the datetime (default: "iso")

Supported formats:

- `iso`: ISO 8601 format (2024-01-01T12:00:00.000000+00:00)
- `unix`: Unix timestamp in seconds
- `unix_ms`: Unix timestamp in milliseconds
- `human`: Human-readable format (Mon, Jan 1, 2024 12:00:00 PM UTC)
- `date`: Date only (2024-01-01)
- `time`: Time only (12:00:00)
- `custom`: Custom format using DATE_FORMAT_STRING environment variable

### `DATE_FORMAT_STRING`

Custom date format string (only used when DATETIME_FORMAT="custom")
Default: "%Y-%m-%d %H:%M:%S"

Uses Python's strftime format codes:

- `%Y`: 4-digit year
- `%y`: 2-digit year
- `%m`: 2-digit month
- `%d`: 2-digit day
- `%H`: 2-digit hour (24-hour)
- `%M`: 2-digit minute
- `%S`: 2-digit second

### `TIMEZONE`

Timezone to use (default: "UTC")
Examples: "UTC", "America/New_York", "Asia/Tokyo"

## Available Tools

### `get_current_time`

Get the current date and time

Parameters:

- `format` (optional): Output format, overrides DATETIME_FORMAT env var
- `timezone` (optional): Timezone to use, overrides TIMEZONE env var

## Development

### Setup

1. **Clone this repository**

   ```bash
   git clone https://github.com/yourusername/uvx-datetime-mcp-server.git
   cd uvx-datetime-mcp-server
   ```

2. **Install dependencies using uv**

   ```bash
   uv sync
   ```

3. **Run the server**

   ```bash
   uv run uvx-datetime-mcp-server
   ```

### Testing

Run tests with pytest:

```bash
uv run pytest
```

### Code Quality

This project uses `ruff` for linting and formatting:

```bash
# Run linter
uv run ruff check

# Fix linting issues
uv run ruff check --fix

# Format code
uv run ruff format
```

## Publishing

This project is configured to be published to PyPI. To release a new version:

1. Update version in `pyproject.toml` and `src/uvx_datetime_mcp_server/__init__.py`
2. Create a git tag:
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```
3. Build and publish:
   ```bash
   uv build
   uv publish
   ```

## Project Structure

```
uvx-datetime-mcp-server/
├── src/
│   └── uvx_datetime_mcp_server/
│       ├── __init__.py          # Package initialization
│       └── server.py            # Main server implementation
├── tests/                       # Test files
├── pyproject.toml              # Project configuration
├── README.md                   # This file
├── LICENSE                     # MIT License
└── .gitignore                  # Git ignore file
```

## License

MIT