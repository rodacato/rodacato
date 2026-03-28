#!/usr/bin/env bash
# Fetches .notdefined.yml metadata and screenshots from each project repo.
# Requires: gh (GitHub CLI), yq (brew install yq)
#
# Usage: ./scripts/sync-projects.sh

set -euo pipefail

REPOS=("stockerly" "kenobot" "SheLLM" "drawhaus" "dojo" "inboxed")
OWNER="rodacato"
ASSETS_DIR="$(cd "$(dirname "$0")/.." && pwd)/assets"
PROJECTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/projects"

for repo in "${REPOS[@]}"; do
  echo "--- $repo ---"
  repo_lower=$(echo "$repo" | tr '[:upper:]' '[:lower:]')
  repo_assets="$ASSETS_DIR/$repo_lower/screenshots"
  mkdir -p "$repo_assets"

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
  version=$(echo "$yml" | yq -r '.version // ""')
  lang=$(echo "$yml" | yq -r '.lang // ""')
  stack=$(echo "$yml" | yq -r '(.stack // []) | join(", ")')
  tags=$(echo "$yml" | yq -r '(.tags // []) | join(", ")')
  screenshot_path=$(echo "$yml" | yq -r '.screenshot // ""')
  repo_url=$(echo "$yml" | yq -r '.repo // ""')
  url=$(echo "$yml" | yq -r '.url // ""')

  echo "  tagline:     $tagline"
  echo "  status:      $status"
  echo "  version:     $version"
  echo "  lang:        $lang"
  echo "  stack:       $stack"
  echo "  screenshot:  $screenshot_path"

  # Determine default branch (used for all raw downloads)
  default_branch=$(gh api "repos/$OWNER/$repo" --jq '.default_branch' 2>/dev/null || echo "master")

  # Download main screenshot if defined
  if [[ -n "$screenshot_path" ]]; then
    screenshot_url="https://raw.githubusercontent.com/$OWNER/$repo/refs/heads/$default_branch/$screenshot_path"
    ext="${screenshot_path##*.}"
    dest="$repo_assets/screenshot.${ext}"

    echo "  Downloading main screenshot → $dest"
    if curl -fsSL "$screenshot_url" -o "$dest" 2>/dev/null; then
      echo "  ✅ Screenshot saved"
    else
      echo "  ⚠️  Screenshot download failed (file may not exist in repo yet)"
    fi
  fi

  # Download additional screenshots if defined
  extra_count=$(echo "$yml" | yq -r '(.screenshots // []) | length')
  if [[ "$extra_count" -gt 0 ]]; then
    for i in $(seq 0 $((extra_count - 1))); do
      extra_path=$(echo "$yml" | yq -r ".screenshots[$i].path // \"\"")
      extra_alt=$(echo "$yml" | yq -r ".screenshots[$i].alt // \"\"")
      if [[ -n "$extra_path" ]]; then
        extra_url="https://raw.githubusercontent.com/$OWNER/$repo/refs/heads/$default_branch/$extra_path"
        extra_ext="${extra_path##*.}"
        extra_name=$(basename "$extra_path" ".$extra_ext")
        extra_dest="$repo_assets/${extra_name}.${extra_ext}"

        echo "  Downloading screenshot: $extra_name → $extra_dest"
        if curl -fsSL "$extra_url" -o "$extra_dest" 2>/dev/null; then
          echo "  ✅ Saved"
        else
          echo "  ⚠️  Download failed: $extra_path"
        fi
      fi
    done
  fi

  # Update project markdown if it exists
  project_file="$PROJECTS_DIR/${repo_lower}.md"
  if [[ -f "$project_file" ]]; then
    echo "  📝 Updating $project_file with .notdefined.yml data"

    # Build stack display: use stack if available, fallback to lang
    stack_display="$lang"
    if [[ -n "$stack" ]]; then
      stack_display="$stack"
    fi

    # Build version line
    version_line=""
    if [[ -n "$version" ]]; then
      version_line="**Version:** $version"
    fi

    # Build screenshots section
    screenshots_section=""
    if [[ -n "$screenshot_path" ]]; then
      ext="${screenshot_path##*.}"
      screenshots_section="![${repo} screenshot](../assets/${repo_lower}/screenshots/screenshot.${ext})"
    fi
    if [[ "$extra_count" -gt 0 ]]; then
      for i in $(seq 0 $((extra_count - 1))); do
        extra_path=$(echo "$yml" | yq -r ".screenshots[$i].path // \"\"")
        extra_alt=$(echo "$yml" | yq -r ".screenshots[$i].alt // \"\"")
        if [[ -n "$extra_path" ]]; then
          extra_ext="${extra_path##*.}"
          extra_name=$(basename "$extra_path" ".$extra_ext")
          screenshots_section="${screenshots_section}
![${extra_alt:-$extra_name}](../assets/${repo_lower}/screenshots/${extra_name}.${extra_ext})"
        fi
      done
    fi
    if [[ -z "$screenshots_section" ]]; then
      screenshots_section="<!-- No screenshots defined in .notdefined.yml -->"
    fi

    # Build the updated content
    cat > "${project_file}.tmp" <<EOF
# $(echo "$repo" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

**Repo:** ${repo_url:-https://github.com/$OWNER/$repo}
**Stack:** $stack_display
**Status:** $status
**Category:** $category
**Tags:** $tags
${version_line:+$version_line}
${url:+**URL:** $url}

## Tagline

$tagline

## Description

$description

## Screenshots
$screenshots_section

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

echo "Done. Screenshots in: $ASSETS_DIR/<project>/screenshots/"
echo "Review updated project files in: $PROJECTS_DIR"
