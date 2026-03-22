# Leccion 04: Concurrencia Moderna

**Modulo 00: Fundamentos** | Semanas 4-6

---

## TL;DR — Resumen en 2 minutos

- **async/await**: Escribir codigo asincrono que se lee como codigo normal — adios a los callbacks anidados
- **Task y TaskGroup**: Task lanza trabajo asincrono, TaskGroup coordina multiples tareas en paralelo
- **Actors**: Protegen estado mutable de accesos concurrentes — como una clase con un candado automatico
- **Sendable**: Protocolo que garantiza que un tipo es seguro para compartir entre hilos
- **AsyncSequence**: Secuencias que producen valores de forma asincrona — ideal para streams de datos

---

## Cupertino MCP

```bash
cupertino search "swift concurrency"
cupertino search "async await Swift"
cupertino search "Task Swift"
cupertino search "actor Swift"
cupertino search "Sendable protocol"
cupertino search "structured concurrency"
cupertino search "AsyncSequence"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC21 | [Meet async/await in Swift](https://developer.apple.com/videos/play/wwdc2021/10132/) | **Esencial** — Introduccion oficial |
| WWDC21 | [Structured Concurrency in Swift](https://developer.apple.com/videos/play/wwdc2021/10134/) | **Esencial** — Task, TaskGroup |
| WWDC21 | [Protect Mutable State with Actors](https://developer.apple.com/videos/play/wwdc2021/10133/) | **Esencial** — Actors |
| WWDC22 | [Eliminate Data Races](https://developer.apple.com/videos/play/wwdc2022/110351/) | Sendable, Swift 6 |
| WWDC24 | [Migrate Your App to Swift 6](https://developer.apple.com/videos/play/wwdc2024/10169/) | Migracion practica |
| :es: | [Julio Cesar Fernandez — Concurrencia](https://www.youtube.com/@AppleCodingAcademy) | Serie completa en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Concurrencia Moderna?

Antes de Swift 5.5, la concurrencia en iOS era un infierno de callbacks anidados, DispatchQueues y race conditions invisibles. Apple introdujo async/await no solo por comodidad sintactica, sino para hacer que los **data races sean detectables en compilacion** (Swift 6).

La concurrencia moderna de Swift se basa en tres pilares:
1. **async/await**: Codigo asincrono que se lee como sincrono
2. **Structured concurrency**: Las tareas hijas siempre terminan antes que sus padres
3. **Actors**: Aislamiento de datos para evitar race conditions

#### Los Tres Pilares de la Concurrencia Swift

```
  ┌─────────────────────────────────────────────────────────────┐
  │                 CONCURRENCIA MODERNA SWIFT                  │
  ├─────────────────┬──────────────────┬────────────────────────┤
  │   async/await   │   Structured     │      Actors            │
  │                 │   Concurrency    │                        │
  │  Codigo async   │  Las tareas      │  Aislamiento de        │
  │  que se lee     │  hijas terminan  │  estado mutable        │
  │  como sincrono  │  antes que el    │  compartido            │
  │                 │  padre           │                        │
  │  ┌───┐         │  ┌─Task──┐       │  ┌─Actor─────────┐    │
  │  │ A │──await──▶│  │ ├─child│       │  │ private state │    │
  │  │ B │──await──▶│  │ ├─child│       │  │ func ──await──│    │
  │  │ C │         │  │ └─done │       │  └───────────────┘    │
  │  └───┘         │  └───────┘       │                        │
  └─────────────────┴──────────────────┴────────────────────────┘
```

### async/await

```swift
// ANTES (callbacks — "pyramid of doom")
func obtenerUsuarioAntiguo(id: Int, completion: @escaping (Result<Usuario, Error>) -> Void) {
    // callback hell...
}

// AHORA (async/await — limpio y legible)
func obtenerUsuario(id: Int) async throws -> Usuario {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw ErrorAPI.respuestaInvalida
    }

    return try JSONDecoder().decode(Usuario.self, from: data)
}

// Llamar funciones async
func cargarDatos() async {
    do {
        let usuario = try await obtenerUsuario(id: 42)
        print("Usuario: \(usuario.nombre)")
    } catch {
        print("Error: \(error)")
    }
}
```

### Task y Task Groups

```swift
// Task: ejecutar trabajo asincrono
let task = Task {
    let usuario = try await obtenerUsuario(id: 1)
    return usuario.nombre
}

// Cancelar si es necesario
task.cancel()

// Task.detached: sin heredar el contexto del actor
Task.detached(priority: .background) {
    await procesarEnBackground()
}

// TaskGroup: paralelismo estructurado
func cargarMultiplesUsuarios(ids: [Int]) async throws -> [Usuario] {
    try await withThrowingTaskGroup(of: Usuario.self) { group in
        for id in ids {
            group.addTask {
                try await obtenerUsuario(id: id)
            }
        }

        var usuarios: [Usuario] = []
        for try await usuario in group {
            usuarios.append(usuario)
        }
        return usuarios
    }
}
```

#### Secuencial vs Paralelo — Visualizacion

```
  SECUENCIAL (uno tras otro):
  ┌──Madrid──┐┌──Barcelona──┐┌──Sevilla──┐
  0ms       300ms          600ms         900ms   Total: ~900ms

  PARALELO (async let):
  ┌──Madrid────┐
  ┌──Barcelona─┐
  ┌──Sevilla───┐
  0ms         300ms                              Total: ~300ms
                                                 3x mas rapido!

  TASKGROUP (paralelismo dinamico):
  ┌──Ciudad 1──┐
  ┌──Ciudad 2──┐
  ┌──Ciudad 3──┐
  ┌──Ciudad N──┐  ← N tareas en paralelo
  0ms         300ms
```

### Actors

Los actors son reference types que protegen su estado interno de accesos concurrentes.

```swift
actor ContadorSeguro {
    private var valor = 0

    func incrementar() {
        valor += 1
    }

    func obtenerValor() -> Int {
        valor
    }
}

let contador = ContadorSeguro()

// Acceder a un actor requiere await
await contador.incrementar()
let valor = await contador.obtenerValor()

// @MainActor: garantiza ejecucion en el hilo principal
@MainActor
class ViewModel {
    var items: [String] = []

    func cargar() async {
        let datos = await fetchDatos()  // Esto puede correr en background
        items = datos  // Esto corre en main thread (garantizado por @MainActor)
    }
}
```

### Sendable

El protocolo `Sendable` marca tipos que son seguros para enviar entre contextos de concurrencia.

```swift
// Structs con propiedades Sendable son automaticamente Sendable
struct Punto: Sendable {
    let x: Double
    let y: Double
}

// Classes necesitan ser final y tener solo propiedades inmutables
final class Configuracion: Sendable {
    let apiKey: String
    let baseURL: String

    init(apiKey: String, baseURL: String) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
}

// @Sendable para closures
func ejecutarEnBackground(_ trabajo: @Sendable () async -> Void) {
    Task.detached {
        await trabajo()
    }
}
```

### AsyncSequence y AsyncStream

```swift
// AsyncSequence: iterar sobre valores asincronos
func lineasDeArchivo(url: URL) -> AsyncLineSequence<URL.AsyncBytes> {
    url.lines
}

// AsyncStream: crear tu propio stream
func temporizador(intervalo: Duration) -> AsyncStream<Date> {
    AsyncStream { continuation in
        Task {
            while !Task.isCancelled {
                continuation.yield(Date())
                try? await Task.sleep(for: intervalo)
            }
            continuation.finish()
        }
    }
}

// Uso
for await fecha in temporizador(intervalo: .seconds(1)) {
    print("Tick: \(fecha)")
}
```

### Task Cancellation

```swift
func descargarImagen(url: URL) async throws -> Data {
    // Verificar cancelacion periodicamente
    try Task.checkCancellation()

    let (data, _) = try await URLSession.shared.data(from: url)

    // Verificar de nuevo despues de operacion larga
    try Task.checkCancellation()

    return data
}

// Cooperative cancellation
func procesarLote(items: [Item]) async throws {
    for item in items {
        guard !Task.isCancelled else {
            print("Procesamiento cancelado")
            return
        }
        try await procesar(item)
    }
}
```

---

## Ejemplo de Codigo

### Archivo: `Codigo/ConcurrencyDemo.swift`

```swift
import Foundation

// MARK: - Actor de Cache

actor ImageCache {
    private var cache: [String: Data] = [:]

    func obtener(clave: String) -> Data? {
        cache[clave]
    }

    func guardar(_ datos: Data, clave: String) {
        cache[clave] = datos
    }

    var cantidadItems: Int {
        cache.count
    }
}

// MARK: - Servicio con async/await

struct ServicioClima {
    func obtenerTemperatura(ciudad: String) async throws -> Double {
        // Simular llamada de red
        try await Task.sleep(for: .milliseconds(500))
        let temperaturas = ["Madrid": 22.5, "Barcelona": 25.0, "Sevilla": 30.2]
        guard let temp = temperaturas[ciudad] else {
            throw ErrorClima.ciudadNoEncontrada(ciudad)
        }
        return temp
    }
}

enum ErrorClima: Error {
    case ciudadNoEncontrada(String)
}

// MARK: - Demo

func demoAsyncAwait() async {
    let servicio = ServicioClima()

    // Secuencial
    print("=== Secuencial ===")
    do {
        let temp1 = try await servicio.obtenerTemperatura(ciudad: "Madrid")
        let temp2 = try await servicio.obtenerTemperatura(ciudad: "Barcelona")
        print("Madrid: \(temp1)C, Barcelona: \(temp2)C")
    } catch {
        print("Error: \(error)")
    }

    // Paralelo con async let
    print("\n=== Paralelo (async let) ===")
    do {
        async let madrid = servicio.obtenerTemperatura(ciudad: "Madrid")
        async let barcelona = servicio.obtenerTemperatura(ciudad: "Barcelona")
        async let sevilla = servicio.obtenerTemperatura(ciudad: "Sevilla")

        let temps = try await [madrid, barcelona, sevilla]
        print("Temperaturas: \(temps)")
    } catch {
        print("Error: \(error)")
    }

    // TaskGroup
    print("\n=== TaskGroup ===")
    let ciudades = ["Madrid", "Barcelona", "Sevilla"]
    await withTaskGroup(of: (String, Double?).self) { group in
        for ciudad in ciudades {
            group.addTask {
                let temp = try? await servicio.obtenerTemperatura(ciudad: ciudad)
                return (ciudad, temp)
            }
        }

        for await (ciudad, temp) in group {
            if let temp {
                print("\(ciudad): \(temp)C")
            }
        }
    }

    // Actor
    print("\n=== Actor (Cache) ===")
    let cache = ImageCache()
    await cache.guardar(Data("imagen1".utf8), clave: "foto1")
    await cache.guardar(Data("imagen2".utf8), clave: "foto2")
    print("Items en cache: \(await cache.cantidadItems)")
}

// Entry point
Task {
    await demoAsyncAwait()
}

// Mantener vivo el proceso
RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
```

---

## Ejercicio 1: Descargador Concurrente (Basico)

**Objetivo**: Practicar async/await y Task.

**Requisitos**:
1. Funcion `descargar(url:) async throws -> String` que simule descarga con Task.sleep
2. Descargar 3 URLs secuencialmente y medir el tiempo
3. Descargar las mismas 3 URLs en paralelo con `async let` y comparar tiempos

---

## Ejercicio 2: Sistema de Cola con Actor (Intermedio)

**Objetivo**: Practicar actors y structured concurrency.

**Requisitos**:
1. Actor `ColaDeTrabajo` con metodos: agregar, procesarSiguiente, pendientes
2. Struct `Trabajo` con id, descripcion y prioridad
3. Procesar trabajos con TaskGroup respetando prioridad
4. Implementar cancelacion cooperativa

---

## Ejercicio 3: Pipeline Asincrono (Avanzado)

**Objetivo**: Combinar AsyncStream, actors y TaskGroup.

**Requisitos**:
1. AsyncStream que emita eventos simulados cada 0.5 segundos
2. Actor `Procesador` que acumule y transforme eventos
3. Pipeline: generar -> filtrar -> transformar -> almacenar
4. Implementar backpressure basico (limitar items en cola)
5. Cancelacion limpia de todo el pipeline

---

## Recursos Adicionales

- **Cupertino**: `cupertino search "swift concurrency"`
- **WWDC**: Meet Swift Concurrency, Swift Concurrency: Behind the Scenes
- **Julio Cesar Fernandez**: Concurrencia en Swift (espanol)

---

## Checklist

- [ ] Escribir funciones async y llamarlas con await
- [ ] Usar try/catch con funciones async throws
- [ ] Paralelizar con async let
- [ ] Crear TaskGroups para paralelismo dinamico
- [ ] Implementar actors para estado compartido thread-safe
- [ ] Usar @MainActor para actualizaciones de UI
- [ ] Entender Sendable y por que importa
- [ ] Crear AsyncStreams basicos
- [ ] Implementar cancelacion cooperativa
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

La concurrencia sera omnipresente en tu app:
- **async/await** para todas las llamadas de red y I/O
- **Actors** para caches y estado compartido
- **@MainActor** en tus ViewModels
- **TaskGroup** para cargas paralelas (imagenes, datos)
- **AsyncStream** para datos en tiempo real (HealthKit, Location)

---

*Leccion 04 | Concurrencia Moderna | Semanas 4-6 | Modulo 00: Fundamentos*
*Siguiente: Leccion 05 — Xcode 26*
