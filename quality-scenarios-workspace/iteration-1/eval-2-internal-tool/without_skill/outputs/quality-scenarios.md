# Quality Scenarios

## Kontext
Internes Tool, 2 Entwickler, Modular Monolith.

---

## QS-1: Simplicity — Onboarding neuer Entwickler

| Feld | Beschreibung |
|---|---|
| **Quelle** | Neuer Entwickler |
| **Stimulus** | Erhaelt Zugang zum Repository und Projektdokumentation |
| **Artefakt** | Gesamtes System (Codebase, Build, lokale Umgebung) |
| **Umgebung** | Entwicklungsumgebung, erster Arbeitstag |
| **Antwort** | Entwickler kann lokale Umgebung aufsetzen, Tests ausfuehren und ersten Bug-Fix committen |
| **Antwortmetrik** | Innerhalb von 5 Arbeitstagen produktiv (erster eigenstaendiger Commit) |
| **Prioritaet** | Critical |
| **Automatisierbar** | Nein |

---

## QS-2: Testability — Modulunabhaengige Tests

| Feld | Beschreibung |
|---|---|
| **Quelle** | CI-Pipeline |
| **Stimulus** | Entwickler pusht Code-Aenderung in einem Modul |
| **Artefakt** | Betroffenes Modul |
| **Umgebung** | CI-Umgebung, normaler Betrieb |
| **Antwort** | Unit-Tests des Moduls laufen ohne andere Module zu starten |
| **Antwortmetrik** | >90% Line Coverage pro Modul, Test-Suite laeuft in <30 Sekunden |
| **Prioritaet** | Critical |
| **Automatisierbar** | Ja — Coverage-Report in CI (atomar, bei jedem Push) |

---

## QS-3: Maintainability — Funktionslaenge und Komplexitaet

| Feld | Beschreibung |
|---|---|
| **Quelle** | Statische Code-Analyse |
| **Stimulus** | Entwickler oeffnet Pull Request |
| **Artefakt** | Alle geaenderten Dateien |
| **Umgebung** | CI-Pipeline, PR-Check |
| **Antwort** | Build schlaegt fehl, wenn Funktion >50 Zeilen oder zyklomatische Komplexitaet >=10 |
| **Antwortmetrik** | 0 Verletzungen in geaendertem Code |
| **Prioritaet** | Critical |
| **Automatisierbar** | Ja — Linter-Rule in CI (atomar, bei jedem PR) |

---

## QS-4: Security — RBAC-Zugriffskontrolle

| Feld | Beschreibung |
|---|---|
| **Quelle** | Authentifizierter Benutzer ohne passende Rolle |
| **Stimulus** | Versucht auf geschuetzte Ressource zuzugreifen |
| **Artefakt** | API-Endpunkt / Modul-Schnittstelle |
| **Umgebung** | Laufendes System, normaler Betrieb |
| **Antwort** | Zugriff wird verweigert (HTTP 403), Versuch wird im Audit-Log protokolliert |
| **Antwortmetrik** | 100% der geschuetzten Endpunkte pruefen Rollen; jeder abgelehnte Zugriff erzeugt Audit-Eintrag |
| **Prioritaet** | Important |
| **Automatisierbar** | Ja — Integrationstest gegen alle geschuetzten Routen (atomar, bei jedem Push) |

---

## QS-5: Security — Audit-Log fuer Datenzugriff

| Feld | Beschreibung |
|---|---|
| **Quelle** | Beliebiger Benutzer |
| **Stimulus** | Liest oder aendert personenbezogene oder geschaeftskritische Daten |
| **Artefakt** | Audit-Log-Modul |
| **Umgebung** | Laufendes System, normaler Betrieb |
| **Antwort** | Audit-Eintrag wird geschrieben mit Benutzer-ID, Zeitstempel, Aktion, betroffene Ressource |
| **Antwortmetrik** | 100% der datenveraendernden Operationen erzeugen einen Audit-Eintrag |
| **Prioritaet** | Important |
| **Automatisierbar** | Ja — Test prueft Audit-Eintraege nach definierten Operationen (atomar) |
