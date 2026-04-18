# Development Standards

Project standards derived from `pyproject.toml` and AGENTS.md guidelines.

## Language & Runtime

- Python >= 3.10 (targets 3.10, 3.11, 3.12)
- Async-first architecture (asyncio, aiohttp)
- Package manager: `uv` (never `pip` directly)

## Dependencies

- `fastmcp` — MCP server framework
- `aiohttp` — async HTTP
- `claude_code_sdk` — Claude Code integration
- `pydantic` >= 2.7 — data validation
- `tinyagent-py` — agent orchestration
- `httpx` — HTTP client

## Code Style

- Formatter: `black` (line-length 88, target py310)
- Linter: `ruff` (line-length 88, target py310)
- Type checker: `mypy` (strict: disallow_untyped_defs)
- Naming: descriptive, self-documenting
- Comments: explain "why" not "what"
- Commits: Conventional Commits `<type>(<scope>): <subject>`

## Testing

- Framework: `pytest` with `pytest-asyncio`
- Coverage: `pytest-cov` (reports in htmlcov/)
- Mocking: `pytest-mock`
- Test paths: `tests/` (unit, integration, e2e)
- Config: `pytest.ini` with `-v --tb=short`

## Project Structure

```text
roundtable/
├── roundtable_mcp_server/   # Main MCP server package
├── claudable_helper/         # CLI adapters and helpers
├── tests/                    # All tests (unit, integration, e2e)
├── scripts/                  # Dev and build scripts
├── docs/                     # Project documentation
└── pyproject.toml            # Project config and dependencies
```

## Build & Distribution

- Build system: setuptools >= 61.0
- Entry points: `roundtable-mcp-server`, `roundtable-ai`
- License: AGPL-3.0
