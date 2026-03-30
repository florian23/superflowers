Feature: Code-Impact-Analyse
  Als Nutzer des Compliance Reports
  will ich sehen welchen Impact ein Feature auf die Codebasis hat
  damit ich erkennen kann ob Features sauber isoliert sind oder tief in bestehenden Code eingreifen

  Background:
    Given ein Git-Repository mit erkannten Feature-Zyklen

  @critical
  Scenario: Dateien pro Feature zählen
    Given ein Feature-Zyklus mit 3 neuen und 2 geänderten Dateien
    When die Code-Impact-Analyse läuft
    Then zeigt der Report 3 neue Dateien
    And 2 geänderte Dateien

  @critical
  Scenario: Lines added und removed erfassen
    Given ein Feature-Zyklus mit 150 hinzugefügten und 30 entfernten Zeilen
    When die Code-Impact-Analyse läuft
    Then zeigt der Report 150 hinzugefügte Zeilen
    And 30 entfernte Zeilen

  @critical
  Scenario: Churn-Ratio berechnen
    Given ein Feature-Zyklus mit 100 geänderten Zeilen in bestehenden Dateien
    And 200 neuen Zeilen in neuen Dateien
    When die Churn-Ratio berechnet wird
    Then beträgt die Churn-Ratio 0.33
    And sie wird als "niedrig" eingestuft

  Scenario: Betroffene Verzeichnisse als Blast Radius anzeigen
    Given ein Feature-Zyklus der Dateien in 3 verschiedenen Verzeichnissen ändert
    When die Code-Impact-Analyse läuft
    Then werden alle 3 betroffenen Verzeichnisse aufgelistet

  Scenario: Hotspot-Dateien erkennen
    Given Dateien die in mehreren Feature-Zyklen geändert wurden
    When die Hotspot-Analyse läuft
    Then werden Dateien die in 3 oder mehr Zyklen geändert wurden als Hotspots markiert
