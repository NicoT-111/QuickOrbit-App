import Foundation

guard CommandLine.arguments.count == 6 else {
    fputs("Usage: CreateAppcast.swift owner/repository version signature-attributes notes-file output-xml\n", stderr)
    exit(2)
}
let repository = CommandLine.arguments[1]
let version = CommandLine.arguments[2]
let attributes = CommandLine.arguments[3]
guard repository.range(of: "^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", options: .regularExpression) != nil,
      version.range(of: "^[0-9]+(\\.[0-9]+){0,3}$", options: .regularExpression) != nil,
      attributes.range(of: "^sparkle:edSignature=\"[A-Za-z0-9+/=]+\" length=\"[0-9]+\"$", options: .regularExpression) != nil else {
    fputs("Invalid repository, version or Sparkle signature output.\n", stderr)
    exit(1)
}
let notes = try String(contentsOfFile: CommandLine.arguments[4], encoding: .utf8)
let escapedNotes = notes
    .replacingOccurrences(of: "&", with: "&amp;")
    .replacingOccurrences(of: "<", with: "&lt;")
    .replacingOccurrences(of: ">", with: "&gt;")
let formatter = DateFormatter()
formatter.locale = Locale(identifier: "en_US_POSIX")
formatter.timeZone = TimeZone(secondsFromGMT: 0)
formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
let date = formatter.string(from: Date())
let xml = """
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>QuickOrbit Updates</title>
    <description>Signierte Versionen von QuickOrbit.</description>
    <language>de</language>
    <item>
      <title>QuickOrbit \(version)</title>
      <link>https://github.com/\(repository)/releases/tag/v\(version)</link>
      <sparkle:version>\(version)</sparkle:version>
      <sparkle:shortVersionString>\(version)</sparkle:shortVersionString>
      <pubDate>\(date)</pubDate>
      <description><![CDATA[<pre style="white-space: pre-wrap; font-family: -apple-system, sans-serif;">\(escapedNotes.replacingOccurrences(of: "]]>", with: "]] &gt;"))</pre>]]></description>
      <enclosure url="https://github.com/\(repository)/releases/download/v\(version)/QuickOrbit-v\(version).zip" \(attributes) type="application/octet-stream" />
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
    </item>
  </channel>
</rss>
"""
try Data(xml.utf8).write(to: URL(fileURLWithPath: CommandLine.arguments[5]), options: .atomic)
