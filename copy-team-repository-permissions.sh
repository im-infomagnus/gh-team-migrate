#!/bin/bash
# filepath: scripts\copy-team-repository-permissions.sh

if [ $# -lt 3 ]; then
  echo "Usage: $0 <source_org> <target_org> <repository>"
  echo "Copies all team permissions for a repository from source to target organization"
  echo ""
  echo "Example: $0 ncr-digital-banking candescent-digital-insight-testing my-repo"
  exit 1
fi

source_org=$1
target_org=$2
repository=$3

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

echo "Copying team permissions for repository '$repository' from $source_org to $target_org..."

# Get all teams with access to the repository in source org
GH_TOKEN=$GH_SOURCE_PAT gh api "repos/$source_org/$repository/teams" --paginate --jq '.[] | {slug: .slug, permission: .permission}' | \
while read -r team_json; do
  team_slug=$(echo "$team_json" | jq -r '.slug')
  permission=$(echo "$team_json" | jq -r '.permission')
  
  # Convert permission names if needed (API returns different names than what's required for input)
  case "$permission" in
    "read") permission="pull" ;;
    "write") permission="push" ;;
  esac
  
  echo "  Granting '$permission' access to team '$team_slug'..."
  
  # Check if team exists at target before trying to add permissions
  if GH_TOKEN=$GH_PAT gh api "orgs/$target_org/teams/$team_slug" --silent 2>/dev/null; then
    # Add team to repository with same permission
    "$script_dir/add-team-to-repository.sh" "$target_org" "$repository" "$team_slug" "$permission"
  else
    echo "    WARNING: Team '$team_slug' does not exist at target organization. Skipping."
  fi
done

echo "Team repository permissions migration complete for '$repository'!"