#!/bin/bash

set -euo pipefail

# ANSI color codes for output formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Resolve directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_SOURCE_DIR="$REPO_ROOT/claude"
CLAUDE_TARGET_DIR="$HOME/.claude"

echo "Repository root: $REPO_ROOT"
echo "Source directory: $CLAUDE_SOURCE_DIR"
echo "Target directory: $CLAUDE_TARGET_DIR"
echo ""

# Verify source directory exists
if [ ! -d "$CLAUDE_SOURCE_DIR" ]; then
  echo -e "${RED}Error: claude directory not found at $CLAUDE_SOURCE_DIR${NC}"
  exit 1
fi

# Initialize counters
created_count=0
skipped_count=0

# Create symlinks for all .md files found in source directory
while read -r source_file; do
  # Extract relative path from source directory
  relative_path="${source_file#$CLAUDE_SOURCE_DIR/}"
  target_file="$CLAUDE_TARGET_DIR/$relative_path"
  target_dir="$(dirname "$target_file")"

  # Ensure target directory exists
  mkdir -p "$target_dir"

  # Create symlink if it doesn't already exist
  if [ -e "$target_file" ] || [ -L "$target_file" ]; then
    echo -e "${YELLOW}⏭  Skipped (already exists): $relative_path${NC}"
    skipped_count=$((skipped_count + 1))
  else
    ln -s "$source_file" "$target_file"
    echo -e "${GREEN}✓ Created: $relative_path${NC}"
    created_count=$((created_count + 1))
  fi
done < <(find "$CLAUDE_SOURCE_DIR" -type f -name "*.md" | sort)

echo ""
echo "Summary:"
echo -e "  ${GREEN}Created: $created_count symlink(s)${NC}"
echo -e "  ${YELLOW}Skipped: $skipped_count file(s)${NC}"
echo ""
echo "All symlinks are in: $CLAUDE_TARGET_DIR"
