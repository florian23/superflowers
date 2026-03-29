# Bounded Context Analysis: Legacy-Versicherungsmonolith

## Ausgangslage

Ein 10 Jahre alter Java-Monolith fuer Versicherungsverwaltung mit:
- Vertragsmanagement, Schadensbearbeitung, Kundenverwaltung, Dokumentengenerierung, Praemienberechnung als eng gekoppelte Module
- Eine zentrale Oracle-Datenbank mit ca. 400 Tabellen
- Anforderung: schrittweise Modernisierung, kein Big-Bang

## Methodik zur Grenzziehung

### Angewandte Heuristiken

1. **Geschaeftsfaehigkeiten (Business Capabilities):** Jeder Bounded Context entspricht einer eigenstaendigen Geschaeftsfaehigkeit, die fuer sich allein Wert liefert.
2. **Dateneigentumsrecht:** Welche Tabellen gehoeren logisch zusammen? Welche Entitaet ist der "System of Record"?
3. **Aenderungszyklen:** Module, die sich gemeinsam aendern, gehoeren zusammen. Module mit unterschiedlichen Release-Kadenzen sollten getrennt werden.
4. **Teamstruktur:** Welche Teams arbeiten an welchen Bereichen? (Conway's Law)
5. **Regulatorische Grenzen:** Schadensbearbeitung unterliegt anderen Compliance-Anforderungen als Kundenverwaltung.

### Identifizierte Bounded Contexts

Sieben Kontexte wurden identifiziert (Details siehe context-map.md):

1. **Vertragsmanagement** -- Kern des Systems, hoechste Kopplung
2. **Schadensbearbeitung** -- Eigenstaendiger Lebenszyklus mit klaren Ein-/Ausgaengen
3. **Kundenverwaltung** -- Stammdaten-Service, viele Konsumenten
4. **Praemienberechnung** -- Berechnungslogik, gut isolierbar
5. **Dokumentengenerierung** -- Reine Ausgabe-Funktion, technisch gut trennbar
6. **Partner & Vertrieb** -- Eigene Domaene mit Provisionslogik
7. **Inkasso & Buchhaltung** -- Finanznahe Prozesse, eigene Compliance

## Analyse der Kopplungspunkte

### Kritische Shared-Data-Probleme

Die groesste Herausforderung im Monolith sind die gemeinsam genutzten Tabellen. Typische Muster in einem solchen System:

| Problem | Beispiel | Auswirkung |
|---------|----------|------------|
| Gott-Tabelle "VERTRAG" | Wird von Vertrags-, Schaden-, Praemien- und Dokumentenlogik geschrieben | Jede Aenderung hat Seiteneffekte |
| Gott-Tabelle "KUNDE" | Wird von allen Modulen gelesen und teilweise geschrieben | Keine klare Datenhoheit |
| Stored Procedures | PL/SQL-Logik in der Datenbank implementiert Geschaeftsregeln | Logik ist unsichtbar fuer die Java-Schicht |
| Fremdschluessel quer durch Domaenen | SCHADEN -> VERTRAG -> KUNDE -> ADRESSE | Datenbank erzwingt Kopplung |

### Implizite Kontextgrenzen im bestehenden Code

Auch im Monolith gibt es bereits Grenzen, die man nutzen kann:
- **Package-Struktur:** Wenn die Java-Packages bereits nach Fachlichkeit strukturiert sind (z.B. `de.versicherung.vertrag`, `de.versicherung.schaden`), sind das Hinweise auf natuerliche Grenzen.
- **Datenbank-Schemata:** Falls bereits Oracle-Schemata existieren, koennen diese als Ausgangspunkt dienen.
- **Bestehende Service-Interfaces:** Interne APIs oder Fassaden zwischen Modulen deuten auf intentionale Grenzen hin.

## Empfohlene Migrationsstrategie

### Phase 1: Strangler Fig -- Dokumentengenerierung extrahieren (Monate 1-4)

**Warum zuerst:** Dokumentengenerierung ist ein reiner Konsument, schreibt keine Geschaeftsdaten zurueck und hat die geringste bidirektionale Kopplung.

**Vorgehen:**
1. Neuen Dokumenten-Service aufsetzen (z.B. Spring Boot + Template-Engine)
2. API definieren, die Vertragsdaten, Kundendaten und Schadensdaten als Input erhaelt
3. Im Monolith einen Adapter bauen, der die neue API aufruft statt der alten Dokumentenlogik
4. Alten Code im Monolith stilllegen

**Risiken:** Gering. Rollback-Faehigkeit bleibt erhalten, da der Monolith die alte Logik noch hat.

### Phase 2: Kundenverwaltung als eigenen Service (Monate 3-8)

**Warum als Zweites:** Kundenverwaltung ist ein zentraler Datenlieferant. Die Extraktion erzwingt die Definition einer klaren Daten-API und ist die Grundlage fuer alle weiteren Extraktionen.

**Vorgehen:**
1. Customer-API definieren (REST oder gRPC)
2. Anti-Corruption Layer im Monolith: alle Kundenzugriffe ueber eine Fassade leiten
3. Daten in den neuen Service migrieren (Dual-Write-Phase mit Konsistenzpruefung)
4. Monolith schrittweise auf die neue API umstellen
5. Kundentabellen im Monolith zu Read-Only-Views degradieren, dann entfernen

**Risiken:** Mittel. Dual-Write-Konsistenz muss sorgfaeltig ueberwacht werden.

### Phase 3: Praemienberechnung extrahieren (Monate 6-10)

**Warum:** Praemienberechnung ist rechenlastig, aendert sich haeufig (neue Tarife) und profitiert am meisten von unabhaengigem Deployment.

**Vorgehen:**
1. Berechnungslogik als zustandslosen Service implementieren
2. Eingabe: Vertragsdaten + Risikofaktoren. Ausgabe: Praemie
3. Synchroner Aufruf aus dem Monolith, da Ergebnis sofort benoetigt wird
4. PL/SQL-Logik in der Datenbank identifizieren und in den neuen Service migrieren

### Phase 4: Schadensbearbeitung (Monate 9-15)

**Warum spaeter:** Hohe Komplexitaet, eigener Workflow, regulatorische Anforderungen. Profitiert davon, dass Kunde und Praemie bereits extrahiert sind.

### Phase 5: Vertragsmanagement (Monate 14-24)

**Zuletzt:** Vertragsmanagement ist der Kern mit der hoechsten Kopplung. Erst extrahieren, wenn die umgebenden Kontexte bereits eigenstaendig sind.

## Datenstrategie

### Datenhoheit pro Kontext

| Bounded Context       | Besitzt die Daten fuer          | Bietet anderen an via        |
|-----------------------|---------------------------------|------------------------------|
| Kundenverwaltung      | Kunde, Adresse, Kontakt         | Kunden-API (ID, Name, Rolle)|
| Vertragsmanagement    | Vertrag, Deckung, Nachtrag      | Vertrags-API (ID, Status)   |
| Schadensbearbeitung   | Schaden, Regulierung, Gutachten | Schadens-API (ID, Status)   |
| Praemienberechnung    | Tarif, Risikofaktor, Praemie    | Berechnungs-API (sync)      |
| Dokumentengenerierung | Vorlage, Dokument, Druckauftrag | Generierungs-API (async)    |
| Partner & Vertrieb    | Vermittler, Provision           | Partner-API (ID, Provision) |
| Inkasso & Buchhaltung | Beitragskonto, Mahnung          | Konto-API (Saldo, Status)   |

### Umgang mit den 400 Tabellen

1. **Zuordnung:** Jede Tabelle genau einem Bounded Context zuordnen. Tabellen, die von mehreren Kontexten beschrieben werden, sind Kandidaten fuer Aufspaltung.
2. **Views fuer die Uebergangsphase:** Solange Kontexte noch in der gemeinsamen Datenbank leben, Views erstellen, die nur die Spalten exponieren, die der jeweilige Kontext benoetigt.
3. **Datenmigration:** Pro extrahiertem Kontext die zugehoerigen Tabellen in eine eigene Datenbank migrieren. Change Data Capture (z.B. Debezium) fuer die Synchronisation waehrend der Uebergangsphase.

## Risiken und Gegenmassnahmen

| Risiko | Wahrscheinlichkeit | Gegenmassnahme |
|--------|---------------------|----------------|
| Verteilte Transaktionen | Hoch | Saga-Pattern statt 2PC; Eventual Consistency akzeptieren |
| Datenkonsistenz bei Dual-Write | Hoch | Change Data Capture (Debezium), Konsistenz-Monitoring |
| PL/SQL-Geschaeftslogik uebersehen | Mittel | Systematisches Audit aller Stored Procedures, Trigger, Views |
| Performance-Regression durch Netzwerk-Hops | Mittel | Caching, Bulk-APIs, asynchrone Kommunikation wo moeglich |
| Team-Ueberlastung durch parallele Migration und Feature-Entwicklung | Hoch | Feature-Freeze fuer betroffene Module waehrend Extraktion |
| Unerkannte Kopplungen in der Datenbank | Hoch | Datenbankanalyse-Tools einsetzen (z.B. SchemaSpy, Oracle DBA-Views fuer FK-Abhaengigkeiten) |

## Empfehlungen

1. **Sofort starten:** Dokumentengenerierung als ersten Kandidaten extrahieren -- geringes Risiko, hoher Lerneffekt.
2. **Datenbank-Archaeologie:** Vor jeder Extraktion die betroffenen Tabellen, Views, Stored Procedures und Trigger vollstaendig erfassen.
3. **Event-Backbone frueh einfuehren:** Bereits in Phase 1 einen Event-Bus (z.B. Kafka) aufsetzen, auch wenn anfangs nur wenige Events fliessen.
4. **Feature-Toggles:** Jede Extraktion hinter einem Feature-Toggle ausfuehren, um schnell zurueckrollen zu koennen.
5. **Observability:** Distributed Tracing (z.B. OpenTelemetry) von Anfang an einbauen, um Netzwerk-bedingte Probleme sichtbar zu machen.
