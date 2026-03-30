---
name: guardrail-integrity
description: Prüft ob Fitness Functions, BDD-Szenarien und Hard Gates inhaltlich stabil bleiben oder über die Zeit aufgeweicht werden
weight: 1.5
---

## Analysis

Diese Metrik ist der Kern des Compliance Reports. Sie prüft nicht ob Artefakte existieren, sondern ob ihr **Inhalt stabil** bleibt. Jede Änderung an einem Guardrail ist ein Signal — entweder gerechtfertigt (mit ADR) oder ein Zeichen von Erosion.

### Was sind Guardrails in diesem Kontext?

1. **Fitness Functions** — Schwellwerte und Regeln in architecture.md (z.B. "coverage >= 80%", "no circular dependencies", "single HTML file")
2. **BDD-Szenarien** — Given/When/Then Szenarien in .feature Dateien die Akzeptanzkriterien definieren
3. **Hard Gates** — HARD-GATE Blöcke in SKILL.md Dateien die nicht-verhandelbare Bedingungen definieren
4. **Quality Scenarios** — Testbare Qualitäts-Szenarien in quality-scenarios.md
5. **Style Fitness Functions** — Architektur-Stil-Invarianten in architecture.md

### Git-Commands

```bash
# Alle Änderungen an architecture.md über die Zeit
git log --all -p -- architecture.md

# Alle Änderungen an .feature Dateien mit Diff
git log --all -p -- '*.feature'

# Alle Änderungen an quality-scenarios.md
git log --all -p -- quality-scenarios.md

# Änderungen an HARD-GATE Blöcken in Skills
git log --all -p -- 'skills/*/SKILL.md'

# Spezifisch: Wurden Schwellwerte in architecture.md geändert?
# Suche nach Zeilen mit Zahlen die sich zwischen Versionen unterscheiden
git log --all -p -- architecture.md | grep '^[-+].*[0-9]'

# Spezifisch: Wurden Scenario: Zeilen entfernt?
git log --all -p -- '*.feature' | grep '^-.*Scenario'

# Spezifisch: Wurden HARD-GATE Blöcke entfernt oder aufgeweicht?
git log --all -p -- 'skills/*/SKILL.md' | grep '^[-+].*HARD-GATE\|^[-+].*Do NOT\|^[-+].*No exceptions'
```

## Checks

### 1. Fitness-Function-Beständigkeit
- **Was:** Jede Fitness Function in architecture.md wird getrackt — Schwellwert, Beschreibung, Cadence
- **Bestanden:** Fitness Function existiert unverändert seit Erstellung
- **Warnung:** Schwellwert geändert (z.B. 80% → 60%)
- **Akzeptabel:** Schwellwert verschärft (z.B. 80% → 90%) oder mit ADR begründet
- **Messung:** Diff jeder FF-Zeile zwischen Commits, kategorisiert als: unchanged | tightened | loosened | removed | added

### 2. BDD-Szenario-Beständigkeit
- **Was:** Jedes Szenario in .feature Dateien wird getrackt
- **Bestanden:** Szenario existiert unverändert seit Erstellung
- **Warnung:** Szenario entfernt oder Given/When/Then vereinfacht (weniger Assertions)
- **Akzeptabel:** Szenario erweitert (mehr Assertions) oder durch besseres ersetzt (mit begründendem Commit)
- **Messung:** Pro .feature Datei: Szenario-Anzahl, Szenario-Namen, Step-Anzahl pro Szenario — Vergleich zwischen Commits

### 3. Hard-Gate-Stabilität
- **Was:** HARD-GATE Blöcke in SKILL.md Dateien
- **Bestanden:** Hard Gate existiert unverändert
- **Warnung:** Hard Gate entfernt, abgeschwächt, oder Ausnahme hinzugefügt
- **Messung:** Textvergleich der HARD-GATE Blöcke zwischen Commits

### 4. Quality-Scenario-Beständigkeit
- **Was:** Szenarien in quality-scenarios.md mit ihren Response Measures
- **Bestanden:** Szenario und Response Measure unverändert
- **Warnung:** Response Measure gelockert (z.B. "<200ms" → "<500ms") oder Szenario entfernt
- **Akzeptabel:** Response Measure verschärft oder neues Szenario hinzugefügt

### 5. Style-FF-Beständigkeit
- **Was:** Architecture Style Fitness Functions in architecture.md
- **Bestanden:** Style FF existiert unverändert
- **Warnung:** Style FF entfernt oder Check abgeschwächt
- **Akzeptabel:** Nur bei ADR-begründetem Stil-Wechsel (Superseding)

## Scoring

Für jede Guardrail-Kategorie:
- **100%** — Alle Guardrails unverändert oder nur verschärft
- **75%** — Änderungen vorhanden, aber alle mit ADR begründet
- **50%** — Änderungen ohne ADR, aber keine Entfernungen
- **25%** — Guardrails entfernt ohne Ersatz
- **0%** — Massive Erosion — viele Guardrails aufgeweicht oder entfernt

Gesamt-Score = Gewichteter Durchschnitt aller Kategorien

## Visualization

### Im Feature-Detail
- **Guardrail Change Log:** Tabelle aller Änderungen an Guardrails im Zyklus
  - Spalten: Guardrail | Typ | Änderung | Begründung | Bewertung
  - Farbcodierung: Grün (verschärft/unverändert), Gelb (mit ADR geändert), Rot (aufgeweicht/entfernt)

### Im Trend
- **Guardrail-Bestandskurve:** Anzahl aktiver Guardrails über die Zeit (sollte monoton steigend oder stabil sein)
- **Änderungs-Heatmap:** Pro Zyklus: wieviele Guardrails geändert/entfernt/hinzugefügt
- **Stabilitäts-Score:** Prozent der Guardrails die seit Erstellung unverändert sind
- **Erosions-Timeline:** Wann wurden welche Guardrails aufgeweicht (rot markierte Punkte auf Zeitachse)
