# Leccion 34: XCTest — El Framework de Testing de Apple

**Modulo 09: Testing y Calidad** | Semanas 43-44

---

## TL;DR — Resumen en 2 minutos

- **XCTest** es el framework de testing integrado en Xcode — toda app profesional necesita tests
- **XCTAssert** y sus variantes verifican condiciones: `XCTAssertEqual`, `XCTAssertThrowsError`, `XCTAssertNil`
- **setUp/tearDown** preparan y limpian el estado antes/despues de cada test
- **async testing** funciona directamente con `async/await` — no mas expectations para concurrencia basica
- **Mocking con protocolos** aisla dependencias — test doubles (stub, mock, spy, fake) verifican comportamiento

> Herramienta: **Xcode 26** con panel de Test Navigator (Cmd+6) para ejecutar y ver resultados

---

## Cupertino MCP

```bash
cupertino search "XCTest"
cupertino search "XCTestCase"
cupertino search --source apple-docs "XCTAssert"
cupertino search "XCTestExpectation"
cupertino search "async testing XCTest"
cupertino search "test plan Xcode"
cupertino search "code coverage Xcode"
cupertino search --source apple-docs "measure performance testing"
cupertino search --source updates "testing Xcode 26"
cupertino search "XCTUnwrap"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Testing | Novedades testing en Xcode 26 |
| WWDC24 | [Go further with Swift Testing](https://developer.apple.com/videos/play/wwdc2024/) | **Esencial** — comparativa con XCTest |
| WWDC21 | [Embrace Expected Failures in XCTest](https://developer.apple.com/videos/play/wwdc2021/) | Manejo de fallos conocidos |
| WWDC20 | [Write Tests to Fail](https://developer.apple.com/videos/play/wwdc2020/) | Filosofia de testing |
| EN | [Paul Hudson — Testing](https://www.hackingwithswift.com) | Fundamentos de testing |
| ES | [SwiftBeta — Testing](https://www.swiftbeta.com) | Testing en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Testing?

Cada vez que haces un cambio en tu app sin tests, estas jugando a la ruleta rusa con tu codigo. Los tests automatizados son la unica forma de garantizar que lo que funcionaba ayer sigue funcionando hoy. No es un lujo, es una necesidad profesional.

El costo de un bug en produccion es 10x mayor que detectarlo en desarrollo. Un test que tarda 0.01 segundos en ejecutarse reemplaza minutos de verificacion manual. Y lo mas importante: los tests te dan confianza para refactorizar sin miedo.

XCTest lleva con nosotros desde los origenes de iOS. Es maduro, estable y esta profundamente integrado en Xcode. Aunque Swift Testing (Leccion 35) es el futuro, XCTest sigue siendo la base que todo desarrollador debe dominar.

### XCTestCase — La Unidad Basica

Cada clase de test hereda de `XCTestCase`. Cada metodo que empieza con `test` se ejecuta automaticamente. Xcode descubre los tests por convencion de nombres.

```swift
import XCTest

// MARK: - Test basico de XCTest
final class CalculadoraTests: XCTestCase {

    // MARK: - Propiedades
    var calculadora: Calculadora!

    // MARK: - setUp y tearDown

    /// Se ejecuta ANTES de cada metodo test individual
    override func setUp() {
        super.setUp()
        calculadora = Calculadora()
    }

    /// Se ejecuta DESPUES de cada metodo test individual
    override func tearDown() {
        calculadora = nil
        super.tearDown()
    }

    // MARK: - Tests de suma

    func testSumaPositivos() {
        let resultado = calculadora.sumar(3, 5)
        XCTAssertEqual(resultado, 8, "3 + 5 deberia ser 8")
    }

    func testSumaNegativos() {
        let resultado = calculadora.sumar(-3, -5)
        XCTAssertEqual(resultado, -8, "(-3) + (-5) deberia ser -8")
    }

    func testSumaCero() {
        let resultado = calculadora.sumar(0, 0)
        XCTAssertEqual(resultado, 0, "0 + 0 deberia ser 0")
    }
}

// MARK: - Modelo bajo test
struct Calculadora {
    func sumar(_ a: Int, _ b: Int) -> Int { a + b }
    func dividir(_ a: Double, _ b: Double) throws -> Double {
        guard b != 0 else { throw CalculadoraError.divisionPorCero }
        return a / b
    }
}

enum CalculadoraError: Error {
    case divisionPorCero
}
```

**Convencion de nombres**: `test` + `QueSePrueba` + `Condicion` + `ResultadoEsperado`. Ejemplo: `testDivision_CuandoDivisorEsCero_LanzaError`. Nombres largos y descriptivos son preferibles a nombres cortos y ambiguos.

### La Familia XCTAssert

XCTest proporciona multiples funciones de asercion, cada una para un caso especifico:

```swift
import XCTest

final class AsercionesTests: XCTestCase {

    // MARK: - Aserciones de igualdad
    func testAserciones() {
        // Igualdad
        XCTAssertEqual(2 + 2, 4)
        XCTAssertNotEqual(2 + 2, 5)

        // Booleanos
        XCTAssertTrue(5 > 3)
        XCTAssertFalse(3 > 5)

        // Nulabilidad
        let nombre: String? = "Jose"
        let apellido: String? = nil
        XCTAssertNotNil(nombre)
        XCTAssertNil(apellido)

        // Comparacion numerica con precision (para Double/Float)
        XCTAssertEqual(0.1 + 0.2, 0.3, accuracy: 0.0001)

        // Comparacion de orden
        XCTAssertGreaterThan(10, 5)
        XCTAssertLessThanOrEqual(5, 5)
    }

    // MARK: - Aserciones de errores
    func testDivisionPorCero() {
        let calc = Calculadora()

        // Verificar que SI lanza error
        XCTAssertThrowsError(try calc.dividir(10, 0)) { error in
            XCTAssertEqual(error as? CalculadoraError, .divisionPorCero)
        }

        // Verificar que NO lanza error
        XCTAssertNoThrow(try calc.dividir(10, 2))
    }

    // MARK: - XCTUnwrap — desempaquetar o fallar
    func testDesempaquetarOpcional() throws {
        let datos: [String: Any] = ["nombre": "Jose", "edad": 30]

        // XCTUnwrap lanza XCTSkip si el valor es nil
        let nombre = try XCTUnwrap(datos["nombre"] as? String)
        XCTAssertEqual(nombre, "Jose")

        let edad = try XCTUnwrap(datos["edad"] as? Int)
        XCTAssertEqual(edad, 30)
    }

    // MARK: - XCTFail — fallo incondicional
    func testCasoImposible() {
        let estado = "activo"
        switch estado {
        case "activo":
            break // OK
        case "inactivo":
            break // OK
        default:
            XCTFail("Estado desconocido: \(estado)")
        }
    }
}
```

### setUp y tearDown — Ciclo de Vida

El ciclo de vida de los tests es fundamental para escribir tests aislados y reproducibles:

```swift
import XCTest

final class CicloDeVidaTests: XCTestCase {

    // MARK: - Nivel de clase (una vez para TODOS los tests)

    override class func setUp() {
        super.setUp()
        print("1. setUpClass — Se ejecuta UNA VEZ antes de todos los tests")
        // Configuracion costosa: base de datos, servidor mock, etc.
    }

    override class func tearDown() {
        print("6. tearDownClass — Se ejecuta UNA VEZ despues de todos los tests")
        super.tearDown()
    }

    // MARK: - Nivel de instancia (una vez por CADA test)

    override func setUp() {
        super.setUp()
        print("2. setUp — Se ejecuta antes de CADA test")
    }

    override func tearDown() {
        print("5. tearDown — Se ejecuta despues de CADA test")
        super.tearDown()
    }

    // MARK: - setUp async (iOS 26+)
    override func setUp() async throws {
        try await super.setUp()
        // Preparar datos asincrono
    }

    // MARK: - addTeardownBlock — limpieza garantizada
    func testConLimpiezaGarantizada() {
        let recurso = RecursoTemporal()
        recurso.abrir()

        // Se ejecuta SIEMPRE, incluso si el test falla
        addTeardownBlock {
            recurso.cerrar()
        }

        XCTAssertTrue(recurso.estaAbierto)
    }
}

struct RecursoTemporal {
    private(set) var estaAbierto = false
    mutating func abrir() { estaAbierto = true }
    mutating func cerrar() { estaAbierto = false }
}
```

### Testing Async/Await

Con Swift moderno, los tests asincrono son naturales:

```swift
import XCTest

// MARK: - Servicio bajo test
protocol ServicioUsuarioProtocol {
    func obtenerUsuario(id: Int) async throws -> Usuario
    func guardarUsuario(_ usuario: Usuario) async throws
}

struct Usuario: Equatable, Codable {
    let id: Int
    let nombre: String
    let email: String
}

enum ServicioError: Error {
    case noEncontrado
    case sinConexion
    case datosInvalidos
}

// MARK: - Tests asincrono
final class ServicioUsuarioTests: XCTestCase {

    var servicio: MockServicioUsuario!

    override func setUp() {
        super.setUp()
        servicio = MockServicioUsuario()
    }

    // MARK: - async test — simplemente marca el metodo como async
    func testObtenerUsuarioExitoso() async throws {
        let usuarioEsperado = Usuario(id: 1, nombre: "Jose", email: "jose@email.com")
        servicio.usuarioARetornar = usuarioEsperado

        let resultado = try await servicio.obtenerUsuario(id: 1)

        XCTAssertEqual(resultado, usuarioEsperado)
        XCTAssertEqual(servicio.obtenerUsuarioLlamadoCon, 1)
    }

    func testObtenerUsuarioNoEncontrado() async {
        servicio.errorALanzar = ServicioError.noEncontrado

        do {
            _ = try await servicio.obtenerUsuario(id: 999)
            XCTFail("Deberia haber lanzado error")
        } catch {
            XCTAssertEqual(error as? ServicioError, .noEncontrado)
        }
    }

    // MARK: - XCTestExpectation — para callbacks legacy
    func testConCallback() {
        let expectation = expectation(description: "Callback recibido")

        funcionConCallback { resultado in
            XCTAssertEqual(resultado, "OK")
            expectation.fulfill()
        }

        // Esperar hasta 5 segundos
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Multiples expectations
    func testNotificacionesMultiples() {
        let exp1 = expectation(description: "Primera notificacion")
        let exp2 = expectation(description: "Segunda notificacion")

        // Simular dos notificaciones
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp1.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            exp2.fulfill()
        }

        wait(for: [exp1, exp2], timeout: 3.0, enforceOrder: true)
    }
}

func funcionConCallback(completion: @escaping (String) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        completion("OK")
    }
}
```

### Mocking con Protocolos — Aislar Dependencias

El mocking es la tecnica mas importante para escribir tests unitarios. La idea es reemplazar dependencias reales (red, base de datos, sensores) con objetos controlados:

```swift
import XCTest

// MARK: - Protocolo que define el contrato
protocol RepositorioProductos {
    func obtenerTodos() async throws -> [Producto]
    func guardar(_ producto: Producto) async throws
    func eliminar(id: String) async throws
}

struct Producto: Equatable, Identifiable {
    let id: String
    let nombre: String
    let precio: Double
}

// MARK: - Test Doubles

/// STUB — retorna valores predefinidos, no verifica interacciones
class StubRepositorioProductos: RepositorioProductos {
    var productosARetornar: [Producto] = []
    var errorALanzar: Error?

    func obtenerTodos() async throws -> [Producto] {
        if let error = errorALanzar { throw error }
        return productosARetornar
    }

    func guardar(_ producto: Producto) async throws {
        if let error = errorALanzar { throw error }
    }

    func eliminar(id: String) async throws {}
}

/// MOCK — verifica que se llamaron los metodos correctos
class MockRepositorioProductos: RepositorioProductos {
    var productosARetornar: [Producto] = []
    var errorALanzar: Error?

    // Registro de llamadas
    var obtenerTodosLlamado = false
    var guardarLlamadoCon: Producto?
    var eliminarLlamadoConId: String?
    var cantidadLlamadas = 0

    func obtenerTodos() async throws -> [Producto] {
        obtenerTodosLlamado = true
        cantidadLlamadas += 1
        if let error = errorALanzar { throw error }
        return productosARetornar
    }

    func guardar(_ producto: Producto) async throws {
        guardarLlamadoCon = producto
        cantidadLlamadas += 1
        if let error = errorALanzar { throw error }
    }

    func eliminar(id: String) async throws {
        eliminarLlamadoConId = id
        cantidadLlamadas += 1
        if let error = errorALanzar { throw error }
    }
}

/// SPY — registra TODAS las interacciones para verificacion posterior
class SpyRepositorioProductos: RepositorioProductos {
    enum Invocacion: Equatable {
        case obtenerTodos
        case guardar(Producto)
        case eliminar(id: String)
    }

    var invocaciones: [Invocacion] = []
    var productosARetornar: [Producto] = []

    func obtenerTodos() async throws -> [Producto] {
        invocaciones.append(.obtenerTodos)
        return productosARetornar
    }

    func guardar(_ producto: Producto) async throws {
        invocaciones.append(.guardar(producto))
    }

    func eliminar(id: String) async throws {
        invocaciones.append(.eliminar(id: id))
    }
}

// MARK: - ViewModel bajo test
@MainActor
class ProductosViewModel {
    private let repositorio: RepositorioProductos

    var productos: [Producto] = []
    var error: Error?
    var estaCargando = false

    init(repositorio: RepositorioProductos) {
        self.repositorio = repositorio
    }

    func cargarProductos() async {
        estaCargando = true
        do {
            productos = try await repositorio.obtenerTodos()
        } catch {
            self.error = error
        }
        estaCargando = false
    }

    func agregarProducto(_ producto: Producto) async {
        do {
            try await repositorio.guardar(producto)
            productos.append(producto)
        } catch {
            self.error = error
        }
    }
}

// MARK: - Tests del ViewModel
@MainActor
final class ProductosViewModelTests: XCTestCase {

    func testCargarProductosExitoso() async {
        // Arrange
        let mock = MockRepositorioProductos()
        let productosEsperados = [
            Producto(id: "1", nombre: "iPhone", precio: 999),
            Producto(id: "2", nombre: "MacBook", precio: 1999)
        ]
        mock.productosARetornar = productosEsperados

        let viewModel = ProductosViewModel(repositorio: mock)

        // Act
        await viewModel.cargarProductos()

        // Assert
        XCTAssertEqual(viewModel.productos, productosEsperados)
        XCTAssertTrue(mock.obtenerTodosLlamado)
        XCTAssertFalse(viewModel.estaCargando)
        XCTAssertNil(viewModel.error)
    }

    func testCargarProductosConError() async {
        let mock = MockRepositorioProductos()
        mock.errorALanzar = ServicioError.sinConexion

        let viewModel = ProductosViewModel(repositorio: mock)

        await viewModel.cargarProductos()

        XCTAssertTrue(viewModel.productos.isEmpty)
        XCTAssertNotNil(viewModel.error)
    }

    func testAgregarProductoRegistraInteraccion() async {
        let spy = SpyRepositorioProductos()
        let viewModel = ProductosViewModel(repositorio: spy)
        let producto = Producto(id: "3", nombre: "iPad", precio: 799)

        await viewModel.agregarProducto(producto)

        XCTAssertEqual(spy.invocaciones, [.guardar(producto)])
        XCTAssertEqual(viewModel.productos.count, 1)
    }
}
```

### Performance Testing

XCTest permite medir el rendimiento de codigo critico:

```swift
import XCTest

final class PerformanceTests: XCTestCase {

    // MARK: - measure basico
    func testRendimientoOrdenamiento() {
        let datos = (0..<10_000).map { _ in Int.random(in: 0...100_000) }

        measure {
            // Este bloque se ejecuta multiples veces
            // Xcode calcula promedio y desviacion estandar
            _ = datos.sorted()
        }
    }

    // MARK: - measure con opciones
    func testRendimientoConMetricas() {
        let opciones = XCTMeasureOptions()
        opciones.iterationCount = 10 // Numero de iteraciones

        measure(options: opciones) {
            // Operacion a medir
            var suma = 0
            for i in 0..<100_000 {
                suma += i
            }
            _ = suma
        }
    }

    // MARK: - measure con metricas especificas
    func testRendimientoMemoria() {
        measure(
            metrics: [
                XCTClockMetric(),          // Tiempo de reloj
                XCTMemoryMetric(),         // Uso de memoria
                XCTCPUMetric()             // Uso de CPU
            ]
        ) {
            // Operacion que puede consumir memoria
            var arrays: [[Int]] = []
            for _ in 0..<100 {
                arrays.append(Array(0..<1000))
            }
        }
    }

    // MARK: - Baseline de rendimiento
    func testRendimientoConBaseline() {
        // Xcode guarda el baseline despues de la primera ejecucion
        // Las ejecuciones siguientes comparan contra el baseline
        // Si el rendimiento degrada mas del 10%, el test falla
        measure {
            let texto = String(repeating: "a", count: 10_000)
            _ = texto.reversed()
        }
    }
}
```

### Code Coverage

La cobertura de codigo mide que porcentaje de tu codigo se ejecuta durante los tests:

```swift
// Para activar code coverage:
// 1. Edit Scheme > Test > Options > Code Coverage > marcar "Gather coverage"
// 2. O en Test Plan: Coverage > Enable Code Coverage

// MARK: - Ejemplo de cobertura completa
struct Validador {
    enum ResultadoValidacion {
        case valido
        case invalido(String)
    }

    func validarEmail(_ email: String) -> ResultadoValidacion {
        guard !email.isEmpty else {
            return .invalido("Email vacio")          // Linea 1
        }
        guard email.contains("@") else {
            return .invalido("Falta @")              // Linea 2
        }
        guard email.contains(".") else {
            return .invalido("Falta dominio")        // Linea 3
        }
        return .valido                               // Linea 4
    }
}

// Tests que cubren el 100%
final class ValidadorTests: XCTestCase {
    let validador = Validador()

    func testEmailVacio() {                             // Cubre linea 1
        let resultado = validador.validarEmail("")
        if case .invalido(let msg) = resultado {
            XCTAssertEqual(msg, "Email vacio")
        } else {
            XCTFail("Deberia ser invalido")
        }
    }

    func testEmailSinArroba() {                         // Cubre linea 2
        let resultado = validador.validarEmail("jose")
        if case .invalido(let msg) = resultado {
            XCTAssertEqual(msg, "Falta @")
        } else {
            XCTFail("Deberia ser invalido")
        }
    }

    func testEmailSinDominio() {                        // Cubre linea 3
        let resultado = validador.validarEmail("jose@")
        if case .invalido(let msg) = resultado {
            XCTAssertEqual(msg, "Falta dominio")
        } else {
            XCTFail("Deberia ser invalido")
        }
    }

    func testEmailValido() {                            // Cubre linea 4
        let resultado = validador.validarEmail("jose@email.com")
        if case .valido = resultado {
            // OK
        } else {
            XCTFail("Deberia ser valido")
        }
    }
}
```

---

## Ejercicios

### Ejercicio 1: Sistema de Autenticacion (Basico)

Crea tests para un `AuthManager` que maneja login/logout:

```swift
// Implementa AuthManager y sus tests
protocol AuthService {
    func login(email: String, password: String) async throws -> Token
    func logout() async throws
}

struct Token: Equatable {
    let valor: String
    let expira: Date
}

class AuthManager {
    private let servicio: AuthService
    private(set) var tokenActual: Token?
    var estaAutenticado: Bool { tokenActual != nil }

    init(servicio: AuthService) {
        self.servicio = servicio
    }

    func iniciarSesion(email: String, password: String) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.credencialesVacias
        }
        tokenActual = try await servicio.login(email: email, password: password)
    }

    func cerrarSesion() async throws {
        try await servicio.logout()
        tokenActual = nil
    }
}

enum AuthError: Error {
    case credencialesVacias
    case credencialesInvalidas
}

// TODO: Crea MockAuthService y escribe tests para:
// 1. Login exitoso guarda token
// 2. Login con credenciales vacias lanza error
// 3. Logout limpia token
// 4. estaAutenticado refleja estado correcto
```

### Ejercicio 2: Cache con Expiracion (Intermedio)

Implementa y testea un cache generico con TTL (time-to-live):

```swift
// Implementa y testea
class Cache<Key: Hashable, Value> {
    struct Entrada {
        let valor: Value
        let expira: Date
    }

    private var almacen: [Key: Entrada] = []
    private let ttl: TimeInterval

    init(ttl: TimeInterval = 300) { // 5 minutos por defecto
        self.ttl = ttl
    }

    func guardar(_ valor: Value, para clave: Key) {
        almacen[clave] = Entrada(valor: valor, expira: Date().addingTimeInterval(ttl))
    }

    func obtener(_ clave: Key) -> Value? {
        guard let entrada = almacen[clave] else { return nil }
        guard entrada.expira > Date() else {
            almacen.removeValue(forKey: clave)
            return nil
        }
        return entrada.valor
    }

    func limpiarExpirados() {
        let ahora = Date()
        almacen = almacen.filter { $0.value.expira > ahora }
    }

    var cantidad: Int { almacen.count }
}

// TODO: Escribe tests para:
// 1. Guardar y obtener valor
// 2. Valor expirado retorna nil
// 3. limpiarExpirados elimina entradas vencidas
// 4. Cache con TTL personalizado
// 5. Performance test con 10,000 entradas
```

### Ejercicio 3: Pipeline de Datos (Avanzado)

Testea un pipeline asincrono completo con multiples dependencias:

```swift
// Implementa tests completos para este pipeline
protocol DataFetcher {
    func fetch(url: URL) async throws -> Data
}

protocol DataParser {
    func parse<T: Decodable>(_ data: Data, as type: T.Type) throws -> T
}

protocol DataCache {
    func get(key: String) async -> Data?
    func set(key: String, data: Data) async
}

class DataPipeline {
    private let fetcher: DataFetcher
    private let parser: DataParser
    private let cache: DataCache

    init(fetcher: DataFetcher, parser: DataParser, cache: DataCache) {
        self.fetcher = fetcher
        self.parser = parser
        self.cache = cache
    }

    func load<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
        let cacheKey = url.absoluteString

        // Intentar cache primero
        if let cached = await cache.get(key: cacheKey) {
            return try parser.parse(cached, as: type)
        }

        // Fetch de red
        let data = try await fetcher.fetch(url: url)

        // Guardar en cache
        await cache.set(key: cacheKey, data: data)

        // Parsear y retornar
        return try parser.parse(data, as: type)
    }
}

// TODO: Crea mocks para los 3 protocolos y testea:
// 1. Carga desde red cuando cache esta vacia
// 2. Carga desde cache cuando hay datos cacheados
// 3. Error de red se propaga correctamente
// 4. Error de parseo se propaga correctamente
// 5. Los datos se cachean despues de fetch exitoso
// 6. Verificar orden de llamadas con Spy
```

---

## 5 Errores Comunes

### Error 1: Tests que dependen del orden de ejecucion

```swift
// MAL — un test depende del estado dejado por otro
class MalTests: XCTestCase {
    static var contador = 0

    func testA_Incrementar() {
        MalTests.contador += 1
        XCTAssertEqual(MalTests.contador, 1) // Funciona si se ejecuta primero
    }

    func testB_Verificar() {
        XCTAssertEqual(MalTests.contador, 1) // Falla si testA no se ejecuto antes
    }
}

// BIEN — cada test es independiente
class BienTests: XCTestCase {
    var contador = 0

    override func setUp() {
        super.setUp()
        contador = 0 // Estado limpio en cada test
    }

    func testIncrementar() {
        contador += 1
        XCTAssertEqual(contador, 1)
    }
}
```

### Error 2: Testear implementacion en lugar de comportamiento

```swift
// MAL — testea COMO se implementa (fragil)
func testMal() {
    let vm = ProductosViewModel(repositorio: mock)
    // Verificar que internamente usa un array
    // Verificar que llama a un metodo privado especifico
}

// BIEN — testea QUE hace (robusto)
func testBien() async {
    let mock = MockRepositorioProductos()
    mock.productosARetornar = [Producto(id: "1", nombre: "Test", precio: 10)]
    let vm = ProductosViewModel(repositorio: mock)

    await vm.cargarProductos()

    XCTAssertEqual(vm.productos.count, 1) // Comportamiento observable
}
```

### Error 3: Tests sin mensajes descriptivos

```swift
// MAL — cuando falla no sabes por que
XCTAssertEqual(resultado, 42)

// BIEN — el mensaje explica la intencion
XCTAssertEqual(resultado, 42, "El descuento del 10% sobre 46.67 deberia dar 42")
```

### Error 4: No testear los casos de error

```swift
// MAL — solo testea el happy path
func testLogin() async throws {
    let token = try await servicio.login(email: "test@test.com", password: "123")
    XCTAssertNotNil(token)
}

// BIEN — testea happy path Y error paths
func testLoginExitoso() async throws {
    let token = try await servicio.login(email: "test@test.com", password: "123")
    XCTAssertNotNil(token)
}

func testLoginEmailVacio() async {
    do {
        _ = try await servicio.login(email: "", password: "123")
        XCTFail("Deberia lanzar error")
    } catch {
        XCTAssertEqual(error as? AuthError, .credencialesVacias)
    }
}

func testLoginSinConexion() async {
    mock.errorALanzar = ServicioError.sinConexion
    do {
        _ = try await servicio.login(email: "test@test.com", password: "123")
        XCTFail("Deberia lanzar error de conexion")
    } catch {
        XCTAssertEqual(error as? ServicioError, .sinConexion)
    }
}
```

### Error 5: Tests lentos por dependencias reales

```swift
// MAL — usa red real, es lento y no determinista
func testMal() async throws {
    let servicio = ServicioRealHTTP()
    let usuario = try await servicio.obtenerUsuario(id: 1) // 200ms-2s
    XCTAssertNotNil(usuario)
}

// BIEN — usa mock, es rapido y determinista
func testBien() async throws {
    let mock = MockServicioUsuario()
    mock.usuarioARetornar = Usuario(id: 1, nombre: "Test", email: "t@t.com")
    let usuario = try await mock.obtenerUsuario(id: 1) // <1ms
    XCTAssertEqual(usuario.nombre, "Test")
}
```

---

## Checklist de la Leccion

- [ ] Se por que los tests automatizados son necesarios
- [ ] Puedo crear una clase `XCTestCase` con metodos de test
- [ ] Conozco la familia completa de `XCTAssert` y cuando usar cada uno
- [ ] Entiendo el ciclo de vida `setUp/tearDown` a nivel de clase e instancia
- [ ] Puedo escribir tests asincrono con `async/await`
- [ ] Se usar `XCTestExpectation` para callbacks legacy
- [ ] Puedo crear test doubles: stub, mock, spy y fake
- [ ] Entiendo Arrange-Act-Assert como estructura de cada test
- [ ] Puedo medir rendimiento con `measure {}` y metricas
- [ ] Se como activar y leer el reporte de code coverage
- [ ] Mis tests son independientes, rapidos y deterministas

---

## Notas Personales

```
Fecha inicio:
Fecha completado:
Dificultad (1-5):
Conceptos que necesito repasar:
Dudas pendientes:
```

---

## Conexion Proyecto Integrador

En el Proyecto Integrador, aplica XCTest para:

1. **Capa de datos**: Testea los repositorios con mocks del servicio de red y SwiftData
2. **ViewModels**: Verifica que cada ViewModel maneja correctamente los estados (cargando, exito, error)
3. **Validaciones**: Testea toda la logica de validacion de formularios con multiples casos
4. **Performance**: Usa `measure {}` para verificar que las operaciones criticas no degradan
5. **Cobertura**: Apunta a 80%+ de cobertura en la capa de logica de negocio

> **Nota**: En la siguiente leccion (35) veremos Swift Testing, el framework moderno que complementa XCTest con una sintaxis mas expresiva.
