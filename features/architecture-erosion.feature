Feature: Architektur-Erosions-Erkennung
  Als Nutzer des Compliance Reports
  will ich sehen ob die Architektur-Guardrails über die Zeit stabil bleiben
  damit ich Drift und Erosion frühzeitig erkennen kann

  Background:
    Given ein Git-Repository mit Architektur-Artefakten

  @critical
  Scenario: Fitness-Function-Schwellwert-Absenkung erkennen
    Given architecture.md enthält eine Fitness Function mit Schwellwert "coverage >= 80%"
    And ein Commit ändert den Schwellwert auf "coverage >= 60%"
    When die Architektur-Erosion geprüft wird
    Then wird eine Drift-Warnung generiert: "FF-Schwellwert gesenkt ohne ADR"

  @critical
  Scenario: Entfernte BDD-Szenarien erkennen
    Given eine .feature Datei mit 5 Szenarien
    And ein Commit entfernt 2 Szenarien ohne Ersatz
    When die Architektur-Erosion geprüft wird
    Then wird eine Drift-Warnung generiert: "2 BDD-Szenarien entfernt"

  @critical
  Scenario: ADR-Hygiene prüfen
    Given 3 ADRs mit Status "Accepted" und 1 ADR mit Status "Superseded"
    And der superseded ADR hat keinen Nachfolger
    When die ADR-Hygiene geprüft wird
    Then wird eine Warnung generiert: "Superseded ADR ohne Nachfolger"

  Scenario: Fitness-Function-Verlauf als Timeline darstellen
    Given architecture.md wurde in 3 Feature-Zyklen geändert
    When der Fitness-Function-Verlauf analysiert wird
    Then enthält der Report eine Timeline der FF-Änderungen pro Zyklus

  Scenario: BDD-Szenario-Wachstum tracken
    Given .feature Dateien mit Szenarien über 5 Feature-Zyklen
    When das BDD-Wachstum analysiert wird
    Then zeigt der Report die kumulative Anzahl Szenarien pro Zyklus

  Scenario: Fitness-Function-Änderung mit ADR ist akzeptabel
    Given architecture.md enthält eine geänderte Fitness Function
    And ein zugehöriger ADR dokumentiert die Änderung
    When die Architektur-Erosion geprüft wird
    Then wird keine Drift-Warnung generiert
    And die Änderung wird als "dokumentiert" markiert
