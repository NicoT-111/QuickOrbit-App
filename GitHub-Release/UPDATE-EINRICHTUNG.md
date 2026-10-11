# QuickOrbit-Updates über GitHub

QuickOrbit verwendet Sparkle 2.10.0. Der Feed liegt als signiertes `appcast.xml`-Asset im jeweils neuesten Release von `NicoT-111/QuickOrbit-App`; daneben liegt die passende `QuickOrbit-v<Version>.zip`.

## Einmaliger Wechsel zu v59

Version 56 verwendet einen nicht mehr erreichbaren Feed. Version 57 hat in der Sandbox keine ausgehende Netzwerkberechtigung. Version 58 kann den Feed laden, aber der Sparkle-Installer war noch nicht vollständig für die Sandbox konfiguriert. Daher ist v59 die empfohlene einmalige manuelle Installation: QuickOrbit beenden, die aktuelle ZIP aus dem [neuesten Release](https://github.com/NicoT-111/QuickOrbit-App/releases/latest) laden, entpacken und `QuickOrbit.app` in „Programme“ ersetzen. Profile und Einstellungen liegen außerhalb des App-Bundles und werden dadurch nicht gezielt gelöscht.

Ab v59 sind der ausgehende Netzwerkzugriff, `SUEnableInstallerLauncherService` und die benötigten Mach-Lookup-Ausnahmen eingerichtet. Die Sparkle-Hilfsprogramme werden getrennt signiert. Damit sind die laut [Sparkle-Sandbox-Anleitung](https://sparkle-project.org/documentation/sandboxing/) erforderlichen Voraussetzungen vorhanden. Ein vollständiger v59→späterer-Version-Installationstest auf einem separaten Mac bleibt vor breiter Verteilung nötig.

## Neue Version veröffentlichen

1. Beide Versionsnummern in `Packaging/Info.plist` erhöhen und `GitHub-Release/ReleaseNotes-v<Version>.md` anlegen. Veröffentlichte Tags und ZIP-Dateien nicht nachträglich ersetzen.
2. `Build.command` und `Generate-Update-Feed.command` ausführen. Sie erzeugen die Universal-App und signieren ZIP sowie Feed mit dem privaten Ed25519-Schlüssel. Dieser Schlüssel darf nie ins Repository oder Release gelangen.
3. Ein neues öffentliches GitHub-Release mit Tag `v<Version>` vom aktuellen Quellstand anlegen, als „Latest“ markieren und **beide** Assets hochladen: `QuickOrbit-v<Version>.zip` und `Updates/appcast.xml`.
4. Den Live-Feed über `https://github.com/NicoT-111/QuickOrbit-App/releases/latest/download/appcast.xml` und den ZIP-Download prüfen. In einer installierten älteren Version den manuellen Update-Check, Download, Ersatz und Neustart testen.

`Publish-GitHub-Release.command --publish` kann die Veröffentlichung mit angemeldeter GitHub CLI übernehmen; andernfalls ist der manuelle Upload möglich. Die automatische Suche läuft ungefähr alle sechs Stunden, solange die App läuft. Ein Release-Upload ist kein sofortiger Push an alle Nutzer.

Für eine reibungsarme öffentliche Verteilung werden Apple Developer ID-Signierung und Notarisierung empfohlen. Ohne `QUICKORBIT_SIGNING_IDENTITY` entsteht nur eine ad-hoc-Signatur; macOS kann vor dem ersten Start warnen. `QUICKORBIT_NOTARY_PROFILE` unterstützt die Notarisierung. Der private Updateschlüssel liegt lokal außerhalb des Repositorys und muss sicher aufbewahrt werden.
