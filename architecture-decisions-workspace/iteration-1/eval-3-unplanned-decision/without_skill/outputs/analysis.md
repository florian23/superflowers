# Analyse: ADR-003 ohne Skill-Unterstuetzung

## Zusammenfassung

Diese ADR entstand ungeplant waehrend der Implementierung. Synchrone HTTP-Aufrufe zwischen Order- und Inventory-Service fuehrten unter Last zu Timeouts. Die Entscheidung fuer eine Message Queue wurde als Reaktion auf dieses konkrete Problem getroffen.

## Bewertung des erstellten ADR

### Staerken
- **Kontextbeschreibung**: Das Problem (Timeouts unter Last) und der Anlass (ungeplant, aus Implementierungserfahrung) sind klar dokumentiert.
- **Alternativen**: Drei Alternativen wurden betrachtet, mit jeweils kurzer Begruendung fuer und gegen.
- **Konsequenzen**: Positive und negative Auswirkungen sind getrennt aufgefuehrt.
- **Bezug zu bestehenden ADRs**: Die Verbindung zu ADR-001 und ADR-002 ist hergestellt.

### Schwaechen
- **Keine spezifische Technologieentscheidung**: Die ADR laesst offen, ob RabbitMQ oder Kafka gewaehlt wird. Das ist bewusst, koennte aber eine Folge-ADR erfordern.
- **Keine Quantifizierung**: Es fehlen konkrete Zahlen zu den beobachteten Timeouts (Haeufigkeit, Dauer, betroffene Requests), die die Dringlichkeit belegen wuerden.
- **Kein Migrationsplan**: Wie der Uebergang von synchron zu asynchron erfolgen soll (Big Bang vs. schrittweise), ist nicht beschrieben.
- **Keine Fitness Functions**: Es sind keine messbaren Kriterien definiert, anhand derer der Erfolg der Entscheidung ueberprueft werden kann (z.B. maximale Latenz p99, Fehlerrate unter Last).

## Beobachtungen zum Prozess ohne Skill

- Die ADR-Erstellung erfolgte ohne strukturierte Anleitung. Das fuehrt dazu, dass wichtige Aspekte wie Fitness Functions, Migrationsplanung und quantitative Belege leicht vergessen werden.
- Die Qualitaet haengt stark vom Vorwissen des Erstellers ab. Ein erfahrener Architekt wuerde einige der fehlenden Punkte vermutlich ergaenzen; in einem Team mit weniger Erfahrung wuerden sie fehlen.
- Der Bezug zu bestehenden ADRs wurde hergestellt, aber eine systematische Pruefung auf Konsistenz mit der Gesamtarchitektur fehlt.
