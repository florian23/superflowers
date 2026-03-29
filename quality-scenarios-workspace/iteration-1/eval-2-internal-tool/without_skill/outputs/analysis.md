# Analyse

## Zusammenfassung

5 Quality Scenarios erstellt fuer ein internes Tool (2 Entwickler, Modular Monolith). Fokus auf minimalen Overhead — nur Szenarien, die direkt aus den definierten Architecture Characteristics abgeleitet sind.

## Abdeckung der Architecture Characteristics

| Characteristic | Priority | Anzahl Szenarien | Abgedeckt |
|---|---|---|---|
| Simplicity | Critical | 1 (QS-1) | Ja |
| Testability | Critical | 1 (QS-2) | Ja |
| Maintainability | Critical | 1 (QS-3) | Ja |
| Security | Important | 2 (QS-4, QS-5) | Ja |

## Fitness-Function-Eignung

| Szenario | Automatisierbar | Empfohlenes Tooling |
|---|---|---|
| QS-1 (Simplicity) | Nein | Manuell bei Onboarding pruefen |
| QS-2 (Testability) | Ja | Coverage-Tool (z.B. JaCoCo, Istanbul) in CI |
| QS-3 (Maintainability) | Ja | Linter/Statische Analyse (z.B. ESLint, SonarQube) in CI |
| QS-4 (Security/RBAC) | Ja | Integrationstest gegen geschuetzte Routen |
| QS-5 (Security/Audit) | Ja | Test-Assertion auf Audit-Log-Eintraege |

## Entscheidungen

- **5 statt mehr Szenarien**: Bei 2 Entwicklern und internem Tool ist weniger Overhead wichtiger als lueckenlose Abdeckung. Jedes Szenario ist direkt aus architecture.md abgeleitet.
- **Security in 2 Szenarien aufgeteilt**: RBAC und Audit-Log sind unabhaengig testbar und haben unterschiedliche Stimuli.
- **Keine Performance-Szenarien**: Internes Tool ohne Performance-Anforderung in den Characteristics — bewusst weggelassen.
- **Sprache**: Szenarien auf Deutsch, da Anfrage auf Deutsch und internes Team.

## Risiken

- **QS-1 nicht automatisierbar**: Simplicity lässt sich nur indirekt messen. Empfehlung: README und Setup-Skript aktuell halten.
- **Coverage-Ziel 90%**: Bei kleinem Team realistisch, aber Threshold muss im CI konfiguriert werden, sonst bleibt es eine Absicht.
