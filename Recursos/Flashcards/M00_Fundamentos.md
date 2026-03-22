# Flashcards — Modulo 00: Fundamentos de Swift

---

### Tarjeta 1
**Pregunta:** Cual es la diferencia entre `let` y `var` en Swift?
**Respuesta:** `let` declara una constante (valor inmutable una vez asignado). `var` declara una variable (valor que puede cambiar). Swift favorece `let` por defecto para mayor seguridad y claridad de intencion.

---

### Tarjeta 2
**Pregunta:** Nombra los tipos de valor fundamentales en Swift y por que se llaman "tipos de valor".
**Respuesta:** `Int`, `Double`, `String`, `Bool`, `Array`, `Dictionary`, `Set`, structs y enums. Se llaman tipos de valor porque al asignarlos o pasarlos a una funcion se crea una **copia independiente**, no una referencia al original.

---

### Tarjeta 3
**Pregunta:** Que es un Optional en Swift y por que existe?
**Respuesta:** Un Optional (`T?`) es un tipo que puede contener un valor de tipo `T` o `nil`. Existe para eliminar errores de null pointer en tiempo de compilacion: Swift te obliga a manejar explicitamente la ausencia de valor antes de usarlo.

---

### Tarjeta 4
**Pregunta:** Cuales son las 4 formas principales de desenvolver (unwrap) un Optional?
**Respuesta:** 1) `if let` — unwrap condicional. 2) `guard let` — unwrap con salida temprana. 3) `??` (nil-coalescing) — valor por defecto. 4) `!` (force unwrap) — peligroso, solo si estas 100% seguro de que no es nil.

---

### Tarjeta 5
**Pregunta:** Que es un closure en Swift y cual es su sintaxis basica?
**Respuesta:** Un closure es un bloque de codigo autocontenido que puede capturar valores de su contexto. Sintaxis: `{ (parametros) -> TipoRetorno in cuerpo }`. Los closures son tipos de referencia y se usan extensivamente en APIs como `map`, `filter`, `sorted` y callbacks asincronos.

---

### Tarjeta 6
**Pregunta:** Cuales son las 3 diferencias principales entre `struct` y `class` en Swift?
**Respuesta:** 1) **Tipo de valor vs referencia**: struct es valor (se copia), class es referencia (se comparte). 2) **Herencia**: solo class soporta herencia. 3) **Deinit**: solo class tiene `deinit`. Swift recomienda usar struct por defecto y class solo cuando necesitas identidad, herencia o comportamiento de referencia.

---

### Tarjeta 7
**Pregunta:** Que son los enums con valores asociados y para que sirven?
**Respuesta:** Son enums donde cada caso puede llevar datos adjuntos de diferentes tipos. Ejemplo: `enum Resultado { case exito(datos: Data), case error(mensaje: String) }`. Sirven para modelar estados con datos asociados de forma segura, eliminando la necesidad de propiedades opcionales.

---

### Tarjeta 8
**Pregunta:** Que significa Protocol-Oriented Programming (POP) y por que Swift lo favorece?
**Respuesta:** POP es un paradigma donde defines comportamiento mediante protocolos (interfaces) y extensiones de protocolo con implementaciones por defecto. Swift lo favorece porque: 1) Funciona con tipos de valor (structs). 2) Permite composicion flexible (un tipo adopta multiples protocolos). 3) Evita los problemas de la herencia profunda de clases.

---

### Tarjeta 9
**Pregunta:** Que son los Generics y que problema resuelven?
**Respuesta:** Los generics permiten escribir funciones y tipos flexibles que funcionan con cualquier tipo, manteniendo la seguridad de tipos. Ejemplo: `func intercambiar<T>(_ a: inout T, _ b: inout T)`. Resuelven la duplicacion de codigo: escribes la logica una vez y funciona con Int, String, o cualquier tipo.

---

### Tarjeta 10
**Pregunta:** Como funciona ARC (Automatic Reference Counting) y cuando se libera un objeto?
**Respuesta:** ARC cuenta cuantas referencias fuertes (`strong`) apuntan a un objeto en memoria. Cuando el conteo llega a **cero**, ARC libera el objeto automaticamente. A diferencia del garbage collection, ARC es determinista: sabes exactamente cuando se libera la memoria.

---

### Tarjeta 11
**Pregunta:** Que es un ciclo de referencia fuerte y como se resuelve?
**Respuesta:** Ocurre cuando dos objetos se referencian mutuamente con referencias fuertes, impidiendo que ARC los libere (memory leak). Se resuelve usando `weak` (referencia debil, se vuelve nil) o `unowned` (referencia sin dueno, nunca es nil pero puede crashear si el objeto se libero).

---

### Tarjeta 12
**Pregunta:** Que es `async/await` y que ventaja tiene sobre los callbacks?
**Respuesta:** `async/await` es el modelo de concurrencia estructurada de Swift. Una funcion marcada `async` puede suspenderse sin bloquear el hilo. `await` marca el punto de suspension. Ventajas: codigo lineal y legible (sin piramide de callbacks), propagacion natural de errores con `try`, y el compilador verifica la seguridad de concurrencia.

---

### Tarjeta 13
**Pregunta:** Que es un `Task` en Swift concurrency y cuales son sus variantes?
**Respuesta:** Un `Task` es una unidad de trabajo asincrono. Variantes: 1) `Task { }` — tarea no estructurada que hereda el actor. 2) `Task.detached { }` — tarea independiente sin herencia de contexto. 3) `TaskGroup` — grupo de tareas estructuradas con `withTaskGroup`. Las tareas estructuradas se cancelan automaticamente si el padre se cancela.

---

### Tarjeta 14
**Pregunta:** Que es un Actor y que problema resuelve?
**Respuesta:** Un `actor` es un tipo de referencia que protege su estado mutable del acceso concurrente. Solo una tarea puede acceder al estado del actor a la vez. Resuelve las **data races**: el compilador te obliga a usar `await` para acceder a propiedades del actor desde fuera, garantizando acceso serializado.

---

### Tarjeta 15
**Pregunta:** Que es el protocolo `Sendable` y por que es importante en Swift 6?
**Respuesta:** `Sendable` indica que un valor puede enviarse de forma segura entre contextos de concurrencia (entre actores o tareas). En Swift 6 con strict concurrency, el compilador **exige** que los tipos cruzando limites de aislamiento sean `Sendable`. Los tipos de valor (structs con propiedades Sendable) conforman automaticamente; las clases deben ser `final` con propiedades inmutables o usar `@unchecked Sendable`.
