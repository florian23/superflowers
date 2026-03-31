# Design: Review Agents für die superflowers Pipeline

## Datum: 2026-03-31

## Problem

Agents neigen dazu ihre eigene Arbeit zu loben. Aktuell haben nur 3 von 13 kritischen Steps in der Pipeline einen frischen Review-Agent. Die Eval-Ergebnisse zeigen +41% durchschnittliches Delta durch Skills — aber ohne unabhängige Reviews könnte Qualität trotzdem driften.

## Lösung

Spezialisierte Review-Agents als `.md` Dateien im `agents/` Verzeichnis, die von Skills nach kritischen Steps dispatcht werden. Iterativer Loop bis "Approved".

## Pattern (aus subagent-driven-development übernommen)

```
Skill macht Arbeit
  → Dispatch Reviewer-Agent (frisch, kein Kontext vom Original)
  → Reviewer: ❌ Issues gefunden
  → Skill iteriert (fixt die Issues)
  → Dispatch Reviewer-Agent erneut (frisch)
  → Reviewer: ✅ Approved
  → Weiter zum nächsten Step
```

Reviewer-Agents leben als `.md` Dateien in `agents/` und werden über das Agent Tool dispatcht. Sie sind keine eigenständigen Skills.

**Alle Reviewer-Agents leben in `agents/`** — auch die bestehenden die aktuell innerhalb von Skills liegen (z.B. `skills/architecture-assessment/architecture-reviewer-prompt.md`). Diese werden nach `agents/` verschoben. Skills verweisen auf `agents/<name>.md` statt eigene Prompt-Dateien zu halten. Ein Ort, eine Konvention.

## Max-Iterations-Schutz

Der iterative Review-Loop hat ein Limit:
- **Max 3 Iterationen** pro Reviewer
- Nach 3 gescheiterten Iterationen: **Eskalation an den User**
- Der User entscheidet: weiter iterieren, Reviewer-Feedback überstimmen, oder Arbeit abbrechen

```
Iteration 1: Reviewer → ISSUES_FOUND → Skill fixt
Iteration 2: Reviewer → ISSUES_FOUND → Skill fixt
Iteration 3: Reviewer → ISSUES_FOUND → ESKALATION AN USER
  User: "Weiter iterieren" | "Reviewer überstimmen" | "Abbrechen"
```

## Übergreifendes Immutabilitäts-Prinzip

Alle Reviewer-Agents prüfen neben ihren fachlichen Kriterien auch das **Immutabilitäts-Prinzip**:

> Bestehende Artefakte (Quality Scenarios, .feature Dateien, Fitness Functions) dürfen nicht stillschweigend geändert oder überschrieben werden. Die bevorzugte Lösung ist immer: **neue Tests/Szenarien/FFs hinzufügen**, nicht bestehende ändern.

Wenn ein Agent bestehende Artefakte ändern will:
1. Reviewer erkennt die Änderung → Status: **CHANGE_REQUIRES_APPROVAL**
2. Reviewer präsentiert dem User: Was wird geändert? Warum? Was war vorher?
3. **4-Augen-Prinzip:** User muss die Änderung explizit genehmigen
4. Erst nach Genehmigung darf der Agent die Änderung durchführen
5. Bei Fitness Functions: Änderung muss zusätzlich durch ADR begründet sein

Reviewer-Output-Status:
- **APPROVED** — alles korrekt, keine Änderungen an Bestehendem
- **ISSUES_FOUND** — fachliche Probleme, Agent soll iterieren
- **CHANGE_REQUIRES_APPROVAL** — Änderung an bestehendem Artefakt erkannt, User-Genehmigung erforderlich

## Die 11 Reviewer-Agents

### Kategorie A: Neue Agents (kein Review vorhanden)

#### 1. agents/constraint-reviewer.md
**Aufgerufen von:** constraint-selection (nach Step 4: User-Bestätigung)
**Prüft:**
- Missed constraints: Gibt es Projekt-Constraints die hätten selektiert werden sollen?
- False inclusions: Ist ein selektierter Constraint irrelevant für das Feature?
- Exclusion reasons: Sind die Ausschluss-Begründungen korrekt?
- Process constraints: Sind sie als Uncertain markiert, nicht als Relevant?
**Input:** Approved design, selektierte + ausgeschlossene Constraints, Constraint-Repo-Pfad
**Output:** APPROVED | ISSUES_FOUND (mit konkreten Punkten)

#### 2. agents/project-constraint-reviewer.md
**Aufgerufen von:** project-constraints (nach Step 4: Präsentation an User)
**Prüft:**
- Projekt-Profil korrekt? Stimmt die Tech-Stack-Analyse mit dem tatsächlichen Code überein?
- Missed matches: Gibt es Constraints im Repo deren applies_to zum Projekt passt aber nicht selektiert wurden?
- Over-inclusion: Wurden Constraints inkludiert die nicht zum Projekt passen?
- Process/Infra constraints als Uncertain markiert?
**Input:** Projekt-Profil, selektierte + ausgeschlossene Constraints, Projekt-Code, Constraint-Repo
**Output:** APPROVED | ISSUES_FOUND

#### 3. agents/quality-scenario-reviewer.md
**Aufgerufen von:** quality-scenarios (nach Step 5: Szenarien erstellt)
**Prüft:**
- Coverage: Hat jede Charakteristik aus architecture.md mindestens ein Szenario?
- Constraint-Coverage: Hat jedes Constraint-Prüfkriterium ein Szenario?
- Test-Typ-Korrektheit: Passt der zugewiesene Test-Typ zum Szenario?
- Test-Typ-Diversität: Nicht alles integration-tests?
- Tradeoffs identifiziert: Gibt es offensichtliche Konflikte die fehlen?
- Response Measures: Sind alle konkret und messbar?
- **Duplikat-Check:** Gibt es Szenarien die inhaltlich identisch oder redundant zu bestehenden quality-scenarios.md Einträgen sind?
- **Widerspruchs-Check:** Widersprechen neue Szenarien bestehenden (z.B. unterschiedliche Response Measures für die gleiche Charakteristik)?
- **Immutabilitäts-Check:** Werden bestehende Szenarien geändert oder überschrieben? Falls ja: STOPP — Änderungen an bestehenden Szenarien erfordern explizite User-Genehmigung (4-Augen-Prinzip)
**Input:** architecture.md, active constraints, quality-scenarios.md (bestehend + neu)
**Output:** APPROVED | ISSUES_FOUND | CHANGE_REQUIRES_APPROVAL (bei Änderungen an Bestehendem)

#### 4. agents/bdd-step-reviewer.md
**Aufgerufen von:** bdd-testing (nach Step Definition Implementation)
**Prüft ausschließlich Step-Definition-Qualität:**
- Steps sind thin glue (keine Business-Logik in Steps)
- Keine hardcoded Werte in Steps
- Steps delegieren an echten Application Code
- Keine Mock-Behavior die echte Logik simuliert
- **Immutabilitäts-Check:** Werden bestehende Step Definitions geändert? Falls ja: CHANGE_REQUIRES_APPROVAL
**Input:** Step-Definition-Code (bestehend + neu)
**Output:** APPROVED | ISSUES_FOUND | CHANGE_REQUIRES_APPROVAL

#### 4b. agents/feature-file-reviewer.md
**Aufgerufen von:** feature-design (nach Szenario-Erstellung) UND bdd-testing (bei .feature-Änderungen)
**Prüft ausschließlich .feature-Datei-Integrität:**
- **Duplikat-Check:** Gibt es neue Szenarien die inhaltlich identisch zu bestehenden .feature Szenarien sind?
- **Widerspruchs-Check:** Widersprechen neue Szenarien bestehenden (z.B. gleicher Given/When mit unterschiedlichem Then)?
- **Immutabilitäts-Check:** Werden bestehende .feature Dateien geändert? Falls ja: STOPP → CHANGE_REQUIRES_APPROVAL. Neue Szenarien hinzufügen ist bevorzugt gegenüber bestehende zu ändern.
- Constraint-Szenarien: Hat jeder aktive Constraint mindestens ein BDD-Szenario?
- Constraint-Tags: Sind @constraint-SEC-001 etc. Tags vorhanden?
**Input:** .feature Dateien (bestehend + neu), active constraints
**Output:** APPROVED | ISSUES_FOUND | CHANGE_REQUIRES_APPROVAL

#### 5. agents/fitness-function-reviewer.md
**Aufgerufen von:** fitness-functions (nach FF-Implementation)
**Prüft:**
- FFs testen Architektur, nicht Implementation Details
- Thresholds stimmen mit architecture.md Zielen überein
- Cadence ist korrekt zugewiesen (Atomic/Holistic/Nightly)
- Style-FFs decken die Stil-Invarianten ab
- Constraint-bezogene FFs decken die Prüfkriterien ab
- **Duplikat-Check:** Gibt es neue FFs die inhaltlich dasselbe prüfen wie bestehende?
- **Widerspruchs-Check:** Widersprechen neue FF-Thresholds bestehenden (z.B. Coverage 80% vs 90% für dieselbe Characteristic)?
- **Immutabilitäts-Check:** Werden bestehende Fitness Functions geändert (Thresholds gesenkt, Checks entfernt)? Falls ja: STOPP — Änderungen an bestehenden FFs erfordern explizite User-Genehmigung (4-Augen-Prinzip). Bestehende FFs dürfen nur durch ADR-begründete Superseding-Entscheidung geändert werden.
**Input:** architecture.md (bestehend + neu), active constraints, FF-Code (bestehend + neu)
**Output:** APPROVED | ISSUES_FOUND | CHANGE_REQUIRES_APPROVAL

### Kategorie B: Bestehende Reviewer nach `agents/` verschieben und erweitern

Bestehende Reviewer-Prompts werden aus den Skills nach `agents/` verschoben und um Constraint-Awareness erweitert. Skills verweisen dann auf `agents/<name>.md`.

#### 6. agents/architecture-reviewer.md (verschieben + erweitern)
**Bisher in:** skills/architecture-assessment/architecture-reviewer-prompt.md → **verschoben nach** agents/
**Bestehende Checks** bleiben (Completeness, Consistency, Stability, Measurability)
**Zusätzlich prüfen:**
- Constraint-Alignment: Sind aktive Constraints in den Charakteristiken reflektiert?
- Security-Constraints → Security Characteristic elevated?
- Compliance-Constraints → Compliance Characteristic vorhanden?
- Constraint-Tabelle in architecture.md vorhanden?

#### 7. → abgedeckt durch agents/feature-file-reviewer.md (4b)
Feature-File-Review ist jetzt ein eigener Agent (4b) der von feature-design UND bdd-testing aufgerufen wird. Die bestehenden inline-Reviews in feature-design/SKILL.md verweisen auf diesen Agent.

#### 8. agents/plan-reviewer.md (verschieben + erweitern)
**Bisher in:** skills/writing-plans/plan-document-reviewer-prompt.md → **verschoben nach** agents/
**Bestehende Checks** bleiben (Completeness, Spec alignment, Task decomposition, Buildability)
**Zusätzlich prüfen:**
- Active Constraints im Plan-Header gelistet?
- Constraint-Compliance-Tasks im Plan vorhanden?
- BDD Step-Definition-Tasks für Constraint-Szenarien?

#### 9. agents/spec-reviewer.md (verschieben + erweitern)
**Bisher in:** skills/brainstorming/spec-document-reviewer-prompt.md → **verschoben nach** agents/
**Bestehende Checks** bleiben (Completeness, Consistency, Clarity, Scope, YAGNI)
**Zusätzlich prüfen:**
- Constraint-Section in der Spec vorhanden?
- Referenziert die Spec die aktive Constraints-Datei?
- Sind Constraint-Anforderungen in der Spec adressiert?

### Kategorie C: Neue Agents für kritische Lücken

#### 10. agents/architecture-style-reviewer.md
**Aufgerufen von:** architecture-style-selection (nach Stil-Wahl)
**Prüft:**
- Wurden alle 8 Stile gegen die Top-3 Charakteristiken bewertet?
- Ist der gewählte Stil der mit dem besten Fit-Score?
- Sind die Tradeoffs dokumentiert?
- Sind die Style-Fitness-Functions vollständig?
- Stimmt die Stil-Wahl mit den Constraint-Anforderungen überein?
- **Immutabilitäts-Check:** Wenn architecture.md bereits einen "Selected Architecture Style" hat — wird der Stil geändert? Falls ja: CHANGE_REQUIRES_APPROVAL. Ein Stil-Wechsel hat massive Auswirkungen (alle Style-FFs ändern sich, Quality Scenarios betroffen) und muss per ADR dokumentiert werden.
**Input:** architecture.md (bestehend + neu), active constraints
**Output:** APPROVED | ISSUES_FOUND | CHANGE_REQUIRES_APPROVAL

#### 11. agents/completion-verifier.md
**Aufgerufen von:** verification-before-completion (als finaler Check)
**Prüft:**
- Alle Verifikations-Commands frisch ausführen (nicht aus Cache/Memory)
- Constraint-Prüfkriterien: Jedes einzeln prüfen
- BDD: Alle .feature Files bestehen?
- Fitness Functions: Alle bestehen?
- Plan-Requirements: Jeder Task abgehakt?
**Input:** Implementierungsplan, active constraints, architecture.md, .feature files
**Output:** APPROVED | BLOCKED (mit konkreten Failures)

## Integration in die Skills

Jeder Skill der einen Reviewer-Agent nutzt, bekommt:
1. Einen neuen Step im Flowchart: "Dispatch Reviewer → Loop until Approved"
2. Einen Verweis auf die Agent-Datei
3. Die Information welche Inputs der Reviewer bekommt

## Verzeichnisstruktur nach Implementation

Alle Reviewer-Agents an einem Ort:

```
agents/
├── code-reviewer.md                    # Bestehend (unverändert)
├── constraint-reviewer.md              # Neu (Gap 1)
├── project-constraint-reviewer.md      # Neu (Gap 2)
├── quality-scenario-reviewer.md        # Neu (Gap 3)
├── bdd-step-reviewer.md                # Neu (Gap 4)
├── feature-file-reviewer.md            # Neu (Gap 4b, ersetzt Gap 7)
├── fitness-function-reviewer.md        # Neu (Gap 5)
├── architecture-reviewer.md            # Verschoben + erweitert (Gap 6)
├── plan-reviewer.md                    # Verschoben + erweitert (Gap 8)
├── spec-reviewer.md                    # Verschoben + erweitert (Gap 9)
├── architecture-style-reviewer.md      # Neu (Gap 10)
└── completion-verifier.md              # Neu (Gap 11)
```

8 neue Agent-Dateien + 3 bestehende verschoben und erweitert = 12 Agents total (inkl. code-reviewer).

## Implementierungsreihenfolge

Nach Risiko priorisiert (höchstes Risiko zuerst):

1. **completion-verifier** (Gap 11) — Agent prüft sich selbst = höchstes Risiko
2. **constraint-reviewer** (Gap 1) — Falsche Constraint-Selektion cascadiert durch gesamte Pipeline
3. **architecture-style-reviewer** (Gap 10) — Falscher Stil treibt alles Nachfolgende
4. **quality-scenario-reviewer** (Gap 3) — Fehlende Szenarien = fehlende Tests
5. **architecture-reviewer erweitern** (Gap 6) — Constraints in Architektur
6. **feature-design erweitern** (Gap 7) — Constraint-Szenarien
7. **project-constraint-reviewer** (Gap 2) — Projekt-Setup
8. **plan-reviewer erweitern** (Gap 8) — Constraint-Tasks im Plan
9. **spec-reviewer erweitern** (Gap 9) — Constraint-Section in Spec
10. **fitness-function-reviewer** (Gap 5) — FF-Qualität
11. **bdd-step-reviewer** (Gap 4) — Step-Definition-Qualität
