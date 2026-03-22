# Leccion 35: Swift Testing — El Framework Moderno de Testing

**Modulo 09: Testing y Calidad** | Semana 45

---

## TL;DR — Resumen en 2 minutos

- **Swift Testing** es el framework moderno de Apple con `@Test` y `#expect` — mas expresivo que XCTest
- **`#expect`** reemplaza toda la familia XCTAssert con una sola macro que muestra valores automaticamente
- **Parameterized tests** ejecutan el mismo test con multiples inputs — eliminan duplicacion masiva
- **Tags y traits** organizan y configuran tests — `.disabled`, `.bug`, `.timeLimit`, `.enabled(if:)`
- **Ejecucion paralela** por defecto — tests mas rapidos, pero requieren aislamiento real

> Herramienta: **Xcode 26** soporta Swift Testing y XCTest en el mismo proyecto simultaneamente

---

## Cupertino MCP

```bash
cupertino search "Swift Testing"
cupertino search "Swift Testing @Test"
cupertino search --source apple-docs "expect macro testing"
cupertino search "Swift Testing Suite"
cupertino search "Swift Testing traits"
cupertino search "Swift Testing parameterized"
cupertino search "Swift Testing confirmation"
cupertino search "Swift Testing tags"
cupertino search --source updates "Swift Testing 2025"
cupertino search "migrate XCTest Swift Testing"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Swift Testing | Novedades Swift Testing en Xcode 26 |
| WWDC24 | [Meet Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10179/) | **Esencial** — introduccion completa |
| WWDC24 | [Go further with Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10195/) | Traits, parametrizacion, migracion |
| EN | [Paul Hudson — Swift Testing](https://www.hackingwithswift.com) | Tutorial practico |
| EN | [Sean Allen — Swift Testing](https://www.youtube.com/@seanallen) | Comparativa con XCTest |
| EN | [Vincent Pradeilles — Testing](https://www.youtube.com/@v_pradeilles) | Tips avanzados |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Swift Testing?

XCTest tiene 10+ anos. Funciona, pero carga con decisiones de diseno de la era Objective-C: herencia obligatoria de `XCTestCase`, prefijo `test` en nombres, multiples funciones `XCTAssert*` sin contexto automatico de fallo. Swift Testing nace como un framework Swift-native, disenado desde cero para aprovechar macros, concurrencia moderna y el sistema de tipos de Swift.

La diferencia mas inmediata: cuando un `#expect` falla, te muestra automaticamente los valores de ambos lados de la comparacion. Con `XCTAssertEqual` necesitabas agregar un mensaje manual para tener esa informacion. Esto solo ya justifica la migracion.

Swift Testing coexiste perfectamente con XCTest. No necesitas migrar todo de golpe. Puedes escribir tests nuevos con Swift Testing y migrar los existentes gradualmente.

### @Test — La Base de Todo

```swift
import Testing

// MARK: - Test basico — no necesita clase ni herencia
@Test("La suma de dos positivos es correcta")
func sumaPositivos() {
    let resultado = 3 + 5
    #expect(resultado == 8)
}

// MARK: - @Test con nombre descriptivo
@Test("El email vacio no es valido")
func emailVacioInvalido() {
    let validador = ValidadorEmail()
    let resultado = validador.esValido("")
    #expect(resultado == false)
}

// MARK: - Modelo de ejemplo
struct ValidadorEmail {
    func esValido(_ email: String) -> Bool {
        !email.isEmpty && email.contains("@") && email.contains(".")
    }
}
```

A diferencia de XCTest, no necesitas una clase, no necesitas herencia, y el nombre del test lo defines tu con un string descriptivo en lugar de depender del nombre del metodo.

### #expect vs XCTAssert — Una Macro para Todo

```swift
import Testing

@Test("Familia completa de expect")
func demoExpect() {
    // MARK: - Igualdad (reemplaza XCTAssertEqual)
    #expect(2 + 2 == 4)
    #expect("hola".count == 4)

    // MARK: - Desigualdad (reemplaza XCTAssertNotEqual)
    #expect(2 + 2 != 5)

    // MARK: - Booleanos (reemplaza XCTAssertTrue/False)
    #expect(5 > 3)
    #expect(![false, false].contains(true))

    // MARK: - Opcionales (reemplaza XCTAssertNil/NotNil)
    let nombre: String? = "Jose"
    #expect(nombre != nil)

    let apellido: String? = nil
    #expect(apellido == nil)

    // MARK: - Comparaciones (reemplaza XCTAssertGreaterThan, etc.)
    #expect(10 > 5)
    #expect(5 <= 5)
    #expect(3 >= 3)
}

// MARK: - #expect con throws (reemplaza XCTAssertThrowsError)
@Test("Division por cero lanza error")
func divisionPorCero() throws {
    let calc = Calculadora()

    #expect(throws: CalculadoraError.divisionPorCero) {
        try calc.dividir(10, entre: 0)
    }
}

// MARK: - #expect throws con verificacion del error
@Test("Error de validacion tiene mensaje correcto")
func errorValidacion() throws {
    #expect {
        try validar(email: "")
    } throws: { error in
        // Verificacion personalizada del error
        guard let validacionError = error as? ValidacionError else {
            return false
        }
        return validacionError.campo == "email"
    }
}

// MARK: - #require — falla el test si la condicion no se cumple
@Test("Desempaquetar opcional obligatorio")
func desempaquetarOpcional() throws {
    let datos: [String: Any] = ["nombre": "Jose", "edad": 30]

    // #require es como XCTUnwrap — si falla, detiene el test
    let nombre = try #require(datos["nombre"] as? String)
    #expect(nombre == "Jose")

    let edad = try #require(datos["edad"] as? Int)
    #expect(edad == 30)

    // Si el valor no existe, el test se detiene aqui
    // No ejecuta las lineas siguientes
}

struct Calculadora {
    func dividir(_ a: Double, entre b: Double) throws -> Double {
        guard b != 0 else { throw CalculadoraError.divisionPorCero }
        return a / b
    }
}

enum CalculadoraError: Error { case divisionPorCero }

struct ValidacionError: Error {
    let campo: String
    let mensaje: String
}

func validar(email: String) throws {
    guard !email.isEmpty else {
        throw ValidacionError(campo: "email", mensaje: "No puede estar vacio")
    }
}
```

La ventaja clave de `#expect`: cuando falla, la macro automaticamente captura y muestra los valores de las expresiones. No necesitas un tercer argumento de mensaje para saber que paso.

### @Suite — Organizar Tests

```swift
import Testing

// MARK: - Suite agrupa tests relacionados
@Suite("Validador de Formularios")
struct ValidadorFormularioTests {
    let validador = ValidadorFormulario()

    // MARK: - Suite anidada para email
    @Suite("Validacion de Email")
    struct EmailTests {
        let validador = ValidadorFormulario()

        @Test("Email valido pasa validacion")
        func emailValido() {
            #expect(validador.validarEmail("jose@email.com") == true)
        }

        @Test("Email sin arroba falla")
        func emailSinArroba() {
            #expect(validador.validarEmail("joseemail.com") == false)
        }

        @Test("Email vacio falla")
        func emailVacio() {
            #expect(validador.validarEmail("") == false)
        }
    }

    // MARK: - Suite anidada para password
    @Suite("Validacion de Password")
    struct PasswordTests {
        let validador = ValidadorFormulario()

        @Test("Password con 8+ caracteres es valida")
        func passwordLarga() {
            #expect(validador.validarPassword("MiClave123!") == true)
        }

        @Test("Password con menos de 8 caracteres falla")
        func passwordCorta() {
            #expect(validador.validarPassword("abc") == false)
        }
    }
}

struct ValidadorFormulario {
    func validarEmail(_ email: String) -> Bool {
        !email.isEmpty && email.contains("@") && email.contains(".")
    }

    func validarPassword(_ password: String) -> Bool {
        password.count >= 8
    }
}
```

Los `@Suite` pueden ser `struct` (recomendado) o `class`. Usa `struct` porque cada test obtiene una copia independiente — aislamiento natural sin `setUp/tearDown`.

### Traits — Configurar Comportamiento

```swift
import Testing

// MARK: - .disabled — desactivar temporalmente
@Test("Feature en desarrollo", .disabled("Esperando API v2"))
func featureEnDesarrollo() {
    // Este test no se ejecuta pero aparece en el reporte
}

// MARK: - .bug — asociar con bug tracker
@Test("Crash al cargar imagen grande", .bug("https://jira.com/PROJ-123", "OOM con imagenes >50MB"))
func crashImagenGrande() {
    // Test asociado a un bug conocido
    #expect(true)
}

// MARK: - .timeLimit — limite de tiempo
@Test("Operacion debe completar en 2 segundos", .timeLimit(.seconds(2)))
func operacionRapida() async {
    // Si tarda mas de 2 segundos, el test falla automaticamente
    let resultado = await operacionCostosa()
    #expect(resultado != nil)
}

// MARK: - .enabled(if:) — ejecucion condicional
@Test("Solo en iOS", .enabled(if: plataformaActual == .iOS))
func soloIOS() {
    #expect(true)
}

// MARK: - .serialized — forzar ejecucion secuencial
@Suite("Tests que modifican estado compartido", .serialized)
struct TestsSecuenciales {
    @Test func paso1() { /* ... */ }
    @Test func paso2() { /* ... */ }
    @Test func paso3() { /* ... */ }
}

// MARK: - Combinar multiples traits
@Test(
    "Feature critica con restricciones",
    .bug("https://jira.com/PROJ-456"),
    .timeLimit(.seconds(5)),
    .tags(.critico)
)
func featureCritica() async {
    #expect(true)
}

func operacionCostosa() async -> String? {
    try? await Task.sleep(for: .milliseconds(100))
    return "resultado"
}

let plataformaActual = Plataforma.iOS
enum Plataforma { case iOS, macOS, watchOS }
```

### Parameterized Tests — Eliminar Duplicacion

Esta es la funcionalidad mas poderosa de Swift Testing. En lugar de escribir 10 tests casi identicos, escribes uno parametrizado:

```swift
import Testing

// MARK: - Parametrizacion basica con coleccion
@Test("Numeros pares son divisibles entre 2", arguments: [2, 4, 6, 8, 10, 100, 1000])
func esPar(numero: Int) {
    #expect(numero % 2 == 0)
}

// MARK: - Parametrizacion con enum
enum MonedaSoportada: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case mxn = "MXN"
}

@Test("Todas las monedas tienen codigo de 3 letras", arguments: MonedaSoportada.allCases)
func codigoMoneda(moneda: MonedaSoportada) {
    #expect(moneda.rawValue.count == 3)
}

// MARK: - Parametrizacion con tuplas para input/output
@Test("Conversion de temperatura", arguments: [
    (celsius: 0.0, fahrenheit: 32.0),
    (celsius: 100.0, fahrenheit: 212.0),
    (celsius: -40.0, fahrenheit: -40.0),
    (celsius: 37.0, fahrenheit: 98.6)
])
func conversionTemperatura(celsius: Double, fahrenheit: Double) {
    let resultado = celsius * 9/5 + 32
    #expect(abs(resultado - fahrenheit) < 0.1)
}

// MARK: - Parametrizacion con dos colecciones (producto cartesiano)
@Test("Multiplicacion de signos", arguments: [-3, -1, 0, 1, 3], [-2, -1, 0, 1, 2])
func multiplicacionSignos(a: Int, b: Int) {
    let resultado = a * b
    if a > 0 && b > 0 {
        #expect(resultado > 0)
    } else if a < 0 && b < 0 {
        #expect(resultado > 0)
    } else if a == 0 || b == 0 {
        #expect(resultado == 0)
    } else {
        #expect(resultado < 0)
    }
}

// MARK: - Caso real: validacion de emails
struct CasoEmail: CustomTestStringConvertible {
    let email: String
    let esValido: Bool
    let razon: String

    // Para que los tests muestren nombres legibles
    var testDescription: String { "\(email) -> \(esValido ? "valido" : "invalido")" }
}

let casosEmail: [CasoEmail] = [
    CasoEmail(email: "jose@email.com", esValido: true, razon: "formato correcto"),
    CasoEmail(email: "jose@email", esValido: false, razon: "sin dominio"),
    CasoEmail(email: "", esValido: false, razon: "vacio"),
    CasoEmail(email: "jose", esValido: false, razon: "sin arroba"),
    CasoEmail(email: "@email.com", esValido: false, razon: "sin usuario"),
    CasoEmail(email: "a@b.c", esValido: true, razon: "formato minimo valido"),
]

@Test("Validacion de email", arguments: casosEmail)
func validacionEmail(caso: CasoEmail) {
    let validador = ValidadorEmail()
    #expect(validador.esValido(caso.email) == caso.esValido)
}

struct ValidadorEmail {
    func esValido(_ email: String) -> Bool {
        !email.isEmpty && email.contains("@") && email.contains(".")
    }
}
```

### Tags — Organizar por Categoria

```swift
import Testing

// MARK: - Definir tags personalizados
extension Tag {
    @Tag static var critico: Self
    @Tag static var integracion: Self
    @Tag static var lento: Self
    @Tag static var regresion: Self
    @Tag static var ui: Self
}

// MARK: - Usar tags en tests
@Test("Login exitoso", .tags(.critico))
func loginExitoso() async {
    #expect(true)
}

@Test("Sincronizacion con servidor", .tags(.integracion, .lento))
func sincronizacion() async {
    #expect(true)
}

@Test("Regression: crash al rotar pantalla", .tags(.regresion, .ui))
func regressionRotacion() {
    #expect(true)
}

// MARK: - Tags a nivel de Suite
@Suite("Tests criticos del carrito", .tags(.critico))
struct CarritoTests {
    @Test func agregarProducto() { #expect(true) }
    @Test func eliminarProducto() { #expect(true) }
    @Test func calcularTotal() { #expect(true) }
}

// En Xcode, puedes filtrar tests por tag:
// Test Plan > Configuration > Tags > Include/Exclude
```

### Confirmation — Verificar Eventos Asincrono

```swift
import Testing

// MARK: - confirmation reemplaza XCTestExpectation
@Test("El delegado recibe notificacion de completado")
func delegadoNotificado() async {
    // confirmation espera que se llame exactamente 1 vez
    await confirmation("delegado notificado") { confirm in
        let gestor = GestorDescarga()
        gestor.alCompletar = {
            confirm() // Equivalente a expectation.fulfill()
        }
        await gestor.iniciarDescarga()
    }
}

// MARK: - confirmation con count para multiples eventos
@Test("Se procesan exactamente 3 items")
func procesarMultiplesItems() async {
    await confirmation("item procesado", expectedCount: 3) { confirm in
        let procesador = ProcesadorBatch()
        procesador.alProcesarItem = { _ in
            confirm()
        }
        await procesador.procesar(items: ["A", "B", "C"])
    }
}

// MARK: - Modelos de soporte
class GestorDescarga {
    var alCompletar: (() -> Void)?

    func iniciarDescarga() async {
        // Simular descarga
        try? await Task.sleep(for: .milliseconds(50))
        alCompletar?()
    }
}

class ProcesadorBatch {
    var alProcesarItem: ((String) -> Void)?

    func procesar(items: [String]) async {
        for item in items {
            try? await Task.sleep(for: .milliseconds(10))
            alProcesarItem?(item)
        }
    }
}
```

### Migracion de XCTest a Swift Testing

```swift
// ============================================
// ANTES: XCTest
// ============================================
import XCTest

final class UsuarioXCTests: XCTestCase {
    var servicio: MockServicio!

    override func setUp() {
        super.setUp()
        servicio = MockServicio()
    }

    override func tearDown() {
        servicio = nil
        super.tearDown()
    }

    func testCrearUsuarioExitoso() async throws {
        let usuario = try await servicio.crear(nombre: "Jose")
        XCTAssertEqual(usuario.nombre, "Jose")
        XCTAssertNotNil(usuario.id)
    }

    func testCrearUsuarioNombreVacio() async {
        do {
            _ = try await servicio.crear(nombre: "")
            XCTFail("Deberia lanzar error")
        } catch {
            XCTAssertEqual(error as? ServError, .nombreVacio)
        }
    }

    func testNombresValidos() {
        // Repetir test para cada nombre... tedioso
        XCTAssertTrue(servicio.esNombreValido("Jose"))
        XCTAssertTrue(servicio.esNombreValido("Maria"))
        XCTAssertFalse(servicio.esNombreValido(""))
        XCTAssertFalse(servicio.esNombreValido("A"))
    }
}

// ============================================
// DESPUES: Swift Testing
// ============================================
import Testing

@Suite("Gestion de Usuarios")
struct UsuarioSwiftTests {
    // struct proporciona aislamiento natural
    // No necesita setUp/tearDown
    let servicio = MockServicio()

    @Test("Crear usuario con nombre valido")
    func crearUsuarioExitoso() async throws {
        let usuario = try await servicio.crear(nombre: "Jose")
        #expect(usuario.nombre == "Jose")
        #expect(usuario.id != nil)
    }

    @Test("Crear usuario con nombre vacio lanza error")
    func crearUsuarioNombreVacio() async throws {
        #expect(throws: ServError.nombreVacio) {
            try await servicio.crear(nombre: "")
        }
    }

    // Parametrizado reemplaza multiples asserts
    @Test("Nombres validos e invalidos", arguments: [
        ("Jose", true),
        ("Maria", true),
        ("", false),
        ("A", false)
    ])
    func validarNombre(nombre: String, esValido: Bool) {
        #expect(servicio.esNombreValido(nombre) == esValido)
    }
}

// MARK: - Modelos compartidos
struct UsuarioModelo: Identifiable {
    let id: String?
    let nombre: String
}

enum ServError: Error { case nombreVacio }

class MockServicio {
    func crear(nombre: String) async throws -> UsuarioModelo {
        guard !nombre.isEmpty else { throw ServError.nombreVacio }
        return UsuarioModelo(id: "uuid-\(nombre)", nombre: nombre)
    }

    func esNombreValido(_ nombre: String) -> Bool {
        nombre.count >= 2
    }
}
```

### Ejecucion Paralela

Swift Testing ejecuta tests en paralelo por defecto. Esto es mas rapido pero requiere que cada test sea verdaderamente independiente:

```swift
import Testing

// MARK: - Tests paralelos (por defecto)
@Suite("Tests independientes — se ejecutan en paralelo")
struct TestsParalelos {
    @Test func operacion1() async {
        try? await Task.sleep(for: .seconds(1))
        #expect(true)
    }

    @Test func operacion2() async {
        try? await Task.sleep(for: .seconds(1))
        #expect(true)
    }

    // Ambos tardan ~1 segundo en total, no 2
}

// MARK: - Forzar ejecucion secuencial cuando es necesario
@Suite("Tests que necesitan orden", .serialized)
struct TestsSecuenciales {
    @Test func paso1() async {
        // Se ejecuta primero
        #expect(true)
    }

    @Test func paso2() async {
        // Se ejecuta despues de paso1
        #expect(true)
    }
}
```

---

## Ejercicios

### Ejercicio 1: Carrito de Compras (Basico)

Usa Swift Testing para testear un carrito de compras:

```swift
import Testing

struct ProductoCarrito: Equatable {
    let id: String
    let nombre: String
    let precio: Double
}

struct Carrito {
    private(set) var items: [(producto: ProductoCarrito, cantidad: Int)] = []

    var total: Double {
        items.reduce(0) { $0 + $1.producto.precio * Double($1.cantidad) }
    }

    var cantidadItems: Int {
        items.reduce(0) { $0 + $1.cantidad }
    }

    mutating func agregar(_ producto: ProductoCarrito, cantidad: Int = 1) {
        if let index = items.firstIndex(where: { $0.producto == producto }) {
            items[index].cantidad += cantidad
        } else {
            items.append((producto, cantidad))
        }
    }

    mutating func eliminar(_ producto: ProductoCarrito) {
        items.removeAll { $0.producto == producto }
    }

    mutating func vaciar() {
        items.removeAll()
    }
}

// TODO: Escribe tests con @Test y #expect para:
// 1. Agregar producto al carrito
// 2. Agregar mismo producto incrementa cantidad
// 3. Calcular total correctamente
// 4. Eliminar producto
// 5. Vaciar carrito
// Usa @Suite para organizar y parametrized tests donde sea apropiado
```

### Ejercicio 2: Conversor de Monedas Parametrizado (Intermedio)

Usa parameterized tests para testear un conversor de monedas:

```swift
import Testing

struct TasaCambio {
    let origen: String
    let destino: String
    let tasa: Double
}

class ConversorMonedas {
    private var tasas: [String: [String: Double]] = [
        "USD": ["EUR": 0.92, "GBP": 0.79, "MXN": 17.15, "JPY": 149.50],
        "EUR": ["USD": 1.09, "GBP": 0.86, "MXN": 18.65, "JPY": 162.50]
    ]

    func convertir(monto: Double, de origen: String, a destino: String) throws -> Double {
        guard monto >= 0 else { throw ConversorError.montoNegativo }
        guard origen != destino else { return monto }
        guard let tasaOrigen = tasas[origen],
              let tasa = tasaOrigen[destino] else {
            throw ConversorError.tasaNoDisponible
        }
        return (monto * tasa * 100).rounded() / 100
    }
}

enum ConversorError: Error {
    case montoNegativo
    case tasaNoDisponible
}

// TODO: Escribe tests parametrizados para:
// 1. Conversiones validas con multiples monedas y montos
// 2. Conversion a misma moneda retorna mismo monto
// 3. Monto negativo lanza error (parametrizado con varios montos negativos)
// 4. Moneda no soportada lanza error
// 5. Usa Tags para categorizar (.critico, .regresion)
// 6. Usa CustomTestStringConvertible para nombres legibles
```

### Ejercicio 3: Sistema de Notificaciones con Confirmation (Avanzado)

Testea un sistema de notificaciones completo usando `confirmation`:

```swift
import Testing

enum TipoNotificacion: Sendable {
    case push(titulo: String, mensaje: String)
    case email(destinatario: String, asunto: String)
    case sms(numero: String, texto: String)
}

protocol CanalNotificacion: Sendable {
    func enviar(_ notificacion: TipoNotificacion) async throws
}

class SistemaNotificaciones {
    private let canales: [CanalNotificacion]
    var alEnviar: ((TipoNotificacion) -> Void)?
    var alFallar: ((Error) -> Void)?

    init(canales: [CanalNotificacion]) {
        self.canales = canales
    }

    func notificar(_ tipo: TipoNotificacion) async {
        for canal in canales {
            do {
                try await canal.enviar(tipo)
                alEnviar?(tipo)
            } catch {
                alFallar?(error)
            }
        }
    }

    func notificarTodos(_ tipos: [TipoNotificacion]) async {
        for tipo in tipos {
            await notificar(tipo)
        }
    }
}

// TODO: Escribe tests con confirmation para:
// 1. Enviar 1 notificacion a 1 canal llama alEnviar exactamente 1 vez
// 2. Enviar 1 notificacion a 3 canales llama alEnviar 3 veces
// 3. Canal que falla llama alFallar
// 4. notificarTodos con 3 tipos llama alEnviar el numero correcto de veces
// 5. Usa @Suite con .serialized donde sea necesario
// 6. Combina traits: .timeLimit, .tags
```

---

## 5 Errores Comunes

### Error 1: Usar XCTAssert en lugar de #expect

```swift
// MAL — mezclar frameworks sin razon
import Testing
import XCTest

@Test func mezcla() {
    XCTAssertEqual(2 + 2, 4) // NO — esto es XCTest dentro de Swift Testing
}

// BIEN — usar #expect consistentemente
import Testing

@Test func correcto() {
    #expect(2 + 2 == 4)
}
```

### Error 2: No usar #require para dependencias criticas

```swift
// MAL — el test continua con nil y da errores confusos
@Test func sinRequire() {
    let datos: [String: Any] = ["nombre": "Jose"]
    let nombre = datos["nombre"] as? String
    #expect(nombre == "Jose") // Funciona, pero si fuera nil el mensaje es confuso
    // ... 20 lineas mas que dependen de nombre
}

// BIEN — #require detiene el test inmediatamente si falla
@Test func conRequire() throws {
    let datos: [String: Any] = ["nombre": "Jose"]
    let nombre = try #require(datos["nombre"] as? String)
    #expect(nombre == "Jose")
    // Si nombre fuera nil, el test se detiene aqui con mensaje claro
}
```

### Error 3: Estado compartido en tests paralelos

```swift
// MAL — estado mutable compartido en paralelo
@Suite("Tests con estado compartido")
struct TestsMal {
    static var contador = 0 // PELIGRO: estado compartido

    @Test func incrementar() {
        TestsMal.contador += 1 // Data race!
        #expect(TestsMal.contador == 1)
    }

    @Test func verificar() {
        #expect(TestsMal.contador == 0) // Resultado impredecible
    }
}

// BIEN — cada test tiene su propio estado
@Suite("Tests con estado aislado")
struct TestsBien {
    @Test func incrementar() {
        var contador = 0 // Estado local
        contador += 1
        #expect(contador == 1)
    }

    @Test func verificar() {
        let contador = 0
        #expect(contador == 0)
    }
}
```

### Error 4: No usar parametrizacion cuando hay patrones repetitivos

```swift
// MAL — copiar/pegar tests con valores diferentes
@Test func emailValidoConPunto() {
    #expect(validar("jose@email.com") == true)
}
@Test func emailValidoConSubdominio() {
    #expect(validar("jose@sub.email.com") == true)
}
@Test func emailInvalidoSinArroba() {
    #expect(validar("joseemail.com") == false)
}
@Test func emailInvalidoVacio() {
    #expect(validar("") == false)
}

// BIEN — un solo test parametrizado
@Test("Validacion de email", arguments: [
    ("jose@email.com", true),
    ("jose@sub.email.com", true),
    ("joseemail.com", false),
    ("", false)
])
func emailValido(email: String, esperado: Bool) {
    #expect(validar(email) == esperado)
}

func validar(_ email: String) -> Bool {
    !email.isEmpty && email.contains("@")
}
```

### Error 5: Olvidar .serialized cuando los tests no son independientes

```swift
// MAL — tests que dependen de orden pero se ejecutan en paralelo
@Suite("Flujo de usuario")
struct FlujoMal {
    let db = BaseDatosTest.compartida

    @Test func paso1_crear() async {
        await db.insertar("usuario1")  // Puede ejecutarse despues de paso2
    }

    @Test func paso2_verificar() async {
        let existe = await db.existe("usuario1")  // Resultado impredecible
        #expect(existe)
    }
}

// BIEN — forzar orden con .serialized
@Suite("Flujo de usuario", .serialized)
struct FlujoBien {
    let db = BaseDatosTest.compartida

    @Test func paso1_crear() async {
        await db.insertar("usuario1")
    }

    @Test func paso2_verificar() async {
        let existe = await db.existe("usuario1")
        #expect(existe)
    }
}

class BaseDatosTest: @unchecked Sendable {
    static let compartida = BaseDatosTest()
    private var datos: Set<String> = []

    func insertar(_ item: String) async { datos.insert(item) }
    func existe(_ item: String) async -> Bool { datos.contains(item) }
}
```

---

## Checklist de la Leccion

- [ ] Puedo crear tests con `@Test` y `#expect` sin necesitar herencia
- [ ] Entiendo la diferencia entre `#expect` y `#require`
- [ ] Se organizar tests con `@Suite` y suites anidados
- [ ] Puedo configurar tests con traits: `.disabled`, `.bug`, `.timeLimit`, `.enabled(if:)`
- [ ] Domino parameterized tests para eliminar duplicacion
- [ ] Se usar `Tags` para categorizar y filtrar tests
- [ ] Puedo verificar eventos asincrono con `confirmation`
- [ ] Entiendo que la ejecucion es paralela por defecto y cuando usar `.serialized`
- [ ] Se migrar tests de XCTest a Swift Testing gradualmente
- [ ] Puedo implementar `CustomTestStringConvertible` para nombres legibles
- [ ] Entiendo cuando usar Swift Testing vs XCTest (UI tests siguen en XCTest)

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

En el Proyecto Integrador, aplica Swift Testing para:

1. **Tests nuevos**: Escribe todos los tests nuevos con `@Test` y `#expect` en lugar de XCTest
2. **Validaciones parametrizadas**: Usa parameterized tests para todos los validadores de formularios
3. **Tags por feature**: Crea tags como `.carrito`, `.auth`, `.perfil` para filtrar tests por funcionalidad
4. **Confirmation para eventos**: Usa `confirmation` para verificar que los delegados y callbacks se invocan
5. **Traits para CI/CD**: Marca tests de integracion con `.tags(.integracion)` para excluirlos en CI rapido

> **Nota**: Swift Testing y XCTest coexisten en el mismo proyecto. Usa Swift Testing para logica de negocio y XCTest para UI testing (Leccion 36).
