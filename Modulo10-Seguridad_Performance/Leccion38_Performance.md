# Leccion 38: Performance — Instruments, Profiling, Optimizacion

**Modulo 10: Seguridad y Performance** | Semana 48

---

## TL;DR — Resumen en 2 minutos

- **Instruments** es la herramienta de profiling de Apple — mide tiempo, memoria, energia y mas en tu app real
- **Time Profiler** muestra donde se gasta el CPU — identifica funciones lentas y cuellos de botella
- **Allocations** rastrea cada byte de memoria — detecta crecimiento descontrolado y objetos que no se liberan
- **Leaks** encuentra memory leaks — ciclos de referencia que impiden la desalocacion
- **SwiftUI Instrument** mide evaluaciones de body — cada evaluacion innecesaria es un frame perdido

> Herramienta: **Xcode 26 Instruments** (Product > Profile, o Cmd+I) para profiling en dispositivo real

---

## Cupertino MCP

```bash
cupertino search "Instruments performance"
cupertino search "Time Profiler"
cupertino search --source apple-docs "Instruments"
cupertino search "memory management Swift"
cupertino search "SwiftUI performance"
cupertino search --source updates "Instruments iOS 26"
cupertino search "energy efficiency iOS"
cupertino search "launch time optimization"
cupertino search --source hig "performance"
cupertino search --source samples "performance"
cupertino search "MetricKit"
cupertino search_symbols "os_signpost"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Instruments | Novedades Instruments para iOS 26 |
| WWDC24 | [Analyze heap memory](https://developer.apple.com/videos/play/wwdc2024/10173/) | **Esencial** — memoria heap |
| WWDC23 | [Analyze hangs with Instruments](https://developer.apple.com/videos/play/wwdc2023/10248/) | Detectar hangs y stutters |
| WWDC22 | [Improve app size and runtime performance](https://developer.apple.com/videos/play/wwdc2022/110363/) | Tamano y arranque |
| WWDC21 | [Detect and diagnose memory issues](https://developer.apple.com/videos/play/wwdc2021/10180/) | Diagnostico de memoria |
| WWDC24 | [Demystify SwiftUI performance](https://developer.apple.com/videos/play/wwdc2024/) | SwiftUI internals |
| EN | [Sean Allen — Performance](https://www.youtube.com/@seanallen) | Tips practicos |
| EN | [Paul Hudson — SwiftUI Performance](https://www.hackingwithswift.com) | Optimizacion SwiftUI |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Performance?

Una app que funciona correctamente pero es lenta, es una app rota. El 53% de los usuarios abandonan una app que tarda mas de 3 segundos en cargar. Los stutters en scroll hacen que tu app se sienta barata. Los memory leaks causan crashes silenciosos. Performance no es optimizacion prematura — es calidad basica.

Hay cuatro dimensiones de performance:
1. **Tiempo de CPU**: Cuanto tarda en ejecutarse tu codigo
2. **Memoria**: Cuanta RAM consume tu app
3. **Energia**: Cuanta bateria drena
4. **Responsividad**: El main thread esta libre para responder al usuario

### Instruments — Tu Laboratorio de Performance

Instruments es la herramienta de profiling integrada en Xcode. No adivines donde esta el problema — midelo.

#### Como Lanzar Instruments

```swift
// MARK: - Lanzar Instruments desde Xcode

/// 1. Cmd + I (Product > Profile)
///    - Compila en modo Release (optimizado)
///    - Abre el selector de plantillas de Instruments

/// 2. Seleccionar plantilla:
///    - Time Profiler: para CPU
///    - Allocations: para memoria
///    - Leaks: para memory leaks
///    - SwiftUI: para evaluaciones de views
///    - Energy Log: para consumo de bateria
///    - Network: para llamadas de red
///    - Animation Hitches: para stutters en UI

/// 3. SIEMPRE hacer profiling en dispositivo fisico
///    - El Simulator usa la CPU de tu Mac (resultados no reales)
///    - El dispositivo tiene restricciones reales de RAM y CPU

/// 4. Usar modo Release, no Debug
///    - Debug tiene optimizaciones desactivadas
///    - Los resultados en Debug son engañosos
```

### Time Profiler — Donde se Gasta el Tiempo

Time Profiler muestrea el stack de llamadas cada milisegundo. Te muestra exactamente que funciones consumen mas CPU.

```swift
import Foundation

// MARK: - Ejemplo: Codigo lento que Time Profiler detectaria

/// Este codigo tiene un problema de performance que
/// Time Profiler revelaria inmediatamente

struct ProcesadorDatos {

    // MAL — O(n^2) innecesario
    func buscarDuplicadosLento(_ numeros: [Int]) -> [Int] {
        var duplicados: [Int] = []
        for i in 0..<numeros.count {
            for j in (i + 1)..<numeros.count {
                if numeros[i] == numeros[j] && !duplicados.contains(numeros[i]) {
                    duplicados.append(numeros[i])
                }
            }
        }
        return duplicados
    }

    // BIEN — O(n) con Set
    func buscarDuplicadosRapido(_ numeros: [Int]) -> [Int] {
        var vistos = Set<Int>()
        var duplicados = Set<Int>()

        for numero in numeros {
            if vistos.contains(numero) {
                duplicados.insert(numero)
            }
            vistos.insert(numero)
        }

        return Array(duplicados)
    }
}

// Medir la diferencia
let datos = (0..<10_000).map { _ in Int.random(in: 0..<1000) }
let procesador = ProcesadorDatos()

let inicioLento = CFAbsoluteTimeGetCurrent()
let resultadoLento = procesador.buscarDuplicadosLento(datos)
let tiempoLento = CFAbsoluteTimeGetCurrent() - inicioLento

let inicioRapido = CFAbsoluteTimeGetCurrent()
let resultadoRapido = procesador.buscarDuplicadosRapido(datos)
let tiempoRapido = CFAbsoluteTimeGetCurrent() - inicioRapido

print("Lento: \(String(format: "%.4f", tiempoLento))s — \(resultadoLento.count) duplicados")
print("Rapido: \(String(format: "%.4f", tiempoRapido))s — \(resultadoRapido.count) duplicados")
print("Mejora: \(String(format: "%.0f", tiempoLento / tiempoRapido))x mas rapido")
```

**Pregunta Socratica**: Time Profiler muestra que una funcion toma el 40% del CPU. Eso significa que es un problema? Que mas necesitas saber antes de optimizar?

#### Instrumentar con os_signpost

```swift
import Foundation
import os

// MARK: - os_signpost para medir intervalos especificos

/// os_signpost marca puntos en el timeline de Instruments
/// Aparecen como barras coloreadas en la linea de tiempo
/// Perfectos para medir operaciones de negocio

let logger = OSLog(subsystem: "com.miapp", category: "Performance")

func cargarYProcesarDatos() async {
    // Marcar inicio de la operacion
    let signpostID = OSSignpostID(log: logger)

    os_signpost(
        .begin,
        log: logger,
        name: "Carga de Datos",
        signpostID: signpostID,
        "Iniciando carga de %d registros", 1000
    )

    // Simular carga de red
    try? await Task.sleep(for: .milliseconds(500))

    os_signpost(
        .event,
        log: logger,
        name: "Carga de Datos",
        signpostID: signpostID,
        "Datos recibidos, iniciando procesamiento"
    )

    // Simular procesamiento
    try? await Task.sleep(for: .milliseconds(200))

    os_signpost(
        .end,
        log: logger,
        name: "Carga de Datos",
        signpostID: signpostID,
        "Completado: %d registros procesados", 1000
    )
}

// En Instruments, veras una barra "Carga de Datos" con los eventos marcados
```

### Allocations — Rastreo de Memoria

Allocations muestra cada objeto que tu app crea, cuanta memoria ocupa y cuando se libera (o no).

```swift
import Foundation

// MARK: - Patrones de memoria que Allocations detecta

/// 1. Crecimiento descontrolado — memoria que sube y nunca baja
/// 2. Objetos abandonados — no son leaks pero tampoco se usan
/// 3. Picos de memoria — asignaciones masivas temporales

// Ejemplo: Crecimiento descontrolado por cache sin limite
class CacheSinLimite {
    // MAL — crece indefinidamente
    private var cache: [String: Data] = [:]

    func guardar(clave: String, datos: Data) {
        cache[clave] = datos
        // Nunca se elimina nada!
    }
}

// BIEN — Cache con limite usando NSCache
class CacheConLimite {
    private let cache = NSCache<NSString, NSData>()

    init() {
        // Limite de 50 MB
        cache.totalCostLimit = 50 * 1024 * 1024
        // Limite de 100 objetos
        cache.countLimit = 100
    }

    func guardar(clave: String, datos: Data) {
        cache.setObject(
            datos as NSData,
            forKey: clave as NSString,
            cost: datos.count
        )
    }

    func leer(clave: String) -> Data? {
        cache.object(forKey: clave as NSString) as Data?
    }
}

// Ejemplo: Pico de memoria por procesamiento masivo
func procesarImagenesMAL(_ urls: [URL]) async throws -> [Data] {
    // MAL — carga TODAS las imagenes en memoria simultaneamente
    var resultados: [Data] = []
    for url in urls {
        let (datos, _) = try await URLSession.shared.data(from: url)
        resultados.append(datos) // Pico de memoria!
    }
    return resultados
}

func procesarImagenesBIEN(_ urls: [URL]) async throws {
    // BIEN — procesar en lotes
    let tamanoDeLote = 5
    for lote in stride(from: 0, to: urls.count, by: tamanoDeLote) {
        let fin = min(lote + tamanoDeLote, urls.count)
        let urlsDelLote = Array(urls[lote..<fin])

        await withTaskGroup(of: Void.self) { grupo in
            for url in urlsDelLote {
                grupo.addTask {
                    guard let (datos, _) = try? await URLSession.shared.data(from: url) else {
                        return
                    }
                    // Procesar y guardar resultado, liberar datos
                    await self.guardarResultado(datos)
                }
            }
        }
        // Cada lote se libera antes de cargar el siguiente
    }
}
```

### Leaks — Detectar Memory Leaks

Un memory leak ocurre cuando objetos se referencian mutuamente y ninguno puede ser liberado. En Swift, esto sucede con ciclos de referencias fuertes entre clases.

```swift
import Foundation

// MARK: - Memory Leaks — Ciclos de referencia

/// ARC (Automatic Reference Counting) libera objetos cuando
/// su reference count llega a 0.
/// Un ciclo de referencia impide que esto suceda.

// MAL — Ciclo de referencia = Memory Leak
class Controlador {
    var servicio: Servicio?
    let nombre: String

    init(nombre: String) {
        self.nombre = nombre
        print("\(nombre) init")
    }

    deinit {
        print("\(nombre) deinit") // NUNCA se llama!
    }
}

class Servicio {
    var controlador: Controlador? // Referencia fuerte de vuelta!
    let nombre: String

    init(nombre: String) {
        self.nombre = nombre
        print("\(nombre) init")
    }

    deinit {
        print("\(nombre) deinit") // NUNCA se llama!
    }
}

// Esto crea un leak:
func crearLeak() {
    let ctrl = Controlador(nombre: "MiControlador")
    let srv = Servicio(nombre: "MiServicio")

    ctrl.servicio = srv
    srv.controlador = ctrl
    // Al salir del scope, ambos tienen reference count > 0
    // Ninguno puede ser liberado
}

// BIEN — Romper el ciclo con weak
class ControladorSeguro {
    var servicio: ServicioSeguro?
    let nombre: String

    init(nombre: String) {
        self.nombre = nombre
        print("\(nombre) init")
    }

    deinit {
        print("\(nombre) deinit") // Se llama correctamente
    }
}

class ServicioSeguro {
    weak var controlador: ControladorSeguro? // weak rompe el ciclo
    let nombre: String

    init(nombre: String) {
        self.nombre = nombre
        print("\(nombre) init")
    }

    deinit {
        print("\(nombre) deinit") // Se llama correctamente
    }
}

// Sin leak:
func sinLeak() {
    let ctrl = ControladorSeguro(nombre: "CtrlSeguro")
    let srv = ServicioSeguro(nombre: "SrvSeguro")

    ctrl.servicio = srv
    srv.controlador = ctrl
    // Al salir, ctrl se libera, srv.controlador es nil, srv se libera
}

crearLeak()    // deinit NUNCA se llama
sinLeak()      // deinit se llama para ambos

// MARK: - Closures y ciclos de referencia

class DescargadorImagenes {
    var imagen: Data?
    var onCompleto: (() -> Void)?

    func descargar(url: URL) {
        // MAL — self capturado fuertemente en el closure
        onCompleto = {
            print("Imagen descargada: \(self.imagen?.count ?? 0) bytes")
        }

        // BIEN — capture list con [weak self]
        onCompleto = { [weak self] in
            guard let self else { return }
            print("Imagen descargada: \(self.imagen?.count ?? 0) bytes")
        }
    }

    deinit {
        print("DescargadorImagenes deinit")
    }
}
```

**Pregunta Socratica**: Cual es la diferencia entre `weak` y `unowned`? En que escenarios usarias `unowned` con seguridad?

### SwiftUI Performance — Evaluaciones de Body

Cada vez que SwiftUI evalua el `body` de una View, compara el resultado con el anterior y aplica los cambios. Evaluaciones innecesarias desperdician CPU y causan stutters.

```swift
import SwiftUI

// MARK: - SwiftUI Performance Patterns

/// SwiftUI reevalua body cuando:
/// 1. Un @State/@Binding cambia
/// 2. Un @Observable cambia una propiedad observada
/// 3. El parent se reevalua
/// 4. Un @Environment cambia

/// El SwiftUI Instrument muestra cada evaluacion de body
/// y cuanto tiempo tomo

// MAL — Vista monolitica que se reevalua completamente
struct VistaMonoliticaMAL: View {
    @State private var contador = 0
    @State private var nombre = ""
    @State private var items = (0..<100).map { "Item \($0)" }

    var body: some View {
        VStack {
            // Cambiar contador reevalua TODO, incluyendo la lista
            Text("Contador: \(contador)")
            Button("Incrementar") { contador += 1 }

            TextField("Nombre", text: $nombre)

            // Esta lista se reevalua cada vez que contador cambia!
            List(items, id: \.self) { item in
                FilaCompleja(titulo: item)
            }
        }
    }
}

// BIEN — Separar en sub-views independientes
struct VistaSeparadaBIEN: View {
    var body: some View {
        VStack {
            ContadorView()      // Solo se reevalua cuando SU estado cambia
            NombreView()        // Independiente del contador
            ListaItemsView()    // Independiente de ambos
        }
    }
}

struct ContadorView: View {
    @State private var contador = 0

    var body: some View {
        VStack {
            Text("Contador: \(contador)")
            Button("Incrementar") { contador += 1 }
        }
    }
}

struct NombreView: View {
    @State private var nombre = ""

    var body: some View {
        TextField("Nombre", text: $nombre)
    }
}

struct ListaItemsView: View {
    let items = (0..<100).map { "Item \($0)" }

    var body: some View {
        List(items, id: \.self) { item in
            FilaCompleja(titulo: item)
        }
    }
}

struct FilaCompleja: View {
    let titulo: String

    var body: some View {
        HStack {
            Image(systemName: "star")
            Text(titulo)
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}

// MARK: - Computaciones costosas en body

// MAL — Filtrar y ordenar en cada evaluacion de body
struct ListaFiltradaMAL: View {
    @State private var busqueda = ""
    let todosLosItems: [String]

    var body: some View {
        // Esto se ejecuta en CADA evaluacion de body
        let filtrados = todosLosItems
            .filter { $0.localizedCaseInsensitiveContains(busqueda) }
            .sorted()

        List(filtrados, id: \.self) { item in
            Text(item)
        }
    }
}

// BIEN — Mover logica fuera del body
@Observable
class ListaViewModel {
    var busqueda = "" {
        didSet { filtrar() }
    }

    private(set) var itemsFiltrados: [String] = []
    private let todosLosItems: [String]

    init(items: [String]) {
        self.todosLosItems = items
        self.itemsFiltrados = items
    }

    private func filtrar() {
        if busqueda.isEmpty {
            itemsFiltrados = todosLosItems
        } else {
            itemsFiltrados = todosLosItems
                .filter { $0.localizedCaseInsensitiveContains(busqueda) }
        }
    }
}

struct ListaFiltradaBIEN: View {
    @State private var viewModel: ListaViewModel

    init(items: [String]) {
        _viewModel = State(initialValue: ListaViewModel(items: items))
    }

    var body: some View {
        // body solo lee itemsFiltrados — no hace computo
        List(viewModel.itemsFiltrados, id: \.self) { item in
            Text(item)
        }
        .searchable(text: $viewModel.busqueda)
    }
}
```

### Optimizacion de Launch Time

El tiempo de arranque es la primera impresion. Apple recomienda menos de 400ms para aparecer interactiva.

```swift
import SwiftUI
import os

// MARK: - Optimizacion de Launch Time

/// Fases del arranque:
/// 1. Pre-main: Carga de dylibs, inicializacion de runtime
/// 2. Post-main: Tu codigo en @main hasta primer frame
/// 3. Extended: Carga de datos iniciales

/// El App Launch Instrument muestra cada fase

@main
struct MiApp: App {
    // MAL — Trabajo pesado en init
    // init() {
    //     cargarBaseDeDatos()    // Bloquea el arranque!
    //     sincronizarServidor()  // No es necesario al inicio!
    //     precalcularEstadisticas() // Puede esperar!
    // }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // BIEN — Diferir trabajo no critico
                    await cargaInicial()
                }
        }
    }

    func cargaInicial() async {
        // Fase 1: Lo minimo para mostrar UI (< 100ms)
        // Ya esta hecho — SwiftUI muestra ContentView

        // Fase 2: Datos necesarios para la primera pantalla
        async let datos = cargarDatosLocales()

        // Fase 3: Trabajo en background que puede esperar
        Task.detached(priority: .background) {
            await precalcularEstadisticas()
        }

        // Esperar solo lo necesario
        _ = await datos
    }
}

// MARK: - Reducir pre-main time

/// Para reducir el tiempo pre-main:
/// 1. Minimizar frameworks dinamicos — usar static linking
/// 2. Evitar +load y +initialize (Objective-C legacy)
/// 3. Reducir inicializadores globales
/// 4. Usar lazy para propiedades costosas

struct ConfiguracionApp {
    // MAL — Se inicializa al cargar el tipo
    // static let configuracion = cargarConfiguracionCompleta()

    // BIEN — Se inicializa la primera vez que se accede
    static var configuracion: Configuracion {
        if _configuracion == nil {
            _configuracion = cargarConfiguracionMinima()
        }
        return _configuracion!
    }
    private static var _configuracion: Configuracion?
}

struct Configuracion {
    let apiURL: URL
    let version: String
}

func cargarConfiguracionMinima() -> Configuracion {
    Configuracion(
        apiURL: URL(string: "https://api.miapp.com")!,
        version: "1.0"
    )
}
```

### Reduccion de Tamano de Binario

Un binario mas pequeno se descarga mas rapido y ocupa menos espacio en el dispositivo del usuario.

```swift
// MARK: - Reduccion de tamano de binario

/// Configuraciones en Build Settings:

/// 1. Optimization Level
///    - Debug: -Onone (sin optimizacion)
///    - Release: -Osize (optimizar para tamano) o -O (optimizar para velocidad)

/// 2. Strip Debug Symbols
///    - Release: Strip Linked Product = YES
///    - Genera dSYM para symbolication de crashes

/// 3. Dead Code Stripping
///    - DEAD_CODE_STRIPPING = YES
///    - Elimina funciones que nunca se llaman

/// 4. Asset Catalogs
///    - Usar Asset Catalog (no archivos sueltos)
///    - Habilitar App Thinning para enviar solo assets necesarios
///    - Comprimir imagenes antes de agregarlas

/// 5. Codigo
///    - Eliminar imports no usados
///    - Evitar generics excesivos (cada especializacion genera codigo)
///    - Usar @inlinable con precaucion

// Ejemplo: Auditar imports no usados
// En Xcode: Build Settings > "Unused" para warnings relevantes

/// 6. Frameworks
///    - Preferir frameworks del sistema sobre terceros
///    - Si un framework de terceros solo se usa para 1 funcion,
///      considera implementar esa funcion directamente
```

### Eficiencia Energetica

Una app que drena bateria recibe malas reseñas y puede ser limitada por el sistema.

```swift
import Foundation

// MARK: - Eficiencia energetica

/// Las operaciones mas costosas en bateria:
/// 1. GPS continuos (usa significantLocationChange cuando puedas)
/// 2. Networking frecuente (agrupa peticiones, usa background fetch)
/// 3. CPU intensivo en foreground (mueve a background queue)
/// 4. Animaciones continuas (pausar cuando no son visibles)

// MAL — Timer que ejecuta cada segundo, siempre
class MonitorMAL {
    var timer: Timer?

    func iniciar() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.verificarActualizaciones()
        }
    }

    func verificarActualizaciones() {
        // Peticion de red cada segundo — destruye bateria
    }
}

// BIEN — Usar BGTaskScheduler y adaptive timing
class MonitorBIEN {
    private var intervaloActual: TimeInterval = 5.0
    private var task: Task<Void, Never>?

    func iniciar() {
        task = Task {
            while !Task.isCancelled {
                let hayNovedad = await verificarActualizaciones()

                // Backoff adaptativo: si no hay novedades, esperar mas
                if hayNovedad {
                    intervaloActual = 5.0
                } else {
                    intervaloActual = min(intervaloActual * 1.5, 60.0)
                }

                try? await Task.sleep(for: .seconds(intervaloActual))
            }
        }
    }

    func detener() {
        task?.cancel()
    }

    func verificarActualizaciones() async -> Bool {
        // Solo verificar si es necesario
        return false
    }
}

// MARK: - Agrupar trabajo de red

/// URLSession automaticamente agrupa peticiones cuando usas:
/// - Background sessions
/// - waitsForConnectivity = true
/// - isDiscretionary = true (el sistema elige cuando ejecutar)

func crearSesionEficiente() -> URLSession {
    let config = URLSessionConfiguration.default

    // Esperar conectividad en lugar de fallar inmediatamente
    config.waitsForConnectivity = true

    // Permitir que el sistema optimice la peticion
    config.isDiscretionary = false // true solo para tareas no urgentes

    // Timeout razonable
    config.timeoutIntervalForRequest = 30

    return URLSession(configuration: config)
}
```

### Anti-patrones de Performance en SwiftUI

```swift
import SwiftUI

// MARK: - Anti-patrones comunes en SwiftUI

// Anti-patron 1: Crear objetos en body
struct VistaMAL1: View {
    var body: some View {
        // MAL — DateFormatter se crea en CADA evaluacion
        let formatter = DateFormatter()
        formatter.dateStyle = .long

        return Text(formatter.string(from: .now))
    }
}

struct VistaBIEN1: View {
    // BIEN — DateFormatter se crea una sola vez
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    var body: some View {
        Text(Self.formatter.string(from: .now))
    }
}

// Anti-patron 2: AnyView borra tipo y previene diffing eficiente
struct VistaMAL2: View {
    let mostrarImagen: Bool

    var body: some View {
        // MAL — AnyView previene optimizaciones de SwiftUI
        if mostrarImagen {
            return AnyView(Image(systemName: "star"))
        } else {
            return AnyView(Text("Sin imagen"))
        }
    }
}

struct VistaBIEN2: View {
    let mostrarImagen: Bool

    var body: some View {
        // BIEN — SwiftUI puede hacer diff eficientemente
        if mostrarImagen {
            Image(systemName: "star")
        } else {
            Text("Sin imagen")
        }
    }
}

// Anti-patron 3: GeometryReader innecesario
struct VistaMAL3: View {
    var body: some View {
        // MAL — GeometryReader cuando solo necesitas ancho completo
        GeometryReader { geo in
            Image(systemName: "star")
                .frame(width: geo.size.width)
        }
    }
}

struct VistaBIEN3: View {
    var body: some View {
        // BIEN — .frame(maxWidth:) logra lo mismo sin GeometryReader
        Image(systemName: "star")
            .frame(maxWidth: .infinity)
    }
}

// Anti-patron 4: Observar todo el modelo cuando solo necesitas una propiedad
@Observable
class ModeloGrande {
    var nombre = ""
    var email = ""
    var avatar: Data?
    var historial: [String] = []
    var configuracion: [String: Any] = [:]
    var contador = 0  // Cambia frecuentemente
}

struct VistaMAL4: View {
    var modelo: ModeloGrande

    var body: some View {
        // MAL — Cada cambio en contador reevalua TODA esta vista
        // aunque solo muestre el nombre
        Text(modelo.nombre)
    }
}

// BIEN — Vista solo observa lo que necesita
struct VistaBIEN4: View {
    let nombre: String // Solo recibe el dato que necesita

    var body: some View {
        Text(nombre)
    }
}

// Anti-patron 5: Trabajo sincrono pesado en body
struct VistaMAL5: View {
    let datos: [Dato]

    var body: some View {
        // MAL — filtrar, mapear y ordenar en body
        let procesados = datos
            .filter { $0.esValido }
            .map { $0.transformar() }
            .sorted { $0.fecha > $1.fecha }

        List(procesados) { item in
            Text(item.titulo)
        }
    }
}

// BIEN — Preprocesar fuera del body
struct VistaBIEN5: View {
    let datosPreparados: [DatoTransformado]

    var body: some View {
        List(datosPreparados) { item in
            Text(item.titulo)
        }
    }
}

// Tipos de soporte para los ejemplos
struct Dato: Identifiable {
    let id = UUID()
    let esValido: Bool
    let fecha: Date
    func transformar() -> DatoTransformado {
        DatoTransformado(titulo: "Item", fecha: fecha)
    }
}

struct DatoTransformado: Identifiable {
    let id = UUID()
    let titulo: String
    let fecha: Date
}
```

### MetricKit — Metricas en Produccion

```swift
import Foundation
// import MetricKit  // Descomentar en proyecto Xcode

// MARK: - MetricKit — Metricas de apps en produccion

/// MetricKit recolecta datos de performance de usuarios reales
/// Recibes reportes diarios con metricas agregadas

/// Metricas disponibles:
/// - Tiempo de arranque (launch time)
/// - Hangs (main thread bloqueado > 250ms)
/// - Uso de memoria
/// - Uso de disco
/// - Uso de red
/// - Uso de bateria
/// - Crashes y excepciones

/*
class MetricsManager: NSObject, MXMetricManagerSubscriber {

    func iniciar() {
        let manager = MXMetricManager.shared
        manager.add(self)
    }

    // Recibido cada 24 horas con metricas agregadas
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // Tiempo de arranque
            if let launchMetric = payload.applicationLaunchMetrics {
                let tiempoMedio = launchMetric.histogrammedResumeTime
                print("Tiempo arranque medio: \(tiempoMedio)")
            }

            // Hangs
            if let hangMetric = payload.applicationResponsivenessMetrics {
                print("Hang diagnostics: \(hangMetric)")
            }

            // Memoria
            if let memMetric = payload.memoryMetrics {
                let picoMemoria = memMetric.peakMemoryUsage
                print("Pico de memoria: \(picoMemoria)")
            }
        }
    }

    // Recibido cuando ocurre un crash o hang significativo
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            if let crashes = payload.crashDiagnostics {
                for crash in crashes {
                    print("Crash: \(crash.callStackTree)")
                }
            }

            if let hangs = payload.hangDiagnostics {
                for hang in hangs {
                    print("Hang: \(hang.hangDuration)")
                }
            }
        }
    }
}
*/
```

---

## Ejercicios

### Ejercicio 1 — Basico: Encontrar y Arreglar Memory Leaks

Dado el siguiente codigo con 3 memory leaks, identifcalos y corrigelos:

```swift
// Codigo con leaks — encontrar y arreglar
class NetworkManager {
    var onComplete: ((Data) -> Void)?
    var cache: [String: Data] = [:]

    func fetchData(url: URL) {
        // Leak 1: Closure captura self fuertemente
        onComplete = { data in
            self.cache[url.absoluteString] = data
            self.procesarDatos(data)
        }
    }

    func procesarDatos(_ data: Data) { }
    deinit { print("NetworkManager deinit") }
}

class ViewController {
    var networkManager: NetworkManager?
    var delegate: ViewControllerDelegate?

    func setup() {
        networkManager = NetworkManager()
        // Leak 2: Delegate con referencia fuerte circular
        delegate = MiDelegate(controller: self)

        // Leak 3: Timer retiene self
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.actualizar()
        }
    }

    func actualizar() { }
    deinit { print("ViewController deinit") }
}

protocol ViewControllerDelegate: AnyObject { }

class MiDelegate: ViewControllerDelegate {
    var controller: ViewController  // Referencia fuerte!

    init(controller: ViewController) {
        self.controller = controller
    }
}
```

**Criterios de exito**: Los 3 deinit se llaman correctamente. Explicar por que cada fix funciona.

### Ejercicio 2 — Intermedio: Optimizar Lista de SwiftUI

Tienes una lista con 10,000 items que tiene scroll con stutters. Optimizala:

```swift
// Vista con problemas de performance — optimizar
@Observable
class CatalogoViewModel {
    var productos: [Producto] = []
    var busqueda = ""
    var ordenAscendente = true

    var productosFiltrados: [Producto] {
        // Ejecutado en CADA evaluacion de body
        productos
            .filter { busqueda.isEmpty || $0.nombre.localizedCaseInsensitiveContains(busqueda) }
            .sorted { ordenAscendente ? $0.precio < $1.precio : $0.precio > $1.precio }
    }
}

struct CatalogoView: View {
    @State var viewModel = CatalogoViewModel()

    var body: some View {
        List(viewModel.productosFiltrados) { producto in
            // Celda costosa que se recrea constantemente
            VStack {
                AsyncImage(url: producto.imagenURL) // Sin placeholder ni cache
                Text(producto.nombre)
                Text(formateadorPrecio().string(from: NSNumber(value: producto.precio)) ?? "")
            }
        }
        .searchable(text: $viewModel.busqueda)
    }

    // Creado en cada evaluacion!
    func formateadorPrecio() -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "es_MX")
        return f
    }
}

struct Producto: Identifiable {
    let id = UUID()
    let nombre: String
    let precio: Double
    let imagenURL: URL
}
```

**Criterios de exito**: Scroll fluido a 60fps. Busqueda responsiva. Sin re-creacion de formatters.

### Ejercicio 3 — Avanzado: Sistema de Profiling Integrado

Crea un sistema de profiling que tu app pueda usar en produccion:

```swift
// Esqueleto para empezar
actor PerformanceTracker {
    struct Metrica {
        let nombre: String
        let duracion: TimeInterval
        let timestamp: Date
        let metadata: [String: String]
    }

    private var metricas: [Metrica] = []
    private let limiteMetricas = 1000

    /// Medir una operacion asincrona
    func medir<T>(
        nombre: String,
        metadata: [String: String] = [:],
        operacion: () async throws -> T
    ) async rethrows -> T {
        // Implementar medicion con os_signpost
        // Guardar metrica
        // Retornar resultado
    }

    /// Generar reporte de performance
    func generarReporte() -> String {
        // Agrupar por nombre
        // Calcular: promedio, p50, p95, p99, max
        // Formato legible
    }

    /// Detectar regresiones comparando con baseline
    func detectarRegresiones(baseline: [String: TimeInterval]) -> [String] {
        // Si una metrica es >20% mas lenta que el baseline, reportar
    }
}
```

**Criterios de exito**: Mide operaciones con precision de milisegundos. Genera reportes con percentiles. Detecta regresiones automaticamente.

---

## 5 Errores Comunes

### Error 1: Hacer profiling en el Simulator

```swift
// MAL — Profiling en Simulator
// El Simulator usa la CPU de tu Mac (Intel/M-series)
// Los resultados NO representan un iPhone real
// Cmd+I con Simulator seleccionado = resultados invalidos

// BIEN — Siempre hacer profiling en dispositivo fisico
// 1. Conectar iPhone/iPad por cable
// 2. Seleccionar el dispositivo como destino
// 3. Cmd+I para abrir Instruments
// 4. Los resultados reflejan el hardware real del usuario
```

### Error 2: Optimizar sin medir

```swift
// MAL — "Creo que este codigo es lento, voy a optimizarlo"
// Resultado: codigo mas complejo sin mejora real

func procesarDatos(_ datos: [Int]) -> [Int] {
    // "Optimizacion" prematura con unsafe pointers
    // Codigo complejo, dificil de mantener, sin mejora medible
    datos.withUnsafeBufferPointer { buffer in
        // ... codigo innecesariamente complejo ...
        return Array(buffer)
    }
}

// BIEN — Medir primero, optimizar despues
func procesarDatosSimple(_ datos: [Int]) -> [Int] {
    // Simple y legible — medir si realmente es un cuello de botella
    datos.filter { $0 > 0 }.sorted()
}

// Si Instruments muestra que ES un problema, ENTONCES optimizar
// y medir de nuevo para confirmar la mejora
```

### Error 3: Capturar self sin [weak self] en closures de larga vida

```swift
// MAL — Closure retiene self indefinidamente
class DataManager {
    var timer: Timer?

    func iniciar() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.actualizar() // self nunca se libera mientras el timer viva
        }
    }

    func actualizar() { /* ... */ }
}

// BIEN — [weak self] permite la liberacion
class DataManagerSeguro {
    var timer: Timer?

    func iniciar() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.actualizar() // Si self fue liberado, no hace nada
        }
    }

    func actualizar() { /* ... */ }

    deinit {
        timer?.invalidate()
    }
}
```

### Error 4: Crear objetos costosos dentro de body en SwiftUI

```swift
// MAL — NumberFormatter creado en CADA evaluacion de body
struct PrecioView: View {
    let precio: Double

    var body: some View {
        let formatter = NumberFormatter()  // NUEVO cada vez!
        formatter.numberStyle = .currency
        return Text(formatter.string(from: NSNumber(value: precio)) ?? "")
    }
}

// BIEN — Formatter estatico, creado una sola vez
struct PrecioViewOptimizado: View {
    let precio: Double

    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()

    var body: some View {
        Text(Self.formatter.string(from: NSNumber(value: precio)) ?? "")
    }
}
```

### Error 5: Ignorar warnings de memoria del sistema

```swift
// MAL — No manejar didReceiveMemoryWarning
// El sistema mata tu app sin warning visible al usuario

// BIEN — Responder a notificaciones de memoria
class AppLifecycleManager {
    init() {
        // Escuchar notificaciones de memoria baja
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.liberarMemoria()
        }
    }

    func liberarMemoria() {
        // 1. Limpiar caches
        URLCache.shared.removeAllCachedResponses()

        // 2. Liberar imagenes no visibles
        // imageCache.removeAll()

        // 3. Cancelar descargas no criticas
        // downloadManager.cancelNonEssential()

        print("Memoria liberada por warning del sistema")
    }
}
```

---

## Checklist de Objetivos

- [ ] Se como lanzar Instruments desde Xcode (Cmd+I)
- [ ] Entiendo por que debo hacer profiling en dispositivo fisico, no en Simulator
- [ ] Puedo usar Time Profiler para identificar funciones lentas
- [ ] Puedo usar Allocations para detectar crecimiento de memoria
- [ ] Puedo usar Leaks para encontrar ciclos de referencia
- [ ] Se usar os_signpost para instrumentar mi propio codigo
- [ ] Identifico y corrijo memory leaks con weak/unowned
- [ ] Entiendo cuando usar [weak self] vs [unowned self] en closures
- [ ] Aplico patrones de performance en SwiftUI (separar views, evitar AnyView)
- [ ] Se que no debo crear objetos costosos dentro de body
- [ ] Conozco tecnicas para optimizar launch time
- [ ] Entiendo como reducir el tamano del binario
- [ ] Se usar MetricKit para metricas en produccion
- [ ] Puedo explicar las 4 dimensiones de performance (CPU, memoria, energia, responsividad)

---

## Notas Personales

> Espacio para tus reflexiones sobre performance. Preguntate:
> - Cuales son los puntos mas lentos de mi app actual?
> - He medido el launch time de mi app? Cuanto tarda?
> - Tengo memory leaks que no he detectado?
> - Mis listas de SwiftUI hacen scroll fluido con datos reales?
>
> _Escribe aqui tus notas..._

---

## Conexion con el Proyecto Integrador

En el Proyecto Integrador, la performance se valida en cada etapa:

1. **Launch Time**: Medir con App Launch Instrument. Objetivo: < 400ms hasta primer frame interactivo. Diferir toda carga no critica con `.task`
2. **Listas y Scroll**: Usar el SwiftUI Instrument para verificar que las listas del proyecto (items, historial, configuracion) hacen scroll a 60fps sin evaluaciones innecesarias
3. **Memoria**: Navegar por toda la app con Allocations activo. La memoria debe estabilizarse, no crecer indefinidamente. Validar que no hay leaks al navegar entre pantallas
4. **Red**: Agrupar peticiones. Usar cache de URLSession. Implementar retry con backoff exponencial (Leccion 21)
5. **Energia**: Si el proyecto usa LocationManager (Leccion 23) o HealthKit (Leccion 22), verificar con Energy Log que no drenan bateria innecesariamente
6. **MetricKit**: Integrar MetricKit para recibir metricas de usuarios reales despues del lanzamiento. Configurar alertas para regresiones

> La performance no es una tarea final — es una disciplina continua. Cada PR deberia incluir una verificacion de performance en las areas afectadas.

---

*Leccion anterior: [Leccion 37 — Seguridad](Leccion37_Seguridad.md)*
