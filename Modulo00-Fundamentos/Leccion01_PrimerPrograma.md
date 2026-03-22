# Leccion 01: Tu Primer Programa en Swift

**Modulo 00: Fundamentos — Bloque A: Iniciacion** | Semana 1

---

## TL;DR — Resumen en 2 minutos

- **Programar es dar instrucciones**: como una receta de cocina, pero para el ordenador
- **Variables (var/let)**: cajas con nombre donde guardas datos — let no cambia, var si
- **Tipos basicos**: Int (numeros), Double (decimales), String (texto), Bool (si/no)
- **print()**: tu primera forma de ver resultados — imprime texto en la consola
- **Swift es seguro**: te avisa de errores ANTES de ejecutar, no despues

> Herramienta recomendada: **Swift Playgrounds** en iPad o Mac

---

## Cupertino MCP

```bash
# Consultar antes de iniciar la leccion
cupertino search --source swift-book "the basics"
cupertino search "swift programming language"
cupertino search "Swift variables constants"
cupertino search "Swift basic types"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| ES | [Julio Cesar Fernandez — Swift desde cero](https://www.youtube.com/@jcfmunoz) | Fundamentos en espanol |
| EN | [Paul Hudson — Day 1: Variables](https://www.hackingwithswift.com/100/swiftui/1) | 100 Days of SwiftUI |
| EN | [CodeWithChris — Swift for Beginners](https://www.youtube.com/@CodeWithChris) | Muy visual y paso a paso |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Que es Programar?

Imagina que quieres preparar una tortilla de patatas. Necesitas una receta: una lista de pasos
ordenados que sigues uno a uno. Si cambias el orden (echar los huevos antes de pelar las
patatas), el resultado es un desastre.

**Programar es exactamente eso**: escribir una receta para el ordenador. El ordenador es muy
rapido y muy obediente, pero tambien muy literal. Si le dices "salta 1000 veces", lo hara sin
preguntar. Si te olvidas de un paso, no lo adivinara por ti.

```
+---------------------------------------------------+
|  RECETA DE COCINA          PROGRAMA EN SWIFT       |
+---------------------------------------------------+
|  Ingredientes         -->  Datos (variables)       |
|  Pasos ordenados      -->  Instrucciones (codigo)  |
|  "Hornear 30 min"     -->  "Esperar respuesta"     |
|  Resultado: un plato  -->  Resultado: una app      |
+---------------------------------------------------+
```

**Swift** es el lenguaje de programacion creado por Apple en 2014. Es el que se usa para
crear apps de iPhone, iPad, Apple Watch, Mac y Apple Vision Pro. Antes se usaba
Objective-C (un lenguaje de 1984), pero Swift es mucho mas moderno, seguro y facil de leer.

**Por que Swift?** Porque Apple lo diseno pensando en dos cosas:
1. Que sea **seguro**: te avisa de errores antes de ejecutar tu programa
2. Que sea **legible**: el codigo se parece al ingles, es casi como leer una frase

---

### Variables y Constantes

Piensa en una **variable** como una caja con una etiqueta. Dentro de la caja guardas algo
(un numero, un texto, un dato). La etiqueta es el nombre que le pones para poder encontrarla
despues.

En Swift hay dos tipos de "cajas":

#### `let` — Constante (caja sellada)

Una vez que pones algo dentro, **no puedes cambiarlo**. Como tu fecha de nacimiento: siempre
sera la misma.

```swift
let nombre = "Maria"
let fechaNacimiento = "15 de marzo de 1995"
let paisDeOrigen = "Espana"
```

Si intentas cambiar una constante, Swift te avisa con un error:

```swift
let nombre = "Maria"
nombre = "Ana"  // ERROR: no puedes cambiar una constante
```

#### `var` — Variable (caja abierta)

Puedes cambiar lo que hay dentro cuando quieras. Como tu edad: cambia cada ano.

```swift
var edad = 28
var ciudadActual = "Madrid"

edad = 29                  // Cumpliste anos, se actualiza
ciudadActual = "Barcelona" // Te mudaste, se actualiza
```

```
  let (constante)              var (variable)
  +----------+                 +----------+
  | "Maria"  |  <-- sellada    | 28       |  <-- abierta
  +----------+                 +----------+
  No puedes cambiar            edad = 29
  el contenido                 +----------+
                               | 29       |
                               +----------+
```

**Regla de oro**: Usa `let` siempre que puedas. Solo usa `var` cuando necesites que el valor
cambie. Swift incluso te avisara si usas `var` pero nunca cambias el valor: "Oye, esto
deberia ser `let`".

---

### Tipos Basicos

Cada caja (variable) guarda un tipo especifico de dato. No puedes meter un texto donde
esperabas un numero. Los cuatro tipos basicos son:

#### Int — Numeros enteros

Para cosas que se cuentan sin decimales: edades, cantidades, anos.

```swift
var edad = 25
let cantidadHermanos = 2
var puntuacion = 1500
```

#### Double — Numeros con decimales

Para precios, medidas, temperaturas... cualquier cosa que tenga parte decimal.

```swift
let precio = 9.99
var temperatura = 36.6
let altura = 1.75
```

#### String — Texto

Cualquier texto va entre comillas dobles. Puede ser una letra, una palabra o una novela entera.

```swift
let saludo = "Hola, mundo"
var mensajeDelDia = "Hoy hace buen tiempo"
let emoji = "🎉"  // Si, los emojis tambien son texto
```

#### Bool — Verdadero o Falso

Solo tiene dos valores posibles: `true` (verdadero) o `false` (falso).
Piensa en un interruptor de luz: encendido o apagado, no hay termino medio.

```swift
let esMayorDeEdad = true
var tieneDescuento = false
let aceptoTerminos = true
```

```
+------------------+-------------------+------------------+
| TIPO             | EJEMPLO           | PARA QUE SIRVE   |
+------------------+-------------------+------------------+
| Int              | 25, -3, 1000      | Contar cosas      |
| Double           | 9.99, 3.14, -0.5  | Medir cosas       |
| String           | "Hola", "Swift"   | Texto             |
| Bool             | true, false       | Decisiones si/no  |
+------------------+-------------------+------------------+
```

#### Inferencia de tipos: Swift es listo

No necesitas decirle a Swift que tipo es cada variable. El lo deduce solo:

```swift
let nombre = "Ana"    // Swift sabe que es String
let edad = 30         // Swift sabe que es Int
let precio = 4.50     // Swift sabe que es Double
let activo = true     // Swift sabe que es Bool
```

Pero si quieres ser explicito (a veces ayuda a la claridad), puedes indicar el tipo:

```swift
let precio: Double = 9.99
let cantidad: Int = 5
let mensaje: String = "Bienvenido"
let disponible: Bool = true
```

Esto es util cuando quieres que un numero entero sea Double:

```swift
let nota: Double = 10    // Sin ": Double", Swift pensaria que es Int
```

---

### Operadores — Hacer cosas con los datos

#### Operadores aritmeticos (matematicas basicas)

```swift
let a = 10
let b = 3

let suma = a + b         // 13
let resta = a - b        // 7
let multiplicacion = a * b  // 30
let division = a / b     // 3 (division entera, sin decimales)
let resto = a % b        // 1 (el "sobrante" de dividir 10 entre 3)
```

**Ojo con la division entera**: `10 / 3` da `3`, no `3.33`. Si quieres decimales, usa Double:

```swift
let aDecimal = 10.0
let bDecimal = 3.0
let divisionExacta = aDecimal / bDecimal  // 3.3333...
```

#### Unir textos (concatenacion)

Puedes juntar textos con el operador `+`:

```swift
let nombre = "Maria"
let apellido = "Garcia"
let nombreCompleto = nombre + " " + apellido  // "Maria Garcia"
```

#### Interpolacion de cadenas — la forma moderna

En lugar de unir textos con `+`, Swift tiene una forma mas elegante con `\()`:

```swift
let nombre = "Maria"
let edad = 28

let presentacion = "Me llamo \(nombre) y tengo \(edad) anos"
// Resultado: "Me llamo Maria y tengo 28 anos"
```

Puedes poner cualquier expresion dentro de `\()`:

```swift
let precio = 15.0
let cantidad = 3
let mensaje = "Total: \(precio * Double(cantidad)) euros"
// Resultado: "Total: 45.0 euros"
```

#### Operadores de comparacion

Comparan dos valores y devuelven `true` o `false`:

```swift
let edad = 20

edad == 20   // true  (es igual a?)
edad != 18   // true  (es diferente de?)
edad > 18    // true  (es mayor que?)
edad < 25    // true  (es menor que?)
edad >= 20   // true  (es mayor o igual?)
edad <= 19   // false (es menor o igual?)
```

---

### print() — Tu Primera Herramienta

`print()` es la forma mas basica de ver que esta pasando en tu programa. Imprime texto
en la consola (esa pantalla negra donde aparecen los resultados).

```swift
print("Hola, mundo!")
// Consola: Hola, mundo!
```

Puedes imprimir variables:

```swift
let nombre = "Carlos"
let edad = 32

print(nombre)           // Carlos
print(edad)             // 32
print("Hola, \(nombre)! Tienes \(edad) anos.")
// Hola, Carlos! Tienes 32 anos.
```

Piensa en `print()` como tu "linterna" para ver que pasa dentro del programa. Cuando algo
no funcione, pon un `print()` para ver que valor tiene una variable en ese momento.

---

### Comentarios — Notas para ti mismo

Los comentarios son texto que Swift ignora completamente. Son notas para ti (o para quien
lea tu codigo despues).

```swift
// Esto es un comentario de una linea
// Swift lo ignora, es solo para humanos

let edad = 25  // Edad del usuario

/*
   Esto es un comentario
   de varias lineas.
   Util para explicaciones largas.
*/
```

**Por que son importantes?** Porque en 6 meses no vas a recordar por que escribiste
ese codigo. Los comentarios son como post-its que te dejas a ti mismo.

---

## Ejemplos de Codigo

### Archivo: `Codigo/PrimerPrograma.swift`

```swift
// MARK: - Mi primer programa en Swift
// Ejecutar con: swift Modulo00-Fundamentos/Codigo/PrimerPrograma.swift

// --- Constantes: datos que no cambian ---
let nombre = "Ana"
let apellido = "Lopez"
let anoNacimiento = 1995
let estatura: Double = 1.68

// --- Variables: datos que pueden cambiar ---
var edad = 30
var ciudad = "Sevilla"
var estaEstudiando = true

// --- Imprimir una presentacion ---
print("=== Mi Presentacion ===")
print("Nombre completo: \(nombre) \(apellido)")
print("Ano de nacimiento: \(anoNacimiento)")
print("Edad actual: \(edad)")
print("Estatura: \(estatura) m")
print("Ciudad: \(ciudad)")
print("Estudiando: \(estaEstudiando)")

// --- Operaciones basicas ---
let anoActual = 2026
let edadCalculada = anoActual - anoNacimiento
print("\nEdad calculada: \(edadCalculada) anos")

// --- Actualizando variables ---
ciudad = "Madrid"
edad = 31
print("\nDespues de mudarse:")
print("Ciudad: \(ciudad)")
print("Edad: \(edad)")

// --- Calculadora simple ---
let precioManzanas = 2.50
let cantidad = 4
let total = precioManzanas * Double(cantidad)
print("\n\(cantidad) manzanas a \(precioManzanas) euros = \(total) euros")
```

---

## Ejercicio 1: Presentacion Personal (Basico)

**Objetivo**: Practicar variables, constantes, tipos basicos y print().

**Requisitos**:
1. Crea constantes para: nombre, apellido, anoNacimiento
2. Crea variables para: edad, ciudadActual, esEstudiante, estatura (Double)
3. Imprime una presentacion completa usando interpolacion de cadenas
4. Calcula la edad a partir del ano actual (2026) y el ano de nacimiento
5. Muestra el resultado por consola con un formato legible

**Ejemplo de salida esperada**:
```
=== Ficha Personal ===
Nombre: Maria Garcia
Edad: 28 anos (nacida en 1998)
Ciudad: Valencia
Estatura: 1.65 m
Estudiante: si
```

---

## Ejercicio 2: Calculadora Basica (Intermedio)

**Objetivo**: Practicar operadores aritmeticos y mostrar resultados.

**Requisitos**:
1. Declara dos variables numericas: `numeroA` y `numeroB`
2. Calcula y muestra: suma, resta, multiplicacion, division y resto
3. Usa versiones Double para mostrar la division exacta (con decimales)
4. Muestra los resultados con formato claro

**Ejemplo de salida esperada**:
```
=== Calculadora ===
Numeros: 17 y 5
Suma:           17 + 5 = 22
Resta:          17 - 5 = 12
Multiplicacion: 17 * 5 = 85
Division entera: 17 / 5 = 3
Resto:          17 % 5 = 2
Division exacta: 17.0 / 5.0 = 3.4
```

---

## Ejercicio 3: Tienda Simple (Avanzado)

**Objetivo**: Combinar todos los conceptos para modelar un escenario real.

**Requisitos**:
1. Crea variables para un producto de tienda: nombre, precio (Double), stock (Int),
   estaEnOferta (Bool), porcentajeDescuento (Double, ejemplo: 0.15 para 15%)
2. Calcula el precio con descuento (solo si esta en oferta)
3. Pide una cantidad de compra (usa una variable) y calcula el subtotal
4. Anade un IVA del 21% al subtotal
5. Muestra un "ticket de compra" con todos los datos formateados

**Ejemplo de salida esperada**:
```
=== Ticket de Compra ===
Producto: Auriculares Bluetooth
Precio original: 49.99 euros
Descuento (15%): -7.50 euros
Precio con descuento: 42.49 euros
Cantidad: 2
Subtotal: 84.98 euros
IVA (21%): 17.85 euros
TOTAL: 102.83 euros
Stock restante: 8
```

---

## Checklist

- [ ] Entender que es programar (dar instrucciones al ordenador)
- [ ] Saber la diferencia entre `let` (constante) y `var` (variable)
- [ ] Conocer los 4 tipos basicos: Int, Double, String, Bool
- [ ] Usar print() para mostrar resultados en consola
- [ ] Usar interpolacion de cadenas: `"Hola, \(nombre)"`
- [ ] Realizar operaciones aritmeticas basicas
- [ ] Usar comentarios para documentar el codigo
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Aunque todavia no empezamos el Proyecto Integrador (semana 20), todo lo que aprendes aqui
es la base absoluta:

- **Variables y constantes** se usan en cada linea de cualquier app
- **Tipos basicos** son los ladrillos con los que construiras modelos de datos
- **print()** sera tu herramienta de depuracion mas basica
- **Interpolacion de cadenas** aparecera en cada pantalla que muestre texto al usuario

Sin estos fundamentos, nada de lo que viene despues tiene sentido. Asegurate de que te
sientes comodo con todo antes de pasar a la Leccion 02.

---

*Leccion 01 (L01) | Tu Primer Programa | Semana 1 | Modulo 00: Fundamentos*
*Siguiente: Leccion 02 (L02) — Control de Flujo y Colecciones*
