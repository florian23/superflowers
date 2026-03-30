Feature: Feature-Zyklus-Erkennung
  Als Nutzer des Compliance Reports
  will ich Feature-Zyklen automatisch aus der Git-Historie erkannt haben
  damit ich die Entwicklung pro Feature nachvollziehen kann

  Background:
    Given ein Git-Repository mit Commit-Historie

  @critical
  Scenario: Worktree-Branch als Feature-Zyklus erkennen
    Given ein Branch "worktree/auth-system" mit 5 Commits
    And der Branch wurde in main gemergt
    When der Compliance Report generiert wird
    Then wird "auth-system" als Feature-Zyklus erkannt
    And der Zyklus enthält alle 5 Commits

  @critical
  Scenario: Spec-Commit als Zyklusstart erkennen
    Given ein Commit der "docs/superflowers/specs/2026-03-10-auth-design.md" erstellt
    And nachfolgende Implementierungs-Commits im selben Branch
    When der Compliance Report generiert wird
    Then wird ein Feature-Zyklus mit Startdatum "2026-03-10" erkannt
    And der Spec-Commit wird als Zyklusstart markiert

  @critical
  Scenario: Feature-Zyklus durch Feature-File-Commits erkennen
    Given ein Commit der "features/authentication.feature" erstellt
    And nachfolgende Implementierungs-Commits
    When der Compliance Report generiert wird
    Then werden die Feature-File-Commits dem Zyklus zugeordnet

  Scenario: Mehrere Feature-Zyklen chronologisch sortieren
    Given 3 Feature-Zyklen zu verschiedenen Zeitpunkten
    When der Compliance Report generiert wird
    Then werden alle 3 Zyklen erkannt
    And sie sind chronologisch sortiert

  @edge-case
  Scenario: Commits ohne erkennbaren Feature-Zyklus
    Given Commits die keinem Worktree-Branch oder Spec zugeordnet werden können
    When der Compliance Report generiert wird
    Then werden diese Commits als "unzugeordnet" gruppiert
