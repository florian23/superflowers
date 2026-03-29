# language: de
Feature: Layout-Algorithmen Dropdown-Menue
  Statt eines einzelnen Auto-Layout-Buttons bietet die Toolbar ein
  Dropdown-Menue mit verschiedenen Layout-Algorithmen, damit Nutzer
  den passenden Algorithmus fuer ihren Graphen waehlen koennen.

  Background:
    Given ein Wissensgraph mit Knoten und Kanten ist geoeffnet

  # --- Algorithmus-Auswahl ---

  @critical
  Scenario: Dropdown-Menue oeffnen
    When ich das Layout-Menue oeffne
    Then sehe ich die verfuegbaren Layout-Algorithmen:
      | Algorithmus   |
      | Kraftbasiert  |
      | Hierarchisch  |
      | Kreisfoermig  |

  @critical
  Scenario Outline: Layout-Algorithmus anwenden
    Given die Knoten sind unuebersichtlich positioniert
    When ich den Layout-Algorithmus "<Algorithmus>" auswaehle
    Then werden die Knoten nach dem "<Algorithmus>"-Verfahren angeordnet

    Examples:
      | Algorithmus   |
      | Kraftbasiert  |
      | Hierarchisch  |
      | Kreisfoermig  |

  # --- Erwartetes Verhalten je Algorithmus ---

  Scenario: Kraftbasiertes Layout erzeugt gleichmaessige Abstande
    Given die Knoten sind unuebersichtlich positioniert
    When ich den Layout-Algorithmus "Kraftbasiert" auswaehle
    Then haben benachbarte Knoten gleichmaessige Abstande zueinander
    And ueberlappen sich keine Knoten

  Scenario: Hierarchisches Layout zeigt Ebenen
    Given der Graph hat eine Baumstruktur
    When ich den Layout-Algorithmus "Hierarchisch" auswaehle
    Then sind die Knoten in hierarchischen Ebenen angeordnet
    And verlaufen Kanten von oben nach unten

  Scenario: Kreisfoermiges Layout ordnet Knoten im Kreis an
    Given die Knoten sind unuebersichtlich positioniert
    When ich den Layout-Algorithmus "Kreisfoermig" auswaehle
    Then sind die Knoten auf einem Kreis angeordnet

  # --- Dropdown-Verhalten ---

  Scenario: Dropdown-Menue schliesst sich nach Auswahl
    When ich das Layout-Menue oeffne
    And ich den Layout-Algorithmus "Kraftbasiert" auswaehle
    Then ist das Layout-Menue geschlossen

  Scenario: Dropdown-Menue ohne Auswahl schliessen
    When ich das Layout-Menue oeffne
    And ich ausserhalb des Menues klicke
    Then ist das Layout-Menue geschlossen
    And bleibt das aktuelle Layout unveraendert

  # --- Fehlerfaelle und Randbedingungen ---

  @edge-case
  Scenario: Layout auf leeren Graphen anwenden
    Given der Wissensgraph hat keine Knoten
    When ich das Layout-Menue oeffne
    Then sind alle Layout-Algorithmen deaktiviert

  @edge-case
  Scenario: Layout auf Graphen mit einem einzelnen Knoten
    Given der Wissensgraph hat genau einen Knoten
    When ich den Layout-Algorithmus "Kraftbasiert" auswaehle
    Then bleibt der Knoten an seiner Position

  @edge-case
  Scenario: Layout waehrend laufender Berechnung
    Given ein Layout-Algorithmus wird gerade berechnet
    When ich einen anderen Layout-Algorithmus auswaehle
    Then wird die laufende Berechnung abgebrochen
    And der neu gewaehlte Algorithmus wird angewendet
