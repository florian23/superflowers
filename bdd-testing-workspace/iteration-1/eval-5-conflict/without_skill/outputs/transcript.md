# Transcript: Eval 5 - Conflict zwischen Test und neuem Feature

## Frage
Ich implementiere gerade ein neues Feature in /tmp/bdd-eval-5/. Das Scenario 'Einfache Suche' erwartet exakte Matches aber mein neuer Code macht Fuzzy-Matching. Soll ich den Test anpassen?

## Analyse

### Projektstruktur
- `/tmp/bdd-eval-5/features/suche.feature` - BDD Feature-Datei
- `/tmp/bdd-eval-5/features/step_definitions/suche-steps.js` - Step Definitions
- `/tmp/bdd-eval-5/package.json` - Projektdatei mit Cucumber-Dependency

### Feature-Datei (suche.feature)
Zwei Scenarios:
1. **Einfache Suche**: Erwartet, dass bei Suche nach "Server" in ["Server", "Service", "Database"] genau EIN Ergebnis gefunden wird - exakt "Server".
2. **Keine Treffer**: Erwartet, dass bei Suche nach "Router" in ["Server", "Service"] keine Ergebnisse kommen.

### Step Definition (suche-steps.js)
Die aktuelle Implementierung im When-Step nutzt strikten Gleichheitsvergleich:
```js
results = nodes.filter(n => n === term);
```

### Kernproblem
Die Frage ist: Soll der Test angepasst werden, weil der neue Code Fuzzy-Matching statt exaktem Matching macht?

## Empfehlung

**Nein, den bestehenden Test NICHT einfach anpassen.** Stattdessen sollte differenziert vorgegangen werden:

1. **Das Scenario "Einfache Suche" beschreibt gewuenschtes Verhalten, nicht Implementierungsdetails.** Die Formulierung "wird genau der Knoten 'Server' gefunden" drueckt eine klare fachliche Erwartung aus: Bei einer Suche nach "Server" soll exakt dieser Knoten gefunden werden - nicht auch "Service" (was bei Fuzzy-Matching passieren koennte, da "Server" und "Service" sich aehnlich sind).

2. **Tests an neuen Code anpassen ist ein Anti-Pattern**, wenn das urspruengliche Verhalten weiterhin korrekt sein soll. BDD-Scenarios dokumentieren fachliche Anforderungen. Wenn das Szenario sagt "genau der Knoten 'Server'", dann ist das die Spezifikation.

3. **Stattdessen sollte der bestehende Test erhalten bleiben UND ein neues Scenario fuer Fuzzy-Matching hinzugefuegt werden**, z.B.:

```gherkin
Scenario: Fuzzy-Suche findet aehnliche Knoten
  Given Knoten mit Labels "Server", "Service", "Database"
  When ich fuzzy nach "Serv" suche
  Then werden die Knoten "Server", "Service" gefunden
```

4. **Das Scenario "Keine Treffer" ist ebenfalls kritisch**: Bei Fuzzy-Matching koennte "Router" ploetzlich Treffer liefern (z.B. "Router" aehnlich zu "Server"?). Dieses Scenario muss weiterhin bestehen bleiben, um sicherzustellen, dass nicht alles gematcht wird.

5. **In der Step Definition sollte der When-Step differenziert werden**: Ein Step fuer exakte Suche und ein Step fuer Fuzzy-Suche, oder die Suche akzeptiert einen Modus-Parameter.

### Zusammenfassung
Den bestehenden Test anzupassen waere falsch - er drueckt eine gueltige fachliche Anforderung aus. Stattdessen: Neues Scenario fuer Fuzzy-Matching ergaenzen, Step Definitions erweitern, und sicherstellen dass beide Suchmodi (exakt und fuzzy) korrekt funktionieren.
