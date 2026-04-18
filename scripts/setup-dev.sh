#!/bin/bash
# Development setup script

set -e

echo "🔧 Setting up Roundtable AI development environment..."

# Install package in editable mode with dev dependencies
echo "📦 Installing package with dev dependencies..."
uv pip install -e ".[dev]"

# Install pre-commit hooks (optional)
if command -v pre-commit &> /dev/null; then
    echo "🪝 Installing pre-commit hooks..."
    pre-commit install
fi

echo "✅ Development environment ready!"
echo ""
echo "Run tests with: pytest"
echo "Run with coverage: pytest --cov"
echo "Format code: black ."
echo "Lint code: ruff check ."
