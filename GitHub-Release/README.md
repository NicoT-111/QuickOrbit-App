# GitHub-Releases ohne Quellcode

Dieser Ordner enthält Versionshinweise und die Anleitung für signierte Updates. Der Swift-Quellcode wird nicht hochgeladen.

## Neue Version veröffentlichen

1. `CFBundleShortVersionString` und `CFBundleVersion` in `Packaging/Info.plist` erhöhen.
2. Eine passende Datei `ReleaseNotes-v<Version>.md` in diesem Ordner anlegen.
3. `Publish-GitHub-Release.command` ohne Argument starten und die erzeugten Dateien prüfen.
4. Anschließend ausdrücklich `Publish-GitHub-Release.command --publish` starten.

Vor der ersten Veröffentlichung einmal `Setup-Updates.command` starten. Der Assistent baut die Universal-App und lädt App-ZIP und signierten Update-Feed `appcast.xml` als GitHub-Release-Assets in `NicoT-111/QuickOrbit-App`. Die installierte App kann danach neue Versionen prüfen, laden und ersetzen. Einzelheiten: [Update-Einrichtung](UPDATE-EINRICHTUNG.md).

Für `--publish` wird die GitHub CLI `gh` mit einer Anmeldung bei deinem Konto benötigt. Ohne `gh` ein öffentliches Release mit neuem Tag `v<Version>` erstellen, als „Latest“ markieren und `QuickOrbit-v<Version>.zip` sowie `Updates/appcast.xml` gemeinsam hochladen.
