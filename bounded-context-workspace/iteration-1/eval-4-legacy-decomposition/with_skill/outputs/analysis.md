# Bounded Context Analysis: Legacy-Versicherungsmonolith

## Last Updated: 2026-03-29

## Ausgangslage

Ein 10 Jahre alter Java-Monolith fuer Versicherungsverwaltung. Alle Geschaeftsbereiche — Vertragsmanagement, Schadensbearbeitung, Kundenverwaltung, Dokumentengenerierung, Praemienberechnung — sind in einer Codebasis verschmolzen, gestuetzt auf eine Oracle-Datenbank mit 400 Tabellen. Ziel ist schrittweise Modernisierung (kein Big-Bang).

## Subdomain-Klassifikation

| Subdomain | Typ | Begruendung |
|---|---|---|
| Vertragsmanagement | **Core** | Kerngeschaeft des Versicherers. Der Versicherungsvertrag ist das zentrale Produkt. Komplexe Geschaeftsregeln fuer Policierung, Nachtraege, Kuendigungen sind Wettbewerbsvorteil. |
| Schadensbearbeitung | **Core** | Direkt umsatzrelevant. Schnelle, faire Schadenregulierung ist Differenzierungsmerkmal gegenueber Wettbewerbern. Hohe regulatorische Anforderungen. |
| Praemienberechnung | **Core** | Aktuarielle Kompetenz und Preisgestaltung sind wettbewerbsentscheidend. Wer besser tarifiert, gewinnt im Markt. |
| Kundenverwaltung | **Supporting** | Notwendig, aber kein Differenzierungsmerkmal. Stammdaten, Rollen, Kontaktmanagement — wichtig, aber branchenueblich. |
| Dokumentengenerierung | **Supporting** | Notwendig fuer Geschaeftsbetrieb (Policen-Druck, Schadenbriefe), aber kein Wettbewerbsvorteil. Austauschbar durch Standard-Dokumentenloesungen. |

## Bounded Context Boundaries — Entscheidungsbegruendung

### Warum 5 neue Kontexte + 1 Legacy-Kontext?

Die Zerlegung folgt dem **linguistischen Test**: Dieselben Begriffe bedeuten in verschiedenen Bereichen unterschiedliches.

**"Kunde" hat verschiedene Bedeutungen:**
- In Vertragswesen: Versicherungsnehmer (haelt Police, zahlt Praemie)
- In Schadenregulierung: Anspruchsteller (kann Dritter sein, kein Vertragspartner)
- In der Legacy-DB: Eine Zeile in der Kundentabelle mit einem "Typ"-Feld

**"Vertrag" hat verschiedene Bedeutungen:**
- In Vertragswesen: Lebendiges Objekt mit Zustand, Deckungen, Nachtraegen
- In Schadenregulierung: Referenz zur Deckungspruefung (nur Deckungsumfang relevant)
- In Praemienberechnung: Risikotraeger mit Merkmalen zur Tarifierung
- In der Legacy-DB: Flache Zeile mit 80 Spalten

**"Dokument" hat verschiedene Bedeutungen:**
- In Dokumentenservice: Template + generiertes PDF mit Archivierungspflicht
- In Vertragswesen: Die Police, die dem Kunden zugestellt wird
- In der Legacy-DB: BLOB-Referenz in einer Dokumententabelle

### Warum Kundendomaene als eigener Kontext?

Alternativ waere "Kunde" Teil von Vertragswesen. Aber:
- Schadensbearbeitung braucht Kundendaten unabhaengig vom Vertrag
- Kundendomaene aendert sich seltener als Vertragswesen
- Zentrale Kundensicht (360-Grad-Sicht) ist ein eigenes fachliches Anliegen
- Mehrere Kontexte konsumieren Kundendaten — Open Host Service ist sauberer als N:1-Kopplung

### Warum Dokumentenservice als eigener Kontext?

Alternativ waere Dokumentengenerierung Teil jedes fachlichen Kontexts. Aber:
- Dokumentenlogik (Vorlagen, Rendering, Archivierung) ist orthogonal zu Fachlichkeit
- Einheitliche Archivierung und Compliance-Anforderungen
- Kann als reaktiver Service hinter Events arbeiten (lose Kopplung)

## Anti-Corruption Layer Strategie

**Dies ist der zentrale Architekturentscheid fuer die Migration.**

Jeder neue Bounded Context kommuniziert mit dem Monolith **ausschliesslich** ueber einen Anti-Corruption Layer. Der ACL:

1. **Uebersetzt Datenmodelle:** Legacy-Tabellenstruktur wird in das reiche Domaenenmodell des neuen Kontexts transformiert. Nie direkte SQL-Queries gegen Legacy-Tabellen aus neuem Code.

2. **Kapselt Protokolle:** Ob der Monolith ueber REST, SOAP, direkten DB-Zugriff oder Messaging angebunden wird — der ACL verbirgt das vor der Domaene.

3. **Ermoeglicht schrittweise Migration:** Durch das Strangler-Fig-Pattern kann der ACL schrittweise Anfragen vom Monolith auf den neuen Kontext umleiten. Der ACL wird zur Weiche.

### ACL-Implementierung pro Kontext

```
┌──────────────────────┐
│   Neuer Bounded      │
│   Context            │
│   (reines Domaenen-  │
│    modell)           │
├──────────────────────┤
│   ACL / Adapter      │  ← Uebersetzungsschicht
│   - LegacyVertrag    │
│     → Police         │
│   - LegacyKunde     │
│     → Versicherungs- │
│       nehmer         │
├──────────────────────┤
│   Legacy-Zugriff     │  ← REST/SOAP/DB-View
│   (Monolith-API      │
│    oder DB-Views)    │
└──────────────────────┘
```

**Konkret fuer den Versicherungsmonolith:**

| Neuer Kontext | ACL uebersetzt | Legacy-Anbindung |
|---|---|---|
| Tarifierung & Praemie | Legacy-Berechnungsparameter → Risikomerkmale + Tarif | DB-Views auf Vertragstabellen (read-only) |
| Kundendomaene | Undifferenzierte Legacy-Kundentabelle → Rollenmodell (VN, Makler, Geschaedigter) | Synchronisation ueber Change-Data-Capture oder Batch |
| Dokumentenservice | Legacy-Drucksteuerung → Event-basierte Dokumentengenerierung | Messaging (Events von neuen Kontexten), Legacy-Bridge fuer alte Prozesse |
| Vertragswesen | 80-Spalten-Vertragstabelle → Police-Aggregat mit Deckungen, Nachtraegen | DB-Views + REST-API am Monolith, schrittweise Uebernahme |
| Schadenregulierung | Verschmolzene Schaden/Vertrag-Struktur → Eigenstaendiges Schadenfall-Aggregat | REST-API fuer Vertragsdaten (ueber Vertragswesen-ACL) |

## Migrationsreihenfolge und Begruendung

### Phase 1: Tarifierung & Praemie (Risiko: Niedrig)

**Warum zuerst?**
- Klar abgrenzbare Berechungslogik (Input → Output)
- Kann im **Shadow-Mode** parallel zum Legacy laufen: Beide berechnen, Ergebnisse vergleichen
- Keine Downstream-Abhaengigkeiten — kein anderer Kontext konsumiert direkt
- Verifizierbarkeit: Gleiche Praemie = korrekte Migration
- Aktuarielle Regeln muessen ohnehin regelmaessig aktualisiert werden — neuer Kontext macht das einfacher

### Phase 2: Kundendomaene (Risiko: Mittel)

**Warum frueh?**
- Wird von ALLEN anderen Kontexten benoetigt (Vertrag, Schaden, Dokumente)
- Fruehe Extraktion schafft Grundlage fuer alle weiteren Kontexte
- Open Host Service als einheitliche Kundenschnittstelle

**Risiken:**
- Stammdatenmigration aus 400-Tabellen-DB ist komplex
- Datenqualitaet im Legacy (Dubletten, fehlende Rollen-Differenzierung)
- Uebergangszeitraum: Beide Systeme fuehren Kundendaten

### Phase 3: Dokumentenservice (Risiko: Niedrig)

**Warum nach Kundendomaene?**
- Rein reaktiv: Empfaengt Events, generiert Dokumente
- Keine eigene komplexe Geschaeftslogik
- Kann Event-getrieben angebunden werden (lose Kopplung)
- Legacy-Druckstrasse laeuft parallel weiter

### Phase 4: Vertragswesen (Risiko: Hoch)

**Warum nicht frueher?**
- Zentralster und komplexester Kontext
- Benoetigt Kundendomaene (Phase 2) und Tarifierung (Phase 1)
- Nicht als Big-Bang extrahierbar — schrittweise per Vertragsart oder Nachtrag-Typ

**Strategie:**
- Zuerst Leseoperationen migrieren (Vertragsauskunft)
- Dann Schreiboperationen schrittweise (Nachtrag fuer Nachtrag)
- Strangler Fig mit Feature-Toggles

### Phase 5: Schadenregulierung (Risiko: Hoch)

**Warum zuletzt?**
- Benoetigt stabiles Vertragswesen fuer Deckungspruefung
- Benoetigt Kundendomaene fuer Anspruchsteller
- Komplexe Regulierungslogik mit vielen Sonderfaellen
- Regulatorische Anforderungen (Dokumentationspflicht, Fristen)

## Datenbank-Strategie

Die 400-Tabellen-Oracle-DB wird NICHT auf einmal zerlegt.

1. **Sofort:** DB-Views als saubere Leseschnittstelle fuer neue Kontexte (Teil des ACL)
2. **Pro Phase:** Neuer Kontext erhaelt eigenes Schema/eigene DB fuer seine Schreiboperationen
3. **Uebergang:** Dual-Write oder Change-Data-Capture fuer Synchronisation
4. **Langfristig:** Jeder Bounded Context besitzt seine Daten. Legacy-Tabellen schrumpfen mit jeder Phase.

```
Phase 1-2:  Monolith-DB (400 Tabellen)  +  Tarif-DB  +  Kunden-DB
Phase 3:    Monolith-DB (380 Tabellen)  +  Tarif-DB  +  Kunden-DB  +  Dokument-DB
Phase 4:    Monolith-DB (300 Tabellen)  +  alle neuen DBs
Phase 5:    Monolith-DB (200 Tabellen)  +  alle neuen DBs
Endzustand: Monolith-DB abgeschaltet
```

## Red Flags gepreuft

- [x] **Keine technischen Boundaries:** Alle Kontexte sind fachlich motiviert, nicht "Frontend/Backend/Datenbank"
- [x] **Keine Entity-per-Context-Aufspaltung:** "Vertragswesen" ist nicht "Vertragskontext" — es umfasst Police, Nachtrag, Antrag als zusammengehoerende Geschaeftsfaehigkeit
- [x] **Angemessene Anzahl:** 5 neue Kontexte + 1 Legacy-Kontext fuer ein System dieser Groesse ist angemessen
- [x] **Ubiquitaere Sprache definiert:** Jeder Kontext hat eigene Fachbegriffe mit klarer Bedeutung
- [x] **ACL fuer alle Legacy-Integrationen:** Kein neuer Kontext greift direkt auf Legacy-Datenmodell zu

## Offene Fragen fuer die naechste Phase

1. **Team-Schnitt:** Wie viele Teams stehen zur Verfuegung? Conway's Law bestimmt, wie viele Kontexte parallel extrahiert werden koennen.
2. **Regulatorik:** Welche BaFin/Solvency-II-Anforderungen beeinflussen die Datenhaltung?
3. **Bestandsmigration:** Werden alle Altvertraege migriert oder nur Neugeschaeft in neue Kontexte?
4. **Event-Infrastruktur:** Kafka, RabbitMQ oder anderes Messaging fuer die Published-Language-Integration?
5. **API-Gateway:** Wie wird die Umschaltung zwischen Legacy und neuen Kontexten gesteuert (Routing)?
