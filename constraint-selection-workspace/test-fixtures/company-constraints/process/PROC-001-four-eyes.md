## Four-Eyes-Prinzip für Produktions-Deployments

Jedes Deployment in die Produktionsumgebung muss von mindestens zwei Personen freigegeben werden. Der Entwickler darf nicht gleichzeitig der Freigeber sein.

Dies gilt für:
- Produktions-Deployments
- Datenbank-Migrationen in Produktion
- Konfigurationsänderungen an Produktions-Systemen

Nicht relevant für:
- Staging/Development Deployments
- Lokale Entwicklung
- Automatisierte Tests
