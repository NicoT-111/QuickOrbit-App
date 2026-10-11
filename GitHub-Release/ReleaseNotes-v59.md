# QuickOrbit 59

- Behebt die Sparkle-Installation in der sandboxed App: Der benötigte Installer-Dienst ist aktiviert und die Kommunikation mit ihm freigegeben.
- Sparkle-Hilfsprogramme werden auch bei lokalen ad-hoc-Builds getrennt signiert, statt die Sandbox-Rechte der Haupt-App zu übernehmen.
- Die Update-Suche nutzt weiterhin den signierten Feed im offiziellen GitHub-Release.

Wichtig: Version 57 kann wegen ihrer fehlenden Netzwerkfreigabe kein Update selbst abrufen. Bitte Version 59 einmalig manuell herunterladen und `QuickOrbit.app` in „Programme“ ersetzen. Danach sollten neue Versionen direkt in der App gefunden und installiert werden können.

Diese Ausgabe ist ad-hoc signiert und nicht mit Apple Developer ID notarisiert. macOS kann beim ersten Start eine Warnung anzeigen.
