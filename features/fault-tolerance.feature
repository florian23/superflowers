Feature: Fehlertoleranz
  Als Nutzer des Compliance Reports
  will ich dass der Report auch in nicht-idealen Situationen funktioniert
  damit ich ihn in jedem Projekt nutzen kann

  Scenario Outline: Fehlende Artefakte graceful behandeln
    Given ein Git-Repository ohne <artefakt>
    When der Compliance Report generiert wird
    Then wird der Report generiert
    And enthält eine Warnung: "<warnung>"
    And verfügbare Metriken werden trotzdem berechnet

    Examples:
      | artefakt          | warnung                               |
      | architecture.md   | architecture.md nicht gefunden         |
      | .feature Dateien  | Keine Feature Files vorhanden          |
      | doc/adr/          | Kein ADR-Verzeichnis vorhanden         |

  @critical
  Scenario: Shallow Clone
    Given ein Git-Repository mit shallow clone und 50 Commits
    When der Compliance Report generiert wird
    Then wird der Report mit den verfügbaren 50 Commits generiert
    And enthält einen Hinweis zur begrenzten Historie

  Scenario: Leeres Repository
    Given ein Git-Repository mit 0 Commits
    When der Compliance Report generiert wird
    Then wird eine Meldung angezeigt dass keine Commits gefunden wurden
    And der Skill beendet sich ohne Fehler

  @edge-case
  Scenario: Korrupte Git-Historie
    Given ein Git-Repository mit nicht-lesbaren Commits
    When der Compliance Report generiert wird
    Then werden lesbare Commits normal verarbeitet
    And nicht-lesbare Commits werden übersprungen mit Warnung
