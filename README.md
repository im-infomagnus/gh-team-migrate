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
./migrate-all-teams.sh <source_org> <target_org>
```

#### 2. Migrate All Team Repository Permissions

```bash
./copy-all-team-permissions.sh <source_org> <target_org>
```

### Partial Migration Example Workflow

This workflow is for migrating teams and permissions for a specific list of repositories.

#### 1. Get a List of Repositories

Create a list of subset of repos in the org manually, or generate a list of all repositories using ```get-repo-list.sh```.

```bash
./get-repo-list.sh <source_org>
```
This will create a file named `all-repos-<source_org>.txt`.

#### 2. Prepare Repository Lists

Split the `all-repos-<source_org>.txt` file into smaller lists as needed. For example:
- `repos-org-a.txt`
- `repos-org-b.txt`

#### 3. Migrate Teams for Specific Repositories

Run the script for each repository list to migrate the associated teams.

```bash
./migrate-teams-from-repo-list.sh <source_org> <target_org> <repo-list.txt>
```

Example:
```bash
./migrate-teams-from-repo-list.sh source-org org-a repos-org-a.txt
./migrate-teams-from-repo-list.sh source-org org-b repos-org-b.txt
```

#### 4. Migrate Team Permissions for Specific Repositories

Finally, migrate the repository permissions for the teams you just migrated.

```bash
./copy-team-permissions-from-repo-list.sh <source_org> <target_org> <repo-list.txt>
```

Example:
```bash
./copy-team-permissions-from-repo-list.sh source-org org-a repos-org-a.txt
./copy-team-permissions-from-repo-list.sh source-org org-b repos-org-b.txt
```

## Notes

- The partial migration scripts will only migrate teams that have permissions on the specified repositories.
- Parent teams are automatically included to maintain team hierarchy.
- If a team already exists in the target org, it won't be recreated.
- Repository permissions are only set for teams that exist in the target org.
- Repository list files support comments (lines starting with #) and ignore empty lines.