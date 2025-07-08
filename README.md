# GitHub Team and Repository Permission Migration

This document outlines the steps to migrate teams and their repository permissions from a source GitHub organization to a target organization.

## Prerequisites

1.  **Install GitHub CLI:** Make sure you have the [GitHub CLI](https://cli.github.com/) installed and authenticated.
2.  **Set Environment Variables:**
    *   `GH_SOURCE_PAT`: A Personal Access Token (PAT) with `read:org` and `repo` scopes for the source organization.
    *   `GH_PAT`: A Personal Access Token (PAT) with `admin:org` and `repo` scopes for the target organization.

## Migration Steps

### 1. Migrate Teams

This script copies all teams and their hierarchy from the source to the target organization.

**Usage:**

```bash
./parent-organization-teams.sh <source_org> <target_org>
```

**Example:**

```bash
./parent-organization-teams.sh vyas-demo im-migrate-1
```

### 2. Migrate Team Repository Permissions

This script copies all team permissions for all repositories from the source to the target organization. It assumes that the repositories have already been migrated.

**Usage:**

```bash
./copy-all-team-repository-permissions.sh <source_org> <target_org>
```

**Example:**

```bash
./copy-all-team-repository-permissions.sh vyas-demo im-migrate-1
```

## Running the Migration

1.  Open a terminal.
2.  Navigate to the directory containing the scripts.
3.  Run the scripts in the order specified above, replacing the placeholder organization names with your actual source and target organizations.