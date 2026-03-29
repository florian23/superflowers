# Bounded Context Analysis: Internes Zeiterfassungs-Tool

## Ausgangslage

- 30 Mitarbeiter, 1 Entwickler
- Einfache CRUD-App
- Mitarbeiter loggen Stunden auf Projekte
- Manager genehmigen Eintraege
- Monatlicher CSV-Export fuer Buchhaltung

## Analyse

### Drei identifizierte Kontexte -- aber brauchen wir sie getrennt?

Aus DDD-Perspektive lassen sich drei fachliche Bereiche erkennen: Zeiterfassung, Genehmigung und Reporting. Die entscheidende Frage ist jedoch, ob eine Trennung in separate Bounded Contexts bei diesem Projektumfang sinnvoll ist.

### Empfehlung: Ein einziger Bounded Context

**Fuer dieses Projekt ist ein einzelner Bounded Context die richtige Wahl.**

Gruende:

1. **Teamgroesse:** Ein Entwickler. Bounded Contexts dienen primaer der Entkopplung zwischen Teams. Bei einem Ein-Personen-Team gibt es keine organisatorische Grenze, die modelliert werden muss.

2. **Komplexitaet:** Einfache CRUD-Operationen mit einem linearen Workflow (erfassen -> genehmigen -> exportieren). Kein konkurrierendes Domainverstaendnis, keine widerspruechlichen Modelle.

3. **Nutzeranzahl:** 30 Mitarbeiter erzeugen keine Last, die eine Zerlegung in Services rechtfertigt.

4. **Shared Entities:** `Employee`, `Project` und `TimeEntry` werden in allen drei Bereichen benoetigt. Bei getrennten Kontexten muesste man diese Entitaeten duplizieren oder synchronisieren -- ein unverhältnismaessiger Aufwand.

5. **Datenbank:** Eine einzige relationale Datenbank mit wenigen Tabellen (employees, projects, time_entries, approvals) deckt alles ab. Joins sind einfacher als kontextuebergreifende Queries.

### Interne Strukturierung statt Kontexttrennung

Statt separate Bounded Contexts empfehle ich eine modulare Paketstruktur innerhalb eines Kontexts:

```
src/
  timetracking/
    model/          -- TimeEntry, Project, Employee
    api/            -- REST-Endpunkte fuer CRUD
  approval/
    model/          -- ApprovalStatus (Enum)
    api/            -- Genehmigungs-Endpunkte
  export/
    service/        -- CSV-Generator
    api/            -- Export-Endpunkt
```

Dies haelt die fachlichen Bereiche lesbar getrennt, ohne den Overhead separater Kontexte.

### Wann wuerde sich eine Trennung lohnen?

Eine Aufteilung in echte Bounded Contexts waere erst sinnvoll, wenn:

- Mehrere Entwicklerteams unabhaengig arbeiten muessen
- Die Genehmigungslogik deutlich komplexer wird (mehrstufig, regelbasiert)
- Das Reporting eigenstaendige, komplexe Auswertungen benoetigt
- Unterschiedliche Deployment- oder Skalierungsanforderungen entstehen

Keiner dieser Faktoren trifft aktuell zu.

## Fazit

Die drei fachlichen Bereiche (Zeiterfassung, Genehmigung, Export) sind **Module innerhalb eines einzelnen Bounded Contexts**, nicht eigenstaendige Kontexte. Die Context Map zeigt die fachlichen Abhaengigkeiten, aber die Implementierung sollte als ein Monolith mit sauberer interner Struktur erfolgen. Das ist die pragmatische Loesung fuer ein Ein-Entwickler-Projekt mit 30 Nutzern.
