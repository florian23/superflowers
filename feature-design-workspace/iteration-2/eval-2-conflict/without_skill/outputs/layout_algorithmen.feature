Feature: Layout-Algorithmen
  Die verschiedenen Layout-Algorithmen ordnen Knoten im Wissensgraphen
  nach unterschiedlichen Strategien an.

  Background:
    Given ein Wissensgraph mit Knoten und Kanten ist geoeffnet

  # --- Kraftbasiertes Layout ---

  Scenario: Kraftbasiertes Layout - Verbundene Knoten werden gruppiert
    Given folgende Knoten existieren:
      | Knoten |
      | A      |
      | B      |
      | C      |
      | D      |
    And eine Kante zwischen "A" und "B" existiert
    And eine Kante zwischen "A" und "C" existiert
    And keine Kante zwischen "A" und "D" existiert
    When ich das kraftbasierte Layout anwende
    Then ist der Abstand zwischen "A" und "B" kleiner als der Abstand zwischen "A" und "D"
    And ist der Abstand zwischen "A" und "C" kleiner als der Abstand zwischen "A" und "D"

  Scenario: Kraftbasiertes Layout - Keine Knotenueberlappung
    Given mehrere Knoten sind an derselben Position platziert
    When ich das kraftbasierte Layout anwende
    Then ueberlappen sich keine zwei Knoten

  # --- Hierarchisches Layout ---

  Scenario: Hierarchisches Layout - Ebenen werden korrekt zugewiesen
    Given ein gerichteter Graph mit einer Wurzel "Root"
    And "Root" hat Kind-Knoten "Kind1" und "Kind2"
    And "Kind1" hat Kind-Knoten "Enkel1"
    When ich das hierarchische Layout anwende
    Then befindet sich "Root" auf der obersten Ebene
    And "Kind1" und "Kind2" befinden sich auf der zweiten Ebene
    And "Enkel1" befindet sich auf der dritten Ebene

  Scenario: Hierarchisches Layout - Kanten verlaufen von oben nach unten
    Given ein gerichteter Graph mit mindestens zwei Ebenen
    When ich das hierarchische Layout anwende
    Then verlaufen alle Kanten von einer hoeheren zu einer tieferen Ebene

  # --- Kreisfoermiges Layout ---

  Scenario: Kreisfoermiges Layout - Gleichmaessige Verteilung
    Given es existieren 6 Knoten im Graphen
    When ich das kreisfoermige Layout anwende
    Then sind alle Knoten auf einem Kreis angeordnet
    And der Winkelabstand zwischen benachbarten Knoten ist gleich

  Scenario: Kreisfoermiges Layout - Radius passt sich an Knotenanzahl an
    Given es existieren 20 Knoten im Graphen
    When ich das kreisfoermige Layout anwende
    Then ist der Radius gross genug, dass sich keine Knoten ueberlappen
