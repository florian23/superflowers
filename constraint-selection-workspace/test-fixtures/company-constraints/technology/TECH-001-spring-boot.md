---
id: TECH-001
name: Spring Boot für Webservices
category: technology
severity: recommended
applies_to:
  - webservice
  - api
  - backend
  - microservice
---

## Empfehlung

Für neue Webservices und REST-APIs soll Spring Boot (aktuell Version 3.x) mit Kotlin oder Java verwendet werden. Spring Boot ist der Unternehmensstandard für Backend-Services.

## Begründung

Standardisierung der Tech-Stack, vorhandene Expertise im Team, bestehende CI/CD-Pipelines sind auf Spring Boot optimiert.

## Ausnahmen

- CLI-Tools und Scripts: Python oder Go bevorzugt
- Frontend: nicht relevant
- Data Processing Pipelines: Apache Spark/Flink erlaubt

## Prüfkriterien

- [ ] Neuer Webservice nutzt Spring Boot 3.x
- [ ] Kotlin oder Java als Sprache
- [ ] Standard Spring Boot Projektstruktur
