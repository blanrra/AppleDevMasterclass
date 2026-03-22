# Leccion 01: Swift 6 Language

**Modulo 00: Fundamentos** | Semanas 1-2

---

## Cupertino MCP

```bash
# Consultar antes de iniciar la leccion
cupertino search --source swift-book "language guide"
cupertino search "swift programming language"
cupertino search "Swift type inference"
cupertino search "Swift optionals"
cupertino search "Swift closures"
cupertino search "Swift error handling"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [What's New in Swift](https://developer.apple.com/videos/play/wwdc2024/10136/) | **Esencial** — Novedades Swift 6 |
| WWDC23 | [What's New in Swift](https://developer.apple.com/videos/play/wwdc2023/10164/) | Contexto de Swift 5.9 |
| 🇪🇸 | [Julio Cesar Fernandez — Swift 6](https://www.youtube.com/@AppleCodingAcademy) | Resumen en espanol |
| EN | [Paul Hudson — 100 Days of Swift (Days 1-12)](https://www.hackingwithswift.com/100) | Fundamentos paso a paso |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Swift 6?

Swift 6 no es simplemente "otra version" del lenguaje. Representa un cambio fundamental en como Apple concibe la seguridad del codigo. Mientras otros lenguajes anaden features sin un hilo conductor, cada version de Swift refuerza un principio: **hacer que el codigo incorrecto sea imposible de escribir**.

Swift 6 introduce strict concurrency checking por defecto, lo que significa que el compilador detecta data races en tiempo de compilacion. Esto es revolucionario — la mayoria de lenguajes solo descubren estos bugs en produccion.

### Caracteristicas Fundamentales

#### 1. Type Inference (Inferencia de Tipos)

Swift infiere tipos automaticamente, reduciendo boilerplate mientras mantiene total seguridad de tipos. El compilador sabe exactamente que tipo tiene cada variable.

```swift
let mensaje = "Hola, Swift 6"        // String
let numero = 42                       // Int
let precio = 29.99                    // Double
let esValido = true                   // Bool

// Puedes verificar el tipo inferido
print(type(of: mensaje))  // String
```

**Por que importa**: En lenguajes como Objective-C, la falta de inferencia obligaba a escribir tipos redundantes. Swift elimina esa friccion sin sacrificar seguridad.

#### 2. Optionals (Opcionales)

Los optionals son la respuesta de Swift al "billion-dollar mistake" de null references. Un optional te obliga a considerar la ausencia de valor explicitamente.

```swift
var nombre: String? = nil
var edad: Int? = 25

// if-let: desempaquetado seguro
if let edadActual = edad {
    print("La edad es \(edadActual)")
}

// Shorthand if-let (Swift 5.7+)
if let edad {
    print("La edad es \(edad)")
}

// guard-let: salida temprana
func procesarUsuario(nombre: String?) {
    guard let nombre else {
        print("Nombre requerido")
        return
    }
    print("Hola, \(nombre)")
}

// Nil-coalescing operator
let edadFinal = edad ?? 0

// Optional chaining
struct Direccion { var ciudad: String }
struct Persona { var direccion: Direccion? }
let persona = Persona(direccion: nil)
let ciudad = persona.direccion?.ciudad ?? "Desconocida"
```

#### Flujo de Desempaquetado de Optionals

```
  var nombre: String? = valor
         │
         ▼
    ┌─────────┐     ┌──────────────────────────────┐
    │ es nil? │─Sí─▶│ guard let → return / default  │
    └────┬────┘     │ ?? → valor por defecto        │
         │ No       └──────────────────────────────┘
         ▼
    ┌──────────────┐
    │ if let nombre │──▶ usar 'nombre' (ya es String, no String?)
    └──────────────┘
```

#### 3. Closures (Cierres)

Los closures son bloques de codigo autocontenidos que pueden pasarse como parametros. Son la base de muchas APIs de Swift y SwiftUI.

```swift
// Closure basico
let saludar = { print("Hola, Swift 6!") }
saludar()

// Con parametros y retorno
let multiplicar: (Int, Int) -> Int = { a, b in a * b }
print(multiplicar(5, 3))  // 15

// Trailing closure syntax
let numeros = [3, 1, 4, 1, 5, 9, 2, 6]
let ordenados = numeros.sorted { $0 < $1 }

// Closures como parametros de funcion
func ejecutar(_ a: Int, _ b: Int, operacion: (Int, Int) -> Int) -> Int {
    operacion(a, b)
}
let suma = ejecutar(10, 5) { $0 + $1 }  // 15

// map, filter, reduce
let pares = numeros.filter { $0 % 2 == 0 }        // [4, 2, 6]
let dobles = numeros.map { $0 * 2 }                // [6, 2, 8, ...]
let total = numeros.reduce(0) { $0 + $1 }          // 31
```

#### 4. Structs vs Classes

La distincion mas importante en Swift: value types vs reference types.

```swift
// STRUCT (Value Type) - se COPIA al asignar
struct Punto {
    var x: Int
    var y: Int

    mutating func mover(dx: Int, dy: Int) {
        x += dx
        y += dy
    }
}

var p1 = Punto(x: 0, y: 0)
var p2 = p1           // p2 es una COPIA independiente
p2.mover(dx: 5, dy: 5)
print(p1)  // Punto(x: 0, y: 0) — no cambio
print(p2)  // Punto(x: 5, y: 5)

// CLASS (Reference Type) - se COMPARTE al asignar
class Contador {
    var valor: Int
    init(valor: Int) { self.valor = valor }
}

let c1 = Contador(valor: 0)
let c2 = c1           // c2 apunta al MISMO objeto
c2.valor = 42
print(c1.valor)  // 42 — si cambio!
```

**Regla de Apple**: Usa struct por defecto. Solo usa class cuando necesites reference semantics, herencia, o identidad de objeto (ej: ObservableObject legacy).

#### Struct vs Class — Diagrama Visual

```
  STRUCT (Value Type)              CLASS (Reference Type)
  Cada variable = copia propia     Ambas variables = mismo objeto

  var p1 = Punto(x: 0)            let c1 = Contador(valor: 0)
  var p2 = p1                      let c2 = c1

  ┌──────────────┐                 ┌──────────┐
  │ p1: x = 0    │                 │ c1 ──────┼───┐
  └──────────────┘                 └──────────┘   │
  ┌──────────────┐                                ▼
  │ p2: x = 99   │  ← copia       ┌──────────────────┐
  └──────────────┘   independiente │ valor = 99       │ ← HEAP
                                   └──────────────────┘
  p1.x == 0  ✅                              ▲
  p2.x == 99 ✅                    ┌──────────┐   │
  (cada uno su valor)              │ c2 ──────┼───┘
                                   └──────────┘
                                   c1.valor == 99  ⚠️
                                   c2.valor == 99
                                   (ambos ven el cambio!)
```

#### 5. Enums con Associated Values

Los enums de Swift son mucho mas poderosos que en otros lenguajes.

```swift
enum EstadoPedido {
    case pendiente
    case procesando(progreso: Double)
    case completado(fecha: Date)
    case cancelado(razon: String)
}

func describir(_ estado: EstadoPedido) -> String {
    switch estado {
    case .pendiente:
        return "Esperando procesamiento"
    case .procesando(let progreso):
        return "Procesando: \(Int(progreso * 100))%"
    case .completado(let fecha):
        return "Completado el \(fecha)"
    case .cancelado(let razon):
        return "Cancelado: \(razon)"
    }
}

// Enum con raw values
enum Prioridad: Int, CaseIterable, Comparable {
    case baja = 1
    case media = 2
    case alta = 3

    static func < (lhs: Prioridad, rhs: Prioridad) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
```

#### 6. Protocolos Basicos

Los protocolos definen un contrato que los tipos deben cumplir. Son la base del Protocol-Oriented Programming (leccion 02).

```swift
protocol Describible {
    var descripcion: String { get }
    func resumen() -> String
}

struct Producto: Describible {
    let nombre: String
    let precio: Decimal

    var descripcion: String {
        "\(nombre) — $\(precio)"
    }

    func resumen() -> String {
        "Producto: \(descripcion)"
    }
}
```

#### 7. Genericos Basicos

Los genericos permiten escribir codigo flexible y reutilizable.

```swift
func intercambiar<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

struct Pila<Element> {
    private var elementos: [Element] = []

    var estaVacia: Bool { elementos.isEmpty }
    var tope: Element? { elementos.last }

    mutating func apilar(_ elemento: Element) {
        elementos.append(elemento)
    }

    mutating func desapilar() -> Element? {
        elementos.popLast()
    }
}

var pila = Pila<Int>()
pila.apilar(1)
pila.apilar(2)
print(pila.desapilar()!)  // 2
```

#### 8. Error Handling

Swift tiene un sistema robusto de manejo de errores con do-catch-throw.

```swift
enum ErrorRed: Error, LocalizedError {
    case sinConexion
    case timeout(segundos: Int)
    case respuestaInvalida(codigo: Int)

    var errorDescription: String? {
        switch self {
        case .sinConexion: return "Sin conexion a internet"
        case .timeout(let seg): return "Timeout despues de \(seg)s"
        case .respuestaInvalida(let cod): return "Respuesta invalida: \(cod)"
        }
    }
}

func obtenerDatos(url: String) throws -> String {
    guard !url.isEmpty else {
        throw ErrorRed.sinConexion
    }
    return "Datos de \(url)"
}

// do-catch
do {
    let datos = try obtenerDatos(url: "https://api.example.com")
    print(datos)
} catch let error as ErrorRed {
    print("Error de red: \(error.localizedDescription)")
} catch {
    print("Error desconocido: \(error)")
}

// try? — convierte error en nil
let resultado = try? obtenerDatos(url: "")  // nil
```

---

## Ejemplos de Codigo

### Archivo: `Codigo/Swift6Basics.swift`

```swift
import Foundation

// MARK: - Sistema de Gestion de Tareas

struct Tarea: Identifiable, CustomStringConvertible {
    let id = UUID()
    var titulo: String
    var descripcion: String
    var completada: Bool = false
    var prioridad: Prioridad
    let fechaCreacion = Date()

    enum Prioridad: Int, CaseIterable, Comparable {
        case baja = 1, media = 2, alta = 3

        var emoji: String {
            switch self {
            case .baja: return "🟢"
            case .media: return "🟡"
            case .alta: return "🔴"
            }
        }

        static func < (lhs: Prioridad, rhs: Prioridad) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    var description: String {
        let estado = completada ? "✅" : "⬜️"
        return "\(estado) \(prioridad.emoji) \(titulo)"
    }
}

struct GestorTareas {
    private var tareas: [Tarea] = []

    mutating func agregar(_ tarea: Tarea) {
        tareas.append(tarea)
    }

    mutating func completar(id: UUID) {
        guard let idx = tareas.firstIndex(where: { $0.id == id }) else { return }
        tareas[idx].completada = true
    }

    func filtrar(prioridad: Tarea.Prioridad) -> [Tarea] {
        tareas.filter { $0.prioridad == prioridad }
    }

    func pendientes() -> [Tarea] {
        tareas.filter { !$0.completada }.sorted { $0.prioridad > $1.prioridad }
    }

    func listar() {
        tareas.forEach { print($0) }
    }
}

// MARK: - Demo

var gestor = GestorTareas()
gestor.agregar(Tarea(titulo: "Aprender Swift 6", descripcion: "Completar leccion 01", prioridad: .alta))
gestor.agregar(Tarea(titulo: "Practicar closures", descripcion: "Hacer ejercicios", prioridad: .media))
gestor.agregar(Tarea(titulo: "Leer documentacion", descripcion: "Cupertino MCP", prioridad: .baja))

print("=== Todas las tareas ===")
gestor.listar()

print("\n=== Pendientes (ordenadas por prioridad) ===")
for tarea in gestor.pendientes() {
    print(tarea)
}
```

---

## Ejercicio 1: Sistema de Biblioteca (Basico)

**Objetivo**: Practicar structs, enums, arrays y funciones.

**Requisitos**:
1. Crear enum `Genero` con: novela, poesia, teatro, ciencia, historia
2. Crear struct `Libro` con: titulo, autor, ano, genero, prestado
3. Crear struct `Biblioteca` con funciones para:
   - Agregar libros
   - Prestar un libro por titulo
   - Devolver un libro
   - Listar libros disponibles
   - Buscar por genero

---

## Ejercicio 2: Calculadora Generica (Intermedio)

**Objetivo**: Practicar genericos, error handling y closures.

**Requisitos**:
1. Crear una calculadora generica que funcione con Int, Double y Float
2. Implementar operaciones: sumar, restar, multiplicar, dividir
3. La division debe lanzar error si el divisor es cero
4. Agregar historial de operaciones usando closures
5. Implementar `undo()` que revierta la ultima operacion

---

## Ejercicio 3: Sistema de Inventario (Avanzado)

**Objetivo**: Combinar todos los conceptos de la leccion.

**Requisitos**:
1. Protocolo `Almacenable` con propiedades: id, nombre, cantidad
2. Enum `CategoriaProducto` con associated values para metadata
3. Struct `Producto` que implemente `Almacenable`
4. Struct `Inventario<T: Almacenable>` generico con:
   - Agregar/eliminar items
   - Busqueda por nombre (case-insensitive)
   - Filtrado por cantidad minima
   - Resumen estadistico (total items, valor total, promedio)
5. Manejo de errores para operaciones invalidas

---

## Recursos Adicionales

- **Cupertino**: `cupertino search --source swift-book "language guide"`
- **Paul Hudson**: hackingwithswift.com — Swift tutorials
- **Julio Cesar Fernandez**: acodingacademy.com — Swift 6 en espanol

---

## Checklist

- [ ] Entender type inference y cuando declarar tipos explicitamente
- [ ] Dominar optionals: if-let, guard-let, nil-coalescing, optional chaining
- [ ] Usar closures como parametros y trailing closure syntax
- [ ] Diferenciar structs (value) vs classes (reference) y cuando usar cada uno
- [ ] Crear enums con associated values y raw values
- [ ] Implementar protocolos basicos
- [ ] Usar genericos para codigo reutilizable
- [ ] Manejar errores con do-catch, try?, y errores custom
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Los conceptos de esta leccion son la base de TODO lo que viene despues. En el Proyecto Integrador usaras:
- **Structs** para tus modelos de datos
- **Enums** para estados de la app
- **Optionals** en todas partes (datos de red, input de usuario)
- **Genericos** para tu capa de networking
- **Error handling** para toda operacion que pueda fallar

---

*Leccion 01 | Swift 6 Language | Semanas 1-2 | Modulo 00: Fundamentos*
*Siguiente: Leccion 02 — POP y Genericos Avanzados*
