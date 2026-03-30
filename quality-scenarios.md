# Quality Scenarios

Generated from architecture.md quality goals using ATAM.

## Last Updated: 2026-03-30

## Scenario Summary

| ID | Characteristic | Scenario | Test Type | Priority |
|----|---------------|----------|-----------|----------|
| QS-001 | Extensibility | Neue Metrik: max. 1 neue Datei + 1 Registry-Eintrag | fitness-function | Critical |
| QS-002 | Extensibility | Neue Metrik erscheint automatisch im Report ohne Template-Änderung | integration-test | Critical |
| QS-003 | Extensibility | Entfernen einer Metrik bricht keine andere Metrik | integration-test | Critical |
| QS-004 | Usability | Landing → Feature-Detail in ≤3 Klicks | manual-review | Critical |
| QS-005 | Usability | HTML5-Validierung ohne Errors | fitness-function | Critical |
| QS-006 | Usability | Responsive: lesbar auf 1024px und 1920px | manual-review | Critical |
| QS-007 | Portability | Exakt 1 HTML-Datei, 0 externe Requests | fitness-function | Critical |
| QS-008 | Portability | Report funktioniert offline mit allen Charts | integration-test | Critical |
| QS-009 | Fault Tolerance | Repo ohne architecture.md → Warnung statt Crash | integration-test | Important |
| QS-010 | Fault Tolerance | Shallow clone → Report mit verfügbaren Daten | integration-test | Important |
| QS-011 | Fault Tolerance | Leeres Repo (0 Commits) → sinnvolle Meldung | unit-test | Important |
| QS-012 | Testability | Jede Metrik unabhängig testbar mit synthetischem Git-Repo | unit-test | Important |
| QS-013 | Performance | 500-Commit-Repo: Report in <2 Minuten | load-test | Nice-to-have |

## Test Type Distribution

| Test Type | Count | Scenarios |
|-----------|-------|-----------|
| fitness-function | 3 | QS-001, QS-005, QS-007 |
| integration-test | 5 | QS-002, QS-003, QS-008, QS-009, QS-010 |
| unit-test | 2 | QS-011, QS-012 |
| manual-review | 2 | QS-004, QS-006 |
| load-test | 1 | QS-013 |

## Scenarios

### Extensibility

#### QS-001: Neue Metrik hinzufügen — Datei-Budget
- **Characteristic:** Extensibility
- **Source:** Entwickler (Skill-Autor)
- **Stimulus:** Fügt eine neue Compliance-Metrik zum System hinzu
- **Environment:** Bestehendes System mit N Metriken
- **Artifact:** metrics/ Verzeichnis, Plugin-Registry
- **Response:** Neue Metrik ist im System registriert und wird beim nächsten Report-Lauf ausgeführt
- **Response Measure:** Max. 1 neue Datei erstellt + 1 Registry-Eintrag geändert, 0 Änderungen an bestehenden Metriken oder Core
- **Test Type:** fitness-function

#### QS-002: Neue Metrik erscheint im Report
- **Characteristic:** Extensibility
- **Source:** Skill-Lauf nach Hinzufügen einer neuen Metrik
- **Stimulus:** Report wird generiert mit N+1 Metriken
- **Environment:** Normaler Betrieb, Repo mit Feature-Zyklen
- **Artifact:** HTML-Report, Report-Generator
- **Response:** Report enthält Sektion für neue Metrik mit korrekten Daten und Visualisierung
- **Response Measure:** Neue Metrik ist im Report sichtbar ohne Änderung am HTML-Template oder Report-Generator
- **Test Type:** integration-test

#### QS-003: Metrik entfernen ohne Seiteneffekte
- **Characteristic:** Extensibility
- **Source:** Entwickler entfernt eine Metrik-Datei
- **Stimulus:** Report wird generiert mit N-1 Metriken
- **Environment:** Normaler Betrieb
- **Artifact:** Verbleibende Metriken, Report-Generator
- **Response:** Report wird fehlerfrei generiert, verbleibende Metriken sind unverändert korrekt
- **Response Measure:** 0 Fehler, 0 geänderte Ergebnisse bei verbleibenden Metriken
- **Test Type:** integration-test

### Usability

#### QS-004: Navigation — Klicktiefe
- **Characteristic:** Usability
- **Source:** User öffnet Report im Browser
- **Stimulus:** Will Details zu einem bestimmten Feature sehen
- **Environment:** Report mit 10+ Features
- **Artifact:** HTML-Report, Timeline-Navigation
- **Response:** User navigiert von Executive Summary zum Feature-Detail
- **Response Measure:** ≤3 Klicks von Landing-View zu jedem Feature-Detail
- **Test Type:** manual-review

#### QS-005: HTML5-Validierung
- **Characteristic:** Usability
- **Source:** Automatisierter CI-Check
- **Stimulus:** Generierter Report wird gegen W3C HTML5-Spezifikation validiert
- **Environment:** Jeder Commit
- **Artifact:** HTML-Report-Datei
- **Response:** Report ist valides HTML5
- **Response Measure:** 0 Validation Errors (Warnings akzeptabel)
- **Test Type:** fitness-function

#### QS-006: Responsive Design
- **Characteristic:** Usability
- **Source:** User öffnet Report auf verschiedenen Bildschirmgrößen
- **Stimulus:** Report wird auf 1024px und 1920px Viewport dargestellt
- **Environment:** Normaler Betrieb, moderner Browser
- **Artifact:** HTML-Report, CSS-Layout
- **Response:** Alle Inhalte sind lesbar, Charts skalieren, keine horizontalen Scrollbars
- **Response Measure:** Alle Sektionen sichtbar und lesbar auf beiden Viewports
- **Test Type:** manual-review

### Portability

#### QS-007: Single-File — keine externen Requests
- **Characteristic:** Portability
- **Source:** Automatisierter CI-Check
- **Stimulus:** Generierter Report wird auf externe URLs/Requests geprüft
- **Environment:** Jeder Commit
- **Artifact:** HTML-Report-Datei
- **Response:** Report ist exakt 1 Datei, enthält keine externen URL-Referenzen (CDN, API, etc.)
- **Response Measure:** 1 Datei, 0 externe HTTP/HTTPS-Referenzen in src/href/url() Attributen
- **Test Type:** fitness-function

#### QS-008: Offline-Funktionalität
- **Characteristic:** Portability
- **Source:** User öffnet Report ohne Internetverbindung
- **Stimulus:** Report wird im Browser ohne Netzwerk geöffnet
- **Environment:** Offline, moderner Browser
- **Artifact:** HTML-Report, eingebettete Charts
- **Response:** Alle Sektionen rendern korrekt, Charts sind sichtbar und interaktiv
- **Response Measure:** 0 fehlende Ressourcen, alle Charts gerendert
- **Test Type:** integration-test

### Fault Tolerance

#### QS-009: Fehlende Artefakte — Graceful Degradation
- **Characteristic:** Fault Tolerance
- **Source:** Skill-Aufruf in Repo ohne architecture.md / .feature Dateien / doc/adr/
- **Stimulus:** Report-Generierung wird gestartet
- **Environment:** Unvollständiges Repo
- **Artifact:** Report-Generator, Metrik-Plugins
- **Response:** Report wird generiert mit Warnungen für fehlende Artefakte; verfügbare Metriken werden trotzdem berechnet
- **Response Measure:** Kein Crash/Fehler, Warnung pro fehlendem Artefakt im Report sichtbar
- **Test Type:** integration-test

#### QS-010: Shallow Clone Support
- **Characteristic:** Fault Tolerance
- **Source:** Skill-Aufruf in shallow-geclontem Repo
- **Stimulus:** Report-Generierung mit begrenzter Git-Historie
- **Environment:** Shallow clone (z.B. --depth=50)
- **Artifact:** Git-Daten-Extraktor
- **Response:** Report wird mit verfügbaren Daten generiert, fehlende Historie wird als Einschränkung vermerkt
- **Response Measure:** Kein Crash, Hinweis "Shallow clone detected — history limited to N commits"
- **Test Type:** integration-test

#### QS-011: Leeres Repo
- **Characteristic:** Fault Tolerance
- **Source:** Skill-Aufruf in Repo mit 0 Commits
- **Stimulus:** Report-Generierung in leerem Repo
- **Environment:** Frisch initialisiertes Git-Repo
- **Artifact:** Git-Daten-Extraktor
- **Response:** Sinnvolle Meldung: "No commits found — nothing to analyze"
- **Response Measure:** Kein Crash, klare Fehlermeldung, Exit ohne Report-Generierung
- **Test Type:** unit-test

### Testability

#### QS-012: Unabhängige Metrik-Tests
- **Characteristic:** Testability
- **Source:** Entwickler will eine einzelne Metrik testen
- **Stimulus:** Test-Lauf für eine spezifische Metrik mit synthetischem Git-Repo
- **Environment:** Test-Umgebung mit präpariertem Git-Repo
- **Artifact:** Einzelne Metrik-Logik
- **Response:** Metrik liefert erwartete Ergebnisse unabhängig von anderen Metriken
- **Response Measure:** Metrik ist isoliert ausführbar und testbar; kein Setup anderer Metriken nötig
- **Test Type:** unit-test

### Performance

#### QS-013: Report-Generierung — Zeitbudget
- **Characteristic:** Performance
- **Source:** Skill-Aufruf in mittelgroßem Repo
- **Stimulus:** Report-Generierung für Repo mit 500 Commits und 10 Feature-Zyklen
- **Environment:** Normaler Betrieb, lokales Repo
- **Artifact:** Gesamter Analyse- und Generierungsprozess
- **Response:** Report wird vollständig generiert
- **Response Measure:** Gesamtdauer <2 Minuten (aspirational)
- **Test Type:** load-test

## Tradeoffs and Sensitivity Points

### Tradeoff: Portability vs. Dateigröße
- **Tension:** Portability (QS-007, QS-008) vs. Usability (QS-004 — große Datei = langsamer)
- **Scenarios affected:** QS-007, QS-008, QS-004
- **Decision:** Portability gewinnt — Chart.js inline (~200KB) ist akzeptabel. Bei >1MB Report: Warnung im Skill-Output.

### Sensitivity Point: Anzahl Feature-Zyklen
- **Parameter:** Anzahl analysierter Features
- **Affects:** QS-013 (mehr Features = mehr Git-Commands = längere Generierung), QS-004 (mehr Features = längere Timeline)
- **Current setting:** Alle Features im Repo (kein Limit, ggf. --since Filter)
