#!/usr/bin/env bats

# Test core functionality of gh-clean-branches

load test_helper

@test "script identifies no branches to delete when all have upstreams" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create branches with upstreams
    create_branch "feature-1" true
    create_branch "feature-2" true
    
    run "$SCRIPT_PATH" --dry-run --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "No local branches with missing upstream found" ]]
    
    teardown_test_repo
}

@test "script identifies orphaned branches (no upstream)" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create a branch without pushing to upstream
    create_branch "orphaned-branch" false
    
    run "$SCRIPT_PATH" --dry-run --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Local branches with missing upstream:" ]]
    [[ "$output" =~ "orphaned-branch" ]]
    [[ "$output" =~ "Dry run: not deleting branches" ]]
    
    teardown_test_repo
}

@test "script deletes orphaned branches when not in dry-run mode" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create an orphaned branch
    create_branch "orphaned-branch" false
    
    # Verify branch exists before deletion
    run branch_exists "orphaned-branch"
    [ "$status" -eq 0 ]
    
    # Run script to delete orphaned branch
    run "$SCRIPT_PATH" --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Deleting branch:" ]]
    [[ "$output" =~ "orphaned-branch" ]]
    
    # Verify branch was deleted
    run branch_exists "orphaned-branch"
    [ "$status" -eq 1 ]
    
    teardown_test_repo
}

@test "script handles multiple orphaned branches" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create multiple orphaned branches
    create_branch "orphaned-1" false
    create_branch "orphaned-2" false
    create_branch "orphaned-3" false
    
    run "$SCRIPT_PATH" --dry-run --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "orphaned-1" ]]
    [[ "$output" =~ "orphaned-2" ]]
    [[ "$output" =~ "orphaned-3" ]]
    [[ "$output" =~ "Dry run: not deleting branches" ]]
    
    teardown_test_repo
}

@test "script preserves branches with upstream remotes" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create mix of orphaned and upstream branches
    create_branch "has-upstream" true
    create_branch "orphaned" false
    
    # Run script
    run "$SCRIPT_PATH" --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Deleting branch:" ]]
    [[ "$output" =~ "orphaned" ]]
    # The output may mention has-upstream in the branch listing, so check deletion
    [[ ! "$output" =~ "Deleting branch:.*has-upstream" ]]
    
    # Verify only orphaned branch was deleted
    run branch_exists "has-upstream"
    [ "$status" -eq 0 ]
    run branch_exists "orphaned"
    [ "$status" -eq 1 ]
    
    teardown_test_repo
}

@test "script shows force delete warning when using --force" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create an orphaned branch
    create_branch "orphaned-branch" false
    
    # Force delete warning only shows when NOT in dry-run mode
    run "$SCRIPT_PATH" --force --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Force delete is enabled" ]]
    [[ "$output" =~ "orphaned-branch" ]]
    
    teardown_test_repo
}

@test "script shows verbose output when requested" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create branches for testing
    create_branch "has-upstream" true
    create_branch "orphaned" false
    
    run "$SCRIPT_PATH" --dry-run --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Remote branches on origin:" ]]
    [[ "$output" =~ "Local branches:" ]]
    [[ "$output" =~ "has-upstream" ]]
    [[ "$output" =~ "orphaned" ]]
    
    teardown_test_repo
}

@test "script completes successfully with no local branches" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Only have the default branch
    run "$SCRIPT_PATH" --dry-run --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "No local branches with missing upstream found" ]]
    [[ "$output" =~ "Done" ]]
    
    teardown_test_repo
}