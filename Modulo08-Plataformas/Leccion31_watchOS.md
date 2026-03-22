# Leccion 31: watchOS — Apps para Apple Watch

**Modulo 08: Plataformas** | Semanas 39-40

---

## TL;DR — Resumen en 2 minutos

- **watchOS apps** pueden ser independientes o companion de iOS — desde watchOS 7, la mayoria son independientes
- **SwiftUI es la unica forma** de crear UI en watchOS — no existe UIKit para Watch
- **NavigationStack** funciona igual que en iOS, pero el espacio es limitado — menos es mas
- **Complications** muestran datos en la esfera del reloj usando WidgetKit — son la cara visible de tu app
- **WatchConnectivity** sincroniza datos entre iPhone y Apple Watch de forma bidireccional

> Herramienta: **Xcode 26** con Apple Watch Simulator para probar complications y Digital Crown

---

## Cupertino MCP

```bash
cupertino search "watchOS"
cupertino search "WatchKit"
cupertino search --source apple-docs "watchOS SwiftUI"
cupertino search "WatchConnectivity"
cupertino search "WidgetKit complications"
cupertino search "HealthKit workout"
cupertino search --source hig "watchOS design"
cupertino search --source samples "watchOS"
cupertino search --source updates "watchOS 26"
cupertino search "Digital Crown SwiftUI"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in watchOS 26 | Novedades watchOS 26 |
| WWDC24 | [Build a great Apple Watch app](https://developer.apple.com/videos/play/wwdc2024/) | **Esencial** — arquitectura |
| WWDC23 | [Design and build apps for watchOS 10](https://developer.apple.com/videos/play/wwdc2023/10138/) | Rediseno watchOS 10 |
| WWDC23 | [Update your app for watchOS 10](https://developer.apple.com/videos/play/wwdc2023/10031/) | Migracion practica |
| EN | [Sean Allen — watchOS](https://www.youtube.com/@seanallen) | Tutoriales claros |
| EN | [Paul Hudson — watchOS](https://www.hackingwithswift.com) | Fundamentos Watch |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que watchOS?

Apple Watch es el dispositivo mas personal de Apple. Esta en la muneca del usuario, siempre visible, siempre accesible. Una app de Watch no es una version reducida de tu app iOS — es una experiencia diseñada para **interacciones de 5-10 segundos**. El usuario levanta la muneca, ve la informacion, actua y baja la muneca.

watchOS tiene tres puntos de contacto con el usuario:
1. **La app**: experiencia completa cuando el usuario la abre
2. **Complications**: datos visibles directamente en la esfera del reloj
3. **Notificaciones**: alertas con acciones rapidas

### Arquitectura de una App watchOS

Desde watchOS 7, las apps pueden ser completamente independientes. No necesitan una app iOS companion para funcionar.

```swift
import SwiftUI

// MARK: - Punto de entrada de la app watchOS
@main
struct MiAppWatch: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Vista principal con TabView
struct ContentView: View {
    @State private var seleccion: Tab = .resumen

    enum Tab: Hashable {
        case resumen
        case actividad
        case configuracion
    }

    var body: some View {
        // En watchOS, TabView usa paginacion vertical por defecto
        TabView(selection: $seleccion) {
            ResumenView()
                .tag(Tab.resumen)

            ActividadView()
                .tag(Tab.actividad)

            ConfiguracionView()
                .tag(Tab.configuracion)
        }
        .tabViewStyle(.verticalPage)
    }
}
```

### SwiftUI en watchOS — Diferencias Clave

SwiftUI funciona en watchOS, pero con restricciones importantes. La pantalla es pequena (40-49mm), el usuario interactua con toques y Digital Crown, y las sesiones son breves.

```swift
import SwiftUI

// MARK: - Navegacion en watchOS
struct ResumenView: View {
    @State private var frecuenciaCardiaca: Int = 72
    @State private var pasosHoy: Int = 6543

    var body: some View {
        NavigationStack {
            List {
                // Seccion de salud
                Section("Salud") {
                    NavigationLink {
                        DetalleFrequenciaView(bpm: frecuenciaCardiaca)
                    } label: {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                            Text("\(frecuenciaCardiaca) BPM")
                        }
                    }

                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundStyle(.green)
                        Text("\(pasosHoy) pasos")
                    }
                }

                // Seccion de acciones rapidas
                Section("Acciones") {
                    Button("Iniciar Entrenamiento") {
                        // Accion
                    }
                    .foregroundStyle(.green)

                    Button("Registrar Agua") {
                        // Accion
                    }
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Mi Salud")
        }
    }
}

struct DetalleFrequenciaView: View {
    let bpm: Int

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundStyle(.red)
                .symbolEffect(.pulse)

            Text("\(bpm)")
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Rango normal")
                .font(.caption2)
                .foregroundStyle(.green)
        }
        .navigationTitle("Frecuencia")
    }
}
```

### Digital Crown — Entrada Unica de watchOS

El Digital Crown es un input unico de watchOS. SwiftUI lo soporta nativamente con `.digitalCrownRotation`.

```swift
import SwiftUI

// MARK: - Uso del Digital Crown
struct SelectorTemperaturaView: View {
    @State private var temperatura: Double = 22.0

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: temperaturaIcono)
                .font(.system(size: 30))
                .foregroundStyle(temperaturaColor)

            Text("\(temperatura, specifier: "%.1f")°C")
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text("Gira la corona para ajustar")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        // Digital Crown: rango 15-30, paso de 0.5
        .focusable()
        .digitalCrownRotation(
            $temperatura,
            from: 15.0,
            through: 30.0,
            by: 0.5,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
    }

    private var temperaturaIcono: String {
        if temperatura < 18 { return "thermometer.snowflake" }
        if temperatura > 26 { return "thermometer.sun.fill" }
        return "thermometer.medium"
    }

    private var temperaturaColor: Color {
        if temperatura < 18 { return .blue }
        if temperatura > 26 { return .red }
        return .green
    }
}
```

### Complications con WidgetKit

Las Complications son la forma principal en que los usuarios ven datos de tu app. Desde watchOS 10, se construyen con WidgetKit, el mismo framework que los widgets de iOS.

```swift
import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct ActividadEntry: TimelineEntry {
    let date: Date
    let pasos: Int
    let calorias: Int
    let distanciaKm: Double
}

// MARK: - Timeline Provider
struct ActividadProvider: TimelineProvider {
    func placeholder(in context: Context) -> ActividadEntry {
        ActividadEntry(date: .now, pasos: 5000, calorias: 250, distanciaKm: 3.2)
    }

    func getSnapshot(in context: Context, completion: @escaping (ActividadEntry) -> Void) {
        let entry = ActividadEntry(date: .now, pasos: 7234, calorias: 340, distanciaKm: 4.8)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ActividadEntry>) -> Void) {
        let entry = ActividadEntry(date: .now, pasos: 7234, calorias: 340, distanciaKm: 4.8)
        // Actualizar cada 15 minutos
        let siguienteActualizacion = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(siguienteActualizacion))
        completion(timeline)
    }
}

// MARK: - Vistas de Complication
struct ActividadComplicationView: View {
    let entry: ActividadEntry
    @Environment(\.widgetFamily) var familia

    var body: some View {
        switch familia {
        case .accessoryCircular:
            // Circular — muestra un dato con gauge
            Gauge(value: Double(entry.pasos), in: 0...10000) {
                Image(systemName: "figure.walk")
            } currentValueLabel: {
                Text("\(entry.pasos / 1000)k")
            }
            .gaugeStyle(.accessoryCircular)

        case .accessoryRectangular:
            // Rectangular — muestra multiples datos
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "figure.walk")
                    Text("\(entry.pasos) pasos")
                }
                .font(.caption)

                HStack {
                    Image(systemName: "flame.fill")
                    Text("\(entry.calorias) kcal")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

        case .accessoryInline:
            // Inline — una sola linea de texto
            Text("\(entry.pasos) pasos | \(entry.calorias) kcal")

        default:
            Text("\(entry.pasos)")
        }
    }
}

// MARK: - Widget Definition
struct ActividadWidget: Widget {
    let kind = "ActividadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ActividadProvider()) { entry in
            ActividadComplicationView(entry: entry)
        }
        .configurationDisplayName("Actividad")
        .description("Muestra tu actividad diaria")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
```

### Workout Sessions con HealthKit

Las sesiones de entrenamiento son una de las funciones estrella de watchOS.

```swift
import SwiftUI
import HealthKit

// MARK: - Workout Manager
@Observable
class WorkoutManager {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    var frecuenciaCardiaca: Double = 0
    var caloriasQuemadas: Double = 0
    var distancia: Double = 0
    var estaActivo: Bool = false

    func solicitarPermisos() async {
        let tipos: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning)
        ]

        let compartir: Set<HKSampleType> = [
            HKQuantityType(.workoutType)
        ]

        do {
            try await healthStore.requestAuthorization(toShare: compartir, read: tipos)
        } catch {
            print("Error solicitando permisos: \(error)")
        }
    }

    func iniciarEntrenamiento(tipo: HKWorkoutActivityType) async {
        let configuracion = HKWorkoutConfiguration()
        configuracion.activityType = tipo
        configuracion.locationType = .outdoor

        do {
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuracion
            )
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuracion
            )

            let inicio = Date()
            session?.startActivity(with: inicio)
            try await builder?.beginCollection(at: inicio)
            estaActivo = true
        } catch {
            print("Error iniciando entrenamiento: \(error)")
        }
    }

    func pausarEntrenamiento() {
        session?.pause()
    }

    func reanudarEntrenamiento() {
        session?.resume()
    }

    func finalizarEntrenamiento() async {
        session?.end()
        do {
            try await builder?.endCollection(at: .now)
            try await builder?.finishWorkout()
            estaActivo = false
        } catch {
            print("Error finalizando: \(error)")
        }
    }
}

// MARK: - Vista de Entrenamiento
struct EntrenamientoView: View {
    @State private var manager = WorkoutManager()

    var body: some View {
        VStack(spacing: 12) {
            if manager.estaActivo {
                // Metricas en vivo
                VStack(spacing: 8) {
                    MetricaRow(
                        icono: "heart.fill",
                        valor: "\(Int(manager.frecuenciaCardiaca))",
                        unidad: "BPM",
                        color: .red
                    )

                    MetricaRow(
                        icono: "flame.fill",
                        valor: "\(Int(manager.caloriasQuemadas))",
                        unidad: "kcal",
                        color: .orange
                    )

                    MetricaRow(
                        icono: "figure.run",
                        valor: String(format: "%.2f", manager.distancia / 1000),
                        unidad: "km",
                        color: .green
                    )
                }

                // Controles
                HStack {
                    Button {
                        manager.pausarEntrenamiento()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                    .tint(.yellow)

                    Button {
                        Task { await manager.finalizarEntrenamiento() }
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    .tint(.red)
                }
            } else {
                Button("Iniciar Carrera") {
                    Task {
                        await manager.solicitarPermisos()
                        await manager.iniciarEntrenamiento(tipo: .running)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
    }
}

struct MetricaRow: View {
    let icono: String
    let valor: String
    let unidad: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icono)
                .foregroundStyle(color)
                .frame(width: 20)
            Text(valor)
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text(unidad)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
```

### WatchConnectivity — Sincronizacion con iPhone

```swift
import WatchConnectivity

// MARK: - Servicio de Conectividad Watch <-> iPhone
@Observable
class ConectividadWatch: NSObject, WCSessionDelegate {
    static let compartido = ConectividadWatch()
    var ultimoMensaje: String = ""
    var contextoRecibido: [String: Any] = [:]

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Enviar datos

    /// Envia contexto que se sincroniza en background
    /// Ideal para preferencias y configuracion
    func enviarContexto(_ datos: [String: Any]) {
        do {
            try WCSession.default.updateApplicationContext(datos)
        } catch {
            print("Error enviando contexto: \(error)")
        }
    }

    /// Envia mensaje interactivo (requiere que ambos esten activos)
    func enviarMensaje(_ datos: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("iPhone no alcanzable")
            return
        }

        WCSession.default.sendMessage(datos) { respuesta in
            print("Respuesta: \(respuesta)")
        } errorHandler: { error in
            print("Error: \(error)")
        }
    }

    /// Transfiere archivo al companion
    func enviarArchivo(_ url: URL, metadata: [String: Any]? = nil) {
        WCSession.default.transferFile(url, metadata: metadata)
    }

    // MARK: - Delegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith state: WCSessionActivationState,
        error: Error?
    ) {
        print("WCSession activada: \(state.rawValue)")
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext context: [String: Any]
    ) {
        Task { @MainActor in
            contextoRecibido = context
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        Task { @MainActor in
            ultimoMensaje = message["texto"] as? String ?? "Sin texto"
        }
    }

    // Requeridos solo en iOS, no en watchOS
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
```

#### Diagrama de Arquitectura watchOS

```
  ┌──────────────────────────────────────────────────────┐
  │              ARQUITECTURA watchOS                     │
  │                                                       │
  │  ┌─────────────────────────────────────────────────┐ │
  │  │            ESFERA DEL RELOJ                     │ │
  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐     │ │
  │  │  │ Circular │  │Rectangul │  │  Inline  │     │ │
  │  │  │  Gauge   │  │  Multi   │  │  Texto   │     │ │
  │  │  └──────────┘  └──────────┘  └──────────┘     │ │
  │  │           COMPLICATIONS (WidgetKit)             │ │
  │  └─────────────────────────────────────────────────┘ │
  │                        │                              │
  │                    Tap abre                           │
  │                        ▼                              │
  │  ┌─────────────────────────────────────────────────┐ │
  │  │              APP watchOS                        │ │
  │  │  ┌───────────┐  ┌───────────┐  ┌───────────┐  │ │
  │  │  │ Resumen   │  │ Actividad │  │  Config   │  │ │
  │  │  │  (Tab 1)  │  │  (Tab 2)  │  │  (Tab 3)  │  │ │
  │  │  └───────────┘  └───────────┘  └───────────┘  │ │
  │  │       TabView (vertical pages)                  │ │
  │  └─────────────────────────────────────────────────┘ │
  │            │                        │                 │
  │     HealthKit                WatchConnectivity        │
  │     Workouts                       │                  │
  │                                    ▼                  │
  │                           ┌──────────────┐           │
  │                           │   iPhone App │           │
  │                           │  Companion   │           │
  │                           └──────────────┘           │
  └──────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: App de Hidratacion para watchOS (Basico)

**Objetivo**: Crear una app independiente de watchOS para registrar consumo de agua.

**Requisitos**:
1. Vista principal con el total de agua consumida hoy (en ml)
2. Tres botones rapidos para agregar: 250ml, 350ml, 500ml
3. Digital Crown para ajuste fino (de 50 en 50ml)
4. Gauge circular que muestre progreso hacia meta diaria (2000ml)
5. Lista de registros del dia con hora y cantidad
6. Animacion de celebracion al alcanzar la meta

---

## Ejercicio 2: Complication con WidgetKit (Intermedio)

**Objetivo**: Crear complications para mostrar datos de la app de hidratacion.

**Requisitos**:
1. Complication circular: Gauge con porcentaje de meta completada
2. Complication rectangular: ml consumidos + meta + ultimo registro
3. Complication inline: "750/2000 ml" como texto
4. TimelineProvider que actualice cada 30 minutos
5. Placeholder y snapshot con datos de ejemplo realistas
6. La complication debe lanzar la app en la seccion correcta al tocarla

---

## Ejercicio 3: Workout Session con WatchConnectivity (Avanzado)

**Objetivo**: App de entrenamiento que sincroniza datos con iPhone.

**Requisitos**:
1. Selector de tipo de entrenamiento: carrera, caminata, ciclismo
2. Pantalla de entrenamiento activo con: frecuencia cardiaca, calorias, distancia, tiempo
3. Controles: pausar, reanudar, finalizar con confirmacion
4. Always-on display con datos simplificados durante el entrenamiento
5. WatchConnectivity para enviar resumen del entrenamiento a iPhone al finalizar
6. Usar `updateApplicationContext` para sincronizar preferencias de configuracion

---

## 5 Errores Comunes

### 1. Disenar como si fuera un iPhone pequeno
```swift
// MAL — demasiada informacion en pantalla
List {
    ForEach(0..<20) { i in
        HStack {
            Image(systemName: "star")
            VStack(alignment: .leading) {
                Text("Titulo del item \(i)")
                Text("Descripcion muy larga que no cabe")
                Text("Detalle adicional innecesario")
            }
        }
    }
}

// BIEN — informacion concisa, glanceable
List {
    ForEach(0..<5) { i in
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("Item \(i)")
                .lineLimit(1)
        }
    }
}
```

### 2. No usar .focusable() con Digital Crown
```swift
// MAL — digitalCrownRotation sin focusable no responde
VStack {
    Text("\(valor)")
}
.digitalCrownRotation($valor) // no funciona sin focusable

// BIEN — focusable habilita la interaccion con la corona
VStack {
    Text("\(valor)")
}
.focusable()
.digitalCrownRotation($valor, from: 0, through: 100, by: 1)
```

### 3. Ignorar los limites de background execution
```swift
// MAL — asumir que la app sigue activa en background
Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
    actualizarDatos() // no se ejecuta en background
}

// BIEN — usar background refresh tasks
func schedule() {
    WKApplication.shared().scheduleBackgroundRefresh(
        withPreferredDate: Date().addingTimeInterval(15 * 60),
        userInfo: nil
    ) { error in
        if let error { print("Error: \(error)") }
    }
}
```

### 4. No manejar WCSession.isReachable
```swift
// MAL — enviar sin verificar conectividad
func enviar() {
    WCSession.default.sendMessage(["dato": "valor"]) { _ in }
    // falla silenciosamente si iPhone no esta disponible
}

// BIEN — verificar y usar el metodo apropiado
func enviar() {
    if WCSession.default.isReachable {
        // Mensaje interactivo — inmediato
        WCSession.default.sendMessage(["dato": "valor"]) { _ in }
    } else {
        // Application context — se entrega cuando sea posible
        try? WCSession.default.updateApplicationContext(["dato": "valor"])
    }
}
```

### 5. Complications que no se actualizan
```swift
// MAL — timeline sin politica de actualizacion
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let entry = MiEntry(date: .now, valor: 42)
    let timeline = Timeline(entries: [entry], policy: .never) // nunca actualiza!
    completion(timeline)
}

// BIEN — actualizar periodicamente
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let ahora = Date.now
    let entry = MiEntry(date: ahora, valor: 42)
    let proximaActualizacion = Calendar.current.date(byAdding: .minute, value: 15, to: ahora)!
    let timeline = Timeline(entries: [entry], policy: .after(proximaActualizacion))
    completion(timeline)
}
```

---

## Checklist

- [ ] Entender la diferencia entre apps independientes y companion
- [ ] Crear una app watchOS con SwiftUI y NavigationStack
- [ ] Usar TabView con `.verticalPage` para navegacion principal
- [ ] Implementar Digital Crown con `.digitalCrownRotation` y `.focusable()`
- [ ] Crear Complications con WidgetKit: circular, rectangular, inline
- [ ] Implementar TimelineProvider con politica de actualizacion apropiada
- [ ] Usar HealthKit para sesiones de entrenamiento
- [ ] Implementar WatchConnectivity para sincronizacion con iPhone
- [ ] Disenar para interacciones de 5-10 segundos (glanceable)
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

watchOS complementa el Proyecto Integrador como extension natural:
- **Complications** para mostrar datos clave del proyecto en la esfera (progreso, proxima tarea)
- **Digital Crown** para input rapido (calificaciones, cantidades, sliders)
- **WatchConnectivity** para sincronizar datos entre iPhone y Watch en tiempo real
- **HealthKit** si el proyecto involucra salud/fitness — datos directos del sensor
- **Notificaciones actionables** en la muneca para respuestas rapidas sin sacar el iPhone
- **Always-on display** para sesiones activas (entrenamientos, timers, navegacion)

---

*Leccion 31 | watchOS — Apps para Apple Watch | Semanas 39-40 | Modulo 08: Plataformas*
*Siguiente: Leccion 32 — visionOS: Apps Espaciales*
