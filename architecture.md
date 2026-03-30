# Architecture Characteristics

## Last Updated: 2026-03-30

## Top 3 Priority Characteristics
1. **Extensibility** — Neue Metriken, Prüfungen und Visualisierungen ohne Umbau der bestehenden Analyse-Pipeline hinzufügbar
2. **Usability** — Professioneller, intuitiv navigierbarer HTML-Report mit interaktiver Timeline, der zum regelmäßigen Gebrauch einlädt
3. **Portability** — Single-File HTML ohne externe Abhängigkeiten, offline-fähig, überall öffenbar

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Performance | Nice-to-have | Report-Generierung in unter 2 Minuten für Projekte mit bis zu 500 Commits (aspirational) | No | — |
| Fault Tolerance | Important | Graceful degradation bei fehlenden Artefakten (kein Crash, Warnung im Report stattdessen); unterstützt shallow clones und leere Repos | Yes - edge case tests | Atomic (commit) |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Extensibility | Critical | Neue Metrik hinzufügbar durch max. 1 neue Datei + 1 Registry-Eintrag, 0 Änderungen an bestehenden Metriken oder Report-Template (must-have) | Yes - neue Metrik darf max. 2 Dateien berühren | Atomic (commit) |
| Testability | Important | Analyse-Logik testbar mit synthetischen Git-Repos; jede Metrik unabhängig testbar; >80% Test-Coverage auf Analyse-Module (must-have) | Yes - coverage ≥80% auf src/analysis/ | Atomic (commit) |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function | Cadence |
|---------------|----------|---------------|-----------------|---------|
| Usability | Critical | Max. 3 Klicks von Landing-View zu jedem Feature-Detail; valides HTML5; responsive viewport (must-have). Professionelles visuelles Design (aspirational) | Yes - HTML-Validierung + max-click-depth check | Atomic (commit) |
| Portability | Critical | Exakt 1 HTML-Datei, 0 externe Requests, alle Assets inline (CSS, JS, Charts), funktioniert offline im Browser (must-have) | Yes - single-file + no-external-request check | Atomic (commit) |

## Architecture Drivers
- **Observability über Zeit:** Der Haupttreiber — ohne Beobachtbarkeit greifen Guardrails ins Leere weil Drift unbemerkt bleibt
- **Retroaktive Analyse:** Git als Single Source of Truth ermöglicht Analyse vergangener Feature-Zyklen ohne vorheriges Setup
- **Wachsende Metrik-Landschaft:** Die wertvollsten Metriken werden sich erst im Gebrauch herausstellen — das System muss organisch wachsen können
- **Zero-Infrastructure:** Kein Server, keine Datenbank, kein Build-System — der Report ist das Produkt

## Architecture Decisions
- **Git-Archäologie statt Event-Logging:** Retroaktiv funktionsfähig, keine Hooks nötig, Git ist die Single Source of Truth
- **Single-File HTML:** Maximale Portabilität, kein Deployment, sofort teilbar
- **Skill-basierter Aufruf:** Integration in bestehenden Claude Code Workflow via `/compliance-report`
- **Microkernel als Architektur-Stil:** Core (Skill-Orchestrierung + Report-Generator) mit Plugin-Metriken (deklarative .md Dateien im metrics/ Verzeichnis)

## Selected Architecture Style

**Style:** Microkernel
**Partitioning:** domain
**Cost Category:** $

### Selection Rationale
- Driving characteristics: Extensibility (★★★/evolvability), Simplicity (★★★★★), Testability (★★★)
- Fit score: 11/15
- Microkernel ist der natürliche Fit für ein Plugin-basiertes Analyse-Tool: Core-System (Git-Extraktor + Report-Generator + Plugin-Registry) mit austauschbaren Metrik-Plugins
- Skill-basierte Umsetzung: Core = SKILL.md, Plugins = deklarative .md Dateien im metrics/ Verzeichnis
- Service-Based (12/15) wurde verworfen weil verteilte Architekturen für ein CLI-Tool unverhältnismäßig komplex sind
- Microservices (11/15, $$$$$) und Event-Driven (9/15, $$$) aus denselben Gründen ausgeschlossen

### Tradeoffs Accepted
- Evolvability: Rated 3/5 — akzeptabel weil das Plugin-System die Evolution auf Metrik-Ebene ermöglicht, Kern-Änderungen selten nötig
- Testability: Rated 3/5 — mitigiert durch unabhängig testbare Plugins und synthetische Git-Test-Repos

### Evolution Path
- Phase 1: Core + 3 initiale Metrik-Plugins (Workflow-Compliance, Code-Impact, Architecture-Erosion)
- Phase 2: Weitere Plugins basierend auf Nutzungserfahrung (BDD-Trend, ADR-Hygiene, Hotspot-Analyse)
- Phase 3: Optional — Plugin-API formalisieren wenn Community-Beiträge gewünscht

### Architecture Style Fitness Functions

| Fitness Function | What it checks | Tool/Approach | ADR |
|---|---|---|---|
| Core-Plugin Separation | Core (SKILL.md + Report-Template) hat keine Abhängigkeit zu spezifischen Metrik-Plugins | Verzeichnis-Struktur-Check: Core referenziert nur Plugin-Interface, nie spezifische Plugins | pending |
| Plugin Interface Compliance | Alle Metrik-Dateien in metrics/ folgen dem definierten Format (Name, Description, Git-Commands, Scoring, Visualization) | Format-Validierung der .md Dateien | pending |
| Plugin Isolation | Metrik-Plugins haben keine Abhängigkeiten untereinander | Keine Cross-Referenzen zwischen metrics/*.md Dateien | pending |
| Core Stability | Core-Skill ändert sich nicht wenn neue Metriken hinzugefügt werden | Git-Diff-Check: neue Metrik-Commits berühren nur metrics/ + ggf. Registry | pending |

## Changelog
- 2026-03-30: Initial architecture assessment for Git-based Compliance & Quality Tracker
- 2026-03-30: Selected Microkernel architecture style — Core + Plugin-Metriken
