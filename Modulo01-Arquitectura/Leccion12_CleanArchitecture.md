# Leccion 12: Clean Architecture y Dependency Injection

**Modulo 01: Arquitectura** | Semana 14

---

## TL;DR — Resumen en 2 minutos

- **Clean Architecture** separa en 3 capas: Presentation, Domain, Data
- **Repository Pattern** abstrae el origen de datos (red, local, cache)
- **DI con protocolos**: las dependencias se inyectan, no se crean internamente
- **@Environment** es el mecanismo natural de DI en SwiftUI
- **Testabilidad**: con DI puedes sustituir implementaciones reales por mocks

> Principio: cada capa solo conoce la capa inmediatamente inferior, nunca al reves.

---

## Cupertino MCP

```bash
cupertino search "SwiftUI Environment"
cupertino search "Swift protocols"
cupertino search "SwiftUI dependency injection"
cupertino search "Swift Testing mocks"
cupertino search --source apple-docs "Environment values"
cupertino search --source samples "Architecture"
cupertino search_conformances "Sendable"
cupertino search "protocol oriented programming"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC23 | [Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/) | @Observable + Environment |
| WWDC24 | [A Swift Tour: Explore Swift's features and design](https://developer.apple.com/videos/play/wwdc2024/10184/) | Protocolos y genericos |
| WWDC25 | What's New in Swift | Swift 6.2 y Sendable |
| EN | [Azamsharp — Clean Architecture Debate](https://www.youtube.com/@azamsharp) | Cuando SI y cuando NO aplicarla |
| EN | [pointfree.co — Dependencies](https://www.pointfree.co) | DI funcional avanzada |
| EN | [Essential Developer — Clean Architecture](https://www.youtube.com/@EssentialDeveloper) | Patrones profesionales iOS |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Antes de empezar: ¿Por que no hablamos de SOLID?

Si vienes del mundo Java o de entrevistas tecnicas, probablemente esperabas que este modulo empezara con los principios SOLID (Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion). Es importante entender por que no los usamos como marco principal en Swift.

SOLID nacio para la **Programacion Orientada a Objetos clasica**: herencia, jerarquias de clases, polimorfismo por subclases. Swift no es ese lenguaje. Desde WWDC 2015, Apple definio Swift como un lenguaje que **prioriza la orientacion a protocolos** (POP) sobre la orientacion a objetos.

¿Que significa esto en la practica?

- **Liskov Substitution** habla de jerarquias de herencia — pero en Swift usamos structs (que no heredan) y protocol conformances
- **Open/Closed** se logra con herencia en OOP — en Swift usamos `extension` y protocol extensions, sin jerarquias
- **Interface Segregation** pide interfaces pequenas — Swift ya lo hace por diseno: `Equatable`, `Hashable`, `Codable`, `Sendable` son protocolos minimos y combinables
- **Dependency Inversion** es el mas aplicable, pero en SwiftUI la inyeccion se hace con `@Environment`, no con contenedores DI al estilo Spring

Esto no significa que SOLID sea malo. Significa que **el contexto importa**: aplicar patrones de un paradigma a otro sin adaptarlos genera mas complejidad de la que resuelve.

Los principios que si guian la arquitectura Swift moderna son:

1. **Structs primero** — tipos de valor por defecto, clases solo cuando necesites referencia
2. **Propiedad clara del estado** — `@State`, `@Binding`, `@Observable`, `@Environment` definen quien es dueno de que
3. **Protocolos como abstraccion** — desacoplar con protocolos, no con herencia
4. **`final` por defecto** — las clases se cierran a herencia, favoreciendo static dispatch
5. **Seguridad en compilacion** — si compila sin warnings ni force unwraps, estas haciendo las cosas bien

> Lectura recomendada: [Julio Cesar Fernandez — "Si te piden principios SOLID en una oferta iOS, ¡huye!"](https://www.linkedin.com/pulse/si-te-piden-principios-solid-en-una-oferta-ios-huye-fern%C3%A1ndez-mu%C3%B1oz-f1vze/) — un analisis profundo de por que SOLID no encaja en Swift y una propuesta de principios nativos del lenguaje.

---

### Por que ir mas alla de MVVM?

MVVM (Leccion 11) separa la View del ViewModel, pero no dice nada sobre como organizar el acceso a datos, la logica de negocio reutilizable o como intercambiar la fuente de datos sin modificar el ViewModel.

En una app pequena, MVVM basta. Pero cuando tu app crece:

- **El ViewModel habla directamente con la red** — si cambias la API, reescribes ViewModels
- **No puedes testear sin red** — porque el ViewModel tiene URLSession hardcodeado
- **Logica duplicada** — dos ViewModels calculan lo mismo porque no hay capa compartida
- **Migrar de API a SwiftData** requiere tocar todos los ViewModels

Clean Architecture resuelve esto anadiendo capas de abstraccion con responsabilidades claras.

### Las 3 capas de Clean Architecture

```
┌─────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                     │
│   Views + ViewModels                                │
│   Solo UI y logica de presentacion.                 │
│   Depende de: Domain                                │
└───────────────────────┬─────────────────────────────┘
                        │ usa protocolos de Domain
┌───────────────────────▼─────────────────────────────┐
│                DOMAIN LAYER                         │
│   Modelos + Protocolos (Repository interfaces)      │
│   Logica de negocio pura. Sin dependencias externas.│
│   No depende de nada.                               │
└───────────────────────┬─────────────────────────────┘
                        │ implementa protocolos
┌───────────────────────▼─────────────────────────────┐
│                  DATA LAYER                         │
│   Implementaciones concretas de Repositories.       │
│   Networking, SwiftData, UserDefaults, Cache.       │
│   Depende de: Domain (para implementar protocolos)  │
└─────────────────────────────────────────────────────┘
```

**Regla de oro**: las dependencias apuntan hacia adentro. Presentation depende de Domain. Data depende de Domain. Domain no depende de nadie.

### Domain Layer: el corazon de la app

La capa de Domain contiene:

1. **Models**: structs puros que representan entidades del negocio
2. **Repository protocols**: contratos que definen que operaciones de datos existen
3. **Use Cases** (opcional): logica de negocio reutilizable entre ViewModels

```swift
// MARK: - Domain Layer

// Modelo puro — sin dependencias de frameworks
struct Producto: Identifiable, Sendable {
    let id: UUID
    var nombre: String
    var precio: Double
    var categoria: Categoria
    var disponible: Bool

    enum Categoria: String, CaseIterable, Sendable {
        case electronica, ropa, hogar, deportes
    }
}

// Protocolo del repositorio — contrato, no implementacion
protocol ProductoRepository: Sendable {
    func obtenerTodos() async throws -> [Producto]
    func obtenerPorCategoria(_ categoria: Producto.Categoria) async throws -> [Producto]
    func guardar(_ producto: Producto) async throws
    func eliminar(_ producto: Producto) async throws
    func buscar(texto: String) async throws -> [Producto]
}
```

El protocolo `ProductoRepository` define QUE operaciones existen, pero no dice COMO se implementan. Eso es responsabilidad de la Data Layer.

### Data Layer: las implementaciones

Cada protocolo del Domain puede tener multiples implementaciones:

```swift
// MARK: - Data Layer

// Implementacion que usa la API remota
final class RemoteProductoRepository: ProductoRepository {
    private let baseURL = URL(string: "https://api.mitienda.com")!

    func obtenerTodos() async throws -> [Producto] {
        let url = baseURL.appendingPathComponent("productos")
        let (data, _) = try await URLSession.shared.data(from: url)
        let dtos = try JSONDecoder().decode([ProductoDTO].self, from: data)
        return dtos.map { $0.toDomain() }
    }

    func obtenerPorCategoria(_ categoria: Producto.Categoria) async throws -> [Producto] {
        let todos = try await obtenerTodos()
        return todos.filter { $0.categoria == categoria }
    }

    func guardar(_ producto: Producto) async throws {
        // POST a la API...
    }

    func eliminar(_ producto: Producto) async throws {
        // DELETE a la API...
    }

    func buscar(texto: String) async throws -> [Producto] {
        let todos = try await obtenerTodos()
        return todos.filter { $0.nombre.localizedCaseInsensitiveContains(texto) }
    }
}

// Implementacion local para desarrollo y testing
final class LocalProductoRepository: ProductoRepository {
    private var productos: [Producto] = [
        Producto(id: UUID(), nombre: "iPhone 17", precio: 999, categoria: .electronica, disponible: true),
        Producto(id: UUID(), nombre: "MacBook Pro", precio: 2499, categoria: .electronica, disponible: true),
        Producto(id: UUID(), nombre: "Camiseta Apple", precio: 49, categoria: .ropa, disponible: false),
    ]

    func obtenerTodos() async throws -> [Producto] {
        try await Task.sleep(for: .milliseconds(500))  // Simular latencia
        return productos
    }

    func obtenerPorCategoria(_ categoria: Producto.Categoria) async throws -> [Producto] {
        try await Task.sleep(for: .milliseconds(300))
        return productos.filter { $0.categoria == categoria }
    }

    func guardar(_ producto: Producto) async throws {
        if let index = productos.firstIndex(where: { $0.id == producto.id }) {
            productos[index] = producto
        } else {
            productos.append(producto)
        }
    }

    func eliminar(_ producto: Producto) async throws {
        productos.removeAll { $0.id == producto.id }
    }

    func buscar(texto: String) async throws -> [Producto] {
        return productos.filter { $0.nombre.localizedCaseInsensitiveContains(texto) }
    }
}
```

**Punto clave**: ambas implementaciones cumplen el mismo protocolo. El ViewModel no sabe ni le importa cual esta usando.

### Repository Pattern en detalle

El Repository Pattern es el puente entre Domain y Data. Abstrae completamente el origen de los datos:

```swift
// El ViewModel trabaja con el protocolo, nunca con la implementacion
@Observable
class CatalogoViewModel {
    private let repository: ProductoRepository

    var productos: [Producto] = []
    var cargando = false
    var error: String?

    // El repositorio se inyecta — no se crea internamente
    init(repository: ProductoRepository) {
        self.repository = repository
    }

    func cargar() async {
        cargando = true
        error = nil

        do {
            productos = try await repository.obtenerTodos()
        } catch {
            self.error = "Error al cargar: \(error.localizedDescription)"
        }

        cargando = false
    }

    func filtrarPor(_ categoria: Producto.Categoria) async {
        cargando = true
        do {
            productos = try await repository.obtenerPorCategoria(categoria)
        } catch {
            self.error = error.localizedDescription
        }
        cargando = false
    }
}
```

Ahora el mismo ViewModel funciona con datos remotos, locales o mock — sin cambiar una sola linea.

### Dependency Injection con protocolos

DI significa que un objeto **recibe** sus dependencias en lugar de **crearlas** internamente.

```swift
// ❌ SIN DI — dependencia hardcodeada
@Observable
class UserViewModel {
    private let service = APIService()  // Crea su propia dependencia

    func cargar() async {
        // Solo puede usar APIService, imposible testear sin red
    }
}

// ✅ CON DI — dependencia inyectada via protocolo
@Observable
class UserViewModel {
    private let repository: UserRepository  // Depende de abstraccion

    init(repository: UserRepository) {       // Se inyecta desde fuera
        self.repository = repository
    }

    func cargar() async {
        // Funciona con cualquier implementacion de UserRepository
    }
}
```

**Tres formas de inyectar dependencias:**

```swift
// 1. Constructor injection (preferida)
let vm = UserViewModel(repository: RemoteUserRepository())

// 2. Environment injection en SwiftUI
ContentView()
    .environment(carritoVM)

// 3. Property injection (menos comun)
let vm = UserViewModel()
vm.repository = RemoteUserRepository()
```

### @Environment como sistema de DI en SwiftUI

SwiftUI tiene un sistema de DI incorporado con `@Environment`. Es la forma mas natural de inyectar dependencias en el arbol de vistas:

```swift
// MARK: - Configurar DI en el punto de entrada

@main
struct TiendaApp: App {
    // Decidir que implementaciones usar
    @State private var catalogoVM = CatalogoViewModel(
        repository: RemoteProductoRepository()  // Produccion: API real
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(catalogoVM)
        }
    }
}

// Para previews o testing, usar implementacion local:
#Preview {
    ContentView()
        .environment(
            CatalogoViewModel(repository: LocalProductoRepository())
        )
}
```

Tambien puedes crear **EnvironmentKeys** personalizados para inyectar repositorios directamente:

```swift
// Definir la clave de entorno
struct ProductoRepositoryKey: EnvironmentKey {
    static let defaultValue: ProductoRepository = LocalProductoRepository()
}

extension EnvironmentValues {
    var productoRepository: ProductoRepository {
        get { self[ProductoRepositoryKey.self] }
        set { self[ProductoRepositoryKey.self] = newValue }
    }
}

// Inyectar en la app
@main
struct TiendaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.productoRepository, RemoteProductoRepository())
        }
    }
}

// Consumir en cualquier vista
struct CatalogoView: View {
    @Environment(\.productoRepository) private var repository

    var body: some View {
        // Usar repository...
    }
}
```

### Testabilidad: el verdadero beneficio de DI

Con DI y protocolos, testear es trivial. Creas un mock que cumple el protocolo:

```swift
// Mock para testing
final class MockProductoRepository: ProductoRepository {
    var productosSimulados: [Producto] = []
    var debefallar = false

    func obtenerTodos() async throws -> [Producto] {
        if debefallar {
            throw URLError(.notConnectedToInternet)
        }
        return productosSimulados
    }

    func obtenerPorCategoria(_ categoria: Producto.Categoria) async throws -> [Producto] {
        return productosSimulados.filter { $0.categoria == categoria }
    }

    func guardar(_ producto: Producto) async throws {
        productosSimulados.append(producto)
    }

    func eliminar(_ producto: Producto) async throws {
        productosSimulados.removeAll { $0.id == producto.id }
    }

    func buscar(texto: String) async throws -> [Producto] {
        return productosSimulados.filter { $0.nombre.contains(texto) }
    }
}

// Test usando el mock
import Testing

@Test func catalogoViewModel_cargaProductos() async {
    // Arrange
    let mock = MockProductoRepository()
    mock.productosSimulados = [
        Producto(id: UUID(), nombre: "Test", precio: 10, categoria: .electronica, disponible: true)
    ]
    let vm = CatalogoViewModel(repository: mock)

    // Act
    await vm.cargar()

    // Assert
    #expect(vm.productos.count == 1)
    #expect(vm.productos.first?.nombre == "Test")
    #expect(vm.cargando == false)
    #expect(vm.error == nil)
}

@Test func catalogoViewModel_manejaErrores() async {
    let mock = MockProductoRepository()
    mock.debefallar = true
    let vm = CatalogoViewModel(repository: mock)

    await vm.cargar()

    #expect(vm.productos.isEmpty)
    #expect(vm.error != nil)
}
```

Sin DI, estos tests necesitarian red real, bases de datos reales y serian lentos y fragiles.

### Cuando Clean Architecture es overengineering

Clean Architecture no es gratis. Cada capa adicional agrega archivos, protocolos e indirecciones. Evalua si la necesitas:

| Situacion | Recomendacion |
|-----------|---------------|
| App con 2-3 pantallas simples | MVVM basico es suficiente |
| Prototipo o MVP | MVVM sin Repository |
| App con una sola fuente de datos | Repository opcional |
| App con API + cache + SwiftData | Repository necesario |
| App con equipo de 3+ devs | Clean Architecture recomendada |
| App que necesita tests extensivos | Clean Architecture necesaria |
| Proyecto personal de aprendizaje | Implementar para practicar, simplificar despues |

**Regla practica**: si no vas a tener multiples implementaciones de un repositorio ni vas a escribir tests unitarios, el Repository Pattern agrega complejidad sin beneficio claro.

### Estructura de archivos recomendada

```
MiApp/
├── Domain/
│   ├── Models/
│   │   ├── Producto.swift
│   │   ├── Usuario.swift
│   │   └── Pedido.swift
│   └── Repositories/
│       ├── ProductoRepository.swift      // Solo el protocol
│       ├── UsuarioRepository.swift
│       └── PedidoRepository.swift
├── Data/
│   ├── Remote/
│   │   ├── RemoteProductoRepository.swift
│   │   ├── RemoteUsuarioRepository.swift
│   │   └── APIClient.swift
│   ├── Local/
│   │   ├── LocalProductoRepository.swift  // SwiftData
│   │   └── LocalUsuarioRepository.swift
│   └── DTOs/
│       ├── ProductoDTO.swift             // Mapeo JSON -> Domain
│       └── UsuarioDTO.swift
├── Presentation/
│   ├── Catalogo/
│   │   ├── CatalogoView.swift
│   │   └── CatalogoViewModel.swift
│   ├── Perfil/
│   │   ├── PerfilView.swift
│   │   └── PerfilViewModel.swift
│   └── Carrito/
│       ├── CarritoView.swift
│       └── CarritoViewModel.swift
└── App/
    ├── TiendaApp.swift                   // Punto de entrada + DI
    └── DependencyContainer.swift         // Configuracion de DI
```

---

## Ejercicios

### Ejercicio 1 — Basico: Repository con dos implementaciones

Crea un sistema de notas con Repository Pattern:

**Domain:**
```swift
struct Nota: Identifiable, Sendable {
    let id: UUID
    var titulo: String
    var contenido: String
    let fechaCreacion: Date
    var fechaModificacion: Date
}

protocol NotaRepository: Sendable {
    func obtenerTodas() async throws -> [Nota]
    func guardar(_ nota: Nota) async throws
    func eliminar(_ nota: Nota) async throws
}
```

**Requisitos:**
- Implementar `InMemoryNotaRepository` (datos en array local)
- Implementar `UserDefaultsNotaRepository` (persistir en UserDefaults con Codable)
- Ambas deben cumplir el protocolo `NotaRepository`
- Crear un `NotasViewModel` que reciba el repositorio por constructor
- Verificar que el ViewModel funciona identicamente con ambas implementaciones

### Ejercicio 2 — Intermedio: App completa con Clean Architecture

Construye una app de gestion de contactos con las 3 capas:

**Domain:**
- Modelo `Contacto` con: nombre, telefono, email, grupo, esFavorito
- Protocolo `ContactoRepository` con CRUD completo + busqueda + filtro por grupo

**Data:**
- `LocalContactoRepository`: datos hardcodeados para desarrollo
- `PersistentContactoRepository`: usando un archivo JSON en el file system

**Presentation:**
- `ContactosListView` + `ContactosViewModel`: lista con busqueda y filtro
- `ContactoDetailView` + `ContactoDetailViewModel`: vista de detalle editable
- `ContactoFormView`: formulario para crear/editar (sheet)

**Requisitos adicionales:**
- DTOs separados de los modelos de Domain
- El ViewModel de detalle recibe solo el ID y carga del repositorio
- Validacion de email y telefono en el ViewModel (no en la View)

### Ejercicio 3 — Avanzado: Intercambiar fuentes de datos via Environment

Crea una app de clima que demuestre el poder de DI:

**Arquitectura:**
```
Domain/
  ├── ClimaInfo.swift          // Model
  └── ClimaRepository.swift    // Protocol

Data/
  ├── APIClimaRepository.swift     // Datos "reales" (simulados)
  ├── MockClimaRepository.swift    // Datos mock para previews
  └── OfflineClimaRepository.swift // Cache local

Presentation/
  ├── ClimaView.swift
  └── ClimaViewModel.swift
```

**Requisitos:**
- Definir `ClimaRepositoryKey` como `EnvironmentKey`
- Inyectar diferentes repositorios segun el contexto:
  - Produccion: `APIClimaRepository`
  - Previews: `MockClimaRepository`
  - Sin conexion: `OfflineClimaRepository`
- Un toggle en Settings que permita cambiar entre API y offline **en runtime**
- Tests unitarios usando `MockClimaRepository` que verifiquen:
  - Carga exitosa actualiza el estado
  - Error de red muestra mensaje apropiado
  - Cambio de ciudad recarga los datos

---

## Errores Comunes

### 1. Crear dependencias internamente en lugar de inyectarlas

```swift
// ❌ MAL — el ViewModel crea su propia dependencia
@Observable
class ProductoVM {
    private let repo = RemoteProductoRepository()  // Hardcodeado, imposible testear
}

// ✅ BIEN — la dependencia se inyecta
@Observable
class ProductoVM {
    private let repo: ProductoRepository  // Protocolo, no implementacion concreta

    init(repo: ProductoRepository) {
        self.repo = repo
    }
}
```

### 2. Domain Layer que depende de frameworks externos

```swift
// ❌ MAL — el modelo importa SwiftUI
import SwiftUI

struct Producto {
    var nombre: String
    var color: Color      // Dependencia de SwiftUI en Domain!
    var imagen: Image     // Domain no debe conocer SwiftUI
}

// ✅ BIEN — modelo puro sin dependencias de UI
struct Producto {
    var nombre: String
    var colorHex: String       // Dato puro
    var imagenNombre: String   // La View lo transforma a Image
}
```

### 3. Repository que expone detalles de implementacion

```swift
// ❌ MAL — el protocolo revela que usa URLSession
protocol ProductoRepository {
    func obtener(con request: URLRequest) async throws -> [Producto]
    func guardar(en context: ModelContext) throws   // Revela SwiftData
}

// ✅ BIEN — protocolo limpio, sin detalles de implementacion
protocol ProductoRepository {
    func obtenerTodos() async throws -> [Producto]
    func guardar(_ producto: Producto) async throws
}
```

### 4. Capas innecesarias en apps simples

```swift
// ❌ OVERENGINEERING — para una app de notas personal
Domain/
  Models/Nota.swift
  Repositories/NotaRepository.swift
  UseCases/CrearNotaUseCase.swift        // Innecesario
  UseCases/EliminarNotaUseCase.swift     // Solo llama al repo
  UseCases/ObtenerNotasUseCase.swift     // Solo llama al repo
Data/
  DataSources/LocalDataSource.swift      // Capa extra sin valor
  Repositories/NotaRepositoryImpl.swift
  Mappers/NotaMapper.swift              // Mapeo trivial

// ✅ PRAGMATICO — las capas que realmente necesitas
Domain/
  Nota.swift
  NotaRepository.swift
Data/
  LocalNotaRepository.swift
Presentation/
  NotasViewModel.swift
  NotasView.swift
```

### 5. No separar DTOs de modelos de Domain

```swift
// ❌ MAL — el modelo de Domain se acopla al formato JSON de la API
struct Producto: Codable, Identifiable {
    let product_id: Int      // Nombre del JSON, no de Swift
    let product_name: String // Si la API cambia, Domain se rompe
    let is_available: Bool
}

// ✅ BIEN — DTO separado con mapeo a Domain
// Data Layer
struct ProductoDTO: Codable {
    let product_id: Int
    let product_name: String
    let is_available: Bool

    func toDomain() -> Producto {
        Producto(
            id: UUID(),
            nombre: product_name,
            disponible: is_available
        )
    }
}

// Domain Layer — modelo limpio
struct Producto: Identifiable {
    let id: UUID
    var nombre: String
    var disponible: Bool
}
```

---

## Checklist de objetivos

- [ ] Entiendo las 3 capas de Clean Architecture y sus responsabilidades
- [ ] Se crear protocolos de Repository en la Domain Layer
- [ ] Puedo implementar multiples repositorios que cumplen el mismo protocolo
- [ ] Entiendo Dependency Injection y por que es importante para testabilidad
- [ ] Se usar @Environment para inyectar dependencias en SwiftUI
- [ ] Puedo crear EnvironmentKeys personalizados
- [ ] Distingo cuando Clean Architecture aporta valor vs cuando es overengineering
- [ ] Se separar DTOs de modelos de Domain
- [ ] Puedo escribir tests unitarios usando mocks inyectados
- [ ] Complete los 3 ejercicios progresivos

---

## Notas Personales

> Espacio para anotar dudas, descubrimientos o reflexiones durante la leccion.
>
> ---
>
>
>

---

## Conexion con Proyecto Integrador

El Proyecto Integrador usara Clean Architecture como estructura base:

- **Domain**: modelos puros (`Usuario`, `Producto`, `Pedido`) y protocolos de Repository
- **Data**: implementacion local (SwiftData) para desarrollo, remota para produccion
- **Presentation**: ViewModels inyectados con los repositorios correctos segun el contexto

**Decisiones arquitectonicas para el proyecto:**
1. Cada feature tiene su propio Repository protocol
2. `DependencyContainer` en el `@main App` configura todas las inyecciones
3. Previews usan repositorios mock con datos de ejemplo
4. Tests unitarios usan repositorios mock para verificar logica de negocio

> **Accion**: crea la estructura de carpetas (Domain/, Data/, Presentation/) para tu proyecto y define los protocolos de Repository para tus 2-3 entidades principales.

---

*Leccion 12 (L12) | Clean Architecture y DI | Semana 14 | Modulo 01*