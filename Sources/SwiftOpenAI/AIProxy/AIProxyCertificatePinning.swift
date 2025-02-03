//
//  AIProxyCertificatePinning.swift
//
//
//  Created by Lou Zell on 6/23/24.
//

import Foundation
import OSLog

private let aiproxyLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnknownApp",
                                   category: "SwiftOpenAI+AIProxyCertificatePinning")

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
      _ session: URLSession,
      task: URLSessionTask,
      didReceive challenge: URLAuthenticationChallenge
   ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
      return self.answerChallenge(challenge)
   }

   func urlSession(
      _ session: URLSession,
      didReceive challenge: URLAuthenticationChallenge
   ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
      return self.answerChallenge(challenge)
   }

   private func answerChallenge(
      _ challenge: URLAuthenticationChallenge
   ) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
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
 private var publicKeysAsData: [Data] = {
     let newVal = publicKeysAsHex.map { publicKeyAsHex in
         let keyData = Data(publicKeyAsHex)

         let attributes: [String: Any] = [
             kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
             kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
             kSecAttrKeySizeInBits as String: 256
         ]

         var error: Unmanaged<CFError>?
         let publicKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error)!

         let localPublicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil)! as Data

         if let error = error {
             print("Failed to create public key: \(error.takeRetainedValue() as Error)")
             fatalError()
         }
         return localPublicKeyData
     }
     return newVal
 }()

private let publicKeysAsHex: [[UInt8]] = [
     // live on api.aiproxy.pro
     [
         0x04, 0x25, 0xa2, 0xd1, 0x81, 0xc0, 0x38, 0xce, 0x57, 0xaa, 0x6e, 0xf0, 0x5a, 0xc3, 0x6a,
         0xa7, 0xc4, 0x69, 0x69, 0xcb, 0xeb, 0x24, 0xe5, 0x20, 0x7d, 0x06, 0xcb, 0xc7, 0x49, 0xd5,
         0x0c, 0xac, 0xe6, 0x96, 0xc5, 0xc9, 0x28, 0x00, 0x8e, 0x69, 0xff, 0x9d, 0x32, 0x01, 0x53,
         0x74, 0xab, 0xfd, 0x46, 0x03, 0x32, 0xed, 0x93, 0x7f, 0x0f, 0xe9, 0xd9, 0xc3, 0xaf, 0xe7,
         0xa5, 0xcb, 0xc1, 0x29, 0x35
     ],

     // live on beta-api.aiproxy.pro
     [
         0x04, 0xaf, 0xb2, 0xcc, 0xe2, 0x51, 0x92, 0xcf, 0xb8, 0x01, 0x25, 0xc1, 0xb8, 0xda, 0x29,
         0x51, 0x9f, 0x91, 0x4c, 0xaa, 0x09, 0x66, 0x3d, 0x81, 0xd7, 0xad, 0x6f, 0xdb, 0x78, 0x10,
         0xd4, 0xbe, 0xcd, 0x4f, 0xe3, 0xaf, 0x4f, 0xb6, 0xd2, 0xca, 0x85, 0xb6, 0xc7, 0x3e, 0xb4,
         0x61, 0x62, 0xe1, 0xfc, 0x90, 0xd6, 0x84, 0x1f, 0x98, 0xca, 0x83, 0x60, 0x8b, 0x65, 0xcb,
         0x1a, 0x57, 0x6e, 0x32, 0x35,
     ],

     // backup-EC-key-A.key
     [
         0x04, 0x2c, 0x25, 0x74, 0xbc, 0x7e, 0x18, 0x10, 0x27, 0xbd, 0x03, 0x56, 0x4a, 0x7b, 0x32,
         0xd2, 0xc1, 0xb0, 0x2e, 0x58, 0x85, 0x9a, 0xb0, 0x7d, 0xcd, 0x7e, 0x23, 0x33, 0x88, 0x2f,
         0xc0, 0xfe, 0xce, 0x2e, 0xbf, 0x36, 0x67, 0xc6, 0x81, 0xf6, 0x52, 0x2b, 0x9b, 0xaf, 0x97,
         0x3c, 0xac, 0x00, 0x39, 0xd8, 0xcc, 0x43, 0x6b, 0x1d, 0x65, 0xa5, 0xad, 0xd1, 0x57, 0x4b,
         0xad, 0xb1, 0x17, 0xd3, 0x10
     ],

     // backup-EC-key-B.key
     [
         0x04, 0x34, 0xae, 0x84, 0x94, 0xe9, 0x02, 0xf0, 0x78, 0x0e, 0xee, 0xe6, 0x4e, 0x39, 0x7f,
         0xb4, 0x84, 0xf6, 0xec, 0x55, 0x20, 0x0d, 0x36, 0xe9, 0xa6, 0x44, 0x6b, 0x9b, 0xe1, 0xef,
         0x19, 0xe7, 0x90, 0x5b, 0xf4, 0xa3, 0x29, 0xf3, 0x56, 0x7c, 0x60, 0x97, 0xf0, 0xc6, 0x61,
         0x83, 0x31, 0x5d, 0x2d, 0xc9, 0xcc, 0x40, 0x43, 0xad, 0x81, 0x63, 0xfd, 0xcf, 0xe2, 0x8e,
         0xfa, 0x07, 0x09, 0xf6, 0xf2
     ],

     // backup-EC-key-C.key
     [
         0x04, 0x84, 0x4e, 0x33, 0xc8, 0x60, 0xe7, 0x78, 0xaa, 0xa2, 0xb6, 0x0b, 0xcf, 0x7a, 0x52,
         0x43, 0xd1, 0x6d, 0x58, 0xff, 0x17, 0xb8, 0xea, 0x8a, 0x39, 0x53, 0xfb, 0x8b, 0x66, 0x7d,
         0x10, 0x39, 0x80, 0x2c, 0x8d, 0xc9, 0xc3, 0x34, 0x33, 0x98, 0x14, 0xeb, 0x88, 0x7b, 0xf5,
         0x4d, 0x1f, 0x07, 0xae, 0x6a, 0x02, 0x6b, 0xf5, 0x9b, 0xa8, 0xc6, 0x55, 0x5c, 0x27, 0xcd,
         0x1b, 0xc0, 0x27, 0x2d, 0x82
     ]

 ]

private func getServerCert(secTrust: SecTrust) -> SecCertificate? {
    if #available(macOS 12.0, iOS 15.0, *) {
        guard let certs = SecTrustCopyCertificateChain(secTrust) as? [SecCertificate] else {
            return nil
        }
        return certs[0]
    } else {
        return SecTrustGetCertificateAtIndex(secTrust, 0);
    }
}
