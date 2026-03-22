# Leccion 05: Xcode 26

**Modulo 00: Fundamentos** | Semanas 9-10

---

## TL;DR — Resumen en 2 minutos

- **Xcode es tu taller completo**: editor, debugger, profiler, simulador y sistema de build en uno
- **Breakpoints + LLDB**: tu mejor amigo para encontrar bugs — aprende `po`, `p` y breakpoints condicionales
- **SwiftUI Previews**: ves los cambios en tiempo real sin compilar — usa `#Preview` con diferentes configs
- **SPM**: gestiona dependencias externas directamente desde Xcode — sin CocoaPods ni Carthage
- **Instruments**: cuando tu app va lenta, Instruments te dice exactamente donde esta el problema

> Esta leccion requiere **Xcode 26** instalado. Los niveles 1-2 pasan de Swift Playgrounds a Xcode aqui.

---

## Cupertino MCP

```bash
cupertino search --source updates "Xcode 26"
cupertino search "Xcode release notes"
cupertino search "Swift Package Manager"
cupertino search "Xcode debugging"
cupertino search "Instruments"
cupertino search "SwiftUI previews"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Xcode 26 | **Esencial** — Novedades Xcode 26 |
| WWDC23 | [Debug with Structured Logging](https://developer.apple.com/videos/play/wwdc2023/10226/) | Debugging moderno |
| WWDC19 | [Getting Started with Instruments](https://developer.apple.com/videos/play/wwdc2019/411/) | Instruments basico |
| EN | [Paul Solt — Xcode Tips](https://www.youtube.com/@taborplayer) | Productividad en Xcode |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Dedicar una Leccion a Xcode?

Xcode es mas que un editor de texto. Es un IDE completo con debugger, profiler, simulador, herramientas de diseno y sistema de build integrado. Dominar Xcode multiplica tu productividad — muchos desarrolladores con anos de experiencia solo usan el 20% de sus capacidades.

### Configuracion de Proyecto

#### Crear un Proyecto Nuevo
1. File > New > Project
2. Seleccionar plantilla (App, Framework, Package)
3. Configurar: nombre, bundle ID, team, target platforms
4. Seleccionar SwiftData si necesitas persistencia

#### Estructura del Proyecto
```
MiApp/
  MiApp.swift              # @main entry point
  ContentView.swift         # Vista principal
  Models/                   # Modelos de datos
  Views/                    # Vistas SwiftUI
  ViewModels/               # ViewModels
  Assets.xcassets/          # Recursos (imagenes, colores)
  Info.plist                # Configuracion de la app
  MiApp.entitlements        # Permisos (HealthKit, etc.)
```

#### Build Settings Importantes
- **Swift Language Version**: Swift 6
- **Strict Concurrency Checking**: Complete
- **Deployment Target**: iOS 26.0
- **Build Configuration**: Debug vs Release

### Debugging

#### Breakpoints
- **Line breakpoint**: Click en el numero de linea
- **Conditional breakpoint**: Right-click > Edit > agregar condicion
- **Symbolic breakpoint**: Debug > Breakpoints > Create Symbolic Breakpoint
- **Exception breakpoint**: Para capturar crashes automaticamente

#### LLDB Console
```
po variable          // Print Object — imprime el valor
p variable           // Print — imprime con tipo
expr variable = 42   // Modificar valor en runtime
bt                   // Backtrace — ver call stack
```

#### Mapa de Herramientas de Debugging

```
  ┌─────────────── DEBUGGING EN XCODE ──────────────────┐
  │                                                      │
  │  Breakpoints          LLDB Console    Memory Graph   │
  │  ┌────────────┐      ┌────────────┐  ┌───────────┐  │
  │  │ Line    🔴 │      │ po obj     │  │ Detectar  │  │
  │  │ Condition  │      │ p variable │  │ retain    │  │
  │  │ Symbolic   │      │ expr x=42  │  │ cycles    │  │
  │  │ Exception  │      │ bt (stack) │  │ visualmente│  │
  │  └────────────┘      └────────────┘  └───────────┘  │
  │                                                      │
  │  View Debugger        Instruments     Network        │
  │  ┌────────────┐      ┌────────────┐  ┌───────────┐  │
  │  │ Jerarquia  │      │ Time Prof  │  │ Trafico   │  │
  │  │ de vistas  │      │ Allocations│  │ HTTP      │  │
  │  │ 3D explode │      │ Leaks      │  │ Latencia  │  │
  │  └────────────┘      └────────────┘  └───────────┘  │
  └──────────────────────────────────────────────────────┘
```

#### Memory Graph Debugger
- Debug > Debug Memory Graph
- Detecta retain cycles visualmente
- Muestra todas las referencias a un objeto

### SwiftUI Previews

```swift
#Preview {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview("iPad") {
    ContentView()
        .previewDevice("iPad Pro 13-inch")
}

// Preview con datos de ejemplo
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}
```

### Swift Package Manager (SPM)

```swift
// Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiLibreria",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "MiLibreria", targets: ["MiLibreria"]),
    ],
    dependencies: [
        .package(url: "https://github.com/autor/paquete.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "MiLibreria", dependencies: []),
        .testTarget(name: "MiLibreriaTests", dependencies: ["MiLibreria"]),
    ]
)
```

#### Agregar Dependencias en Xcode
1. File > Add Package Dependencies
2. Pegar URL del repositorio
3. Seleccionar version rule (Up to Next Major)
4. Agregar a target

### Instruments (Introduccion)

Instruments es la herramienta de profiling de Apple. Se profundizara en Modulo 10.

- **Time Profiler**: Donde pasa tiempo tu app
- **Allocations**: Uso de memoria
- **Leaks**: Detectar memory leaks
- **Network**: Trafico de red
- **SwiftUI**: View body evaluations

Abrir: Product > Profile (Cmd+I)

### Simulador

- **Multiples dispositivos**: iPhone, iPad, Apple Watch, Vision Pro
- **Simular condiciones**: Ubicacion, notificaciones push, network throttling
- **Screenshots y grabacion**: Cmd+S para screenshot
- **Dark mode**: Settings > Developer > Dark Appearance

### Schemes y Configurations

- **Debug**: Optimizaciones desactivadas, asserts activos, simbolos de debug
- **Release**: Optimizaciones activadas, asserts eliminados, para distribucion
- **Custom schemes**: Para testing, staging, production

### Atajos de Teclado Esenciales

| Atajo | Accion |
|-------|--------|
| Cmd+B | Build |
| Cmd+R | Run |
| Cmd+U | Test |
| Cmd+I | Profile (Instruments) |
| Cmd+Shift+O | Open Quickly |
| Cmd+Shift+J | Reveal in Navigator |
| Cmd+Shift+K | Clean Build Folder |
| Ctrl+Cmd+R | Run without build |
| Cmd+0 | Toggle Navigator |
| Cmd+Option+0 | Toggle Inspector |

---

## Ejercicio 1: Setup de Proyecto (Basico)

**Objetivo**: Familiarizarse con Xcode creando un proyecto desde cero.

**Requisitos**:
1. Crear un nuevo proyecto iOS App con SwiftUI
2. Configurar: nombre, bundle ID, target iOS 26
3. Activar Strict Concurrency Checking (Complete)
4. Agregar un paquete SPM (ej: swift-collections)
5. Crear una preview con modo oscuro

---

## Ejercicio 2: Debugging Avanzado (Intermedio)

**Objetivo**: Practicar herramientas de debugging.

**Requisitos**:
1. Crear un bug intencional (crash, logic error, retain cycle)
2. Usar breakpoints condicionales para encontrar el bug
3. Usar Memory Graph Debugger para detectar el retain cycle
4. Usar LLDB console para inspeccionar variables en runtime

---

## Ejercicio 3: Proyecto Multi-Target (Avanzado)

**Objetivo**: Configurar un proyecto complejo.

**Requisitos**:
1. Crear proyecto con targets: iOS App, Widget Extension, Watch App
2. Compartir codigo entre targets con un framework local
3. Configurar schemes para Debug, Staging y Release
4. Agregar un SPM package y usarlo en multiples targets

---

## Recursos Adicionales

- **Cupertino**: `cupertino search --source updates "Xcode 26"`
- **Paul Solt**: Xcode basics y configuracion

---

## Checklist

- [ ] Crear un proyecto nuevo con configuracion correcta (iOS 26, Swift 6)
- [ ] Usar breakpoints (line, conditional, exception)
- [ ] Navegar con Open Quickly (Cmd+Shift+O)
- [ ] Usar LLDB console basico (po, p, bt)
- [ ] Crear SwiftUI Previews con diferentes configuraciones
- [ ] Agregar dependencias con SPM
- [ ] Usar Memory Graph Debugger
- [ ] Conocer Instruments basico (Time Profiler)
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Tu Proyecto Integrador sera un proyecto Xcode real:
- **Multi-target**: App principal + Widget + Watch App
- **SPM**: Para organizar codigo compartido
- **Instruments**: Para optimizar antes de publicar
- **Schemes**: Debug y Release correctamente configurados

---

*Leccion 05 (L09) | Xcode 26 | Semanas 9-10 | Modulo 00: Fundamentos*
*Siguiente: Leccion 06 (L10) — SwiftUI Fundamentos*
