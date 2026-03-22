# Leccion 36: UI Testing y SwiftLint — Calidad Visible y Codigo Limpio

**Modulo 09: Testing y Calidad** | Semana 46

---

## TL;DR — Resumen en 2 minutos

- **XCUITest** automatiza interacciones de usuario — taps, swipes, texto, navegacion completa
- **Accessibility identifiers** son la clave para encontrar elementos de UI de forma estable
- **Page Object Pattern** organiza tests de UI en objetos reutilizables — adios codigo fragil
- **SwiftLint** enforce reglas de estilo automaticamente — errores y warnings en compilacion
- **CI/CD integration** ejecuta tests de UI y linting en cada pull request automaticamente

> Herramienta: **Xcode 26** con UI Test Recording (boton rojo en el editor de tests)

---

## Cupertino MCP

```bash
cupertino search "XCUITest"
cupertino search "XCUIApplication"
cupertino search "XCUIElement"
cupertino search --source apple-docs "accessibility identifier"
cupertino search "UI testing Xcode"
cupertino search "XCUIElementQuery"
cupertino search "XCTExpectedFailure"
cupertino search --source apple-docs "launch arguments testing"
cupertino search --source updates "UI testing Xcode 26"
cupertino search --source hig "accessibility"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Testing | Novedades UI testing en Xcode 26 |
| WWDC24 | [Diagnose failures in UI tests](https://developer.apple.com/videos/play/wwdc2024/) | **Esencial** — diagnosticar fallos |
| WWDC22 | [Use Xcode to develop a multiplatform app](https://developer.apple.com/videos/play/wwdc2022/) | Testing multi-plataforma |
| WWDC21 | [Explore UI testing improvements](https://developer.apple.com/videos/play/wwdc2021/) | Mejoras en UI testing |
| EN | [Paul Hudson — UI Testing](https://www.hackingwithswift.com) | Tutorial paso a paso |
| EN | [Sean Allen — SwiftLint](https://www.youtube.com/@seanallen) | Configuracion SwiftLint |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que UI Testing?

Los unit tests verifican que tu logica es correcta. Pero el usuario no interactua con tu logica — interactua con botones, listas, formularios y navegacion. Un ViewModel puede pasar todos sus tests y aun asi la app puede tener un boton que no responde, una lista que no muestra datos, o una navegacion rota.

Los UI tests llenan ese vacio. Simulan exactamente lo que hace un usuario: abrir la app, tocar botones, escribir texto, deslizar listas, verificar que aparece lo esperado. Son mas lentos que los unit tests (segundos vs milisegundos), pero verifican lo que realmente importa: la experiencia del usuario.

La regla de oro: tests unitarios para logica, UI tests para flujos criticos del usuario.

### XCUIApplication — Lanzar la App

```swift
import XCTest

// MARK: - Test de UI basico
final class LoginUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false // Detener al primer fallo

        app = XCUIApplication()

        // MARK: - Launch arguments para configurar estado
        app.launchArguments = ["--ui-testing"]
        app.launchEnvironment = [
            "MOCK_API": "true",
            "RESET_STATE": "true"
        ]

        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Test de login exitoso
    func testLoginExitoso() {
        // Encontrar elementos por accessibility identifier
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]

        // Interactuar
        emailField.tap()
        emailField.typeText("jose@email.com")

        passwordField.tap()
        passwordField.typeText("MiClave123!")

        loginButton.tap()

        // Verificar resultado
        let welcomeLabel = app.staticTexts["welcomeLabel"]
        XCTAssertTrue(welcomeLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(welcomeLabel.label, "Bienvenido, Jose")
    }

    // MARK: - Test de login fallido
    func testLoginCredencialesInvalidas() {
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]

        emailField.tap()
        emailField.typeText("malo@email.com")

        passwordField.tap()
        passwordField.typeText("incorrecta")

        loginButton.tap()

        // Verificar que aparece error
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
        errorAlert.buttons["OK"].tap()

        // Verificar que seguimos en login
        XCTAssertTrue(emailField.exists)
    }
}
```

### Accessibility Identifiers — La Clave para UI Tests Estables

Los accessibility identifiers son la forma correcta de encontrar elementos. No uses textos visibles (que cambian con idiomas) ni posiciones (que cambian con el layout):

```swift
import SwiftUI

// MARK: - Vista con accessibility identifiers
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var mostrarError = false
    @State private var mensajeBienvenida = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .accessibilityIdentifier("emailTextField")   // Para UI tests

            SecureField("Contrasena", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .accessibilityIdentifier("passwordTextField")

            Button("Iniciar Sesion") {
                iniciarSesion()
            }
            .accessibilityIdentifier("loginButton")

            if !mensajeBienvenida.isEmpty {
                Text(mensajeBienvenida)
                    .accessibilityIdentifier("welcomeLabel")
            }
        }
        .padding()
        .alert("Error", isPresented: $mostrarError) {
            Button("OK") { }
        } message: {
            Text("Credenciales invalidas")
        }
    }

    private func iniciarSesion() {
        // Logica de login
    }
}

// MARK: - Componentes reutilizables con identifiers
struct ProductoRow: View {
    let producto: ProductoUI
    let indice: Int

    var body: some View {
        HStack {
            Text(producto.nombre)
                .accessibilityIdentifier("productoNombre_\(indice)")

            Spacer()

            Text("$\(producto.precio, specifier: "%.2f")")
                .accessibilityIdentifier("productoPrecio_\(indice)")

            Button("Agregar") {
                // accion
            }
            .accessibilityIdentifier("productoAgregar_\(indice)")
        }
    }
}

struct ProductoUI {
    let nombre: String
    let precio: Double
}

// MARK: - Lista con identifiers dinamicos
struct ListaProductosView: View {
    let productos: [ProductoUI]

    var body: some View {
        List {
            ForEach(Array(productos.enumerated()), id: \.offset) { indice, producto in
                ProductoRow(producto: producto, indice: indice)
            }
        }
        .accessibilityIdentifier("listaProductos")
    }
}
```

### Queries y Elementos — Encontrar lo que Necesitas

```swift
import XCTest

final class QueriesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Tipos de elementos
    func testTiposDeElementos() {
        // Botones
        let boton = app.buttons["miBoton"]

        // Campos de texto
        let textField = app.textFields["miCampo"]
        let secureField = app.secureTextFields["miPassword"]

        // Textos estaticos (labels)
        let label = app.staticTexts["miLabel"]

        // Imagenes
        let imagen = app.images["miImagen"]

        // Switches (toggles)
        let toggle = app.switches["miToggle"]

        // Sliders
        let slider = app.sliders["miSlider"]

        // Navigation bars
        let navBar = app.navigationBars["Titulo"]

        // Tab bars
        let tabBar = app.tabBars
        let tab = tabBar.buttons["Inicio"]

        // Alerts
        let alert = app.alerts["Error"]

        // Sheets
        let sheet = app.sheets.firstMatch

        // Celdas de tabla
        let celda = app.cells["celda_0"]

        _ = (boton, textField, secureField, label, imagen, toggle, slider, navBar, tab, alert, sheet, celda)
    }

    // MARK: - Busqueda por predicado
    func testBusquedaPorPredicado() {
        // Buscar por label que contiene texto
        let predicate = NSPredicate(format: "label CONTAINS 'Bienvenido'")
        let elementos = app.staticTexts.matching(predicate)
        XCTAssertTrue(elementos.count > 0)

        // Buscar por label que empieza con texto
        let predicate2 = NSPredicate(format: "label BEGINSWITH 'Error'")
        let errores = app.staticTexts.matching(predicate2)
        _ = errores
    }

    // MARK: - Verificar existencia y propiedades
    func testPropiedadesDeElementos() {
        let boton = app.buttons["loginButton"]

        // Existencia
        XCTAssertTrue(boton.exists)

        // Habilitado/deshabilitado
        XCTAssertTrue(boton.isEnabled)

        // Seleccionado
        // XCTAssertTrue(boton.isSelected)

        // Tiene foco
        // XCTAssertTrue(boton.hasFocus)

        // Valor del label
        XCTAssertEqual(boton.label, "Iniciar Sesion")

        // Valor (para campos de texto, sliders, etc.)
        let campo = app.textFields["emailTextField"]
        campo.tap()
        campo.typeText("hola")
        XCTAssertEqual(campo.value as? String, "hola")
    }
}
```

### Interacciones — Simular al Usuario

```swift
import XCTest

final class InteraccionesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Toques
    func testToques() {
        let boton = app.buttons["miBoton"]
        boton.tap()                    // Toque simple
        boton.doubleTap()             // Doble toque
        boton.press(forDuration: 1.5) // Toque largo (1.5 segundos)
        boton.twoFingerTap()          // Toque con dos dedos
    }

    // MARK: - Texto
    func testTexto() {
        let campo = app.textFields["emailTextField"]
        campo.tap()
        campo.typeText("jose@email.com") // Escribir texto

        // Limpiar campo
        campo.tap()
        let textoActual = campo.value as? String ?? ""
        let borrar = String(repeating: XCUIKeyboardKey.delete.rawValue,
                           count: textoActual.count)
        campo.typeText(borrar)

        // Escribir nuevo texto
        campo.typeText("nuevo@email.com")
    }

    // MARK: - Gestos de deslizamiento
    func testDeslizamientos() {
        let lista = app.tables["miLista"]
        lista.swipeUp()      // Deslizar hacia arriba (scroll down)
        lista.swipeDown()    // Deslizar hacia abajo (scroll up)
        lista.swipeLeft()    // Deslizar hacia izquierda
        lista.swipeRight()   // Deslizar hacia derecha
    }

    // MARK: - Swipe para eliminar
    func testSwipeParaEliminar() {
        let celda = app.cells.element(boundBy: 0)
        celda.swipeLeft()

        let botonEliminar = app.buttons["Eliminar"]
        if botonEliminar.waitForExistence(timeout: 2) {
            botonEliminar.tap()
        }
    }

    // MARK: - Pull to refresh
    func testPullToRefresh() {
        let primeraCelda = app.cells.firstMatch
        let inicio = primeraCelda.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
        let fin = primeraCelda.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 6))
        inicio.press(forDuration: 0, thenDragTo: fin)
    }

    // MARK: - Pickers y sliders
    func testPickersYSliders() {
        // Ajustar slider (valor entre 0 y 1)
        let slider = app.sliders["miSlider"]
        slider.adjust(toNormalizedSliderPosition: 0.75)

        // Seleccionar en picker
        let picker = app.pickers["miPicker"]
        picker.pickerWheels.element.adjust(toPickerWheelValue: "Opcion 3")
    }
}
```

### Esperar Elementos — La Paciencia del Test

```swift
import XCTest

final class EsperasUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - waitForExistence — la mas comun
    func testEsperarElemento() {
        app.buttons["cargarDatos"].tap()

        // Esperar hasta 10 segundos a que aparezca la lista
        let lista = app.tables["listaResultados"]
        let aparecio = lista.waitForExistence(timeout: 10)
        XCTAssertTrue(aparecio, "La lista deberia aparecer despues de cargar datos")
    }

    // MARK: - Esperar que un elemento desaparezca
    func testEsperarQueDesaparezca() {
        app.buttons["cargarDatos"].tap()

        // Esperar que el spinner desaparezca
        let spinner = app.activityIndicators["loadingSpinner"]
        let expectation = expectation(for: NSPredicate(format: "exists == false"),
                                       evaluatedWith: spinner)
        wait(for: [expectation], timeout: 15)
    }

    // MARK: - Esperar propiedad especifica
    func testEsperarPropiedad() {
        let boton = app.buttons["enviarButton"]

        // Esperar que el boton se habilite
        let expectation = expectation(
            for: NSPredicate(format: "isEnabled == true"),
            evaluatedWith: boton
        )
        wait(for: [expectation], timeout: 5)

        boton.tap()
    }

    // MARK: - Esperar cantidad de elementos
    func testEsperarCantidad() {
        app.buttons["cargarDatos"].tap()

        // Esperar que la lista tenga al menos 5 celdas
        let predicate = NSPredicate(format: "count >= 5")
        let expectation = expectation(
            for: predicate,
            evaluatedWith: app.cells
        )
        wait(for: [expectation], timeout: 10)
    }
}
```

### Page Object Pattern — Tests de UI Mantenibles

El Page Object Pattern es la tecnica mas importante para UI tests mantenibles. Encapsula los detalles de la UI en objetos reutilizables:

```swift
import XCTest

// MARK: - Page Objects

/// Cada "pagina" (pantalla) tiene su propio objeto
struct LoginPage {
    let app: XCUIApplication

    // MARK: - Elementos
    var emailField: XCUIElement {
        app.textFields["emailTextField"]
    }

    var passwordField: XCUIElement {
        app.secureTextFields["passwordTextField"]
    }

    var loginButton: XCUIElement {
        app.buttons["loginButton"]
    }

    var errorAlert: XCUIElement {
        app.alerts["Error"]
    }

    var registroButton: XCUIElement {
        app.buttons["registroButton"]
    }

    // MARK: - Acciones
    @discardableResult
    func escribirEmail(_ email: String) -> LoginPage {
        emailField.tap()
        emailField.typeText(email)
        return self
    }

    @discardableResult
    func escribirPassword(_ password: String) -> LoginPage {
        passwordField.tap()
        passwordField.typeText(password)
        return self
    }

    /// Retorna HomePage porque el login exitoso navega a Home
    func tapLogin() -> HomePage {
        loginButton.tap()
        return HomePage(app: app)
    }

    /// Retorna LoginPage porque el login fallido se queda en Login
    func tapLoginEsperandoError() -> LoginPage {
        loginButton.tap()
        return self
    }

    func tapRegistro() -> RegistroPage {
        registroButton.tap()
        return RegistroPage(app: app)
    }

    // MARK: - Verificaciones
    func verificarErrorVisible() -> LoginPage {
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
        return self
    }

    func cerrarError() -> LoginPage {
        errorAlert.buttons["OK"].tap()
        return self
    }
}

struct HomePage {
    let app: XCUIApplication

    var welcomeLabel: XCUIElement {
        app.staticTexts["welcomeLabel"]
    }

    var listaProductos: XCUIElement {
        app.collectionViews["listaProductos"]
    }

    var perfilTab: XCUIElement {
        app.tabBars.buttons["Perfil"]
    }

    var carritoTab: XCUIElement {
        app.tabBars.buttons["Carrito"]
    }

    func verificarBienvenida(_ nombre: String) -> HomePage {
        XCTAssertTrue(welcomeLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(welcomeLabel.label.contains(nombre))
        return self
    }

    func irAPerfil() -> PerfilPage {
        perfilTab.tap()
        return PerfilPage(app: app)
    }

    func irACarrito() -> CarritoPage {
        carritoTab.tap()
        return CarritoPage(app: app)
    }
}

struct RegistroPage {
    let app: XCUIApplication
    // ... elementos y acciones de registro
}

struct PerfilPage {
    let app: XCUIApplication
    // ... elementos y acciones de perfil
}

struct CarritoPage {
    let app: XCUIApplication
    // ... elementos y acciones del carrito
}

// MARK: - Tests usando Page Objects
final class FlujoCompletoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
    }

    func testLoginExitoso() {
        LoginPage(app: app)
            .escribirEmail("jose@email.com")
            .escribirPassword("MiClave123!")
            .tapLogin()
            .verificarBienvenida("Jose")
    }

    func testLoginFallido() {
        LoginPage(app: app)
            .escribirEmail("malo@email.com")
            .escribirPassword("incorrecta")
            .tapLoginEsperandoError()
            .verificarErrorVisible()
            .cerrarError()
    }

    func testFlujoCompraCompleto() {
        LoginPage(app: app)
            .escribirEmail("jose@email.com")
            .escribirPassword("MiClave123!")
            .tapLogin()
            .verificarBienvenida("Jose")
            .irACarrito()
        // .agregarProducto(...)
        // .verificarTotal(...)
        // .pagar()
    }
}
```

### SwiftLint — Codigo Consistente Automaticamente

SwiftLint enforce reglas de estilo en tu codigo Swift. Detecta problemas de estilo, convenciones rotas y patrones daninos automaticamente.

```yaml
# .swiftlint.yml — Archivo de configuracion en la raiz del proyecto

# Reglas desactivadas
disabled_rules:
  - trailing_whitespace        # Espacios al final de linea
  - line_length                # Longitud de linea (configuramos abajo)
  - force_cast                 # A veces necesario con APIs de Apple

# Reglas opcionales activadas
opt_in_rules:
  - empty_count               # Usar .isEmpty en lugar de .count == 0
  - closure_spacing            # Espacios en closures
  - contains_over_filter_count # .contains en lugar de .filter.count
  - discouraged_optional_boolean # Evitar Bool?
  - empty_string               # Usar .isEmpty para strings
  - fatal_error_message        # fatalError debe tener mensaje
  - first_where                # .first(where:) en lugar de .filter.first
  - force_unwrapping           # Evitar ! (warning, no error)
  - implicitly_unwrapped_optional # Evitar ImplicitlyUnwrappedOptional
  - last_where                 # .last(where:) en lugar de .filter.last
  - modifier_order             # Orden consistente de modificadores
  - overridden_super_call      # Llamar super en overrides
  - private_outlet             # @IBOutlet debe ser private
  - sorted_imports             # Imports ordenados
  - unowned_variable_capture   # Preferir [weak self] sobre [unowned self]
  - vertical_whitespace_closing_braces # Sin lineas vacias antes de }

# Configuracion especifica de reglas
line_length:
  warning: 120
  error: 200
  ignores_comments: true
  ignores_urls: true

type_body_length:
  warning: 300
  error: 500

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 40
  error: 80

function_parameter_count:
  warning: 5
  error: 8

# Directorios excluidos
excluded:
  - Pods
  - .build
  - DerivedData
  - Packages
  - "*.generated.swift"

# Rutas incluidas
included:
  - Sources
  - Tests

# Reglas personalizadas
custom_rules:
  no_print_in_production:
    name: "No print en produccion"
    regex: "\\bprint\\("
    message: "Usa Logger en lugar de print()"
    severity: warning
    match_kinds:
      - identifier

  no_hardcoded_strings:
    name: "No strings hardcodeados en Views"
    regex: 'Text\("[^"]*"\)(?!.*\.accessibilityIdentifier)'
    message: "Considera usar Localization para strings en Text()"
    severity: warning
```

### Instalar y Ejecutar SwiftLint

```bash
# Instalar con Homebrew
brew install swiftlint

# Ejecutar analisis
swiftlint lint

# Corregir automaticamente lo que se pueda
swiftlint lint --fix

# Analizar un archivo especifico
swiftlint lint --path Sources/MiArchivo.swift

# Generar reporte en formato JSON
swiftlint lint --reporter json > swiftlint-report.json

# Ver reglas disponibles
swiftlint rules

# Verificar configuracion
swiftlint lint --config .swiftlint.yml
```

### Integrar SwiftLint en Xcode

```bash
# Agregar como Build Phase en Xcode:
# Target > Build Phases > + > New Run Script Phase

# Script para Build Phase:
if command -v swiftlint >/dev/null 2>&1; then
    swiftlint lint --quiet
else
    echo "warning: SwiftLint no instalado. Ejecuta: brew install swiftlint"
fi

# Script alternativo con Swift Package Manager:
# Agregar al Package.swift como plugin
# .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.0")
```

### Reglas de SwiftLint en Accion

```swift
// MARK: - Ejemplos de lo que SwiftLint detecta

// ❌ force_unwrapping — Evitar !
let nombre = diccionario["nombre"]!  // Warning

// ✅ Usar optional binding
if let nombre = diccionario["nombre"] {
    print(nombre)
}

// ❌ empty_count — No comparar .count con 0
if array.count == 0 { }  // Warning

// ✅ Usar .isEmpty
if array.isEmpty { }

// ❌ force_cast — Evitar as!
let numero = valor as! Int  // Warning

// ✅ Usar as? con guard
guard let numero = valor as? Int else { return }

// ❌ first_where — No usar .filter().first
let primero = lista.filter { $0.activo }.first  // Warning

// ✅ Usar .first(where:)
let primero = lista.first(where: \.activo)

// ❌ sorted_imports — Imports desordenados
import UIKit     // Warning
import Foundation
import SwiftUI

// ✅ Imports ordenados
import Foundation
import SwiftUI
import UIKit

// MARK: - Desactivar reglas localmente (cuando es necesario)

// swiftlint:disable force_cast
let view = cell.contentView as! MiCustomView
// swiftlint:enable force_cast

// Desactivar para una sola linea
let resultado = try! operacion() // swiftlint:disable:this force_try
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml — GitHub Actions

name: Tests y Calidad
on:
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Instalar SwiftLint
        run: brew install swiftlint
      - name: Ejecutar SwiftLint
        run: swiftlint lint --strict --reporter github-actions-logging

  unit-tests:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Unit Tests
        run: |
          xcodebuild test \
            -scheme MiApp \
            -destination 'platform=iOS Simulator,name=iPhone 16' \
            -resultBundlePath TestResults \
            -enableCodeCoverage YES

  ui-tests:
    runs-on: macos-15
    needs: unit-tests  # Solo si los unit tests pasan
    steps:
      - uses: actions/checkout@v4
      - name: UI Tests
        run: |
          xcodebuild test \
            -scheme MiAppUITests \
            -destination 'platform=iOS Simulator,name=iPhone 16' \
            -resultBundlePath UITestResults
```

---

## Ejercicios

### Ejercicio 1: Login Flow con Page Objects (Basico)

Implementa el flujo completo de login con Page Object Pattern:

```swift
import XCTest

// TODO: Implementa estos Page Objects y tests:

// 1. LoginPage con:
//    - emailField, passwordField, loginButton, forgotPasswordButton
//    - escribirEmail(), escribirPassword(), tapLogin(), tapOlvidePassword()
//    - verificarCamposVacios(), verificarErrorVisible()

// 2. ForgotPasswordPage con:
//    - emailField, enviarButton, volverButton
//    - escribirEmail(), tapEnviar(), tapVolver()
//    - verificarConfirmacion()

// 3. Tests:
//    - testLoginExitosoNavegarAHome
//    - testLoginFallidoMostrarError
//    - testOlvidePasswordEnviarEmail
//    - testOlvidePasswordVolver
//    - testCamposVaciosBotonDeshabilitado
```

### Ejercicio 2: Lista de Productos con Interacciones (Intermedio)

Testea una lista de productos con busqueda, filtrado y acciones:

```swift
import XCTest

// TODO: Implementa Page Objects y tests para:

// ProductListPage:
//   - searchBar, filterButton, listaProductos
//   - buscar(texto:), aplicarFiltro(categoria:), seleccionarProducto(indice:)
//   - swipeParaEliminar(indice:), pullToRefresh()
//   - verificarCantidadProductos(esperada:), verificarProductoVisible(nombre:)

// ProductDetailPage:
//   - nombreLabel, precioLabel, agregarCarritoButton, favoritoButton
//   - tapAgregarAlCarrito(), tapFavorito(), volver()
//   - verificarNombre(esperado:), verificarPrecio(esperado:)

// Tests:
// 1. testBuscarProductoMuestraResultados
// 2. testFiltrarPorCategoriaReduceLista
// 3. testSeleccionarProductoNavegarADetalle
// 4. testSwipeEliminarProducto
// 5. testPullToRefreshActualizaLista
// 6. testAgregarAlCarritoDesdeDetalle
```

### Ejercicio 3: Configuracion SwiftLint Personalizada (Avanzado)

Crea una configuracion SwiftLint completa para el Proyecto Integrador:

```yaml
# TODO: Crea .swiftlint.yml con:

# 1. Reglas habilitadas:
#    - Todas las reglas de seguridad (force_cast, force_try, force_unwrapping)
#    - Reglas de rendimiento (first_where, last_where, contains_over_filter_count)
#    - Reglas de estilo (sorted_imports, modifier_order, vertical_whitespace)

# 2. Configuracion de limites:
#    - line_length: warning 120, error 200
#    - file_length: warning 400, error 700
#    - function_body_length: warning 30, error 60
#    - type_body_length: warning 250, error 400
#    - function_parameter_count: warning 4, error 6

# 3. Reglas personalizadas:
#    - no_print: detectar print() y sugerir Logger
#    - no_todo: detectar TODO sin ticket asociado
#    - no_force_unwrap_in_views: detectar ! en archivos *View.swift

# 4. Exclusiones:
#    - Generated/, Pods/, .build/, Tests/Mocks/

# 5. GitHub Actions workflow que ejecute SwiftLint y UI tests

# Bonus: Crea un script pre-commit hook que ejecute swiftlint --fix
```

---

## 5 Errores Comunes

### Error 1: Buscar elementos por texto visible en lugar de identifier

```swift
// MAL — se rompe con localizacion o cambios de UI
let boton = app.buttons["Iniciar Sesion"]  // Cambia en ingles a "Log In"
let label = app.staticTexts["Bienvenido"]  // Cambia a "Welcome"

// BIEN — accessibility identifier es estable
let boton = app.buttons["loginButton"]
let label = app.staticTexts["welcomeLabel"]

// En SwiftUI:
Button("Iniciar Sesion") { /* ... */ }
    .accessibilityIdentifier("loginButton")  // Siempre agregar esto
```

### Error 2: No esperar elementos asincrono

```swift
// MAL — el elemento puede no existir aun
func testMal() {
    app.buttons["cargarDatos"].tap()
    let celda = app.cells.element(boundBy: 0)
    XCTAssertTrue(celda.exists)  // FALLA — los datos no han cargado
}

// BIEN — esperar a que aparezca
func testBien() {
    app.buttons["cargarDatos"].tap()
    let celda = app.cells.element(boundBy: 0)
    XCTAssertTrue(celda.waitForExistence(timeout: 10))  // Espera hasta 10s
}
```

### Error 3: Tests de UI sin estado controlado

```swift
// MAL — depende del estado real de la app
func testMal() {
    app.launch()
    // El test asume que no hay sesion activa
    // Pero si otro test dejo una sesion abierta, falla
}

// BIEN — launch arguments para controlar estado
func testBien() {
    app.launchArguments = ["--ui-testing", "--reset-state", "--mock-api"]
    app.launchEnvironment = ["USER_LOGGED_IN": "false"]
    app.launch()
    // Estado predecible y controlado
}

// En la app, detectar el flag:
// if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
//     usarDatosMock()
// }
```

### Error 4: UI tests demasiado granulares

```swift
// MAL — un test por cada elemento de la pantalla
func testEmailFieldExiste() { XCTAssertTrue(app.textFields["email"].exists) }
func testPasswordFieldExiste() { XCTAssertTrue(app.secureTextFields["pass"].exists) }
func testBotonExiste() { XCTAssertTrue(app.buttons["login"].exists) }
// 50 tests mas asi...

// BIEN — tests que verifican flujos completos del usuario
func testFlujoLoginCompleto() {
    LoginPage(app: app)
        .escribirEmail("jose@email.com")
        .escribirPassword("clave123")
        .tapLogin()
        .verificarBienvenida("Jose")
}
```

### Error 5: SwiftLint con demasiadas reglas desde el inicio

```swift
// MAL — activar 100 reglas de golpe genera 500 warnings
// El equipo las ignora y pierde el valor de la herramienta

// BIEN — empezar con pocas reglas criticas y agregar gradualmente
// Fase 1: Solo errores de seguridad
//   force_cast, force_try, force_unwrapping

// Fase 2: Agregar reglas de estilo basicas
//   sorted_imports, line_length, trailing_whitespace

// Fase 3: Reglas de rendimiento
//   first_where, contains_over_filter_count, empty_count

// Fase 4: Reglas personalizadas del equipo
//   no_print, naming conventions
```

---

## Checklist de la Leccion

- [ ] Puedo crear UI tests con `XCUIApplication` y `XCUIElement`
- [ ] Se agregar `accessibilityIdentifier` a todos los elementos testeables
- [ ] Puedo simular interacciones: tap, typeText, swipe, scroll
- [ ] Domino `waitForExistence` y esperas con predicados
- [ ] Implemento Page Object Pattern para tests mantenibles
- [ ] Se usar launch arguments para controlar el estado del test
- [ ] Puedo instalar y configurar SwiftLint con `.swiftlint.yml`
- [ ] Conozco las reglas mas importantes de SwiftLint y cuando desactivarlas
- [ ] Puedo crear reglas personalizadas de SwiftLint
- [ ] Se integrar SwiftLint como Build Phase en Xcode
- [ ] Puedo configurar CI/CD con GitHub Actions para tests y linting

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

En el Proyecto Integrador, aplica UI Testing y SwiftLint para:

1. **Flujos criticos**: Escribe UI tests para login, navegacion principal, y la funcionalidad core del proyecto
2. **Page Objects**: Crea un Page Object por cada pantalla principal — Login, Home, Detalle, Carrito, Perfil
3. **Accessibility identifiers**: Agrega identifiers a TODOS los elementos interactivos de cada vista
4. **SwiftLint**: Configura `.swiftlint.yml` con reglas progresivas — empieza con seguridad, luego estilo
5. **CI/CD**: Configura GitHub Actions para ejecutar unit tests, UI tests y SwiftLint en cada PR

> **Nota**: Los UI tests usan XCTest (no Swift Testing). Swift Testing es para logica de negocio. UI tests seguiran con XCUITest por el foreseeable future.
