Feature: Skill-Aufruf und Filterung
  Als Nutzer
  will ich den Compliance Report als Skill im Claude Code aufrufen können
  damit er in meinen bestehenden Workflow integriert ist

  @critical
  Scenario: Vollständigen Report generieren
    Given ein Git-Repository mit Feature-Zyklen
    When der Skill ohne Parameter aufgerufen wird
    Then wird ein vollständiger Report über alle Feature-Zyklen generiert
    And die Report-Datei wird unter docs/superflowers/reports/ gespeichert

  Scenario: Report für ein spezifisches Feature
    Given ein Git-Repository mit den Feature-Zyklen "auth", "payment" und "search"
    When der Skill mit Parameter "--feature=payment" aufgerufen wird
    Then enthält der Report nur den Feature-Zyklus "payment"
    And der Trend zeigt dennoch den Kontext aller Features

  Scenario: Report ab einem bestimmten Datum
    Given ein Git-Repository mit Commits von Januar bis März
    When der Skill mit Parameter "--since=2026-03-01" aufgerufen wird
    Then enthält der Report nur Feature-Zyklen ab März

  Scenario: Report-Datei mit Datum im Namen
    Given ein Compliance Report wird am 2026-03-30 generiert
    When der Report gespeichert wird
    Then lautet der Dateiname "2026-03-30-compliance-report.html"

  @edge-case
  Scenario: Unbekanntes Feature als Parameter
    Given ein Git-Repository ohne Feature-Zyklus "nonexistent"
    When der Skill mit Parameter "--feature=nonexistent" aufgerufen wird
    Then wird eine Meldung angezeigt dass kein Feature mit diesem Namen gefunden wurde

  @edge-case
  Scenario: Ungültiges Datum als Parameter
    Given ein Git-Repository mit Commits
    When der Skill mit Parameter "--since=kein-datum" aufgerufen wird
    Then wird eine Fehlermeldung zum ungültigen Datumsformat angezeigt
