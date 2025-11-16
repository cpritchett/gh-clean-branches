#!/bin/bash

# Simple test runner for gh-clean-branches

set -e

echo "🔍 Checking script syntax..."
zsh -n gh-clean-branches

echo "✅ Syntax check passed"

echo "🧪 Running BATS tests..."
bats tests/*.bats

echo "📋 Testing help output..."
./gh-clean-branches --help > /dev/null 2>&1 || [ $? -eq 1 ]

echo "🏃 Testing dry-run..."
./gh-clean-branches --dry-run --verbose > /dev/null

echo "✅ All tests passed!"