Feature: Coding Eval — FeatureBench-basierte Skill-Evaluation
  Als Entwickler von superflowers
  will ich automatisiert messen ob die Skills bessere Feature-Implementierungen produzieren
  damit ich den Mehrwert des Frameworks quantifizieren kann

  Background:
    Given ein konfigurierter Coding-Eval Skill

  @critical
  Scenario: Vollautomatischer Eval-Durchlauf für einen Task
    Given ein FeatureBench Task mit Repo, Base-Commit und Test-Suite
    When der Eval-Skill mit diesem Task aufgerufen wird
    Then wird das Repo auf den Base-Commit geklont
    And ein Subagent implementiert das Feature ohne superflowers Skills
    And ein Subagent implementiert das Feature mit superflowers Skills
    And die Test-Suite wird gegen beide Lösungen ausgeführt
    And ein Vergleichs-Report wird generiert

  @critical
  Scenario: Without-Skill Subagent arbeitet ohne superflowers
    Given ein FeatureBench Task
    When der Without-Skill Subagent gestartet wird
    Then erhält der Agent nur das Problem Statement und den Repo-Zugang
    And der Agent hat keinen Zugriff auf superflowers Skills
    And der Agent implementiert das Feature direkt

  @critical
  Scenario: With-Skill Subagent nutzt vollen superflowers Workflow
    Given ein FeatureBench Task
    When der With-Skill Subagent gestartet wird
    Then durchläuft der Agent den superflowers Workflow
    And erzeugt Spezifikations-Artefakte vor der Implementierung

  @critical
  Scenario: Docker-basierte Test-Ausführung
    Given eine Agent-Lösung im Repo
    When die Tests ausgeführt werden
    Then werden die FAIL_TO_PASS Tests im FeatureBench Docker-Container ausgeführt
    And werden die PASS_TO_PASS Tests geprüft
    And das Ergebnis wird als Resolved/Partial/Failed klassifiziert

  @critical
  Scenario: Vergleichs-Report mit Hard und Soft Metriken
    Given Ergebnisse für with_skill und without_skill
    When der Report generiert wird
    Then enthält er Hard Metriken pro Task (Tests bestanden: Resolved/Partial/Failed)
    And Soft Metriken pro Task (Artefakte erzeugt, Code-Qualität)
    And einen Gesamtvergleich über alle Tasks

  Scenario: Mehrere Tasks in einem Durchlauf
    Given 3 konfigurierte FeatureBench Tasks
    When der Eval-Skill mit --all aufgerufen wird
    Then werden alle 3 Tasks sequenziell evaluiert
    And der Gesamt-Report enthält alle 3 Tasks

  Scenario: Task-Vorbereitung aus FeatureBench Dataset
    Given Zugriff auf das FeatureBench HuggingFace Dataset
    When ein Task vorbereitet wird
    Then wird das Problem Statement als task.md extrahiert
    And die Test-Dateien werden gespeichert
    And das Repo wird auf den Base-Commit geklont

  @edge-case
  Scenario: Subagent schlägt fehl oder läuft in Timeout
    Given ein Task bei dem der Subagent nicht terminiert
    When der Timeout erreicht wird
    Then wird der Subagent abgebrochen
    And das Ergebnis wird als "Timeout" markiert
    And der nächste Task wird fortgesetzt

  @edge-case
  Scenario: Docker-Container für Task nicht verfügbar
    Given ein Task dessen Docker-Image nicht gepullt werden kann
    When die Tests ausgeführt werden sollen
    Then wird eine Warnung generiert
    And der Task wird als "Nicht auswertbar" markiert
