Feature: Layout-Dropdown
  Das Layout-Dropdown in der Toolbar ermoeglicht die Auswahl verschiedener
  Layout-Algorithmen zur Anordnung der Knoten im Wissensgraphen.

  Background:
    Given ein Wissensgraph mit Knoten und Kanten ist geoeffnet
    And die Knoten sind unuebersichtlich positioniert
    And ich den "Layout"-Dropdown klicke

  @critical
  Scenario: Kraftbasiertes Layout anwenden
    When ich die Option "Kraftbasiert" auswaehle
    Then werden die Knoten mit dem kraftbasierten Algorithmus angeordnet
    And verbundene Knoten werden naeher beieinander platziert
    And nicht verbundene Knoten werden weiter auseinander geschoben
    And das Dropdown-Menue schliesst sich

  @critical
  Scenario: Hierarchisches Layout anwenden
    When ich die Option "Hierarchisch" auswaehle
    Then werden die Knoten in einer hierarchischen Baumstruktur angeordnet
    And uebergeordnete Knoten werden oberhalb ihrer Kindknoten platziert
    And das Dropdown-Menue schliesst sich

  @critical
  Scenario: Kreisfoermiges Layout anwenden
    When ich die Option "Kreisfoermig" auswaehle
    Then werden die Knoten auf einer Kreisform angeordnet
    And alle Knoten sind gleichmaessig auf dem Kreis verteilt
    And das Dropdown-Menue schliesst sich

  Scenario: Dropdown schliesst sich bei Klick ausserhalb
    When ich ausserhalb des Dropdown-Menues klicke
    Then schliesst sich das Dropdown-Menue
    And es wird kein Layout-Algorithmus angewendet

  Scenario: Aktuell ausgewaehlter Algorithmus ist markiert
    Given das kraftbasierte Layout wurde bereits angewendet
    When ich den "Layout"-Dropdown klicke
    Then ist die Option "Kraftbasiert" visuell hervorgehoben
