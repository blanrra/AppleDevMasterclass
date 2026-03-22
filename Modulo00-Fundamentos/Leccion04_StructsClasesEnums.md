# Leccion 04: Structs, Clases y Enums

**Modulo 00: Fundamentos** | Semana 4

---

## TL;DR — Resumen en 2 minutos

- **Structs**: tus propios tipos de datos — como crear un molde para galletas (value type, se copian)
- **Clases**: similares a structs pero se comparten — como un documento de Google Docs (reference type)
- **Propiedades y metodos**: los datos y acciones que tiene tu tipo
- **Enums**: un conjunto fijo de opciones — como los dias de la semana o estados de un pedido
- **Regla de Swift**: preferir structs sobre clases, a menos que necesites herencia o referencia compartida

> Herramienta recomendada: **Swift Playgrounds** en iPad o Mac

---

## Cupertino MCP

```bash
# Consultar antes de iniciar la leccion
cupertino search --source swift-book "structures and classes"
cupertino search --source swift-book "enumerations"
cupertino search "Swift value types"
cupertino search "Swift properties methods"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC15 | [Building Better Apps with Value Types](https://developer.apple.com/videos/play/wwdc2015/414/) | Por que structs |
| EN | [Paul Hudson — Structs vs Classes](https://www.hackingwithswift.com/100/8) | Comparacion clara |
| ES | Julio Cesar Fernandez — Tipos en Swift | Value vs Reference |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Structs — Creando Tus Propios Tipos

Imagina un **molde para galletas**. Defines la forma una vez (la struct) y luego haces tantas galletas como quieras (las instancias). Cada galleta es independiente — si le pones chocolate a una, las demas no cambian.

Un struct es tu forma de crear tipos de datos a medida. Swift ya tiene tipos como `String`, `Int`, `Array` — y todos son structs internamente.

#### Tu primera struct

```swift
struct Persona {
    // Propiedades almacenadas (stored properties)
    var nombre: String
    var edad: Int
    var email: String
}

// Crear una instancia — Swift genera el inicializador automaticamente
var carlos = Persona(nombre: "Carlos", edad: 30, email: "carlos@mail.com")
print(carlos.nombre)  // Carlos

// Modificar una propiedad
carlos.edad = 31
print(carlos.edad)  // 31
```

Swift genera automaticamente un **memberwise initializer** — un `init` que pide cada propiedad en orden. No necesitas escribirlo tu.

#### Propiedades computadas (computed properties)

Son propiedades que se calculan cada vez que las pides, en lugar de almacenar un valor.

```swift
struct Rectangulo {
    var ancho: Double
    var alto: Double

    // Propiedad computada — se calcula, no se almacena
    var area: Double {
        ancho * alto
    }

    var perimetro: Double {
        2 * (ancho + alto)
    }

    var descripcion: String {
        "Rectangulo de \(ancho) x \(alto) (area: \(area))"
    }
}

let rect = Rectangulo(ancho: 5, alto: 3)
print(rect.area)         // 15.0
print(rect.perimetro)    // 16.0
print(rect.descripcion)  // Rectangulo de 5.0 x 3.0 (area: 15.0)
```

#### Metodos

Los metodos son funciones que pertenecen al tipo. Pueden acceder a las propiedades del tipo directamente.

```swift
struct Contador {
    var valor: Int = 0

    // Metodo regular — solo lee propiedades
    func mostrar() {
        print("Valor actual: \(valor)")
    }

    // Metodo mutating — modifica propiedades
    mutating func incrementar() {
        valor += 1
    }

    mutating func incrementar(en cantidad: Int) {
        valor += cantidad
    }

    mutating func reiniciar() {
        valor = 0
    }
}

var contador = Contador()
contador.mostrar()           // Valor actual: 0
contador.incrementar()
contador.incrementar(en: 5)
contador.mostrar()           // Valor actual: 6
contador.reiniciar()
contador.mostrar()           // Valor actual: 0
```

**Palabra clave `mutating`**: Como las structs son value types, Swift te obliga a marcar explicitamente los metodos que cambian propiedades. Esto es una medida de seguridad — sabes de un vistazo que metodos modifican el estado.

#### Inicializadores custom

Puedes crear tus propios inicializadores ademas del automatico.

```swift
struct Temperatura {
    var celsius: Double

    // Init custom — a partir de Fahrenheit
    init(fahrenheit: Double) {
        self.celsius = (fahrenheit - 32) / 1.8
    }

    // Init custom — a partir de Kelvin
    init(kelvin: Double) {
        self.celsius = kelvin - 273.15
    }

    // Init por defecto (celsius directo)
    init(celsius: Double) {
        self.celsius = celsius
    }

    var fahrenheit: Double {
        celsius * 1.8 + 32
    }
}

let t1 = Temperatura(celsius: 100)
let t2 = Temperatura(fahrenheit: 212)
let t3 = Temperatura(kelvin: 373.15)

print(t1.celsius)  // 100.0
print(t2.celsius)  // 100.0
print(t3.celsius)  // 100.0
```

---

### Value Type — Copias Independientes

Este es el concepto mas importante de los structs. Cuando asignas un struct a otra variable, se crea una **copia completamente independiente**.

```swift
struct Punto {
    var x: Int
    var y: Int
}

var puntoA = Punto(x: 0, y: 0)
var puntoB = puntoA              // puntoB es una COPIA independiente

puntoB.x = 10
puntoB.y = 20

print(puntoA)  // Punto(x: 0, y: 0)   — NO cambio
print(puntoB)  // Punto(x: 10, y: 20) — Solo este cambio
```

#### Diagrama: Comportamiento de Value Types

```
  ANTES de modificar puntoB:

  puntoA               puntoB (copia)
  ┌─────────────┐      ┌─────────────┐
  │  x: 0       │      │  x: 0       │  ← copia del valor
  │  y: 0       │      │  y: 0       │
  └─────────────┘      └─────────────┘
  (Stack)               (Stack)

  DESPUES de modificar puntoB:

  puntoA               puntoB
  ┌─────────────┐      ┌─────────────┐
  │  x: 0       │      │  x: 10      │  ← solo este cambio
  │  y: 0       │      │  y: 20      │
  └─────────────┘      └─────────────┘

  Cada variable tiene su propia copia.
  Modificar una NO afecta a la otra.
```

---

### Clases — Cuando Necesitas Compartir

Imagina un **documento de Google Docs**. Cuando compartes el enlace con alguien, ambos ven y editan el *mismo* documento. No hay copias — todos trabajan sobre el mismo dato.

Eso es una clase: cuando asignas una instancia de clase a otra variable, ambas variables apuntan al **mismo objeto** en memoria.

```swift
class CuentaBancaria {
    var titular: String
    var saldo: Double

    init(titular: String, saldo: Double) {
        self.titular = titular
        self.saldo = saldo
    }

    func depositar(_ monto: Double) {
        saldo += monto
        print("\(titular): deposito de $\(monto). Saldo: $\(saldo)")
    }

    func retirar(_ monto: Double) {
        guard saldo >= monto else {
            print("\(titular): fondos insuficientes")
            return
        }
        saldo -= monto
        print("\(titular): retiro de $\(monto). Saldo: $\(saldo)")
    }

    // deinit se ejecuta cuando el objeto se libera de memoria
    deinit {
        print("Cuenta de \(titular) cerrada")
    }
}

let cuentaOriginal = CuentaBancaria(titular: "Carlos", saldo: 1000)
let otraReferencia = cuentaOriginal  // NO es copia — es el MISMO objeto

otraReferencia.depositar(500)
print(cuentaOriginal.saldo)  // 1500 — ambas ven el cambio!
```

#### Diferencias clave con structs

| Aspecto | Struct | Clase |
|---------|--------|-------|
| Tipo | Value type (se copia) | Reference type (se comparte) |
| Memoria | Stack (rapido) | Heap (mas lento) |
| Init automatico | Si (memberwise) | No (debes escribirlo) |
| `mutating` | Necesario para cambiar propiedades | No necesario |
| Herencia | No | Si |
| `deinit` | No | Si |
| `let` constante | No puedes cambiar propiedades | Puedes cambiar propiedades (la referencia es constante, no el objeto) |

Nota importante sobre `let`:

```swift
// Struct con let — NO puedes cambiar nada
let puntoFijo = Punto(x: 0, y: 0)
// puntoFijo.x = 5  // ERROR: Cannot assign to property

// Clase con let — SI puedes cambiar propiedades
let cuenta = CuentaBancaria(titular: "Ana", saldo: 100)
cuenta.depositar(50)  // Funciona! let protege la referencia, no el contenido
```

#### Herencia (introduccion basica)

Las clases pueden heredar propiedades y metodos de otra clase.

```swift
class Vehiculo {
    var velocidadActual: Double = 0

    func describir() -> String {
        "Viajando a \(velocidadActual) km/h"
    }
}

class Bicicleta: Vehiculo {
    var tieneCesta: Bool = false

    override func describir() -> String {
        var desc = super.describir()
        if tieneCesta {
            desc += " (con cesta)"
        }
        return desc
    }
}

let bici = Bicicleta()
bici.velocidadActual = 15
bici.tieneCesta = true
print(bici.describir())  // Viajando a 15.0 km/h (con cesta)
```

---

### Struct vs Class — Cuando Usar Cada Uno

```
  ┌──────────────────────────────────────────────────────────────┐
  │                DECIDE: Struct o Class?                       │
  │                                                              │
  │  Necesitas herencia?                                         │
  │    SI ──▶ Class                                              │
  │    NO ──▼                                                    │
  │                                                              │
  │  Necesitas que multiples partes del codigo                   │
  │  compartan el MISMO objeto?                                  │
  │    SI ──▶ Class                                              │
  │    NO ──▼                                                    │
  │                                                              │
  │  Necesitas deinit (cleanup al destruirse)?                   │
  │    SI ──▶ Class                                              │
  │    NO ──▼                                                    │
  │                                                              │
  │  ──▶ STRUCT (opcion por defecto)                             │
  └──────────────────────────────────────────────────────────────┘
```

**La regla de Apple**: Usa `struct` por defecto. La inmensa mayoria de los tipos en Swift (incluidos `String`, `Array`, `Dictionary`, `Int`, `Bool`) son structs. Solo usa `class` cuando realmente necesites referencia compartida o herencia.

#### El mismo dato, diferente comportamiento

```swift
// Version STRUCT
struct ConfigStruct {
    var tema: String = "claro"
}

var configA = ConfigStruct()
var configB = configA       // COPIA
configB.tema = "oscuro"
print(configA.tema)  // "claro"  — configA no cambio
print(configB.tema)  // "oscuro"

// Version CLASS
class ConfigClass {
    var tema: String = "claro"
}

let configX = ConfigClass()
let configY = configX       // MISMA REFERENCIA
configY.tema = "oscuro"
print(configX.tema)  // "oscuro"  — configX SI cambio!
print(configY.tema)  // "oscuro"
```

---

### Enums — Opciones Finitas

Piensa en un **semaforo**: tiene exactamente tres estados posibles (rojo, amarillo, verde). No puede estar en "azul" o "morado". Un enum modela exactamente esto — un conjunto cerrado y finito de opciones.

#### Enum basico

```swift
enum DiaSemana {
    case lunes, martes, miercoles, jueves, viernes
    case sabado, domingo
}

var hoy = DiaSemana.miercoles

// Una vez que Swift conoce el tipo, puedes abreviar con el punto
hoy = .viernes

// Switch con enum — debe ser exhaustivo (cubrir todos los casos)
switch hoy {
case .lunes, .martes, .miercoles, .jueves, .viernes:
    print("Dia laboral")
case .sabado, .domingo:
    print("Fin de semana!")
}
```

#### Enums con raw values

Puedes asociar un valor fijo (String, Int, etc.) a cada caso.

```swift
enum Planeta: Int {
    case mercurio = 1, venus, tierra, marte   // 1, 2, 3, 4 automatico
    case jupiter, saturno, urano, neptuno     // 5, 6, 7, 8
}

print(Planeta.tierra.rawValue)  // 3

// Crear desde raw value (puede fallar, por eso es opcional)
if let planeta = Planeta(rawValue: 3) {
    print(planeta)  // tierra
}

enum Moneda: String {
    case dolar = "USD"
    case euro = "EUR"
    case peso = "MXN"
    case sol = "PEN"
}

print(Moneda.euro.rawValue)  // EUR
```

#### Enums con associated values (valores asociados)

Esta es la caracteristica **mas poderosa** de los enums en Swift. Cada caso puede llevar datos adicionales de diferente tipo.

```swift
enum EstadoPedido {
    case pendiente
    case procesando(progreso: Double)
    case enviado(tracking: String, estimado: String)
    case entregado(fecha: String)
    case cancelado(motivo: String)
}

func describirEstado(_ estado: EstadoPedido) -> String {
    switch estado {
    case .pendiente:
        return "Tu pedido esta pendiente de procesamiento"
    case .procesando(let progreso):
        return "Procesando: \(Int(progreso * 100))% completado"
    case .enviado(let tracking, let estimado):
        return "Enviado! Tracking: \(tracking). Llega: \(estimado)"
    case .entregado(let fecha):
        return "Entregado el \(fecha)"
    case .cancelado(let motivo):
        return "Cancelado: \(motivo)"
    }
}

let miPedido = EstadoPedido.enviado(tracking: "MX12345", estimado: "25 de marzo")
print(describirEstado(miPedido))
// Enviado! Tracking: MX12345. Llega: 25 de marzo
```

#### Metodos y propiedades en enums

Los enums pueden tener metodos y propiedades computadas, igual que los structs.

```swift
enum Estacion {
    case primavera, verano, otono, invierno

    var emoji: String {
        switch self {
        case .primavera: return "🌸"
        case .verano: return "☀️"
        case .otono: return "🍂"
        case .invierno: return "❄️"
        }
    }

    var temperaturaPromedio: String {
        switch self {
        case .primavera: return "15-20 C"
        case .verano: return "25-35 C"
        case .otono: return "10-18 C"
        case .invierno: return "0-10 C"
        }
    }

    func siguiente() -> Estacion {
        switch self {
        case .primavera: return .verano
        case .verano: return .otono
        case .otono: return .invierno
        case .invierno: return .primavera
        }
    }
}

let ahora = Estacion.primavera
print("\(ahora.emoji) Temperatura: \(ahora.temperaturaPromedio)")
print("Siguiente: \(ahora.siguiente().emoji)")
```

---

### Poniendolo Todo Junto

Un ejemplo que combina struct, class y enum modelando un sistema real.

```swift
// ENUM — Estados fijos del pedido
enum EstadoOrden {
    case creada
    case pagada(metodo: String)
    case enviada(tracking: String)
    case completada
}

// STRUCT — Cada producto es un valor independiente
struct Producto {
    let nombre: String
    let precio: Double
}

// STRUCT — Cada orden contiene productos y un estado
struct Orden {
    let id: Int
    var productos: [Producto]
    var estado: EstadoOrden

    var total: Double {
        productos.reduce(0) { $0 + $1.precio }
    }

    func resumen() -> String {
        let items = productos.map { $0.nombre }.joined(separator: ", ")
        return "Orden #\(id): [\(items)] — Total: $\(total)"
    }
}

// CLASS — El servicio se comparte en toda la app
class ServicioPedidos {
    var ordenes: [Orden] = []
    private var siguienteId = 1

    func crearOrden(productos: [Producto]) -> Orden {
        let orden = Orden(id: siguienteId, productos: productos, estado: .creada)
        ordenes.append(orden)
        siguienteId += 1
        return orden
    }

    func resumenCompleto() {
        print("=== Resumen de Pedidos ===")
        for orden in ordenes {
            print(orden.resumen())
        }
        let total = ordenes.reduce(0) { $0 + $1.total }
        print("Total general: $\(total)")
    }
}

// DEMO
let servicio = ServicioPedidos()

let orden1 = servicio.crearOrden(productos: [
    Producto(nombre: "Laptop", precio: 999.99),
    Producto(nombre: "Mouse", precio: 29.99)
])

let orden2 = servicio.crearOrden(productos: [
    Producto(nombre: "Teclado", precio: 79.99)
])

servicio.resumenCompleto()
```

---

## Ejercicio 1: Persona con Presentacion (Basico)

**Objetivo**: Practicar structs con propiedades almacenadas, computadas y metodos.

**Requisitos**:
1. Crear struct `Persona` con propiedades: nombre, apellido, edad, email
2. Agregar propiedad computada `nombreCompleto` que combine nombre y apellido
3. Agregar propiedad computada `esMayorDeEdad` que retorne Bool
4. Agregar metodo `presentarse()` que imprima una presentacion amigable
5. Crear al menos 3 instancias y demostrar que son copias independientes

```swift
// Ejemplo de uso esperado:
var persona = Persona(nombre: "Carlos", apellido: "Lopez", edad: 30, email: "carlos@mail.com")
persona.presentarse()
// "Hola, soy Carlos Lopez. Tengo 30 anos y mi email es carlos@mail.com"
```

---

## Ejercicio 2: Cuenta Bancaria con Referencia (Intermedio)

**Objetivo**: Practicar clases, reference types y entender la diferencia con structs.

**Requisitos**:
1. Crear class `CuentaBancaria` con: titular, saldo, historial de movimientos
2. Metodo `depositar(_ monto: Double)` — agrega al saldo y registra movimiento
3. Metodo `retirar(_ monto: Double) -> Bool` — retira si hay fondos, registra movimiento
4. Metodo `transferir(a destino: CuentaBancaria, monto: Double) -> Bool`
5. Metodo `imprimirEstado()` que muestre saldo e historial
6. **Demostrar reference behavior**: crear dos variables que apunten a la misma cuenta y mostrar que ambas ven los cambios

```swift
// Demostrar que es reference type:
let cuenta = CuentaBancaria(titular: "Ana", saldo: 1000)
let mismaReferencia = cuenta
mismaReferencia.depositar(500)
print(cuenta.saldo)  // 1500 — ambas ven el cambio
```

---

## Ejercicio 3: Sistema de Entregas (Avanzado)

**Objetivo**: Combinar struct, class y enum con associated values para modelar un sistema real.

**Requisitos**:
1. Enum `EstadoEntrega` con associated values:
   - `.preparando`
   - `.enCamino(conductor: String, estimado: String)`
   - `.entregado(firma: String, hora: String)`
   - `.fallido(razon: String)`
2. Struct `Paquete` con: id, descripcion, peso (Double), destino, estado (EstadoEntrega)
3. Metodo en Paquete que devuelva un resumen segun el estado actual
4. Class `ServicioEntregas` con:
   - Array de paquetes
   - Metodo para crear paquete
   - Metodo para actualizar estado de un paquete
   - Metodo para listar paquetes filtrados por estado
   - Propiedad computada: total de paquetes por estado

```swift
// Ejemplo de uso esperado:
let servicio = ServicioEntregas()
let paquete = servicio.crearPaquete(descripcion: "Laptop", peso: 2.5, destino: "Madrid")
servicio.actualizarEstado(id: paquete.id, nuevoEstado: .enCamino(conductor: "Pedro", estimado: "14:30"))
servicio.listarPaquetes(conEstado: .enCamino)
```

---

## Recursos Adicionales

- **Cupertino**: `cupertino search --source swift-book "structures and classes"`
- **Cupertino**: `cupertino search --source swift-book "enumerations"`
- **WWDC15**: Building Better Apps with Value Types
- **Paul Hudson**: hackingwithswift.com — Structs vs Classes

---

## Checklist

- [ ] Crear structs con propiedades almacenadas y computadas
- [ ] Escribir metodos en structs (regulares y mutating)
- [ ] Entender el memberwise initializer automatico
- [ ] Crear inicializadores custom
- [ ] Entender value type: copiar un struct crea copia independiente
- [ ] Crear clases con propiedades y metodos
- [ ] Entender reference type: asignar una clase comparte el mismo objeto
- [ ] Conocer la diferencia de `let` con struct vs class
- [ ] Saber cuando usar struct (por defecto) y cuando class
- [ ] Crear enums basicos y con raw values
- [ ] Crear enums con associated values
- [ ] Agregar metodos y propiedades computadas a enums
- [ ] Usar switch exhaustivo con enums
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Structs, clases y enums son los bloques de construccion de cualquier app. En el Proyecto Integrador usaras:
- **Structs** para todos tus modelos de datos (Producto, Usuario, Configuracion) — SwiftData trabaja con structs
- **Enums** para modelar estados de la app (cargando, exito, error) y opciones del usuario
- **Enums con associated values** para manejar respuestas de red (exito con datos, error con mensaje)
- **Clases** solo cuando sea necesario: ViewModels con `@Observable` y servicios compartidos
- La regla "struct por defecto, class cuando necesites referencia" guiara todas tus decisiones de modelado

---

*Leccion 04 (L04) | Structs, Clases y Enums | Semana 4 | Modulo 00: Fundamentos*
*Siguiente: Leccion 05 (L05) — Swift 6 Language*
