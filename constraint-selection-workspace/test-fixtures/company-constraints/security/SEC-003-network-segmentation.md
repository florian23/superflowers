---
id: SEC-003
name: Network Segmentation
category: security
severity: recommended
applies_to:
  - infrastructure
  - deployment
  - networking
---

## Anforderung

Produktions-Services müssen in segmentierten Netzwerken betrieben werden. Datenbank-Server dürfen nicht direkt aus dem Internet erreichbar sein.

## Begründung

Defense-in-depth Strategie. Minimiert Blast Radius bei Kompromittierung.

## Prüfkriterien

- [ ] Datenbanken sind nur aus dem Applikations-Netz erreichbar
- [ ] Keine direkte Internet-Verbindung zu Datenbank-Servern
- [ ] Service-to-Service Kommunikation über internes Netz
