// L37_SeguridadDemo.swift — Conceptos de Seguridad
// Ejecutar: swift L37_SeguridadDemo.swift
//
// WHY: La seguridad no es un feature — es un requisito. Entender
// hashing, cifrado, y validacion de passwords desde los fundamentos
// permite tomar mejores decisiones con CryptoKit en produccion.

import Foundation

// MARK: - Hashing Simulado
// Un hash convierte datos en un "fingerprint" de longitud fija.
// Es de una sola via — no se puede revertir.

struct HashSimple {
    /// Hash basado en DJB2 — algoritmo simple para demostracion
    /// (En produccion usar SHA256 de CryptoKit)
    static func hash(_ texto: String) -> String {
        var hash: UInt64 = 5381
        for byte in texto.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte) // hash * 33 + byte
        }
        return String(format: "%016llx", hash)
    }

    /// Hash con salt — agrega valor aleatorio para prevenir ataques de diccionario
    static func hashConSalt(_ texto: String, salt: String) -> (hash: String, salt: String) {
        let combinado = salt + texto
        return (hash: hash(combinado), salt: salt)
    }

    static func generarSalt() -> String {
        let caracteres = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<16).map { _ in caracteres.randomElement()! })
    }
}

// MARK: - Cifrado XOR (Demostracion)
// XOR es el cifrado mas simple posible: dato XOR clave = cifrado
// cifrado XOR clave = dato original
// (En produccion usar AES-GCM de CryptoKit)

struct CifradoXOR {
    static func cifrar(_ texto: String, clave: String) -> [UInt8] {
        let bytesTexto = Array(texto.utf8)
        let bytesClave = Array(clave.utf8)
        return bytesTexto.enumerated().map { (i, byte) in
            byte ^ bytesClave[i % bytesClave.count]
        }
    }

    static func descifrar(_ datos: [UInt8], clave: String) -> String {
        let bytesClave = Array(clave.utf8)
        let bytesOriginales = datos.enumerated().map { (i, byte) in
            byte ^ bytesClave[i % bytesClave.count]
        }
        return String(bytes: bytesOriginales, encoding: .utf8) ?? "(error de decodificacion)"
    }

    static func aHex(_ datos: [UInt8]) -> String {
        datos.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Validador de Passwords

struct ValidadorPassword {
    struct Resultado: CustomStringConvertible {
        let valido: Bool
        let errores: [String]
        let fortaleza: String // Debil, Media, Fuerte

        var description: String {
            if valido {
                return "VALIDA (Fortaleza: \(fortaleza))"
            }
            return "INVALIDA — \(errores.joined(separator: ", "))"
        }
    }

    func validar(_ password: String) -> Resultado {
        var errores: [String] = []
        var puntaje = 0

        // Regla 1: Longitud minima
        if password.count < 8 {
            errores.append("Minimo 8 caracteres")
        } else {
            puntaje += password.count >= 12 ? 2 : 1
        }

        // Regla 2: Contiene mayusculas
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            errores.append("Necesita al menos una mayuscula")
        } else { puntaje += 1 }

        // Regla 3: Contiene minusculas
        if password.rangeOfCharacter(from: .lowercaseLetters) == nil {
            errores.append("Necesita al menos una minuscula")
        } else { puntaje += 1 }

        // Regla 4: Contiene numeros
        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            errores.append("Necesita al menos un numero")
        } else { puntaje += 1 }

        // Regla 5: Contiene simbolos
        let simbolos = CharacterSet.alphanumerics.inverted
        if password.unicodeScalars.first(where: { simbolos.contains($0) }) == nil {
            errores.append("Necesita al menos un simbolo (!@#$...)")
        } else { puntaje += 2 }

        // Regla 6: No contiene patrones comunes
        let patrones = ["123456", "password", "qwerty", "abcdef"]
        for patron in patrones {
            if password.lowercased().contains(patron) {
                errores.append("Contiene patron comun '\(patron)'")
                puntaje -= 2
            }
        }

        let fortaleza: String
        switch puntaje {
        case ..<3: fortaleza = "Debil"
        case 3...5: fortaleza = "Media"
        default: fortaleza = "Fuerte"
        }

        return Resultado(valido: errores.isEmpty, errores: errores, fortaleza: fortaleza)
    }
}

// MARK: - Almacenamiento Seguro (Abstraccion de Keychain)

protocol AlmacenSeguro {
    func guardar(clave: String, valor: String) throws
    func leer(clave: String) throws -> String?
    func eliminar(clave: String) throws
}

/// Simulacion de Keychain Services (en produccion usar Security framework)
final class KeychainSimulado: AlmacenSeguro {
    // En produccion, Keychain cifra automaticamente con hardware (Secure Enclave)
    private var almacen: [String: String] = [:]
    private let claveInterna = "secure_key_demo"

    func guardar(clave: String, valor: String) throws {
        // Simulamos que Keychain cifra los datos
        let cifrado = CifradoXOR.aHex(CifradoXOR.cifrar(valor, clave: claveInterna))
        almacen[clave] = cifrado
        print("    Keychain: Guardado '\(clave)' (cifrado: \(cifrado.prefix(20))...)")
    }

    func leer(clave: String) throws -> String? {
        guard let cifrado = almacen[clave] else { return nil }
        print("    Keychain: Leyendo '\(clave)' (datos cifrados en disco)")
        // En produccion, Keychain descifra transparentemente
        return "(valor seguro para '\(clave)' — cifrado: \(cifrado.prefix(16))...)"
    }

    func eliminar(clave: String) throws {
        almacen.removeValue(forKey: clave)
        print("    Keychain: Eliminado '\(clave)'")
    }
}

// MARK: - Ejecucion del Demo

print("=== DEMO SEGURIDAD ===\n")

// 1. Hashing
print("1. Hashing (funcion de una via):")
let textos = ["Hola Mundo", "Hola Mundo", "Hola mundo"]
for t in textos {
    print("   \"\(t)\" -> \(HashSimple.hash(t))")
}
print("   Nota: mismo input = mismo hash. Cambio minimo = hash totalmente distinto.")

print("\n   Hashing con salt:")
let salt = HashSimple.generarSalt()
let (h1, _) = HashSimple.hashConSalt("miPassword", salt: salt)
let (h2, _) = HashSimple.hashConSalt("miPassword", salt: HashSimple.generarSalt())
print("   Password con salt1: \(h1)")
print("   Password con salt2: \(h2)")
print("   Mismo password, distinto salt = hashes diferentes (previene rainbow tables)")

// 2. Cifrado/Descifrado
print("\n2. Cifrado XOR (concepto — en produccion usar AES-GCM):")
let mensaje = "Datos confidenciales del usuario"
let clave = "ClaveSecreta2026"
let cifrado = CifradoXOR.cifrar(mensaje, clave: clave)
let descifrado = CifradoXOR.descifrar(cifrado, clave: clave)
print("   Original:   \(mensaje)")
print("   Cifrado:    \(CifradoXOR.aHex(cifrado))")
print("   Descifrado: \(descifrado)")

// 3. Validacion de passwords
print("\n3. Validacion de Passwords:")
let validador = ValidadorPassword()
let passwords = ["abc", "password123", "MiClave1", "Str0ng!P@ssw0rd#2026"]
for pwd in passwords {
    let resultado = validador.validar(pwd)
    print("   \"\(pwd)\" -> \(resultado)")
}

// 4. Keychain simulado
print("\n4. Almacenamiento Seguro (Keychain):")
let keychain = KeychainSimulado()
try? keychain.guardar(clave: "api_token", valor: "sk-abc123xyz789")
try? keychain.guardar(clave: "refresh_token", valor: "rt-refresh-999")
if let valor = try? keychain.leer(clave: "api_token") {
    print("    Leido: \(valor)")
}

print("\n--- Punto clave ---")
print("Hashing = verificar integridad (passwords, checksums).")
print("Cifrado = proteger confidencialidad (datos en reposo/transito).")
print("Keychain = almacenamiento seguro respaldado por Secure Enclave.")
