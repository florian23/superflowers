Feature: Toolbar
  Die Toolbar bietet Schnellzugriff auf wichtige Aktionen.

  Background:
    Given ein Wissensgraph mit Knoten und Kanten ist geoeffnet

  @critical
  Scenario: Layout-Dropdown-Menue oeffnen
    When ich auf den "Layout"-Dropdown-Button in der Toolbar klicke
    Then wird ein Dropdown-Menue mit folgenden Layout-Algorithmen angezeigt:
      | Algorithmus    |
      | Kraftbasiert   |
      | Hierarchisch   |
      | Kreisfoermig   |

  @critical
  Scenario: Kraftbasiertes Layout anwenden
    Given die Knoten sind unuebersichtlich positioniert
    When ich auf den "Layout"-Dropdown-Button in der Toolbar klicke
    And ich den Eintrag "Kraftbasiert" auswaehle
    Then werden die Knoten mittels kraftbasiertem Algorithmus angeordnet
    And ueberlappende Knoten werden aufgeloest
    And verbundene Knoten werden naeher beieinander platziert

  @critical
  Scenario: Hierarchisches Layout anwenden
    Given die Knoten sind unuebersichtlich positioniert
    When ich auf den "Layout"-Dropdown-Button in der Toolbar klicke
    And ich den Eintrag "Hierarchisch" auswaehle
    Then werden die Knoten in einer hierarchischen Baumstruktur angeordnet
    And Eltern-Knoten werden ueber ihren Kind-Knoten positioniert

  @critical
  Scenario: Kreisfoermiges Layout anwenden
    Given die Knoten sind unuebersichtlich positioniert
    When ich auf den "Layout"-Dropdown-Button in der Toolbar klicke
    And ich den Eintrag "Kreisfoermig" auswaehle
    Then werden die Knoten auf einem Kreis gleichmaessig verteilt angeordnet

  Scenario: Dropdown-Menue schliesst nach Auswahl
    When ich auf den "Layout"-Dropdown-Button in der Toolbar klicke
    And ich den Eintrag "Kraftbasiert" auswaehle
    Then wird das Dropdown-Menue geschlossen

  Scenario: Dropdown-Menue schliesst bei Klick ausserhalb
    When ich auf den "Layout"-Dropdown-Button in der Toolbar klicke
    And ich ausserhalb des Dropdown-Menues klicke
    Then wird das Dropdown-Menue geschlossen
    And es wird kein Layout-Algorithmus angewendet

  Scenario: Zaehler zeigt aktuelle Anzahl
    Then zeigt der Zaehler die korrekte Anzahl Knoten an
