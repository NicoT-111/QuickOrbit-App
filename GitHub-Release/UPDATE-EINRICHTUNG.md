# QuickOrbit-Updates über GitHub

Die App verwendet Sparkle 2.10.0. Nutzer können automatisch prüfen lassen, manuell nach Updates suchen und nach der Einrichtung auch Updates automatisch laden und installieren lassen. Versionen und Änderungen erscheinen im nativen Update-Fenster. Automatische Installation ist eine eigene Nutzereinstellung; ein laufender Orbit wird nicht sofort ohne Vorankündigung durch einen Neustart unterbrochen.

## Einmalig einrichten

1. Das neue App-Repository `https://github.com/NicoT-111/QuickOrbit-App` prüfen. App-ZIP und `appcast.xml` müssen dort gemeinsam im neuesten Release liegen. Die Website bleibt im bisherigen Repository `NicoT-111/QuickOrbit`. Falls das App-Repository später umbenannt wird, müssen `SUFeedURL` in `Packaging/Info.plist`, die GitHub-Adresse in `Source/QuickOrbit.swift` und `repository` in beiden Veröffentlichungsskripten angepasst werden.
2. `Setup-Updates.command` per Doppelklick starten. Das Tool versucht den macOS-Schlüsselbund. Wenn dieser den Zugriff ablehnt, legt es einen privaten Ed25519-Schlüssel mit Dateirechten `600` außerhalb des Release-Ordners unter `Documents/Codex/.quickorbit-signing/QuickOrbit-ed25519.key` ab. Nur der öffentliche Schlüssel wird in die App-Konfiguration übernommen. Der lokale Schlüssel wurde bereits angelegt und die App-Konfiguration aktualisiert.
3. Den privaten Updateschlüssel sicher außerhalb von GitHub sichern. Er wird für jede spätere Veröffentlichung benötigt. Niemals in ein Repository oder Release hochladen. Zum Wechseln des Macs die offiziellen Sparkle-Werkzeuge für den Schlüssel-Export und -Import verwenden.
4. Für jedes Update beide Versionsnummern in `Packaging/Info.plist` erhöhen und `GitHub-Release/ReleaseNotes-v<Version>.md` anlegen. Bereits veröffentlichte Tags nicht überschreiben. Version 57 ist die erste Version für das neue Repository.
5. `Publish-GitHub-Release.command` starten. Es baut die App und erzeugt mit dem privaten Schlüssel den signierten Feed. Dateien prüfen, danach `Publish-GitHub-Release.command --publish` ausführen. Dafür wird `gh` mit Anmeldung bei GitHub benötigt.

Alternativ ohne `gh`: `Build.command`, danach `Generate-Update-Feed.command` ausführen. Auf GitHub ein neues öffentliches Release anlegen, als „Latest“ markieren und **beide** Dateien hochladen: `QuickOrbit-v<Version>.zip` und `Updates/appcast.xml`.

Die erste App mit eingebautem Updater und öffentlichem Schlüssel müssen bestehende Nutzer einmal manuell installieren. Alte Apps ohne Updater können diesen nicht nachträglich von selbst erhalten. Bei späteren Veröffentlichungen erhalten Nutzer die neuen Versionen abhängig von ihren Update-Einstellungen. Die App prüft standardmäßig etwa alle sechs Stunden, solange sie läuft; ein Upload löst keinen sofortigen Push an alle Nutzer aus.

## Für einen sauberen öffentlichen macOS-Download

Empfohlen ist ein **Developer ID Application**-Zertifikat aus dem Apple Developer Program plus Notarisierung. Die Bereitstellung bleibt bei GitHub; eine App-Store-Veröffentlichung ist dafür nicht nötig.

Das Build-Skript unterstützt `QUICKORBIT_SIGNING_IDENTITY` für das Zertifikat und `QUICKORBIT_NOTARY_PROFILE` für ein bereits eingerichtetes `notarytool`-Schlüsselbundprofil. Ohne diese Werte entstehen lokale ad-hoc-signierte Test-Builds; Sparkle-Updates benötigen weiterhin den gesonderten Ed25519-Schlüssel. Ad-hoc-Builds sind kein Ersatz für Developer-ID-Signierung und Notarisierung bei der Verteilung an fremde Macs.

Bei gesetztem Notarisierungsprofil wartet der Build auf Apple und heftet das Ticket an die App, bevor die Release-ZIP erstellt und für Sparkle signiert wird. Zugangsdaten und private Schlüssel gehören weder in den Quellcode noch in die Release-Dateien.

## Vor dem ersten öffentlichen Update prüfen

Eine eingerichtete ältere Version in `/Applications` installieren, danach eine höhere Version mit gültiger Signatur und Feed veröffentlichen. In der älteren Version „Nach Updates suchen“ verwenden: Versionshinweise, Download, Installation und Neustart prüfen. Zusätzlich bei ausgeschalteter automatischer Prüfung testen, dass nur eine manuelle Suche startet. Den ZIP-Inhalt nach Signierung oder Feed-Erstellung nicht verändern.

Die lokale Version kompiliert mit Sparkle. v56 wurde im alten Repository veröffentlicht. Damit bestehende v56-Installationen v57 automatisch finden, muss nach Veröffentlichung von v57 im neuen Repository zusätzlich der signierte v57-Feed als `appcast.xml` im neuesten Release des alten Repositorys erreichbar sein. Sein ZIP-Verweis zeigt bereits auf das neue Repository. Ohne diese Brücke müssen Nutzer v57 einmalig manuell installieren. Den vollständigen Aktualisierungsvorgang erst nach Veröffentlichung beider Feeds auf einem separaten Test-Mac prüfen.

Offizielle Anleitung: https://sparkle-project.org/documentation/ und https://sparkle-project.org/documentation/publishing/.
