import Foundation

// MARK: - Leccion 01: Swift 6 Language — Sistema de Gestion de Tareas
// Ejecutar: swift Modulo00-Fundamentos/Codigo/Swift6Basics.swift

// MARK: - Modelo

struct Tarea: Identifiable, CustomStringConvertible {
    let id = UUID()
    var titulo: String
    var descripcion: String
    var completada: Bool = false
    var prioridad: Prioridad
    let fechaCreacion = Date()

    enum Prioridad: Int, CaseIterable, Comparable {
        case baja = 1, media = 2, alta = 3

        var emoji: String {
            switch self {
            case .baja: return "🟢"
            case .media: return "🟡"
            case .alta: return "🔴"
            }
        }

        static func < (lhs: Prioridad, rhs: Prioridad) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    var description: String {
        let estado = completada ? "✅" : "⬜️"
        return "\(estado) \(prioridad.emoji) \(titulo)"
    }
}

// MARK: - Gestor

struct GestorTareas {
    private var tareas: [Tarea] = []

    mutating func agregar(_ tarea: Tarea) {
        tareas.append(tarea)
        print("+ Agregada: \(tarea.titulo)")
    }

    mutating func completar(id: UUID) {
        guard let idx = tareas.firstIndex(where: { $0.id == id }) else {
            print("⚠️ Tarea no encontrada")
            return
        }
        tareas[idx].completada = true
        print("✅ Completada: \(tareas[idx].titulo)")
    }

    func filtrar(prioridad: Tarea.Prioridad) -> [Tarea] {
        tareas.filter { $0.prioridad == prioridad }
    }

    func pendientes() -> [Tarea] {
        tareas.filter { !$0.completada }.sorted { $0.prioridad > $1.prioridad }
    }

    func listar() {
        if tareas.isEmpty {
            print("(sin tareas)")
            return
        }
        tareas.forEach { print("  \($0)") }
    }
}

// MARK: - Genericos: Pila

struct Pila<Element> {
    private var elementos: [Element] = []

    var estaVacia: Bool { elementos.isEmpty }
    var tope: Element? { elementos.last }
    var count: Int { elementos.count }

    mutating func apilar(_ elemento: Element) {
        elementos.append(elemento)
    }

    mutating func desapilar() -> Element? {
        elementos.popLast()
    }
}

// MARK: - Error Handling

enum ErrorValidacion: Error, CustomStringConvertible {
    case campoVacio(String)
    case longitudInvalida(campo: String, minimo: Int)

    var description: String {
        switch self {
        case .campoVacio(let campo):
            return "El campo '\(campo)' no puede estar vacio"
        case .longitudInvalida(let campo, let minimo):
            return "El campo '\(campo)' debe tener al menos \(minimo) caracteres"
        }
    }
}

func validarTitulo(_ titulo: String) throws -> String {
    guard !titulo.isEmpty else {
        throw ErrorValidacion.campoVacio("titulo")
    }
    guard titulo.count >= 3 else {
        throw ErrorValidacion.longitudInvalida(campo: "titulo", minimo: 3)
    }
    return titulo
}

// MARK: - Demo

print("========================================")
print("  DEMO: Swift 6 Basics")
print("========================================\n")

// 1. Gestor de Tareas
print("--- Gestor de Tareas ---")
var gestor = GestorTareas()
let t1 = Tarea(titulo: "Aprender Swift 6", descripcion: "Completar leccion 01", prioridad: .alta)
let t2 = Tarea(titulo: "Practicar closures", descripcion: "Hacer ejercicios", prioridad: .media)
let t3 = Tarea(titulo: "Leer documentacion", descripcion: "Cupertino MCP", prioridad: .baja)

gestor.agregar(t1)
gestor.agregar(t2)
gestor.agregar(t3)

print("\nTodas las tareas:")
gestor.listar()

gestor.completar(id: t2.id)
print("\nPendientes (por prioridad):")
for tarea in gestor.pendientes() {
    print("  \(tarea)")
}

// 2. Pila Generica
print("\n--- Pila Generica ---")
var pila = Pila<String>()
pila.apilar("Primero")
pila.apilar("Segundo")
pila.apilar("Tercero")
print("Tope: \(pila.tope ?? "vacia")")
print("Desapilado: \(pila.desapilar() ?? "nada")")
print("Nuevo tope: \(pila.tope ?? "vacia")")

// 3. Error Handling
print("\n--- Error Handling ---")
let titulos = ["Aprender Swift", "AB", ""]
for titulo in titulos {
    do {
        let validado = try validarTitulo(titulo)
        print("✅ Titulo valido: \(validado)")
    } catch {
        print("❌ \(error)")
    }
}

// 4. Closures: Higher-order functions
print("\n--- Closures y Higher-Order Functions ---")
let numeros = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3]
let pares = numeros.filter { $0 % 2 == 0 }
let dobles = numeros.map { $0 * 2 }
let suma = numeros.reduce(0, +)

print("Numeros: \(numeros)")
print("Pares: \(pares)")
print("Dobles: \(dobles)")
print("Suma: \(suma)")

print("\n========================================")
print("  Demo completada")
print("========================================")
