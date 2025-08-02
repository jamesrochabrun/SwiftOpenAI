//
//  AIProxyCertificatePinning.swift
//
//
//  Created by Lou Zell on 6/23/24.
//
#if !os(Linux)
import Foundation
import OSLog

private let aiproxyLogger = Logger(
  subsystem: Bundle.main.bundleIdentifier ?? "UnknownApp",
  category: "SwiftOpenAI+AIProxyCertificatePinning")

// MARK: - AIProxyCertificatePinningDelegate

/// ## About
/// Use this class in conjunction with a URLSession to adopt certificate pinning in your app.
/// Cert pinning greatly reduces the ability for an attacker to snoop on your traffic.
///
/// A common misunderstanding about https is that it's hard for an attacker to read your traffic.
/// Unfortunately, that is only true if you, as the developer, control both sides of the pipe.
/// As an app developer, this is almost never the case. You ship your apps to the app store, and
/// attackers install them. When an attacker has your app on hardware they control (e.g. an iPhone),
/// it is trivial for them to MITM your app and read encrypted traffic.
///
/// Certificate pinning adds an additional layer of security by only allowing the TLS handshake to
/// succeed if your app recognizes the public key from the other side. I have baked in several AIProxy
/// public keys to this implementation.
///
/// This also functions as a reference implementation for any other libraries that want to interact
/// with the aiproxy.pro service using certificate pinning.
///
/// ## Implementor's note, and a gotcha
/// Use an instance of this class as the delegate to URLSession. For example:
///
///     let mySession = URLSession(
///        configuration: .default,
///        delegate: AIProxyCertificatePinningDelegate(),
///        delegateQueue: nil
///     )
///
/// In a perfect world, this would be all that is required of you. In fact, it is all that is required to protect requests made
/// with `await mySession.data(for:)`, because Foundation calls `urlSession:didReceiveChallenge:`
/// internally. However, `await mySession.bytes(for:)` is not protected, which is rather odd. As a workaround,
/// change your callsites from:
///
///     await mySession.bytes(for: request)
///
/// to:
///
///     await mySession.bytes(
///         for: request,
///         delegate: mySession.delegate as? URLSessionTaskDelegate
///     )
///
/// If you encounter other calls in the wild that do not invoke `urlSession:didReceiveChallenge:` on this class,
/// please report them to me.
final class AIProxyCertificatePinningDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
  func urlSession(
    _: URLSession,
    task _: URLSessionTask,
    didReceive challenge: URLAuthenticationChallenge)
    async -> (URLSession.AuthChallengeDisposition, URLCredential?)
  {
    answerChallenge(challenge)
  }

  func urlSession(
    _: URLSession,
    didReceive challenge: URLAuthenticationChallenge)
    async -> (URLSession.AuthChallengeDisposition, URLCredential?)
  {
    answerChallenge(challenge)
  }

  private func answerChallenge(
    _ challenge: URLAuthenticationChallenge)
    -> (URLSession.AuthChallengeDisposition, URLCredential?)
  {
    guard let secTrust = challenge.protectionSpace.serverTrust else {
      aiproxyLogger.error("Could not access the server's security space")
      return (.cancelAuthenticationChallenge, nil)
    }

    guard let certificate = getServerCert(secTrust: secTrust) else {
      aiproxyLogger.error("Could not access the server's TLS cert")
      return (.cancelAuthenticationChallenge, nil)
    }

    let serverPublicKey = SecCertificateCopyKey(certificate)!
    let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil)!

    for publicKeyData in publicKeysAsData {
      if serverPublicKeyData as Data == publicKeyData {
        let credential = URLCredential(trust: secTrust)
        return (.useCredential, credential)
      }
    }
    return (.cancelAuthenticationChallenge, nil)
  }
}

// MARK: - Private

private var publicKeysAsData: [Data] = publicKeysAsHex.map { publicKeyAsHex in
  let keyData = Data(publicKeyAsHex)

  let attributes: [String: Any] = [
    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
    kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
    kSecAttrKeySizeInBits as String: 256,
  ]

  var error: Unmanaged<CFError>?
  let publicKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error)!

  let localPublicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil)! as Data

  if let error {
    print("Failed to create public key: \(error.takeRetainedValue() as Error)")
    fatalError()
  }
  return localPublicKeyData
}

private let publicKeysAsHex: [[UInt8]] = [
  // live on api.aiproxy.pro
  [
    0x04, 0x25, 0xA2, 0xD1, 0x81, 0xC0, 0x38, 0xCE, 0x57, 0xAA, 0x6E, 0xF0, 0x5A, 0xC3, 0x6A,
    0xA7, 0xC4, 0x69, 0x69, 0xCB, 0xEB, 0x24, 0xE5, 0x20, 0x7D, 0x06, 0xCB, 0xC7, 0x49, 0xD5,
    0x0C, 0xAC, 0xE6, 0x96, 0xC5, 0xC9, 0x28, 0x00, 0x8E, 0x69, 0xFF, 0x9D, 0x32, 0x01, 0x53,
    0x74, 0xAB, 0xFD, 0x46, 0x03, 0x32, 0xED, 0x93, 0x7F, 0x0F, 0xE9, 0xD9, 0xC3, 0xAF, 0xE7,
    0xA5, 0xCB, 0xC1, 0x29, 0x35,
  ],

  // live on beta-api.aiproxy.pro
  [
    0x04, 0xAF, 0xB2, 0xCC, 0xE2, 0x51, 0x92, 0xCF, 0xB8, 0x01, 0x25, 0xC1, 0xB8, 0xDA, 0x29,
    0x51, 0x9F, 0x91, 0x4C, 0xAA, 0x09, 0x66, 0x3D, 0x81, 0xD7, 0xAD, 0x6F, 0xDB, 0x78, 0x10,
    0xD4, 0xBE, 0xCD, 0x4F, 0xE3, 0xAF, 0x4F, 0xB6, 0xD2, 0xCA, 0x85, 0xB6, 0xC7, 0x3E, 0xB4,
    0x61, 0x62, 0xE1, 0xFC, 0x90, 0xD6, 0x84, 0x1F, 0x98, 0xCA, 0x83, 0x60, 0x8B, 0x65, 0xCB,
    0x1A, 0x57, 0x6E, 0x32, 0x35,
  ],

  // backup-EC-key-A.key
  [
    0x04, 0x2C, 0x25, 0x74, 0xBC, 0x7E, 0x18, 0x10, 0x27, 0xBD, 0x03, 0x56, 0x4A, 0x7B, 0x32,
    0xD2, 0xC1, 0xB0, 0x2E, 0x58, 0x85, 0x9A, 0xB0, 0x7D, 0xCD, 0x7E, 0x23, 0x33, 0x88, 0x2F,
    0xC0, 0xFE, 0xCE, 0x2E, 0xBF, 0x36, 0x67, 0xC6, 0x81, 0xF6, 0x52, 0x2B, 0x9B, 0xAF, 0x97,
    0x3C, 0xAC, 0x00, 0x39, 0xD8, 0xCC, 0x43, 0x6B, 0x1D, 0x65, 0xA5, 0xAD, 0xD1, 0x57, 0x4B,
    0xAD, 0xB1, 0x17, 0xD3, 0x10,
  ],

  // backup-EC-key-B.key
  [
    0x04, 0x34, 0xAE, 0x84, 0x94, 0xE9, 0x02, 0xF0, 0x78, 0x0E, 0xEE, 0xE6, 0x4E, 0x39, 0x7F,
    0xB4, 0x84, 0xF6, 0xEC, 0x55, 0x20, 0x0D, 0x36, 0xE9, 0xA6, 0x44, 0x6B, 0x9B, 0xE1, 0xEF,
    0x19, 0xE7, 0x90, 0x5B, 0xF4, 0xA3, 0x29, 0xF3, 0x56, 0x7C, 0x60, 0x97, 0xF0, 0xC6, 0x61,
    0x83, 0x31, 0x5D, 0x2D, 0xC9, 0xCC, 0x40, 0x43, 0xAD, 0x81, 0x63, 0xFD, 0xCF, 0xE2, 0x8E,
    0xFA, 0x07, 0x09, 0xF6, 0xF2,
  ],

  // backup-EC-key-C.key
  [
    0x04, 0x84, 0x4E, 0x33, 0xC8, 0x60, 0xE7, 0x78, 0xAA, 0xA2, 0xB6, 0x0B, 0xCF, 0x7A, 0x52,
    0x43, 0xD1, 0x6D, 0x58, 0xFF, 0x17, 0xB8, 0xEA, 0x8A, 0x39, 0x53, 0xFB, 0x8B, 0x66, 0x7D,
    0x10, 0x39, 0x80, 0x2C, 0x8D, 0xC9, 0xC3, 0x34, 0x33, 0x98, 0x14, 0xEB, 0x88, 0x7B, 0xF5,
    0x4D, 0x1F, 0x07, 0xAE, 0x6A, 0x02, 0x6B, 0xF5, 0x9B, 0xA8, 0xC6, 0x55, 0x5C, 0x27, 0xCD,
    0x1B, 0xC0, 0x27, 0x2D, 0x82,
  ],
]

private func getServerCert(secTrust: SecTrust) -> SecCertificate? {
  if #available(macOS 12.0, iOS 15.0, *) {
    guard let certs = SecTrustCopyCertificateChain(secTrust) as? [SecCertificate] else {
      return nil
    }
    return certs[0]
  } else {
    return SecTrustGetCertificateAtIndex(secTrust, 0)
  }
}
#endif
