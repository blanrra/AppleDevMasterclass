# PLAN MAESTRO — AppleDevMasterclass: Guia Maestra Apple Developer

Curriculum completo desde iniciacion hasta experto en el ecosistema Apple. ~60 semanas, 14 modulos, 48 lecciones. Se adapta al nivel de cada estudiante.

---

## Datos del Plan

| Aspecto | Detalle |
|---------|---------|
| **Duracion** | ~60 semanas (flexible segun nivel de entrada) |
| **Modulos** | 14 (00-13) |
| **Lecciones** | 48 |
| **Horas/dia** | 1-2 horas |
| **Nivel** | Iniciacion → Intermedio → Avanzado → Experto |
| **Target** | iOS 26, iPadOS 26, watchOS 26, visionOS 26, macOS Tahoe 26 |
| **Xcode** | 26 (Swift 6.2) |
| **Fuente** | Cupertino MCP (documentacion oficial Apple) |
| **Origen** | Fusion de SwiftLearning + AppleEcosystemPlan, ampliado con track de iniciacion |

---

## Puntos de Entrada por Nivel

| Nivel | Perfil | Punto de Entrada | Semanas Estimadas |
|-------|--------|------------------|-------------------|
| 1 — Iniciacion | Nunca ha programado | Modulo 00, Leccion L01 | ~60 semanas |
| 2 — Principiante Swift | Programa en otro lenguaje | Modulo 00, Leccion L03+ | ~52 semanas |
| 3 — Intermedio | Conoce Swift y SwiftUI basico | Modulo 01+ | ~44 semanas |
| 4 — Avanzado | Dev iOS experimentado | Modulo 05+ | ~30 semanas |

> El profesor evalua el nivel al inicio y recomienda el punto de entrada. El estudiante puede ajustarlo en cualquier momento.

---

## Vista General

| Modulo | Nombre | Semanas | Lecciones | Temas Clave |
|--------|--------|---------|-----------|-------------|
| 00 | Fundamentos | 1-12 | L01-L10 | Programacion desde cero, Swift 6, POP, Genericos, Errores, Memoria, Concurrencia, Xcode, SwiftUI basico |
| 01 | Arquitectura | 13-14 | L11-L12 | MVVM, Clean Architecture, Inyeccion de dependencias |
| 02 | Diseno y UX | 15-16 | L13-L14 | HIG, Liquid Glass, SF Symbols, Accesibilidad |
| 03 | SwiftUI Avanzado | 17-22 | L15-L18 | Navegacion, Composicion, Listas, Animaciones |
| 04 | Datos y Persistencia | 23-26 | L19-L21 | SwiftData, CloudKit, Networking |
| 05 | Hardware y Sensores | 27-30 | L22-L24 | HealthKit, Location/Maps, Camera/Photos |
| 06 | IA y ML | 31-34 | L25-L27 | Foundation Models, ImagePlayground, CoreML/Vision |
| 07 | Integracion Sistema | 35-38 | L28-L30 | App Intents, Siri, Widgets, Live Activities, Notificaciones |
| 08 | Plataformas | 39-42 | L31-L33 | watchOS, visionOS, macOS, iPadOS |
| 09 | Testing y Calidad | 43-46 | L34-L36 | XCTest, Swift Testing, UI Testing, SwiftLint |
| 10 | Seguridad y Performance | 47-48 | L37-L38 | CryptoKit, Privacy Manifests, Instruments |
| 11 | Monetizacion y Distribucion | 49-50 | L39-L40 | StoreKit 2, App Store, TestFlight |
| 12 | Extras y Especializacion | 51-52 | L41-L44 | Server-Side Swift, Metal, Combine, Open Source |

---

## Detalle por Modulo

### MODULO 00: FUNDAMENTOS (Semanas 1-12)

El modulo mas extenso. Cubre desde los conceptos basicos de programacion hasta las bases solidas de Swift 6 y SwiftUI. Las lecciones L01-L04 son para nivel iniciacion; estudiantes con experiencia previa pueden comenzar en L03 o posterior.

#### Bloque A: Iniciacion (Semanas 1-4) — *Nivel 1*

> Para estudiantes sin experiencia previa en programacion. Si ya programas en otro lenguaje, puedes saltar al Bloque B.

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L01 | 1 | Tu Primer Programa en Swift | Que es programar, Playgrounds, variables (let/var), tipos basicos (Int, Double, String, Bool), print(), comentarios, operadores basicos | `cupertino search --source swift-book "the basics"` |
| L02 | 2 | Control de Flujo y Colecciones | if/else, switch, for-in, while, guard, Array, Dictionary, Set, optionals (introduccion), unwrapping basico | `cupertino search --source swift-book "control flow"` |
| L03 | 3 | Funciones y Closures | Funciones, parametros, valores de retorno, argument labels, closures, trailing closures, captura de valores, funciones de orden superior (map, filter, reduce) | `cupertino search --source swift-book "functions"` |
| L04 | 4 | Structs, Clases y Enums | Structs vs classes, propiedades, metodos, inicializadores, herencia, enums con associated values, value types vs reference types | `cupertino search --source swift-book "structures and classes"` |

**Proyecto practico**: App de calculadora en terminal que usa todos los conceptos basicos.

#### Bloque B: Swift Intermedio (Semanas 5-8) — *Nivel 2*

> Para estudiantes que ya programan pero son nuevos en Swift, o que completaron el Bloque A.

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L05 | 5 | Swift 6 Language | Type inference avanzado, optionals a fondo, pattern matching, closures avanzados, protocolos basicos, genericos basicos, error handling basico | `cupertino search --source swift-book "language guide"` |
| L06 | 5-6 | POP y Genericos Avanzados | Protocol extensions, protocol composition, associated types, conditional conformance, generics constraints, where clauses, opaque types (some/any) | `cupertino search "protocol oriented programming"` |
| L07 | 7 | Manejo de Errores y Memoria | Result type, typed throws, ARC, strong/weak/unowned, retain cycles, value vs reference semantics, copy-on-write | `cupertino search "automatic reference counting"` |
| L08 | 8 | Concurrencia Moderna | async/await, Task, TaskGroup, actors, @MainActor, Sendable, structured concurrency, AsyncSequence, AsyncStream, task cancellation | `cupertino search "swift concurrency"` |

**Proyecto practico**: Libreria de networking type-safe con async/await y manejo robusto de errores.

#### Bloque C: Herramientas y SwiftUI (Semanas 9-12) — *Todos los niveles*

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L09 | 9-10 | Xcode 26 | Configuracion de proyecto, debugging, breakpoints, Instruments basico, previews, simulador, schemes, SPM | `cupertino search --source updates "Xcode 26"` |
| L10 | 11-12 | SwiftUI Fundamentos | View protocol, @State, @Binding, @Observable, body, modifiers, stacks, controles basicos, listas simples, navegacion basica | `cupertino search "SwiftUI fundamentals"` |

**Proyecto practico**: Primera app SwiftUI — lista de tareas con persistencia basica.

---

### MODULO 01: ARQUITECTURA (Semanas 13-14)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L11 | 13 | MVVM en SwiftUI | Patron MVVM, separation of concerns, ViewModels con @Observable, bindings, estado local vs global | `cupertino search "MVVM SwiftUI"` |
| L12 | 14 | Clean Architecture y DI | Capas (Presentation/Domain/Data), repository pattern, inyeccion de dependencias, Environment-based injection, protocol abstractions | `cupertino search "dependency injection SwiftUI"` |

**Proyecto practico**: Refactorizar app anterior con Clean Architecture.

---

### MODULO 02: DISENO Y UX (Semanas 15-16)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L13 | 15 | HIG, Liquid Glass y SF Symbols | Human Interface Guidelines, Liquid Glass design system, SF Symbols 6, typography, color system, iconografia | `cupertino search --source hig "design"` |
| L14 | 16 | Accesibilidad | VoiceOver, Dynamic Type, accessibility modifiers, accessibility labels, accessibility traits, AX audit | `cupertino search "accessibility SwiftUI"` |

---

### MODULO 03: SWIFTUI AVANZADO (Semanas 17-22)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L15 | 17-18 | Navegacion Avanzada | NavigationStack, NavigationSplitView, NavigationPath, programmatic navigation, deep linking, coordinators | `cupertino search "NavigationStack"` |
| L16 | 19 | Composicion de Vistas | ViewBuilder, custom view modifiers, preference keys, GeometryReader, Layout protocol, custom containers | `cupertino search "ViewBuilder SwiftUI"` |
| L17 | 20 | Listas y Colecciones | List, LazyVStack, LazyVGrid, ForEach, Searchable, Section, Pull-to-refresh, pagination, performance | `cupertino search "List SwiftUI"` |
| L18 | 21-22 | Animaciones y Transiciones | Animation, withAnimation, matchedGeometryEffect, PhaseAnimator, KeyframeAnimator, custom transitions, Canvas, TimelineView | `cupertino search "animation SwiftUI"` |

**Proyecto practico**: App de seguimiento de habitos con navegacion compleja y animaciones.

---

### MODULO 04: DATOS Y PERSISTENCIA (Semanas 23-26)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L19 | 23-24 | SwiftData | @Model, ModelContainer, ModelContext, relaciones, migraciones, queries, predicados, sorting, @Query | `cupertino search "SwiftData"` |
| L20 | 25 | CloudKit | CKContainer, CKRecord, sincronizacion, SwiftData + CloudKit, conflict resolution, sharing | `cupertino search "CloudKit"` |
| L21 | 26 | Networking | URLSession avanzado, async/await networking, Codable, HTTP/2, background transfers, WebSockets | `cupertino search "URLSession"` |

**Proyecto practico**: App con persistencia local y sincronizacion cloud. **Inicia Proyecto Integrador (semana 24).**

---

### MODULO 05: HARDWARE Y SENSORES (Semanas 27-30)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L22 | 27-28 | HealthKit | HKHealthStore, tipos de datos, autorizacion, queries, statistics, workouts, background delivery | `cupertino search "HealthKit"` |
| L23 | 29 | Location y Maps | CoreLocation, MapKit, MapKit for SwiftUI, annotations, routes, geofencing, region monitoring | `cupertino search "MapKit SwiftUI"` |
| L24 | 30 | Camera y Photos | AVFoundation, PhotoKit, PHPickerViewController, camera capture, photo library, video recording | `cupertino search "AVFoundation camera"` |

---

### MODULO 06: IA Y ML (Semanas 31-34)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L25 | 31-32 | Foundation Models | SystemLanguageModel, on-device AI, prompts, streaming, tool calling, guardrails, @Generable | `cupertino search "Foundation Models"` |
| L26 | 33 | ImagePlayground | ImageCreator, generacion de imagenes, personalizacion, integracion con SwiftUI | `cupertino search "ImagePlayground"` |
| L27 | 34 | CoreML y Vision | CoreML models, Vision framework, image classification, object detection, text recognition, Create ML | `cupertino search "CoreML"` |

---

### MODULO 07: INTEGRACION CON EL SISTEMA (Semanas 35-38)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L28 | 35-36 | App Intents y Siri | AppIntents framework, App Shortcuts, Siri integration, parameterized intents, entities | `cupertino search "AppIntents"` |
| L29 | 37 | Widgets y Live Activities | WidgetKit, timeline provider, widget families, Live Activities, Dynamic Island, ActivityKit | `cupertino search "WidgetKit"` |
| L30 | 38 | Notificaciones | UserNotifications, push notifications (APNs), local notifications, notification actions, rich notifications | `cupertino search "UserNotifications"` |

---

### MODULO 08: PLATAFORMAS (Semanas 39-42)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L31 | 39-40 | watchOS | WatchKit, watchOS app architecture, complications, workout sessions, connectivity, HealthKit en Watch | `cupertino search "watchOS"` |
| L32 | 41 | visionOS | RealityKit, spatial computing, volumes, immersive spaces, entity component system, hand tracking | `cupertino search "visionOS"` |
| L33 | 42 | macOS e iPadOS | Mac Catalyst, iPad multitasking, keyboard shortcuts, menu bar, toolbar, multi-window | `cupertino search "macOS SwiftUI"` |

---

### MODULO 09: TESTING Y CALIDAD (Semanas 43-46)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L34 | 43-44 | XCTest | Unit testing, mocking, stubbing, test doubles, async testing, performance testing | `cupertino search "XCTest"` |
| L35 | 45 | Swift Testing | Framework moderno @Test, #expect, traits, parameterized tests, tags, parallel execution | `cupertino search "Swift Testing"` |
| L36 | 46 | UI Testing y SwiftLint | XCUITest, accessibility identifiers, page object pattern, SwiftLint, code quality, CI/CD | `cupertino search "UI testing Xcode"` |

---

### MODULO 10: SEGURIDAD Y PERFORMANCE (Semanas 47-48)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L37 | 47 | Seguridad | CryptoKit, Keychain Services, privacy manifests, secure coding, certificate pinning, biometrics | `cupertino search "CryptoKit"` |
| L38 | 48 | Performance | Instruments, Time Profiler, memory leaks, Allocations, view performance, launch time, binary size | `cupertino search "Instruments performance"` |

---

### MODULO 11: MONETIZACION Y DISTRIBUCION (Semanas 49-50)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L39 | 49 | StoreKit 2 | Products, purchases, subscriptions, Transaction, renewal info, StoreKit Testing, offer codes | `cupertino search "StoreKit 2"` |
| L40 | 50 | App Store y TestFlight | App Store Connect, TestFlight, signing, provisioning, review guidelines, metadata, screenshots | `cupertino search "App Store Connect"` |

---

### MODULO 12: EXTRAS Y ESPECIALIZACION (Semanas 51-52)

| Leccion | Semanas | Titulo | Temas | Cupertino MCP |
|---------|---------|--------|-------|---------------|
| L41 | 51 | Server-Side Swift | Vapor framework, Swift on server, API development, deployment | `cupertino search "Server-side Swift"` |
| L42 | 51 | Metal y Graficos | Metal basics, shaders, SpriteKit, SceneKit, juegos 2D/3D | `cupertino search "Metal framework"` |
| L43 | 52 | Combine (Legacy Reference) | Publishers, subscribers, operators, integracion con SwiftUI (referencia, no uso primario) | `cupertino search "Combine framework"` |
| L44 | 52 | Open Source y Comunidad | Swift evolution, contribuir a open source, Swift Package Registry, technical writing | `cupertino search "Swift evolution"` |

---

## Proyecto Integrador

El Proyecto Integrador es una app completa que se construye incrementalmente desde la semana 24.

### Hitos

| Semana | Hito | Modulo Asociado |
|--------|------|-----------------|
| 24 | Definicion y setup del proyecto | Datos y Persistencia |
| 26 | Persistencia local con SwiftData | Datos y Persistencia |
| 30 | Integracion de sensores/hardware | Hardware y Sensores |
| 34 | Features de IA | IA y ML |
| 38 | Widgets y Siri | Integracion Sistema |
| 42 | Version multiplataforma | Plataformas |
| 46 | Suite de tests completa | Testing y Calidad |
| 48 | Optimizacion y seguridad | Seguridad y Performance |
| 50 | Publicacion en TestFlight | Monetizacion y Distribucion |
| 52 | Version final | Extras |

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
5. **Proyecto Integrador** — Se trabaja en paralelo desde la semana 24
6. **Modulos son just-in-time** — Las lecciones de modulos futuros se completan conforme se avanza

---

*Plan creado: Febrero 2026 | Actualizado: Marzo 2026*
*Fusion de: SwiftLearning + AppleEcosystemPlan, ampliado con track de iniciacion*
*~60 semanas de aprendizaje flexible, adaptable a todos los niveles*
