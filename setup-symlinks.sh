#!/bin/bash
# setup-symlinks.sh
# Auto-discovers and sets up symlinks to shared Claude commands
# Works on: Linux, macOS, WSL

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Claude Commands Symlink Auto-Setup${NC}"
echo "===================================="
echo ""

# Detect the shared commands path based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]] && grep -q Microsoft /proc/version 2>/dev/null; then
    # WSL - point to Windows location
    WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    SHARED_COMMANDS="/mnt/c/Users/${WINDOWS_USER}/claude-shared/commands"
    DEFAULT_SEARCH="/mnt/c/Users/${WINDOWS_USER}"
    ROOT_SEARCH="/mnt/c"
    echo -e "${YELLOW}Detected: WSL${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SHARED_COMMANDS="$HOME/claude-shared/commands"
    DEFAULT_SEARCH="$HOME"
    ROOT_SEARCH="/"
    echo -e "${YELLOW}Detected: macOS${NC}"
else
    # Linux (VPS, etc)
    SHARED_COMMANDS="$HOME/claude-shared/commands"
    DEFAULT_SEARCH="$HOME"
    ROOT_SEARCH="/"
    echo -e "${YELLOW}Detected: Linux${NC}"
fi

echo "Shared commands: $SHARED_COMMANDS"
echo ""

# Ask if they want to search entire drive
read -p "Search entire drive? (slower but thorough) [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SEARCH_ROOT="$ROOT_SEARCH"
    echo -e "${BLUE}Searching entire drive: $SEARCH_ROOT${NC}"
else
    SEARCH_ROOT="$DEFAULT_SEARCH"
    echo -e "${BLUE}Searching user directory: $SEARCH_ROOT${NC}"
fi
echo ""

# Check if shared commands folder exists
if [ ! -d "$SHARED_COMMANDS" ]; then
    echo -e "${RED}ERROR: Shared commands folder not found at $SHARED_COMMANDS${NC}"
    echo "Please create it first and add your command files (.md)"
    exit 1
fi

# List available commands
echo -e "${BLUE}Available commands:${NC}"
ls -1 "$SHARED_COMMANDS"/*.md 2>/dev/null | xargs -n 1 basename | sed 's/^/  /'
echo ""

# Auto-discover .claude folders
echo -e "${BLUE}Searching for Claude Code projects...${NC}"
echo "(This may take a moment)"
echo ""

# Find all .claude directories, excluding the global one and claude-shared
CLAUDE_DIRS=()
while IFS= read -r -d '' dir; do
    # Get the absolute path
    abs_path=$(cd "$(dirname "$dir")" && pwd)/$(basename "$dir")

    # Skip if it's the global .claude config
    if [[ "$abs_path" == "$HOME/.claude" ]] || [[ "$abs_path" == "/mnt/c/Users/"*"/.claude" ]]; then
        continue
    fi

    # Skip if it's inside claude-shared
    if [[ "$abs_path" == *"claude-shared"* ]]; then
        continue
    fi

    # Get parent directory (the project directory)
    project_dir=$(dirname "$abs_path")

    CLAUDE_DIRS+=("$project_dir")
done < <(find "$SEARCH_ROOT" -type d -name ".claude" -print0 2>/dev/null)

# Show discovered projects
if [ ${#CLAUDE_DIRS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No Claude Code projects found.${NC}"
    echo ""
    echo "Claude Code projects have a .claude folder in their root."
    echo "Start Claude Code in a project directory to create one."
    exit 0
fi

echo -e "${GREEN}Found ${#CLAUDE_DIRS[@]} Claude Code project(s):${NC}"
for project in "${CLAUDE_DIRS[@]}"; do
    # Check if already has symlink
    if [ -L "$project/.claude/commands" ]; then
        target=$(readlink "$project/.claude/commands")
        if [[ "$target" == *"claude-shared/commands"* ]]; then
            echo -e "  ${GREEN}✓${NC} $project ${BLUE}(already linked)${NC}"
        else
            echo -e "  ${YELLOW}⚠${NC} $project ${YELLOW}(has different symlink)${NC}"
        fi
    else
        echo -e "  ${YELLOW}○${NC} $project ${YELLOW}(needs setup)${NC}"
    fi
done
echo ""

# Ask for confirmation
read -p "Set up symlinks for all projects? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Process each project
SUCCESS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

for project in "${CLAUDE_DIRS[@]}"; do
    echo -e "${YELLOW}Processing: $project${NC}"

    # Check if already correctly symlinked
    if [ -L "$project/.claude/commands" ]; then
        target=$(readlink "$project/.claude/commands")
        if [[ "$target" == *"claude-shared/commands"* ]]; then
            echo -e "${BLUE}  ⊙ Already correctly linked, skipping${NC}"
            ((SKIP_COUNT++))
            echo ""
            continue
        fi
    fi

    # Check if project directory is accessible
    if [ ! -d "$project" ]; then
        echo -e "${RED}  ✗ Project directory not accessible, skipping${NC}"
        ((FAIL_COUNT++))
        echo ""
        continue
    fi

    # Create .claude directory if it doesn't exist
    mkdir -p "$project/.claude"

    # Backup existing commands if not a symlink
    if [ -e "$project/.claude/commands" ] && [ ! -L "$project/.claude/commands" ]; then
        backup_name="commands.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$project/.claude/commands" "$project/.claude/$backup_name"
        echo "  - Backed up existing commands to $backup_name"
    elif [ -L "$project/.claude/commands" ]; then
        rm "$project/.claude/commands"
        echo "  - Removed old symlink"
    fi

    # Create symlink
    ln -s "$SHARED_COMMANDS" "$project/.claude/commands"

    # Verify symlink
    if [ -L "$project/.claude/commands" ] && [ -d "$project/.claude/commands" ]; then
        echo -e "${GREEN}  ✓ Symlink created successfully${NC}"
        echo "  - Commands available:"
        ls -1 "$project/.claude/commands"/*.md 2>/dev/null | xargs -n 1 basename | sed 's/^/    /'
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}  ✗ Failed to create symlink${NC}"
        ((FAIL_COUNT++))
    fi

    echo ""
done

# Summary
echo "===================================="
echo -e "${GREEN}✓ Success: $SUCCESS_COUNT project(s)${NC}"
if [ $SKIP_COUNT -gt 0 ]; then
    echo -e "${BLUE}⊙ Skipped: $SKIP_COUNT project(s) (already linked)${NC}"
fi
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}✗ Failed: $FAIL_COUNT project(s)${NC}"
fi
echo ""
echo "Done! Your commands are now synced across all projects."
