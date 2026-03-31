---
id: COMP-003
name: PCI-DSS Compliance
category: compliance
severity: mandatory
applies_to:
  - payment
  - credit-card
  - financial-data
---

## Anforderung

Systeme die Kreditkartendaten verarbeiten müssen PCI-DSS Level 1 compliant sein.
Kreditkartennummern dürfen nicht im Klartext gespeichert werden.

## Prüfkriterien

- [ ] Kreditkartennummern werden tokenisiert gespeichert
- [ ] Keine vollständigen Kartennummern in Logs
- [ ] Jährliches PCI-DSS Audit bestanden
