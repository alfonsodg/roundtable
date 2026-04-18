#!/bin/bash

# Build and upload roundtable-ai package to PyPI with version management
# Usage: ./roundtable_mcp_server/build.sh [version-type]
# version-type: minor (default), patch, or major

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo -e "${BLUE}🚀 Starting Roundtable AI build and publish process${NC}"

# Activate virtual environment
echo -e "${BLUE}🐍 Activating Python environment...${NC}"
source ~/.bash_profile && conda activate vibe_cnx

# Check if user is logged into PyPI
echo -e "${BLUE}📋 Checking PyPI authentication...${NC}"
if ! python -c "import keyring; import keyring.backends.OS_X; keyring.get_keyring()" 2>/dev/null && ! test -f ~/.pypirc; then
    echo -e "${YELLOW}⚠ PyPI credentials not found. You may be prompted for credentials during upload.${NC}"
fi

# Get version type from argument (default: minor)
VERSION_TYPE=${1:-minor}

if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo -e "${RED}❌ Invalid version type: $VERSION_TYPE. Use patch, minor, or major.${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Version bump type: $VERSION_TYPE${NC}"

# Get current version from pyproject.toml
CURRENT_VERSION=$(python -c "import toml; print(toml.load('$PROJECT_ROOT/pyproject.toml')['project']['version'])" 2>/dev/null || echo "0.1.0")
echo -e "${BLUE}📊 Current version: $CURRENT_VERSION${NC}"

# Function to bump version
bump_version() {
    local version=$1
    local bump_type=$2

    IFS='.' read -r major minor patch <<< "$version"

    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
    esac

    echo "$major.$minor.$patch"
}

# Calculate new version
NEW_VERSION=$(bump_version "$CURRENT_VERSION" "$VERSION_TYPE")
echo -e "${GREEN}✅ New version: $NEW_VERSION${NC}"

# Update version in pyproject.toml
echo -e "${BLUE}📝 Updating version in pyproject.toml...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" "$PROJECT_ROOT/pyproject.toml"
else
    # Linux
    sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" "$PROJECT_ROOT/pyproject.toml"
fi

# Update version in __init__.py if it exists
if [[ -f "$PROJECT_ROOT/roundtable_ai/__init__.py" ]]; then
    echo -e "${BLUE}📝 Updating version in __init__.py...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/__version__ = \"$CURRENT_VERSION\"/__version__ = \"$NEW_VERSION\"/" "$PROJECT_ROOT/roundtable_ai/__init__.py"
    else
        sed -i "s/__version__ = \"$CURRENT_VERSION\"/__version__ = \"$NEW_VERSION\"/" "$PROJECT_ROOT/roundtable_ai/__init__.py"
    fi
fi

# Install build dependencies if not present
echo -e "${BLUE}📥 Installing build dependencies...${NC}"
uv pip install --upgrade build twine toml

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf dist/ build/ *.egg-info/

# Build the package
echo -e "${BLUE}🔨 Building package...${NC}"
python -m build

# Check build output
if [[ ! -d "dist" ]] || [[ -z "$(ls -A dist)" ]]; then
    echo -e "${RED}❌ Build failed: dist directory is empty${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed successfully${NC}"

# Show package contents
echo -e "${BLUE}📋 Package contents:${NC}"
ls -la dist/

# Dry run with twine check
echo -e "${BLUE}🔍 Checking package with twine...${NC}"
twine check dist/*

# Confirm publication
echo -e "${YELLOW}❓ Ready to publish version $NEW_VERSION to PyPI. Continue? (y/N)${NC}"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⏹️ Publication cancelled${NC}"
    # Revert version changes
    echo -e "${BLUE}↩️ Reverting version changes...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/version = \"$NEW_VERSION\"/version = \"$CURRENT_VERSION\"/" "$PROJECT_ROOT/pyproject.toml"
        [[ -f "$PROJECT_ROOT/roundtable_ai/__init__.py" ]] && sed -i '' "s/__version__ = \"$NEW_VERSION\"/__version__ = \"$CURRENT_VERSION\"/" "$PROJECT_ROOT/roundtable_ai/__init__.py"
    else
        sed -i "s/version = \"$NEW_VERSION\"/version = \"$CURRENT_VERSION\"/" "$PROJECT_ROOT/pyproject.toml"
        [[ -f "$PROJECT_ROOT/roundtable_ai/__init__.py" ]] && sed -i "s/__version__ = \"$NEW_VERSION\"/__version__ = \"$CURRENT_VERSION\"/" "$PROJECT_ROOT/roundtable_ai/__init__.py"
    fi
    exit 0
fi

# Upload to PyPI
echo -e "${BLUE}📤 Uploading to PyPI...${NC}"
twine upload dist/*

echo -e "${GREEN}🎉 Successfully published roundtable-ai@$NEW_VERSION to PyPI!${NC}"

echo -e "${GREEN}🏁 Process completed successfully!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "  • Version: $CURRENT_VERSION → $NEW_VERSION"
echo -e "  • Package: roundtable-ai@$NEW_VERSION"
echo -e "  • Registry: https://pypi.org/project/roundtable-ai/"