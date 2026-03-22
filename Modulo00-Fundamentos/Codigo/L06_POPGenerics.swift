import Foundation

// MARK: - Leccion 02: POP y Genericos Avanzados
// Ejecutar: swift Modulo00-Fundamentos/Codigo/POPGenerics.swift

// MARK: - 1. Protocol Extensions con Implementaciones por Defecto

protocol Describible {
    var nombre: String { get }
}

extension Describible {
    func descripcionCompleta() -> String {
        "Soy \(nombre)"
    }

    func log() {
        print("[LOG] \(descripcionCompleta())")
    }
}

// MARK: - 2. Protocol Composition

protocol Identificable {
    var id: String { get }
}

protocol Nombrable {
    var nombre: String { get }
}

protocol Auditable {
    var fechaCreacion: Date { get }
}

typealias EntidadCompleta = Identificable & Nombrable & Auditable

struct Empleado: EntidadCompleta, Describible {
    let id: String
    let nombre: String
    let fechaCreacion: Date
    let departamento: String
}

func registrar(_ entidad: any Identificable & Nombrable) {
    print("📋 Registrando: \(entidad.nombre) (ID: \(entidad.id))")
}

// MARK: - 3. Associated Types y Repositorio Generico

protocol Repositorio {
    associatedtype Entidad: Identifiable

    mutating func guardar(_ entidad: Entidad)
    func obtener(id: Entidad.ID) -> Entidad?
    mutating func eliminar(id: Entidad.ID)
    func todos() -> [Entidad]
}

struct Producto: Identifiable {
    let id: UUID
    var nombre: String
    var precio: Decimal
}

struct RepositorioEnMemoria<T: Identifiable>: Repositorio where T.ID: Hashable {
    typealias Entidad = T
    private var almacen: [T.ID: T] = [:]

    mutating func guardar(_ entidad: T) {
        almacen[entidad.id] = entidad
    }

    func obtener(id: T.ID) -> T? {
        almacen[id]
    }

    mutating func eliminar(id: T.ID) {
        almacen.removeValue(forKey: id)
    }

    func todos() -> [T] {
        Array(almacen.values)
    }
}

// MARK: - 4. Conditional Conformance

struct Caja<T> {
    let contenido: T
}

extension Caja: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        "📦 Caja(\(contenido.description))"
    }
}

extension Caja: Equatable where T: Equatable {
    static func == (lhs: Caja<T>, rhs: Caja<T>) -> Bool {
        lhs.contenido == rhs.contenido
    }
}

// MARK: - 5. Genericos Avanzados con Where

func encontrarDuplicados<T: Hashable>(en array: [T]) -> Set<T> {
    var vistos = Set<T>()
    var duplicados = Set<T>()
    for elemento in array {
        if vistos.contains(elemento) {
            duplicados.insert(elemento)
        }
        vistos.insert(elemento)
    }
    return duplicados
}

// MARK: - 6. some vs any

func crearColeccion() -> some Collection {
    [1, 2, 3, 4, 5]
}

func procesarDescribibles(_ items: [any Describible]) {
    for item in items {
        item.log()
    }
}

// MARK: - Demo

print("========================================")
print("  DEMO: POP y Genericos Avanzados")
print("========================================\n")

// 1. Protocol Extensions
print("--- Protocol Extensions ---")
let emp = Empleado(
    id: "E001",
    nombre: "Laura Garcia",
    fechaCreacion: Date(),
    departamento: "Ingenieria"
)
emp.log()
print("Descripcion: \(emp.descripcionCompleta())")

// 2. Protocol Composition
print("\n--- Protocol Composition ---")
registrar(emp)

// 3. Repositorio Generico
print("\n--- Repositorio Generico ---")
var repo = RepositorioEnMemoria<Producto>()
let p1 = Producto(id: UUID(), nombre: "MacBook Pro", precio: 2499)
let p2 = Producto(id: UUID(), nombre: "iPhone 17", precio: 999)
let p3 = Producto(id: UUID(), nombre: "AirPods Pro", precio: 249)

repo.guardar(p1)
repo.guardar(p2)
repo.guardar(p3)

print("Total productos: \(repo.todos().count)")
if let encontrado = repo.obtener(id: p1.id) {
    print("Encontrado: \(encontrado.nombre) — $\(encontrado.precio)")
}

repo.eliminar(id: p3.id)
print("Despues de eliminar: \(repo.todos().count) productos")
for prod in repo.todos() {
    print("  - \(prod.nombre)")
}

// 4. Conditional Conformance
print("\n--- Conditional Conformance ---")
let caja1 = Caja(contenido: "Swift 6")
let caja2 = Caja(contenido: "Swift 6")
print(caja1)  // Usa CustomStringConvertible
print("Cajas iguales: \(caja1 == caja2)")  // Usa Equatable

// 5. Duplicados con Genericos
print("\n--- Genericos con Where ---")
let numeros = [1, 2, 3, 2, 4, 3, 5]
let dupes = encontrarDuplicados(en: numeros)
print("Numeros: \(numeros)")
print("Duplicados: \(dupes.sorted())")

let palabras = ["swift", "apple", "swift", "ios", "apple"]
let dupePalabras = encontrarDuplicados(en: palabras)
print("Palabras duplicadas: \(dupePalabras.sorted())")

// 6. some vs any
print("\n--- some vs any ---")
let col = crearColeccion()
print("Coleccion (some): \(Array(col))")

struct Robot: Describible {
    let nombre: String
}

let items: [any Describible] = [
    emp,
    Robot(nombre: "R2-D2")
]
procesarDescribibles(items)

print("\n========================================")
print("  Demo completada")
print("========================================")
