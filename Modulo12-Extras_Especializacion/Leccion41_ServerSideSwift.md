# Leccion 41: Server-Side Swift con Vapor

**Modulo 12: Extras y Especializacion** | Semana 51

---

## TL;DR — Resumen en 2 minutos

- **Vapor** es el framework mas popular para Swift en servidor — mismo lenguaje en frontend y backend
- **Routes** definen endpoints HTTP — `app.get("api", "users")` mapea a `GET /api/users`
- **Content protocol** extiende Codable para HTTP — convierte structs a JSON automaticamente
- **Fluent** es el ORM de Vapor — modelos Swift que mapean a tablas SQL sin escribir queries
- **Compartir codigo** entre iOS y servidor es la mayor ventaja — mismos modelos, validaciones y logica

> Herramienta: **Vapor Toolbox** (`brew install vapor`) para crear y gestionar proyectos

---

## Cupertino MCP

```bash
cupertino search "Server-side Swift"
cupertino search "Swift Package Manager"
cupertino search --source swift-book "concurrency"
cupertino search "Codable"
cupertino search "URLSession"
cupertino search --source updates "Swift 6"
cupertino search "Sendable"
cupertino search "async await"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Swift | Novedades relevantes para servidor |
| WWDC24 | [Explore Swift performance](https://developer.apple.com/videos/play/wwdc2024/) | Performance en servidor |
| EN | [Vapor Official — Getting Started](https://docs.vapor.codes) | **Esencial** — documentacion oficial |
| EN | [Paul Hudson — Server-Side Swift](https://www.hackingwithswift.com/articles/server-side-swift) | Introduccion practica |
| EN | [Mikaela Caron — Vapor](https://www.youtube.com/@miabordin) | Tutoriales paso a paso |
| EN | [Tim Condon — Vapor](https://www.youtube.com/@0xTim) | Contribuidor principal de Vapor |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Swift en el Servidor?

Imagina que tienes una app iOS con modelos Codable perfectamente definidos. Tu backend en Node.js o Python tiene sus propios modelos que *deberian* ser iguales pero inevitablemente divergen. Un dia alguien cambia un campo en el backend y tu app crashea. Con Server-Side Swift, compartes literalmente el mismo archivo de modelos. Un cambio en el struct `Usuario` se refleja en ambos lados. Ademas, si ya dominas Swift, no necesitas aprender otro lenguaje para tu backend.

Swift en el servidor ofrece: type safety end-to-end, performance comparable a Go/Rust, async/await nativo y un ecosistema creciente.

### Configuracion de un Proyecto Vapor

```swift
// Package.swift — Configuracion del proyecto Vapor
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MiAPISwift",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.11.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", target: "vapor"),
                .product(name: "Fluent", target: "fluent"),
                .product(name: "FluentSQLiteDriver", target: "fluent-sqlite-driver"),
            ]
        ),
    ]
)
```

### Routing — Definir Endpoints

Los routes son el corazon de cualquier API. Cada route mapea un metodo HTTP + path a una funcion Swift.

```swift
import Vapor

// MARK: - Configuracion de Routes
func routes(_ app: Application) throws {
    // GET /
    app.get { req in
        return "Bienvenido a MiAPI v1.0"
    }

    // GET /api/saludo/:nombre
    app.get("api", "saludo", ":nombre") { req -> String in
        guard let nombre = req.parameters.get("nombre") else {
            throw Abort(.badRequest, reason: "Nombre requerido")
        }
        return "Hola, \(nombre)!"
    }

    // Agrupar routes con prefijo
    let api = app.grouped("api", "v1")

    // GET /api/v1/status
    api.get("status") { req -> EstadoAPI in
        return EstadoAPI(
            version: "1.0",
            estado: "operativo",
            timestamp: Date()
        )
    }

    // Registrar controladores
    try api.register(collection: UsuarioController())
    try api.register(collection: TareaController())
}

// MARK: - Modelo de respuesta
struct EstadoAPI: Content {
    let version: String
    let estado: String
    let timestamp: Date
}
```

### Content Protocol — Codable para HTTP

Content es la extension de Vapor sobre Codable. Cualquier struct que conforme `Content` puede enviarse como JSON automaticamente.

```swift
import Vapor
import Fluent

// MARK: - Modelos Compartidos (iOS + Server)
// Este archivo puede vivir en un Swift Package compartido

struct CrearUsuarioRequest: Content, Validatable {
    let nombre: String
    let email: String
    let edad: Int?

    // Validaciones del lado servidor
    static func validations(_ validations: inout Validations) {
        validations.add("nombre", as: String.self,
                       is: .count(2...50))
        validations.add("email", as: String.self,
                       is: .email)
        validations.add("edad", as: Int?.self,
                       is: .nil || .range(13...120),
                       required: false)
    }
}

struct UsuarioResponse: Content {
    let id: UUID
    let nombre: String
    let email: String
    let creadoEn: Date
}

// MARK: - Controlador CRUD completo
struct UsuarioController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usuarios = routes.grouped("usuarios")

        usuarios.get(use: listar)           // GET /api/v1/usuarios
        usuarios.post(use: crear)           // POST /api/v1/usuarios
        usuarios.get(":id", use: obtener)   // GET /api/v1/usuarios/:id
        usuarios.put(":id", use: actualizar) // PUT /api/v1/usuarios/:id
        usuarios.delete(":id", use: eliminar) // DELETE /api/v1/usuarios/:id
    }

    // Listar todos los usuarios
    func listar(req: Request) async throws -> [UsuarioResponse] {
        let usuarios = try await UsuarioModel.query(on: req.db).all()
        return usuarios.map { $0.toResponse() }
    }

    // Crear usuario
    func crear(req: Request) async throws -> UsuarioResponse {
        try CrearUsuarioRequest.validate(content: req)
        let input = try req.content.decode(CrearUsuarioRequest.self)

        let usuario = UsuarioModel(
            nombre: input.nombre,
            email: input.email
        )
        try await usuario.save(on: req.db)
        return usuario.toResponse()
    }

    // Obtener usuario por ID
    func obtener(req: Request) async throws -> UsuarioResponse {
        guard let usuario = try await UsuarioModel.find(
            req.parameters.get("id"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }
        return usuario.toResponse()
    }

    // Actualizar usuario
    func actualizar(req: Request) async throws -> UsuarioResponse {
        guard let usuario = try await UsuarioModel.find(
            req.parameters.get("id"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }

        let input = try req.content.decode(CrearUsuarioRequest.self)
        usuario.nombre = input.nombre
        usuario.email = input.email
        try await usuario.save(on: req.db)
        return usuario.toResponse()
    }

    // Eliminar usuario
    func eliminar(req: Request) async throws -> HTTPStatus {
        guard let usuario = try await UsuarioModel.find(
            req.parameters.get("id"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }
        try await usuario.delete(on: req.db)
        return .noContent
    }
}
```

### Fluent ORM — Base de Datos sin SQL

Fluent mapea tus modelos Swift a tablas en la base de datos. Soporta PostgreSQL, MySQL, SQLite y MongoDB.

```swift
import Fluent
import Vapor

// MARK: - Modelo Fluent
final class UsuarioModel: Model, @unchecked Sendable {
    static let schema = "usuarios"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "nombre")
    var nombre: String

    @Field(key: "email")
    var email: String

    @Timestamp(key: "creado_en", on: .create)
    var creadoEn: Date?

    @Timestamp(key: "actualizado_en", on: .update)
    var actualizadoEn: Date?

    // Relacion: un usuario tiene muchas tareas
    @Children(for: \.$usuario)
    var tareas: [TareaModel]

    init() {}

    init(nombre: String, email: String) {
        self.nombre = nombre
        self.email = email
    }

    func toResponse() -> UsuarioResponse {
        UsuarioResponse(
            id: id ?? UUID(),
            nombre: nombre,
            email: email,
            creadoEn: creadoEn ?? Date()
        )
    }
}

// MARK: - Migracion (crear tabla)
struct CrearTablaUsuarios: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("usuarios")
            .id()
            .field("nombre", .string, .required)
            .field("email", .string, .required)
            .field("creado_en", .datetime)
            .field("actualizado_en", .datetime)
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("usuarios").delete()
    }
}

// MARK: - Modelo con Relacion
final class TareaModel: Model, @unchecked Sendable {
    static let schema = "tareas"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "titulo")
    var titulo: String

    @Field(key: "completada")
    var completada: Bool

    @Parent(key: "usuario_id")
    var usuario: UsuarioModel

    init() {}
}
```

### Middleware — Interceptar Requests

```swift
import Vapor

// MARK: - Middleware Custom
struct LogMiddleware: AsyncMiddleware {
    func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        let inicio = Date()
        request.logger.info("\(request.method) \(request.url.path)")

        let response = try await next.respond(to: request)

        let duracion = Date().timeIntervalSince(inicio)
        request.logger.info(
            "\(request.method) \(request.url.path) -> \(response.status.code) [\(String(format: "%.2f", duracion * 1000))ms]"
        )
        return response
    }
}

// MARK: - Middleware de autenticacion basica
struct APIKeyMiddleware: AsyncMiddleware {
    let claveValida: String

    func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard let apiKey = request.headers.first(name: "X-API-Key"),
              apiKey == claveValida else {
            throw Abort(.unauthorized, reason: "API Key invalida")
        }
        return try await next.respond(to: request)
    }
}
```

### Compartir Codigo entre iOS y Servidor

```swift
// SharedModels/Sources/SharedModels/Modelos.swift
// Este Swift Package se usa en AMBOS targets

import Foundation

// MARK: - Modelos compartidos iOS + Server
public struct Tarea: Codable, Identifiable, Sendable {
    public let id: UUID
    public var titulo: String
    public var completada: Bool
    public var prioridad: Prioridad
    public var fechaLimite: Date?

    public init(
        id: UUID = UUID(),
        titulo: String,
        completada: Bool = false,
        prioridad: Prioridad = .media,
        fechaLimite: Date? = nil
    ) {
        self.id = id
        self.titulo = titulo
        self.completada = completada
        self.prioridad = prioridad
        self.fechaLimite = fechaLimite
    }
}

public enum Prioridad: String, Codable, Sendable, CaseIterable {
    case baja, media, alta, urgente
}

// MARK: - Cliente API para iOS
// Usa los mismos modelos que el servidor
public actor APIClient {
    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }

    public func obtenerTareas() async throws -> [Tarea] {
        let url = baseURL.appendingPathComponent("api/v1/tareas")
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([Tarea].self, from: data)
    }

    public func crearTarea(_ tarea: Tarea) async throws -> Tarea {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/v1/tareas"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(tarea)

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Tarea.self, from: data)
    }
}
```

### Deployment — Docker y Servicios Cloud

```dockerfile
# Dockerfile para Vapor
FROM swift:6.0-jammy as build
WORKDIR /app
COPY . .
RUN swift build -c release

FROM swift:6.0-jammy-slim
WORKDIR /app
COPY --from=build /app/.build/release/App .
EXPOSE 8080
ENTRYPOINT ["./App", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
```

```swift
// configure.swift — Configuracion del servidor
import Vapor
import Fluent
import FluentSQLiteDriver

func configure(_ app: Application) async throws {
    // Base de datos
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Migraciones
    app.migrations.add(CrearTablaUsuarios())

    // Middleware global
    app.middleware.use(LogMiddleware())

    // CORS para desarrollo
    let corsConfig = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE],
        allowedHeaders: [.accept, .authorization, .contentType]
    )
    app.middleware.use(CORSMiddleware(configuration: corsConfig))

    // Ejecutar migraciones
    try await app.autoMigrate()

    // Routes
    try routes(app)
}
```

---

## Ejercicio 1: API REST Basica con Vapor (Basico)

**Objetivo**: Crear un servidor Vapor que sirva una API REST simple de notas.

**Requisitos**:
1. Crear un proyecto Vapor con `vapor new MiNotas --no-fluent`
2. Definir un struct `Nota: Content` con id, titulo, contenido y fecha
3. Implementar routes: GET /api/notas (listar), POST /api/notas (crear), GET /api/notas/:id (detalle)
4. Almacenar las notas en memoria (array en el Application)
5. Devolver errores apropiados con `Abort(.notFound)` si la nota no existe
6. Probar con `curl` o una herramienta como HTTPie/Postman

---

## Ejercicio 2: CRUD Completo con Fluent y SQLite (Intermedio)

**Objetivo**: Crear una API con persistencia real usando Fluent ORM.

**Requisitos**:
1. Agregar Fluent y FluentSQLiteDriver al proyecto
2. Crear un modelo `Proyecto` con: id, nombre, descripcion, activo (Bool), creadoEn
3. Crear la migracion correspondiente con validaciones (nombre unico)
4. Implementar CRUD completo: listar, crear, obtener, actualizar, eliminar
5. Agregar un endpoint GET /api/proyectos/activos que filtre solo los activos
6. Implementar paginacion con `PageRequest` en el listado
7. Agregar middleware de logging que registre cada request

---

## Ejercicio 3: Modelos Compartidos iOS + Servidor (Avanzado)

**Objetivo**: Crear un Swift Package con modelos compartidos entre una app iOS y un servidor Vapor.

**Requisitos**:
1. Crear un Swift Package `SharedModels` con structs para `Tarea` y `Categoria`
2. El package debe compilar tanto para iOS como para Linux/macOS
3. En el servidor: usar los modelos para routes y respuestas
4. En iOS: crear un `APIClient` actor que consuma la API usando los mismos modelos
5. Implementar validaciones compartidas (longitud de titulo, formato de email)
6. Crear un Dockerfile multi-stage que compile y ejecute el servidor
7. Demostrar que un cambio en el modelo compartido se refleja en ambos lados

---

## 5 Errores Comunes

### 1. No usar async/await en los handlers
```swift
// MAL — bloquear el event loop con operaciones sincronas
app.get("datos") { req -> String in
    let datos = cargarDatosSincrono() // BLOQUEA el hilo
    return datos
}

// BIEN — siempre usar async
app.get("datos") { req async throws -> String in
    let datos = try await cargarDatosAsync()
    return datos
}
```

### 2. Exponer modelos de base de datos directamente
```swift
// MAL — el modelo Fluent tiene campos internos que no quieres exponer
app.get("usuarios") { req async throws -> [UsuarioModel] in
    return try await UsuarioModel.query(on: req.db).all()
    // expone timestamps internos, relaciones, etc
}

// BIEN — usar DTOs (Data Transfer Objects)
app.get("usuarios") { req async throws -> [UsuarioResponse] in
    let usuarios = try await UsuarioModel.query(on: req.db).all()
    return usuarios.map { $0.toResponse() } // solo campos publicos
}
```

### 3. No validar input del cliente
```swift
// MAL — confiar en el input del cliente
app.post("usuarios") { req async throws -> UsuarioResponse in
    let input = try req.content.decode(CrearUsuarioRequest.self)
    // guardar directamente sin validar
}

// BIEN — validar antes de procesar
app.post("usuarios") { req async throws -> UsuarioResponse in
    try CrearUsuarioRequest.validate(content: req)
    let input = try req.content.decode(CrearUsuarioRequest.self)
    // ahora es seguro procesar
}
```

### 4. Queries N+1 con relaciones
```swift
// MAL — un query por cada usuario para obtener sus tareas
let usuarios = try await UsuarioModel.query(on: req.db).all()
for usuario in usuarios {
    let tareas = try await usuario.$tareas.get(on: req.db) // N queries adicionales!
}

// BIEN — eager loading en un solo query
let usuarios = try await UsuarioModel.query(on: req.db)
    .with(\.$tareas) // JOIN automatico
    .all()
```

### 5. No manejar CORS para desarrollo iOS
```swift
// MAL — la app iOS no puede conectar al servidor local
// (sin configuracion CORS, el simulador rechaza las peticiones)

// BIEN — configurar CORS apropiadamente
let corsConfig = CORSMiddleware.Configuration(
    allowedOrigin: .all, // en produccion, restringir a tu dominio
    allowedMethods: [.GET, .POST, .PUT, .DELETE],
    allowedHeaders: [.accept, .authorization, .contentType]
)
app.middleware.use(CORSMiddleware(configuration: corsConfig))
```

---

## Checklist

- [ ] Entender por que Swift en el servidor tiene ventajas para desarrolladores iOS
- [ ] Crear un proyecto Vapor desde cero con `vapor new`
- [ ] Definir routes con diferentes metodos HTTP (GET, POST, PUT, DELETE)
- [ ] Usar Content protocol para serializar/deserializar JSON
- [ ] Implementar un RouteCollection (controlador) organizado
- [ ] Configurar Fluent con SQLite para persistencia
- [ ] Crear modelos con @ID, @Field, @Timestamp y relaciones
- [ ] Escribir migraciones para crear y modificar tablas
- [ ] Implementar middleware custom (logging, autenticacion)
- [ ] Compartir modelos entre iOS y servidor via Swift Package

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Server-Side Swift abre nuevas posibilidades para el Proyecto Integrador:
- **Backend propio** en Vapor que sirva la API del proyecto — control total sobre los datos
- **Modelos compartidos** via Swift Package — mismos structs en iOS y servidor, cero desincronizacion
- **Autenticacion** con JWT o API Keys para proteger endpoints sensibles
- **Fluent ORM** para persistencia en PostgreSQL en produccion, SQLite en desarrollo
- **Docker** para deployment en Railway, Fly.io o cualquier servicio que soporte contenedores
- **WebSockets** para funcionalidad en tiempo real (chat, notificaciones live)
- **Validaciones compartidas** que garantizan consistencia en ambos lados

---

*Leccion 41 | Server-Side Swift con Vapor | Semana 51 | Modulo 12: Extras y Especializacion*
*Siguiente: Leccion 42 — Metal y Graficos*
