# language: de
Feature: Toolbar
  Die Toolbar bietet Schnellzugriff auf wichtige Aktionen.

  Background:
    Given ein Wissensgraph mit Knoten und Kanten ist geoeffnet

  # CONFLICT RESOLVED: Das Szenario "Auto-Layout anwenden" wurde entfernt.
  # Grund: Der einzelne "Auto-Layout"-Button wurde durch ein Dropdown-Menue
  # mit verschiedenen Layout-Algorithmen ersetzt (siehe layout-algorithmen.feature).
  # Vorheriger Step "When ich den Auto-Layout-Button klicke" ist nicht mehr gueltig.
  # Aenderung erfordert Nutzer-Zustimmung vor Implementierung.

  @critical
  Scenario: Layout-Dropdown ist in der Toolbar sichtbar
    Then sehe ich ein Layout-Dropdown-Menue in der Toolbar

  Scenario: Zaehler zeigt aktuelle Anzahl
    Then zeigt der Zaehler die korrekte Anzahl Knoten an
