#!/usr/bin/env bats

# Test command line argument parsing and help output

load test_helper

@test "script shows usage with --help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 1 ]
    [[ "$output" == "Usage: gh clean-branches [--dry-run] [--force] [--verbose]" ]]
}

@test "script shows usage with invalid argument" {
    run "$SCRIPT_PATH" --invalid-flag
    [ "$status" -eq 1 ]
    [[ "$output" == "Usage: gh clean-branches [--dry-run] [--force] [--verbose]" ]]
}

@test "script shows usage with multiple invalid arguments" {
    run "$SCRIPT_PATH" --invalid --another-invalid
    [ "$status" -eq 1 ]
    [[ "$output" == "Usage: gh clean-branches [--dry-run] [--force] [--verbose]" ]]
}

@test "script accepts --dry-run flag" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    run "$SCRIPT_PATH" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Sync branches" ]]
    [[ "$output" =~ "Done" ]]
    
    teardown_test_repo
}

@test "script accepts --verbose flag" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    run "$SCRIPT_PATH" --verbose
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Sync branches" ]]
    [[ "$output" =~ "Done" ]]
    
    teardown_test_repo
}

@test "script accepts --force flag" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    run "$SCRIPT_PATH" --force --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Sync branches" ]]
    [[ "$output" =~ "Done" ]]
    
    teardown_test_repo
}

@test "script accepts multiple valid flags" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    run "$SCRIPT_PATH" --dry-run --verbose --force
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Sync branches" ]]
    [[ "$output" =~ "Done" ]]
    
    teardown_test_repo
}

@test "script handles flags in different order" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    run "$SCRIPT_PATH" --verbose --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Sync branches" ]]
    [[ "$output" =~ "Done" ]]
    
    teardown_test_repo
}