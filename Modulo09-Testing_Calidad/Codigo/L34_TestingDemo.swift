// L34_TestingDemo.swift — Conceptos de Testing sin XCTest
// Ejecutar: swift L34_TestingDemo.swift
//
// WHY: Testear no es opcional — es la unica forma de garantizar que
// el codigo funciona hoy Y manana. Aqui construimos un mini framework
// de testing para entender Mock, Stub, Spy y assertions por dentro.

import Foundation

// MARK: - Mini Framework de Testing

struct TestResult {
    let nombre: String
    let paso: Bool
    let mensaje: String?
}

final class TestRunner {
    private var resultados: [TestResult] = []
    private var grupo: String = ""

    func describe(_ nombre: String, bloque: () throws -> Void) {
        grupo = nombre
        print("\n  \(nombre)")
        do {
            try bloque()
        } catch {
            registrar(nombre: "Error inesperado", paso: false, mensaje: "\(error)")
        }
    }

    func it(_ descripcion: String, test: () throws -> Void) {
        do {
            try test()
            registrar(nombre: descripcion, paso: true)
        } catch {
            registrar(nombre: descripcion, paso: false, mensaje: "\(error)")
        }
    }

    private func registrar(nombre: String, paso: Bool, mensaje: String? = nil) {
        let resultado = TestResult(nombre: nombre, paso: paso, mensaje: mensaje)
        resultados.append(resultado)
        let icono = paso ? "PASS" : "FAIL"
        print("    [\(icono)] \(nombre)")
        if let msg = mensaje { print("           \(msg)") }
    }

    func resumen() {
        let pasaron = resultados.filter { $0.paso }.count
        let fallaron = resultados.filter { !$0.paso }.count
        print("\n  ================================")
        print("  Resultados: \(pasaron) pasaron, \(fallaron) fallaron de \(resultados.count) total")
        if fallaron == 0 {
            print("  Todos los tests pasaron!")
        }
        print("  ================================")
    }
}

// Assertions personalizadas
struct Assert {
    static func igual<T: Equatable>(_ actual: T, _ esperado: T, _ mensaje: String = "") throws {
        guard actual == esperado else {
            throw AssertionError.noIgual("Esperado: \(esperado), Actual: \(actual). \(mensaje)")
        }
    }

    static func verdadero(_ condicion: Bool, _ mensaje: String = "") throws {
        guard condicion else {
            throw AssertionError.noVerdadero(mensaje)
        }
    }

    static func nulo<T>(_ valor: T?, _ mensaje: String = "") throws {
        guard valor == nil else {
            throw AssertionError.noNulo("Se esperaba nil pero se obtuvo: \(valor!). \(mensaje)")
        }
    }

    static func noNulo<T>(_ valor: T?, _ mensaje: String = "") throws {
        guard valor != nil else {
            throw AssertionError.esNulo(mensaje)
        }
    }

    static func lanza<E: Error>(_ tipo: E.Type, bloque: () throws -> Void) throws {
        do {
            try bloque()
            throw AssertionError.noLanzo("Se esperaba error de tipo \(tipo)")
        } catch is E {
            // Correcto — lanzo el error esperado
        }
    }
}

enum AssertionError: Error, CustomStringConvertible {
    case noIgual(String)
    case noVerdadero(String)
    case noNulo(String)
    case esNulo(String)
    case noLanzo(String)

    var description: String {
        switch self {
        case .noIgual(let m), .noVerdadero(let m), .noNulo(let m),
             .esNulo(let m), .noLanzo(let m):
            return m
        }
    }
}

// MARK: - Codigo a Testear: Servicio de Autenticacion

protocol ServicioAutenticacion {
    func login(usuario: String, password: String) -> Bool
    func logout()
}

struct CredencialInvalida: Error {}

final class AuthService: ServicioAutenticacion {
    private let validador: ValidadorCredenciales
    private(set) var usuarioActual: String?

    init(validador: ValidadorCredenciales) {
        self.validador = validador
    }

    func login(usuario: String, password: String) -> Bool {
        guard validador.validar(usuario: usuario, password: password) else { return false }
        usuarioActual = usuario
        return true
    }

    func logout() {
        usuarioActual = nil
    }
}

protocol ValidadorCredenciales {
    func validar(usuario: String, password: String) -> Bool
}

// MARK: - Patrones de Test Doubles

// STUB — Devuelve valores predefinidos (no verifica interacciones)
class StubValidador: ValidadorCredenciales {
    var resultadoFijo: Bool

    init(resultado: Bool) { self.resultadoFijo = resultado }

    func validar(usuario: String, password: String) -> Bool {
        return resultadoFijo // Siempre devuelve lo configurado
    }
}

// SPY — Registra las llamadas para verificar interacciones
class SpyValidador: ValidadorCredenciales {
    var llamadas: [(usuario: String, password: String)] = []
    var vecesLlamado: Int { llamadas.count }
    var resultadoFijo: Bool = true

    func validar(usuario: String, password: String) -> Bool {
        llamadas.append((usuario, password))
        return resultadoFijo
    }
}

// MOCK — Verifica comportamiento esperado
class MockValidador: ValidadorCredenciales {
    var esperaUsuario: String?
    var esperaPassword: String?
    var fueVerificado = false

    func validar(usuario: String, password: String) -> Bool {
        fueVerificado = true
        return usuario == esperaUsuario && password == esperaPassword
    }

    func verificar() -> Bool { fueVerificado }
}

// MARK: - Ejecucion de Tests

print("=== DEMO TESTING: Mock, Stub, Spy ===")

let runner = TestRunner()

runner.describe("AuthService con Stub") {
    runner.it("login exitoso cuando stub devuelve true") {
        let stub = StubValidador(resultado: true)
        let auth = AuthService(validador: stub)
        let resultado = auth.login(usuario: "jose", password: "cualquiera")
        try Assert.verdadero(resultado, "Login deberia ser exitoso")
        try Assert.igual(auth.usuarioActual, "jose")
    }

    runner.it("login falla cuando stub devuelve false") {
        let stub = StubValidador(resultado: false)
        let auth = AuthService(validador: stub)
        let resultado = auth.login(usuario: "jose", password: "mala")
        try Assert.verdadero(!resultado, "Login deberia fallar")
        try Assert.nulo(auth.usuarioActual)
    }
}

runner.describe("AuthService con Spy") {
    runner.it("verifica que el validador fue llamado con los parametros correctos") {
        let spy = SpyValidador()
        let auth = AuthService(validador: spy)
        _ = auth.login(usuario: "admin", password: "secreto")
        try Assert.igual(spy.vecesLlamado, 1)
        try Assert.igual(spy.llamadas[0].usuario, "admin")
        try Assert.igual(spy.llamadas[0].password, "secreto")
    }
}

runner.describe("AuthService con Mock") {
    runner.it("verifica interaccion completa con credenciales esperadas") {
        let mock = MockValidador()
        mock.esperaUsuario = "jose"
        mock.esperaPassword = "swift6"
        let auth = AuthService(validador: mock)
        let resultado = auth.login(usuario: "jose", password: "swift6")
        try Assert.verdadero(resultado)
        try Assert.verdadero(mock.verificar(), "Mock deberia haber sido invocado")
    }
}

runner.describe("AuthService — Logout") {
    runner.it("logout limpia el usuario actual") {
        let stub = StubValidador(resultado: true)
        let auth = AuthService(validador: stub)
        _ = auth.login(usuario: "jose", password: "x")
        try Assert.noNulo(auth.usuarioActual)
        auth.logout()
        try Assert.nulo(auth.usuarioActual)
    }
}

runner.resumen()

print("\n--- Punto clave ---")
print("Stub = respuesta fija. Spy = registra llamadas. Mock = verifica comportamiento.")
print("La DI por protocolo hace posible inyectar cualquiera de estos en tests.")
