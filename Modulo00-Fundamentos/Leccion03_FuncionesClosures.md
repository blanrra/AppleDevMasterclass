# Leccion 03: Funciones y Closures

**Modulo 00: Fundamentos** | Semana 3

---

## TL;DR — Resumen en 2 minutos

- **Funciones**: bloques de codigo reutilizables — escribes una vez, usas muchas veces
- **Parametros y retorno**: las funciones reciben datos (parametros) y devuelven resultados
- **Argument labels**: Swift usa etiquetas para que las llamadas se lean como ingles natural
- **Closures**: funciones anonimas que puedes guardar en variables — la base de Swift moderno
- **map/filter/reduce**: funciones que transforman colecciones usando closures

> Herramienta recomendada: **Swift Playgrounds** en iPad o Mac

---

## Cupertino MCP

```bash
# Consultar antes de iniciar la leccion
cupertino search --source swift-book "functions"
cupertino search --source swift-book "closures"
cupertino search "Swift higher order functions"
cupertino search "Swift trailing closure"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| ES | Julio Cesar Fernandez — Funciones en Swift | Explicacion clara y directa |
| EN | [Paul Hudson — Functions](https://www.hackingwithswift.com/100/5) | 100 Days of Swift |
| EN | [Paul Hudson — Closures](https://www.hackingwithswift.com/100/6) | El tema mas dificil para principiantes |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Funciones — Tu Primera Herramienta de Organizacion

Piensa en una funcion como un **electrodomestico de cocina**. Una licuadora recibe ingredientes (parametros), hace algo con ellos (el cuerpo de la funcion) y te entrega un resultado (el valor de retorno). No necesitas saber como funciona por dentro cada vez que la usas — solo metes los ingredientes y obtienes el resultado.

Sin funciones, tu codigo seria una lista interminable de instrucciones. Con funciones, lo organizas en bloques con nombre que puedes reutilizar.

#### Funcion basica (sin parametros, sin retorno)

La funcion mas simple: un bloque de codigo con nombre.

```swift
func saludar() {
    print("Hola, bienvenido a Swift!")
}

// Llamar a la funcion
saludar()  // Hola, bienvenido a Swift!
saludar()  // Puedes usarla cuantas veces quieras
```

#### Funcion con parametros

Los parametros son los "ingredientes" que recibe la funcion.

```swift
func saludar(nombre: String) {
    print("Hola, \(nombre)!")
}

saludar(nombre: "Carlos")  // Hola, Carlos!
saludar(nombre: "Maria")   // Hola, Maria!
```

#### Funcion con valor de retorno

Usa `->` para indicar que tipo de dato devuelve la funcion.

```swift
func sumar(a: Int, b: Int) -> Int {
    return a + b
}

let resultado = sumar(a: 5, b: 3)
print(resultado)  // 8

// Si el cuerpo es una sola expresion, el return es implicito
func multiplicar(a: Int, b: Int) -> Int {
    a * b
}
```

#### Retorno multiple con tuplas

Una funcion puede devolver varios valores a la vez usando una tupla.

```swift
func analizarCalificaciones(_ notas: [Double]) -> (promedio: Double, maxima: Double, minima: Double) {
    let promedio = notas.reduce(0, +) / Double(notas.count)
    let maxima = notas.max() ?? 0
    let minima = notas.min() ?? 0
    return (promedio, maxima, minima)
}

let resultado = analizarCalificaciones([8.5, 9.0, 7.5, 10.0, 6.5])
print("Promedio: \(resultado.promedio)")  // Promedio: 8.3
print("Maxima: \(resultado.maxima)")      // Maxima: 10.0
print("Minima: \(resultado.minima)")      // Minima: 6.5
```

---

### Argument Labels — Codigo que se Lee Como Prosa

Una de las caracteristicas mas distintivas de Swift es que las funciones usan **etiquetas externas** e **internas**. Esto hace que el codigo se lea casi como una frase en ingles (o espanol).

#### Nombres externos vs internos

```swift
// "desde" y "hasta" son las etiquetas externas (las ve quien llama)
// "origen" y "destino" son los nombres internos (los usa el cuerpo)
func mover(desde origen: String, hasta destino: String) {
    print("Moviendo de \(origen) a \(destino)")
}

// Al llamar se lee como: mover desde "Madrid" hasta "Barcelona"
mover(desde: "Madrid", hasta: "Barcelona")
```

#### Omitir la etiqueta con `_`

A veces la etiqueta externa es innecesaria porque el nombre de la funcion ya deja claro que espera.

```swift
func saludar(_ nombre: String) {
    print("Hola, \(nombre)!")
}

// Mas limpio: saludar("Carlos") en vez de saludar(nombre: "Carlos")
saludar("Carlos")
```

#### Por que importa esto?

Compara con otros lenguajes:

```swift
// En otros lenguajes:
// move("Madrid", "Barcelona")  -- que es cada parametro?

// En Swift:
// mover(desde: "Madrid", hasta: "Barcelona")  -- cristalino!
```

Las etiquetas hacen que tu codigo sea **autodocumentado**. Quien lo lea no necesita ir a la definicion para entender que hace cada parametro.

---

### Default Parameters (Parametros por Defecto)

Puedes darle valores predeterminados a los parametros. Si no los pasas al llamar, se usa el valor por defecto.

```swift
func saludar(nombre: String, saludo: String = "Hola", entusiasmo: Int = 1) {
    let signos = String(repeating: "!", count: entusiasmo)
    print("\(saludo), \(nombre)\(signos)")
}

saludar(nombre: "Carlos")                          // Hola, Carlos!
saludar(nombre: "Carlos", saludo: "Buenos dias")   // Buenos dias, Carlos!
saludar(nombre: "Carlos", entusiasmo: 5)           // Hola, Carlos!!!!!
```

Esto es muy comun en APIs de Apple — muchas funciones tienen parametros opcionales con valores sensatos por defecto.

---

### Functions as First-Class Citizens

En Swift, las funciones son "ciudadanos de primera clase". Esto significa que puedes tratarlas como cualquier otro valor: guardarlas en variables, pasarlas como parametros y devolverlas como resultado.

```swift
// 1. Guardar una funcion en una variable
func sumar(_ a: Int, _ b: Int) -> Int { a + b }
func restar(_ a: Int, _ b: Int) -> Int { a - b }

var operacion: (Int, Int) -> Int = sumar
print(operacion(10, 3))  // 13

operacion = restar
print(operacion(10, 3))  // 7

// 2. Pasar una funcion como parametro
func aplicar(_ a: Int, _ b: Int, operacion: (Int, Int) -> Int) -> Int {
    operacion(a, b)
}

let resultado = aplicar(10, 3, operacion: sumar)  // 13
```

**Esto es la antesala de los closures.** Si puedes guardar funciones en variables y pasarlas como parametros... por que no crear funciones anonimas directamente? Eso es un closure.

---

### Closures — Funciones Anonimas

Un closure es como una **nota con instrucciones** que puedes pasar de mano en mano. No tiene nombre propio — es una funcion empaquetada que puedes guardar, pasar y ejecutar donde quieras.

#### Sintaxis basica

```swift
// Sintaxis completa de un closure:
// { (parametros) -> TipoRetorno in
//     cuerpo
// }

let saludar = { (nombre: String) -> String in
    return "Hola, \(nombre)!"
}

print(saludar("Carlos"))  // Hola, Carlos!
```

#### De funcion a closure — paso a paso

Veamos como una funcion se transforma en un closure progresivamente:

```swift
// Paso 1: Funcion normal
func doble(_ numero: Int) -> Int {
    return numero * 2
}

// Paso 2: Como closure (sintaxis completa)
let dobleClosure = { (numero: Int) -> Int in
    return numero * 2
}

// Paso 3: Swift infiere el tipo de retorno
let dobleClosure2 = { (numero: Int) in
    numero * 2
}

// Paso 4: Cuando se usa como parametro, Swift infiere todo
let numeros = [1, 2, 3, 4, 5]
let dobles = numeros.map { numero in numero * 2 }

// Paso 5: Shorthand con $0, $1, etc.
let doblesFinal = numeros.map { $0 * 2 }
```

#### Trailing Closure Syntax

Cuando el ultimo parametro de una funcion es un closure, puedes escribirlo fuera de los parentesis. Esto hace el codigo mucho mas limpio.

```swift
// Sin trailing closure
let ordenados = numeros.sorted(by: { $0 < $1 })

// Con trailing closure — mas limpio
let ordenados2 = numeros.sorted { $0 < $1 }

// Cuando la funcion SOLO recibe un closure, puedes omitir los parentesis
let dobles = numeros.map { $0 * 2 }
```

#### Shorthand: $0, $1, $2...

Dentro de un closure, `$0` es el primer parametro, `$1` el segundo, y asi sucesivamente. Usalo cuando el closure es corto y claro.

```swift
let nombres = ["Carlos", "Ana", "Pedro", "Maria"]

// $0 es cada elemento del array
let mayusculas = nombres.map { $0.uppercased() }
// ["CARLOS", "ANA", "PEDRO", "MARIA"]

// $0 y $1 son los dos elementos que se comparan
let ordenadosPorLongitud = nombres.sorted { $0.count < $1.count }
// ["Ana", "Pedro", "Maria", "Carlos"]
```

**Consejo**: Si el closure es complejo o tiene mas de una linea, usa nombres descriptivos en lugar de `$0`. La claridad siempre gana.

```swift
// Demasiado críptico:
let resultado = datos.filter { $0.2 > 100 && $0.1 != nil }

// Mucho mejor:
let resultado = datos.filter { registro in
    registro.monto > 100 && registro.fecha != nil
}
```

---

### Higher-Order Functions — Transformar Colecciones

Las funciones de orden superior son funciones que reciben o devuelven otras funciones. En la practica, las usaras constantemente para transformar arrays.

#### map — Transformar cada elemento

`map` toma cada elemento, le aplica una transformacion y devuelve un nuevo array.

```swift
let precios = [10.0, 25.0, 30.0, 15.0]

// Sin map (forma imperativa con for):
var preciosConIVA: [Double] = []
for precio in precios {
    preciosConIVA.append(precio * 1.21)
}

// Con map (forma funcional):
let preciosConIVA2 = precios.map { $0 * 1.21 }
// [12.1, 30.25, 36.3, 18.15]
```

#### filter — Quedarte con los que pasan una prueba

`filter` evalua cada elemento con una condicion y devuelve solo los que la cumplen.

```swift
let edades = [15, 22, 17, 30, 12, 45, 19]

// Sin filter:
var mayoresDeEdad: [Int] = []
for edad in edades {
    if edad >= 18 {
        mayoresDeEdad.append(edad)
    }
}

// Con filter:
let mayoresDeEdad2 = edades.filter { $0 >= 18 }
// [22, 30, 45, 19]
```

#### reduce — Combinar todo en un solo valor

`reduce` toma un valor inicial y va acumulando los elementos en un resultado.

```swift
let numeros = [1, 2, 3, 4, 5]

// Sin reduce:
var suma = 0
for numero in numeros {
    suma += numero
}

// Con reduce:
let suma2 = numeros.reduce(0) { acumulado, actual in
    acumulado + actual
}
// 15

// Version corta:
let suma3 = numeros.reduce(0, +)  // 15
```

#### sorted(by:) — Ordenar con criterio custom

```swift
struct Producto {
    let nombre: String
    let precio: Double
}

let productos = [
    Producto(nombre: "Laptop", precio: 999.99),
    Producto(nombre: "Mouse", precio: 29.99),
    Producto(nombre: "Teclado", precio: 79.99),
    Producto(nombre: "Monitor", precio: 349.99)
]

// Ordenar por precio (menor a mayor)
let porPrecio = productos.sorted { $0.precio < $1.precio }

// Ordenar por nombre (A-Z)
let porNombre = productos.sorted { $0.nombre < $1.nombre }
```

#### Encadenar operaciones

La verdadera potencia esta en **encadenar** estas funciones para crear pipelines de transformacion.

```swift
let ventas = [
    ("Laptop", 999.99),
    ("Mouse", 29.99),
    ("Teclado", 79.99),
    ("Monitor", 349.99),
    ("Cable", 9.99),
    ("Webcam", 59.99)
]

// Pipeline: filtrar productos caros, obtener nombres, ordenar
let productosCaros = ventas
    .filter { $0.1 > 50 }           // Solo productos > $50
    .map { $0.0 }                    // Obtener solo el nombre
    .sorted()                        // Ordenar alfabeticamente

print(productosCaros)
// ["Laptop", "Monitor", "Teclado", "Webcam"]

// Total de ventas de productos baratos
let totalBaratos = ventas
    .filter { $0.1 <= 50 }
    .reduce(0) { $0 + $1.1 }

print("Total baratos: $\(totalBaratos)")  // Total baratos: $39.98
```

---

## Ejemplos de Codigo

### Archivo: `Codigo/FuncionesClosures.swift`

```swift
import Foundation

// MARK: - Funciones Basicas

func calcularPropina(cuenta: Double, porcentaje: Double = 0.15) -> (propina: Double, total: Double) {
    let propina = cuenta * porcentaje
    return (propina, cuenta + propina)
}

let resultado = calcularPropina(cuenta: 85.50)
print("Propina: $\(resultado.propina)")  // $12.825
print("Total: $\(resultado.total)")      // $98.325

let resultadoGeneral = calcularPropina(cuenta: 85.50, porcentaje: 0.20)
print("Propina generosa: $\(resultadoGeneral.propina)")  // $17.1

// MARK: - Closures en Accion

let operaciones: [String: (Double, Double) -> Double] = [
    "sumar": { $0 + $1 },
    "restar": { $0 - $1 },
    "multiplicar": { $0 * $1 },
    "dividir": { $1 != 0 ? $0 / $1 : 0 }
]

if let sumar = operaciones["sumar"] {
    print("5 + 3 = \(sumar(5, 3))")  // 8.0
}

// MARK: - Pipeline de Datos

struct Estudiante {
    let nombre: String
    let calificacion: Double
    let materia: String
}

let estudiantes = [
    Estudiante(nombre: "Carlos", calificacion: 9.5, materia: "Matematicas"),
    Estudiante(nombre: "Ana", calificacion: 8.0, materia: "Historia"),
    Estudiante(nombre: "Pedro", calificacion: 6.5, materia: "Matematicas"),
    Estudiante(nombre: "Maria", calificacion: 9.8, materia: "Historia"),
    Estudiante(nombre: "Luis", calificacion: 7.0, materia: "Matematicas"),
    Estudiante(nombre: "Sofia", calificacion: 8.5, materia: "Historia")
]

// Pipeline: mejores de matematicas
let mejoresMatematicas = estudiantes
    .filter { $0.materia == "Matematicas" }
    .filter { $0.calificacion >= 7.0 }
    .sorted { $0.calificacion > $1.calificacion }
    .map { "\($0.nombre): \($0.calificacion)" }

print("\nMejores en Matematicas:")
mejoresMatematicas.forEach { print("  \($0)") }

// Promedio general
let promedio = estudiantes
    .map { $0.calificacion }
    .reduce(0, +) / Double(estudiantes.count)

print("Promedio general: \(promedio)")
```

---

## Ejercicio 1: Calculadora con Etiquetas (Basico)

**Objetivo**: Practicar funciones, parametros, retorno y argument labels.

**Requisitos**:
1. Crear funcion `sumar(_ a: Double, con b: Double) -> Double`
2. Crear funcion `restar(_ a: Double, menos b: Double) -> Double`
3. Crear funcion `multiplicar(_ a: Double, por b: Double) -> Double`
4. Crear funcion `dividir(_ a: Double, entre b: Double) -> Double?` (retorna nil si b es 0)
5. Crear funcion `calcular(operacion: String, a: Double, b: Double) -> Double?` que use las anteriores

Las llamadas deben leerse naturalmente:
```swift
sumar(10, con: 5)           // 15
restar(10, menos: 3)        // 7
multiplicar(4, por: 3)      // 12
dividir(10, entre: 0)       // nil
```

---

## Ejercicio 2: Filtro de Estudiantes (Intermedio)

**Objetivo**: Practicar closures como parametros y higher-order functions.

**Requisitos**:
1. Crear struct `Alumno` con: nombre, edad, promedio, carrera
2. Crear un array con al menos 8 alumnos de diferentes carreras
3. Crear funcion `filtrarAlumnos(_ alumnos: [Alumno], criterio: (Alumno) -> Bool) -> [Alumno]`
4. Usar la funcion con diferentes closures:
   - Filtrar por promedio mayor a 8.0
   - Filtrar por carrera especifica
   - Filtrar por edad (mayores de 20)
5. Crear funcion `reporteAlumnos` que use map para generar un reporte formateado

---

## Ejercicio 3: Pipeline de Productos (Avanzado)

**Objetivo**: Construir un pipeline completo encadenando higher-order functions.

**Requisitos**:
1. Crear struct `Producto` con: nombre, precio, categoria, enStock
2. Crear un catalogo con al menos 12 productos de diferentes categorias
3. Construir los siguientes pipelines encadenando map/filter/reduce/sorted:
   - **Pipeline 1**: Productos en stock con precio > $50, ordenados por precio, mostrando solo nombre y precio
   - **Pipeline 2**: Total del inventario (suma de precios de productos en stock)
   - **Pipeline 3**: Productos por categoria — nombre de la categoria y cuantos productos tiene
4. Crear funcion generica `procesarCatalogo` que reciba el array y un closure de transformacion

```swift
// Ejemplo de uso esperado:
let resultado = procesarCatalogo(catalogo) { productos in
    productos
        .filter { $0.enStock }
        .sorted { $0.precio < $1.precio }
        .map { "\($0.nombre): $\($0.precio)" }
}
```

---

## Recursos Adicionales

- **Cupertino**: `cupertino search --source swift-book "functions"`
- **Cupertino**: `cupertino search --source swift-book "closures"`
- **Paul Hudson**: hackingwithswift.com — Closures explained
- **Julio Cesar Fernandez**: acodingacademy.com — Funciones en Swift

---

## Checklist

- [ ] Crear funciones con parametros y valores de retorno
- [ ] Usar argument labels para que las llamadas se lean naturalmente
- [ ] Usar parametros por defecto para simplificar llamadas comunes
- [ ] Entender que las funciones son first-class citizens en Swift
- [ ] Escribir closures con sintaxis completa y shorthand ($0, $1)
- [ ] Dominar trailing closure syntax
- [ ] Usar map para transformar arrays
- [ ] Usar filter para seleccionar elementos
- [ ] Usar reduce para combinar elementos en un valor
- [ ] Encadenar operaciones en pipelines fluidos
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Las funciones y closures son el tejido que conecta todo tu codigo. En el Proyecto Integrador usaras:
- **Funciones con labels claros** para APIs internas legibles
- **Closures** en practicamente todo: callbacks, animaciones SwiftUI, predicados de busqueda
- **map/filter/reduce** para transformar datos del servidor antes de mostrarlos
- **Trailing closures** en cada modificador de SwiftUI (`.onAppear { }`, `.task { }`, `.sheet { }`)
- **Pipelines funcionales** para procesar datos de SwiftData antes de presentarlos

---

*Leccion 03 (L03) | Funciones y Closures | Semana 3 | Modulo 00: Fundamentos*
*Siguiente: Leccion 04 (L04) — Structs, Clases y Enums*
