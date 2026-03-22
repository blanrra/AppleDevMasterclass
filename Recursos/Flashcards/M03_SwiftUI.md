# Flashcards — Modulo 03: SwiftUI Avanzado

---

### Tarjeta 1
**Pregunta:** Como funciona `NavigationStack` y por que reemplaza a `NavigationView`?
**Respuesta:** `NavigationStack` gestiona una pila de navegacion basada en datos. Usa `navigationDestination(for:)` para definir destinos por tipo. Reemplaza a `NavigationView` porque: 1) Soporta navegacion programatica con un path. 2) Es mas predecible. 3) Funciona mejor en iPad y Mac con `NavigationSplitView`.

---

### Tarjeta 2
**Pregunta:** Que es `NavigationPath` y para que se usa?
**Respuesta:** `NavigationPath` es un stack type-erased que almacena la ruta de navegacion. Permite: 1) Navegar programaticamente con `path.append(valor)`. 2) Volver atras con `path.removeLast()`. 3) Ir al root con `path = NavigationPath()`. 4) Es `Codable`, asi que puedes guardar y restaurar el estado de navegacion completo.

---

### Tarjeta 3
**Pregunta:** Que es un `@ViewBuilder` y cuando se usa?
**Respuesta:** `@ViewBuilder` es un result builder que permite construir vistas compuestas a partir de multiples expresiones. Se usa en: 1) El `body` de toda View (implicitamente). 2) Parametros de closure en componentes custom. 3) Funciones que devuelven vistas condicionales. Permite usar `if/else`, `switch` y multiples vistas sin necesidad de `Group`.

---

### Tarjeta 4
**Pregunta:** Como se crea un `ViewModifier` personalizado y por que es util?
**Respuesta:** Se crea un struct que conforma `ViewModifier` con un metodo `body(content:) -> some View`. Se aplica con `.modifier(MiModifier())` o con una extension de View: `func miEstilo() -> some View { modifier(MiModifier()) }`. Es util para encapsular combinaciones de modificadores reutilizables y mantener las vistas limpias.

---

### Tarjeta 5
**Pregunta:** Que es una `PreferenceKey` y que patron habilita?
**Respuesta:** Una `PreferenceKey` permite pasar datos de una vista hija hacia una vista padre (flujo inverso al normal). Se define un struct con `defaultValue` y `reduce()`. La hija establece el valor con `.preference(key:value:)` y el padre lo lee con `.onPreferenceChange`. Patron comun: medir el tamano de una vista hija para ajustar el layout del padre.

---

### Tarjeta 6
**Pregunta:** Cual es la diferencia entre `VStack` y `LazyVStack`?
**Respuesta:** `VStack` crea **todas** sus vistas hijas inmediatamente, incluso las que no son visibles. `LazyVStack` solo crea las vistas cuando estan a punto de aparecer en pantalla. Usa `LazyVStack` dentro de `ScrollView` para listas largas. Usa `VStack` para grupos pequenos (< 20 elementos) donde necesitas que todos existan para calcular el layout.

---

### Tarjeta 7
**Pregunta:** Como funciona el modificador `.searchable` en SwiftUI?
**Respuesta:** `.searchable(text: $busqueda)` agrega una barra de busqueda nativa a un `NavigationStack`. Soporta: 1) Sugerencias con `.searchSuggestions { }`. 2) Scopes con `.searchScopes`. 3) Tokens para filtros. 4) El texto de busqueda se bindea a una propiedad `@State`. La ubicacion de la barra (inline, sidebar) se adapta automaticamente a cada plataforma.

---

### Tarjeta 8
**Pregunta:** Cual es la diferencia entre `withAnimation` y `.animation()`?
**Respuesta:** `withAnimation(.spring) { estado = nuevoValor }` anima **todos** los cambios visuales causados por esa mutacion de estado, sin importar donde ocurran en el arbol. `.animation(.spring, value: estado)` anima solo los cambios en la vista donde se aplica el modificador cuando cambia el `value` especificado. Prefiere `withAnimation` para control explicito.

---

### Tarjeta 9
**Pregunta:** Que es `matchedGeometryEffect` y para que se usa?
**Respuesta:** Es un modificador que crea una transicion animada fluida entre dos vistas con el mismo `id` y `namespace` (definido con `@Namespace`). Cuando una vista desaparece y otra con el mismo id aparece, SwiftUI anima posicion, tamano y forma entre ambas. Uso tipico: transiciones hero entre una lista y una vista de detalle.

---

### Tarjeta 10
**Pregunta:** Como funciona `PhaseAnimator` y cuando usarlo?
**Respuesta:** `PhaseAnimator` itera automaticamente por un array de fases, aplicando cambios visuales en cada una. Ejemplo: `PhaseAnimator([false, true]) { phase in ... }`. Cada fase puede tener su propia animacion. Usalo para: animaciones continuas multi-paso, efectos de pulsacion, o secuencias complejas que se repiten. Es declarativo y reemplaza timers manuales.

---

### Tarjeta 11
**Pregunta:** Que es `.contentTransition` y que opciones ofrece?
**Respuesta:** `.contentTransition` define como se anima el cambio de contenido dentro de una vista (especialmente texto y numeros). Opciones: 1) `.numericText()` — los digitos ruedan individualmente. 2) `.interpolate` — transicion suave entre formas. 3) `.opacity` — fade in/out. Se combina con `withAnimation` para activar la transicion al cambiar el valor.

---

### Tarjeta 12
**Pregunta:** Como se implementa scroll programatico en SwiftUI?
**Respuesta:** Se usa `ScrollViewReader` que provee un `ScrollViewProxy`. Cada elemento necesita un `.id(valor)`. Para scrollear: `proxy.scrollTo(id, anchor: .top)` dentro de un `withAnimation`. Desde iOS 17+, tambien existe `.scrollPosition(id:)` como alternativa mas declarativa que bindea la posicion actual del scroll.
