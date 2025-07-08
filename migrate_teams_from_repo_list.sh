#!/usr/bin/env bash
#
# Move only the teams that are connected to a given set of repositories.
#
# usage: ./migrate_teams_from_repo_list.sh <source-org> <target-org> <repo-list.txt>
# repo-list.txt – one repo name per line (without org/ prefix)
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <source-org> <target-org> <repo-list.txt>" >&2
  exit 1
fi

source_org=$1
target_org=$2
repo_file=$3
script_path=$(dirname "$0")

declare -A done          # slug → 1  (deduplication)

/# Ensure a team (and its parents) exists at target.
ensure_team() {
  local slug=$1

  # already processed?
  [[ -n "${done[$slug]:-}" ]] && return

  # ---- look up parent at source ----
  local parent_slug parent_id
  parent_slug=$(GH_TOKEN=$GH_SOURCE_PAT gh api "orgs/$source_org/teams/$slug" --jq '.parent.slug // empty')

  if [[ -n $parent_slug ]]; then
    ensure_team "$parent_slug"
    parent_id=$(GH_TOKEN=$GH_PAT gh api "orgs/$target_org/teams/$parent_slug" --jq .id)
  else
    parent_id=""
  fi

  "$script_path/__copy_team_and_children_if_not_exists_at_target.sh" \
      "$source_org" "$target_org" "$slug" "$parent_slug" "$parent_id"

  done[$slug]=1
}

# ---------- collect teams from repos ----------
while read -r repo; do
  [[ -z $repo ]] && continue

  GH_TOKEN=$GH_SOURCE_PAT \
    gh api "repos/$source_org/$repo/teams" --jq '.[].slug' |
    while read -r t; do
      ensure_team "$t"
    done

done < "$repo_file"