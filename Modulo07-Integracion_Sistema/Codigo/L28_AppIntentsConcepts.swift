// L28_AppIntentsConcepts.swift — App Intents Conceptual Demo
// Ejecutar: swift L28_AppIntentsConcepts.swift
//
// WHY: App Intents permiten que Siri, Shortcuts y Spotlight ejecuten
// acciones de tu app. El sistema usa protocolos para descubrir que
// puede hacer tu app. Aqui simulamos ese sistema basado en protocolos.

import Foundation

// MARK: - Protocolos del Sistema de Intents
// Estos simulan los protocolos reales de App Intents framework

protocol AppIntent {
    /// Titulo que Siri/Shortcuts muestra al usuario
    static var title: String { get }
    /// Descripcion para el usuario
    static var descripcion: String { get }
    /// Ejecuta la accion y devuelve un resultado
    func perform() throws -> IntentResult
}

struct IntentResult: CustomStringConvertible {
    let mensaje: String
    let exito: Bool
    var description: String { exito ? "OK: \(mensaje)" : "ERROR: \(mensaje)" }
}

// Simula @Parameter — los parametros que Siri pregunta al usuario
protocol IntentParameter {
    associatedtype Value
    var nombre: String { get }
    var valor: Value? { get set }
    var requerido: Bool { get }
}

struct ParametroTexto: IntentParameter {
    let nombre: String
    var valor: String?
    let requerido: Bool
}

struct ParametroNumero: IntentParameter {
    let nombre: String
    var valor: Int?
    let requerido: Bool
}

// MARK: - Entity — Datos que el sistema puede consultar
// Simula AppEntity para exponer datos a Siri/Spotlight

protocol AppEntity {
    var id: String { get }
    var displayName: String { get }
    static var tipoEntidad: String { get }
}

protocol EntityQuery {
    associatedtype Entity: AppEntity
    func resultados() -> [Entity]
    func buscar(texto: String) -> [Entity]
}

// MARK: - Implementacion Concreta

struct Recordatorio: AppEntity {
    let id: String
    let displayName: String
    let fecha: String
    let prioridad: Int
    static let tipoEntidad = "Recordatorio"
}

// Intent concreto: Crear recordatorio
struct CrearRecordatorioIntent: AppIntent {
    static let title = "Crear Recordatorio"
    static let descripcion = "Crea un nuevo recordatorio con titulo y prioridad"

    var titulo: ParametroTexto
    var prioridad: ParametroNumero

    init(titulo: String? = nil, prioridad: Int? = nil) {
        self.titulo = ParametroTexto(nombre: "titulo", valor: titulo, requerido: true)
        self.prioridad = ParametroNumero(nombre: "prioridad", valor: prioridad, requerido: false)
    }

    func perform() throws -> IntentResult {
        guard let titulo = titulo.valor, !titulo.isEmpty else {
            return IntentResult(mensaje: "Se necesita un titulo", exito: false)
        }
        let prio = prioridad.valor ?? 1
        return IntentResult(
            mensaje: "Recordatorio '\(titulo)' creado con prioridad \(prio)",
            exito: true
        )
    }
}

// Intent concreto: Buscar recordatorios
struct BuscarRecordatoriosIntent: AppIntent {
    static let title = "Buscar Recordatorios"
    static let descripcion = "Busca recordatorios por texto"

    var termino: ParametroTexto

    init(termino: String? = nil) {
        self.termino = ParametroTexto(nombre: "termino", valor: termino, requerido: true)
    }

    func perform() throws -> IntentResult {
        let query = RecordatorioQuery()
        let texto = termino.valor ?? ""
        let resultados = query.buscar(texto: texto)
        if resultados.isEmpty {
            return IntentResult(mensaje: "No se encontraron recordatorios para '\(texto)'", exito: true)
        }
        let nombres = resultados.map { $0.displayName }.joined(separator: ", ")
        return IntentResult(mensaje: "Encontrados: \(nombres)", exito: true)
    }
}

// EntityQuery — el sistema consulta esto para Spotlight/Siri
struct RecordatorioQuery: EntityQuery {
    // Base de datos simulada
    private let datos = [
        Recordatorio(id: "1", displayName: "Comprar leche", fecha: "2026-03-23", prioridad: 1),
        Recordatorio(id: "2", displayName: "Reunion con equipo", fecha: "2026-03-24", prioridad: 3),
        Recordatorio(id: "3", displayName: "Comprar regalo", fecha: "2026-03-25", prioridad: 2),
        Recordatorio(id: "4", displayName: "Estudiar Swift", fecha: "2026-03-22", prioridad: 3),
    ]

    func resultados() -> [Recordatorio] { datos }

    func buscar(texto: String) -> [Recordatorio] {
        datos.filter { $0.displayName.lowercased().contains(texto.lowercased()) }
    }
}

// MARK: - Registro de Intents (el sistema descubre que puede hacer la app)

struct IntentRegistry {
    var intentsRegistrados: [(titulo: String, descripcion: String)] = []

    mutating func registrar<I: AppIntent>(_ tipo: I.Type) {
        intentsRegistrados.append((titulo: tipo.title, descripcion: tipo.descripcion))
        print("  Registrado: \"\(tipo.title)\" — \(tipo.descripcion)")
    }

    func listar() {
        print("  Intents disponibles para Siri/Shortcuts:")
        for (i, intent) in intentsRegistrados.enumerated() {
            print("    \(i + 1). \(intent.titulo)")
        }
    }
}

// MARK: - Ejecucion del Demo

// MARK: - Ejecucion del Demo

print("=== DEMO APP INTENTS (Conceptual) ===\n")

// 1. Registro de intents
print("1. Registrando intents en el sistema:")
var registry = IntentRegistry()
registry.registrar(CrearRecordatorioIntent.self)
registry.registrar(BuscarRecordatoriosIntent.self)
registry.listar()

// 2. Siri ejecuta un intent
print("\n2. Siri: \"Crea un recordatorio llamado Ir al gym\"")
let crear = CrearRecordatorioIntent(titulo: "Ir al gym", prioridad: 2)
let resultado = try? crear.perform()
print("  \(resultado!)")

// 3. Busqueda por Spotlight
print("\n3. Spotlight: Buscando 'comprar'")
let buscar = BuscarRecordatoriosIntent(termino: "comprar")
let resultadoBusqueda = try? buscar.perform()
print("  \(resultadoBusqueda!)")

// 4. Manejo de error — parametro faltante
print("\n4. Intent sin parametro requerido:")
let sinTitulo = CrearRecordatorioIntent(titulo: nil)
let errorResult = try? sinTitulo.perform()
print("  \(errorResult!)")

print("\n--- Punto clave ---")
print("App Intents = protocolos que el sistema descubre automaticamente.")
print("Tu app declara QUE puede hacer; Siri/Shortcuts lo ejecutan.")
