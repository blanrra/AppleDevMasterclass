# Leccion 02: Protocol-Oriented Programming y Genericos Avanzados

**Modulo 00: Fundamentos** | Semanas 2-3

---

## Cupertino MCP

```bash
cupertino search "protocol oriented programming"
cupertino search "protocol extensions Swift"
cupertino search "associated types"
cupertino search "opaque types some any"
cupertino search "conditional conformance"
cupertino search --source swift-book "generics"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC15 | [Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/play/wwdc2015/408/) | **Esencial** — El video que cambio todo |
| WWDC22 | [Embrace Swift Generics](https://developer.apple.com/videos/play/wwdc2022/110352/) | **Esencial** — some vs any explicado |
| WWDC22 | [Design Protocol Interfaces](https://developer.apple.com/videos/play/wwdc2022/110353/) | Associated types avanzados |
| 🇪🇸 | [Julio Cesar Fernandez — Protocolos](https://www.youtube.com/@AppleCodingAcademy) | POP en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que POP?

En la WWDC 2015, Apple presento "Protocol-Oriented Programming in Swift" y cambio la forma de pensar sobre el diseno de software. La pregunta clave es: **por que protocolos en lugar de clases base?**

La herencia de clases tiene tres problemas fundamentales:
1. **Single inheritance**: Solo puedes heredar de una clase. Si necesitas comportamiento de dos fuentes, estas atrapado.
2. **Fragile base class**: Cambiar la clase base puede romper todas las subclases.
3. **Reference semantics forzada**: Las clases son reference types, lo que introduce complejidad de memoria y threading.

Los protocolos resuelven los tres: puedes conformar a multiples protocolos, las extensiones son aditivas (no rompen nada), y funcionan con value types (structs).

#### OOP vs POP — Diagrama Comparativo

```
  OOP (Herencia de Clases)           POP (Composicion de Protocolos)

  ┌─────────────────┐               ┌──────────┐ ┌────────────┐ ┌───────────┐
  │   AnimalBase    │               │ Volador  │ │ Nadador    │ │ Terrestre │
  │   (class)       │               │(protocol)│ │ (protocol) │ │(protocol) │
  └────────┬────────┘               └────┬─────┘ └─────┬──────┘ └─────┬─────┘
           │                              │             │              │
    ┌──────┴──────┐                  ┌────┴─────────────┴──────────────┴────┐
    │             │                  │  Pato: Volador & Nadador & Terrestre │
  ┌─┴──┐    ┌────┴───┐              │  (struct — value type!)             │
  │Ave │    │Mamifero│              └──────────────────────────────────────┘
  └─┬──┘    └────────┘
    │                                ✅ Multiple conformance
  ┌─┴──┐                            ✅ Value types
  │Pato│ ← ¿Tambien nada?           ✅ Extensions no rompen nada
  └────┘   ¡No puede heredar         ✅ Testing facil (mock con protocolo)
            de Ave Y Nadador!
  ❌ Single inheritance
  ❌ Solo reference types
  ❌ Fragile base class
```

### Protocol Extensions

Las extensiones de protocolo permiten proporcionar implementaciones por defecto. Esto es como tener "herencia" pero para value types.

```swift
protocol Describible {
    var nombre: String { get }
}

// Extension con implementacion por defecto
extension Describible {
    func descripcionCompleta() -> String {
        "Soy \(nombre)"
    }

    func log() {
        print("[LOG] \(descripcionCompleta())")
    }
}

struct Usuario: Describible {
    let nombre: String
    // descripcionCompleta() y log() ya estan disponibles gratuitamente
}

let user = Usuario(nombre: "Carlos")
user.log()  // [LOG] Soy Carlos
```

### Protocol Composition

Combinar protocolos con `&` te permite crear "super-interfaces" sin herencia.

```swift
protocol Identificable {
    var id: String { get }
}

protocol Nombrable {
    var nombre: String { get }
}

protocol Auditable {
    var fechaCreacion: Date { get }
    var ultimaModificacion: Date { get }
}

// Composicion: un tipo que cumple con los tres
typealias EntidadCompleta = Identificable & Nombrable & Auditable

// Funcion que acepta la composicion
func registrar(_ entidad: any Identificable & Nombrable) {
    print("Registrando \(entidad.nombre) con ID: \(entidad.id)")
}
```

### Associated Types

Los associated types hacen que los protocolos sean genericos.

```swift
protocol Repositorio {
    associatedtype Entidad: Identifiable

    func obtener(id: Entidad.ID) -> Entidad?
    func guardar(_ entidad: Entidad)
    func eliminar(id: Entidad.ID)
    func todos() -> [Entidad]
}

struct Usuario: Identifiable {
    let id: UUID
    var nombre: String
    var email: String
}

struct RepositorioEnMemoria<T: Identifiable>: Repositorio where T.ID: Hashable {
    typealias Entidad = T
    private var almacen: [T.ID: T] = [:]

    func obtener(id: T.ID) -> T? {
        almacen[id]
    }

    mutating func guardar(_ entidad: T) {
        almacen[entidad.id] = entidad
    }

    mutating func eliminar(id: T.ID) {
        almacen.removeValue(forKey: id)
    }

    func todos() -> [T] {
        Array(almacen.values)
    }
}
```

### Conditional Conformance

Agregar conformance solo cuando se cumplen ciertas condiciones.

```swift
// Array es Equatable SOLO SI sus elementos son Equatable
extension Array: Equatable where Element: Equatable {}

// Ejemplo practico
struct Caja<T> {
    let contenido: T
}

// Caja es CustomStringConvertible solo si T lo es
extension Caja: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        "Caja(\(contenido.description))"
    }
}
```

### Opaque Types: some vs any

```swift
// `some` — Tipo opaco: el compilador sabe el tipo exacto, tu no
func crearColeccion() -> some Collection {
    [1, 2, 3]  // Siempre retorna el MISMO tipo concreto
}

// `any` — Tipo existencial: puede ser CUALQUIER tipo que conforme
func procesar(items: [any Describible]) {
    for item in items {
        print(item.descripcionCompleta())
    }
}

// Regla: usa `some` cuando puedas (mejor performance), `any` cuando necesites heterogeneidad
```

#### some vs any — Cuando Usar Cada Uno

```
  some Collection                    any Describible
  ┌──────────────────────┐          ┌──────────────────────┐
  │ Compilador sabe el   │          │ Compilador NO sabe   │
  │ tipo exacto           │          │ el tipo exacto        │
  │                       │          │                       │
  │ Siempre retorna       │          │ Puede ser CUALQUIER   │
  │ el MISMO tipo         │          │ tipo que conforme     │
  │                       │          │                       │
  │ ✅ Mejor performance  │          │ ✅ Arrays heterogeneos│
  │ ✅ Optimizaciones     │          │ ✅ Flexibilidad       │
  │ ❌ No arrays mixtos   │          │ ❌ Overhead runtime   │
  └──────────────────────┘          └──────────────────────┘

  Regla: usa 'some' cuando puedas, 'any' cuando necesites mezclar tipos
```

### Genericos Avanzados con Constraints

```swift
// Multiple constraints
func comparar<T: Comparable & CustomStringConvertible>(_ a: T, _ b: T) -> T {
    let resultado = a > b ? a : b
    print("Mayor: \(resultado.description)")
    return resultado
}

// Where clause
func encontrarDuplicados<T: Hashable>(en array: [T]) -> Set<T> {
    var vistos = Set<T>()
    var duplicados = Set<T>()
    for elemento in array {
        if vistos.contains(elemento) {
            duplicados.insert(elemento)
        }
        vistos.insert(elemento)
    }
    return duplicados
}

// Extension con where
extension Pila where Element: Equatable {
    func contiene(_ elemento: Element) -> Bool {
        // Solo disponible cuando Element es Equatable
        elementos.contains(elemento)
    }
}
```

---

## Ejemplo de Codigo: PaymentSystem.swift

El archivo `Codigo/PaymentSystem.swift` (migrado de Phase1-POP) demuestra todos estos conceptos en un sistema de pagos real:

- **Protocolos basicos**: `Payable`, `Verifiable`, `Refundable`
- **Protocol composition**: `typealias SecurePayment = Payable & Verifiable`
- **Protocol extensions**: implementaciones por defecto de `formattedAmount()` e `isValid()`
- **Conditional extensions**: `processSecurely()` solo disponible para `Payable & Verifiable`
- **Polimorfismo**: arrays heterogeneos `[any Payable]`

```bash
swift Modulo00-Fundamentos/Codigo/PaymentSystem.swift
```

---

## Ejercicio 1: Sistema de Notificaciones (Basico)

**Objetivo**: Practicar protocolos, extensions y protocol composition.

**Requisitos**:
1. Protocolo `Notificable` con: titulo, mensaje, enviar()
2. Protocolo `Priorizable` con: prioridad (enum alta/media/baja)
3. Extension de `Notificable` con implementacion por defecto de `enviar()`
4. Typealias `NotificacionUrgente = Notificable & Priorizable`
5. Implementar: EmailNotificacion, PushNotificacion, SMSNotificacion

---

## Ejercicio 2: Coleccion Generica (Intermedio)

**Objetivo**: Practicar associated types y genericos con constraints.

**Requisitos**:
1. Protocolo `Almacen` con associated type `Item: Identifiable`
2. Metodos: agregar, obtener por id, eliminar, filtrar con closure
3. Extension condicional: `buscar(nombre:)` solo cuando Item tiene propiedad nombre
4. Implementar `AlmacenEnMemoria<T>` y `AlmacenOrdenado<T: Comparable>`

---

## Ejercicio 3: Sistema de Plugins (Avanzado)

**Objetivo**: Combinar POP, genericos, composicion y opaque types.

**Requisitos**:
1. Protocolo `Plugin` con associated type para Config y Output
2. Protocolo `Configurable` con metodo configure()
3. Protocol composition para `PluginCompleto = Plugin & Configurable`
4. Implementar un sistema de pipeline que encadene plugins
5. Usar `some Plugin` para retornos y `any Plugin` para colecciones

---

## Recursos Adicionales

- **Cupertino**: `cupertino search "protocol oriented programming"`
- **WWDC 2015**: Protocol-Oriented Programming in Swift (video fundacional)
- **Julio Cesar Fernandez**: Arquitectura con protocolos

---

## Checklist

- [ ] Entender por que POP sobre OOP (3 problemas de herencia)
- [ ] Crear protocol extensions con implementaciones por defecto
- [ ] Usar protocol composition con & y typealias
- [ ] Implementar associated types en protocolos
- [ ] Aplicar conditional conformance con where
- [ ] Diferenciar some vs any y cuando usar cada uno
- [ ] Usar generics con multiple constraints
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

En el Proyecto Integrador, POP sera tu herramienta de diseno principal:
- **Protocolos** para definir contratos entre capas (Repository, Service, ViewModel)
- **Protocol composition** para dependencias especificas
- **Associated types** en tu capa de datos generica
- **Conditional conformance** para features opcionales
- **Opaque types** en tu API publica

---

*Leccion 02 | POP y Genericos Avanzados | Semanas 2-3 | Modulo 00: Fundamentos*
*Siguiente: Leccion 03 — Manejo de Errores y Memoria*
