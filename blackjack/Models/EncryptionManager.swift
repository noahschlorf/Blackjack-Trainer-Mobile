//
//  EncryptionManager.swift
//  blackjack
//
//  Created by Noah Schlorf on 12/2/24.
//
//  This file demonstrates how to perform AES-GCM encryption and decryption
//  using Apple's CryptoKit. Including this file means your app uses
//  standard cryptographic algorithms outside of the built-in Apple OS
//  (HTTPS, Keychain, etc.).
//
//  IMPORTANT: You may need to declare export compliance in App Store Connect
//  and possibly file an annual self-classification report. Consult
//  legal advice for specific requirements.
//

import SwiftUI
import CryptoKit

/// A simple manager demonstrating AES-GCM encryption/decryption.
struct EncryptionManager {
    
    /// Generate a random 256-bit symmetric key for AES.
    /// In a real app, you might store this in the Keychain or securely transmit it, etc.
    static func generateSymmetricKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
    
    /// Encrypt a `String` using AES-GCM.
    /// Returns a tuple of (ciphertext, nonce, tag) on success, or nil on error.
    static func encryptMessage(_ message: String,
                               using key: SymmetricKey) -> (ciphertext: Data,
                                                             nonce: AES.GCM.Nonce,
                                                             tag: Data)? {
        do {
            // Convert the message to raw Data
            let messageData = Data(message.utf8)
            
            // Generate a random nonce
            let nonce = try AES.GCM.Nonce()
            
            // Perform encryption
            let sealedBox = try AES.GCM.seal(messageData, using: key, nonce: nonce)
            
            // The combined property includes ciphertext + tag
            // but we can also separate them if we want.
            let combinedCipher = sealedBox.ciphertext + sealedBox.tag
            
            // Return ciphertext & nonce & tag separately
            return (combinedCipher, nonce, sealedBox.tag)
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    /// Decrypt AES-GCM data using the same key + nonce.
    /// We expect the last 16 bytes to be the authentication tag.
    static func decryptMessage(ciphertext: Data,
                               nonce: AES.GCM.Nonce,
                               using key: SymmetricKey) -> String? {
        do {
            // The AES.GCM tag is 16 bytes (128 bits) by default
            let tagSize = 16
            guard ciphertext.count >= tagSize else { return nil }
            
            // Separate the raw ciphertext from the authentication tag
            let actualCiphertext = ciphertext.dropLast(tagSize)
            let tag = ciphertext.suffix(tagSize)
            
            // Reconstruct the sealed box
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce,
                                                  ciphertext: actualCiphertext,
                                                  tag: tag)
            
            // Decrypt
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            // Convert the decrypted bytes back to a String
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
}

/// EXAMPLE SwiftUI usage.
/// Place this in a test View or call the methods from your own code.
struct EncryptionExampleView: View {
    
    @State private var key = EncryptionManager.generateSymmetricKey()
    @State private var nonce: AES.GCM.Nonce?
    @State private var cipherData: Data?
    @State private var decryptedText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Encrypt 'Hello World'") {
                let result = EncryptionManager.encryptMessage("Hello World", using: key)
                if let r = result {
                    cipherData = r.ciphertext
                    nonce = r.nonce
                    print("Encrypted cipherData = \(cipherData?.base64EncodedString() ?? "")")
                }
            }
            
            Button("Decrypt Cipher") {
                guard let cData = cipherData,
                      let n = nonce
                else { return }
                
                if let decrypted = EncryptionManager.decryptMessage(ciphertext: cData,
                                                                    nonce: n,
                                                                    using: key) {
                    decryptedText = decrypted
                    print("Decrypted = \(decrypted)")
                }
            }
            
            Text("Decrypted Text: \(decryptedText)")
                .padding()
        }
        .padding()
    }
}
