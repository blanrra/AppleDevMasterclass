# Leccion 40: App Store y TestFlight

**Modulo 11: Monetizacion y Distribucion** | Semana 50

---

## TL;DR — Resumen en 2 minutos

- **App Store Connect**: El portal web donde gestionas tu app — metadata, precios, testers, analytics y envios a revision
- **Signing**: Certificates + Provisioning Profiles identifican tu equipo y autorizan tu app; Automatic Signing en Xcode lo simplifica
- **TestFlight**: Distribuye betas a testers internos (hasta 100) y externos (hasta 10,000) con feedback integrado
- **Review Guidelines**: Las reglas que Apple aplica para aceptar tu app — conocerlas evita rechazos
- **Metadata**: Screenshots, descripcion, keywords y previews son tu vitrina — optimizarlos impacta descargas

---

## Cupertino MCP

```bash
cupertino search "App Store Connect"
cupertino search "TestFlight"
cupertino search "App Review"
cupertino search "provisioning profile"
cupertino search "code signing"
cupertino search "app metadata"
cupertino search "phased release"
cupertino search "App Store Connect API"
cupertino search --source updates "App Store Connect"
cupertino search --source hig "app store"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC23 | [What's new in App Store Connect](https://developer.apple.com/videos/play/wwdc2023/10117/) | **Esencial** — Novedades y flujos |
| WWDC22 | [Explore in-app purchase integration and migration](https://developer.apple.com/videos/play/wwdc2022/10040/) | Integracion con App Store Connect |
| WWDC21 | [What's new in managing Apple devices](https://developer.apple.com/videos/play/wwdc2021/10130/) | Certificates y provisioning |
| WWDC24 | [What's new in App Store Connect](https://developer.apple.com/videos/play/wwdc2024/10063/) | Actualizaciones recientes |
| WWDC23 | [Simplify distribution in Xcode and Xcode Cloud](https://developer.apple.com/videos/play/wwdc2023/10015/) | Distribucion desde Xcode |
| :es: | [Julio Cesar Fernandez — Publicar en App Store](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que dominar el proceso de distribucion?

Puedes escribir la mejor app del mundo, pero si no la publicas correctamente, nadie la usara. Muchos desarrolladores pasan semanas programando y luego se frustran con el proceso de publicacion: rechazos por violar guidelines, screenshots mal dimensionados, certificados expirados, o betas que no llegan a los testers.

Dominar App Store Connect y TestFlight no es opcional — es parte fundamental del ciclo de desarrollo profesional. Un desarrollador que conoce el proceso puede publicar una actualizacion en horas, no en dias.

```
  ┌──────────────────────────────────────────────────────────────────┐
  │              CICLO DE VIDA DE UNA APP                            │
  ├──────────────────────────────────────────────────────────────────┤
  │                                                                  │
  │   Desarrollo          Testing           Distribucion             │
  │   ┌──────────┐       ┌──────────┐      ┌──────────────┐         │
  │   │ Xcode    │──────>│TestFlight│─────>│ App Store    │         │
  │   │ Codigo   │       │ Internal │      │ Review       │         │
  │   │ Debug    │       │ External │      │ Aprobacion   │         │
  │   └──────────┘       └──────────┘      │ Publicacion  │         │
  │       │                   │            └──────┬───────┘         │
  │       │                   │                   │                  │
  │       │              Feedback              Analytics             │
  │       │              Crash logs            Descargas             │
  │       │              Screenshots           Retencion             │
  │       │                   │                   │                  │
  │       └───────────────────┘                   │                  │
  │              Iterar                           │                  │
  │              ◄────────────────────────────────┘                  │
  └──────────────────────────────────────────────────────────────────┘
```

### Certificates y Provisioning Profiles — La Base del Signing

Antes de poder ejecutar tu app en un dispositivo real o enviarla a TestFlight, necesitas entender el sistema de firma de codigo de Apple.

```
  ┌──────────────────────────────────────────────────────────────────┐
  │                   SISTEMA DE SIGNING                             │
  ├──────────────────────────────────────────────────────────────────┤
  │                                                                  │
  │   CERTIFICATE (Certificado)                                      │
  │   ┌─────────────────────────────────────┐                        │
  │   │ Identifica a tu equipo/empresa      │                        │
  │   │ Types:                              │                        │
  │   │  • Development — para debug local   │                        │
  │   │  • Distribution — para App Store    │                        │
  │   │ Contiene: clave publica + privada   │                        │
  │   │ Expira: 1 ano                       │                        │
  │   └─────────────────┬───────────────────┘                        │
  │                     │                                            │
  │   APP ID            │     DEVICES (solo Development)             │
  │   ┌────────────┐    │     ┌──────────────┐                       │
  │   │ Bundle ID  │    │     │ UDIDs de     │                       │
  │   │ com.tu.app │    │     │ dispositivos │                       │
  │   └──────┬─────┘    │     │ registrados  │                       │
  │          │          │     └──────┬───────┘                       │
  │          └────┬─────┘           │                                │
  │               │                 │                                │
  │          ┌────▼─────────────────▼────┐                           │
  │          │  PROVISIONING PROFILE     │                           │
  │          │  = Certificate            │                           │
  │          │  + App ID                 │                           │
  │          │  + Devices (dev)          │                           │
  │          │  + Entitlements           │                           │
  │          └───────────────────────────┘                           │
  └──────────────────────────────────────────────────────────────────┘
```

```swift
// MARK: - Conceptos de Signing (no es codigo ejecutable, es referencia)

/*
 TIPOS DE CERTIFICADO:

 1. Apple Development
    - Para ejecutar en dispositivos de desarrollo
    - Maximo 1 por miembro del equipo
    - Requiere que el dispositivo este registrado

 2. Apple Distribution
    - Para enviar a App Store / TestFlight
    - Maximo 3 por equipo
    - No requiere registro de dispositivos

 PROVISIONING PROFILE:
    - Development: Certificate + App ID + Device UDIDs
    - App Store: Certificate + App ID (sin devices)
    - Ad Hoc: Certificate + App ID + hasta 100 devices

 ENTITLEMENTS:
    - Permisos especiales que tu app necesita
    - Push Notifications, HealthKit, CloudKit, etc.
    - Se configuran en App ID y en el proyecto Xcode
*/
```

### Automatic Signing — La Opcion Recomendada

```swift
// MARK: - Configurar Automatic Signing en Xcode

/*
 PASOS:

 1. Xcode > Target > Signing & Capabilities

 2. Marcar "Automatically manage signing"
    - Xcode crea y gestiona:
      • Certificate (Development y Distribution)
      • App ID con tu Bundle Identifier
      • Provisioning Profile
    - Se regenera automaticamente si expira

 3. Seleccionar tu Team (cuenta de desarrollador)
    - Personal Team (gratuito): solo dispositivos propios, no App Store
    - Apple Developer Program ($99/ano): App Store, TestFlight, todo

 4. Bundle Identifier unico
    - Formato: com.tuempresa.tuapp
    - Debe ser unico en todo el App Store
    - No se puede cambiar despues de publicar

 VENTAJAS DE AUTOMATIC SIGNING:
    - No gestionas certificados manualmente
    - No descargas provisioning profiles
    - Xcode resuelve conflictos automaticamente
    - Funciona para Development y Distribution

 CUANDO USAR MANUAL SIGNING:
    - Equipos grandes con CI/CD (Xcode Cloud, Fastlane)
    - Multiples targets con diferentes profiles
    - Distribucion Enterprise (in-house)
*/
```

### App Store Connect — El Portal Central

```swift
// MARK: - Estructura de App Store Connect

/*
 APP STORE CONNECT (appstoreconnect.apple.com)

 ┌─────────────────────────────────────────────────┐
 │  Mi App                                          │
 ├─────────────────────────────────────────────────┤
 │                                                  │
 │  1. INFORMACION DE LA APP                        │
 │     • Nombre (localizado por idioma)             │
 │     • Subtitulo (30 caracteres)                  │
 │     • Categoria primaria y secundaria            │
 │     • Clasificacion por edad (cuestionario)      │
 │     • Politica de privacidad (URL obligatoria)   │
 │                                                  │
 │  2. PRECIOS Y DISPONIBILIDAD                     │
 │     • Precio base (Apple calcula por region)     │
 │     • Paises donde esta disponible               │
 │     • Pre-orders (hasta 180 dias antes)          │
 │                                                  │
 │  3. VERSIONES                                    │
 │     • Version actual en App Store                │
 │     • Version en revision                        │
 │     • Builds subidos desde Xcode/CI              │
 │                                                  │
 │  4. TESTFLIGHT                                   │
 │     • Testers internos y externos                │
 │     • Grupos de testing                          │
 │     • Builds y feedback                          │
 │                                                  │
 │  5. ANALYTICS                                    │
 │     • Descargas, retención, crashes              │
 │     • Ingresos por compras in-app                │
 │     • Fuentes de adquisicion                     │
 │                                                  │
 │  6. COMPRAS IN-APP                               │
 │     • Productos (StoreKit 2 — Leccion 39)        │
 │     • Suscripciones y grupos                     │
 │     • Offer codes y promociones                  │
 │                                                  │
 └─────────────────────────────────────────────────┘
*/
```

### Subir un Build a App Store Connect

```swift
// MARK: - Proceso para subir un build

/*
 DESDE XCODE:

 1. Seleccionar el scheme de Release
    Product > Scheme > Edit Scheme > Archive > Build Configuration: Release

 2. Configurar el target:
    - Version: 1.0.0 (Marketing Version — lo que ve el usuario)
    - Build: 1 (incrementar con cada upload)
    - Bundle ID correcto
    - Signing: Automatic (Distribution)

 3. Archivar:
    Product > Archive (Cmd+Shift+B no sirve — debe ser Archive)
    - Xcode compila en modo Release
    - Genera un .xcarchive en Organizer

 4. Distribuir desde Organizer:
    Window > Organizer
    - Seleccionar el archive
    - "Distribute App"
    - Opciones:
      a) App Store Connect — para TestFlight y App Store
      b) Ad Hoc — para dispositivos registrados (.ipa)
      c) Enterprise — distribucion interna (requiere cuenta Enterprise)
      d) Development — solo para testing

 5. Upload:
    - Xcode valida el build
    - Sube a App Store Connect
    - Procesamiento (5-30 minutos)
    - Recibes email cuando esta listo

 DESDE LINEA DE COMANDOS (CI/CD):

    # Archivar
    xcodebuild archive \
      -project MiApp.xcodeproj \
      -scheme MiApp \
      -archivePath MiApp.xcarchive

    # Exportar
    xcodebuild -exportArchive \
      -archivePath MiApp.xcarchive \
      -exportPath ./build \
      -exportOptionsPlist ExportOptions.plist

    # Subir con altool o xcrun
    xcrun altool --upload-app \
      -f build/MiApp.ipa \
      -t ios \
      -u tu@email.com \
      -p @keychain:AC_PASSWORD

    # O con la nueva herramienta notarytool (Xcode 13+)
    xcrun notarytool submit build/MiApp.ipa \
      --apple-id tu@email.com \
      --team-id TU_TEAM_ID \
      --password @keychain:AC_PASSWORD
*/
```

### TestFlight — Distribucion de Betas

```swift
// MARK: - TestFlight: Testers Internos vs Externos

/*
 TESTERS INTERNOS:
    - Miembros de tu equipo en App Store Connect
    - Hasta 100 testers
    - Reciben builds INMEDIATAMENTE (sin revision de Apple)
    - Roles: Admin, App Manager, Developer, Marketing, Finance
    - Ideal para: equipo de desarrollo, QA interno

 TESTERS EXTERNOS:
    - Cualquier persona con email
    - Hasta 10,000 testers por app
    - Se organizan en Grupos
    - El PRIMER build de cada version requiere Beta App Review
      (generalmente 24-48 horas, mas rapido que App Review)
    - Builds posteriores de la misma version NO requieren revision
    - Ideal para: beta publica, clientes seleccionados, comunidad

 FLUJO:
    1. Subir build desde Xcode
    2. Esperar procesamiento (5-30 min)
    3. Internal Testers → se notifica automaticamente
    4. External Testers → agregar a grupo → submit for review → aprobar → notificar
    5. Testers instalan via app TestFlight
    6. Testers envian feedback (screenshots + texto) desde la app
    7. Crash reports aparecen en App Store Connect

 DURACION:
    - Cada build expira en 90 dias
    - Los testers reciben aviso de expiracion
    - Debes subir nuevo build antes de que expire
*/
```

### Configurar TestFlight Programaticamente

```swift
import SwiftUI

// MARK: - Detectar si la app corre en TestFlight

func esTestFlight() -> Bool {
    // TestFlight instala un receipt diferente
    guard let receiptURL = Bundle.main.appStoreReceiptURL else {
        return false
    }
    return receiptURL.lastPathComponent == "sandboxReceipt"
}

// MARK: - Vista con informacion de build para testers

struct InfoBuildView: View {
    var body: some View {
        if esTestFlight() {
            Section("Info de Testing") {
                LabeledContent("Version",
                    value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")
                LabeledContent("Build",
                    value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")
                LabeledContent("Entorno", value: "TestFlight")

                Button("Enviar feedback") {
                    // TestFlight tiene su propio mecanismo de feedback
                    // Los testers pueden hacer screenshot y enviar desde TestFlight
                }
            }
        }
    }
}

// MARK: - Enviar datos de diagnostico a tu servidor (para testers)

struct DiagnosticoTester {
    let version: String
    let build: String
    let dispositivo: String
    let sistemaOperativo: String
    let esTestFlight: Bool

    static var actual: DiagnosticoTester {
        let info = Bundle.main.infoDictionary ?? [:]
        return DiagnosticoTester(
            version: info["CFBundleShortVersionString"] as? String ?? "?",
            build: info["CFBundleVersion"] as? String ?? "?",
            dispositivo: modeloDispositivo(),
            sistemaOperativo: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            esTestFlight: SwiftLearning.esTestFlight()
        )
    }

    private static func modeloDispositivo() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { id, element in
            guard let value = element.value as? Int8, value != 0 else { return id }
            return id + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
```

### App Store Review Guidelines — Evitar Rechazos

```swift
// MARK: - Razones comunes de rechazo y como evitarlas

/*
 LAS 10 RAZONES MAS COMUNES DE RECHAZO:

 1. BUGS Y CRASHES (Guideline 2.1)
    - La app crashea durante la revision
    - Funcionalidades incompletas o placeholders
    SOLUCION: Probar exhaustivamente en TestFlight antes de enviar

 2. LINKS ROTOS O CONTENIDO PLACEHOLDER (Guideline 2.1)
    - Textos "Lorem ipsum" visibles
    - Botones que no hacen nada
    - URLs que llevan a paginas 404
    SOLUCION: Revisar TODA la app como usuario final

 3. INFORMACION DE LOGIN (Guideline 2.1)
    - La app requiere login pero no proporcionas credenciales de demo
    SOLUCION: En "App Review Information" incluir usuario y password de prueba

 4. PERMISOS SIN JUSTIFICACION (Guideline 5.1.1)
    - Pedir acceso a camara, ubicacion, contactos sin explicar por que
    - NSUsageDescription generico: "Esta app necesita acceso"
    SOLUCION: Mensajes claros y especificos en Info.plist
      MAL:  "La app necesita acceso a tu ubicacion"
      BIEN: "Usamos tu ubicacion para mostrarte restaurantes cercanos"

 5. COMPRAS IN-APP MAL IMPLEMENTADAS (Guideline 3.1.1)
    - No incluir boton de "Restaurar compras"
    - Forzar compra para funcionalidad basica
    - Dirigir a web para pagos (evitando comision de Apple)
    SOLUCION: Usar StoreKit 2 correctamente (Leccion 39)

 6. PRIVACIDAD (Guideline 5.1.2)
    - No incluir Privacy Policy (obligatoria)
    - Privacy Nutrition Labels incorrectas en App Store Connect
    - Recolectar datos sin consentimiento
    SOLUCION: Privacy Policy real, Privacy Manifests actualizados

 7. CONTENIDO MINIMO (Guideline 4.2)
    - La app es demasiado simple (un wrapper de website)
    - Funcionalidad que ya ofrece iOS nativamente
    SOLUCION: Agregar valor real que justifique una app nativa

 8. METADATA ENGANOSA (Guideline 2.3)
    - Screenshots que no reflejan la app real
    - Descripcion con funcionalidades que no existen
    - Keywords irrelevantes (spam)
    SOLUCION: Screenshots reales, descripcion honesta

 9. CONTENIDO GENERADO POR USUARIOS SIN MODERACION (Guideline 1.2)
    - Chat, comentarios, fotos sin sistema de reportes
    - Sin mecanismo para bloquear usuarios abusivos
    SOLUCION: Implementar report/block y moderacion

 10. INTELLECTUAL PROPERTY (Guideline 5.2)
     - Usar marcas, logos o contenido protegido sin permiso
     - Nombre de app similar a una app famosa
     SOLUCION: Nombres originales, solo contenido propio o con licencia
*/

// MARK: - Notas de App Review (campo en App Store Connect)

/*
 El campo "App Review Information > Notes" es tu comunicacion directa
 con el revisor de Apple. Usalo para:

 - Explicar funcionalidades no obvias
 - Proporcionar credenciales de demo
 - Aclarar por que necesitas ciertos permisos
 - Explicar el modelo de negocio
 - Enlazar a documentacion del hardware requerido

 Ejemplo:
 "Para probar la funcionalidad de escaneo QR, use los codigos de ejemplo
  adjuntos en los screenshots. La funcion de HealthKit requiere datos
  que puede generar en la app Health (Salud). Usuario demo: test@app.com
  Password: Review2026!"
*/
```

### Metadata — Tu Vitrina en el App Store

```swift
// MARK: - Optimizacion de metadata (ASO — App Store Optimization)

/*
 NOMBRE DE LA APP (30 caracteres max)
    - Incluir keyword principal si es natural
    - MAL:  "Mi App Genial de Tareas Todo List Organizador"
    - BIEN: "Taskify — Gestor de Tareas"

 SUBTITULO (30 caracteres max)
    - Complementa el nombre con beneficio clave
    - Ejemplo: "Organiza tu dia con IA"

 KEYWORDS (100 caracteres max, separadas por coma)
    - Sin espacios despues de la coma (ahorra caracteres)
    - No repetir palabras del nombre (Apple ya las indexa)
    - Incluir sinonimos y variaciones
    - MAL:  "tareas, lista de tareas, gestor de tareas"
    - BIEN: "productividad,organizador,habitos,recordatorios,planificador"

 DESCRIPCION (4000 caracteres max)
    - Las primeras 3 lineas son las mas importantes (se ven sin "mas...")
    - Estructura: beneficio principal > features > social proof
    - No repetir keywords innecesariamente

 SCREENSHOTS (requeridos)
    - iPhone 6.9" (iPhone 16 Pro Max) — OBLIGATORIO
    - iPhone 6.7" (iPhone 16 Plus)
    - iPad 13" (iPad Pro M4)
    - Hasta 10 screenshots por tamaño
    - Los primeros 3 son los mas importantes (visible sin scroll)
    - Incluir texto descriptivo sobre cada screenshot
    - Mostrar la app en uso, no solo pantallas estaticas

 APP PREVIEW (videos opcionales)
    - Hasta 3 videos de 15-30 segundos
    - Se reproducen automaticamente (sin sonido) en el App Store
    - Muestran funcionalidad real — no animacion de marketing
    - Tamaño maximo: 500 MB
*/
```

### Phased Release y Distribucion Gradual

```swift
// MARK: - Phased Release (distribucion gradual)

/*
 En lugar de publicar a todos los usuarios al mismo tiempo,
 puedes hacer un Phased Release que distribuye gradualmente
 durante 7 dias:

 Dia 1: 1% de usuarios
 Dia 2: 2% de usuarios
 Dia 3: 5% de usuarios
 Dia 4: 10% de usuarios
 Dia 5: 20% de usuarios
 Dia 6: 50% de usuarios
 Dia 7: 100% de usuarios

 VENTAJAS:
 - Detectar crashes en un porcentaje pequeno antes de afectar a todos
 - Monitorear metricas de retencion y engagement
 - Puedes PAUSAR o REANUDAR el rollout en cualquier momento
 - Si hay un bug grave, puedes pausar y publicar un fix

 NOTA: Los usuarios que buscan la actualizacion manualmente
 la reciben inmediatamente — Phased Release solo afecta
 las actualizaciones automaticas.

 COMO ACTIVARLO:
 App Store Connect > tu app > la version > Phased Release for Automatic Updates
*/
```

### App Store Connect API — Automatizacion

```swift
// MARK: - App Store Connect API (automatizacion)

/*
 La App Store Connect API permite automatizar tareas via REST:
 - Gestionar builds y versiones
 - Gestionar testers de TestFlight
 - Leer sales reports y analytics
 - Gestionar metadata programaticamente
 - Gestionar certificates y profiles

 AUTENTICACION:
 - Usa JSON Web Tokens (JWT) firmados con una API Key
 - Las API Keys se crean en App Store Connect > Users and Access > Keys
 - Roles: Admin, Developer, Finance, etc.

 HERRAMIENTAS QUE USAN ESTA API:
 - Fastlane: automatizacion de builds, screenshots, y uploads
 - Xcode Cloud: CI/CD nativo de Apple
 - Scripts personalizados con Swift/Python

 EJEMPLO CON CURL:
*/

// Generar JWT para autenticacion (conceptual)
/*
 # Header
 {
   "alg": "ES256",
   "kid": "TU_KEY_ID",
   "typ": "JWT"
 }

 # Payload
 {
   "iss": "TU_ISSUER_ID",
   "iat": 1616600000,
   "exp": 1616603600,
   "aud": "appstoreconnect-v1"
 }

 # Endpoint ejemplo: listar apps
 curl -H "Authorization: Bearer $JWT" \
   https://api.appstoreconnect.apple.com/v1/apps
*/
```

### Xcode Cloud — CI/CD Nativo

```swift
// MARK: - Xcode Cloud (CI/CD integrado)

/*
 Xcode Cloud es el servicio de CI/CD de Apple integrado en Xcode y
 App Store Connect. Ventajas sobre alternativas:

 CARACTERISTICAS:
 - Compilar y archivar automaticamente al hacer push
 - Ejecutar tests en multiples simuladores
 - Distribuir a TestFlight automaticamente
 - Integrado con App Store Connect — no requiere setup externo
 - Entorno macOS gestionado por Apple (siempre actualizado)

 WORKFLOWS:
 1. Start Condition: push a branch, pull request, tag, schedule
 2. Environment: Xcode version, macOS version
 3. Actions: Build, Test, Archive, Analyze
 4. Post-Actions: Notify (Slack, email), Deploy to TestFlight

 EJEMPLO DE WORKFLOW:
 - Al hacer push a "main":
   1. Build el proyecto
   2. Ejecutar unit tests
   3. Ejecutar UI tests en iPhone y iPad
   4. Si todo pasa: Archive y subir a TestFlight (internal)
   5. Notificar al equipo en Slack

 CONFIGURAR:
 - Xcode > Product > Xcode Cloud > Create Workflow
 - O desde App Store Connect > Xcode Cloud

 HORAS INCLUIDAS:
 - Apple Developer Program incluye 25 horas/mes de compute
 - Suficiente para proyectos individuales y equipos pequenos
 - Se pueden comprar bloques adicionales

 ci_post_clone.sh — Script personalizado:
*/

// Ejemplo de ci_post_clone.sh para instalar dependencias
/*
 #!/bin/sh
 # Instalar herramientas necesarias
 brew install swiftlint

 # Instalar SPM dependencies (Xcode Cloud lo hace automaticamente)
 # Configurar variables de entorno
 echo "Build number: $CI_BUILD_NUMBER"
 echo "Branch: $CI_BRANCH"
*/
```

### Privacy Manifests y Nutrition Labels

```swift
// MARK: - Privacy Manifests (obligatorios desde 2024)

/*
 A partir de primavera 2024, Apple requiere que todas las apps
 y SDKs de terceros incluyan un Privacy Manifest (PrivacyInfo.xcprivacy).

 EL ARCHIVO DECLARA:
 1. Privacy Nutrition Labels (tipos de datos recolectados)
 2. Required Reason APIs (APIs que requieren justificacion)
 3. Tracking domains (dominios de tracking)
 4. Data linked to user vs not linked

 REQUIRED REASON APIs (ejemplos):
 - UserDefaults — razon: guardar preferencias del usuario
 - NSFileSystemFreeSize — razon: verificar espacio disponible
 - systemUptime — razon: calcular intervalos
 - NSProcessInfo.activeProcessorCount — razon: optimizar rendimiento

 PRIVACY NUTRITION LABELS (en App Store Connect):
 - Datos recolectados: nombre, email, ubicacion, fotos, etc.
 - Proposito: funcionalidad, analytics, publicidad, etc.
 - Linked to user: si/no
 - Used for tracking: si/no

 Si mientes en las labels, Apple puede rechazar actualizaciones
 o eliminar tu app.
*/

// Ejemplo de PrivacyInfo.xcprivacy (formato plist simplificado)
/*
 <?xml version="1.0" encoding="UTF-8"?>
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

### Vista Completa: Paywall + Info de Suscripcion

```swift
import SwiftUI
import StoreKit

// MARK: - Pantalla de configuracion con info de suscripcion y version

struct ConfiguracionAppView: View {
    @State private var esPremium = false
    @State private var versionInfo = ""

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Estado de suscripcion
                Section("Suscripcion") {
                    if esPremium {
                        Label("Plan Premium Activo", systemImage: "crown.fill")
                            .foregroundStyle(.yellow)
                        Button("Gestionar suscripcion") {
                            // Abre la gestion de suscripciones de Apple
                            Task {
                                if let windowScene = UIApplication.shared
                                    .connectedScenes.first as? UIWindowScene {
                                    try? await AppStore
                                        .showManageSubscriptions(in: windowScene)
                                }
                            }
                        }
                    } else {
                        NavigationLink("Ver planes Premium") {
                            // PantallaSuscripcion() de Leccion 39
                            Text("Paywall aqui")
                        }
                    }
                }

                // MARK: - Info de la app
                Section("Acerca de") {
                    LabeledContent("Version", value: versionApp)
                    LabeledContent("Build", value: buildApp)
                    if esTestFlight() {
                        Label("TestFlight Beta", systemImage: "hammer.fill")
                            .foregroundStyle(.blue)
                    }
                }

                // MARK: - Legal
                Section("Legal") {
                    Link("Politica de Privacidad",
                         destination: URL(string: "https://tuapp.com/privacy")!)
                    Link("Terminos de Uso",
                         destination: URL(string: "https://tuapp.com/terms")!)
                    Link("EULA",
                         destination: URL(string: "https://tuapp.com/eula")!)
                }

                // MARK: - Soporte
                Section("Soporte") {
                    Link("Contactar Soporte",
                         destination: URL(string: "mailto:soporte@tuapp.com")!)
                    Button("Calificar en App Store") {
                        solicitarResena()
                    }
                }
            }
            .navigationTitle("Configuracion")
        }
    }

    // MARK: - Helpers

    var versionApp: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    var buildApp: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }

    func esTestFlight() -> Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }

    func solicitarResena() {
        if let windowScene = UIApplication.shared
            .connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
```

### Checklist Pre-Envio a App Store

```swift
// MARK: - Checklist antes de enviar a revision

/*
 CODIGO:
 [ ] Sin crashes conocidos — probar en TestFlight minimo 1 semana
 [ ] Sin memory leaks — verificar con Instruments
 [ ] Sin warnings del compilador (idealmente 0 warnings)
 [ ] Todas las APIs con permisos tienen NSUsageDescription descriptivo
 [ ] Privacy Manifest (PrivacyInfo.xcprivacy) actualizado
 [ ] StoreKit: boton de restaurar compras visible
 [ ] Version y Build numbers incrementados

 APP STORE CONNECT:
 [ ] Screenshots para todos los tamaños requeridos
 [ ] Descripcion clara y honesta (sin keywords spam)
 [ ] Keywords optimizados (100 chars max, sin repetir nombre)
 [ ] Categoria correcta (primaria y secundaria)
 [ ] Clasificacion por edad actualizada (cuestionario)
 [ ] URL de Privacy Policy valida y accesible
 [ ] Informacion de contacto del soporte
 [ ] App Review Notes con credenciales de demo (si requiere login)
 [ ] Privacy Nutrition Labels correctas

 TESTFLIGHT:
 [ ] Build probado por internal testers (sin crashes)
 [ ] Build probado por external testers (feedback positivo)
 [ ] Probado en dispositivos reales (no solo simulador)
 [ ] Probado en la version minima de iOS soportada
 [ ] Probado en iPad si la app es Universal

 LEGAL:
 [ ] EULA personalizado (si aplica) o usar el estandar de Apple
 [ ] No usar contenido protegido sin licencia
 [ ] Cumplir con GDPR/CCPA si aplica (usuarios en EU/California)
*/
```

---

## Ejercicio 1: Preparar App para TestFlight (Basico)

**Objetivo**: Configurar un proyecto Xcode listo para distribucion via TestFlight.

**Requisitos**:
1. Crear un proyecto nuevo con Bundle ID unico (com.tunombre.ejercicio40)
2. Configurar Automatic Signing con tu Team
3. Configurar Version (1.0.0) y Build (1) correctamente
4. Agregar al menos 3 entradas de NSUsageDescription en Info.plist con textos descriptivos
5. Crear una vista `InfoBuildView` que muestre version, build y si es TestFlight
6. Archivar el proyecto (Product > Archive) y verificar que compila sin errores en Release

---

## Ejercicio 2: Metadata y Screenshots Optimizados (Intermedio)

**Objetivo**: Preparar toda la metadata necesaria para una publicacion en App Store.

**Requisitos**:
1. Escribir nombre (30 chars max) y subtitulo (30 chars max) para tu app
2. Escribir descripcion de App Store (minimo 500 caracteres) con estructura: beneficio > features > CTA
3. Optimizar 100 caracteres de keywords (sin repetir palabras del nombre, sin espacios despues de comas)
4. Crear una vista `ConfiguracionAppView` con seccion de suscripcion, info de la app, legal y soporte
5. Implementar `SKStoreReviewController.requestReview` en un momento contextual (no al abrir la app)
6. Crear un `PrivacyInfo.xcprivacy` basico declarando al menos UserDefaults como Required Reason API

---

## Ejercicio 3: Pipeline Completo de Distribucion (Avanzado)

**Objetivo**: Simular el flujo completo desde desarrollo hasta publicacion.

**Requisitos**:
1. Crear un proyecto con al menos 3 pantallas funcionales (sin placeholders ni lorem ipsum)
2. Configurar un StoreKit Configuration File con 2 productos (Leccion 39) integrados en la app
3. Implementar deteccion de entorno (Debug, TestFlight, App Store) con UI diferenciada
4. Crear una vista de "What's New" que muestre las novedades de la version actual
5. Implementar phased release mentality: Feature Flags basicos con `UserDefaults` o `@AppStorage`
6. Escribir App Review Notes explicando como probar la app (credenciales demo, funcionalidades clave)
7. Crear checklist pre-envio como un archivo JSON o enum Swift con todos los items verificables
8. Documentar las 5 razones de rechazo mas probables para tu app especifica y como las preveniste

---

## 5 Errores Comunes

### 1. No incrementar el Build number antes de subir

```swift
// MAL — mismo build number que el anterior
// App Store Connect rechaza el upload con:
// "ERROR ITMS-90062: This bundle is invalid.
//  The value for key CFBundleVersion [1] in the Info.plist
//  must contain a higher version than that of the previously
//  uploaded version [1]."

// BIEN — incrementar Build number cada vez
// Version: 1.0.0 (se mantiene para la misma release)
// Build:   1 → 2 → 3 → 4 (incrementar con cada upload)

// Automatizar con script de build:
// agvtool next-version -all
// O en Build Settings: CURRENT_PROJECT_VERSION = $(inherited)
```

### 2. Screenshots que no coinciden con la app real

```swift
// MAL — usar mockups de Figma en lugar de la app real
// Apple puede rechazar si los screenshots no reflejan la experiencia real
// "Guideline 2.3.1 — Your app's screenshots do not sufficiently
//  reflect your app in use"

// BIEN — capturar screenshots reales de la app
// Usar el simulador con Cmd+S (guardar screenshot)
// O mejor: automatizar con UI Tests

/*
 // UI Test para generar screenshots automaticamente
 func testGenerarScreenshots() {
     let app = XCUIApplication()
     app.launch()

     // Pantalla principal
     let screenshot1 = app.screenshot()
     let attachment1 = XCTAttachment(screenshot: screenshot1)
     attachment1.name = "01_Pantalla_Principal"
     attachment1.lifetime = .keepAlways
     add(attachment1)

     // Navegar a segunda pantalla
     app.buttons["Ver Detalle"].tap()
     let screenshot2 = app.screenshot()
     let attachment2 = XCTAttachment(screenshot: screenshot2)
     attachment2.name = "02_Detalle"
     attachment2.lifetime = .keepAlways
     add(attachment2)
 }
*/
```

### 3. No proporcionar credenciales de demo para App Review

```swift
// MAL — la app requiere login pero no hay forma de probarlo
// El revisor no puede crear cuenta → rechazo inmediato
// "We were unable to review your app as it crashed on launch.
//  We need to be able to fully access your app to complete our review."

// BIEN — proporcionar credenciales en App Review Information
/*
 App Store Connect > tu app > App Review Information:

 Sign-in Information:
   Username: reviewer@tuapp.com
   Password: Review2026!

 Notes for Reviewer:
   "Para probar la funcionalidad completa, use las credenciales
    proporcionadas. La cuenta tiene datos de ejemplo precargados.
    La funcion de escaneo QR puede probarse con los codigos en
    los screenshots adjuntos."
*/
```

### 4. Olvidar la URL de Privacy Policy

```swift
// MAL — campo de Privacy Policy vacio
// Desde 2018, Apple requiere Privacy Policy para TODAS las apps
// Incluso apps que no recolectan datos necesitan una

// BIEN — tener una Privacy Policy accesible
/*
 Opciones gratuitas:
 1. Generar con herramientas como privacypolicytemplate.net
 2. Publicar en GitHub Pages (gratis)
 3. Publicar en tu sitio web

 La URL debe:
 - Ser accesible publicamente (sin login)
 - Cargar correctamente (Apple la verifica)
 - Estar en el idioma de la app (o ingles)
 - Describir que datos recolectas y como los usas

 Si no recolectas NINGUN dato:
 "Esta aplicacion no recolecta, almacena ni comparte
  datos personales del usuario."
*/
```

### 5. Enviar a revision sin probar en TestFlight

```swift
// MAL — archivar y enviar directamente a App Store Review
// Si hay un crash que no detectaste, pierdes dias esperando la revision
// y luego mas dias resolviendo el rechazo

// BIEN — flujo profesional
/*
 1. Subir build a App Store Connect
 2. Distribuir a Internal Testers (inmediato)
 3. Probar durante 2-3 dias con el equipo
 4. Distribuir a External Testers (requiere Beta Review ~24h)
 5. Probar durante 1 semana con beta testers
 6. Revisar crash reports en App Store Connect
 7. Solo si no hay crashes criticos → Submit for App Review
 8. Activar Phased Release al ser aprobado

 Este flujo agrega ~2 semanas pero previene:
 - Rechazos por bugs
 - Reviews de 1 estrella por crashes
 - Actualizaciones de emergencia (hotfixes)
*/
```

---

## Checklist

- [ ] Entender el sistema de signing: Certificates, App IDs, Provisioning Profiles
- [ ] Configurar Automatic Signing correctamente en Xcode
- [ ] Saber la diferencia entre Version (marketing) y Build number
- [ ] Archivar un proyecto y subirlo a App Store Connect desde Xcode Organizer
- [ ] Configurar TestFlight con internal testers y external testers
- [ ] Detectar programaticamente si la app corre en TestFlight
- [ ] Conocer las 10 razones mas comunes de rechazo de App Review
- [ ] Preparar metadata optimizada: nombre, subtitulo, keywords, descripcion
- [ ] Crear screenshots para todos los tamaños requeridos
- [ ] Configurar Privacy Policy URL y Privacy Nutrition Labels
- [ ] Crear PrivacyInfo.xcprivacy con Required Reason APIs
- [ ] Entender Phased Release y cuando usarlo
- [ ] Implementar SKStoreReviewController para solicitar resenas
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

El proceso de distribucion es la etapa final del proyecto integrador:
- **Signing**: Configurar Automatic Signing con tu Bundle ID unico para el proyecto
- **TestFlight**: Distribuir la beta del proyecto a testers externos para recibir feedback real antes de publicar
- **Metadata**: Preparar screenshots profesionales de las pantallas principales del proyecto para el App Store
- **Privacy**: Crear el Privacy Manifest declarando todas las APIs y datos que usa el proyecto (HealthKit, ubicacion, SwiftData)
- **Review**: Escribir notas detalladas para el revisor explicando como probar las funcionalidades avanzadas (IA, sensores, widgets)
- **Phased Release**: Usar distribucion gradual para la primera version publica y monitorear crashes antes de llegar al 100%

---

*Leccion 40 | App Store y TestFlight | Semana 50 | Modulo 11: Monetizacion y Distribucion*
*Siguiente: Modulo 12 — Extras y Especializacion*
