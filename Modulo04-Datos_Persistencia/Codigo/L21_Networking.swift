// L21_Networking.swift — Networking Moderno con async/await
// Ejecutar: swift L21_Networking.swift
//
// WHY: async/await reemplaza completamente los completion handlers
// para networking. Combinado con Codable y protocolos, creamos
// un cliente API limpio, testeable y con manejo robusto de errores.

import Foundation

// MARK: - Modelos Codable
// Estos modelos mapean la respuesta de JSONPlaceholder (API publica)

struct Post: Codable, CustomStringConvertible {
    let userId: Int
    let id: Int
    let title: String
    let body: String

    var description: String {
        "Post #\(id) por usuario \(userId): \(title.prefix(50))..."
    }
}

struct Usuario: Codable, CustomStringConvertible {
    let id: Int
    let name: String
    let email: String
    let username: String

    var description: String {
        "\(name) (@\(username)) — \(email)"
    }
}

// MARK: - Errores de Red

enum NetworkError: Error, CustomStringConvertible {
    case urlInvalida(String)
    case sinConexion
    case respuestaInvalida(Int)
    case decodificacionFallida(String)
    case desconocido(Error)

    var description: String {
        switch self {
        case .urlInvalida(let url): return "URL invalida: \(url)"
        case .sinConexion: return "Sin conexion a internet"
        case .respuestaInvalida(let code): return "HTTP \(code)"
        case .decodificacionFallida(let tipo): return "No se pudo decodificar: \(tipo)"
        case .desconocido(let err): return "Error desconocido: \(err.localizedDescription)"
        }
    }
}

// MARK: - Protocolo Endpoint
// Define la estructura de cualquier endpoint de forma declarativa

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }

    // URL completa construida automaticamente
    var url: URL? { get }
}

extension Endpoint {
    var baseURL: String { "https://jsonplaceholder.typicode.com" }
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var url: URL? { URL(string: baseURL + path) }
}

// Endpoints concretos — cada caso es un endpoint tipado
enum JSONPlaceholderEndpoint: Endpoint {
    case posts
    case post(id: Int)
    case usuarios
    case usuario(id: Int)
    case postsDeUsuario(userId: Int)

    var path: String {
        switch self {
        case .posts: return "/posts"
        case .post(let id): return "/posts/\(id)"
        case .usuarios: return "/users"
        case .usuario(let id): return "/users/\(id)"
        case .postsDeUsuario(let uid): return "/users/\(uid)/posts"
        }
    }

    var method: HTTPMethod { .get }
}

// MARK: - API Client con async/await

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    /// Peticion generica que decodifica cualquier tipo Codable
    func request<T: Codable>(_ endpoint: Endpoint, tipo: T.Type) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.urlInvalida(endpoint.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        for (clave, valor) in endpoint.headers {
            request.setValue(valor, forHTTPHeaderField: clave)
        }

        print("  [\(endpoint.method.rawValue)] \(url.absoluteString)")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.desconocido(error)
        }

        // Verificar status code
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.respuestaInvalida(httpResponse.statusCode)
        }

        // Decodificar
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodificacionFallida(String(describing: T.self))
        }
    }
}

// MARK: - Funcion principal async
// En un script Swift, la forma mas simple de usar async es con una funcion async
// que se ejecuta dentro de un bloque concurrente.

func ejecutarDemo() async {
    print("=== DEMO NETWORKING ASYNC/AWAIT ===\n")

    let client = APIClient()

    // 1. Obtener un post especifico
    print("1. Obteniendo post #1:")
    do {
        let post = try await client.request(
            JSONPlaceholderEndpoint.post(id: 1),
            tipo: Post.self
        )
        print("  Resultado: \(post)\n")
    } catch {
        print("  Error: \(error)\n")
    }

    // 2. Obtener lista de usuarios
    print("2. Obteniendo usuarios:")
    do {
        let usuarios = try await client.request(
            JSONPlaceholderEndpoint.usuarios,
            tipo: [Usuario].self
        )
        print("  Se obtuvieron \(usuarios.count) usuarios:")
        for u in usuarios.prefix(3) {
            print("    - \(u)")
        }
        print("    ... y \(usuarios.count - 3) mas\n")
    } catch {
        print("  Error: \(error)\n")
    }

    // 3. Peticiones concurrentes con async let
    print("3. Peticiones concurrentes (async let):")
    do {
        async let postsFuture = client.request(
            JSONPlaceholderEndpoint.posts,
            tipo: [Post].self
        )
        async let usuariosFuture = client.request(
            JSONPlaceholderEndpoint.usuarios,
            tipo: [Usuario].self
        )
        // Ambas peticiones corren en paralelo
        let (posts, usuarios) = try await (postsFuture, usuariosFuture)
        print("  Resultado simultaneo: \(posts.count) posts + \(usuarios.count) usuarios\n")
    } catch {
        print("  Error en peticion concurrente: \(error)\n")
    }

    // 4. Manejo de errores
    print("4. Manejo de error (post inexistente):")
    do {
        let _ = try await client.request(
            JSONPlaceholderEndpoint.post(id: 99999),
            tipo: Post.self
        )
    } catch let error as NetworkError {
        print("  Error tipado: \(error)\n")
    } catch {
        print("  Error generico: \(error)\n")
    }

    print("--- Punto clave ---")
    print("async/await hace el networking lineal y legible.")
    print("Endpoint como protocolo + generics = cliente reutilizable.")
}

// Ejecutar la funcion async desde el contexto top-level del script
// Nota: A partir de Swift 5.7+, los scripts soportan await a nivel top-level
await ejecutarDemo()
