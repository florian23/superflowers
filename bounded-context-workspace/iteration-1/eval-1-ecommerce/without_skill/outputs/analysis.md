# Bounded Context Analyse: E-Commerce Plattform

## Ausgangslage

- **Domaene:** E-Commerce Plattform
- **Fachliche Bereiche:** Produktkatalog, Warenkorb/Checkout, Bezahlung, Versand/Fulfillment, Kundenverwaltung, Empfehlungssystem
- **Teams:** 3
- **Architekturstil:** Service-Based Architecture

## Identifizierte Bounded Contexts (6)

### 1. Product Catalog

**Abgrenzung:** Verwaltet die zentrale Produktwahrheit -- was wird verkauft, zu welchem Preis, in welchen Kategorien. Dieser Context besitzt die Hoheit ueber Produktdaten.

**Ubiquitous Language:**
- *Product* -- ein verkaufbares Gut mit SKU, Name, Beschreibung
- *Category* -- hierarchische Einordnung von Produkten
- *Price* -- aktueller Verkaufspreis inkl. Aktionspreise
- *ProductAttribute* -- variable Eigenschaft (Farbe, Groesse etc.)

**Warum eigener Context:** Product hat in jedem anderen Context eine andere Bedeutung. Im Katalog ist es ein reichhaltiges Objekt mit Beschreibungen und Bildern. In der Bestellung ist es nur eine Referenz mit Preis-Snapshot. Diese Modell-Divergenz rechtfertigt die Trennung.

---

### 2. Order Management

**Abgrenzung:** Deckt den gesamten Bestellprozess ab -- vom Hinzufuegen zum Warenkorb ueber Checkout bis zur finalen Bestellung. Warenkorb und Bestellung gehoeren zusammen, weil der Warenkorb der direkte Vorlaeufer der Bestellung ist und beide denselben Lebenszyklus teilen.

**Ubiquitous Language:**
- *Cart* -- temporaere Sammlung von Kaufabsichten
- *Order* -- verbindliche Bestellung nach Checkout
- *OrderLine* -- einzelne Position mit Produktreferenz und Menge
- *OrderStatus* -- Zustand im Bestelllebenszyklus (created, paid, shipped, completed)

**Warum eigener Context:** Der Bestellprozess hat eigene Geschaeftsregeln (Mindestbestellwert, Gutscheine, Steuern) und einen klaren Lebenszyklus, der von Produktdaten und Zahlung unabhaengig ist.

---

### 3. Payment

**Abgrenzung:** Kapselt die gesamte Zahlungslogik inkl. Integration mit externen Payment-Providern (Stripe, PayPal etc.), PCI-Compliance und Rueckerstattungen.

**Ubiquitous Language:**
- *Payment* -- ein Zahlungsvorgang zu einer Bestellung
- *Transaction* -- einzelne Buchung bei einem Provider
- *Refund* -- Rueckerstattung eines Zahlungsbetrags
- *PaymentMethod* -- Kreditkarte, PayPal, Rechnung etc.

**Warum eigener Context:** Zahlungen unterliegen regulatorischen Anforderungen (PCI-DSS) und erfordern spezielle Sicherheitsmassnahmen. Die Isolation schuetzt den Rest des Systems und ermoeglicht unabhaengige Compliance-Audits.

---

### 4. Shipping & Fulfillment

**Abgrenzung:** Verantwortlich fuer alles nach der Bezahlung -- Lagerbestand, Kommissionierung, Versand, Sendungsverfolgung und Retourenabwicklung.

**Ubiquitous Language:**
- *Shipment* -- physischer Versandvorgang
- *InventoryItem* -- Lagerbestand eines Produkts
- *TrackingInfo* -- Sendungsverfolgungsdaten
- *Return* -- Retoure mit Grund und Status

**Warum eigener Context:** Fulfillment hat einen voellig anderen Rhythmus als Bestellungen -- es arbeitet mit physischen Prozessen, Lagerhaltung und Logistik-Partnern. Die Entkopplung erlaubt unabhaengige Skalierung (z.B. Weihnachtsgeschaeft).

---

### 5. Customer Management

**Abgrenzung:** Verwaltet Kundenidentitaet, Authentifizierung, Profilinformationen und Adressen. Ist die Single Source of Truth fuer "Wer ist der Kunde?".

**Ubiquitous Language:**
- *Customer* -- registrierter Benutzer mit eindeutiger ID
- *Address* -- Liefer- oder Rechnungsadresse
- *CustomerProfile* -- Praeferenzen und Einstellungen
- *Credentials* -- Login-Daten und Authentifizierungsinfo

**Warum eigener Context:** Kundendaten werden von fast allen anderen Contexts referenziert, aber nur hier veraendert. Die zentrale Verwaltung verhindert Dateninkonsistenz und buendelt Datenschutz-Anforderungen (DSGVO) an einer Stelle.

---

### 6. Recommendation

**Abgrenzung:** Analysiert Kundenverhalten und Produktdaten, um personalisierte Empfehlungen zu generieren. Konsumiert Daten, produziert aber keine transaktionalen Aenderungen.

**Ubiquitous Language:**
- *RecommendationModel* -- trainiertes Modell fuer Produktvorschlaege
- *CustomerBehavior* -- aggregiertes Kaufverhalten und Browsing-Muster
- *ProductScore* -- Relevanz-Bewertung eines Produkts fuer einen Kunden

**Warum eigener Context:** Das Empfehlungssystem arbeitet mit anderen Datenmodellen (Events, Scores, ML-Modelle) und hat einen voellig anderen technischen Stack und Aenderungsrhythmus als transaktionale Contexts.

---

## Team-Zuordnung (3 Teams, 6 Contexts)

| Team   | Bounded Contexts                        | Begruendung                                                    |
|--------|-----------------------------------------|----------------------------------------------------------------|
| Team 1 | Product Catalog, Customer Management    | Stammdaten-Team: Produkt- und Kundendaten als Kern-Assets      |
| Team 2 | Order Management, Payment               | Transaktions-Team: Bestellung und Bezahlung sind eng gekoppelt  |
| Team 3 | Shipping/Fulfillment, Recommendation    | Operations/Intelligence-Team: physische Prozesse + Datenanalyse |

**Prinzip:** Die Zuordnung folgt dem Inverse Conway Maneuver -- die Teamstruktur spiegelt die gewuenschte Architektur. Eng gekoppelte Contexts liegen bei einem Team, um Kommunikations-Overhead zwischen Teams zu minimieren.

**Hinweis zu Team 3:** Shipping und Recommendation wirken auf den ersten Blick unzusammenhaengend. Die Zuordnung ergibt sich aus der Constraint von 3 Teams. Alternativ koennte Recommendation auch zu Team 1 wandern (naehe zu Produktdaten). Sollte das Recommendation-System stark wachsen, waere es ein Kandidat fuer ein eigenes Team.

---

## Integrationsmuster fuer Service-Based Architecture

Da eine Service-Based Architecture zum Einsatz kommt (typischerweise groebere Services als Microservices, oft mit geteilter Datenbank-Infrastruktur), gelten folgende Empfehlungen:

### Synchrone Kommunikation
- **Order -> Product Catalog:** REST-API fuer Produktpreis-Abfrage beim Checkout (mit lokalem Cache)
- **Order -> Customer Management:** REST-API fuer Adress- und Kundenvalidierung

### Asynchrone Kommunikation (Events)
- **Order -> Payment:** `OrderPlaced`-Event loest Zahlungsvorgang aus
- **Payment -> Order:** `PaymentCompleted`/`PaymentFailed`-Event aktualisiert Bestellstatus
- **Order -> Shipping:** `OrderPaid`-Event loest Fulfillment aus
- **Shipping -> Order:** `ShipmentDispatched`-Event aktualisiert Bestellstatus
- **Order -> Recommendation:** `OrderCompleted`-Event fuettert das Empfehlungsmodell
- **Product Catalog -> Recommendation:** `ProductUpdated`-Events fuer Katalogaenderungen

### Daten-Ownership
Jeder Bounded Context besitzt sein eigenes Schema. In einer Service-Based Architecture koennen diese Schemas in derselben Datenbankinstanz liegen, muessen aber durch Schema-Trennung isoliert sein. Kein Context darf direkt auf Tabellen eines anderen Contexts zugreifen.

---

## Risiken und offene Punkte

1. **Warenkorb-Zuordnung:** Der Warenkorb koennte auch als eigener Context modelliert werden, falls er komplexe eigene Regeln entwickelt (z.B. gespeicherte Warenkoerbe, Wunschlisten). Aktuell ist er Teil von Order Management.

2. **Pricing-Komplexitaet:** Falls das Preismodell komplex wird (dynamische Preise, B2B-Staffelpreise, Aktionen), koennte ein eigener Pricing-Context notwendig werden.

3. **Inventory als Shared Concern:** Lagerbestand wird sowohl vom Produktkatalog (Verfuegbarkeitsanzeige) als auch von Shipping/Fulfillment (tatsaechlicher Bestand) benoetigt. Die Hoheit liegt bei Fulfillment, der Katalog bekommt eine projizierte Sicht via Event.

4. **Team 3 Heterogenitaet:** Shipping und Recommendation erfordern unterschiedliche Kompetenzen. Bei Teamwachstum sollte hier zuerst gesplittet werden.
