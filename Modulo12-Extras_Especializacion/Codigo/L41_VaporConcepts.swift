// L41_VaporConcepts.swift — Server-Side Swift (Conceptual)
// Ejecutar: swift L41_VaporConcepts.swift
//
// WHY: Vapor permite usar Swift en el backend, compartiendo modelos
// y logica con iOS. Aqui construimos un mini-framework web para
// entender rutas, middleware, request/response y el patron pipeline.

import Foundation

// MARK: - Tipos HTTP Basicos

enum MetodoHTTP: String, CustomStringConvertible {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    var description: String { rawValue }
}

struct Request: CustomStringConvertible {
    let metodo: MetodoHTTP
    let path: String
    var headers: [String: String]
    var body: String?
    var parametros: [String: String] // Path params como /users/:id

    var description: String {
        "\(metodo) \(path)"
    }
}

struct Response: CustomStringConvertible {
    var status: Int
    var headers: [String: String]
    var body: String

    var description: String {
        "HTTP \(status) — \(body.prefix(80))"
    }

    static func ok(_ body: String) -> Response {
        Response(status: 200, headers: ["Content-Type": "application/json"], body: body)
    }

    static func created(_ body: String) -> Response {
        Response(status: 201, headers: ["Content-Type": "application/json"], body: body)
    }

    static func notFound(_ mensaje: String = "No encontrado") -> Response {
        Response(status: 404, headers: ["Content-Type": "application/json"], body: "{\"error\": \"\(mensaje)\"}")
    }

    static func unauthorized() -> Response {
        Response(status: 401, headers: [:], body: "{\"error\": \"No autorizado\"}")
    }
}

// MARK: - Handler y Ruta

typealias RouteHandler = (Request) -> Response

struct Route {
    let metodo: MetodoHTTP
    let pathPattern: String  // Ej: "/users/:id"
    let handler: RouteHandler

    /// Verifica si un path concreto coincide con el patron
    func coincide(metodo: MetodoHTTP, path: String) -> [String: String]? {
        guard self.metodo == metodo else { return nil }

        let partes = pathPattern.split(separator: "/")
        let partesPath = path.split(separator: "/")
        guard partes.count == partesPath.count else { return nil }

        var params: [String: String] = [:]
        for (patron, valor) in zip(partes, partesPath) {
            if patron.hasPrefix(":") {
                let nombreParam = String(patron.dropFirst())
                params[nombreParam] = String(valor)
            } else if patron != valor {
                return nil
            }
        }
        return params
    }
}

// MARK: - Middleware (Pipeline Pattern)
// Cada middleware procesa el request antes de llegar al handler

protocol Middleware {
    var nombre: String { get }
    func procesar(request: Request, siguiente: (Request) -> Response) -> Response
}

struct LoggingMiddleware: Middleware {
    let nombre = "Logger"
    func procesar(request: Request, siguiente: (Request) -> Response) -> Response {
        print("    [LOG] <- \(request)")
        let response = siguiente(request)
        print("    [LOG] -> \(response.status)")
        return response
    }
}

struct AuthMiddleware: Middleware {
    let nombre = "Auth"
    let tokenValido: String

    func procesar(request: Request, siguiente: (Request) -> Response) -> Response {
        guard let token = request.headers["Authorization"],
              token == "Bearer \(tokenValido)" else {
            print("    [AUTH] Acceso denegado — token invalido")
            return .unauthorized()
        }
        print("    [AUTH] Token valido")
        return siguiente(request)
    }
}

struct CORSMiddleware: Middleware {
    let nombre = "CORS"
    func procesar(request: Request, siguiente: (Request) -> Response) -> Response {
        var response = siguiente(request)
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response
    }
}

// MARK: - Router (Registra rutas y despacha requests)

final class Router {
    private var rutas: [Route] = []
    private var middlewares: [Middleware] = []

    func usar(_ middleware: Middleware) {
        middlewares.append(middleware)
        print("  Middleware registrado: \(middleware.nombre)")
    }

    func get(_ path: String, handler: @escaping RouteHandler) {
        rutas.append(Route(metodo: .get, pathPattern: path, handler: handler))
    }

    func post(_ path: String, handler: @escaping RouteHandler) {
        rutas.append(Route(metodo: .post, pathPattern: path, handler: handler))
    }

    func delete(_ path: String, handler: @escaping RouteHandler) {
        rutas.append(Route(metodo: .delete, pathPattern: path, handler: handler))
    }

    func manejar(_ request: Request) -> Response {
        // Buscar ruta que coincida
        for ruta in rutas {
            if let params = ruta.coincide(metodo: request.metodo, path: request.path) {
                var req = request
                req.parametros = params

                // Construir pipeline de middlewares
                let handler = ruta.handler
                let pipeline = middlewares.reversed().reduce(handler) { next, mw in
                    { req in mw.procesar(request: req, siguiente: next) }
                }
                return pipeline(req)
            }
        }
        return .notFound("Ruta \(request.metodo) \(request.path) no encontrada")
    }
}

// MARK: - Ejecucion del Demo

print("=== DEMO SERVER-SIDE SWIFT (Conceptual) ===\n")

// Configurar el "servidor"
let router = Router()

// 1. Registrar middlewares
print("1. Configurando middlewares:")
router.usar(LoggingMiddleware())
router.usar(CORSMiddleware())

// 2. Definir rutas (como en Vapor)
print("\n2. Registrando rutas...")

// Base de datos simulada
var usuarios: [String: [String: String]] = [
    "1": ["nombre": "Jose", "email": "jose@dev.com"],
    "2": ["nombre": "Maria", "email": "maria@dev.com"],
]

router.get("/usuarios") { _ in
    let lista = usuarios.map { "{\"\($0.key)\": \"\($0.value["nombre"]!)\"}" }
    return .ok("[\(lista.joined(separator: ", "))]")
}

router.get("/usuarios/:id") { req in
    guard let id = req.parametros["id"], let user = usuarios[id] else {
        return .notFound("Usuario no encontrado")
    }
    return .ok("{\"id\": \"\(id)\", \"nombre\": \"\(user["nombre"]!)\"}")
}

router.post("/usuarios") { req in
    let id = "\(usuarios.count + 1)"
    usuarios[id] = ["nombre": req.body ?? "Nuevo", "email": "nuevo@dev.com"]
    return .created("{\"id\": \"\(id)\", \"creado\": true}")
}

router.delete("/usuarios/:id") { req in
    guard let id = req.parametros["id"] else { return .notFound() }
    usuarios.removeValue(forKey: id)
    return .ok("{\"eliminado\": \"\(id)\"}")
}

// 3. Simular peticiones HTTP
print("\n3. Procesando peticiones:\n")

let peticiones: [Request] = [
    Request(metodo: .get, path: "/usuarios", headers: [:], body: nil, parametros: [:]),
    Request(metodo: .get, path: "/usuarios/1", headers: [:], body: nil, parametros: [:]),
    Request(metodo: .post, path: "/usuarios", headers: [:], body: "Carlos", parametros: [:]),
    Request(metodo: .get, path: "/usuarios/3", headers: [:], body: nil, parametros: [:]),
    Request(metodo: .delete, path: "/usuarios/2", headers: [:], body: nil, parametros: [:]),
    Request(metodo: .get, path: "/ruta/inexistente", headers: [:], body: nil, parametros: [:]),
]

for peticion in peticiones {
    print("  --- \(peticion) ---")
    let respuesta = router.manejar(peticion)
    print("  Respuesta: \(respuesta)\n")
}

print("--- Punto clave ---")
print("Server-side Swift (Vapor) usa los mismos conceptos: protocolos, enums, Codable.")
print("Middleware = pipeline que procesa cada request en cadena.")
print("Puedes compartir modelos Codable entre tu app iOS y el servidor.")
