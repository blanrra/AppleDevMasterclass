# Leccion 03: Manejo de Errores y Memoria

**Modulo 00: Fundamentos** | Semanas 3-4

---

## TL;DR — Resumen en 2 minutos

- **Result type**: Encapsula exito o error en un solo valor — ideal para funciones que pueden fallar
- **Typed throws** (introducido en Swift 5.9, disponible en Swift 6): Puedes especificar exactamente que tipo de error lanza una funcion
- **ARC**: Swift cuenta automaticamente las referencias a objetos y los libera cuando llegan a cero
- **Retain cycles**: Dos objetos que se referencian mutuamente nunca se liberan — solucion: `weak` o `unowned`
- **Value vs Reference**: Los structs se copian (independientes), las clases se comparten (misma memoria)

---

## Cupertino MCP

```bash
cupertino search "automatic reference counting"
cupertino search "error handling Swift"
cupertino search "Result type"
cupertino search --source swift-book "error handling"
cupertino search --source swift-book "automatic reference counting"
cupertino search "memory management Swift"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC21 | [ARC in Swift: Basics and Beyond](https://developer.apple.com/videos/play/wwdc2021/10216/) | **Esencial** — ARC explicado visualmente |
| EN | [Paul Hudson — Retain Cycles Explained](https://www.hackingwithswift.com/plus) | Visualizacion de retain cycles |
| 🇪🇸 | [Julio Cesar Fernandez — Memory Management](https://www.youtube.com/@AppleCodingAcademy) | ARC en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Manejo de Errores Avanzado

#### Result Type

`Result` es un enum generico que encapsula exito o fallo. Es util cuando quieres manejar el error sin try/catch.

```swift
enum ErrorAPI: Error {
    case urlInvalida
    case sinDatos
    case decodificacionFallida(String)
}

func obtenerUsuario(id: Int) -> Result<Usuario, ErrorAPI> {
    guard id > 0 else {
        return .failure(.urlInvalida)
    }
    return .success(Usuario(id: UUID(), nombre: "Carlos", email: "carlos@test.com"))
}

// Uso con switch
switch obtenerUsuario(id: 1) {
case .success(let usuario):
    print("Usuario: \(usuario.nombre)")
case .failure(let error):
    print("Error: \(error)")
}

// Uso funcional con map/flatMap
let nombre = obtenerUsuario(id: 1)
    .map { $0.nombre }
    .mapError { "Fallo: \($0)" }
```

#### Typed Throws (Swift 5.9+)

Desde Swift 5.9 puedes especificar el tipo exacto de error que una funcion puede lanzar (disponible tambien en Swift 6).

```swift
func dividir(_ a: Double, entre b: Double) throws(ErrorMatematico) -> Double {
    guard b != 0 else {
        throw .divisionPorCero
    }
    return a / b
}

enum ErrorMatematico: Error {
    case divisionPorCero
    case overflow
}

// El catch sabe exactamente que tipo de error esperar
do {
    let resultado = try dividir(10, entre: 0)
} catch {
    // `error` es de tipo ErrorMatematico, no generico Error
    switch error {
    case .divisionPorCero:
        print("No se puede dividir por cero")
    case .overflow:
        print("Resultado demasiado grande")
    }
}
```

#### Rethrows

```swift
func ejecutarConReintentos<T>(
    intentos: Int,
    operacion: () throws -> T
) rethrows -> T {
    for intento in 1..<intentos {
        do {
            return try operacion()
        } catch {
            print("Intento \(intento) fallo: \(error)")
            continue
        }
    }
    return try operacion()  // Ultimo intento — deja que el error escape
}
```

### Gestion de Memoria: ARC

#### Como Funciona ARC

ARC (Automatic Reference Counting) cuenta cuantas referencias "fuertes" apuntan a un objeto. Cuando el conteo llega a 0, el objeto se libera.

```swift
class Persona {
    let nombre: String
    init(nombre: String) {
        self.nombre = nombre
        print("\(nombre) inicializado")
    }
    deinit {
        print("\(nombre) liberado de memoria")
    }
}

var ref1: Persona? = Persona(nombre: "Ana")  // count = 1
var ref2 = ref1  // count = 2
ref1 = nil       // count = 1
ref2 = nil       // count = 0 → "Ana liberado de memoria"
```

#### ARC — Conteo de Referencias Visual

```
  var ref1 = Persona("Ana")      ref count: 1
  ┌──────┐     ┌──────────────┐
  │ ref1 ├────▶│ Persona("Ana")│
  └──────┘     └──────────────┘

  var ref2 = ref1                 ref count: 2
  ┌──────┐     ┌──────────────┐
  │ ref1 ├────▶│ Persona("Ana")│◀────┤ ref2 │
  └──────┘     └──────────────┘     └──────┘

  ref1 = nil                      ref count: 1
  ┌──────┐     ┌──────────────┐
  │ nil  │     │ Persona("Ana")│◀────┤ ref2 │
  └──────┘     └──────────────┘     └──────┘

  ref2 = nil                      ref count: 0 → 💀 deinit!
  ┌──────┐     ┌ ─ ─ ─ ─ ─ ─ ┐
  │ nil  │     │  (liberado)  │     ┌──────┐
  └──────┘     └ ─ ─ ─ ─ ─ ─ ┘     │ nil  │
                                     └──────┘
```

#### Retain Cycles

El problema mas comun: dos objetos se referencian mutuamente y ninguno puede ser liberado.

```swift
class Departamento {
    let nombre: String
    var jefe: Empleado?

    init(nombre: String) { self.nombre = nombre }
    deinit { print("Departamento \(nombre) liberado") }
}

class Empleado {
    let nombre: String
    weak var departamento: Departamento?  // weak rompe el ciclo

    init(nombre: String) { self.nombre = nombre }
    deinit { print("Empleado \(nombre) liberado") }
}

var dept: Departamento? = Departamento(nombre: "Ingenieria")
var emp: Empleado? = Empleado(nombre: "Laura")
dept?.jefe = emp
emp?.departamento = dept

dept = nil  // Se libera correctamente gracias a weak
emp = nil   // Se libera correctamente
```

#### Retain Cycle — El Problema y la Solucion

```
  ❌ SIN weak (retain cycle):

  ┌──────────────┐  strong  ┌──────────────┐
  │ Departamento ├─────────▶│   Empleado   │
  │              │◀─────────┤              │
  └──────────────┘  strong  └──────────────┘
       ref count: 1              ref count: 1
       ¡Nunca llega a 0!        ¡Nunca llega a 0!
       💀 MEMORY LEAK           💀 MEMORY LEAK


  ✅ CON weak (sin retain cycle):

  ┌──────────────┐  strong  ┌──────────────┐
  │ Departamento ├─────────▶│   Empleado   │
  │              │◀ ─ ─ ─ ─ ┤              │
  └──────────────┘  weak    └──────────────┘
       ref count: 0 → 💀        ref count: 0 → 💀
       ✅ Se libera              ✅ Se libera
```

#### weak vs unowned

```swift
// weak: la referencia puede ser nil en cualquier momento
// Usa weak cuando el tiempo de vida del objeto referenciado es incierto
weak var delegado: MiDelegado?

// unowned: asumes que la referencia SIEMPRE tendra valor mientras la uses
// Usa unowned cuando sabes que el objeto referenciado vive mas tiempo
class Cliente {
    let nombre: String
    var tarjeta: Tarjeta?
    init(nombre: String) { self.nombre = nombre }
}

class Tarjeta {
    let numero: String
    unowned let titular: Cliente  // El cliente siempre existe mientras la tarjeta exista
    init(numero: String, titular: Cliente) {
        self.numero = numero
        self.titular = titular
    }
}
```

#### Closures y Retain Cycles

Los closures capturan variables por referencia, lo que puede crear retain cycles.

```swift
class DescargaManager {
    var url: String
    var completionHandler: (() -> Void)?

    init(url: String) { self.url = url }

    func iniciar() {
        // PROBLEMA: el closure captura self fuertemente
        // completionHandler = {
        //     print("Descarga de \(self.url) completada")
        // }

        // SOLUCION: capture list con weak
        completionHandler = { [weak self] in
            guard let self else { return }
            print("Descarga de \(self.url) completada")
        }
    }

    deinit { print("DescargaManager liberado") }
}
```

#### Closure Capture — Por que [weak self]

```
  ❌ SIN capture list:

  ┌──────────┐  strong  ┌─────────┐  strong  ┌──────────┐
  │ Manager  ├─────────▶│ closure │─────────▶│ Manager  │
  │          │◀─────────┤         │          │ (self)   │
  └──────────┘          └─────────┘          └──────────┘
                                              ↑ es el mismo!
                         RETAIN CYCLE 💀


  ✅ CON [weak self]:

  ┌──────────┐  strong  ┌─────────┐   weak   ┌──────────┐
  │ Manager  ├─────────▶│ closure │─ ─ ─ ─ ─▶│ Manager  │
  └──────────┘          └─────────┘          │ (self)   │
                                              └──────────┘
                         guard let self ──▶ usar self
                         else { return }   si aun existe
```

### Value Types vs Reference Types

```swift
// Value Type (struct): se copia, thread-safe por naturaleza
struct Coordenada {
    var lat: Double
    var lon: Double
}

// Reference Type (class): se comparte, necesita cuidado con threading
class Ubicacion {
    var nombre: String
    var coordenada: Coordenada
    init(nombre: String, coordenada: Coordenada) {
        self.nombre = nombre
        self.coordenada = coordenada
    }
}
```

**Copy-on-Write (COW)**: Swift optimiza los value types grandes (Array, String, Dictionary). Solo se copian realmente cuando se modifican.

```swift
var array1 = [1, 2, 3, 4, 5]
var array2 = array1  // No se copia aun (comparten la misma memoria)
array2.append(6)     // AHORA se copia (copy-on-write)
```

---

## Ejercicio 1: Gestor de Errores (Basico)

**Objetivo**: Practicar Result type y error handling.

**Requisitos**:
1. Enum de errores para un sistema de login: credencialesInvalidas, cuentaBloqueada, servidorNoDisponible
2. Funcion `login(usuario:password:) -> Result<Token, LoginError>`
3. Funcion `obtenerPerfil(token:) throws -> Perfil`
4. Encadenar ambas operaciones manejando errores en cada paso

---

## Ejercicio 2: Detector de Retain Cycles (Intermedio)

**Objetivo**: Practicar ARC, weak, unowned y deinit.

**Requisitos**:
1. Crear clases Autor y Libro con referencia circular
2. Demostrar el retain cycle con prints en deinit
3. Solucionarlo con weak/unowned
4. Crear un closure que capture self y demostrar la solucion con capture list

---

## Ejercicio 3: Capa de Red Type-Safe (Avanzado)

**Objetivo**: Combinar Result, genericos, protocolos y error handling.

**Requisitos**:
1. Protocolo `Endpoint` con URL, metodo HTTP y tipo de respuesta (associated type)
2. Funcion generica `request<E: Endpoint>(_ endpoint: E) async -> Result<E.Response, NetworkError>`
3. Manejar errores de decodificacion, timeout y respuestas HTTP invalidas
4. Implementar retry con backoff exponencial

---

## Recursos Adicionales

- **Cupertino**: `cupertino search "automatic reference counting"`
- **Swift Book**: `cupertino search --source swift-book "error handling"`

---

## Checklist

- [ ] Usar Result type para operaciones que pueden fallar
- [ ] Entender typed throws (Swift 5.9+)
- [ ] Explicar como funciona ARC (reference counting)
- [ ] Identificar y resolver retain cycles
- [ ] Diferenciar weak vs unowned y cuando usar cada uno
- [ ] Resolver retain cycles en closures con capture lists
- [ ] Entender copy-on-write en value types
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

En el Proyecto Integrador necesitaras:
- **Result type** para tu capa de networking
- **Error types custom** para cada dominio (red, persistencia, validacion)
- **weak self** en TODOS los closures de ViewModels y managers
- **Value types** para modelos de datos (structs con SwiftData)

---

*Leccion 03 | Manejo de Errores y Memoria | Semanas 3-4 | Modulo 00: Fundamentos*
*Siguiente: Leccion 04 — Concurrencia Moderna*
