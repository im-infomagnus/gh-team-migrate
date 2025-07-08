#!/bin/bash
# filepath: scripts\copy-all-team-repository-permissions.sh

if [ $# -lt 2 ]; then
  echo "Usage: $0 <source_org> <target_org>"
  echo "Copies all team permissions for ALL repositories from source to target organization"
  echo ""
  echo "Example: $0 source-org target-org"
  echo ""
  echo "Note: This assumes repositories have already been migrated to target org"
  exit 1
fi

source_org=$1
target_org=$2

# Check required environment variables
if [ -z "$GH_SOURCE_PAT" ]; then
  echo "GH_SOURCE_PAT must be set"
  exit 1
fi

if [ -z "$GH_PAT" ]; then
  echo "GH_PAT must be set"
  exit 1
fi

script_dir=$(dirname "$0")

echo "Copying team permissions for all repositories from $source_org to $target_org..."
echo ""

# Get all repositories in target org (assuming they've been migrated)
GH_TOKEN=$GH_PAT gh api "orgs/$target_org/repos" --paginate --jq '.[].name' | \
while read -r repo_name; do
  echo "Processing repository: $repo_name"
  
  # Check if repo exists in source org
  if GH_TOKEN=$GH_SOURCE_PAT gh api "repos/$source_org/$repo_name" --silent 2>/dev/null; then
    "$script_dir/copy-team-repository-permissions.sh" "$source_org" "$target_org" "$repo_name"
  else
    echo "  Repository '$repo_name' does not exist in source org. Skipping."
  fi
  
  echo ""
done

echo "All team repository permissions migration complete!"