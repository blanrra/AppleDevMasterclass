// L15_Navegacion.swift — Navegacion Programatica y Deep Linking
// Ejecutar: swift L15_Navegacion.swift
//
// WHY: En SwiftUI moderno, la navegacion se maneja con NavigationStack
// y NavigationPath. Usar enums como rutas da type-safety y permite
// deep linking desde URLs, notificaciones push, o Shortcuts.

import Foundation

// MARK: - Definicion de Rutas con Enum
// Cada pantalla de la app es un caso del enum.
// Esto reemplaza las strings magicas y da seguridad de tipos.

enum Ruta: CustomStringConvertible, Hashable {
    case inicio
    case listaProductos(categoria: String)
    case detalleProducto(id: Int)
    case carrito
    case perfil(usuarioId: String)
    case configuracion
    case busqueda(termino: String)

    var description: String {
        switch self {
        case .inicio: return "Pantalla: Inicio"
        case .listaProductos(let cat): return "Pantalla: Productos [\(cat)]"
        case .detalleProducto(let id): return "Pantalla: Detalle Producto #\(id)"
        case .carrito: return "Pantalla: Carrito"
        case .perfil(let uid): return "Pantalla: Perfil (\(uid))"
        case .configuracion: return "Pantalla: Configuracion"
        case .busqueda(let t): return "Pantalla: Busqueda '\(t)'"
        }
    }
}

// MARK: - NavigationPath Simulado
// En SwiftUI real, NavigationPath maneja el stack.
// Aqui simulamos su comportamiento para entender el concepto.

final class RouterNavegacion {
    private var pila: [Ruta] = [.inicio]

    var rutaActual: Ruta { pila.last ?? .inicio }
    var profundidad: Int { pila.count }

    func navegar(a ruta: Ruta) {
        pila.append(ruta)
        print("  -> Navegando a: \(ruta)")
        print("     Pila (\(profundidad) niveles): \(pila.map { "\($0)" }.joined(separator: " > "))")
    }

    func regresar() {
        guard pila.count > 1 else {
            print("  Ya estas en la raiz, no se puede regresar.")
            return
        }
        let removida = pila.removeLast()
        print("  <- Regresando de: \(removida)")
        print("     Ahora en: \(rutaActual)")
    }

    func regresarAInicio() {
        pila = [.inicio]
        print("  <<- Pop to root: \(rutaActual)")
    }

    func mostrarPila() {
        print("  Pila actual: \(pila.map { "\($0)" }.joined(separator: " > "))")
    }
}

// MARK: - Deep Linking — Parseo de URLs
// Convierte URLs como "miapp://producto/42" en rutas tipadas.

struct DeepLinkParser {
    /// Parsea una URL y devuelve la ruta correspondiente
    static func parsear(url: String) -> Ruta? {
        // Eliminar esquema (miapp://)
        guard let urlObj = URL(string: url),
              let host = urlObj.host else {
            return nil
        }

        let componentes = urlObj.pathComponents.filter { $0 != "/" }

        switch host {
        case "inicio":
            return .inicio
        case "productos":
            let categoria = componentes.first ?? "todos"
            return .listaProductos(categoria: categoria)
        case "producto":
            guard let idStr = componentes.first, let id = Int(idStr) else { return nil }
            return .detalleProducto(id: id)
        case "carrito":
            return .carrito
        case "perfil":
            guard let uid = componentes.first else { return nil }
            return .perfil(usuarioId: uid)
        case "buscar":
            // Extraer query parameter: miapp://buscar?q=iphone
            guard let queryItems = URLComponents(string: url)?.queryItems,
                  let termino = queryItems.first(where: { $0.name == "q" })?.value else {
                return nil
            }
            return .busqueda(termino: termino)
        default:
            return nil
        }
    }
}

// MARK: - Ejecucion del Demo

print("=== DEMO NAVEGACION PROGRAMATICA ===\n")

let router = RouterNavegacion()

// 1. Navegacion normal por la pila
print("1. Navegacion por pila:")
router.navegar(a: .listaProductos(categoria: "Electronica"))
router.navegar(a: .detalleProducto(id: 42))
router.navegar(a: .carrito)

print("\n2. Regresando:")
router.regresar()
router.regresar()

print("\n3. Pop to root:")
router.navegar(a: .perfil(usuarioId: "user_123"))
router.navegar(a: .configuracion)
router.regresarAInicio()

// 2. Deep Linking
print("\n4. Deep Linking — Parseo de URLs:")
let urls = [
    "miapp://producto/99",
    "miapp://productos/accesorios",
    "miapp://carrito",
    "miapp://perfil/jose_dev",
    "miapp://buscar?q=iphone",
    "miapp://ruta-invalida",
]

for url in urls {
    if let ruta = DeepLinkParser.parsear(url: url) {
        print("  \(url)  -->  \(ruta)")
    } else {
        print("  \(url)  -->  (ruta no reconocida)")
    }
}

print("\n--- Punto clave ---")
print("Rutas como enums = type-safety + exhaustive switch.")
print("Deep linking parsea URLs en rutas tipadas, no strings.")
