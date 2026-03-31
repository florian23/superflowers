---
id: SEC-001
name: Encryption at Rest
category: security
severity: mandatory
applies_to:
  - data-storage
  - database
  - file-handling
---

## Anforderung

Alle persistierten Daten müssen verschlüsselt gespeichert werden (AES-256 oder gleichwertig).

## Begründung

ISO 27001 Anforderung, Unternehmensrichtlinie IT-SEC-2024-03.

## Implikationen für die Entwicklung

- Datenbanken: Transparent Data Encryption (TDE) aktivieren
- Dateisysteme: Verschlüsselte Volumes verwenden
- Kein Klartext in Logs für sensible Daten
- Key Management über zentrales KMS

## Prüfkriterien

- [ ] Alle Datenbanken nutzen TDE oder äquivalente Verschlüsselung
- [ ] Keine sensiblen Daten im Klartext in Logdateien
- [ ] Encryption Keys werden im Key Management System verwaltet
- [ ] Backup-Daten sind ebenfalls verschlüsselt
