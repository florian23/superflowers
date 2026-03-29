Feature: Toolbar
  Die Toolbar bietet Schnellzugriff auf wichtige Aktionen.

  Background:
    Given ein Wissensgraph mit Knoten und Kanten ist geoeffnet

  @critical
  Scenario: Layout-Dropdown oeffnen
    Given die Toolbar ist sichtbar
    When ich den "Layout"-Dropdown klicke
    Then wird ein Dropdown-Menue mit Layout-Algorithmen angezeigt
    And das Dropdown enthaelt die Optionen "Kraftbasiert", "Hierarchisch" und "Kreisfoermig"

  Scenario: Zaehler zeigt aktuelle Anzahl
    Then zeigt der Zaehler die korrekte Anzahl Knoten an
