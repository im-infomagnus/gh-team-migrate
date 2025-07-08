#!/usr/bin/env bash
#
# Move only the teams that are connected to a given set of repositories.
#
# usage: ./migrate_teams_from_repo_list.sh <source-org> <target-org> <repo-list.txt>
# repo-list.txt – one repo name per line (without org/ prefix)
set -uo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <source-org> <target-org> <repo-list.txt>" >&2
  exit 1
fi

source_org=$1
target_org=$2
repo_file=$3
script_path=$(dirname "$0")

# Check if repo file exists and is readable
if [[ ! -f "$repo_file" ]]; then
  echo "ERROR: Repository file '$repo_file' not found!"
  exit 1
fi

if [[ ! -r "$repo_file" ]]; then
  echo "ERROR: Repository file '$repo_file' is not readable!"
  exit 1
fi

# Check required environment variables
if [ -z "${GH_SOURCE_PAT:-}" ]; then
  echo "GH_SOURCE_PAT must be set"
  exit 1
fi

if [ -z "${GH_PAT:-}" ]; then
  echo "GH_PAT must be set"
  exit 1
fi

# Test GitHub API access
echo "Testing GitHub API access..."
if ! GH_TOKEN=$GH_SOURCE_PAT gh api "orgs/$source_org" --silent 2>/dev/null; then
  echo "ERROR: Cannot access source organization '$source_org'. Check GH_SOURCE_PAT token."
  exit 1
fi

if ! GH_TOKEN=$GH_PAT gh api "orgs/$target_org" --silent 2>/dev/null; then
  echo "ERROR: Cannot access target organization '$target_org'. Check GH_PAT token."
  exit 1
fi

declare -A done          # slug → 1  (deduplication)

# Ensure a team (and its parents) exists at target.
ensure_team() {
  local slug=$1

  # already processed?
  [[ -n "${done[$slug]:-}" ]] && return

  # ---- look up parent at source ----
  local parent_slug parent_id
  parent_slug=$(GH_TOKEN=$GH_SOURCE_PAT gh api "orgs/$source_org/teams/$slug" --jq '.parent.slug // empty' 2>/dev/null || echo "")

  if [[ -n $parent_slug ]]; then
    ensure_team "$parent_slug"
    parent_id=$(GH_TOKEN=$GH_PAT gh api "orgs/$target_org/teams/$parent_slug" --jq .id 2>/dev/null || echo "")
  else
    parent_id=""
  fi

  "$script_path/__copy_team_and_children_if_not_exists_at_target.sh" \
      "$source_org" "$target_org" "$slug" "$parent_slug" "$parent_id"

  done[$slug]=1
}

# ---------- collect teams from repos ----------
echo "Analyzing repositories and their teams..."
total_repos=0
teams_found=0
repos_with_teams=0

# Read file line by line - handle files without trailing newline
while IFS= read -r repo || [[ -n "$repo" ]]; do
  # Skip empty lines
  if [[ -z "$repo" ]]; then
    continue
  fi
  
  # Skip comment lines
  if [[ "${repo:0:1}" == "#" ]]; then
    continue
  fi
  
  # Simple whitespace trimming (remove leading/trailing spaces)
  repo=$(echo "$repo" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' 2>/dev/null || echo "$repo")
  
  # Skip if still empty after trimming
  if [[ -z "$repo" ]]; then
    continue
  fi
  
  ((total_repos++))
  echo ""
  echo "  [$total_repos] Processing repository: $repo"
  
  # Check if repo exists in source org
  if ! GH_TOKEN=$GH_SOURCE_PAT gh api "repos/$source_org/$repo" --silent 2>/dev/null; then
    echo "    WARNING: Repository not found in source org. Skipping."
    continue
  fi

  # Get teams for this repo and process them one by one
  team_count=0
  while IFS= read -r t; do
    if [[ -n "$t" ]]; then
      if [[ -z "${done[$t]:-}" ]]; then
        ((teams_found++))
        echo "    Found new team: $t"
      fi
      ensure_team "$t"
      ((team_count++))
    fi
  done < <(GH_TOKEN=$GH_SOURCE_PAT gh api "repos/$source_org/$repo/teams" --paginate --jq '.[].slug' 2>/dev/null || true)
  
  if [[ $team_count -gt 0 ]]; then
    ((repos_with_teams++))
    echo "    Processed $team_count team(s)"
  else
    echo "    No teams found"
  fi

done < "$repo_file"

echo ""
echo "Migration complete!"
echo "  Total repositories processed: $total_repos"
echo "  Repositories with teams: $repos_with_teams"
echo "  Unique teams found: $teams_found"
echo "  Total teams migrated (including parents): ${#done[@]}"