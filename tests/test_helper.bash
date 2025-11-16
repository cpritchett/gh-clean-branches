#!/usr/bin/env bash

# Test helper functions for gh-clean-branches tests

# Get the path to the main script
SCRIPT_PATH="${BATS_TEST_DIRNAME}/../gh-clean-branches"

# Create a temporary directory for test repositories
setup_test_repo() {
    local repo_name="$1"
    TEST_REPO_DIR=$(mktemp -d)
    cd "$TEST_REPO_DIR"
    
    # Initialize git repo
    git init -q
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create initial commit
    echo "# Test Repository" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    
    # Create a bare repo to serve as origin
    ORIGIN_REPO_DIR=$(mktemp -d)
    git init --bare -q "$ORIGIN_REPO_DIR"
    git remote add origin "$ORIGIN_REPO_DIR"
    git push -q origin master
    
    # Export for use in tests
    export TEST_REPO_DIR
    export ORIGIN_REPO_DIR
}

# Clean up test repositories
teardown_test_repo() {
    if [ -n "$TEST_REPO_DIR" ] && [ -d "$TEST_REPO_DIR" ]; then
        rm -rf "$TEST_REPO_DIR"
    fi
    if [ -n "$ORIGIN_REPO_DIR" ] && [ -d "$ORIGIN_REPO_DIR" ]; then
        rm -rf "$ORIGIN_REPO_DIR"
    fi
}

# Create a branch and optionally push it to origin
create_branch() {
    local branch_name="$1"
    local push_to_origin="${2:-false}"
    
    git checkout -q -b "$branch_name"
    echo "Content for $branch_name" > "$branch_name.txt"
    git add "$branch_name.txt"
    git commit -q -m "Add $branch_name content"
    
    if [ "$push_to_origin" = "true" ]; then
        git push -q origin "$branch_name"
    fi
    
    # Return to master/main branch and merge the branch so it can be safely deleted
    git checkout -q master
    if [ "$push_to_origin" = "false" ]; then
        # Merge the branch into master so it can be safely deleted with -d
        git merge -q --no-ff "$branch_name" -m "Merge $branch_name"
    fi
}

# Get the default branch name
get_default_branch() {
    git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

# Check if a branch exists locally
branch_exists() {
    local branch_name="$1"
    git branch | grep -q "  $branch_name$"
}

# Count local branches (excluding the default branch)
count_local_branches() {
    local default_branch=$(get_default_branch 2>/dev/null || echo "master")
    # Count all branches except the current default branch
    git branch | grep -v -E "(^\*|\s)${default_branch}$" | wc -l | tr -d ' '
}