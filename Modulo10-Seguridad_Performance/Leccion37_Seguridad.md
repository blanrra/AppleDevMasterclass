# Leccion 37: Seguridad — CryptoKit, Keychain, Privacy Manifests

**Modulo 10: Seguridad y Performance** | Semana 47

---

## TL;DR — Resumen en 2 minutos

- **CryptoKit** proporciona cifrado moderno y seguro — AES-GCM para cifrado simetrico, SHA256 para hashing, HMAC para autenticacion de mensajes
- **Keychain Services** almacena credenciales de forma segura — nunca guardes passwords o tokens en UserDefaults
- **Privacy Manifests** declaran que datos usa tu app y por que — obligatorios desde 2024 para App Store
- **LocalAuthentication** integra Face ID y Touch ID — autenticacion biometrica con un solo metodo
- **Certificate Pinning** protege la comunicacion de red — evita ataques man-in-the-middle

> Herramienta: **Xcode 26** con Keychain Access y Instruments para auditar seguridad

---

## Cupertino MCP

```bash
cupertino search "CryptoKit"
cupertino search "CryptoKit AES GCM"
cupertino search "Keychain Services"
cupertino search --source apple-docs "SecItemAdd"
cupertino search "Privacy Manifests"
cupertino search "PrivacyInfo"
cupertino search --source apple-docs "LocalAuthentication"
cupertino search "LAContext biometric"
cupertino search --source hig "privacy"
cupertino search --source updates "privacy manifests iOS 26"
cupertino search "certificate pinning URLSession"
cupertino search_symbols "SymmetricKey"
cupertino search_symbols "SHA256"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Privacy | Novedades privacidad iOS 26 |
| WWDC24 | [What's new in privacy](https://developer.apple.com/videos/play/wwdc2024/10123/) | **Esencial** — Privacy Manifests |
| WWDC23 | [Get started with privacy manifests](https://developer.apple.com/videos/play/wwdc2023/10060/) | Introduccion Privacy Manifests |
| WWDC22 | [What's new in Swift — CryptoKit](https://developer.apple.com/videos/play/wwdc2022/) | CryptoKit actualizaciones |
| WWDC20 | [Secure your app](https://developer.apple.com/videos/play/wwdc2020/10644/) | Fundamentos seguridad |
| EN | [Sean Allen — Keychain](https://www.youtube.com/@seanallen) | Tutorial practico Keychain |
| EN | [Paul Hudson — Biometrics](https://www.hackingwithswift.com/books/ios-swiftui/using-touch-id-and-face-id-with-swiftui) | Face ID paso a paso |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Seguridad?

La seguridad no es una feature opcional — es un requisito fundamental. Cada dia se filtran millones de credenciales porque los desarrolladores toman atajos: guardan tokens en UserDefaults, envian datos sin cifrar, o ignoran las alertas de privacidad. Apple ha respondido con herramientas que hacen que lo seguro sea lo facil.

Hay tres pilares de seguridad en apps modernas:
1. **Datos en reposo**: Como almacenas informacion sensible (Keychain, CryptoKit)
2. **Datos en transito**: Como proteges la comunicacion de red (TLS, certificate pinning)
3. **Privacidad del usuario**: Como declaras y respetas el uso de datos (Privacy Manifests)

### CryptoKit — Criptografia Moderna

CryptoKit es el framework de Apple para operaciones criptograficas. Reemplaza las APIs de C de Security framework con una interfaz Swift moderna, segura por tipo y facil de usar.

#### Hashing con SHA256

El hashing convierte datos de cualquier tamano en un digest de tamano fijo. Es unidireccional: no puedes recuperar los datos originales a partir del hash.

```swift
import CryptoKit
import Foundation

// MARK: - Hashing con SHA256

/// SHA256 produce un digest de 256 bits (32 bytes)
/// Misma entrada siempre produce la misma salida
/// Imposible revertir el hash a los datos originales

let mensaje = "Datos sensibles de la app".data(using: .utf8)!
let hash = SHA256.hash(data: mensaje)

print("Hash SHA256: \(hash)")
// Output: SHA256 digest: 64 bytes hexadecimales

// Convertir hash a string hexadecimal
let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
print("Hash hex: \(hashString)")

// Verificar integridad — comparar dos hashes
let mensajeOriginal = "archivo-importante.zip".data(using: .utf8)!
let hashOriginal = SHA256.hash(data: mensajeOriginal)

let mensajeDescargado = "archivo-importante.zip".data(using: .utf8)!
let hashDescargado = SHA256.hash(data: mensajeDescargado)

if hashOriginal == hashDescargado {
    print("Integridad verificada: el archivo no fue modificado")
}

// SHA384 y SHA512 para mayor seguridad
let hash384 = SHA384.hash(data: mensaje)
let hash512 = SHA512.hash(data: mensaje)
print("SHA384: \(hash384)")
print("SHA512: \(hash512)")
```

**Pregunta Socratica**: Si SHA256 siempre produce la misma salida para la misma entrada, como se usa para verificar que un archivo descargado no fue alterado durante la transmision?

#### HMAC — Autenticacion de Mensajes

HMAC combina un hash con una clave secreta. Permite verificar que un mensaje no fue alterado Y que viene de alguien que posee la clave.

```swift
import CryptoKit
import Foundation

// MARK: - HMAC (Hash-based Message Authentication Code)

/// HMAC = Hash + Clave Secreta
/// Garantiza: integridad del mensaje + autenticidad del remitente

let claveSecreta = SymmetricKey(size: .bits256)
let datos = "Transaccion: $500 a cuenta 1234".data(using: .utf8)!

// Crear firma HMAC
let firma = HMAC<SHA256>.authenticationCode(for: datos, using: claveSecreta)
print("HMAC: \(Data(firma).map { String(format: "%02x", $0) }.joined())")

// Verificar firma — el receptor usa la misma clave
let esValido = HMAC<SHA256>.isValidAuthenticationCode(
    firma,
    authenticating: datos,
    using: claveSecreta
)
print("Firma valida: \(esValido)") // true

// Si alguien modifica los datos, la verificacion falla
let datosModificados = "Transaccion: $5000 a cuenta 1234".data(using: .utf8)!
let esValidoModificado = HMAC<SHA256>.isValidAuthenticationCode(
    firma,
    authenticating: datosModificados,
    using: claveSecreta
)
print("Datos modificados validos: \(esValidoModificado)") // false
```

#### Cifrado Simetrico con AES-GCM

AES-GCM (Advanced Encryption Standard — Galois/Counter Mode) es el estandar de cifrado simetrico. Una sola clave cifra y descifra los datos.

```swift
import CryptoKit
import Foundation

// MARK: - Cifrado simetrico AES-GCM

/// AES-GCM proporciona:
/// 1. Confidencialidad: los datos son ilegibles sin la clave
/// 2. Integridad: detecta si los datos cifrados fueron alterados
/// 3. Autenticacion: verifica que el cifrado fue hecho con la clave correcta

// Generar clave simetrica de 256 bits
let clave = SymmetricKey(size: .bits256)

// Datos a cifrar
let textoOriginal = "Numero de tarjeta: 4532-XXXX-XXXX-1234"
let datosOriginales = textoOriginal.data(using: .utf8)!

// Cifrar
do {
    let cajaCifrada = try AES.GCM.seal(datosOriginales, using: clave)

    // La caja cifrada contiene: nonce + ciphertext + tag
    // El nonce es un valor unico que garantiza que cifrar el mismo texto
    // dos veces produce resultados diferentes

    guard let datosParaTransmitir = cajaCifrada.combined else {
        fatalError("No se pudo combinar datos cifrados")
    }

    print("Datos cifrados: \(datosParaTransmitir.base64EncodedString())")
    print("Tamano original: \(datosOriginales.count) bytes")
    print("Tamano cifrado: \(datosParaTransmitir.count) bytes")

    // Descifrar
    let cajaRecibida = try AES.GCM.SealedBox(combined: datosParaTransmitir)
    let datosDescifrados = try AES.GCM.open(cajaRecibida, using: clave)
    let textoDescifrado = String(data: datosDescifrados, encoding: .utf8)!

    print("Texto descifrado: \(textoDescifrado)")
    // Output: "Numero de tarjeta: 4532-XXXX-XXXX-1234"

} catch {
    print("Error de cifrado: \(error)")
}
```

#### Key Agreement con Curve25519

Para comunicacion segura entre dos partes que no comparten una clave previa, se usa key agreement. Cada parte genera un par de claves (publica/privada) y derivan una clave compartida.

```swift
import CryptoKit
import Foundation

// MARK: - Key Agreement (Diffie-Hellman con Curve25519)

/// Escenario: Alice y Bob quieren comunicarse de forma segura
/// sin haber intercambiado una clave previamente

// Alice genera su par de claves
let clavePrivadaAlice = Curve25519.KeyAgreement.PrivateKey()
let clavePublicaAlice = clavePrivadaAlice.publicKey

// Bob genera su par de claves
let clavePrivadaBob = Curve25519.KeyAgreement.PrivateKey()
let clavePublicaBob = clavePrivadaBob.publicKey

// Ambos intercambian claves publicas (pueden ser enviadas en texto plano)
// y derivan la MISMA clave compartida

do {
    let secretoAlice = try clavePrivadaAlice.sharedSecretFromKeyAgreement(
        with: clavePublicaBob
    )

    let secretoBob = try clavePrivadaBob.sharedSecretFromKeyAgreement(
        with: clavePublicaAlice
    )

    // Derivar clave simetrica del secreto compartido
    let sal = "MiApp-v1".data(using: .utf8)!

    let claveAlice = secretoAlice.hkdfDerivedSymmetricKey(
        using: SHA256.self,
        salt: sal,
        sharedInfo: Data(),
        outputByteCount: 32
    )

    let claveBob = secretoBob.hkdfDerivedSymmetricKey(
        using: SHA256.self,
        salt: sal,
        sharedInfo: Data(),
        outputByteCount: 32
    )

    // Ambas claves son identicas — ahora pueden cifrar/descifrar
    let mensaje = "Mensaje secreto de Alice para Bob".data(using: .utf8)!
    let cifrado = try AES.GCM.seal(mensaje, using: claveAlice)
    let descifrado = try AES.GCM.open(cifrado, using: claveBob)

    print("Bob lee: \(String(data: descifrado, encoding: .utf8)!)")
    // Output: "Mensaje secreto de Alice para Bob"

} catch {
    print("Error en key agreement: \(error)")
}
```

### Keychain Services — Almacenamiento Seguro

El Keychain es la boveda de seguridad de Apple. Los datos almacenados estan cifrados por el hardware del dispositivo y protegidos por el passcode o biometria del usuario.

**Regla de oro**: Todo lo que sea sensible (tokens, passwords, claves API) va al Keychain. NUNCA a UserDefaults, archivos planos, o hardcodeado en el codigo.

```swift
import Foundation
import Security

// MARK: - KeychainManager — Wrapper moderno para Keychain

/// Keychain almacena datos cifrados por hardware
/// Sobrevive a reinstalaciones de la app (a menos que uses kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
/// Compartible entre apps del mismo developer via Keychain Groups

enum KeychainError: Error, LocalizedError {
    case duplicado
    case noEncontrado
    case errorDesconocido(OSStatus)

    var errorDescription: String? {
        switch self {
        case .duplicado: return "El item ya existe en Keychain"
        case .noEncontrado: return "Item no encontrado en Keychain"
        case .errorDesconocido(let status): return "Error Keychain: \(status)"
        }
    }
}

struct KeychainManager {

    // MARK: - Guardar

    /// Guarda datos en el Keychain
    static func guardar(servicio: String, cuenta: String, datos: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: cuenta,
            kSecValueData as String: datos,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Si ya existe, actualizamos
            try actualizar(servicio: servicio, cuenta: cuenta, datos: datos)
        default:
            throw KeychainError.errorDesconocido(status)
        }
    }

    // MARK: - Leer

    /// Lee datos del Keychain
    static func leer(servicio: String, cuenta: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: cuenta,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var resultado: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &resultado)

        guard status == errSecSuccess, let datos = resultado as? Data else {
            if status == errSecItemNotFound {
                throw KeychainError.noEncontrado
            }
            throw KeychainError.errorDesconocido(status)
        }

        return datos
    }

    // MARK: - Actualizar

    /// Actualiza datos existentes en el Keychain
    static func actualizar(servicio: String, cuenta: String, datos: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: cuenta
        ]

        let atributos: [String: Any] = [
            kSecValueData as String: datos
        ]

        let status = SecItemUpdate(query as CFDictionary, atributos as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.errorDesconocido(status)
        }
    }

    // MARK: - Eliminar

    /// Elimina un item del Keychain
    static func eliminar(servicio: String, cuenta: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: cuenta
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.errorDesconocido(status)
        }
    }
}

// MARK: - Uso practico

// Guardar un token de autenticacion
let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc123"
let tokenData = token.data(using: .utf8)!

do {
    try KeychainManager.guardar(
        servicio: "com.miapp.api",
        cuenta: "auth-token",
        datos: tokenData
    )
    print("Token guardado en Keychain")

    // Recuperar el token
    let datosRecuperados = try KeychainManager.leer(
        servicio: "com.miapp.api",
        cuenta: "auth-token"
    )
    let tokenRecuperado = String(data: datosRecuperados, encoding: .utf8)!
    print("Token recuperado: \(tokenRecuperado)")

    // Eliminar al cerrar sesion
    try KeychainManager.eliminar(
        servicio: "com.miapp.api",
        cuenta: "auth-token"
    )
    print("Token eliminado del Keychain")

} catch {
    print("Error Keychain: \(error)")
}
```

**Pregunta Socratica**: Por que usar `kSecAttrAccessibleAfterFirstUnlock` en lugar de `kSecAttrAccessibleWhenUnlocked`? Piensa en una app que necesita acceder al token en background para refrescar datos.

### Privacy Manifests — Declarar Uso de Datos

Desde 2024, Apple requiere Privacy Manifests (`PrivacyInfo.xcprivacy`) para todas las apps. Este archivo declara que APIs sensibles usa tu app y por que.

```swift
// MARK: - Privacy Manifests (PrivacyInfo.xcprivacy)

/// El archivo PrivacyInfo.xcprivacy es un Property List que declara:
/// 1. NSPrivacyTracking: Si la app realiza tracking
/// 2. NSPrivacyTrackingDomains: Dominios de tracking
/// 3. NSPrivacyCollectedDataTypes: Tipos de datos recolectados
/// 4. NSPrivacyAccessedAPITypes: APIs que requieren razon

/// Ejemplo de estructura del Privacy Manifest:
/*
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
   "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
     <key>NSPrivacyTracking</key>
     <false/>

     <key>NSPrivacyTrackingDomains</key>
     <array/>

     <key>NSPrivacyCollectedDataTypes</key>
     <array>
         <dict>
             <key>NSPrivacyCollectedDataType</key>
             <string>NSPrivacyCollectedDataTypeEmailAddress</string>
             <key>NSPrivacyCollectedDataTypeLinked</key>
             <true/>
             <key>NSPrivacyCollectedDataTypeTracking</key>
             <false/>
             <key>NSPrivacyCollectedDataTypePurposes</key>
             <array>
                 <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
             </array>
         </dict>
     </array>

     <key>NSPrivacyAccessedAPITypes</key>
     <array>
         <dict>
             <key>NSPrivacyAccessedAPIType</key>
             <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
             <key>NSPrivacyAccessedAPITypeReasons</key>
             <array>
                 <string>CA92.1</string>
             </array>
         </dict>
     </array>
 </dict>
 </plist>
*/
```

#### APIs que Requieren Razon

```swift
// MARK: - APIs que requieren declaracion en Privacy Manifest

/// Las siguientes APIs requieren una razon valida en el manifest:

/// 1. File Timestamp APIs
///    - FileManager.attributesOfItem(atPath:)
///    - Razon: Para verificar si un recurso fue modificado (DDA9.1)

/// 2. System Boot Time APIs
///    - ProcessInfo.processInfo.systemUptime
///    - Razon: Para medir intervalos de tiempo (35F9.1)

/// 3. Disk Space APIs
///    - FileManager.attributesOfFileSystem(forPath:)
///    - Razon: Para verificar espacio antes de descargas (E174.1)

/// 4. Active Keyboards API
///    - UITextInputMode.activeInputModes
///    - Razon: Para adaptar UI al idioma del teclado (54BD.1)

/// 5. User Defaults APIs
///    - UserDefaults.standard
///    - Razon: Para leer/escribir preferencias de la app (CA92.1)

// Ejemplo: verificar espacio en disco antes de una descarga grande
import Foundation

func verificarEspacioDisponible(bytesNecesarios: Int64) -> Bool {
    // Esta API requiere declaracion en Privacy Manifest
    // Razon: E174.1 — verificar espacio antes de escribir
    do {
        let atributos = try FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
        )
        if let espacioLibre = atributos[.systemFreeSize] as? Int64 {
            return espacioLibre > bytesNecesarios
        }
    } catch {
        print("Error verificando espacio: \(error)")
    }
    return false
}

let necesito500MB: Int64 = 500 * 1024 * 1024
if verificarEspacioDisponible(bytesNecesarios: necesito500MB) {
    print("Hay espacio suficiente para la descarga")
} else {
    print("Espacio insuficiente")
}
```

### LocalAuthentication — Biometria

Face ID y Touch ID proporcionan autenticacion rapida y segura. El framework `LocalAuthentication` maneja todo con unas pocas lineas.

```swift
import LocalAuthentication
import Foundation

// MARK: - Autenticacion Biometrica

/// LAContext evalua politicas de autenticacion
/// El sistema decide si usar Face ID, Touch ID o passcode
/// NUNCA almacena datos biometricos — solo el resultado

class GestorBiometria {

    /// Verifica si la biometria esta disponible
    func biometriaDisponible() -> (disponible: Bool, tipo: String) {
        let contexto = LAContext()
        var error: NSError?

        let disponible = contexto.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        let tipo: String
        switch contexto.biometryType {
        case .faceID: tipo = "Face ID"
        case .touchID: tipo = "Touch ID"
        case .opticID: tipo = "Optic ID"  // Vision Pro
        case .none: tipo = "No disponible"
        @unknown default: tipo = "Desconocido"
        }

        return (disponible, tipo)
    }

    /// Autenticar con biometria
    func autenticar() async throws -> Bool {
        let contexto = LAContext()

        // Texto que aparece en el dialogo de biometria
        contexto.localizedReason = "Accede a tu cuenta de forma segura"

        // Texto del boton fallback (si falla biometria)
        contexto.localizedFallbackTitle = "Usar contraseña"

        // Tiempo en segundos que la autenticacion permanece valida
        // Evita pedir biometria repetidamente
        contexto.touchIDAuthenticationAllowableReuseDuration = 30

        do {
            let exito = try await contexto.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Confirma tu identidad"
            )
            return exito
        } catch let error as LAError {
            switch error.code {
            case .userCancel:
                print("Usuario cancelo la autenticacion")
            case .userFallback:
                print("Usuario eligio usar contraseña")
            case .biometryNotAvailable:
                print("Biometria no disponible en este dispositivo")
            case .biometryNotEnrolled:
                print("No hay datos biometricos registrados")
            case .biometryLockout:
                print("Biometria bloqueada por demasiados intentos")
            default:
                print("Error biometrico: \(error.localizedDescription)")
            }
            throw error
        }
    }
}

// Uso
let gestor = GestorBiometria()
let (disponible, tipo) = gestor.biometriaDisponible()
print("Biometria: \(tipo) — Disponible: \(disponible)")
```

**Importante para Info.plist**: Si usas Face ID, DEBES agregar la clave `NSFaceIDUsageDescription` con una explicacion clara de por que la app necesita Face ID.

### Certificate Pinning — Proteccion de Red

Certificate pinning asegura que tu app solo se comunique con el servidor esperado, previniendo ataques man-in-the-middle incluso si un atacante tiene un certificado valido.

```swift
import Foundation

// MARK: - Certificate Pinning con URLSession

/// Certificate pinning compara el certificado del servidor
/// con un hash conocido almacenado en la app

class SesionSegura: NSObject, URLSessionDelegate {

    // Hash SHA256 del certificado de tu servidor
    // Obtener con: openssl s_client -connect api.tuapp.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
    private let hashEsperado = "AABBCCDD1234567890abcdef..."

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {

        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificado = SecTrustCopyCertificateChain(serverTrust)
                as? [SecCertificate],
              let primerCert = certificado.first else {
            return (.cancelAuthenticationChallenge, nil)
        }

        // Obtener clave publica del certificado
        let datosPublicos = SecCertificateCopyKey(primerCert)

        // En produccion: comparar hash de la clave publica
        // con el hash esperado almacenado en la app

        // Si coincide, aceptar la conexion
        let credencial = URLCredential(trust: serverTrust)
        return (.useCredential, credencial)
    }

    func realizarPeticionSegura() async throws -> Data {
        let config = URLSessionConfiguration.default
        let sesion = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )

        let url = URL(string: "https://api.tuapp.com/datos")!
        let (datos, _) = try await sesion.data(from: url)
        return datos
    }
}
```

### Practicas de Codigo Seguro

```swift
import Foundation

// MARK: - Practicas de seguridad en codigo Swift

/// 1. NUNCA hardcodear secretos en el codigo
// MAL:
// let apiKey = "sk-1234567890abcdef"

// BIEN: Cargar desde Keychain o configuracion segura
func obtenerAPIKey() throws -> String {
    let datos = try KeychainManager.leer(
        servicio: "com.miapp.api",
        cuenta: "api-key"
    )
    return String(data: datos, encoding: .utf8)!
}

/// 2. Limpiar datos sensibles de memoria
func procesarDatosSensibles() {
    var buffer = [UInt8](repeating: 0, count: 32)
    // ... usar buffer con datos sensibles ...

    // Limpiar memoria al terminar
    buffer.withUnsafeMutableBufferPointer { ptr in
        ptr.initialize(repeating: 0)
    }
}

/// 3. Validar inputs siempre
func validarEmail(_ email: String) -> Bool {
    let patron = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    return email.range(of: patron, options: .regularExpression) != nil
}

/// 4. Usar HTTPS siempre — App Transport Security
/// En Info.plist, NO desactivar ATS a menos que sea absolutamente necesario
/// Si necesitas una excepcion, se lo mas especifico posible:
/*
 <key>NSAppTransportSecurity</key>
 <dict>
     <key>NSExceptionDomains</key>
     <dict>
         <key>legacy-api.ejemplo.com</key>
         <dict>
             <key>NSExceptionAllowsInsecureHTTPLoads</key>
             <true/>
         </dict>
     </dict>
 </dict>
*/

/// 5. Usar @Sendable y Swift Concurrency para data races
/// Swift 6 strict concurrency checking previene condiciones de carrera
actor AlmacenSeguro {
    private var datos: [String: String] = [:]

    func guardar(clave: String, valor: String) {
        datos[clave] = valor
    }

    func leer(clave: String) -> String? {
        datos[clave]
    }
}
```

---

## Ejercicios

### Ejercicio 1 — Basico: Gestor de Passwords con Keychain

Crea un `PasswordManager` que:
- Guarde passwords cifradas con CryptoKit antes de almacenar en Keychain
- Recupere y descifre passwords
- Liste todos los servicios guardados
- Elimine passwords individuales o todas

```swift
// Esqueleto para empezar
struct PasswordManager {
    private let claveBase: SymmetricKey

    init() {
        // Generar o recuperar clave base del Keychain
        self.claveBase = SymmetricKey(size: .bits256)
    }

    func guardarPassword(servicio: String, usuario: String, password: String) throws {
        // 1. Cifrar password con AES-GCM
        // 2. Guardar en Keychain con servicio y cuenta
    }

    func obtenerPassword(servicio: String, usuario: String) throws -> String {
        // 1. Leer datos cifrados del Keychain
        // 2. Descifrar con AES-GCM
        // 3. Retornar password en texto plano
    }
}
```

**Criterios de exito**: El password nunca existe en texto plano en Keychain — solo datos cifrados.

### Ejercicio 2 — Intermedio: Sistema de Autenticacion Biometrica

Crea un flujo de autenticacion completo que:
- Verifique disponibilidad de biometria
- Autentique con Face ID/Touch ID
- Caiga a password si biometria falla
- Almacene el estado de sesion en Keychain
- Implemente timeout de sesion (5 minutos de inactividad)

```swift
// Esqueleto para empezar
@Observable
class AuthManager {
    var estaAutenticado = false
    var tipoBiometria: String = ""
    private var ultimaActividad: Date = .now
    private let timeoutSegundos: TimeInterval = 300

    func verificarBiometria() { /* ... */ }
    func autenticarConBiometria() async throws { /* ... */ }
    func autenticarConPassword(_ password: String) -> Bool { /* ... */ }
    func verificarTimeout() { /* ... */ }
    func cerrarSesion() { /* ... */ }
}
```

**Criterios de exito**: El usuario puede autenticarse con biometria o password, y la sesion expira automaticamente.

### Ejercicio 3 — Avanzado: Privacy Audit Tool

Crea una herramienta que audite la seguridad de una app:
- Detecte uso de APIs que requieren Privacy Manifest
- Verifique que no haya secretos hardcodeados (buscar patrones como "sk-", "api_key=")
- Valide que Keychain se usa para datos sensibles
- Genere un reporte con recomendaciones
- Integre con el Privacy Manifest para verificar completitud

```swift
// Esqueleto para empezar
struct AuditoriaSeguridad {
    struct Hallazgo {
        let severidad: Severidad
        let descripcion: String
        let recomendacion: String
    }

    enum Severidad: String {
        case critica, alta, media, baja
    }

    func auditarProyecto(ruta: String) -> [Hallazgo] {
        // 1. Escanear archivos .swift por patrones inseguros
        // 2. Verificar PrivacyInfo.xcprivacy existe y es completo
        // 3. Buscar uso de UserDefaults para datos sensibles
        // 4. Verificar ATS no esta desactivado globalmente
        // 5. Generar reporte
    }
}
```

**Criterios de exito**: La herramienta encuentra al menos 5 tipos de vulnerabilidades comunes y genera recomendaciones claras.

---

## 5 Errores Comunes

### Error 1: Guardar tokens en UserDefaults

```swift
// MAL — UserDefaults NO es seguro
// Cualquier proceso con acceso al sandbox puede leer estos datos
UserDefaults.standard.set("mi-token-secreto", forKey: "authToken")

// BIEN — Keychain esta cifrado por hardware
let tokenData = "mi-token-secreto".data(using: .utf8)!
try KeychainManager.guardar(
    servicio: "com.miapp",
    cuenta: "authToken",
    datos: tokenData
)
```

### Error 2: Ignorar errores de CryptoKit

```swift
// MAL — try! crashea si algo falla
let cifrado = try! AES.GCM.seal(datos, using: clave)

// BIEN — Manejar errores apropiadamente
do {
    let cifrado = try AES.GCM.seal(datos, using: clave)
    // usar cifrado...
} catch CryptoKitError.authenticationFailure {
    print("Los datos fueron alterados — posible ataque")
    // Alertar al usuario y al servidor
} catch {
    print("Error de cifrado: \(error)")
    // Fallback seguro
}
```

### Error 3: No declarar APIs en Privacy Manifest

```swift
// MAL — Usar API sin declararla en PrivacyInfo.xcprivacy
// App Store rechazara tu app
let uptime = ProcessInfo.processInfo.systemUptime

// BIEN — Agregar a PrivacyInfo.xcprivacy:
// NSPrivacyAccessedAPIType: NSPrivacyAccessedAPICategorySystemBootTime
// NSPrivacyAccessedAPITypeReasons: ["35F9.1"]
// Y luego usar la API normalmente
```

### Error 4: No manejar biometria no disponible

```swift
// MAL — Asumir que biometria siempre esta disponible
func login() async {
    let contexto = LAContext()
    let ok = try! await contexto.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Login"
    )
}

// BIEN — Verificar disponibilidad y ofrecer alternativa
func login() async {
    let contexto = LAContext()
    var error: NSError?

    if contexto.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        do {
            let ok = try await contexto.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Confirma tu identidad"
            )
            if ok { /* autenticado */ }
        } catch {
            mostrarLoginConPassword()
        }
    } else {
        // Dispositivo sin biometria — ofrecer alternativa
        mostrarLoginConPassword()
    }
}
```

### Error 5: Desactivar ATS globalmente

```swift
// MAL — Desactivar App Transport Security para todo
/*
 <key>NSAppTransportSecurity</key>
 <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>  <!-- NUNCA hacer esto -->
 </dict>
*/

// BIEN — Excepcion especifica solo para dominios que lo necesiten
/*
 <key>NSAppTransportSecurity</key>
 <dict>
     <key>NSExceptionDomains</key>
     <dict>
         <key>api-legacy.ejemplo.com</key>
         <dict>
             <key>NSExceptionAllowsInsecureHTTPLoads</key>
             <true/>
             <key>NSExceptionMinimumTLSVersion</key>
             <string>TLSv1.2</string>
         </dict>
     </dict>
 </dict>
*/
```

---

## Checklist de Objetivos

- [ ] Entiendo la diferencia entre hashing (SHA256) y cifrado (AES-GCM)
- [ ] Puedo cifrar y descifrar datos con CryptoKit AES-GCM
- [ ] Se usar HMAC para verificar integridad y autenticidad de mensajes
- [ ] Puedo guardar, leer, actualizar y eliminar items del Keychain
- [ ] Entiendo por que NUNCA debo guardar secretos en UserDefaults
- [ ] Se crear y configurar un Privacy Manifest (PrivacyInfo.xcprivacy)
- [ ] Puedo listar las APIs que requieren razon en el Privacy Manifest
- [ ] Se implementar autenticacion biometrica con LocalAuthentication
- [ ] Manejo correctamente los errores de biometria (no disponible, lockout, cancel)
- [ ] Entiendo los conceptos basicos de certificate pinning
- [ ] Aplico practicas de codigo seguro (no hardcodear secretos, validar inputs)
- [ ] Puedo explicar key agreement con Curve25519

---

## Notas Personales

> Espacio para tus reflexiones sobre seguridad. Preguntate:
> - Que datos de mi app actual son sensibles y como los estoy almacenando?
> - Tengo secretos hardcodeados en el codigo que deberia mover al Keychain?
> - Mi Privacy Manifest esta completo y actualizado?
> - Estoy manejando correctamente los errores de biometria?
>
> _Escribe aqui tus notas..._

---

## Conexion con el Proyecto Integrador

En el Proyecto Integrador, la seguridad se aplica en multiples capas:

1. **Autenticacion**: Implementar login con Face ID/Touch ID usando `LocalAuthentication`, con fallback a password
2. **Almacenamiento de tokens**: Guardar el token de sesion en Keychain, nunca en UserDefaults
3. **Cifrado local**: Cifrar datos sensibles del usuario con CryptoKit antes de persistirlos con SwiftData
4. **Privacy Manifest**: Crear un `PrivacyInfo.xcprivacy` completo que declare todas las APIs sensibles usadas
5. **Comunicacion segura**: Implementar certificate pinning para las llamadas a tu API backend
6. **Datos de salud**: Si integras HealthKit (Leccion 22), los datos de salud requieren cifrado adicional y declaraciones de privacidad especificas

> La seguridad no se agrega al final — se diseña desde el principio. Cada feature del proyecto debe considerar: que datos maneja, donde los almacena, y como los transmite.

---

*Siguiente leccion: [Leccion 38 — Performance](Leccion38_Performance.md)*
