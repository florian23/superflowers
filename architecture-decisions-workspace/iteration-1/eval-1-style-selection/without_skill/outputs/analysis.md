# Analyse: Architekturstil-Auswahl

## Bewertungsvergleich

| Kriterium              | Service-Based | Microservices |
|------------------------|:------------:|:-------------:|
| Gesamtbewertung        | 14/15        | 15/15         |
| Geschaetzte Kosten     | $$           | $$$$$         |
| Kosten-Effizienz-Ratio | 7.0          | 3.0           |

## Entscheidungsfaktoren

### 1. Kosten-Nutzen-Analyse

Microservices erreichen zwar die Maximalbewertung, kosten aber das 2,5-fache. Der Zusatznutzen von einem Punkt (6,7 % Verbesserung) steht in keinem Verhaeltnis zum Kostenanstieg von 150 %.

**Kosten-Effizienz-Ratio** (Punkte pro Kostenstufe):
- Service-Based: 14 / 2 = **7.0**
- Microservices: 15 / 5 = **3.0**

Service-Based ist damit 2,3x kosteneffizienter.

### 2. Migrationseignung

| Aspekt                     | Service-Based               | Microservices                    |
|----------------------------|-----------------------------|---------------------------------|
| Migrationsansatz           | Inkrementell, domaeenweise  | Big-Bang oder aufwaendige Parallelstruktur |
| Infrastruktur-Voraussetzung| API Gateway, einfaches Deployment | Service Mesh, Container-Orchestrierung, verteiltes Tracing |
| Time-to-First-Service      | Wochen                      | Monate                          |
| Risiko                     | Gering                      | Hoch                            |

### 3. Team-Passung

Mit 3 Teams von je 4-6 Entwicklern (insgesamt 12-18 Entwickler):

- **Service-Based**: Jedes Team verantwortet 1-3 groebere Services. Klare Ownership, ueberschaubarer Koordinationsaufwand.
- **Microservices**: Bei typischen 5-10+ Microservices pro Team wuerde der Betriebsaufwand (Monitoring, Deployment-Pipelines, Debugging verteilter Systeme) einen signifikanten Anteil der Kapazitaet binden.

### 4. Evolutionsfaehigkeit

Service-Based Architecture laesst den Weg zu Microservices offen. Einzelne Services koennen bei Bedarf aufgeteilt werden, wenn:
- Skalierungsanforderungen dies erfordern
- Teams wachsen und feinere Ownership sinnvoll wird
- Spezifische Domaenen unabhaengige Release-Zyklen benoetigen

## Fazit

Die Entscheidung fuer Service-Based Architecture ist bei den gegebenen Rahmenbedingungen (schrittweise Monolith-Migration, 3 Teams mit 4-6 Entwicklern) die risikoadaequate und kosteneffiziente Wahl. Der minimale Bewertungsunterschied zu Microservices wird durch die erheblich geringeren Kosten und die bessere Migrationseignung deutlich ueberkompensiert.
