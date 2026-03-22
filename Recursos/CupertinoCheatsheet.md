# Cupertino MCP — Cheatsheet de Comandos

Referencia rapida de todos los comandos de Cupertino MCP organizados por tarea.

---

## Busqueda General

```bash
# Busqueda por texto
cupertino search "SwiftUI View"

# Busqueda con limite de resultados
cupertino search "NavigationStack" --limit 5
```

---

## Busqueda por Fuente

```bash
# Documentacion oficial de Apple
cupertino search --source apple-docs "SwiftData"

# Libro oficial de Swift
cupertino search --source swift-book "closures"

# Human Interface Guidelines
cupertino search --source hig "typography"

# Samples de codigo
cupertino search --source samples "SwiftData"

# Release notes y actualizaciones
cupertino search --source updates "iOS 26"
```

---

## Lectura de Documentacion

```bash
# Leer articulo/documento especifico
cupertino read "swiftui-view"
cupertino read "swiftdata-model"

# Leer release notes
cupertino read "ios-26-release-notes"
```

---

## Samples de Codigo

```bash
# Listar todos los samples disponibles
cupertino list-samples

# Filtrar samples por nombre
cupertino list-samples | grep -i "swiftdata"

# Leer un sample especifico
cupertino read-sample "backyard-birds"
cupertino read-sample "food-truck"
```

---

## Frameworks

```bash
# Listar todos los frameworks
cupertino list-frameworks

# Filtrar por plataforma
cupertino list-frameworks --platform ios
cupertino list-frameworks --platform watchos
cupertino list-frameworks --platform visionos
cupertino list-frameworks --platform macos
```

---

## Busqueda por Plataforma

```bash
# Filtrar por version minima de plataforma
cupertino search "HealthKit" --min-ios 26.0
cupertino search "WatchKit" --min-watchos 26.0
cupertino search "RealityKit" --min-visionos 26.0
cupertino search "AppKit" --min-macos 26.0
```

---

## Busqueda Avanzada de Simbolos

```bash
# Buscar simbolos (funciones, tipos, etc.)
cupertino search_symbols "Task"
cupertino search_symbols "NavigationStack"

# Buscar property wrappers
cupertino search_property_wrappers "State"
cupertino search_property_wrappers "Observable"
cupertino search_property_wrappers "Query"

# Buscar conformances de protocolos
cupertino search_conformances "Sendable"
cupertino search_conformances "Codable"
cupertino search_conformances "Hashable"
```

---

## Por Modulo del Curriculum

### Modulo 00: Fundamentos
```bash
cupertino search --source swift-book "language guide"
cupertino search "protocol oriented programming"
cupertino search "automatic reference counting"
cupertino search "swift concurrency"
cupertino search --source updates "Xcode 26"
cupertino search "SwiftUI fundamentals"
```

### Modulo 01: Arquitectura
```bash
cupertino search "MVVM SwiftUI"
cupertino search "dependency injection SwiftUI"
```

### Modulo 02: Diseno y UX
```bash
cupertino search --source hig "design"
cupertino search "liquid-glass"
cupertino search "SF Symbols"
cupertino search "accessibility SwiftUI"
```

### Modulo 03: SwiftUI Avanzado
```bash
cupertino search "NavigationStack"
cupertino search "NavigationSplitView"
cupertino search "ViewBuilder SwiftUI"
cupertino search "List SwiftUI"
cupertino search "animation SwiftUI"
cupertino search "matchedGeometryEffect"
```

### Modulo 04: Datos y Persistencia
```bash
cupertino search "SwiftData"
cupertino search "@Model"
cupertino search "CloudKit"
cupertino search "URLSession"
```

### Modulo 05: Hardware y Sensores
```bash
cupertino search "HealthKit"
cupertino search "MapKit SwiftUI"
cupertino search "Core Location"
cupertino search "AVFoundation camera"
```

### Modulo 06: IA y ML
```bash
cupertino search "Foundation Models"
cupertino search "SystemLanguageModel"
cupertino search "ImagePlayground"
cupertino search "CoreML"
cupertino search "Vision framework"
```

### Modulo 07: Integracion Sistema
```bash
cupertino search "AppIntents"
cupertino search "App Shortcuts"
cupertino search "WidgetKit"
cupertino search "LiveActivities"
cupertino search "UserNotifications"
```

### Modulo 08: Plataformas
```bash
cupertino search "watchOS"
cupertino search "visionOS"
cupertino search "RealityKit"
cupertino search "macOS SwiftUI"
```

### Modulo 09: Testing y Calidad
```bash
cupertino search "XCTest"
cupertino search "Swift Testing"
cupertino search "UI testing Xcode"
```

### Modulo 10: Seguridad y Performance
```bash
cupertino search "CryptoKit"
cupertino search "Privacy Manifests"
cupertino search "Instruments performance"
```

### Modulo 11: Monetizacion y Distribucion
```bash
cupertino search "StoreKit 2"
cupertino search "App Store Connect"
cupertino search "TestFlight"
```

### Modulo 12: Extras
```bash
cupertino search "Server-side Swift"
cupertino search "Metal framework"
cupertino search "Combine framework"
cupertino search "Swift evolution"
```

---

*Referencia: Cupertino MCP v2026*
