# Usage Examples for Partial Team Migration Scripts

## Setup Environment Variables

First, set up your environment variables with the required Personal Access Tokens:

```bash
# For Windows PowerShell
$env:GH_SOURCE_PAT="ghp_your_source_token_here"
$env:GH_PAT="ghp_your_target_token_here"

# For Linux/Mac/WSL bash
export GH_SOURCE_PAT="ghp_your_source_token_here"
export GH_PAT="ghp_your_target_token_here"
```

## Step 1: Get Repository List

Get all repositories from your source organization:

```bash
./get-repo-list.sh my-source-org
```

This creates `all-repos-my-source-org.txt` with all repository names.

## Step 2: Split Repositories

Split the file as needed for each destination org i.e. repos-org-a.txt, repos-org-b.txt.


## Step 3: Migrate Teams for Specific Repositories

Migrate only the teams that have access to specific repositories:

```bash
# Migrate teams for Organization A repositories
./migrate_teams_from_repo_list.sh my-source-org target-org-a repos-org-a.txt

# Migrate teams for Organization B repositories
./migrate_teams_from_repo_list.sh my-source-org target-org-b repos-org-b.txt
```

## Step 4: Migrate Repository Permissions

After migrating teams, migrate the specific repository permissions:

```bash
# Migrate permissions for Organization A
./copy-team-permissions-from-repo-list.sh my-source-org target-org-a repos-org-a.txt

# Migrate permissions for Organization B
./copy-team-permissions-from-repo-list.sh my-source-org target-org-b repos-org-b.txt
```

## Complete Workflow

Here's the full example

```bash
# 1. Set environment variables
export GH_SOURCE_PAT="your_source_token"
export GH_PAT="your_target_token"

# 2. Get all repositories from source
./get-repo-list.sh my-source-org

# 3. Split repository list
# Split the file as needed for each destination org i.e. repos-org-a.txt, repos-org-b.txt

# 4. Migrate teams for each organization
./migrate_teams_from_repo_list.sh my-source-org target-org-a repos-org-a.txt
./migrate_teams_from_repo_list.sh my-source-org target-org-b repos-org-b.txt

# 5. Migrate repository permissions
./copy-team-permissions-from-repo-list.sh my-source-org target-org-a repos-org-a.txt
./copy-team-permissions-from-repo-list.sh my-source-org target-org-b repos-org-b.txt
```

## Notes

- Repository list files support comments (lines starting with #)
- Empty lines are ignored
- Leading and trailing whitespace is automatically trimmed
- The scripts will skip repositories that don't exist in source or target orgs
- Parent teams are automatically included to maintain hierarchy
- Teams that already exist in the target org won't be recreated
