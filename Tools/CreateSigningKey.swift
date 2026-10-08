import CryptoKit
import Foundation
import Darwin

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: CreateSigningKey.swift /absolute/private/key/path\n", stderr)
    exit(2)
}
let keyURL = URL(fileURLWithPath: CommandLine.arguments[1])
let directory = keyURL.deletingLastPathComponent()
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
let key: Curve25519.Signing.PrivateKey
if FileManager.default.fileExists(atPath: keyURL.path) {
    let value = try String(contentsOf: keyURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    guard let seed = Data(base64Encoded: value), seed.count == 32 else {
        fputs("Existing signing key is invalid. It was not replaced.\n", stderr)
        exit(1)
    }
    key = try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
} else {
    key = Curve25519.Signing.PrivateKey()
    let encoded = Data((key.rawRepresentation.base64EncodedString() + "\n").utf8)
    let descriptor = open(keyURL.path, O_WRONLY | O_CREAT | O_EXCL, 0o600)
    guard descriptor >= 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
    defer { close(descriptor) }
    let written = encoded.withUnsafeBytes { write(descriptor, $0.baseAddress, encoded.count) }
    guard written == encoded.count else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
}
print(key.publicKey.rawRepresentation.base64EncodedString())
