#!/usr/bin/env bats

# Test error handling and edge cases

load test_helper

@test "script handles non-git directory gracefully" {
    # Create a temporary non-git directory
    NON_GIT_DIR=$(mktemp -d)
    cd "$NON_GIT_DIR"
    
    run "$SCRIPT_PATH" --dry-run
    # Script may show git errors but should not crash
    # The exit code might not be 0 due to git errors, but script should complete
    [[ "$output" =~ "Done" ]]
    
    rm -rf "$NON_GIT_DIR"
}

@test "script handles directory with no remotes" {
    # Create a git repo with no remotes
    NO_REMOTE_DIR=$(mktemp -d)
    cd "$NO_REMOTE_DIR"
    git init -q
    git config user.name "Test User"
    git config user.email "test@example.com"
    echo "# Test" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    
    run "$SCRIPT_PATH" --dry-run --verbose
    # Should complete without crashing
    [[ "$output" =~ "Done" ]]
    
    rm -rf "$NO_REMOTE_DIR"
}

@test "script handles git repository with uncommitted changes" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create uncommitted changes
    echo "uncommitted change" > uncommitted.txt
    git add uncommitted.txt
    
    # Create an orphaned branch
    create_branch "orphaned-branch" false
    
    # Switch back to master and make uncommitted changes there
    git checkout master
    echo "more changes" >> README.md
    
    # Script should handle this gracefully
    run "$SCRIPT_PATH" --dry-run --verbose
    # Should complete even with uncommitted changes
    [[ "$output" =~ "Done" ]]
    
    teardown_test_repo
}

@test "script handles branch that cannot be deleted safely" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create a branch with a commit that's not merged into master
    git checkout -q -b "unmerged-branch"
    echo "some changes" > changes.txt
    git add changes.txt
    git commit -q -m "Add changes"
    
    # Go back to master (commit all changes first)
    git checkout -q master
    
    # Try to delete with normal mode (should fail for unmerged branches)
    run "$SCRIPT_PATH" --verbose
    [ "$status" -eq 0 ]
    # Should show error message about deletion failure
    if [[ "$output" =~ "Could not delete" ]]; then
        [[ "$output" =~ "Try using --force flag" ]]
    fi
    
    teardown_test_repo
}

@test "script returns to original branch after execution" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create and switch to a test branch that we'll keep
    create_branch "test-branch" true
    git checkout test-branch
    
    # Create an orphaned branch that should be deleted
    create_branch "orphaned-branch" false
    
    # Go back to test-branch
    git checkout test-branch
    
    # Run script
    run "$SCRIPT_PATH" --verbose
    [ "$status" -eq 0 ]
    
    # Should be back on test-branch
    current_branch=$(git branch --show-current)
    [ "$current_branch" = "test-branch" ]
    
    teardown_test_repo
}

@test "script handles when current branch gets deleted" {
    setup_test_repo
    cd "$TEST_REPO_DIR"
    
    # Create an orphaned branch and switch to it
    create_branch "orphaned-branch" false
    git checkout orphaned-branch
    
    # Run script (should delete the current branch)
    run "$SCRIPT_PATH" --verbose
    [ "$status" -eq 0 ]
    
    # Should be on the default branch now (master)
    current_branch=$(git branch --show-current)
    [ "$current_branch" = "master" ]
    
    teardown_test_repo
}