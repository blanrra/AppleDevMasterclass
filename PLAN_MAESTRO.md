# PLAN MAESTRO — Guia Apple Developer (48 Semanas)

Curriculum unificado que fusiona SwiftLearning + AppleEcosystemPlan en una guia de 48 semanas, 13 modulos, 40 lecciones. De intermedio a experto en el ecosistema Apple completo.

---

## Datos del Plan

| Aspecto | Detalle |
|---------|---------|
| **Duracion** | 48 semanas (~12 meses) |
| **Modulos** | 13 (00-12) |
| **Lecciones** | 40 |
| **Horas/dia** | 1-2 horas |
| **Target** | iOS 26, iPadOS 26, watchOS 26, visionOS 26, macOS Tahoe 26 |
| **Xcode** | 26 (Swift 6.2) |
| **Fuente** | Cupertino MCP (documentacion oficial Apple) |
| **Origen** | Fusion de SwiftLearning (8 fases) + AppleEcosystemPlan (15 modulos) |

---

## Vista General

| Modulo | Nombre | Semanas | Lecciones | Temas Clave |
|--------|--------|---------|-----------|-------------|
| 00 | Fundamentos | 1-8 | L01-L06 | Swift 6, POP, Genericos, Errores, Memoria, Concurrencia, Xcode, SwiftUI basico |
| 01 | Arquitectura | 9-10 | L07-L08 | MVVM, Clean Architecture, Inyeccion de dependencias |
| 02 | Diseno y UX | 11-12 | L09-L10 | HIG, Liquid Glass, SF Symbols, Accesibilidad |
| 03 | SwiftUI Avanzado | 13-18 | L11-L14 | Navegacion, Composicion, Listas, Animaciones |
| 04 | Datos y Persistencia | 19-22 | L15-L17 | SwiftData, CloudKit, Networking |
| 05 | Hardware y Sensores | 23-26 | L18-L20 | HealthKit, Location/Maps, Camera/Photos |
| 06 | IA y ML | 27-30 | L21-L23 | Foundation Models, ImagePlayground, CoreML/Vision |
| 07 | Integracion Sistema | 31-34 | L24-L26 | App Intents, Siri, Widgets, Live Activities, Notificaciones |
| 08 | Plataformas | 35-38 | L27-L29 | watchOS, visionOS, macOS, iPadOS |
| 09 | Testing y Calidad | 39-42 | L30-L32 | XCTest, Swift Testing, UI Testing, SwiftLint |
| 10 | Seguridad y Performance | 43-44 | L33-L34 | CryptoKit, Privacy Manifests, Instruments |
| 11 | Monetizacion y Distribucion | 45-46 | L35-L36 | StoreKit 2, App Store, TestFlight |
| 12 | Extras y Especializacion | 47-48 | L37-L40 | Server-Side Swift, Metal, Combine, Open Source |

---

## Detalle por Modulo

### MODULO 00: FUNDAMENTOS (Semanas 1-8)

El modulo mas extenso. Establece las bases solidas de Swift 6 y SwiftUI.

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L01 | 1-2 | Swift 6 Language | Type inference, optionals, closures, structs/classes, enums, protocolos basicos, genericos basicos, error handling | `cupertino search --source swift-book "language guide"` |
| L02 | 2-3 | POP y Genericos Avanzados | Protocol extensions, protocol composition, associated types, conditional conformance, generics constraints, where clauses, opaque types (some/any) | `cupertino search "protocol oriented programming"` |
| L03 | 3-4 | Manejo de Errores y Memoria | Result type, typed throws, ARC, strong/weak/unowned, retain cycles, value vs reference semantics, copy-on-write | `cupertino search "automatic reference counting"` |
| L04 | 4-6 | Concurrencia Moderna | async/await, Task, TaskGroup, actors, @MainActor, Sendable, structured concurrency, AsyncSequence, AsyncStream, task cancellation | `cupertino search "swift concurrency"` |
| L05 | 6-7 | Xcode 26 | Configuracion de proyecto, debugging, breakpoints, Instruments basico, previews, simulador, schemes, SPM | `cupertino search --source updates "Xcode 26"` |
| L06 | 7-8 | SwiftUI Fundamentos | View protocol, @State, @Binding, @Observable, body, modifiers, stacks, controles basicos, listas simples, navegacion basica | `cupertino search "SwiftUI fundamentals"` |

**Proyecto practico**: Libreria de networking type-safe con async/await y manejo robusto de errores.

---

### MODULO 01: ARQUITECTURA (Semanas 9-10)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L07 | 9 | MVVM en SwiftUI | Patron MVVM, separation of concerns, ViewModels con @Observable, bindings, estado local vs global | `cupertino search "MVVM SwiftUI"` |
| L08 | 10 | Clean Architecture y DI | Capas (Presentation/Domain/Data), repository pattern, inyeccion de dependencias, Environment-based injection, protocol abstractions | `cupertino search "dependency injection SwiftUI"` |

**Proyecto practico**: Refactorizar app anterior con Clean Architecture.

---

### MODULO 02: DISENO Y UX (Semanas 11-12)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L09 | 11 | HIG, Liquid Glass y SF Symbols | Human Interface Guidelines, Liquid Glass design system, SF Symbols 6, typography, color system, iconografia | `cupertino search --source hig "design"` |
| L10 | 12 | Accesibilidad | VoiceOver, Dynamic Type, accessibility modifiers, accessibility labels, accessibility traits, AX audit | `cupertino search "accessibility SwiftUI"` |

---

### MODULO 03: SWIFTUI AVANZADO (Semanas 13-18)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L11 | 13-14 | Navegacion Avanzada | NavigationStack, NavigationSplitView, NavigationPath, programmatic navigation, deep linking, coordinators | `cupertino search "NavigationStack"` |
| L12 | 15 | Composicion de Vistas | ViewBuilder, custom view modifiers, preference keys, GeometryReader, Layout protocol, custom containers | `cupertino search "ViewBuilder SwiftUI"` |
| L13 | 16 | Listas y Colecciones | List, LazyVStack, LazyVGrid, ForEach, Searchable, Section, Pull-to-refresh, pagination, performance | `cupertino search "List SwiftUI"` |
| L14 | 17-18 | Animaciones y Transiciones | Animation, withAnimation, matchedGeometryEffect, PhaseAnimator, KeyframeAnimator, custom transitions, Canvas, TimelineView | `cupertino search "animation SwiftUI"` |

**Proyecto practico**: App de seguimiento de habitos con navegacion compleja y animaciones.

---

### MODULO 04: DATOS Y PERSISTENCIA (Semanas 19-22)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L15 | 19-20 | SwiftData | @Model, ModelContainer, ModelContext, relaciones, migraciones, queries, predicados, sorting, @Query | `cupertino search "SwiftData"` |
| L16 | 21 | CloudKit | CKContainer, CKRecord, sincronizacion, SwiftData + CloudKit, conflict resolution, sharing | `cupertino search "CloudKit"` |
| L17 | 22 | Networking | URLSession avanzado, async/await networking, Codable, HTTP/2, background transfers, WebSockets | `cupertino search "URLSession"` |

**Proyecto practico**: App con persistencia local y sincronizacion cloud. **Inicia Proyecto Integrador (semana 20).**

---

### MODULO 05: HARDWARE Y SENSORES (Semanas 23-26)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L18 | 23-24 | HealthKit | HKHealthStore, tipos de datos, autorizacion, queries, statistics, workouts, background delivery | `cupertino search "HealthKit"` |
| L19 | 25 | Location y Maps | CoreLocation, MapKit, MapKit for SwiftUI, annotations, routes, geofencing, region monitoring | `cupertino search "MapKit SwiftUI"` |
| L20 | 26 | Camera y Photos | AVFoundation, PhotoKit, PHPickerViewController, camera capture, photo library, video recording | `cupertino search "AVFoundation camera"` |

---

### MODULO 06: IA Y ML (Semanas 27-30)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L21 | 27-28 | Foundation Models | SystemLanguageModel, on-device AI, prompts, streaming, tool calling, guardrails, @Generable | `cupertino search "Foundation Models"` |
| L22 | 29 | ImagePlayground | ImageCreator, generacion de imagenes, personalizacion, integracion con SwiftUI | `cupertino search "ImagePlayground"` |
| L23 | 30 | CoreML y Vision | CoreML models, Vision framework, image classification, object detection, text recognition, Create ML | `cupertino search "CoreML"` |

---

### MODULO 07: INTEGRACION CON EL SISTEMA (Semanas 31-34)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L24 | 31-32 | App Intents y Siri | AppIntents framework, App Shortcuts, Siri integration, parameterized intents, entities | `cupertino search "AppIntents"` |
| L25 | 33 | Widgets y Live Activities | WidgetKit, timeline provider, widget families, Live Activities, Dynamic Island, ActivityKit | `cupertino search "WidgetKit"` |
| L26 | 34 | Notificaciones | UserNotifications, push notifications (APNs), local notifications, notification actions, rich notifications | `cupertino search "UserNotifications"` |

---

### MODULO 08: PLATAFORMAS (Semanas 35-38)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L27 | 35-36 | watchOS | WatchKit, watchOS app architecture, complications, workout sessions, connectivity, HealthKit en Watch | `cupertino search "watchOS"` |
| L28 | 37 | visionOS | RealityKit, spatial computing, volumes, immersive spaces, entity component system, hand tracking | `cupertino search "visionOS"` |
| L29 | 38 | macOS e iPadOS | Mac Catalyst, iPad multitasking, keyboard shortcuts, menu bar, toolbar, multi-window | `cupertino search "macOS SwiftUI"` |

---

### MODULO 09: TESTING Y CALIDAD (Semanas 39-42)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L30 | 39-40 | XCTest | Unit testing, mocking, stubbing, test doubles, async testing, performance testing | `cupertino search "XCTest"` |
| L31 | 41 | Swift Testing | Framework moderno @Test, #expect, traits, parameterized tests, tags, parallel execution | `cupertino search "Swift Testing"` |
| L32 | 42 | UI Testing y SwiftLint | XCUITest, accessibility identifiers, page object pattern, SwiftLint, code quality, CI/CD | `cupertino search "UI testing Xcode"` |

---

### MODULO 10: SEGURIDAD Y PERFORMANCE (Semanas 43-44)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L33 | 43 | Seguridad | CryptoKit, Keychain Services, privacy manifests, secure coding, certificate pinning, biometrics | `cupertino search "CryptoKit"` |
| L34 | 44 | Performance | Instruments, Time Profiler, memory leaks, Allocations, view performance, launch time, binary size | `cupertino search "Instruments performance"` |

---

### MODULO 11: MONETIZACION Y DISTRIBUCION (Semanas 45-46)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L35 | 45 | StoreKit 2 | Products, purchases, subscriptions, Transaction, renewal info, StoreKit Testing, offer codes | `cupertino search "StoreKit 2"` |
| L36 | 46 | App Store y TestFlight | App Store Connect, TestFlight, signing, provisioning, review guidelines, metadata, screenshots | `cupertino search "App Store Connect"` |

---

### MODULO 12: EXTRAS Y ESPECIALIZACION (Semanas 47-48)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L37 | 47 | Server-Side Swift | Vapor framework, Swift on server, API development, deployment | `cupertino search "Server-side Swift"` |
| L38 | 47 | Metal y Graficos | Metal basics, shaders, SpriteKit, SceneKit, juegos 2D/3D | `cupertino search "Metal framework"` |
| L39 | 48 | Combine (Legacy Reference) | Publishers, subscribers, operators, integracion con SwiftUI (referencia, no uso primario) | `cupertino search "Combine framework"` |
| L40 | 48 | Open Source y Comunidad | Swift evolution, contribuir a open source, Swift Package Registry, technical writing | `cupertino search "Swift evolution"` |

---

## Proyecto Integrador

El Proyecto Integrador es una app completa que se construye incrementalmente desde la semana 20.

### Hitos

| Semana | Hito | Modulo Asociado |
|--------|------|-----------------|
| 20 | Definicion y setup del proyecto | Datos y Persistencia |
| 22 | Persistencia local con SwiftData | Datos y Persistencia |
| 26 | Integracion de sensores/hardware | Hardware y Sensores |
| 30 | Features de IA | IA y ML |
| 34 | Widgets y Siri | Integracion Sistema |
| 38 | Version multiplataforma | Plataformas |
| 42 | Suite de tests completa | Testing y Calidad |
| 44 | Optimizacion y seguridad | Seguridad y Performance |
| 46 | Publicacion en TestFlight | Monetizacion y Distribucion |
| 48 | Version final | Extras |

### Requisitos Minimos
- Usar SwiftData para persistencia
- Implementar al menos 2 plataformas (iOS + watchOS o visionOS)
- Incluir tests unitarios y de UI
- Integrar al menos un sensor o API de hardware
- Tener widget o App Intent
- Publicar en TestFlight

---

## Formato de Cada Leccion

Cada leccion sigue este formato estandarizado:

1. **Cupertino MCP** — Comandos para consultar documentacion oficial
2. **Teoria** — Conceptos con contexto real (WHY antes del HOW)
3. **Ejemplos de Codigo** — Archivos .swift ejecutables
4. **Ejercicio Basico** — Practica guiada
5. **Ejercicio Intermedio** — Aplicacion de conceptos
6. **Ejercicio Avanzado** — Desafio con multiples conceptos
7. **Recursos Adicionales** — Formadores y documentacion extra
8. **Checklist** — Objetivos verificables de la leccion
9. **Notas Personales** — Espacio para el estudiante
10. **Conexion con Proyecto Integrador** — Como aplica al proyecto final

---

## Reglas del Plan

1. **Cupertino es la fuente principal** — Toda documentacion se busca primero ahi
2. **Orden secuencial** — No saltar modulos fundamentales
3. **Practica obligatoria** — Minimo los ejercicios basico e intermedio por leccion
4. **Sin tecnologia legacy** — No DispatchQueue, no Combine (excepto referencia), no Core Data, no ObservableObject
5. **Proyecto Integrador** — Se trabaja en paralelo desde la semana 20
6. **Modulos son just-in-time** — Las lecciones de modulos futuros se completan conforme se avanza

---

*Plan creado: Febrero 2026*
*Fusion de: SwiftLearning (8 fases, 16-22 semanas) + AppleEcosystemPlan (15 modulos, 120 semanas)*
*Optimizado para: 48 semanas de aprendizaje enfocado*
