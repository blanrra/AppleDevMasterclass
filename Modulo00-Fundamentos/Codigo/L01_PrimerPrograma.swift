// ============================================
// Leccion 01: Tu Primer Programa en Swift
// AppleDevMasterclass — Modulo 00
// ============================================
// Ejecutar: swift Modulo00-Fundamentos/Codigo/L01_PrimerPrograma.swift

// MARK: - Variables y Constantes

// let = constante (no cambia)
// var = variable (puede cambiar)

let nombre = "Maria"
var edad = 25

print("Hola, me llamo \(nombre) y tengo \(edad) anos")

// Cambiar una variable
edad = 26
print("Ahora tengo \(edad) anos")

// MARK: - Tipos Basicos

let entero: Int = 42
let decimal: Double = 3.14
let texto: String = "Swift es genial"
let esVerdad: Bool = true

print("Entero: \(entero)")
print("Decimal: \(decimal)")
print("Texto: \(texto)")
print("Booleano: \(esVerdad)")

// MARK: - Type Inference (Swift deduce el tipo)

let precio = 9.99        // Swift sabe que es Double
let cantidad = 3          // Swift sabe que es Int
let producto = "iPhone"   // Swift sabe que es String

// MARK: - Operadores

let suma = 10 + 5        // 15
let resta = 10 - 3       // 7
let multiplicacion = 4 * 3  // 12
let division = 10 / 3    // 3 (division entera)
let resto = 10 % 3       // 1 (modulo)

print("Suma: \(suma), Resta: \(resta)")
print("Multiplicacion: \(multiplicacion)")
print("Division entera: \(division), Resto: \(resto)")

// MARK: - String Interpolation

let saludo = "Hola, \(nombre)! Tienes \(edad) anos."
print(saludo)

let total = Double(cantidad) * precio
print("Total: \(cantidad) x \(producto) = \(total)€")

// MARK: - Comparaciones

let esMayor = edad >= 18
print("¿Es mayor de edad? \(esMayor)")

let sonIguales = 5 == 5
let sonDiferentes = 5 != 3
print("¿5 == 5? \(sonIguales)")
print("¿5 != 3? \(sonDiferentes)")

print("\n=== ¡Felicidades! Has ejecutado tu primer programa en Swift ===")
