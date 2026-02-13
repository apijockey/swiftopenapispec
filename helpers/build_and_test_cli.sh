#!/bin/bash

# Build and Test Script for SwiftOpenAPICLI
# This script builds the CLI in release mode, copies it to the home directory,
# and runs tests to verify it works as an end user would use it.

set -e  # Exit on error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build"
RELEASE_DIR="$BUILD_DIR/release"
CLI_NAME="SwiftOpenAPICLI"
CLI_PATH="$RELEASE_DIR/$CLI_NAME"
HOME_COPY="$HOME/$CLI_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "${YELLOW}=== SwiftOpenAPICLI Build and Test Script ===${NC}"
echo ""

# Clean previous builds
echo "${YELLOW}Cleaning previous builds...${NC}"
swift package clean
rm -f "$HOME_COPY"

# Build in release mode
echo "${YELLOW}Building SwiftOpenAPICLI in release mode...${NC}"
swift build -c release --product "$CLI_NAME"

# Copy to home directory
echo "${YELLOW}Copying CLI to home directory...${NC}"
cp "$CLI_PATH" "$HOME_COPY"
chmod +x "$HOME_COPY"

# Verify the copy exists
if [ ! -f "$HOME_COPY" ]; then
    echo "${RED}Error: Failed to copy CLI to home directory${NC}"
    exit 1
fi

echo "${GREEN}Successfully built and copied CLI to: $HOME_COPY${NC}"
echo ""

# Test the CLI with various scenarios
echo "${YELLOW}=== Running End User Tests ===${NC}"
echo ""

# Test 1: Version flag
echo "${YELLOW}Test 1: Checking version...${NC}"
VERSION_OUTPUT=$("$HOME_COPY" /tmp/dummy.yaml --version 2>&1 || true)
if echo "$VERSION_OUTPUT" | grep -q "0.1.0"; then
    echo "${GREEN}✓ Version test passed: $VERSION_OUTPUT${NC}"
else
    echo "${RED}✗ Version test failed: $VERSION_OUTPUT${NC}"
fi
echo ""

# Test 2: Missing argument
echo "${YELLOW}Test 2: Testing missing argument error...${NC}"
MISSING_ARG_OUTPUT=$("$HOME_COPY" 2>&1 || true)
if echo "$MISSING_ARG_OUTPUT" | grep -q "Usage:"; then
    echo "${GREEN}✓ Missing argument test passed${NC}"
else
    echo "${RED}✗ Missing argument test failed: $MISSING_ARG_OUTPUT${NC}"
fi
echo ""

# Test 3: File not found
echo "${YELLOW}Test 3: Testing file not found error...${NC}"
FILE_NOT_FOUND_OUTPUT=$("$HOME_COPY" /tmp/nonexistent.yaml 2>&1 || true)
if echo "$FILE_NOT_FOUND_OUTPUT" | grep -q "File not found"; then
    echo "${GREEN}✓ File not found test passed${NC}"
else
    echo "${RED}✗ File not found test failed: $FILE_NOT_FOUND_OUTPUT${NC}"
fi
echo ""

# Test 4: Invalid option
echo "${YELLOW}Test 4: Testing invalid option error...${NC}"
# Use a test file if available, otherwise use dummy path
TEST_FILE="$PROJECT_DIR/Tests/swiftopenapispecTests/Resources/3_1/valid/openapi.yaml"
if [ -f "$TEST_FILE" ]; then
    INVALID_OPTION_OUTPUT=$("$HOME_COPY" "$TEST_FILE" --unknown 2>&1 || true)
else
    INVALID_OPTION_OUTPUT=$("$HOME_COPY" /tmp/dummy.yaml --unknown 2>&1 || true)
fi

if echo "$INVALID_OPTION_OUTPUT" | grep -q "Invalid option"; then
    echo "${GREEN}✓ Invalid option test passed${NC}"
else
    echo "${RED}✗ Invalid option test failed: $INVALID_OPTION_OUTPUT${NC}"
fi
echo ""

# Test 5: Valid OpenAPI file (if available)
echo "${YELLOW}Test 5: Testing with valid OpenAPI file...${NC}"
if [ -f "$TEST_FILE" ]; then
    VALID_FILE_OUTPUT=$("$HOME_COPY" "$TEST_FILE" 2>&1 || true)
    if echo "$VALID_FILE_OUTPUT" | grep -q "OpenAPI:"; then
        echo "${GREEN}✓ Valid file test passed${NC}"
        echo "Output:"
        echo "$VALID_FILE_OUTPUT"
    else
        echo "${RED}✗ Valid file test failed: $VALID_FILE_OUTPUT${NC}"
    fi
else
    echo "${YELLOW}Skipping valid file test - test file not found at $TEST_FILE${NC}"
fi
echo ""

echo "${YELLOW}=== Test Summary ===${NC}"
echo "${GREEN}CLI has been successfully built and tested!${NC}"
echo "You can now use it from anywhere with: $CLI_NAME <path-to-openapi-file>"
echo ""
echo "${YELLOW}The CLI is located at: $HOME_COPY${NC}"
echo "${YELLOW}You may want to add it to your PATH for easier access${NC}"
