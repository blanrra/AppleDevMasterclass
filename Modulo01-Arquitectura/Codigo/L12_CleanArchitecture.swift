// L12_CleanArchitecture.swift — Clean Architecture con Dependency Injection
// Ejecutar: swift L12_CleanArchitecture.swift
//
// WHY: Clean Architecture separa el codigo en capas con dependencias que
// apuntan hacia adentro (Domain). Esto permite cambiar la base de datos,
// la red, o la UI sin afectar la logica de negocio.
//
// Capas (de adentro hacia afuera):
//   Domain (Entidades + Casos de Uso) -> Data (Repositorios) -> Presentacion

import Foundation

// ═══════════════════════════════════════════════
// MARK: - CAPA DOMAIN (Centro — sin dependencias externas)
// ═══════════════════════════════════════════════

// Entidad pura — no sabe nada de bases de datos ni de red
struct Producto: CustomStringConvertible {
    let id: String
    var nombre: String
    var precio: Double
    var stock: Int

    var description: String {
        "[\(id)] \(nombre) — $\(String(format: "%.2f", precio)) (stock: \(stock))"
    }
}

// Protocolo del repositorio — definido en Domain, implementado en Data
// Esta es la clave: Domain DEFINE la interfaz, no la implementacion
protocol ProductoRepository {
    func obtenerTodos() throws -> [Producto]
    func guardar(_ producto: Producto) throws
    func buscarPorId(_ id: String) throws -> Producto?
    func eliminar(id: String) throws
}

// Errores del dominio
enum DomainError: Error, CustomStringConvertible {
    case productoNoEncontrado(String)
    case precioInvalido
    case stockInsuficiente

    var description: String {
        switch self {
        case .productoNoEncontrado(let id): return "Producto '\(id)' no encontrado"
        case .precioInvalido: return "El precio debe ser mayor a 0"
        case .stockInsuficiente: return "Stock insuficiente para la operacion"
        }
    }
}

// ═══════════════════════════════════════════════
// MARK: - CAPA DATA (Implementaciones concretas)
// ═══════════════════════════════════════════════

// Repositorio local — usa un diccionario en memoria (simulando SwiftData)
final class LocalProductoRepository: ProductoRepository {
    private var almacen: [String: Producto] = [:]

    func obtenerTodos() throws -> [Producto] {
        print("    [Local] Leyendo de almacenamiento local...")
        return Array(almacen.values)
    }

    func guardar(_ producto: Producto) throws {
        print("    [Local] Guardando '\(producto.nombre)' en disco...")
        almacen[producto.id] = producto
    }

    func buscarPorId(_ id: String) throws -> Producto? {
        print("    [Local] Buscando '\(id)' en cache local...")
        return almacen[id]
    }

    func eliminar(id: String) throws {
        print("    [Local] Eliminando '\(id)' de almacenamiento local...")
        almacen.removeValue(forKey: id)
    }
}

// Repositorio remoto — simula llamadas a una API REST
final class RemoteProductoRepository: ProductoRepository {
    private var servidorSimulado: [String: Producto] = [:]

    func obtenerTodos() throws -> [Producto] {
        print("    [Remoto] GET /api/productos ...")
        return Array(servidorSimulado.values)
    }

    func guardar(_ producto: Producto) throws {
        print("    [Remoto] POST /api/productos — enviando '\(producto.nombre)'...")
        servidorSimulado[producto.id] = producto
    }

    func buscarPorId(_ id: String) throws -> Producto? {
        print("    [Remoto] GET /api/productos/\(id) ...")
        return servidorSimulado[id]
    }

    func eliminar(id: String) throws {
        print("    [Remoto] DELETE /api/productos/\(id) ...")
        servidorSimulado.removeValue(forKey: id)
    }
}

// ═══════════════════════════════════════════════
// MARK: - CAPA SERVICE / USE CASES (Logica de negocio)
// ═══════════════════════════════════════════════

// El servicio recibe el repositorio por INYECCION DE DEPENDENCIAS (protocolo).
// No sabe si es local, remoto, o un mock para testing.
final class ProductoService {
    private let repositorio: ProductoRepository // <-- Depende de la ABSTRACCION

    // DI por constructor — la forma mas limpia y testeable
    init(repositorio: ProductoRepository) {
        self.repositorio = repositorio
    }

    func crearProducto(nombre: String, precio: Double, stock: Int) throws {
        // Regla de negocio: validar precio
        guard precio > 0 else { throw DomainError.precioInvalido }

        let producto = Producto(
            id: UUID().uuidString.prefix(8).lowercased(),
            nombre: nombre,
            precio: precio,
            stock: stock
        )
        try repositorio.guardar(producto)
        print("  Producto creado: \(producto)")
    }

    func listarProductos() throws -> [Producto] {
        let productos = try repositorio.obtenerTodos()
        // Regla de negocio: siempre ordenar por nombre
        return productos.sorted { $0.nombre < $1.nombre }
    }

    func aplicarDescuento(productoId: String, porcentaje: Double) throws {
        guard let producto = try repositorio.buscarPorId(productoId) else {
            throw DomainError.productoNoEncontrado(productoId)
        }
        var actualizado = producto
        actualizado.precio *= (1 - porcentaje / 100)
        try repositorio.guardar(actualizado)
        print("  Descuento de \(porcentaje)% aplicado a '\(producto.nombre)': $\(String(format: "%.2f", producto.precio)) -> $\(String(format: "%.2f", actualizado.precio))")
    }
}

// ═══════════════════════════════════════════════
// MARK: - EJECUCION DEL DEMO
// ═══════════════════════════════════════════════

print("=== DEMO CLEAN ARCHITECTURE ===\n")

// --- Escenario 1: Usando repositorio LOCAL ---
print("--- Escenario 1: Repositorio Local ---")
let repoLocal = LocalProductoRepository()
let servicioLocal = ProductoService(repositorio: repoLocal)

do {
    try servicioLocal.crearProducto(nombre: "MacBook Pro", precio: 2499.00, stock: 10)
    try servicioLocal.crearProducto(nombre: "iPad Air", precio: 799.00, stock: 25)

    let productos = try servicioLocal.listarProductos()
    print("\n  Catalogo local:")
    productos.forEach { print("    \($0)") }
} catch {
    print("  Error: \(error)")
}

// --- Escenario 2: MISMO servicio, repositorio REMOTO ---
// Solo cambiamos la implementacion inyectada — CERO cambios en ProductoService
print("\n--- Escenario 2: Repositorio Remoto (misma logica) ---")
let repoRemoto = RemoteProductoRepository()
let servicioRemoto = ProductoService(repositorio: repoRemoto)

do {
    try servicioRemoto.crearProducto(nombre: "AirPods Pro", precio: 249.00, stock: 50)
    try servicioRemoto.crearProducto(nombre: "Apple Watch", precio: 399.00, stock: 30)

    let productos = try servicioRemoto.listarProductos()
    print("\n  Catalogo remoto:")
    productos.forEach { print("    \($0)") }
} catch {
    print("  Error: \(error)")
}

// --- Escenario 3: Validacion de reglas de negocio ---
print("\n--- Escenario 3: Reglas de Negocio ---")
do {
    try servicioLocal.crearProducto(nombre: "Gratis", precio: -10, stock: 1)
} catch {
    print("  Validacion correcta: \(error)")
}

print("\n--- Punto clave ---")
print("ProductoService NO cambio entre local y remoto.")
print("La DI por protocolo permite intercambiar implementaciones")
print("sin modificar la logica de negocio. Ideal para testing.")
