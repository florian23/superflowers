---
id: COMP-002
name: Audit Logging
category: compliance
severity: mandatory
applies_to:
  - api
  - data-mutation
  - admin-operations
---

## Anforderung

Alle schreibenden Operationen auf Geschäftsdaten müssen in einem unveränderlichen Audit-Log protokolliert werden. Das Log muss enthalten: Wer, Was, Wann, Ergebnis.

## Begründung

SOX-Compliance, interne Revisions-Anforderung REV-2024-01.

## Implikationen für die Entwicklung

- Audit-Log als separater, append-only Speicher
- Jede schreibende Operation loggen (Create, Update, Delete)
- Keine PII im Audit-Log (nur IDs und Operationstypen)
- Log-Retention: mindestens 7 Jahre

## Prüfkriterien

- [ ] Alle POST/PUT/DELETE Operationen werden geloggt
- [ ] Audit-Log enthält: userId, operation, timestamp, result
- [ ] Audit-Log ist append-only (keine Löschung möglich)
- [ ] Keine personenbezogenen Daten im Audit-Log
