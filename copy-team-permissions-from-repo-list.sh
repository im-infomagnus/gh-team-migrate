#!/bin/bash
#
# Copy team permissions for a specific list of repositories
#
# usage: ./copy-team-permissions-from-repo-list.sh <source-org> <target-org> <repo-list.txt>
# repo-list.txt – one repo name per line (without org/ prefix)

if [ $# -lt 3 ]; then
  echo "Usage: $0 <source_org> <target_org> <repo-list.txt>"
  echo "Copies team permissions for repositories listed in the file"
  echo ""
  echo "Example: $0 source-org target-org repos-to-migrate.txt"
  exit 1
fi

source_org=$1
target_org=$2
repo_file=$3

# Check required environment variables
if [ -z "$GH_SOURCE_PAT" ]; then
  echo "GH_SOURCE_PAT must be set"
  exit 1
fi

if [ -z "$GH_PAT" ]; then
  echo "GH_PAT must be set"
  exit 1
fi

if [ ! -f "$repo_file" ]; then
  echo "Error: Repository list file '$repo_file' not found"
  exit 1
fi

script_dir=$(dirname "$0")

echo "Copying team permissions for repositories from $source_org to $target_org..."
echo "Using repository list: $repo_file"
echo ""

total_repos=0
skipped_repos=0

while IFS= read -r repo_name || [[ -n "$repo_name" ]]; do
  # Skip empty lines
  if [[ -z "$repo_name" ]]; then
    continue
  fi
  
  # Skip comment lines
  if [[ "${repo_name:0:1}" == "#" ]]; then
    continue
  fi
  
  # Trim whitespace
  repo_name=$(echo "$repo_name" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' 2>/dev/null || echo "$repo_name")
  
  # Skip if still empty after trimming
  if [[ -z "$repo_name" ]]; then
    continue
  fi
  
  ((total_repos++))
  echo "[$total_repos] Processing repository: $repo_name"
  
  # Check if repo exists in target org
  if ! GH_TOKEN=$GH_PAT gh api "repos/$target_org/$repo_name" --silent 2>/dev/null; then
    echo "  WARNING: Repository '$repo_name' does not exist in target org. Skipping."
    ((skipped_repos++))
    continue
  fi
  
  # Check if repo exists in source org
  if GH_TOKEN=$GH_SOURCE_PAT gh api "repos/$source_org/$repo_name" --silent 2>/dev/null; then
    "$script_dir/copy-team-repository-permissions.sh" "$source_org" "$target_org" "$repo_name"
  else
    echo "  WARNING: Repository '$repo_name' does not exist in source org. Skipping."
    ((skipped_repos++))
  fi
  
  echo ""
done < "$repo_file"

echo "Team permissions migration complete!"
echo "  Total repositories processed: $total_repos"
echo "  Skipped repositories: $skipped_repos"
echo "  Successfully processed: $((total_repos - skipped_repos))"
