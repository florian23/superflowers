# Context Map: Versicherungsverwaltung Legacy-Monolith

## Identified Bounded Contexts

```
+------------------------------------------------------------------+
|                                                                  |
|  +------------------+       +---------------------+              |
|  | Vertrags-        |       | Schaden-            |              |
|  | management       |<----->| bearbeitung         |              |
|  | (Policy Mgmt)    |       | (Claims Processing) |              |
|  +--------+---------+       +----------+----------+              |
|           |                            |                         |
|           | ACL                        | ACL                     |
|           v                            v                         |
|  +------------------+       +---------------------+              |
|  | Praemien-        |       | Kunden-             |              |
|  | berechnung       |<------| verwaltung          |              |
|  | (Premium Calc)   |       | (Customer Mgmt)     |              |
|  +--------+---------+       +----------+----------+              |
|           |                            |                         |
|           |                            |                         |
|           v                            v                         |
|  +------------------+       +---------------------+              |
|  | Dokument-        |       | Partner &           |              |
|  | generierung      |       | Vertrieb            |              |
|  | (Document Gen)   |       | (Distribution)      |              |
|  +------------------+       +---------------------+              |
|                                                                  |
+------------------------------------------------------------------+
```

## Bounded Contexts

### 1. Vertragsmanagement (Policy Management)
- **Kernaufgabe:** Lebenszyklus von Versicherungsvertraegen (Antrag, Police, Nachtrag, Kuendigung)
- **Entitaeten:** Vertrag, Antrag, Nachtrag, Tarif, Deckung, Versicherungsobjekt
- **Geschaetzter Tabellenanteil:** ~100 Tabellen

### 2. Schadensbearbeitung (Claims Processing)
- **Kernaufgabe:** Schadensmeldung, Pruefung, Regulierung, Auszahlung
- **Entitaeten:** Schaden, Schadensfall, Regulierung, Zahlung, Gutachten, Leistung
- **Geschaetzter Tabellenanteil:** ~80 Tabellen

### 3. Kundenverwaltung (Customer Management)
- **Kernaufgabe:** Stammdaten, Rollen (VN, VP, Begguenstigter), Kommunikation
- **Entitaeten:** Kunde, Adresse, Kontakt, Rolle, Bankverbindung, Kommunikationshistorie
- **Geschaetzter Tabellenanteil:** ~60 Tabellen

### 4. Praemienberechnung (Premium Calculation)
- **Kernaufgabe:** Tarifierung, Risikoberechnung, Praemienermittlung
- **Entitaeten:** Tarif, Risikofaktor, Praemie, Rabatt, Beitragsverlauf
- **Geschaetzter Tabellenanteil:** ~50 Tabellen

### 5. Dokumentengenerierung (Document Generation)
- **Kernaufgabe:** Erstellung von Policen, Nachtraegen, Korrespondenz, Bescheiden
- **Entitaeten:** Vorlage, Dokument, Druckauftrag, Archivdokument
- **Geschaetzter Tabellenanteil:** ~40 Tabellen

### 6. Partner & Vertrieb (Distribution)
- **Kernaufgabe:** Vermittler, Provisionen, Vertriebswege
- **Entitaeten:** Vermittler, Provision, Courtage, Vertriebskanal, Abrechnungslauf
- **Geschaetzter Tabellenanteil:** ~40 Tabellen

### 7. Inkasso & Buchhaltung (Billing & Accounting)
- **Kernaufgabe:** Beitragseinzug, Mahnwesen, Hauptbuchintegration
- **Entitaeten:** Beitragskonto, Mahnung, Zahlung, Buchungssatz, SEPA-Mandat
- **Geschaetzter Tabellenanteil:** ~30 Tabellen

## Beziehungen zwischen Kontexten

| Upstream              | Downstream            | Beziehungstyp               |
|-----------------------|-----------------------|-----------------------------|
| Kundenverwaltung      | Vertragsmanagement    | Customer-Supplier           |
| Kundenverwaltung      | Schadensbearbeitung   | Customer-Supplier           |
| Vertragsmanagement    | Praemienberechnung    | Conformist                  |
| Vertragsmanagement    | Schadensbearbeitung   | Customer-Supplier           |
| Vertragsmanagement    | Dokumentengenerierung | Customer-Supplier           |
| Praemienberechnung    | Inkasso & Buchhaltung | Customer-Supplier           |
| Schadensbearbeitung   | Dokumentengenerierung | Customer-Supplier           |
| Vertragsmanagement    | Partner & Vertrieb    | Partnership                 |

## Integrationsmuster

### Anti-Corruption Layer (ACL)
Jeder neue extrahierte Service muss einen ACL gegen die Legacy-Datenbank betreiben, solange die Migration laeuft.

### Shared Kernel (Uebergangsphase)
Waehrend der Migration teilen sich Kontexte unvermeidlich die Oracle-Datenbank. Diese Kopplung wird schrittweise durch Events und APIs ersetzt.

### Domain Events (Zielzustand)
- `VertragAbgeschlossen` --> Praemienberechnung, Dokumentengenerierung, Partner
- `SchadenGemeldet` --> Dokumentengenerierung, Kundenverwaltung
- `PraemieBerechnet` --> Inkasso, Vertragsmanagement
- `KundeAktualisiert` --> Vertragsmanagement, Schadensbearbeitung
