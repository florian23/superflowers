Feature: Metrik-Plugin-System
  Als Entwickler des Compliance Reports
  will ich neue Metriken als unabhängige Plugins hinzufügen können
  damit der Report organisch wachsen kann ohne den Core zu ändern

  @critical
  Scenario: Neue Metrik durch eine Datei hinzufügen
    Given ein funktionierender Compliance Report mit 3 Metriken
    When eine neue Metrik registriert wird
    Then wird die neue Metrik beim nächsten Report-Lauf automatisch erkannt
    And im Report angezeigt
    And es wurde maximal 1 neue Datei erstellt und 1 Registry-Eintrag geändert

  @critical
  Scenario: Bestehende Dateien bleiben unverändert bei neuer Metrik
    Given ein funktionierender Compliance Report mit 3 Metriken
    When eine neue Metrik registriert wird
    Then wurde keine bestehende Metrik-Datei oder Report-Template geändert

  @critical
  Scenario: Metrik entfernen ohne Seiteneffekte
    Given ein Compliance Report mit 4 Metriken
    When eine Metrik entfernt wird
    Then wird der Report mit den verbleibenden 3 Metriken fehlerfrei generiert
    And die Ergebnisse der verbleibenden Metriken sind unverändert

  Scenario: Jede Metrik ist unabhängig testbar
    Given eine einzelne Metrik und ein synthetisches Git-Repository
    When die Metrik isoliert ausgeführt wird
    Then liefert sie Ergebnisse ohne dass andere Metriken konfiguriert sein müssen

  @edge-case
  Scenario: Ungültige Metrik-Datei
    Given eine Metrik-Datei mit fehlendem Pflichtfeld
    When der Report generiert wird
    Then wird eine Warnung für die fehlerhafte Metrik angezeigt
    And der Report wird ohne die fehlerhafte Metrik generiert
    And andere Metriken sind nicht betroffen

  @edge-case
  Scenario: Metrik die während der Ausführung fehlschlägt
    Given eine Metrik die bei der Analyse einen Fehler produziert
    When der Report generiert wird
    Then wird der Fehler als Warnung im Report dokumentiert
    And andere Metriken werden trotzdem korrekt berechnet
