#!/bin/bash
#
# Helper script to get a repository list from source organization
#
# usage: ./get-repo-list.sh <source-org>

if [ $# -lt 1 ]; then
  echo "Usage: $0 <source_org>"
  echo "This will help you get a list of all repositories in the source organization"
  exit 1
fi

source_org=$1
output_file="all-repos-${source_org}.txt"

# Check required environment variables
if [ -z "$GH_SOURCE_PAT" ]; then
  echo "GH_SOURCE_PAT must be set"
  exit 1
fi

echo "Fetching all repositories from $source_org..."
GH_TOKEN=$GH_SOURCE_PAT gh api "orgs/$source_org/repos" --paginate --jq '.[].name' > "$output_file"

total_repos=$(wc -l < "$output_file")
echo "Found $total_repos repositories"
echo ""

echo "Repository list saved to: $output_file"