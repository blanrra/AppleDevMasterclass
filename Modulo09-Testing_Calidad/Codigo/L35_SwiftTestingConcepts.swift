// L35_SwiftTestingConcepts.swift — Swift Testing Framework (Conceptual)
// Ejecutar: swift L35_SwiftTestingConcepts.swift
//
// WHY: Swift Testing es el framework moderno que reemplaza XCTest.
// Usa macros (@Test, #expect) y soporta parametrizacion nativa.
// Aqui simulamos su API para entender el modelo mental.

import Foundation

// MARK: - Simulacion del Framework Swift Testing

/// Resultado de un test individual
struct ResultadoTest {
    let nombre: String
    let tags: Set<String>
    let paso: Bool
    let mensaje: String?
    let duracion: TimeInterval
}

/// Simula la macro #expect — la assertion principal de Swift Testing
func expect(
    _ condicion: Bool,
    _ mensaje: String = "",
    archivo: String = #file,
    linea: Int = #line
) throws {
    guard condicion else {
        throw ExpectError.fallo(mensaje.isEmpty ? "Condicion falsa en linea \(linea)" : mensaje)
    }
}

/// Simula #expect(throws:) para verificar que se lanza un error
func expectThrows<E: Error>(_ tipo: E.Type, bloque: () throws -> Void) throws {
    do {
        try bloque()
        throw ExpectError.fallo("Se esperaba error de tipo \(tipo) pero no se lanzo ninguno")
    } catch is E {
        // Correcto
    }
}

enum ExpectError: Error, CustomStringConvertible {
    case fallo(String)
    var description: String {
        switch self { case .fallo(let m): return m }
    }
}

/// Suite de tests — simula @Suite
final class TestSuite {
    let nombre: String
    private var resultados: [ResultadoTest] = []
    private var filtroTags: Set<String>?

    init(_ nombre: String, filtrarPor tags: Set<String>? = nil) {
        self.nombre = nombre
        self.filtroTags = tags
    }

    /// Simula @Test con tags opcionales
    func test(_ nombre: String, tags: Set<String> = [], bloque: () throws -> Void) {
        // Filtrado por tags — como Swift Testing real
        if let filtro = filtroTags, !filtro.isSubset(of: tags) && !tags.isEmpty {
            if filtro.intersection(tags).isEmpty {
                return // Skip — no coincide con el filtro
            }
        }

        let inicio = Date()
        do {
            try bloque()
            let duracion = Date().timeIntervalSince(inicio)
            let resultado = ResultadoTest(nombre: nombre, tags: tags, paso: true, mensaje: nil, duracion: duracion)
            resultados.append(resultado)
            print("    [PASS] \(nombre)")
        } catch {
            let duracion = Date().timeIntervalSince(inicio)
            let resultado = ResultadoTest(nombre: nombre, tags: tags, paso: false, mensaje: "\(error)", duracion: duracion)
            resultados.append(resultado)
            print("    [FAIL] \(nombre) — \(error)")
        }
    }

    /// Simula @Test con argumentos parametrizados
    func testParametrizado<T: CustomStringConvertible>(
        _ nombre: String,
        argumentos: [T],
        tags: Set<String> = [],
        bloque: (T) throws -> Void
    ) {
        print("    Parametrizado: \(nombre)")
        for arg in argumentos {
            let nombreCompleto = "\(nombre) [\(arg)]"
            test(nombreCompleto, tags: tags) {
                try bloque(arg)
            }
        }
    }

    func resumen() {
        let pasaron = resultados.filter { $0.paso }.count
        let fallaron = resultados.filter { !$0.paso }.count
        print("\n  Suite '\(nombre)': \(pasaron) pasaron, \(fallaron) fallaron")
        if let filtro = filtroTags {
            print("  (filtrado por tags: \(filtro))")
        }
    }
}

// MARK: - Codigo a Testear

struct Calculadora {
    func sumar(_ a: Int, _ b: Int) -> Int { a + b }
    func dividir(_ a: Int, _ b: Int) throws -> Int {
        guard b != 0 else { throw CalculadoraError.divisionPorCero }
        return a / b
    }
}

enum CalculadoraError: Error { case divisionPorCero }

struct ValidadorEmail {
    func esValido(_ email: String) -> Bool {
        email.contains("@") && email.contains(".") && email.count >= 5
    }
}

// MARK: - Ejecucion de Tests

print("=== DEMO SWIFT TESTING (Conceptual) ===\n")

// Suite 1: Tests basicos (simula @Suite)
print("  Suite: Calculadora")
let suite1 = TestSuite("Calculadora")

suite1.test("sumar dos numeros positivos", tags: ["aritmetica"]) {
    let calc = Calculadora()
    try expect(calc.sumar(2, 3) == 5, "2 + 3 deberia ser 5")
}

suite1.test("sumar con negativos", tags: ["aritmetica"]) {
    let calc = Calculadora()
    try expect(calc.sumar(-1, 1) == 0, "-1 + 1 deberia ser 0")
}

suite1.test("dividir lanza error con cero", tags: ["aritmetica", "errores"]) {
    let calc = Calculadora()
    try expectThrows(CalculadoraError.self) {
        _ = try calc.dividir(10, 0)
    }
}

// Tests parametrizados — una de las mejores features de Swift Testing
suite1.testParametrizado(
    "sumar es conmutativa",
    argumentos: [(2, 3), (0, 0), (-5, 5), (100, 200)].map { "\($0.0),\($0.1)" },
    tags: ["aritmetica", "propiedad"]
) { par in
    let nums = par.split(separator: ",").compactMap { Int($0) }
    let calc = Calculadora()
    try expect(calc.sumar(nums[0], nums[1]) == calc.sumar(nums[1], nums[0]))
}

suite1.resumen()

// Suite 2: Validacion de Email
print("\n  Suite: ValidadorEmail")
let suite2 = TestSuite("ValidadorEmail")

suite2.test("email valido", tags: ["validacion"]) {
    let v = ValidadorEmail()
    try expect(v.esValido("jose@dev.com"))
}

suite2.test("email sin arroba es invalido", tags: ["validacion"]) {
    let v = ValidadorEmail()
    try expect(!v.esValido("josedev.com"), "Sin @ deberia ser invalido")
}

suite2.testParametrizado(
    "emails invalidos",
    argumentos: ["", "a@b", "no-email", "@.", "ab"],
    tags: ["validacion"]
) { email in
    let v = ValidadorEmail()
    try expect(!v.esValido(email), "'\(email)' deberia ser invalido")
}

suite2.resumen()

// Suite 3: Filtrado por tags
print("\n  Suite: Solo tests con tag 'errores'")
let suite3 = TestSuite("Filtrada", filtrarPor: ["errores"])

suite3.test("este test no tiene tag errores", tags: ["aritmetica"]) {
    try expect(true) // No deberia ejecutarse
}

suite3.test("division por cero", tags: ["errores"]) {
    try expectThrows(CalculadoraError.self) {
        _ = try Calculadora().dividir(1, 0)
    }
}

suite3.resumen()

print("\n--- Punto clave ---")
print("Swift Testing: @Test + #expect = menos boilerplate que XCTest.")
print("Tests parametrizados evitan duplicar codigo.")
print("Tags permiten filtrar y organizar tests por categoria.")
