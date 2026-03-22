// ============================================
// Leccion 03: Funciones y Closures
// AppleDevMasterclass — Modulo 00
// ============================================
// Ejecutar: swift Modulo00-Fundamentos/Codigo/L03_FuncionesClosures.swift

// MARK: - 1. Funcion simple (sin parametros, sin retorno)

// Una funcion es un bloque de codigo reutilizable
// Se define con "func", un nombre, y parentesis
func saludar() {
    print("¡Hola! Bienvenido a Swift")
}

// Llamar (ejecutar) la funcion
saludar()

// MARK: - 2. Funcion con parametros

// Los parametros son datos que le pasamos a la funcion
func saludarA(nombre: String) {
    print("¡Hola, \(nombre)! ¿Como estas?")
}

saludarA(nombre: "Maria")
saludarA(nombre: "Carlos")

// MARK: - 3. Funcion con valor de retorno

// -> TipoRetorno indica que la funcion devuelve un valor
func sumar(a: Int, b: Int) -> Int {
    return a + b
}

let resultado = sumar(a: 10, b: 5)
print("10 + 5 = \(resultado)")

// Si la funcion tiene una sola linea, el return es implicito
func multiplicar(a: Int, b: Int) -> Int {
    a * b  // No necesita "return" porque es una sola expresion
}

print("4 x 3 = \(multiplicar(a: 4, b: 3))")

// MARK: - 4. Etiquetas de argumento (argument labels)

// Swift permite tener un nombre "externo" y otro "interno"
// Esto hace que las llamadas se lean como oraciones en ingles

func mover(desde origen: String, hasta destino: String) {
    print("Moviendo desde \(origen) hasta \(destino)")
}

// Al llamarla, usamos las etiquetas externas: "desde" y "hasta"
mover(desde: "Madrid", hasta: "Barcelona")

// Usar _ para omitir la etiqueta externa
func saludarPersona(_ nombre: String) {
    print("¡Hola, \(nombre)!")
}

// Ahora no necesitamos escribir la etiqueta
saludarPersona("Laura")

// MARK: - 5. Parametros con valor por defecto

// Si un parametro tiene valor por defecto, es opcional al llamar
func configurar(idioma: String = "espanol", tema: String = "claro") {
    print("Configuracion: idioma=\(idioma), tema=\(tema)")
}

configurar()                              // Usa ambos valores por defecto
configurar(idioma: "ingles")              // Solo cambia el idioma
configurar(idioma: "frances", tema: "oscuro")  // Cambia ambos

// MARK: - 6. Funciones como valores (first-class citizens)

// En Swift, las funciones son valores: se pueden guardar en variables
// El tipo de una funcion se escribe como (Parametros) -> Retorno

func doblar(_ numero: Int) -> Int {
    numero * 2
}

func triplicar(_ numero: Int) -> Int {
    numero * 3
}

// Guardamos una funcion en una variable
var operacion: (Int) -> Int = doblar
print("\nDoblar 5: \(operacion(5))")    // 10

// Cambiamos la variable a otra funcion
operacion = triplicar
print("Triplicar 5: \(operacion(5))")  // 15

// MARK: - 7. Closures: funciones anonimas

// Un closure es una funcion sin nombre
// Sintaxis: { (parametros) -> Retorno in cuerpo }

let saludoClosure = { (nombre: String) -> String in
    return "¡Hola, \(nombre)! (desde un closure)"
}

print("\n\(saludoClosure("Ana"))")

// Closure simple sin parametros
let despedida = {
    print("¡Hasta luego!")
}
despedida()

// MARK: - 8. Closures como parametros de funcion

// Muchas funciones de Swift aceptan closures como parametros
// Esto permite personalizar el comportamiento

func ejecutarOperacion(_ a: Int, _ b: Int, operacion: (Int, Int) -> Int) -> Int {
    return operacion(a, b)
}

// Pasamos un closure como argumento
let suma = ejecutarOperacion(10, 5, operacion: { (a, b) in a + b })
print("\n10 + 5 = \(suma)")

// MARK: - 9. Trailing closure (closure al final)

// Si el ultimo parametro es un closure, se puede escribir fuera de los parentesis
// Esto hace el codigo mas legible

let resta = ejecutarOperacion(10, 3) { (a, b) in
    a - b
}
print("10 - 3 = \(resta)")

// Swift puede inferir los tipos, asi que se simplifica aun mas
let producto = ejecutarOperacion(4, 5) { $0 * $1 }
// $0 = primer parametro, $1 = segundo parametro
print("4 x 5 = \(producto)")

// MARK: - 10. map, filter, reduce — Operaciones funcionales

// Estas funciones usan closures para transformar colecciones
let numeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

// map: transforma cada elemento
// Ejemplo: duplicar cada numero
let duplicados = numeros.map { $0 * 2 }
print("\nOriginal:   \(numeros)")
print("Duplicados: \(duplicados)")

// filter: filtra elementos que cumplan una condicion
// Ejemplo: quedarnos solo con los pares
let pares = numeros.filter { $0 % 2 == 0 }
print("Pares:      \(pares)")

// reduce: combina todos los elementos en un solo valor
// Ejemplo: sumar todos los numeros
// El primer argumento (0) es el valor inicial
let sumaTotal = numeros.reduce(0) { acumulado, actual in
    acumulado + actual
}
print("Suma total: \(sumaTotal)")

// Version corta con $0 y $1
let productoTotal = [1, 2, 3, 4, 5].reduce(1) { $0 * $1 }
print("Producto:   \(productoTotal)")  // 1*2*3*4*5 = 120

// MARK: - 11. sorted(by:) — Ordenar con closures

let nombres = ["Zara", "Ana", "Miguel", "Elena", "Carlos"]

// Ordenar alfabeticamente (por defecto, ascendente)
let ordenados = nombres.sorted()
print("\nOrdenados: \(ordenados)")

// Ordenar de forma personalizada con un closure
let porLongitud = nombres.sorted { $0.count < $1.count }
print("Por longitud: \(porLongitud)")

// Ordenar numeros de mayor a menor
let descendente = numeros.sorted { $0 > $1 }
print("Descendente: \(descendente)")

// MARK: - 12. Encadenando operaciones

// Podemos combinar map, filter, reduce en cadena
let resultadoFinal = numeros
    .filter { $0 % 2 == 0 }      // Solo pares: [2, 4, 6, 8, 10]
    .map { $0 * $0 }              // Elevar al cuadrado: [4, 16, 36, 64, 100]
    .reduce(0, +)                 // Sumar todo: 220

print("\nSuma de cuadrados de pares: \(resultadoFinal)")

print("\n=== ¡Leccion 03 completada! Ya dominas funciones y closures ===")
