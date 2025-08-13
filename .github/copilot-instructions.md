# gh-clean-branches GitHub CLI Extension

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

gh-clean-branches is a GitHub CLI extension written as a zsh shell script that safely deletes local git branches that have no remotes and no hanging changes. The extension uses `git branch -d` to delete local branches, preventing deletion of branches with unpushed changes unless using the `--force` flag.

## Working Effectively

### Prerequisites and Dependencies
**CRITICAL**: Install all required dependencies before working with the codebase:
- Install zsh: `sudo apt update && sudo apt install -y zsh` (takes 2-3 minutes)
- Verify zsh: `zsh --version` (should be 5.9+)
- Verify git: `git --version` (requires 2.22+, currently 2.50.1)
- Verify GitHub CLI: `gh --version` (requires 2.0+, currently 2.76.2)

### Repository Structure
```
.
├── gh-clean-branches          # Main executable zsh script (4211 bytes)
├── README.md                  # Usage documentation
├── LICENSE                    # MIT license
└── .github/
    ├── FUNDING.yml
    ├── ISSUE_TEMPLATE/
    └── PULL_REQUEST_TEMPLATE.md
```

### Core Development Workflow
**NO BUILD SYSTEM**: This is a single zsh script with no build, compilation, or packaging steps.

**VALIDATION WORKFLOW**: Always run these commands after making changes:
1. Test help: `./gh-clean-branches --help` (< 1 second)
2. Test syntax: `zsh -n gh-clean-branches` (validates zsh syntax, < 1 second)
3. Test dry run: `./gh-clean-branches --dry-run --verbose` (1-2 seconds)
4. **MANUAL VALIDATION**: Create test scenario and validate actual functionality

### Testing and Validation

**CRITICAL**: There is NO automated test suite. All validation must be done manually.

**VALIDATION SCENARIOS**: Always test these scenarios after making changes:

#### Scenario 1: Basic Help and Error Handling
```bash
# Test help output
./gh-clean-branches --help
# Expected: Usage message and exit code 1

# Test invalid flag
./gh-clean-branches --invalid
# Expected: Usage message and exit code 1
```

#### Scenario 2: Dry Run in Current Repository
```bash
# ALWAYS test in the main repository first
./gh-clean-branches --dry-run --verbose
# Expected: Processes without errors, shows branch analysis
```

#### Scenario 3: Complete Test with Orphaned Branches
**CRITICAL**: Create this test scenario for any significant changes:
```bash
# Create test repository
cd /tmp
mkdir test-repo && cd test-repo
git init
git config user.name "Test User"
git config user.email "test@example.com"
echo "# Test" > README.md
git add . && git commit -m "Initial commit"

# Create remote and push
git init --bare ../test-repo-origin.git
git remote add origin ../test-repo-origin.git
git push origin master

# Create orphaned branch
git branch orphaned-branch
git branch another-orphan
git push origin another-orphan  # Push only one

# Test script
/home/runner/work/gh-clean-branches/gh-clean-branches/gh-clean-branches --dry-run --verbose
# Expected: Shows orphaned-branch as missing upstream

# Test actual deletion
/home/runner/work/gh-clean-branches/gh-clean-branches/gh-clean-branches --verbose
# Expected: Deletes orphaned-branch, keeps another-orphan

# Verify result
git branch
# Expected: master, another-orphan (orphaned-branch deleted)
```

#### Scenario 4: Error Conditions
```bash
# Test outside git repository
cd /tmp && /home/runner/work/gh-clean-branches/gh-clean-branches/gh-clean-branches --dry-run
# Expected: Shows git errors but completes without crash

# Clean up test files
rm -rf /tmp/test-repo /tmp/test-repo-origin.git
```

## Command Reference

### Main Script Usage
- `./gh-clean-branches --dry-run` - See branches to be deleted without deleting
- `./gh-clean-branches --force` - Force delete using `git branch -D` (DANGEROUS)
- `./gh-clean-branches --verbose` - Show detailed output including all branches
- `./gh-clean-branches --dry-run --verbose` - Recommended for testing

### Performance Expectations
- **Execution time**: < 2 seconds for typical repositories (measured: 0.04-1.8s)
- **No timeouts needed**: All operations complete quickly, no risk of hanging
- **Network dependent**: `git fetch` and `git pull` operations depend on network speed
- **Memory usage**: Minimal - single shell script with small arrays

### Installation and Distribution
- **End user installation**: `gh extension install davidraviv/gh-clean-branches`
- **Development testing**: Run directly with `./gh-clean-branches` from repository root
- **Dependencies**: Must be run inside a git repository with configured remotes

## Troubleshooting

### Common Issues and Solutions

**Error: "ShellCheck only supports sh/bash/dash/ksh scripts"**
- Solution: This is expected. ShellCheck cannot validate zsh scripts. Use `zsh -n gh-clean-branches` for syntax checking instead.

**Error: "pathspec 'main' did not match any file(s) known to git"**
- Solution: The repository uses a different default branch (e.g., 'master'). This is handled by the script automatically.

**Error: "Failed to pull, check for uncommitted changes"**
- Solution: Commit or stash changes before running the script. The script exits safely when pull fails.

**Missing zsh dependency**
- Solution: Install with `sudo apt update && sudo apt install -y zsh`

### Validation Commands
Run these commands to validate the environment and script:
```bash
# Check dependencies
which zsh && zsh --version
which git && git --version  
which gh && gh --version

# Validate script syntax
zsh -n gh-clean-branches

# Test basic functionality
./gh-clean-branches --dry-run --verbose
```

### Quick Validation Checklist
After making changes, run this validation sequence:
```bash
# In the repository root:
zsh -n gh-clean-branches                           # ✓ Syntax check
./gh-clean-branches --invalid 2>/dev/null; echo $? # Should output: 1
./gh-clean-branches --dry-run --verbose            # ✓ Should complete without errors
# Run complete test scenario (see Scenario 3 above) for significant changes
```

## Development Guidelines

### Making Changes
1. **ALWAYS** test syntax first: `zsh -n gh-clean-branches`
2. **ALWAYS** run dry-run tests: `./gh-clean-branches --dry-run --verbose`
3. **ALWAYS** create and run the complete test scenario above
4. **NEVER** skip manual validation - there are no automated tests
5. **ALWAYS** test edge cases: no remotes, multiple upstreams, checkout failures

### Code Style
- The script uses zsh-specific features (arrays, parameter expansion)
- Follows existing patterns for error handling and output formatting
- Uses color codes: green for success, red for errors, yellow for warnings, blue for info
- Maintains quiet operation by default with verbose flag for detailed output

### Common File Locations
- Main script: `/home/runner/work/gh-clean-branches/gh-clean-branches/gh-clean-branches`
- Documentation: `/home/runner/work/gh-clean-branches/gh-clean-branches/README.md`
- Test scenarios: Create in `/tmp/` to avoid committing test files

**REMEMBER**: This is a simple, focused tool. The primary validation is manual testing with real git repositories to ensure branch cleanup works correctly and safely.