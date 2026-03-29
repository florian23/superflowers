# Bounded Context Map: E-Commerce Plattform

## Identifizierte Bounded Contexts

### 1. Product Catalog (Produktkatalog)
- **Verantwortung:** Produktdaten, Kategorien, Attribute, Preise, Verfuegbarkeit, Produktsuche
- **Kernentitaeten:** Product, Category, Price, ProductAttribute
- **Team-Zuordnung:** Team 1

### 2. Order Management (Bestellung & Warenkorb)
- **Verantwortung:** Warenkorb-Verwaltung, Checkout-Prozess, Bestellabwicklung, Bestellstatus
- **Kernentitaeten:** Cart, CartItem, Order, OrderLine, OrderStatus
- **Team-Zuordnung:** Team 2

### 3. Payment (Bezahlung)
- **Verantwortung:** Zahlungsabwicklung, Zahlungsmethoden, Rueckerstattungen, Zahlungsstatus
- **Kernentitaeten:** Payment, PaymentMethod, Transaction, Refund
- **Team-Zuordnung:** Team 2

### 4. Shipping & Fulfillment (Versand)
- **Verantwortung:** Versandoptionen, Sendungsverfolgung, Lagerbestand, Kommissionierung, Retouren
- **Kernentitaeten:** Shipment, TrackingInfo, Warehouse, InventoryItem, Return
- **Team-Zuordnung:** Team 3

### 5. Customer Management (Kundenverwaltung)
- **Verantwortung:** Kundenprofile, Authentifizierung, Adressen, Bestellhistorie-Zugriff, Praeferenzen
- **Kernentitaeten:** Customer, Address, CustomerProfile, Credentials
- **Team-Zuordnung:** Team 1

### 6. Recommendation (Empfehlungssystem)
- **Verantwortung:** Produktempfehlungen, Personalisierung, Kaufverhalten-Analyse, Trending-Produkte
- **Kernentitaeten:** RecommendationModel, CustomerBehavior, ProductScore, BrowsingHistory
- **Team-Zuordnung:** Team 3

---

## Context Map (Beziehungen)

```
+-------------------+        +---------------------+
|  Product Catalog  |<------=|   Recommendation    |
|    (Team 1)       | CF     |     (Team 3)        |
+-------------------+        +---------------------+
        |                             ^
        | PL                          | CF
        v                             |
+-------------------+        +---------------------+
| Order Management  |------->| Customer Management |
|    (Team 2)       | CF     |     (Team 1)        |
+-------------------+        +---------------------+
    |           |
    | PL        | PL
    v           v
+-----------+  +---------------------+
|  Payment  |  | Shipping/Fulfillment|
|  (Team 2) |  |     (Team 3)        |
+-----------+  +---------------------+
```

### Beziehungstypen

| Upstream              | Downstream            | Beziehung                | Typ                        |
|-----------------------|-----------------------|--------------------------|----------------------------|
| Product Catalog       | Order Management      | Produktdaten im Warenkorb | Published Language (PL)   |
| Order Management      | Payment               | Zahlungsausloesung       | Published Language (PL)    |
| Order Management      | Shipping/Fulfillment  | Versandauftrag           | Published Language (PL)    |
| Customer Management   | Order Management      | Kundendaten              | Conformist (CF)            |
| Product Catalog       | Recommendation        | Produktdaten-Feed        | Conformist (CF)            |
| Customer Management   | Recommendation        | Kundenverhalten          | Conformist (CF)            |

### Legende
- **PL (Published Language):** Upstream definiert ein stabiles API/Event-Schema, Downstream konsumiert es
- **CF (Conformist):** Downstream uebernimmt das Modell des Upstream ohne eigene Uebersetzung
