# QuickOrbit

QuickOrbit ist eine macOS-App mit Orbit, Schnellleiste und lokalen Aktionen. Die [Website](https://nicot-111.github.io/QuickOrbit-Website/) liegt in einem eigenen Repository. **Die App und ihre Releases liegen hier.**

Die aktuelle App steht unter [Releases](https://github.com/NicoT-111/QuickOrbit-App/releases/latest). Für die manuelle Installation die ZIP herunterladen, entpacken, QuickOrbit beenden und `QuickOrbit.app` in „Programme“ ersetzen. Die App benötigt macOS 14 oder neuer. Manche Aktionen benötigen eine gesonderte macOS-Freigabe.

## Updates

Ab Version 59 sind Update-Suche und Sparkle-Installer für die Sandbox konfiguriert. Die App lädt den signierten `appcast.xml`-Feed des neuesten Releases in diesem Repository. Für jedes Release werden `QuickOrbit-v<Version>.zip` und `appcast.xml` gemeinsam veröffentlicht.

Version 57 kann wegen fehlender Netzwerkberechtigung kein Update selbst abrufen. Version 56 nutzt außerdem einen nicht mehr erreichbaren Feed im alten Repository. Diese Versionen müssen einmalig manuell durch v59 ersetzt werden. Version 58 konnte den Feed laden, hatte aber noch nicht die vollständige Installer-Konfiguration. Details stehen in [Update-Einrichtung](GitHub-Release/UPDATE-EINRICHTUNG.md).

## Quellcode und Rechte

Der Quellcode ist hier zur Einsicht veröffentlicht; es wird **keine Open-Source-Lizenz** erteilt. Bitte [COPYRIGHT.md](COPYRIGHT.md) lesen. Das Ansehen und Forken innerhalb von GitHub bleibt nach dessen Nutzungsbedingungen möglich; darüber hinaus ist die Veröffentlichung keine Erlaubnis, die App oder den Code zu verändern oder weiterzuverbreiten. Die unveränderte offizielle App darf für den eigenen Gebrauch genutzt werden. Rechte von Drittanbietern bleiben unberührt.

Zum lokalen Bauen im Terminal `zsh Build.command` ausführen. Es lädt bei Bedarf Sparkle 2.10.0 von dessen offizieller Release-Seite und prüft die SHA-256-Prüfsumme. Der private Updateschlüssel ist **nicht** Teil dieses Repositorys. Öffentliche Releases für andere Macs sollten mit Developer ID signiert und von Apple notarisiert sein; lokale Test-Builds werden nur ad-hoc signiert.
