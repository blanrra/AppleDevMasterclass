# Leccion 43: Combine (Referencia Legacy)

**Modulo 12: Extras y Especializacion** | Semana 52

---

> **IMPORTANTE**: Combine es una tecnologia **legacy**. En codigo nuevo, usa **async/await** para concurrencia y **@Observable** para reactividad. Esta leccion existe porque encontraras Combine en codebases existentes y algunas APIs de Apple aun lo usan. Aprende a leerlo, a migrarlo, pero no lo elijas para proyectos nuevos.

---

## TL;DR — Resumen en 2 minutos

- **Publisher** emite valores a lo largo del tiempo — como un grifo que suelta gotas de datos
- **Subscriber** recibe esos valores — `sink` y `assign` son los mas comunes
- **Operators** transforman el flujo — `map`, `filter`, `debounce`, `combineLatest`, `flatMap`
- **@Published** crea un Publisher automatico — cada cambio en la propiedad emite un valor
- **AnyCancellable** gestiona la suscripcion — si se destruye, la suscripcion se cancela
- **En codigo nuevo**: usar async/await + @Observable en lugar de Combine

> Herramienta: **Xcode 26** con breakpoints en pipelines Combine para depurar flujos

---

## Cupertino MCP

```bash
cupertino search "Combine framework"
cupertino search "Publisher protocol"
cupertino search "AnyPublisher"
cupertino search "@Published"
cupertino search "PassthroughSubject"
cupertino search "CurrentValueSubject"
cupertino search --source apple-docs "Combine operators"
cupertino search "async await migration"
cupertino search "Observable macro"
cupertino search --source updates "Combine deprecation"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC19 | [Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/) | Origen de Combine |
| WWDC21 | [Meet async/await in Swift](https://developer.apple.com/videos/play/wwdc2021/10132/) | El reemplazo moderno |
| WWDC23 | [Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/) | @Observable reemplaza @Published |
| EN | [Donny Wals — Practical Combine](https://www.donnywals.com) | **Esencial** — libro de referencia |
| EN | [Paul Hudson — Combine](https://www.hackingwithswift.com/books/combine) | Guia gratuita completa |
| EN | [Antoine van der Lee — Combine](https://www.avanderlee.com) | Articulos practicos |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Aprender Combine si es Legacy?

Porque vas a encontrarlo. Miles de apps en produccion usan Combine. Si te unes a un equipo, es probable que el codebase tenga `@Published`, `sink`, `AnyCancellable` por todas partes. Necesitas entenderlo para mantener ese codigo y, idealmente, migrarlo gradualmente a async/await. Ademas, algunas APIs de Apple como `NotificationCenter.publisher(for:)` y `Timer.publish()` aun devuelven Publishers.

La regla es simple: **lee Combine, migra Combine, no escribas Combine nuevo**.

### Publisher y Subscriber — Los Bloques Basicos

Un Publisher emite una secuencia de valores a lo largo del tiempo, seguida opcionalmente de un completion (exito o error). Un Subscriber se suscribe a ese Publisher para recibir los valores.

```swift
import Combine
import Foundation

// MARK: - Publishers basicos

// 1. Just — emite un solo valor y termina
let justPublisher = Just("Hola Combine")
// Tipo: Just<String> — Publisher que emite String, Never falla

// 2. Sequence — emite una secuencia de valores
let secuenciaPublisher = [1, 2, 3, 4, 5].publisher
// Tipo: Publishers.Sequence<[Int], Never>

// 3. PassthroughSubject — emite valores manualmente
let subject = PassthroughSubject<String, Never>()

// 4. CurrentValueSubject — como Passthrough pero recuerda el ultimo valor
let valorActual = CurrentValueSubject<Int, Never>(0)
print("Valor actual: \(valorActual.value)") // 0

// MARK: - Suscripciones con sink
var cancellables = Set<AnyCancellable>()

// sink — el subscriber mas comun
secuenciaPublisher
    .sink { completion in
        print("Secuencia completada: \(completion)")
    } receiveValue: { valor in
        print("Recibido: \(valor)")
    }
    .store(in: &cancellables)
// Imprime: Recibido: 1, 2, 3, 4, 5, Secuencia completada: finished

// Subject — emitir valores manualmente
subject
    .sink { valor in
        print("Subject dice: \(valor)")
    }
    .store(in: &cancellables)

subject.send("Primer mensaje")
subject.send("Segundo mensaje")
subject.send(completion: .finished) // terminar el stream
```

### Operators — Transformar el Flujo

Los operators son el poder real de Combine. Transforman, filtran y combinan flujos de datos.

```swift
import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// MARK: - Operators de transformacion

// map — transforma cada valor
[1, 2, 3, 4, 5].publisher
    .map { $0 * $0 }  // elevar al cuadrado
    .sink { print("Cuadrado: \($0)") }
    .store(in: &cancellables)
// 1, 4, 9, 16, 25

// compactMap — transforma y descarta nils
["1", "dos", "3", "cuatro", "5"].publisher
    .compactMap { Int($0) }  // solo los que se pueden convertir
    .sink { print("Numero: \($0)") }
    .store(in: &cancellables)
// 1, 3, 5

// flatMap — transforma a otro Publisher (aplanar streams anidados)
func buscarUsuario(id: Int) -> AnyPublisher<String, Never> {
    Just("Usuario_\(id)")
        .delay(for: .seconds(0.1), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
}

[1, 2, 3].publisher
    .flatMap { id in
        buscarUsuario(id: id)
    }
    .sink { print("Encontrado: \($0)") }
    .store(in: &cancellables)

// MARK: - Operators de filtrado

// filter — solo dejar pasar ciertos valores
(1...20).publisher
    .filter { $0.isMultiple(of: 3) }  // multiplos de 3
    .sink { print("Multiplo de 3: \($0)") }
    .store(in: &cancellables)
// 3, 6, 9, 12, 15, 18

// removeDuplicates — eliminar valores consecutivos repetidos
[1, 1, 2, 2, 2, 3, 3, 1].publisher
    .removeDuplicates()
    .sink { print("Unico: \($0)") }
    .store(in: &cancellables)
// 1, 2, 3, 1

// MARK: - Operators de tiempo

// debounce — esperar a que el usuario deje de escribir
let busqueda = PassthroughSubject<String, Never>()

busqueda
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .removeDuplicates()
    .sink { texto in
        print("Buscar: \(texto)")
    }
    .store(in: &cancellables)

// Solo "Swift" se buscaria si las letras se escriben rapido
busqueda.send("S")
busqueda.send("Sw")
busqueda.send("Swi")
busqueda.send("Swif")
busqueda.send("Swift") // <- solo este se emite despues de 300ms de pausa

// throttle — limitar frecuencia de emision
let sensor = PassthroughSubject<Double, Never>()

sensor
    .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
    .sink { print("Lectura: \($0)") }
    .store(in: &cancellables)

// MARK: - Operators de combinacion

// combineLatest — combinar el ultimo valor de cada publisher
let temperatura = CurrentValueSubject<Double, Never>(20.0)
let humedad = CurrentValueSubject<Double, Never>(60.0)

temperatura
    .combineLatest(humedad)
    .map { temp, hum in
        "Temp: \(temp)C, Humedad: \(hum)%"
    }
    .sink { print($0) }
    .store(in: &cancellables)

temperatura.send(22.5) // emite: "Temp: 22.5C, Humedad: 60.0%"
humedad.send(55.0)     // emite: "Temp: 22.5C, Humedad: 55.0%"

// merge — combinar multiples publishers del mismo tipo
let notificacionesLocales = PassthroughSubject<String, Never>()
let notificacionesPush = PassthroughSubject<String, Never>()

notificacionesLocales
    .merge(with: notificacionesPush)
    .sink { print("Notificacion: \($0)") }
    .store(in: &cancellables)

notificacionesLocales.send("Recordatorio local")
notificacionesPush.send("Mensaje push")
// Ambos llegan al mismo sink
```

### @Published y ObservableObject — El Patron Pre-@Observable

```swift
import Combine
import SwiftUI

// MARK: - El patron ANTIGUO con Combine (pre-iOS 17)
// NO uses esto en codigo nuevo — usa @Observable

class ContadorViewModelLegacy: ObservableObject {
    @Published var contador: Int = 0
    @Published var mensaje: String = ""
    @Published var textoBusqueda: String = ""

    @Published private(set) var resultados: [String] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Reaccionar a cambios en textoBusqueda con Combine
        $textoBusqueda
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] texto in
                self?.buscar(texto: texto)
            }
            .store(in: &cancellables)

        // Actualizar mensaje cuando cambia el contador
        $contador
            .map { valor in
                switch valor {
                case 0: return "Empieza a contar"
                case 1...10: return "Vas bien"
                case 11...50: return "Impresionante"
                default: return "Eres imparable!"
                }
            }
            .assign(to: &$mensaje)
            // assign(to:) con & no necesita AnyCancellable
    }

    func incrementar() {
        contador += 1
    }

    private func buscar(texto: String) {
        // Simular busqueda
        resultados = ["Resultado 1 para '\(texto)'", "Resultado 2 para '\(texto)'"]
    }
}

// Vista que usa ObservableObject (patron antiguo)
struct ContadorViewLegacy: View {
    @StateObject private var viewModel = ContadorViewModelLegacy()
    // @StateObject para crear, @ObservedObject para inyectar

    var body: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.contador)")
                .font(.largeTitle)
            Text(viewModel.mensaje)
                .foregroundStyle(.secondary)

            Button("Incrementar") {
                viewModel.incrementar()
            }

            TextField("Buscar...", text: $viewModel.textoBusqueda)
                .textFieldStyle(.roundedBorder)

            ForEach(viewModel.resultados, id: \.self) { resultado in
                Text(resultado)
            }
        }
        .padding()
    }
}
```

### Combine vs async/await — Comparacion Directa

```swift
import Combine
import Foundation

// MARK: - La misma funcionalidad: Combine vs async/await

// ============================================
// VERSION COMBINE (legacy)
// ============================================
class BuscadorCombine {
    private var cancellables = Set<AnyCancellable>()

    func buscar(termino: String) -> AnyPublisher<[String], Error> {
        let url = URL(string: "https://api.ejemplo.com/buscar?q=\(termino)")!

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [String].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func iniciar() {
        buscar(termino: "Swift")
            .retry(3)
            .catch { error -> Just<[String]> in
                print("Error: \(error)")
                return Just([])
            }
            .sink { resultados in
                print("Resultados: \(resultados)")
            }
            .store(in: &cancellables)
    }
}

// ============================================
// VERSION ASYNC/AWAIT (moderna)
// ============================================
actor BuscadorModerno {
    func buscar(termino: String) async throws -> [String] {
        let url = URL(string: "https://api.ejemplo.com/buscar?q=\(termino)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([String].self, from: data)
    }

    func buscarConRetry(termino: String, intentos: Int = 3) async -> [String] {
        for intento in 1...intentos {
            do {
                return try await buscar(termino: termino)
            } catch {
                print("Intento \(intento) fallo: \(error)")
                if intento == intentos { return [] }
                try? await Task.sleep(for: .seconds(1))
            }
        }
        return []
    }
}

// ============================================
// COMPARACION: @Published vs @Observable
// ============================================

// ANTIGUO — ObservableObject + @Published + Combine
class SettingsLegacy: ObservableObject {
    @Published var tema: String = "claro"
    @Published var fontSize: Double = 16
    @Published var notificaciones: Bool = true
    // SwiftUI re-renderiza TODO el body cuando CUALQUIER @Published cambia
}

// MODERNO — @Observable (iOS 17+)
import Observation

@Observable
class SettingsModerno {
    var tema: String = "claro"
    var fontSize: Double = 16
    var notificaciones: Bool = true
    // SwiftUI solo re-renderiza las vistas que leen la propiedad que cambio
}
```

### Migracion de Combine a async/await

```swift
import Combine
import Foundation

// MARK: - Estrategias de migracion

// 1. Convertir Publisher a async sequence
extension Publisher where Failure == Never {
    /// Convierte un Publisher Combine a AsyncStream
    func asAsyncStream() -> AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

// 2. Convertir Publisher con error a throwing async
extension Publisher {
    /// Obtener el primer valor de un Publisher como async
    func primerValor() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}

// 3. Ejemplo de migracion gradual
class ServicioMigrando {
    // PASO 1: Mantener la API Combine existente
    func obtenerDatosCombine() -> AnyPublisher<[String], Error> {
        // implementacion Combine existente
        Just(["dato1", "dato2"])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // PASO 2: Agregar nueva API async que usa la de Combine internamente
    func obtenerDatos() async throws -> [String] {
        try await obtenerDatosCombine().primerValor()
    }

    // PASO 3: Eventualmente, reescribir sin Combine
    func obtenerDatosV2() async throws -> [String] {
        // Implementacion directa sin Combine
        return ["dato1", "dato2"]
    }
}
```

### APIs de Apple que aun usan Combine

```swift
import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// MARK: - APIs que aun devuelven Publishers

// 1. NotificationCenter
NotificationCenter.default
    .publisher(for: UIApplication.didBecomeActiveNotification)
    .sink { _ in
        print("App activa")
    }
    .store(in: &cancellables)

// Equivalente moderno:
// for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
//     print("App activa")
// }

// 2. Timer
Timer.publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .sink { fecha in
        print("Tick: \(fecha)")
    }
    .store(in: &cancellables)

// 3. KVO (Key-Value Observing)
let defaults = UserDefaults.standard
defaults.publisher(for: \.nombreClave)
    .sink { nuevoValor in
        print("Cambio: \(nuevoValor)")
    }
    .store(in: &cancellables)
```

---

## Ejercicio 1: Pipeline de Transformacion (Basico)

**Objetivo**: Crear un pipeline Combine que procese una secuencia de datos.

**Requisitos**:
1. Crear un Publisher a partir de un array de 20 numeros enteros aleatorios
2. Filtrar solo los numeros pares
3. Transformar cada numero a su representacion en texto ("Doce", "Cuatro", etc.) usando map
4. Eliminar duplicados consecutivos con `removeDuplicates()`
5. Limitar a los primeros 5 resultados con `prefix(5)`
6. Imprimir cada valor recibido y el completion

---

## Ejercicio 2: Buscador con Debounce (Intermedio)

**Objetivo**: Implementar un campo de busqueda con debounce usando Combine y comparar con async/await.

**Requisitos**:
1. Crear un ObservableObject con `@Published var textoBusqueda`
2. Pipeline: debounce 300ms → removeDuplicates → filter (minimo 2 caracteres) → buscar
3. Mostrar indicador de carga mientras busca
4. Manejar errores con `catch` y mostrar mensaje al usuario
5. Cancelar busqueda anterior si el usuario sigue escribiendo (switchToLatest o flatMap(.latest))
6. Crear una version equivalente usando async/await + Task.cancel para comparar

---

## Ejercicio 3: Migracion Completa de Combine a async/await (Avanzado)

**Objetivo**: Tomar un ViewModel basado en Combine y migrarlo completamente a async/await.

**Requisitos**:
1. ViewModel original con: 3 @Published propiedades, 2 pipelines Combine, 1 timer, 1 NotificationCenter observer
2. Migrar @Published a @Observable
3. Migrar pipelines a funciones async con Task
4. Migrar timer a `Task.sleep` en un loop
5. Migrar NotificationCenter a `notifications(named:)`
6. Verificar que el comportamiento es identico antes y despues
7. Documentar cada paso de la migracion con comentarios explicativos

---

## 5 Errores Comunes

### 1. Olvidar almacenar el AnyCancellable
```swift
// MAL — la suscripcion se cancela inmediatamente
func configurar() {
    subject.sink { valor in
        print(valor) // NUNCA se ejecuta
    }
    // el AnyCancellable se destruye al salir del scope
}

// BIEN — almacenar en una propiedad
private var cancellables = Set<AnyCancellable>()

func configurar() {
    subject.sink { valor in
        print(valor) // funciona correctamente
    }
    .store(in: &cancellables)
}
```

### 2. Olvidar receive(on: DispatchQueue.main)
```swift
// MAL — actualizar UI desde background thread
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: [Item].self, decoder: JSONDecoder())
    .sink { items in
        self.items = items // CRASH: UI update desde background
    }
    .store(in: &cancellables)

// BIEN — mover a main thread antes de actualizar UI
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: [Item].self, decoder: JSONDecoder())
    .receive(on: DispatchQueue.main) // <-- antes del sink
    .sink { items in
        self.items = items // seguro en main thread
    }
    .store(in: &cancellables)
```

### 3. Usar @ObservedObject en lugar de @StateObject para creacion
```swift
// MAL — se recrea en cada render
struct MiVista: View {
    @ObservedObject var viewModel = MiViewModel() // se recrea!

    var body: some View { Text("Hola") }
}

// BIEN — @StateObject para crear, @ObservedObject para inyectar
struct MiVista: View {
    @StateObject private var viewModel = MiViewModel() // se crea una vez

    var body: some View { Text("Hola") }
}

// MEJOR — usar @Observable (moderno, no necesita wrappers)
struct MiVistaModerna: View {
    @State private var viewModel = MiViewModelModerno() // @Observable

    var body: some View { Text("Hola") }
}
```

### 4. Cadenas de operators sin eraseToAnyPublisher
```swift
// MAL — tipo de retorno imposible de escribir
func buscar() -> Publishers.FlatMap<Publishers.Map<...>, Publishers.Filter<...>> {
    // tipo inmanejable
}

// BIEN — borrar el tipo con eraseToAnyPublisher
func buscar() -> AnyPublisher<[String], Error> {
    subject
        .filter { !$0.isEmpty }
        .flatMap { texto in
            self.fetchResultados(texto)
        }
        .eraseToAnyPublisher() // tipo limpio
}
```

### 5. No cancelar suscripciones al desaparecer la vista
```swift
// MAL — la suscripcion sigue activa aunque la vista ya no existe
class MiViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    init() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.actualizar() // memory leak si la vista se destruye
            }
            .store(in: &cancellables)
    }
    // cancellables se limpia con deinit, pero solo si no hay retain cycle
}

// BIEN — usar [weak self] para evitar retain cycles
Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()
    .sink { [weak self] _ in
        self?.actualizar() // se libera correctamente
    }
    .store(in: &cancellables)
```

---

## Checklist

- [ ] Entender Publisher, Subscriber y el flujo de datos en Combine
- [ ] Usar sink y assign para suscribirse a Publishers
- [ ] Aplicar operators de transformacion: map, compactMap, flatMap
- [ ] Aplicar operators de filtrado: filter, removeDuplicates, debounce
- [ ] Aplicar operators de combinacion: combineLatest, merge, zip
- [ ] Entender @Published y ObservableObject (patron legacy)
- [ ] Gestionar AnyCancellable correctamente con store(in:)
- [ ] Comparar Combine con async/await y entender cuando usar cada uno
- [ ] Migrar un pipeline Combine a async/await
- [ ] Reconocer APIs de Apple que aun devuelven Publishers

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Combine aparece en el Proyecto Integrador como referencia y migracion:
- **Codebases existentes** que encuentres usaran Combine — ahora puedes leerlas y mantenerlas
- **Migracion gradual** de @Published a @Observable sin romper funcionalidad existente
- **APIs de Apple** como NotificationCenter y Timer aun devuelven Publishers — sabras como consumirlos
- **Debounce en busqueda** es un patron que implementaste con async/await pero que entiendes su origen en Combine
- **Interoperabilidad** entre Combine y async/await usando `values` y `AsyncStream` cuando sea necesario
- **Code reviews** donde puedes sugerir migraciones concretas de Combine a tecnologias modernas

---

*Leccion 43 | Combine (Referencia Legacy) | Semana 52 | Modulo 12: Extras y Especializacion*
*Siguiente: Leccion 44 — Open Source y Comunidad*
