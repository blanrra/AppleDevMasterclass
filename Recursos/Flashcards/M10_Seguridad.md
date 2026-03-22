# Flashcards — Modulo 10: Seguridad y Performance

---

### Tarjeta 1
**Pregunta:** Que es CryptoKit y que operaciones criptograficas soporta?
**Respuesta:** CryptoKit es el framework de Apple para criptografia moderna y segura. Soporta: 1) **Hashing**: SHA256, SHA384, SHA512. 2) **Cifrado simetrico**: AES-GCM, ChaChaPoly. 3) **Firmas digitales**: P256, P384, P521 (ECDSA). 4) **Acuerdo de claves**: Diffie-Hellman con curvas elipticas. 5) **HMAC**: autenticacion de mensajes. Todo con una API Swift moderna y segura.

---

### Tarjeta 2
**Pregunta:** Como se cifra y descifra datos con AES-GCM en CryptoKit?
**Respuesta:** Cifrar: `let clave = SymmetricKey(size: .bits256)`, `let sellado = try AES.GCM.seal(datos, using: clave)`, `let datosCifrados = sellado.combined!`. Descifrar: `let caja = try AES.GCM.SealedBox(combined: datosCifrados)`, `let original = try AES.GCM.open(caja, using: clave)`. AES-GCM provee cifrado + autenticacion (AEAD) en una sola operacion.

---

### Tarjeta 3
**Pregunta:** Que es el Keychain y cuando debe usarse en lugar de UserDefaults?
**Respuesta:** El Keychain es el almacenamiento cifrado del sistema para datos sensibles. Usar Keychain para: tokens de autenticacion, contrasenas, claves criptograficas, certificados. Usar UserDefaults solo para preferencias no sensibles. El Keychain: 1) Cifra automaticamente. 2) Persiste entre reinstalaciones. 3) Se puede compartir entre apps del mismo grupo. 4) Se protege con biometria.

---

### Tarjeta 4
**Pregunta:** Que son los Privacy Manifests y por que son obligatorios?
**Respuesta:** Los Privacy Manifests (`PrivacyInfo.xcprivacy`) son archivos que declaran: 1) **Tipos de datos** que recopila tu app (nombre, email, ubicacion). 2) **Proposito** de cada dato. 3) **APIs que requieren razon** (UserDefaults, file timestamp, disk space, etc.). Son obligatorios desde 2024 para enviar a App Store. Apple los usa para generar automaticamente la etiqueta de privacidad de la app.

---

### Tarjeta 5
**Pregunta:** Que es Instruments y cuales son sus herramientas principales?
**Respuesta:** Instruments es la suite de profiling de Apple integrada en Xcode. Herramientas principales: 1) **Time Profiler**: identifica funciones que consumen mas CPU. 2) **Allocations**: uso de memoria y objetos creados. 3) **Leaks**: detecta memory leaks. 4) **Network**: analiza trafico de red. 5) **Core Animation**: mide FPS y rendimiento de UI. 6) **Energy Log**: consumo de bateria.

---

### Tarjeta 6
**Pregunta:** Como se usa Time Profiler para encontrar cuellos de botella?
**Respuesta:** 1) Product > Profile en Xcode (Cmd+I). 2) Seleccionar Time Profiler. 3) Grabar mientras reproduces el problema. 4) Analizar el call tree: las funciones con mayor "Weight" consumen mas tiempo. 5) Usar "Invert Call Tree" para ver funciones costosas primero. 6) Filtrar por tu codigo (ocultar llamadas del sistema). El objetivo es encontrar funciones que bloquean el main thread.

---

### Tarjeta 7
**Pregunta:** Como se detectan memory leaks con Instruments?
**Respuesta:** 1) Usar el instrumento **Leaks**. 2) Grabar mientras navegas por la app (entrar y salir de pantallas). 3) Leaks marca con iconos rojos cuando detecta objetos que no se pueden liberar. 4) Inspeccionar el **backtrace** para ver donde se creo el objeto. 5) Los ciclos de referencia son la causa mas comun: buscar closures que capturan `self` sin `[weak self]` y delegates fuertes.

---

### Tarjeta 8
**Pregunta:** Que son las "Required Reason APIs" en el contexto de privacidad?
**Respuesta:** Son APIs del sistema que Apple considera potencialmente usadas para fingerprinting. Incluyen: `UserDefaults`, file timestamps, disk space, boot time, y active keyboard. Al usarlas, debes declarar en el Privacy Manifest **por que** las usas, seleccionando de una lista de razones aprobadas. Si no declaras la razon, App Store Connect rechaza tu build.

---

### Tarjeta 9
**Pregunta:** Como se optimiza el rendimiento de listas largas en SwiftUI?
**Respuesta:** 1) Usar `List` o `LazyVStack` en lugar de `VStack` (carga bajo demanda). 2) Dar `id` estable a cada elemento (no usar indice de array). 3) Extraer vistas de fila a structs separados para minimizar re-renders. 4) Evitar computaciones pesadas en `body`. 5) Usar `@Query` con `FetchDescriptor` paginado. 6) Medir con Instruments antes de optimizar.

---

### Tarjeta 10
**Pregunta:** Que es App Transport Security (ATS) y como funciona?
**Respuesta:** ATS es una politica de seguridad que obliga a usar HTTPS para todas las conexiones de red. Esta habilitada por defecto. Requiere: TLS 1.2+, cifrado fuerte, certificados validos. Para excepciones (desarrollo local): se configura `NSAppTransportSecurity` en Info.plist con dominios permitidos. **Nunca** deshabilitar ATS completamente en produccion: App Review lo rechaza.
