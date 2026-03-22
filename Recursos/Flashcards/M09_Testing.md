# Flashcards — Modulo 09: Testing y Calidad

---

### Tarjeta 1
**Pregunta:** Que es `XCTestCase` y como se estructura un test unitario basico?
**Respuesta:** `XCTestCase` es la clase base para tests en XCTest. Estructura: 1) Crear clase que hereda de `XCTestCase`. 2) Metodos que empiezan con `test` se ejecutan automaticamente. 3) `setUp()` prepara el estado antes de cada test. 4) `tearDown()` limpia despues de cada test. Cada metodo test debe ser independiente y verificar una sola cosa.

---

### Tarjeta 2
**Pregunta:** Cuales son las funciones `XCTAssert` mas usadas y cuando usar cada una?
**Respuesta:** 1) `XCTAssertEqual(a, b)` — verifica igualdad. 2) `XCTAssertTrue(expr)` / `XCTAssertFalse(expr)` — verifica booleanos. 3) `XCTAssertNil(expr)` / `XCTAssertNotNil(expr)` — verifica opcionales. 4) `XCTAssertThrowsError(expr)` — verifica que lanza error. 5) `XCTAssertGreaterThan(a, b)` — comparaciones. Cada funcion acepta un mensaje descriptivo como ultimo parametro.

---

### Tarjeta 3
**Pregunta:** Que es Swift Testing y como se diferencia de XCTest?
**Respuesta:** Swift Testing es el framework moderno de testing de Apple. Diferencias: 1) Usa `@Test` en lugar de metodos `test...` en una clase. 2) Usa `#expect()` en lugar de `XCTAssert`. 3) No necesita herencia de clase. 4) Soporta tests parametrizados nativamente. 5) Soporta tags para organizar. 6) Mejor integracion con Swift concurrency. Puede coexistir con XCTest en el mismo proyecto.

---

### Tarjeta 4
**Pregunta:** Como se usa `#expect` en Swift Testing y que ventajas tiene?
**Respuesta:** `#expect(expresion)` reemplaza a todos los XCTAssert. Ejemplos: `#expect(resultado == 42)`, `#expect(lista.isEmpty)`, `#expect(throws: MiError.self) { try funcion() }`. Ventaja clave: cuando falla, muestra **automaticamente** los valores de cada lado de la expresion, sin necesidad de mensajes custom. Es una macro que captura el contexto completo.

---

### Tarjeta 5
**Pregunta:** Que son los tests parametrizados en Swift Testing?
**Respuesta:** Permiten ejecutar el mismo test con diferentes datos de entrada automaticamente. Se usa `@Test(arguments:)`: `@Test(arguments: [1, 2, 3, 5, 8]) func esFibonacci(numero: Int)`. Cada argumento genera un test independiente que puede pasar o fallar individualmente. Elimina la duplicacion de tests similares con diferentes inputs.

---

### Tarjeta 6
**Pregunta:** Como se escriben tests de UI con XCUITest?
**Respuesta:** 1) Crear un target de UI Testing. 2) Usar `XCUIApplication()` para lanzar la app. 3) Encontrar elementos: `app.buttons["Guardar"]`, `app.textFields["Email"]`. 4) Interactuar: `.tap()`, `.typeText()`, `.swipeUp()`. 5) Verificar: `XCTAssertTrue(app.staticTexts["Exito"].exists)`. Los tests de UI ejecutan la app real en un simulador.

---

### Tarjeta 7
**Pregunta:** Que son los accessibility identifiers y por que son importantes para testing?
**Respuesta:** Los accessibility identifiers son strings unicos asignados a elementos de UI con `.accessibilityIdentifier("id")`. Son importantes porque: 1) Permiten encontrar elementos en tests de UI de forma estable (no dependen del texto visible que puede cambiar). 2) No son visibles al usuario. 3) No afectan VoiceOver (a diferencia de accessibilityLabel). Son el puente entre el codigo de la app y los tests de UI.

---

### Tarjeta 8
**Pregunta:** Como se testea codigo asincrono en Swift Testing?
**Respuesta:** Los tests pueden ser `async` directamente: `@Test func cargaDatos() async throws { let datos = try await servicio.obtener(); #expect(!datos.isEmpty) }`. Para timeouts: `#expect(performing: { try await operacion() }, throws: Never.self)`. Swift Testing soporta concurrencia nativamente sin necesidad de expectativas como `XCTestExpectation`.

---

### Tarjeta 9
**Pregunta:** Que es SwiftLint y como se configura en un proyecto?
**Respuesta:** SwiftLint es una herramienta que aplica reglas de estilo y convenciones al codigo Swift. Se configura con un archivo `.swiftlint.yml` en la raiz del proyecto. Se puede instalar con SPM, Homebrew o como plugin de Build Tool. Reglas comunes: longitud de linea, forzar `let` sobre `var`, prohibir force unwrap. Se pueden desactivar reglas especificas y crear reglas custom.

---

### Tarjeta 10
**Pregunta:** Que es el patron Arrange-Act-Assert (AAA) en testing?
**Respuesta:** Es la estructura recomendada para cada test: 1) **Arrange** (Preparar): configurar los objetos y datos necesarios. 2) **Act** (Actuar): ejecutar la accion que quieres probar. 3) **Assert** (Verificar): comprobar que el resultado es el esperado. Ejemplo: crear un carrito (arrange), agregar un producto (act), verificar que el total es correcto (assert). Mantiene los tests claros y enfocados.
