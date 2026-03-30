Feature: HTML-Report-Generierung
  Als Nutzer des Compliance Reports
  will ich einen interaktiven, offline-fähigen HTML-Report
  damit ich die Compliance-Daten visuell und navigierbar auswerten kann

  Background:
    Given gesammelte Compliance-Daten für mehrere Feature-Zyklen

  @critical
  Scenario: Single-File HTML ohne externe Abhängigkeiten
    When der HTML-Report generiert wird
    Then wird exakt 1 HTML-Datei erzeugt
    And die Datei enthält keine externen URL-Referenzen

  @critical
  Scenario: Offline-Fähigkeit
    When der HTML-Report generiert wird
    Then sind alle Assets inline eingebettet
    And der Report funktioniert ohne Internetverbindung

  @critical
  Scenario: Valides HTML5
    When der HTML-Report generiert wird
    Then besteht die Datei die HTML5-Validierung ohne Errors

  @critical
  Scenario: Executive Summary mit Compliance-Score
    Given ein Durchschnitts-Score von 82% über 5 Feature-Zyklen
    When der Report im Browser geöffnet wird
    Then zeigt die Executive Summary den Durchschnitts-Score von 82%

  Scenario: Executive Summary mit Trend-Indikator
    Given steigende Compliance-Scores über die letzten 3 Zyklen
    When der Report im Browser geöffnet wird
    Then zeigt die Executive Summary einen positiven Trend-Indikator

  @critical
  Scenario: Interaktive Timeline mit Feature-Punkten
    Given ein Report mit 7 Feature-Zyklen
    When der Report im Browser geöffnet wird
    Then zeigt eine klickbare Timeline alle 7 Features als Punkte

  @critical
  Scenario: Navigation zu Feature-Detail in maximal 3 Klicks
    Given ein Report mit 10 Feature-Zyklen
    When der Nutzer ein beliebiges Feature-Detail erreichen will
    Then ist jedes Feature-Detail in maximal 3 Klicks erreichbar

  @critical
  Scenario: Feature-Detail zeigt Compliance Checklist
    Given ein Report mit Feature "auth-system"
    When der Nutzer die Detail-Ansicht von "auth-system" öffnet
    Then zeigt die Ansicht eine Compliance Checklist mit Bestanden/Nicht-bestanden pro Prüfung

  Scenario: Feature-Detail zeigt Code Impact
    Given ein Report mit Feature "auth-system"
    When der Nutzer die Detail-Ansicht von "auth-system" öffnet
    Then zeigt die Ansicht Dateien, Lines und Churn-Ratio

  Scenario: Compliance-Score-Verlauf als Chart
    Given ein Report mit Daten über 10 Feature-Zyklen
    When der Report im Browser geöffnet wird
    Then zeigt ein Chart den Compliance-Score-Verlauf über die Zeit

  Scenario: Artefakt-Vollständigkeit als Chart
    Given ein Report mit Daten über 10 Feature-Zyklen
    When der Report im Browser geöffnet wird
    Then zeigt ein Chart die Artefakt-Vollständigkeit pro Feature

  Scenario Outline: Farbcodierung für Compliance-Scores
    Given ein Feature-Zyklus mit Score <score>%
    When der Report im Browser geöffnet wird
    Then wird der Score <farbe> dargestellt

    Examples:
      | score | farbe |
      | 91    | grün  |
      | 72    | gelb  |
      | 45    | rot   |

  Scenario: Drift-Warnungen in eigener Sektion
    Given erkannte Drift-Warnungen im Report
    When der Report im Browser geöffnet wird
    Then werden Drift-Warnungen in einer eigenen Sektion angezeigt
    And jede Warnung enthält das betroffene Feature und den Grund

  Scenario: Daten als eingebetteter Datenblock
    When der HTML-Report generiert wird
    Then enthält die HTML-Datei alle Compliance-Daten als strukturierten Datenblock

  Scenario: Aufklappbare Feature-Sektionen
    When der Report im Browser geöffnet wird
    Then sind Feature-Details standardmäßig eingeklappt
    And können per Klick auf- und zugeklappt werden

  Scenario: Responsive Darstellung
    When der Report auf verschiedenen Bildschirmgrößen geöffnet wird
    Then sind alle Inhalte auf 1024px und 1920px Viewport lesbar
