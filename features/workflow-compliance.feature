Feature: Workflow-Compliance-Bewertung
  Als Nutzer des Compliance Reports
  will ich pro Feature-Zyklus sehen ob der vorgeschriebene Workflow eingehalten wurde
  damit ich Abweichungen vom Prozess erkennen kann

  Background:
    Given ein Git-Repository mit erkannten Feature-Zyklen

  @critical
  Scenario: Spec vor Code erkennen
    Given ein Feature-Zyklus mit Spec-Commit vor dem ersten Implementierungs-Commit
    When die Workflow-Compliance bewertet wird
    Then wird "Spec vor Code" als bestanden markiert

  @critical
  Scenario: Code vor Spec erkennen
    Given ein Feature-Zyklus bei dem der erste Implementierungs-Commit vor dem Spec-Commit liegt
    When die Workflow-Compliance bewertet wird
    Then wird "Spec vor Code" als nicht bestanden markiert
    And eine Warnung wird generiert

  @critical
  Scenario: Artefakt-Vollständigkeit prüfen
    Given ein Feature-Zyklus
    When die Artefakt-Vollständigkeit geprüft wird
    Then wird für jedes erwartete Artefakt der Status angezeigt:
      | Artefakt           | Erwartet                                    |
      | architecture.md    | Geändert oder vorhanden im Zyklus           |
      | .feature Dateien   | Mindestens eine erstellt oder geändert       |
      | quality-scenarios  | Geändert oder vorhanden                     |
      | ADR                | Mindestens ein neuer Eintrag in doc/adr/    |

  @critical
  Scenario: Compliance-Score berechnen
    Given ein Feature-Zyklus mit 4 von 5 Compliance-Prüfungen bestanden
    When der Compliance-Score berechnet wird
    Then beträgt der Score 80%

  Scenario: Artefakt-Reihenfolge prüfen
    Given ein Feature-Zyklus mit Commits in dieser Reihenfolge:
      | Reihenfolge | Artefakt        |
      | 1           | Spec            |
      | 2           | Feature Files   |
      | 3           | Implementierung |
    When die Artefakt-Reihenfolge geprüft wird
    Then wird die Reihenfolge als korrekt bewertet

  Scenario: Fehlende Artefakte in Feature ohne Spec
    Given ein Feature-Zyklus ohne Spec-Commit
    When die Workflow-Compliance bewertet wird
    Then wird "Spec vorhanden" als nicht bestanden markiert
    And der Compliance-Score sinkt entsprechend
