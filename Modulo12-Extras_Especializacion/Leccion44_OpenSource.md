# Leccion 44: Open Source y Comunidad

**Modulo 12: Extras y Especializacion** | Semana 52

---

## TL;DR — Resumen en 2 minutos

- **Swift es open source** desde 2015 — el lenguaje, el compilador y la libreria estandar estan en GitHub
- **Swift Evolution** es el proceso formal para proponer cambios al lenguaje — cualquiera puede participar
- **Contribuir a OSS** es la mejor forma de crecer como desarrollador — encuentras issues, envias PRs, recibes code review de expertos
- **Swift Package Registry** permite publicar tus paquetes para que otros los usen — tu codigo beneficia a la comunidad
- **Technical writing** (blogs, documentacion, charlas) te hace visible y consolida tu conocimiento

> Herramienta: **GitHub CLI** (`gh`) para gestionar issues, PRs y releases desde la terminal

---

## Cupertino MCP

```bash
cupertino search "Swift evolution"
cupertino search "Swift Package Manager"
cupertino search "Swift Package Registry"
cupertino search --source swift-book "Swift language"
cupertino search "open source Swift"
cupertino search --source updates "Swift 6"
cupertino search "contributing Swift"
cupertino search "Swift forums"
cupertino search "DocC documentation"
cupertino search "Swift Package plugins"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Swift | Ultimas propuestas aceptadas |
| WWDC24 | [A Swift Tour: Explore Swift's features and design](https://developer.apple.com/videos/play/wwdc2024/) | Filosofia del lenguaje |
| WWDC23 | [Expand on Swift macros](https://developer.apple.com/videos/play/wwdc2023/) | Ejemplo de feature nacida de Swift Evolution |
| EN | [Swift.org — Contributing](https://swift.org/contributing/) | **Esencial** — guia oficial |
| EN | [John Sundell — Swift by Sundell](https://www.swiftbysundell.com) | Ejemplo de technical writing |
| EN | [Point-Free](https://www.pointfree.co) | OSS de alta calidad (swift-composable-architecture) |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Open Source Importa

Aprender a programar en aislamiento tiene un techo. Puedes leer libros y ver videos, pero en algun momento necesitas exponerte al codigo de otros desarrolladores y recibir feedback sobre el tuyo. Open source es esa puerta. No se trata de contribuir a un proyecto enorme desde el dia uno — se trata de leer codigo real, entender decisiones de diseno y eventualmente aportar. Cada PR que envias es una mini-entrevista tecnica con feedback gratuito. Cada issue que resuelves es un problema real que afecta a usuarios reales.

Para desarrolladores Apple, el open source tiene un beneficio adicional: Swift mismo es open source. Puedes leer la implementacion de `Array`, entender como funcionan los macros, y hasta proponer cambios al lenguaje.

### Swift.org y el Ecosistema Open Source

```
  ┌──────────────────────────────────────────────────────────┐
  │              ECOSISTEMA SWIFT OPEN SOURCE                 │
  │                                                           │
  │  CORE:                                                    │
  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
  │  │  swift       │  │  swift-      │  │  swift-      │  │
  │  │  (compiler)  │  │  corelibs    │  │  package-    │  │
  │  │              │  │  (Foundation)│  │  manager     │  │
  │  └──────────────┘  └──────────────┘  └──────────────┘  │
  │                                                           │
  │  SERVIDOR:                                                │
  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
  │  │  Vapor       │  │  swift-nio   │  │  swift-log   │  │
  │  │  (web fw)    │  │  (networking)│  │  (logging)   │  │
  │  └──────────────┘  └──────────────┘  └──────────────┘  │
  │                                                           │
  │  COMUNIDAD:                                               │
  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
  │  │  Alamofire   │  │  Kingfisher  │  │  swift-      │  │
  │  │  (HTTP)      │  │  (imagenes)  │  │  composable  │  │
  │  └──────────────┘  └──────────────┘  └──────────────┘  │
  │                                                           │
  │  GOVERNANCE:                                              │
  │  Swift Forums → Swift Evolution → Core Team → Release     │
  └──────────────────────────────────────────────────────────┘
```

### Swift Evolution — Como Cambia el Lenguaje

Swift Evolution es el proceso democratico por el cual se proponen, discuten y aceptan cambios al lenguaje. Cada feature de Swift que usas — `async/await`, `@Observable`, macros — empezo como una propuesta escrita por alguien de la comunidad.

```swift
// MARK: - Ejemplo: Leer una propuesta de Swift Evolution

// Las propuestas viven en github.com/swiftlang/swift-evolution
// Cada una tiene un formato estandar:

/*
 SE-0401: Ejemplo de Propuesta

 ## Introduccion
 Descripcion breve del cambio propuesto.

 ## Motivacion
 POR QUE este cambio es necesario. Que problema resuelve.
 Ejemplos de codigo que muestran el problema actual.

 ## Solucion Propuesta
 COMO se resuelve. Sintaxis propuesta.
 Ejemplos de codigo con la nueva funcionalidad.

 ## Diseno Detallado
 Especificacion completa de la implementacion.

 ## Impacto en Codigo Existente
 Que se rompe y como se migra.

 ## Alternativas Consideradas
 Otras soluciones que se evaluaron y por que se descartaron.
*/

// MARK: - Propuestas importantes recientes

// SE-0395: Observation (reemplazo de Combine para UI)
// Motivo: @Published y ObservableObject eran ineficientes
// Resultado: @Observable macro

import Observation

@Observable
class MiModelo {
    var nombre: String = ""      // automaticamente observable
    var edad: Int = 0            // SwiftUI solo re-renderiza lo necesario
}

// SE-0392: Custom Actor Executors
// Motivo: Necesidad de controlar en que hilo corre un actor
// Resultado: actor con executor personalizado

// SE-0382: Expression Macros
// Motivo: Reducir boilerplate con generacion de codigo en compilacion
// Resultado: #stringify, @Observable, etc.
```

### Contribuir a Open Source — Guia Practica

```swift
// MARK: - Pasos para tu primera contribucion

/*
 PASO 1: Encontrar un proyecto
 ================================
 Busca proyectos que uses en tus apps. Si usas Alamofire,
 Kingfisher o cualquier otro paquete, ya conoces su API.

 Buenos indicadores de un proyecto saludable:
 - Issues etiquetados como "good first issue" o "help wanted"
 - README con guia de contribucion (CONTRIBUTING.md)
 - CI/CD configurado (GitHub Actions)
 - Maintainers activos que responden issues
 - Codigo de conducta
*/

// PASO 2: Configurar el entorno
// Fork → Clone → Branch → Commit → Push → PR

/*
 # Terminal — flujo de contribucion

 # 1. Fork en GitHub (boton en la web)

 # 2. Clonar tu fork
 gh repo clone tu-usuario/nombre-repo

 # 3. Agregar upstream (repo original)
 git remote add upstream https://github.com/original/nombre-repo.git

 # 4. Crear branch descriptivo
 git checkout -b fix/corregir-crash-lista-vacia

 # 5. Hacer cambios, tests, commit
 git add .
 git commit -m "Fix crash when list is empty"

 # 6. Push a tu fork
 git push origin fix/corregir-crash-lista-vacia

 # 7. Crear PR
 gh pr create --title "Fix crash when list is empty" \
              --body "Fixes #123. Added nil check before accessing first element."
*/

// PASO 3: Escribir un buen PR
/*
 Titulo: Accion concisa en imperativo
   BIEN: "Fix crash when list is empty"
   BIEN: "Add support for async image loading"
   MAL:  "Fixed some stuff"
   MAL:  "Update file.swift"

 Cuerpo:
   - QUE cambiaste y POR QUE
   - Issue que resuelve (Fixes #123)
   - Screenshots si es visual
   - Como probar el cambio
*/

// PASO 4: Responder al code review
/*
 - Agradece el feedback, incluso si es critico
 - No tomes los comentarios como personales
 - Responde a cada comentario, incluso si es "Done"
 - Si no estas de acuerdo, explica tu razonamiento
 - Los maintainers conocen mejor su codebase — aprende de ellos
*/
```

### Crear y Publicar un Swift Package

```swift
// MARK: - Crear un Swift Package desde cero

/*
 # Terminal — crear el paquete

 mkdir MiPaqueteSwift
 cd MiPaqueteSwift
 swift package init --type library

 # Estructura generada:
 # MiPaqueteSwift/
 # ├── Package.swift
 # ├── Sources/
 # │   └── MiPaqueteSwift/
 # │       └── MiPaqueteSwift.swift
 # └── Tests/
 #     └── MiPaqueteSwiftTests/
 #         └── MiPaqueteSwiftTests.swift
*/

// Package.swift — configuracion del paquete
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ValidadorFormularios",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ValidadorFormularios",
            targets: ["ValidadorFormularios"]
        ),
    ],
    dependencies: [
        // Dependencias externas si las necesitas
    ],
    targets: [
        .target(
            name: "ValidadorFormularios",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6) // strict concurrency
            ]
        ),
        .testTarget(
            name: "ValidadorFormulariosTests",
            dependencies: ["ValidadorFormularios"]
        ),
    ]
)
```

```swift
// Sources/ValidadorFormularios/Validador.swift
// MARK: - Ejemplo de libreria publicable

/// Validador de formularios con reglas componibles
public struct Validador<Value: Sendable>: Sendable {
    public let validar: @Sendable (Value) -> ResultadoValidacion

    public init(_ validar: @escaping @Sendable (Value) -> ResultadoValidacion) {
        self.validar = validar
    }
}

/// Resultado de una validacion
public enum ResultadoValidacion: Sendable, Equatable {
    case valido
    case invalido(String)

    public var esValido: Bool {
        if case .valido = self { return true }
        return false
    }

    public var mensaje: String? {
        if case .invalido(let msg) = self { return msg }
        return nil
    }
}

// MARK: - Validadores predefinidos para String
extension Validador where Value == String {
    /// Valida que el string no este vacio
    public static var noVacio: Validador {
        Validador { valor in
            valor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? .invalido("El campo no puede estar vacio")
                : .valido
        }
    }

    /// Valida longitud minima
    public static func longitudMinima(_ minimo: Int) -> Validador {
        Validador { valor in
            valor.count >= minimo
                ? .valido
                : .invalido("Minimo \(minimo) caracteres (tienes \(valor.count))")
        }
    }

    /// Valida formato de email
    public static var email: Validador {
        Validador { valor in
            let patron = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let regex = try? Regex(patron)
            return valor.wholeMatch(of: regex!) != nil
                ? .valido
                : .invalido("Formato de email invalido")
        }
    }
}

// MARK: - Composicion de validadores
extension Validador {
    /// Combina dos validadores — ambos deben pasar
    public func y(_ otro: Validador) -> Validador {
        Validador { valor in
            let resultado1 = self.validar(valor)
            guard resultado1.esValido else { return resultado1 }
            return otro.validar(valor)
        }
    }
}

// MARK: - Uso
/*
 let validadorNombre = Validador<String>.noVacio
     .y(.longitudMinima(2))

 let validadorEmail = Validador<String>.noVacio
     .y(.email)

 print(validadorNombre.validar(""))        // invalido("El campo no puede estar vacio")
 print(validadorNombre.validar("A"))       // invalido("Minimo 2 caracteres (tienes 1)")
 print(validadorNombre.validar("Ana"))     // valido
 print(validadorEmail.validar("test@a.c")) // invalido("Formato de email invalido")
 print(validadorEmail.validar("a@b.com"))  // valido
*/
```

### Documentacion con DocC

```swift
// MARK: - Documentar tu paquete con DocC

/// Un validador componible para formularios.
///
/// `Validador` permite crear reglas de validacion que se pueden
/// combinar para crear validaciones complejas a partir de piezas simples.
///
/// ## Ejemplo de uso
///
/// ```swift
/// let validador = Validador<String>.noVacio
///     .y(.longitudMinima(3))
///     .y(.email)
///
/// switch validador.validar("test@example.com") {
/// case .valido:
///     print("Email correcto")
/// case .invalido(let mensaje):
///     print("Error: \(mensaje)")
/// }
/// ```
///
/// ## Temas
///
/// ### Crear Validadores
/// - ``noVacio``
/// - ``longitudMinima(_:)``
/// - ``email``
///
/// ### Componer Validadores
/// - ``y(_:)``
public struct ValidadorDocumentado<Value: Sendable>: Sendable {
    // implementacion...
    public let validar: @Sendable (Value) -> ResultadoValidacion
}

/*
 # Generar documentacion DocC

 # Desde la raiz del paquete:
 swift package generate-documentation

 # Previsualizar en navegador:
 swift package --disable-sandbox preview-documentation --target ValidadorFormularios

 # Exportar como archivo .doccarchive:
 swift package generate-documentation --output-path docs
*/
```

### Publicar tu Paquete

```
  ┌──────────────────────────────────────────────────────────┐
  │           PUBLICAR UN SWIFT PACKAGE                       │
  │                                                           │
  │  1. PREPARAR                                              │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  - README.md claro con ejemplos                     │ │
  │  │  - LICENSE (MIT es la mas comun)                    │ │
  │  │  - Tests con buena cobertura                        │ │
  │  │  - CI con GitHub Actions                            │ │
  │  │  - Documentacion DocC                               │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                                                           │
  │  2. VERSIONAR (Semantic Versioning)                       │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  MAJOR.MINOR.PATCH                                  │ │
  │  │  1.0.0 → primera version estable                    │ │
  │  │  1.1.0 → nueva funcionalidad (backward compatible)  │ │
  │  │  1.1.1 → bug fix                                    │ │
  │  │  2.0.0 → breaking change                            │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                                                           │
  │  3. PUBLICAR                                              │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  git tag 1.0.0                                      │ │
  │  │  git push origin 1.0.0                              │ │
  │  │  gh release create 1.0.0 --notes "Initial release"  │ │
  │  │                                                      │ │
  │  │  # Los usuarios agregan en Package.swift:           │ │
  │  │  .package(url: "https://github.com/...", from: "1.0.0") │
  │  └─────────────────────────────────────────────────────┘ │
  └──────────────────────────────────────────────────────────┘
```

### Technical Writing — Hacerte Visible

```swift
// MARK: - Estructura de un buen articulo tecnico

/*
 1. TITULO CLARO Y ESPECIFICO
    BIEN: "Como migrar de ObservableObject a @Observable en 5 pasos"
    MAL:  "Cosas sobre SwiftUI"

 2. EL PROBLEMA
    Describe el dolor que resuelves.
    "Si tienes un codebase con 50 ViewModels usando @Published..."

 3. LA SOLUCION
    Codigo ejecutable, no pseudocodigo.
    Cada bloque de codigo debe compilar.

 4. EXPLICACION DEL POR QUE
    No solo el COMO sino el POR QUE funciona.
    "SwiftUI con @Observable solo re-renderiza las vistas que leen
    la propiedad que cambio, a diferencia de @Published que
    invalida todo el body."

 5. ERRORES COMUNES
    Lo que va a salir mal y como solucionarlo.

 6. CONCLUSION
    Resumen y siguiente paso.

 DONDE PUBLICAR:
 - Blog personal (Jekyll, Hugo, o Swift Publish)
 - Medium / dev.to / Hashnode
 - Swift Forums (forums.swift.org)
 - Twitter/X/Mastodon — hilos tecnicos
 - YouTube — screencasts
 - Conferencias — NSSpain, SwiftConf, try! Swift
*/
```

### Comunidad y Recursos

```swift
// MARK: - Recursos de la comunidad Swift

/*
 FOROS Y COMUNICACION:
 =====================
 - forums.swift.org → Foro oficial de Swift
 - iOS Dev Weekly → Newsletter semanal curada
 - Swift Weekly Brief → Resumen de Swift Evolution
 - r/swift, r/iOSprogramming → Reddit
 - Discord: Swift (servidor oficial), iOS Developers
 - Mastodon: iosdev.space

 CONFERENCIAS:
 =============
 - WWDC (Apple) → Junio cada ano
 - try! Swift → Tokyo, NYC
 - NSSpain → Espana
 - SwiftConf → Europa
 - iOSDevUK → Reino Unido
 - Appdevcon → Amsterdam
 - Swift Heroes → Italia

 OPEN SOURCE DESTACADO:
 ======================
 - swift-composable-architecture (Point-Free) → Arquitectura
 - Alamofire → Networking
 - Kingfisher → Imagenes
 - SnapKit → Auto Layout
 - SwiftLint → Linting
 - swift-argument-parser (Apple) → CLI tools
 - swift-collections (Apple) → Estructuras de datos
 - swift-algorithms (Apple) → Algoritmos

 NEWSLETTERS:
 ============
 - iOS Dev Weekly (Dave Verwer)
 - Swift Weekly Brief
 - SwiftLee Weekly (Antoine van der Lee)
 - Hacking with Swift (Paul Hudson)

 PODCASTS:
 =========
 - Swift by Sundell
 - Stacktrace
 - Under the Radar
 - Swift Unwrapped
*/
```

---

## Ejercicio 1: Leer y Analizar una Propuesta de Swift Evolution (Basico)

**Objetivo**: Entender el proceso de Swift Evolution leyendo una propuesta real.

**Requisitos**:
1. Ir a github.com/swiftlang/swift-evolution y elegir una propuesta aceptada reciente (SE-0380+)
2. Leer la propuesta completa y escribir un resumen de 200 palabras en espanol
3. Identificar: el problema que resuelve, la solucion propuesta, y el impacto en codigo existente
4. Crear un archivo Swift ejecutable que demuestre la funcionalidad de la propuesta
5. Escribir tu opinion: crees que fue una buena decision? por que?
6. Buscar en los Swift Forums la discusion original y anotar los argumentos a favor y en contra

---

## Ejercicio 2: Crear y Publicar un Swift Package (Intermedio)

**Objetivo**: Crear un Swift Package reutilizable y publicarlo en GitHub.

**Requisitos**:
1. Crear un paquete con `swift package init --type library`
2. Implementar al menos 3 funcionalidades utiles y relacionadas (ej: utilidades de String, validadores, formatters)
3. Escribir tests unitarios con Swift Testing con al menos 80% de cobertura
4. Agregar documentacion DocC con ejemplos en cada funcion publica
5. Configurar GitHub Actions para CI (tests en cada PR)
6. Crear tags con semantic versioning (0.1.0 inicial)
7. Publicar en GitHub y agregar un README con instrucciones de instalacion

---

## Ejercicio 3: Contribuir a un Proyecto Open Source (Avanzado)

**Objetivo**: Hacer tu primera contribucion real a un proyecto open source Swift.

**Requisitos**:
1. Elegir un proyecto que uses (o uno de Apple como swift-collections, swift-algorithms)
2. Encontrar un issue etiquetado como "good first issue" o "help wanted"
3. Fork del repositorio y configurar el entorno de desarrollo local
4. Implementar la solucion siguiendo las guias de contribucion del proyecto
5. Escribir tests para tu cambio
6. Crear un PR con titulo descriptivo y cuerpo detallado
7. Responder al feedback del code review y hacer los ajustes necesarios

---

## 5 Errores Comunes

### 1. No leer CONTRIBUTING.md antes de enviar un PR
```
# MAL — enviar un PR sin leer las guias
# Resultado: PR rechazado por no seguir convenciones

# BIEN — siempre leer primero:
# - CONTRIBUTING.md (como contribuir)
# - CODE_OF_CONDUCT.md (reglas de comportamiento)
# - README.md (como configurar el proyecto)
# - Issues existentes (alguien ya lo esta haciendo?)
```

### 2. PRs demasiado grandes
```
# MAL — un PR con 50 archivos y 2000 lineas
# Ningun maintainer va a revisar esto

# BIEN — PRs pequenos y enfocados
# Un PR = un cambio logico
# Si el cambio es grande, dividirlo en PRs secuenciales:
# PR 1: Agregar modelo
# PR 2: Agregar tests del modelo
# PR 3: Agregar vista que usa el modelo
```

### 3. No seguir semantic versioning al publicar
```swift
// MAL — version 1.0.0 para algo experimental
// Los usuarios asumen estabilidad con 1.0.0

// BIEN — empezar con 0.x.x hasta que la API sea estable
// 0.1.0 → primer release, API puede cambiar
// 0.2.0 → cambios de API
// 1.0.0 → API estable, promesa de backward compatibility
```

### 4. Publicar un paquete sin tests
```swift
// MAL — paquete sin tests
// "Funciona en mi maquina" no es suficiente

// BIEN — tests que verifican el comportamiento publico
import Testing
@testable import MiPaquete

@Test("Validar email correcto")
func emailValido() {
    let resultado = Validador<String>.email.validar("test@example.com")
    #expect(resultado == .valido)
}

@Test("Validar email incorrecto")
func emailInvalido() {
    let resultado = Validador<String>.email.validar("no-es-email")
    #expect(!resultado.esValido)
}
```

### 5. No mantener tu paquete despues de publicarlo
```
# MAL — publicar y olvidar
# Issues sin responder, PRs ignorados, dependencias desactualizadas

# BIEN — comprometerte a mantener
# - Responder issues en 48 horas (aunque sea "lo revisare")
# - Revisar PRs semanalmente
# - Actualizar dependencias cuando salgan nuevas versiones de Swift
# - Si ya no puedes mantenerlo, buscar un nuevo maintainer
# - Marcar como "archived" si decides abandonarlo
```

---

## Checklist

- [ ] Entender la estructura de Swift.org y el proceso de Swift Evolution
- [ ] Leer al menos una propuesta de Swift Evolution completa
- [ ] Configurar el flujo Fork → Clone → Branch → PR para contribuciones
- [ ] Crear un Swift Package desde cero con `swift package init`
- [ ] Escribir documentacion DocC para funciones publicas
- [ ] Configurar CI con GitHub Actions para tests automaticos
- [ ] Publicar un paquete en GitHub con semantic versioning
- [ ] Conocer los recursos principales de la comunidad Swift
- [ ] Tener un plan para tu primera contribucion open source
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Open source y comunidad son el cierre perfecto del Proyecto Integrador:
- **Publicar componentes** del proyecto como Swift Packages independientes — validadores, utilidades, UI components
- **Documentacion DocC** profesional que demuestra tu capacidad de comunicar codigo
- **GitHub Actions** para CI/CD automatizado — tests en cada commit, build verificado
- **Semantic versioning** para gestionar releases del proyecto de forma profesional
- **README y CONTRIBUTING** que permitan a otros desarrolladores entender y contribuir a tu proyecto
- **Portfolio publico** que demuestra no solo lo que sabes, sino como lo comunicas
- **Blog post** sobre lo que aprendiste construyendo el proyecto — consolida conocimiento y te hace visible

---

*Leccion 44 | Open Source y Comunidad | Semana 52 | Modulo 12: Extras y Especializacion*
*Final del curriculum — Felicidades por completar las 48 semanas!*
