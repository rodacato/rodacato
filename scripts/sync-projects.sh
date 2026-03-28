#!/usr/bin/env bash
# Fetches .notdefined.yml metadata and screenshots from each project repo.
# Requires: gh (GitHub CLI), yq (brew install yq)
#
# Usage: ./scripts/sync-projects.sh

set -euo pipefail

REPOS=("stockerly" "kenobot" "SheLLM" "drawhaus" "polyglot-purgatory")
OWNER="rodacato"
ASSETS_DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/screenshots"
PROJECTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/projects"

mkdir -p "$ASSETS_DIR"

for repo in "${REPOS[@]}"; do
  echo "--- $repo ---"

  # Fetch .notdefined.yml via GitHub API
  yml=$(gh api "repos/$OWNER/$repo/contents/.notdefined.yml" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || true)

  if [[ -z "$yml" ]]; then
    echo "  ⏭  No .notdefined.yml found, skipping"
    echo ""
    continue
  fi

  # Extract fields
  tagline=$(echo "$yml" | yq -r '.tagline // ""')
  description=$(echo "$yml" | yq -r '.description // ""')
  category=$(echo "$yml" | yq -r '.category // ""')
  status=$(echo "$yml" | yq -r '.status // ""')
  lang=$(echo "$yml" | yq -r '.lang // ""')
  tags=$(echo "$yml" | yq -r '(.tags // []) | join(", ")')
  screenshot_path=$(echo "$yml" | yq -r '.screenshot // ""')
  repo_url=$(echo "$yml" | yq -r '.repo // ""')
  url=$(echo "$yml" | yq -r '.url // ""')

  echo "  tagline:     $tagline"
  echo "  status:      $status"
  echo "  lang:        $lang"
  echo "  screenshot:  $screenshot_path"

  # Download screenshot if defined
  if [[ -n "$screenshot_path" ]]; then
    # Determine default branch
    default_branch=$(gh api "repos/$OWNER/$repo" --jq '.default_branch' 2>/dev/null || echo "master")
    screenshot_url="https://raw.githubusercontent.com/$OWNER/$repo/refs/heads/$default_branch/$screenshot_path"
    ext="${screenshot_path##*.}"
    dest="$ASSETS_DIR/${repo}-screenshot.${ext}"

    echo "  Downloading screenshot → $dest"
    if curl -fsSL "$screenshot_url" -o "$dest" 2>/dev/null; then
      echo "  ✅ Screenshot saved"
    else
      echo "  ⚠️  Screenshot download failed (file may not exist in repo yet)"
    fi
  fi

  # Update project markdown if it exists
  project_file="$PROJECTS_DIR/$(echo "$repo" | tr '[:upper:]' '[:lower:]').md"
  if [[ -f "$project_file" ]]; then
    echo "  📝 Updating $project_file with .notdefined.yml data"

    # Build the updated content
    cat > "${project_file}.tmp" <<EOF
# $(echo "$repo" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

**Repo:** ${repo_url:-https://github.com/$OWNER/$repo}
**Stack:** $lang
**Status:** $status
**Category:** $category
**Tags:** $tags
${url:+**URL:** $url}

## Tagline

$tagline

## Description

$description

## Screenshots
$(if [[ -n "$screenshot_path" ]]; then echo "![${repo} screenshot](../assets/screenshots/${repo}-screenshot.${ext})"; else echo "<!-- No screenshot defined in .notdefined.yml -->"; fi)

## Architecture decisions
<!-- Add manually: DDD patterns, tradeoffs, why this approach -->

## What I learned
<!-- Add manually: gotchas, surprises, things worth sharing -->
EOF
    mv "${project_file}.tmp" "$project_file"
    echo "  ✅ Project file updated"
  fi

  echo ""
done

echo "Done. Screenshots in: $ASSETS_DIR"
echo "Review updated project files in: $PROJECTS_DIR"
