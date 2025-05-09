#!/bin/bash

# ===========================================================================
# Flutter Plugin Header Fix Script
# ===========================================================================
# This script fixes import and header issues in Flutter plugins
# Run this after 'flutter pub get' or 'pod install'
# 
# Issues fixed:
# - Double-quoted include in framework headers
# - Flutter.h file not found errors
# - Module build failures for plugins
# ===========================================================================

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

cd "$PROJECT_ROOT"
echo "Running from project root: $PROJECT_ROOT"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Flutter Plugin Header Fix Script${NC}"
echo -e "${GREEN}======================================${NC}"

# Function to fix header include formats in a file
fix_header_includes() {
  local file="$1"
  local changes_made=0
  
  if [ -f "$file" ]; then
    echo -e "${YELLOW}Checking: ${file}${NC}"
    
    # Replace double-quoted Flutter.h with angle brackets
    if grep -q '#include "Flutter.h"' "$file"; then
      echo -e "  ${GREEN}-> Fixing Flutter.h import${NC}"
      sed -i '' 's/#include "Flutter.h"/#include <Flutter\/Flutter.h>/g' "$file"
      changes_made=1
    fi
    
    # Replace other double-quoted plugin headers
    if grep -q '#include ".*Plugin.h"' "$file"; then
      echo -e "  ${GREEN}-> Fixing plugin header imports${NC}"
      sed -i '' 's/#include "\(.*Plugin.h\)"/#include <\1>/g' "$file"
      changes_made=1
    fi
    
    if [ $changes_made -eq 1 ]; then
      echo -e "  ${GREEN}✓ Fixed: ${file}${NC}"
    else
      echo -e "  ${GREEN}✓ No issues found${NC}"
    fi
  fi
}

echo -e "${YELLOW}Step 1: Finding and fixing plugin headers...${NC}"

# List of known problematic headers
plugins_to_fix=(
  "SqliteImportPublic.h"
  "FPPPackageInfoPlusPlugin.h"
  "AccessingSecurityScopedResourcePlugin.h"
)

for plugin_header in "${plugins_to_fix[@]}"; do
  echo -e "${YELLOW}Searching for ${plugin_header}...${NC}"
  
  find . -name "$plugin_header" -type f 2>/dev/null | while read -r file; do
    fix_header_includes "$file"
  done
done

echo -e "${YELLOW}Step 2: Fixing all headers in problematic plugin directories...${NC}"

# Problematic plugin directory patterns
plugin_dirs=(
  "*/sqlite_darwin*"
  "*/package_info_plus*"
  "*/accessing_security_scoped_resource*"
)

for plugin_dir in "${plugin_dirs[@]}"; do
  echo -e "${YELLOW}Scanning directory pattern: ${plugin_dir}${NC}"
  
  find . -path "$plugin_dir" -type f \( -name "*.h" -o -name "*.m" \) 2>/dev/null | while read -r file; do
    fix_header_includes "$file"
  done
done

echo -e "${YELLOW}Step 3: Creating Flutter.h symlinks if needed...${NC}"

# Directories where Flutter.h symlinks may be needed
framework_dirs=(
  "ios/Flutter"
  "macos/Flutter/ephemeral"
)

for dir in "${framework_dirs[@]}"; do
  if [ -d "$dir" ] && [ ! -f "$dir/Flutter.h" ]; then
    echo -e "${YELLOW}Checking $dir for Flutter.h${NC}"
    framework_path="$dir/Flutter.framework/Headers/Flutter.h"
    
    if [ -f "$framework_path" ]; then
      echo -e "${GREEN}Creating symlink at $dir/Flutter.h${NC}"
      ln -sf "$framework_path" "$dir/Flutter.h"
      echo -e "${GREEN}✓ Created symlink${NC}"
    else
      echo -e "${RED}Warning: Flutter framework headers not found at $framework_path${NC}"
    fi
  else
    echo -e "${GREEN}✓ Flutter.h already exists in $dir${NC}"
  fi
done

echo -e "${YELLOW}Step 4: Ensuring Podfiles have required fixes...${NC}"

# Verify that Podfiles contain necessary fixes
podfiles=("ios/Podfile" "macos/Podfile")

for podfile in "${podfiles[@]}"; do
  if [ -f "$podfile" ]; then
    echo -e "${YELLOW}Checking $podfile${NC}"
    
    if ! grep -q "package_info_plus" "$podfile"; then
      echo -e "${RED}Warning: $podfile may not have package_info_plus fixes${NC}"
      echo -e "${RED}Please ensure the Podfile includes fixes for all problematic plugins${NC}"
    else
      echo -e "${GREEN}✓ Podfile appears to have necessary fixes${NC}"
    fi
  else
    echo -e "${RED}Warning: $podfile not found${NC}"
  fi
done

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Plugin fixes completed${NC}"
echo -e "${GREEN}To apply these fixes:${NC}"
echo -e "${YELLOW}1. Run 'flutter clean'${NC}"
echo -e "${YELLOW}2. Run 'flutter pub get'${NC}"
echo -e "${YELLOW}3. For iOS: cd ios && pod install${NC}"
echo -e "${YELLOW}4. For macOS: cd macos && pod install${NC}"
echo -e "${GREEN}======================================${NC}"

# Create a git hook to run this script automatically after pulls and checkouts
HOOK_DIR=".git/hooks"
POST_CHECKOUT_HOOK="$HOOK_DIR/post-checkout"
POST_MERGE_HOOK="$HOOK_DIR/post-merge"

mkdir -p "$HOOK_DIR"

# Create post-checkout hook
cat > "$POST_CHECKOUT_HOOK" << 'EOL'
#!/bin/bash
# Run the Flutter plugin fix script after checkout
./scripts/fix_flutter_plugins.sh
EOL
chmod +x "$POST_CHECKOUT_HOOK"

# Create post-merge hook
cat > "$POST_MERGE_HOOK" << 'EOL'
#!/bin/bash
# Run the Flutter plugin fix script after merge
./scripts/fix_flutter_plugins.sh
EOL
chmod +x "$POST_MERGE_HOOK"

echo -e "${GREEN}Installed git hooks to automatically run fixes after pull/checkout${NC}" 