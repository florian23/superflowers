---
name: project-constraints
description: Use when setting up a new project's constraint baseline, or when the user explicitly asks to review/update project constraints against the organizational constraint repository. Reads project context (code, tech stack, artefacts) to intelligently pre-select relevant constraints.
---

# Project Constraints

Select and maintain which organizational constraints apply to this project. Reads the project context (code, tech stack, architecture, data handling) and matches it against the constraint repository to recommend relevant constraints.

**Announce at start:** "I'm reviewing project constraints against the organizational constraint repository."

## Two Modes

### Mode 1: Initial Setup (constraints/ doesn't exist)

Triggered when `constraint-selection` detects that `constraints_repo` is configured but `constraints/` is missing. Or when the user explicitly runs this skill on a new project.

### Mode 2: Review/Update (constraints/ exists)

Triggered only when the user explicitly asks to review or update project constraints. Checks:
- Are there new constraints in the repo that might apply?
- Has the project context changed (new tech, new data types, new APIs)?
- Are any current project constraints no longer relevant?

## Prerequisites

CLAUDE.md must contain:

```markdown
constraints_repo: /path/to/company-constraints
```

If not configured, inform the user how to set it up and stop.

## Process Flow

```dot
digraph project_constraints {
  start [shape=ellipse, label="Start"];
  check_repo [shape=diamond, label="constraints_repo\nin CLAUDE.md?"];
  inform_setup [shape=box, label="Inform user:\nhow to configure"];
  check_existing [shape=diamond, label="constraints/\nexists?"];

  analyze_project [label="Analyze project context\n(code, stack, artefacts)"];
  read_repo [label="Read all constraints\nfrom repo"];
  match [label="Match constraints\nagainst project context"];
  present_initial [label="Present recommended\nconstraints to user"];

  read_current [label="Read current\nconstraints/ files"];
  diff [label="Diff: repo changes,\nproject context changes"];
  present_update [label="Present changes\nto user"];

  user_ok [shape=diamond, label="User\napproves?"];
  write [label="Write/update\nconstraints/ files"];
  done [shape=doublecircle, label="Done"];

  start -> check_repo;
  check_repo -> inform_setup [label="no"];
  check_repo -> check_existing [label="yes"];
  inform_setup -> done;

  check_existing -> analyze_project [label="no (initial)"];
  check_existing -> read_current [label="yes (review)"];

  analyze_project -> read_repo;
  read_repo -> match;
  match -> present_initial;
  present_initial -> user_ok;

  read_current -> analyze_project [label="then"];
  read_current -> diff;
  diff -> present_update;
  present_update -> user_ok;

  user_ok -> write [label="yes"];
  user_ok -> match [label="revise"];
  write -> done;
}
```

## Step 1: Analyze Project Context

Read the project to understand what it does and what it uses. Check:

- **Language/Framework:** `package.json`, `pom.xml`, `build.gradle`, `pyproject.toml`, `go.mod`, `Cargo.toml` etc.
- **Data storage:** Database configs, ORM setup, migration files
- **APIs:** REST controllers, gRPC definitions, OpenAPI specs, route files
- **Personal data:** User models, PII fields, GDPR-related code
- **Security:** Auth middleware, JWT handling, encryption code
- **Deployment:** Dockerfiles, CI/CD configs, Kubernetes manifests
- **Existing artefacts:** `architecture.md`, `context-map.md`, `quality-scenarios.md`, `doc/adr/`

Build a **project profile** — a mental model of what this project is:

> "This is a Spring Boot web service with PostgreSQL, processing user data including email and payment info, deployed via Docker on Kubernetes. It has REST APIs with JWT authentication."

## Step 2: Read Constraint Repository

Read all `.md` files in the constraint repo (recursively). For each constraint, extract what you can:
- Name/ID (from frontmatter or first heading)
- Category (from frontmatter, directory name, or content)
- Severity (mandatory/recommended/optional — default: recommended)
- Applies-to tags (from frontmatter, if present)
- Core requirement summary

The repo has no fixed structure — handle flat files, nested directories, with or without frontmatter.

## Step 3: Match Constraints Against Project Context

For each constraint, assess relevance based on the project profile:

- **Data storage constraints** → relevant if project has DB/file storage
- **API/security constraints** → relevant if project exposes endpoints
- **PII/compliance constraints** → relevant if project handles personal data
- **Technology constraints** → relevant if project uses the specified tech area
- **Process constraints** → relevant based on deployment target (production vs. internal tool)
- **Infrastructure constraints** → relevant if project manages its own infra

Categorize each constraint as:
- **Relevant** — project context clearly matches constraint's domain
- **Not relevant** — project context doesn't match (with reason)
- **Uncertain** — could go either way, present to user for decision

**Process and infrastructure constraints** (deployment procedures, network setup, CI/CD rules) are almost always **Uncertain** unless the project context makes the match obvious. Do NOT auto-classify them as Relevant — the user must decide.

A constraint's `severity: mandatory` means it's mandatory **when it applies** — not that it applies to every project. A mandatory encryption constraint is irrelevant for a project that doesn't store data.

<HARD-GATE>
Do NOT write or create the constraints/ directory without presenting the full
selection to the user and receiving explicit confirmation. "Soll ich die
Projekt-Constraints so anlegen?" — then WAIT for the answer.
This applies in both Initial Setup and Review/Update mode.
</HARD-GATE>

## Step 4: Present to User

### Initial Setup Mode

> **Projekt-Profil:**
> Spring Boot Webservice, PostgreSQL, User-Daten mit PII, REST APIs, Docker/K8s Deployment
>
> **Empfohlene Constraints für dieses Projekt:**
>
> | Constraint | Kategorie | Severity | Grund |
> |---|---|---|---|
> | SEC-001 Encryption at Rest | Security | Mandatory | Projekt hat PostgreSQL |
> | SEC-002 API Authentication | Security | Mandatory | Projekt hat REST APIs |
> | COMP-001 GDPR Data Retention | Compliance | Mandatory | Projekt verarbeitet PII |
> | TECH-001 Spring Boot | Technology | Recommended | Projekt nutzt Spring Boot |
>
> **Nicht relevant:**
> - SEC-003 Network Segmentation — Infra wird separat gehandhabt
>
> **Unsicher (bitte entscheiden):**
> - PROC-001 Four-Eyes — Geht das Projekt in Produktion?
>
> Soll ich die Projekt-Constraints so anlegen?

### Review/Update Mode

> **Änderungen seit letztem Review:**
>
> **Neue Constraints im Repo:**
> - SEC-004 Container Scanning — Relevant? (Projekt nutzt Docker)
>
> **Projekt-Kontext geändert:**
> - Neues Feature mit Zahlungsdaten → COMP-003 PCI-DSS jetzt relevant?
>
> **Bestehende Constraints weiterhin relevant:** ✓ alle aktuell
>
> Soll ich die Projekt-Constraints aktualisieren?

Wait for user confirmation before writing.

## Step 5: Write constraints/ Files

Create or update `constraints/` directory with one `.md` per category:

```markdown
# Security Constraints

## Aktiv

- **SEC-001**: Encryption at Rest — Alle Daten verschlüsselt speichern
- **SEC-002**: API Authentication — OAuth 2.0 / JWT für alle Endpunkte

## Nicht relevant für dieses Projekt

- **SEC-003**: Network Segmentation — Infra wird vom Plattform-Team gehandhabt
```

Group by category (security, compliance, technology, process, etc.). Include exclusions with reasons.

Commit the files.

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "It's mandatory, so it applies" | Mandatory means mandatory **when the domain matches**. A mandatory encryption rule doesn't apply to a project that stores nothing. |
| "Better safe than include it" | Over-including constraints creates noise and wastes effort. Exclude what doesn't apply, mark uncertain ones for user decision. |
| "I'll just write the files, user can review later" | User confirmation BEFORE writing is a HARD-GATE. Presenting after the fact is not confirmation. |
| "Process constraints always apply to production projects" | Process constraints depend on deployment target, team structure, and org context — only the user knows these. Mark as Uncertain. |
| "The project profile is obvious, I'll skip it" | Present the profile explicitly. The user must see what YOU understood about the project to verify your constraint matching is based on correct assumptions. |

## Red Flags — STOP

- Writing constraints/ without user confirmation
- Classifying all mandatory constraints as Relevant regardless of project match
- Skipping the Uncertain category — if you have 0 uncertain constraints, you're over-confident
- Not presenting a project profile — constraint matching is only as good as the context analysis

## Integration

**Triggered by:** User explicitly, or recommended by `constraint-selection` when `constraints/` is missing
**Produces:** `constraints/*.md` files in the project
**Read by:** `constraint-selection` (which then selects per-feature constraints)
**Reads:** CLAUDE.md (repo path), all project files (context), constraint repo (all constraints)
