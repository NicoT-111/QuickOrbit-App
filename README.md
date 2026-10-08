# QuickOrbit

QuickOrbit ist eine macOS-App mit Orbit, Schnellleiste und lokalen Aktionen. Die [Website](https://nicot-111.github.io/QuickOrbit/) bleibt im bisherigen Web-Repository. **Die App und ihre zukünftigen Releases liegen hier.**

Die jeweils aktuelle, fertig gebaute App steht unter [Releases](https://github.com/NicoT-111/QuickOrbit-App/releases). Für die manuelle Installation die ZIP herunterladen, entpacken und `QuickOrbit.app` nach „Programme“ ziehen. Die App benötigt macOS 14 oder neuer. Manche Aktionen benötigen eine gesonderte macOS-Freigabe.

## Updates

Ab Version 57 fragt die App den signierten `appcast.xml`-Feed des neuesten Releases in diesem Repository ab. Für jedes Release werden `QuickOrbit-v<Version>.zip` und `appcast.xml` gemeinsam veröffentlicht. Bereits installierte Version 56 nutzt noch den Feed im bisherigen Repository; dafür ist eine einmalige Feed-Brücke erforderlich. Details stehen in [Update-Einrichtung](GitHub-Release/UPDATE-EINRICHTUNG.md).

## Quellcode und Rechte

Der Quellcode ist hier zur Einsicht veröffentlicht; es wird **keine Open-Source-Lizenz** erteilt. Bitte [COPYRIGHT.md](COPYRIGHT.md) lesen. Das Ansehen und Forken innerhalb von GitHub bleibt nach dessen Nutzungsbedingungen möglich; darüber hinaus ist die Veröffentlichung keine Erlaubnis, die App oder den Code zu verändern oder weiterzuverbreiten. Die unveränderte offizielle App darf für den eigenen Gebrauch genutzt werden. Rechte von Drittanbietern bleiben unberührt.

Zum lokalen Bauen `Build.command` verwenden. Es lädt bei Bedarf Sparkle 2.10.0 von dessen offizieller Release-Seite und prüft die SHA-256-Prüfsumme. Der private Updateschlüssel ist **nicht** Teil dieses Repositorys. Öffentliche Releases für andere Macs sollten mit Developer ID signiert und von Apple notarisiert sein; lokale Test-Builds werden nur ad-hoc signiert.
