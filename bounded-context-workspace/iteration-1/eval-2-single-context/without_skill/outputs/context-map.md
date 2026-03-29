# Context Map: Internes Zeiterfassungs-Tool

## Identified Bounded Contexts

### 1. Time Tracking (Zeiterfassung)

**Core Domain**

- Mitarbeiter erfassen Arbeitsstunden auf Projekte
- CRUD-Operationen auf Zeiteintraegen (erstellen, lesen, aktualisieren, loeschen)
- Zuordnung von Stunden zu Projekten

**Key Entities:** TimeEntry, Employee, Project

---

### 2. Approval (Genehmigung)

**Supporting Subdomain**

- Manager pruefen und genehmigen erfasste Stunden
- Genehmigungsworkflow (offen, genehmigt, abgelehnt)

**Key Entities:** ApprovalRequest, Manager

---

### 3. Reporting / Export

**Generic Subdomain**

- Monatlicher CSV-Export fuer die Buchhaltung
- Aggregation genehmigter Stunden pro Mitarbeiter und Projekt

**Key Entities:** MonthlyReport, ExportFile

---

## Context Relationships

```
+-------------------+         +-------------------+         +-------------------+
|                   |         |                   |         |                   |
|   Time Tracking   |-------->|     Approval      |-------->|  Reporting/Export  |
|                   | submits |                   | approved|                   |
+-------------------+         +-------------------+  data   +-------------------+
```

- **Time Tracking -> Approval:** Upstream/Downstream (Conformist). Time Tracking liefert erfasste Eintraege an Approval.
- **Approval -> Reporting/Export:** Upstream/Downstream (Conformist). Reporting liest genehmigte Daten aus Approval.

## Domain Classification

| Context | Classification | Reason |
|---|---|---|
| Time Tracking | Core Domain | Kernfunktion der Anwendung |
| Approval | Supporting Subdomain | Unterstuetzt den Kernprozess |
| Reporting/Export | Generic Subdomain | Standard-Exportfunktion, austauschbar |
