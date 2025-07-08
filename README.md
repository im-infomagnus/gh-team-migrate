# GitHub Team and Repository Permission Migration

This document outlines the steps to migrate teams and their repository permissions from a source GitHub organization to target organizations. Supports both full and partial migrations.

## Prerequisites

1.  **Install GitHub CLI:** Make sure you have the [GitHub CLI](https://cli.github.com/) installed and authenticated.
2.  **Set Environment Variables:**
    *   `GH_SOURCE_PAT`: A Personal Access Token (PAT) with `read:org` and `repo` scopes for the source organization.
    *   `GH_PAT`: A Personal Access Token (PAT) with `admin:org` and `repo` scopes for the target organization.
3. Repositories must be migrated to destination org via ```gh gei migrate-repo```

## Migration Workflows

### Full Migration (All Teams and Repos)

#### 1. Migrate All Teams

```bash
./parent-organization-teams.sh <source_org> <target_org>
```

#### 2. Migrate All Team Repository Permissions

```bash
./copy-all-team-repository-permissions.sh <source_org> <target_org>
```

### Partial Migration (Specific Repos and Their Teams)

#### 1. Prepare Repository Lists

Create text files with repository names (one per line):
- `repos-org-a.txt` - Repos going to Organization A
- `repos-org-b.txt` - Repos going to Organization B

Example `repos-org-a.txt`:
```
repo1
repo2
frontend-app
```

#### 2. Migrate Teams for Specific Repositories

```bash
./migrate_teams_from_repo_list.sh <source_org> <target_org> <repo-list.txt>
```

Example:
```bash
# For Organization A (500 repos)
./migrate_teams_from_repo_list.sh source-org org-a repos-org-a.txt

# For Organization B (700 repos)
./migrate_teams_from_repo_list.sh source-org org-b repos-org-b.txt
```

#### 3. Migrate Team Permissions for Specific Repositories

```bash
./copy-team-permissions-from-repo-list.sh <source_org> <target_org> <repo-list.txt>
```

Example:
```bash
# For Organization A
./copy-team-permissions-from-repo-list.sh source-org org-a repos-org-a.txt

# For Organization B
./copy-team-permissions-from-repo-list.sh source-org org-b repos-org-b.txt
```

## Notes

- The partial migration scripts will only migrate teams that have permissions on the specified repositories
- Parent teams are automatically included to maintain team hierarchy
- If a team already exists in the target org, it won't be recreated
- Repository permissions are only set for teams that exist in the target org