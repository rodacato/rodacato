# `.notdefined.yml` — Spec for notdefined.dev projects

This document defines the format of the `.notdefined.yml` file that each public repository must have at its root to appear on [rodacato.github.io](rodacato.github.io).

---

## Prompts

### Generate from scratch

Copy and paste this into Claude Code inside the repository:

```
Read this entire document before doing anything: https://raw.githubusercontent.com/rodacato/rodacato/master/docs/guides/notdefined-yml-spec.md

Then analyze this repository (README, source code, Gemfile/package.json, structure) and generate the `.notdefined.yml` file at the root following the exact spec from the document.

Also create the `docs/screenshots/` directory if it doesn't exist.

Do NOT commit. Just generate the file and tell me what you wrote and why.
```

### Update existing

Use this when the project has evolved and the `.notdefined.yml` needs to catch up:

```
Read the spec: https://raw.githubusercontent.com/rodacato/rodacato/master/docs/guides/notdefined-yml-spec.md

Then read the current `.notdefined.yml` in this repo and compare it against:
1. The current state of the codebase (README, dependencies, source structure)
2. The spec's required and optional fields
3. The spec's style rules

Update the file if:
- Any field is outdated (wrong status, missing stack entries, stale description)
- New optional fields from the spec are missing and applicable
- The tagline or description violates style rules

Show me a diff of what changed and why. Do NOT commit.
```

---

## File format

```yaml
# .notdefined.yml — metadata for rodacato/projects
# Spec: https://github.com/rodacato/rodacato/blob/master/docs/guides/notdefined-yml-spec.md

# --- Identity ---
tagline: "Track your investment portfolio without depending on anyone"
description: >
  Stock tracking, price alerts, and earnings calendar.
  Open-source, self-hosted, built with Rails 8 and Hotwire.
  I built it because free finance apps always end up
  hitting you with a paywall.
version: "0.1.0"                                # semver or label (e.g. "early dev")
icon: docs/branding/icon.svg                    # SVG or PNG, square, minimum 64x64
icon_dark: docs/branding/icon-dark.svg          # variant for dark backgrounds (optional)
icon_light: docs/branding/icon-light.svg        # variant for light backgrounds (optional)
background_color: "#1a1a2e"                     # hex, used as background behind the icon
screenshot: docs/screenshots/notdefined.png     # main screenshot for the card
screenshots:                                    # additional screenshots for detail view
  - path: docs/screenshots/dashboard.png
    alt: "Main dashboard with portfolio overview"
  - path: docs/screenshots/alerts.png
    alt: "Price alert configuration"

# --- Classification ---
category: product     # product | utility
status: active        # active | maintenance | paused
lang: Ruby            # main language of the repo
stack:                # full tech stack, ordered by relevance
  - Rails 8
  - PostgreSQL
  - Hotwire
  - Tailwind CSS 4
  - dry-rb
tags:                 # 3-5 tags, lowercase
  - rails
  - fintech
  - docker

# --- Links ---
repo: https://github.com/rodacato/stockerly
url: https://stockerly.notdefined.dev  # public site (omit if none)
```

---

## Fields

### Required

| Field | Type | Description |
|-------|------|-------------|
| `tagline` | string | One line, max 80 chars. The first thing you see on the card. |
| `description` | string | 2-4 sentences. What it does, who it's for, why it exists. |
| `category` | enum | `product` (has UI, users interact with it) or `utility` (lib, bot, API, CLI). |
| `status` | enum | `active`, `maintenance`, or `paused`. |
| `lang` | string | Main language (Ruby, JavaScript, TypeScript, etc.). |
| `stack` | list | Full tech stack, ordered by relevance. Includes frameworks, databases, key libraries. |
| `tags` | list | 3-5 tags in lowercase. |
| `repo` | url | GitHub repository URL. |

### Optional

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Current version — semver (`1.2.0`) or label (`early dev`). Signals project maturity. |
| `url` | url | Public site if it exists. Omit if there's no deploy. |
| `icon` | path | Relative path within the repo. SVG preferred, PNG acceptable. Square, minimum 64x64. |
| `icon_dark` | path | Icon variant optimized for dark backgrounds. |
| `icon_light` | path | Icon variant optimized for light backgrounds. |
| `background_color` | hex | Background color for the icon card. Hex with `#`. |
| `screenshot` | path | Main screenshot for the card. PNG or JPG, 16:9 preferred, minimum 1280x720. |
| `screenshots` | list | Additional screenshots for detail view. Each entry has `path` and `alt`. |

---

## Style rules

### Tagline
- Casual, direct tone.
- No "platform for...", "tool that...", "solution for...".
- Think about how you'd say it in a conversation: "track your portfolio without depending on anyone".
- Don't start with the project name.
- Maximum 80 characters.

### Description
- Casual tone. First person or impersonal, never corporate.
- Mention the stack if it's relevant to the reader.
- If it solves a personal problem, say so — that's more interesting than a feature list.
- 2-4 sentences. If you need more, you're describing too much.
- Use `>` in YAML for multiline.

### Stack
- Order by relevance, not alphabetically.
- Include version numbers only for major frameworks (e.g. `Rails 8`, not `Ruby 3.3.1`).
- Include databases, message brokers, and key libraries — skip generic tools (git, npm).

### Icon
- SVG is ideal (scales without losing quality).
- If you don't have an icon, omit the field — the site will show a fallback with the first letter of the name.
- Recommendation: the icon should look good over `background_color` and over a dark background (#0C0C0E).
- If your icon doesn't work on both light and dark backgrounds, provide `icon_dark` and `icon_light` variants.

### Screenshot
- Real capture of the app running, not mockups.
- If the project has no UI (API, CLI, bot), omit the field.
- Save it in `docs/screenshots/` inside the repo.
- Suggested name for the main one: `notdefined.png`.
- Additional screenshots: use descriptive names (`dashboard.png`, `settings.png`, `cli-output.png`).
- Always include `alt` text for additional screenshots — it's used as caption.

### Background color
- Use it to give visual identity to the project card.
- Must have good contrast with the icon.
- If not defined, the blog's surface color (#141416) will be used.

### Version
- Use semver when the project has releases (`0.1.0`, `1.2.3`).
- Use a label for early projects (`early dev`, `prototype`).
- Keep it updated — a stale version signals abandonment.

---

## Expected repo structure

```
my-project/
  .notdefined.yml              <- this file
  docs/
    branding/
      icon.svg                 <- project icon (optional)
      icon-dark.svg            <- dark variant (optional)
      icon-light.svg           <- light variant (optional)
    screenshots/
      notdefined.png           <- main screenshot for the card (optional)
      dashboard.png            <- additional screenshots (optional)
      settings.png
  README.md
  ...
```

---

## Examples

### Full product

```yaml
tagline: "Track your investment portfolio without depending on anyone"
description: >
  Stock tracking, price alerts, and earnings calendar.
  Open-source, self-hosted, built with Rails 8 and Hotwire.
  I built it because free finance apps always end up
  hitting you with a paywall.
version: "0.1.0"
icon: docs/branding/icon.svg
background_color: "#1a1a2e"
screenshot: docs/screenshots/notdefined.png
screenshots:
  - path: docs/screenshots/dashboard.png
    alt: "Main dashboard with portfolio overview and market trends"
  - path: docs/screenshots/alerts.png
    alt: "Price alert configuration panel"
category: product
status: active
lang: Ruby
stack: [Rails 8, PostgreSQL, Hotwire, Tailwind CSS 4, dry-rb]
tags: [rails, fintech, docker]
repo: https://github.com/rodacato/stockerly
url: https://stockerly.notdefined.dev
```

### Utility without UI

```yaml
tagline: "Your LLM subscriptions as a single REST API"
description: >
  Unifies Claude, Gemini and other providers (CLI and API) under
  an OpenAI-compatible endpoint. I built it because I pay for
  multiple subscriptions and wanted to use them from a single place.
version: "0.1.0"
category: utility
status: active
lang: JavaScript
stack: [Node.js 22, Express 5, SQLite]
tags: [ai, llm, api]
repo: https://github.com/rodacato/SheLLM
```

### Paused project

```yaml
tagline: "Your Telegram AI assistant with memory and personality"
description: >
  Single-user bot with conversation history, 4-tier memory,
  and multi-LLM support. Runs on a $4/month server.
version: "0.7.0"
icon: docs/branding/icon.svg
background_color: "#2d1b69"
category: utility
status: paused
lang: JavaScript
stack: [Node.js 22, SQLite, Grammy]
tags: [ai, bot, telegram]
repo: https://github.com/rodacato/kenobot
```
