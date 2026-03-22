# Leccion 21: Networking

**Modulo 04: Datos y Persistencia** | Semana 26

---

## TL;DR — Resumen en 2 minutos

- **URLSession + async/await**: La forma moderna de hacer llamadas HTTP — codigo limpio, sin callbacks
- **Codable**: Protocolo que convierte JSON a Swift y viceversa automaticamente con JSONEncoder/JSONDecoder
- **URLRequest**: Configurar metodo HTTP, headers, body y timeout para cada peticion
- **Error handling**: Las llamadas de red fallan por mil razones — siempre manejar errores de forma robusta
- **API Client type-safe**: Construir una capa de abstraccion que haga imposible enviar peticiones malformadas

---

## Cupertino MCP

```bash
cupertino search "URLSession"
cupertino search "URLSession async"
cupertino search "URLRequest"
cupertino search "Codable"
cupertino search "JSONDecoder"
cupertino search "URLSession WebSocket"
cupertino search "URLSessionDownloadTask"
cupertino search --source samples "networking"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC21 | [Use async/await with URLSession](https://developer.apple.com/videos/play/wwdc2021/10095/) | **Esencial** — API moderna |
| WWDC22 | [Reduce networking delays for a more responsive app](https://developer.apple.com/videos/play/wwdc2022/10078/) | Performance |
| WWDC23 | [Beyond the basics of structured concurrency](https://developer.apple.com/videos/play/wwdc2023/10170/) | Concurrencia en red |
| WWDC20 | [What's new in URLSession](https://developer.apple.com/videos/play/wwdc2020/10111/) | WebSocket y mas |
| WWDC18 | [A Tour of UICollectionView](https://developer.apple.com/videos/play/wwdc2018/225/) | Paginacion con red |
| :es: | [Julio Cesar Fernandez — Networking](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que URLSession con async/await?

Antes de async/await, las llamadas de red eran un laberinto de closures, delegados y colas. Un simple GET requeria manejar callbacks, decodificar en un hilo y actualizar la UI en otro. Con async/await, el flujo se lee de arriba a abajo, como si fuera sincrono.

URLSession es el framework nativo de Apple para networking. No necesitas Alamofire ni librerias externas — URLSession con async/await cubre el 95% de los casos.

```
  ┌──────────────────────────────────────────────────────────┐
  │               FLUJO DE UNA LLAMADA HTTP                  │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   1. Construir        2. Ejecutar       3. Decodificar   │
  │   URLRequest          con URLSession    con Codable      │
  │                                                          │
  │   ┌──────────┐       ┌──────────┐      ┌──────────┐     │
  │   │ URL      │       │ async    │      │ JSON     │     │
  │   │ Method   │──────▶│ let      │─────▶│ Decoder  │     │
  │   │ Headers  │       │ (data,   │      │          │     │
  │   │ Body     │       │ response)│      │ → Struct │     │
  │   └──────────┘       └──────────┘      └──────────┘     │
  │                           │                              │
  │                     ┌─────▼─────┐                        │
  │                     │  Validar  │                        │
  │                     │  Status   │                        │
  │                     │  Code     │                        │
  │                     └───────────┘                        │
  └──────────────────────────────────────────────────────────┘
```

### GET Basico con async/await

```swift
import Foundation

// MARK: - GET basico

struct Usuario: Codable, Identifiable {
    let id: Int
    let nombre: String
    let email: String
    let telefono: String

    enum CodingKeys: String, CodingKey {
        case id
        case nombre = "name"
        case email
        case telefono = "phone"
    }
}

func obtenerUsuarios() async throws -> [Usuario] {
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }

    let decoder = JSONDecoder()
    return try decoder.decode([Usuario].self, from: data)
}

// Uso
Task {
    do {
        let usuarios = try await obtenerUsuarios()
        for usuario in usuarios {
            print("\(usuario.nombre) — \(usuario.email)")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Codable a Fondo

`Codable` es la combinacion de `Encodable` y `Decodable`. Te permite convertir entre Swift y JSON (u otros formatos) sin escribir parsing manual.

```swift
import Foundation

// MARK: - Codable basico

struct Publicacion: Codable, Identifiable {
    let id: Int
    let titulo: String
    let cuerpo: String
    let idUsuario: Int

    enum CodingKeys: String, CodingKey {
        case id
        case titulo = "title"
        case cuerpo = "body"
        case idUsuario = "userId"
    }
}

// MARK: - Decodificacion con configuracion personalizada

struct Evento: Codable {
    let nombre: String
    let fecha: Date
    let asistentes: Int
}

// Configurar decoder para fechas ISO 8601
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase

// Configurar encoder
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
```

#### Decodificacion avanzada con init(from:)

```swift
import Foundation

// MARK: - Decodificacion manual para APIs complejas

struct RespuestaAPI: Decodable {
    let exito: Bool
    let datos: [Producto]
    let paginaActual: Int
    let totalPaginas: Int

    enum CodingKeys: String, CodingKey {
        case exito = "success"
        case datos = "data"
        case meta
    }

    enum MetaKeys: String, CodingKey {
        case paginaActual = "current_page"
        case totalPaginas = "total_pages"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        exito = try container.decode(Bool.self, forKey: .exito)
        datos = try container.decode([Producto].self, forKey: .datos)

        // JSON anidado: { "meta": { "current_page": 1, "total_pages": 5 } }
        let meta = try container.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta)
        paginaActual = try meta.decode(Int.self, forKey: .paginaActual)
        totalPaginas = try meta.decode(Int.self, forKey: .totalPaginas)
    }
}

struct Producto: Codable, Identifiable {
    let id: Int
    let nombre: String
    let precio: Double
}
```

### URLRequest — Configurar Peticiones

```swift
import Foundation

// MARK: - POST con URLRequest

func crearPublicacion(titulo: String, cuerpo: String) async throws -> Publicacion {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer tu-token-aqui", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 30

    let body = ["title": titulo, "body": cuerpo, "userId": "1"]
    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }

    return try JSONDecoder().decode(Publicacion.self, from: data)
}

// MARK: - PUT, PATCH, DELETE

func actualizarPublicacion(id: Int, titulo: String) async throws {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)")!
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(["title": titulo])

    let (_, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
}

func eliminarPublicacion(id: Int) async throws {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)")!
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    let (_, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}
```

### Manejo de Errores de Red

Las llamadas de red fallan constantemente: sin internet, timeout, servidor caido, JSON inesperado. Un buen manejo de errores es la diferencia entre una app profesional y una que crashea.

```swift
import Foundation

// MARK: - Errores tipados para networking

enum ErrorRed: LocalizedError {
    case sinConexion
    case timeout
    case servidorNoDisponible(codigo: Int)
    case datosInvalidos
    case decodificacionFallida(Error)
    case noAutorizado
    case limiteExcedido

    var errorDescription: String? {
        switch self {
        case .sinConexion:
            return "Sin conexion a internet. Verifica tu red."
        case .timeout:
            return "La peticion tardo demasiado. Intenta de nuevo."
        case .servidorNoDisponible(let codigo):
            return "Servidor no disponible (codigo: \(codigo))."
        case .datosInvalidos:
            return "Los datos recibidos no son validos."
        case .decodificacionFallida(let error):
            return "Error procesando respuesta: \(error.localizedDescription)"
        case .noAutorizado:
            return "Sesion expirada. Inicia sesion de nuevo."
        case .limiteExcedido:
            return "Demasiadas peticiones. Espera un momento."
        }
    }
}

// MARK: - Funcion con manejo robusto de errores

func peticionSegura<T: Decodable>(url: URL, tipo: T.Type) async throws -> T {
    let data: Data
    let response: URLResponse

    do {
        (data, response) = try await URLSession.shared.data(from: url)
    } catch let error as URLError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            throw ErrorRed.sinConexion
        case .timedOut:
            throw ErrorRed.timeout
        default:
            throw error
        }
    }

    guard let httpResponse = response as? HTTPURLResponse else {
        throw ErrorRed.datosInvalidos
    }

    switch httpResponse.statusCode {
    case 200...299:
        break  // OK
    case 401:
        throw ErrorRed.noAutorizado
    case 429:
        throw ErrorRed.limiteExcedido
    default:
        throw ErrorRed.servidorNoDisponible(codigo: httpResponse.statusCode)
    }

    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        throw ErrorRed.decodificacionFallida(error)
    }
}
```

### API Client Type-Safe

La capa mas profesional: un cliente que hace imposible cometer errores en las peticiones.

```swift
import Foundation

// MARK: - Endpoint type-safe

enum MetodoHTTP: String {
    case GET, POST, PUT, PATCH, DELETE
}

protocol Endpoint {
    associatedtype Respuesta: Decodable
    var ruta: String { get }
    var metodo: MetodoHTTP { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
    var parametrosQuery: [String: String] { get }
}

extension Endpoint {
    var headers: [String: String] { [:] }
    var body: Encodable? { nil }
    var parametrosQuery: [String: String] { [:] }
}

// MARK: - Endpoints concretos

enum UsuarioEndpoint {
    struct Listar: Endpoint {
        typealias Respuesta = [Usuario]
        let ruta = "/users"
        let metodo = MetodoHTTP.GET
    }

    struct Obtener: Endpoint {
        typealias Respuesta = Usuario
        let id: Int
        var ruta: String { "/users/\(id)" }
        let metodo = MetodoHTTP.GET
    }

    struct Crear: Endpoint {
        typealias Respuesta = Usuario
        let ruta = "/users"
        let metodo = MetodoHTTP.POST
        let body: Encodable?

        init(nombre: String, email: String) {
            self.body = ["name": nombre, "email": email]
        }
    }
}

// MARK: - Cliente API generico

actor ClienteAPI {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private var token: String?

    init(baseURL: String) {
        self.baseURL = URL(string: baseURL)!
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func configurarToken(_ token: String) {
        self.token = token
    }

    func ejecutar<E: Endpoint>(_ endpoint: E) async throws -> E.Respuesta {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.ruta),
            resolvingAgainstBaseURL: true
        )!

        if !endpoint.parametrosQuery.isEmpty {
            components.queryItems = endpoint.parametrosQuery.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.metodo.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        for (clave, valor) in endpoint.headers {
            request.setValue(valor, forHTTPHeaderField: clave)
        }

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let codigo = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw ErrorRed.servidorNoDisponible(codigo: codigo)
        }

        return try decoder.decode(E.Respuesta.self, from: data)
    }
}

// Helper para codificar tipos Encodable genericos
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
```

#### Uso del cliente type-safe

```swift
// MARK: - Uso del ClienteAPI

let cliente = ClienteAPI(baseURL: "https://jsonplaceholder.typicode.com")

Task {
    // Listar usuarios — el tipo de retorno se infiere del Endpoint
    let usuarios = try await cliente.ejecutar(UsuarioEndpoint.Listar())
    print("Usuarios: \(usuarios.count)")

    // Obtener un usuario por ID
    let usuario = try await cliente.ejecutar(UsuarioEndpoint.Obtener(id: 1))
    print("Usuario: \(usuario.nombre)")

    // Crear usuario
    let nuevo = try await cliente.ejecutar(
        UsuarioEndpoint.Crear(nombre: "Ana", email: "ana@ejemplo.com")
    )
    print("Creado: \(nuevo.nombre)")
}
```

### Descargas y Uploads

```swift
import Foundation

// MARK: - Descarga de archivos con progreso

func descargarArchivo(desde url: URL, a destino: URL) async throws {
    let (tempURL, response) = try await URLSession.shared.download(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }

    try FileManager.default.moveItem(at: tempURL, to: destino)
    print("Archivo guardado en: \(destino.path)")
}

// MARK: - Upload con progreso usando bytes

func subirArchivo(url: URL, datos: Data) async throws {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

    let (_, response) = try await URLSession.shared.upload(for: request, from: datos)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
}
```

### WebSockets — Comunicacion en Tiempo Real

```swift
import Foundation

// MARK: - WebSocket basico

actor GestorWebSocket {
    private var tarea: URLSessionWebSocketTask?
    private let session = URLSession.shared

    func conectar(a url: URL) {
        tarea = session.webSocketTask(with: url)
        tarea?.resume()
        escucharMensajes()
    }

    func enviar(texto: String) async throws {
        try await tarea?.send(.string(texto))
    }

    func enviar(datos: Data) async throws {
        try await tarea?.send(.data(datos))
    }

    private func escucharMensajes() {
        Task {
            guard let tarea else { return }
            do {
                while tarea.state == .running {
                    let mensaje = try await tarea.receive()
                    switch mensaje {
                    case .string(let texto):
                        print("Recibido texto: \(texto)")
                    case .data(let datos):
                        print("Recibido datos: \(datos.count) bytes")
                    @unknown default:
                        break
                    }
                }
            } catch {
                print("WebSocket error: \(error)")
            }
        }
    }

    func desconectar() async {
        tarea?.cancel(with: .normalClosure, reason: nil)
        tarea = nil
    }
}
```

---

## Ejercicio 1: Consumir una API REST (Basico)

**Objetivo**: Practicar URLSession con async/await y Codable.

**Requisitos**:
1. Consumir la API `https://jsonplaceholder.typicode.com/posts`
2. Modelo `Post` con Codable y CodingKeys para mapear nombres
3. Mostrar los posts en una vista SwiftUI con List
4. Manejar estado de carga (loading, loaded, error) con un enum

---

## Ejercicio 2: CRUD Completo con API Client (Intermedio)

**Objetivo**: Construir un cliente HTTP reutilizable.

**Requisitos**:
1. Crear un `ClienteAPI` actor con baseURL configurable
2. Implementar endpoints type-safe para GET, POST, PUT, DELETE
3. Enum `ErrorRed` con al menos 5 casos y mensajes descriptivos
4. Manejar codigos de estado HTTP (200, 401, 404, 429, 500)
5. Vista SwiftUI que permita crear, editar y eliminar posts

---

## Ejercicio 3: Galeria con Descargas y Cache (Avanzado)

**Objetivo**: Implementar descarga de imagenes con cache y paginacion.

**Requisitos**:
1. Consumir API de imagenes (ej: `https://jsonplaceholder.typicode.com/photos`)
2. Actor `CacheImagenes` que almacene imagenes descargadas en memoria y disco
3. Paginacion infinita: cargar 20 items, cargar mas al llegar al final
4. Mostrar progreso de descarga por imagen
5. Cancelar descargas pendientes al salir de la vista (cooperative cancellation)

---

## 5 Errores Comunes

### 1. No validar el status code HTTP

```swift
// MAL — asumir que si no hay error, todo esta bien
let (data, _) = try await URLSession.shared.data(from: url)
let resultado = try JSONDecoder().decode(Modelo.self, from: data)
// Un 404 devuelve data (HTML de error), no lanza excepcion

// BIEN — siempre validar el codigo de respuesta
let (data, response) = try await URLSession.shared.data(from: url)
guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode) else {
    throw ErrorRed.servidorNoDisponible(codigo:
        (response as? HTTPURLResponse)?.statusCode ?? -1)
}
```

### 2. Bloquear el main thread con networking

```swift
// MAL — llamar desde un contexto sincrono sin Task
func viewDidLoad() {
    let data = try! Data(contentsOf: url)  // Bloquea la UI
}

// BIEN — usar async/await correctamente
func cargarDatos() async {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        // Procesar data
    } catch {
        // Manejar error
    }
}
```

### 3. No manejar la cancelacion de tareas

```swift
// MAL — la tarea sigue corriendo aunque la vista desaparezca
.task {
    while true {
        datos = try? await cargarDatos()
        try? await Task.sleep(for: .seconds(30))
        // Nunca se cancela
    }
}

// BIEN — verificar cancelacion
.task {
    while !Task.isCancelled {
        datos = try? await cargarDatos()
        try? await Task.sleep(for: .seconds(30))
    }
    // .task cancela automaticamente al salir de la vista
}
```

### 4. Hardcodear URLs y tokens

```swift
// MAL — credenciales en el codigo
let token = "sk-abc123secreto"
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

// BIEN — usar configuracion segura
let token = KeychainManager.obtener(clave: "api_token")
// O usar Info.plist / xcconfig para URLs base
let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? ""
```

### 5. Decodificar sin CodingKeys cuando la API usa snake_case

```swift
// MAL — los nombres no coinciden y la decodificacion falla
struct Usuario: Codable {
    let firstName: String   // La API envia "first_name"
    let lastName: String    // La API envia "last_name"
}

// BIEN opcion A — CodingKeys
struct Usuario: Codable {
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

// BIEN opcion B — configurar el decoder
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
// Ahora firstName se mapea automaticamente a first_name
```

---

## Checklist

- [ ] Hacer GET con URLSession.shared.data(from:) y async/await
- [ ] Decodificar JSON con Codable y CodingKeys
- [ ] Configurar URLRequest para POST, PUT, DELETE
- [ ] Validar status codes HTTP correctamente
- [ ] Crear un enum de errores tipados para networking
- [ ] Construir un API Client type-safe con protocolo Endpoint
- [ ] Descargar archivos con URLSession.shared.download(from:)
- [ ] Entender WebSockets basicos con URLSessionWebSocketTask
- [ ] Manejar cancelacion cooperativa en llamadas de red
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Networking sera esencial en multiples areas de tu app:
- **API Client type-safe** como capa de servicio para todas las llamadas remotas
- **Codable** para todos los modelos que viajan por la red
- **Error handling robusto** para mostrar mensajes utiles al usuario
- **Cache de imagenes** para performance en listas con fotos
- **WebSockets** si tu app necesita datos en tiempo real (chat, tracking)
- **Background transfers** para descargas/uploads que continuen con la app cerrada

---

*Leccion 21 | Networking | Semana 26 | Modulo 04: Datos y Persistencia*
*Siguiente: Leccion 22 — Hardware y Sensores (Modulo 05)*
