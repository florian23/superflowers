# Context Map

## Last Updated: 2026-03-29

## Subdomains

| Subdomain | Type | Bounded Context(s) |
|---|---|---|
| Vertragsmanagement | Core | Vertragswesen |
| Schadensbearbeitung | Core | Schadenregulierung |
| Praemienberechnung | Core | Tarifierung & Praemie |
| Kundenverwaltung | Supporting | Kundendomaene |
| Dokumentengenerierung | Supporting | Dokumentenservice |
| Bestandsfuehrung (Legacy) | — | Monolith (Bestandssystem) |

## Bounded Contexts

### Monolith (Bestandssystem)

- **Subdomain:** Legacy (alle Subdomains derzeit verschmolzen)
- **Responsibility:** Der existierende Java-Monolith mit 400-Tabellen-Oracle-DB, der aktuell alle Geschaeftsfunktionen abbildet. Wird schrittweise abgeloest, bleibt aber waehrend der Migration das System of Record.
- **Team:** Bestandsteam (bestehendes Entwicklungsteam)
- **Ubiquitous Language:**
  | Term | Meaning |
  |---|---|
  | Vertrag | Datenbanksatz in der zentralen Vertragstabelle — vermischt Police, Nachtrag, Antrag |
  | Schaden | Schadensfall mit Verknuepfung zu Vertrag, Kunde, Zahlung in einer Struktur |
  | Kunde | Einzelne Entitaet fuer Versicherungsnehmer, Ansprechpartner, Makler, Geschaedigten |
  | Praemie | Berechnungsergebnis, fest verdrahtet mit Vertragslogik |
  | Dokument | Generiertes PDF, gekoppelt an Drucksteuerung, Vorlagen, Archivierung |

### Vertragswesen

- **Subdomain:** Core
- **Responsibility:** Verwaltung des gesamten Vertragslebenszyklus — Antrag, Policierung, Nachtrag, Kuendigung, Wiederinkraftsetzung.
- **Team:** Team Vertrag (neues Team, erstes Extraktionsziel)
- **Ubiquitous Language:**
  | Term | Meaning |
  |---|---|
  | Antrag | Versicherungsantrag vor Policierung — hat Risikopruefungsstatus |
  | Police | Aktiver, policierter Versicherungsvertrag mit definierten Deckungen |
  | Nachtrag | Aenderung an einer bestehenden Police (Deckungserweiterung, Adressaenderung, etc.) |
  | Versicherungsnehmer | Die Person oder Organisation, die den Vertrag haelt (NICHT der Geschaedigte im Schadenfall) |
  | Deckung | Einzelne versicherte Gefahr/Leistung innerhalb einer Police |
  | Vertragsstatus | Lebenszyklus-Zustand: beantragt, aktiv, ruhend, gekuendigt |

### Schadenregulierung

- **Subdomain:** Core
- **Responsibility:** Aufnahme, Pruefung und Regulierung von Versicherungsschaeden — von der Schadenmeldung bis zur Auszahlung.
- **Team:** Team Schaden
- **Ubiquitous Language:**
  | Term | Meaning |
  |---|---|
  | Schadenmeldung | Erstmeldung eines Schadensereignisses durch den Versicherungsnehmer oder Makler |
  | Schadenfall | Registrierter, gepruefter Schaden mit eigener Schadennummer |
  | Regulierung | Entscheidungsprozess: Deckungspruefung, Schadenshoehe, Auszahlung oder Ablehnung |
  | Leistung | Ausgezahlter Betrag an den Anspruchsteller |
  | Anspruchsteller | Person mit Anspruch auf Leistung (kann Versicherungsnehmer oder Dritter sein) |
  | Reserve | Geschaetzter Betrag, der fuer einen offenen Schadenfall zurueckgestellt wird |

### Tarifierung & Praemie

- **Subdomain:** Core
- **Responsibility:** Berechnung von Versicherungspraemien basierend auf Tarifen, Risikomerkmalen und Geschaeftsregeln.
- **Team:** Team Aktuariat/Tarif
- **Ubiquitous Language:**
  | Term | Meaning |
  |---|---|
  | Tarif | Regelwerk zur Praemienberechnung fuer eine Versicherungsart |
  | Praemie | Berechneter Jahresbeitrag fuer eine bestimmte Deckung und Risikosituation |
  | Risikomerkmale | Eigenschaften des versicherten Objekts/Person, die die Praemie beeinflussen |
  | Beitragsanpassung | Jaehrliche Neuberechnung bei Aenderung von Tarifgrundlagen |
  | Rabatt/Zuschlag | Modifikator auf die Grundpraemie (Schadenfreiheit, Selbstbeteiligung, etc.) |

### Kundendomaene

- **Subdomain:** Supporting
- **Responsibility:** Einheitliche Kundensicht — Stammdaten, Kontaktinformationen, Rollen (Versicherungsnehmer, Makler, Geschaedigter), Kommunikationspraeferenzen.
- **Team:** Team Kunde/Plattform
- **Ubiquitous Language:**
  | Term | Meaning |
  |---|---|
  | Kunde | Eine natuerliche oder juristische Person mit Geschaeftsbeziehung zum Versicherer |
  | Rolle | Funktion des Kunden: Versicherungsnehmer, Makler, Geschaedigter, Beguenstigter |
  | Kontaktkanal | Bevorzugte Erreichbarkeit: E-Mail, Post, Telefon, Portal |
  | Kundenhistorie | Chronologische Uebersicht aller Interaktionen und Vorgaenge |

### Dokumentenservice

- **Subdomain:** Supporting
- **Responsibility:** Generierung, Versionierung und Archivierung aller Versicherungsdokumente — Policen, Nachtraege, Schadenbriefe, Korrespondenz.
- **Team:** Team Plattform/Dokumente
- **Ubiquitous Language:**
  | Term | Meaning |
  |---|---|
  | Vorlage | Template fuer einen Dokumententyp mit Platzhaltern |
  | Dokument | Generiertes, finales Schriftstueck (PDF/Brief) mit Archivierungspflicht |
  | Dokumententyp | Klassifikation: Police, Nachtrag, Schadenmitteilung, Mahnung, etc. |
  | Versand | Zustellung ueber den gewaehlten Kanal (Post, E-Mail, Portal-Download) |

## Context Relationships

| Upstream | Downstream | Pattern | Notes |
|---|---|---|---|
| Monolith (Bestandssystem) | Vertragswesen | **Anti-Corruption Layer** | ACL uebersetzt das flache Legacy-Vertragsmodell in das reiche Domaenenmodell. Strangler-Fig-Pattern: Vertragswesen uebernimmt schrittweise Lese- und Schreiboperationen. |
| Monolith (Bestandssystem) | Schadenregulierung | **Anti-Corruption Layer** | ACL entkoppelt die verschmolzene Legacy-Schaden/Vertrag-Struktur. Schadenregulierung liest Vertragsdaten ueber definierte Schnittstelle, nie direkt aus Legacy-Tabellen. |
| Monolith (Bestandssystem) | Tarifierung & Praemie | **Anti-Corruption Layer** | ACL isoliert die neue Tarifengine von den hardcodierten Legacy-Berechnungsregeln. Parallelbetrieb moeglich (Shadow-Mode). |
| Monolith (Bestandssystem) | Kundendomaene | **Anti-Corruption Layer** | ACL uebersetzt die undifferenzierte Legacy-Kundentabelle in das rollenbasierte Kundenmodell. |
| Monolith (Bestandssystem) | Dokumentenservice | **Anti-Corruption Layer** | ACL kapselt die Legacy-Drucksteuerung. Neue Kontexte generieren Dokumente ueber den neuen Service, Legacy nutzt weiterhin die alte Druckstrasse. |
| Vertragswesen | Schadenregulierung | **Customer-Supplier** | Vertragswesen liefert Deckungsinformationen, die Schadenregulierung fuer die Deckungspruefung benoetigt. |
| Vertragswesen | Tarifierung & Praemie | **Customer-Supplier** | Tarifierung berechnet Praemien fuer Vertraege; Vertragswesen liefert Risikodaten und erhaelt berechnete Praemien zurueck. |
| Kundendomaene | Vertragswesen | **Open Host Service** | Kundenstammdaten werden ueber eine definierte API bereitgestellt. Alle Kontexte konsumieren dieselbe Schnittstelle. |
| Kundendomaene | Schadenregulierung | **Open Host Service** | Gleiche API wie oben — Schadenregulierung bezieht Anspruchsteller-Daten. |
| Vertragswesen | Dokumentenservice | **Published Language** | Vertragswesen publiziert Ereignisse (PoliceErstellt, NachtragDurchgefuehrt) als strukturierte Events, Dokumentenservice reagiert darauf und generiert Dokumente. |
| Schadenregulierung | Dokumentenservice | **Published Language** | Schadenereignisse (SchadenAnerkannt, LeistungAusgezahlt) triggern Dokumentengenerierung. |

## Relationship Diagram

```
                    ┌─────────────────────────────────────────────────┐
                    │         MONOLITH (Bestandssystem)               │
                    │   Java · 400 Oracle-Tabellen · 10 Jahre alt    │
                    └──────┬────────┬────────┬───────┬────────┬──────┘
                      ACL  │   ACL  │   ACL  │  ACL  │   ACL  │
                    ┌──────▼──┐ ┌───▼────┐ ┌─▼──────┐│  ┌─────▼──────┐
                    │Vertrags-│ │Schaden-│ │Tarif. &││  │Dokumenten- │
                    │ wesen   │ │regul.  │ │Praemie ││  │ service    │
                    │ (Core)  │ │(Core)  │ │(Core)  ││  │(Supporting)│
                    └──┬──┬───┘ └───▲──▲─┘ └──▲─────┘│  └──▲────▲───┘
                       │  │  C-S    │  │  C-S  │      │     │    │
                       │  └─────────┘  │       │      │     │    │
                       │       C-S     │───────┘      │     │    │
                       │               │              │     │    │
                       │  Pub.Lang.    │  Pub.Lang.   │     │    │
                       └───────────────┼──────────────┼─────┘    │
                                       └──────────────┼──────────┘
                                                      │
                                               ┌──────▼──────┐
                                               │  Kunden-    │
                                               │  domaene    │
                                               │ (Supporting)│
                                               │   OHS API   │
                                               └─────────────┘

Legende:
  ACL        = Anti-Corruption Layer (gegen Legacy)
  C-S        = Customer-Supplier
  OHS        = Open Host Service
  Pub.Lang.  = Published Language (Event-basiert)
```

## Migration Sequence (Strangler Fig)

| Phase | Kontext extrahieren | Abhaengigkeit | Risiko |
|---|---|---|---|
| 1 | **Tarifierung & Praemie** | Keine Downstream-Abhaengigkeiten; kann im Shadow-Mode parallel laufen | Niedrig — Ergebnis ist verifizierbar (gleiche Praemie?) |
| 2 | **Kundendomaene** | Wird von allen anderen Kontexten benoetigt — frueh extrahieren | Mittel — Stammdatenmigration komplex |
| 3 | **Dokumentenservice** | Rein reaktiv, konsumiert Events, keine Business-Logik-Abhaengigkeit | Niedrig — kann Event-getrieben angebunden werden |
| 4 | **Vertragswesen** | Core, hoechste Komplexitaet, benoetigt Kunde + Tarif | Hoch — zentraler Kontext, schrittweise per Nachtrag-Typ |
| 5 | **Schadenregulierung** | Benoetigt Vertrag + Kunde, komplexe Regulierungslogik | Hoch — erst nach stabilem Vertragswesen |
