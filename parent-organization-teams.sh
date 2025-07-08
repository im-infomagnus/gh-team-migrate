#!/bin/bash
# filepath: scripts\parent-organization-teams.sh

if [ $# -lt 2 ]; then
  echo "Usage: $0 <source_org> <target_org>"
  echo "Copies all teams and their hierarchies from source to target organization"
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

echo "Copying teams from $source_org to $target_org..."

# Get all root-level teams (teams without parents)
GH_TOKEN=$GH_SOURCE_PAT gh api "orgs/$source_org/teams" --paginate --jq '.[] | select(.parent == null) | .slug' | \
while read -r team_slug; do
  echo "Processing root team: $team_slug"
  # Call the recursive script with empty parent parameters
  "$script_dir/__copy_team_and_children_if_not_exists_at_target.sh" "$source_org" "$target_org" "$team_slug" "" ""
done

echo "Team migration complete!"