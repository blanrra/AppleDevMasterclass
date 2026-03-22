# Leccion 29: Widgets y Live Activities

**Modulo 07: Integracion con el Sistema** | Semana 37

---

## TL;DR — Resumen en 2 minutos

- **WidgetKit**: Framework para mostrar informacion de tu app en la pantalla de inicio — son vistas SwiftUI read-only con timeline
- **TimelineProvider**: Genera snapshots y entradas futuras para que el sistema muestre contenido sin abrir la app
- **Widget Families**: Tamanos `.systemSmall`, `.systemMedium`, `.systemLarge` y `.accessoryCircular/.rectangular/.inline` para Lock Screen
- **Live Activities**: Muestran estado en tiempo real en la pantalla de bloqueo y Dynamic Island usando ActivityKit
- **ActivityAttributes**: Definen datos estaticos (nombre del pedido) y dinamicos (estado actual) de una Live Activity

---

## Cupertino MCP

```bash
cupertino search "WidgetKit"
cupertino search "TimelineProvider"
cupertino search "Widget protocol"
cupertino search "WidgetFamily"
cupertino search "ActivityKit"
cupertino search "ActivityAttributes"
cupertino search "DynamicIsland"
cupertino search "Live Activities"
cupertino search --source samples "WidgetKit"
cupertino search --source samples "ActivityKit"
cupertino search --source updates "WidgetKit"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC23 | [Bring widgets to new places](https://developer.apple.com/videos/play/wwdc2023/10027/) | **Esencial** — Widgets interactivos |
| WWDC22 | [Complications and widgets: Reloaded](https://developer.apple.com/videos/play/wwdc2022/10050/) | Lock Screen widgets |
| WWDC23 | [Update Live Activities with push notifications](https://developer.apple.com/videos/play/wwdc2023/10185/) | Push para Live Activities |
| WWDC22 | [Meet ActivityKit](https://developer.apple.com/videos/play/wwdc2022/10184/) | Introduccion a Live Activities |
| WWDC24 | [Extend your app's controls across the system](https://developer.apple.com/videos/play/wwdc2024/10157/) | Control Center widgets |
| :es: | [Julio Cesar Fernandez — Widgets](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Widgets?

Los widgets son la forma mas visible de tu app fuera de ella misma. Un usuario puede ver tu contenido **sin abrir la app** — en la pantalla de inicio, en la Lock Screen, en StandBy, en el Apple Watch. Es presencia constante.

A diferencia de una app normal donde tu controlas cuando se renderiza la UI, en un widget **el sistema decide cuando**. Tu solo provees un timeline de contenido futuro, y el sistema renderiza cuando lo necesita. Esto significa que no hay animaciones imperativas, no hay estado en tiempo real (para eso estan Live Activities), y no hay interaccion compleja — son vistas SwiftUI estaticas con datos pre-calculados.

```
  ┌──────────────────────────────────────────────────────────┐
  │              ARQUITECTURA DE UN WIDGET                   │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   Widget Extension (proceso separado)                    │
  │   ┌──────────────────────────────────────────┐           │
  │   │                                          │           │
  │   │   TimelineProvider                       │           │
  │   │   ┌────────────┐   ┌──────────────┐      │           │
  │   │   │ snapshot() │   │ timeline()   │      │           │
  │   │   │ (preview)  │   │ (entradas    │      │           │
  │   │   └────────────┘   │  futuras)    │      │           │
  │   │                    └──────┬───────┘      │           │
  │   │                          │               │           │
  │   │   ┌──────────────────────▼───────────┐   │           │
  │   │   │     TimelineEntry (datos)        │   │           │
  │   │   │     → fecha + modelo             │   │           │
  │   │   └──────────────────────┬───────────┘   │           │
  │   │                          │               │           │
  │   │   ┌──────────────────────▼───────────┐   │           │
  │   │   │     EntryView (SwiftUI)          │   │           │
  │   │   │     → renderizado visual         │   │           │
  │   │   └──────────────────────────────────┘   │           │
  │   └──────────────────────────────────────────┘           │
  │                                                          │
  │   Tamanos: small | medium | large | Lock Screen          │
  └──────────────────────────────────────────────────────────┘
```

### Configurar el Widget Extension

Un widget vive en un **extension target** separado de tu app principal. En Xcode: File > New > Target > Widget Extension.

```swift
import WidgetKit
import SwiftUI

// MARK: - 1. Modelo de datos (TimelineEntry)

struct TareaWidgetEntry: TimelineEntry {
    let date: Date
    let tareasCompletadas: Int
    let tareasTotales: Int
    let siguienteTarea: String
    let progreso: Double
}

// MARK: - 2. Provider (genera el contenido)

struct TareaWidgetProvider: TimelineProvider {

    /// Placeholder — se muestra mientras carga (con datos redactados)
    func placeholder(in context: Context) -> TareaWidgetEntry {
        TareaWidgetEntry(
            date: .now,
            tareasCompletadas: 3,
            tareasTotales: 10,
            siguienteTarea: "Tarea de ejemplo",
            progreso: 0.3
        )
    }

    /// Snapshot — para previsualizacion en la galeria de widgets
    func getSnapshot(in context: Context, completion: @escaping (TareaWidgetEntry) -> Void) {
        let entry = TareaWidgetEntry(
            date: .now,
            tareasCompletadas: 5,
            tareasTotales: 8,
            siguienteTarea: "Revisar pull request",
            progreso: 0.625
        )
        completion(entry)
    }

    /// Timeline — entradas futuras que el sistema renderizara
    func getTimeline(in context: Context, completion: @escaping (Timeline<TareaWidgetEntry>) -> Void) {
        // Leer datos reales (de App Group, SwiftData, UserDefaults compartido)
        let tareasCompletadas = 5
        let tareasTotales = 8

        let entry = TareaWidgetEntry(
            date: .now,
            tareasCompletadas: tareasCompletadas,
            tareasTotales: tareasTotales,
            siguienteTarea: "Implementar login",
            progreso: Double(tareasCompletadas) / Double(tareasTotales)
        )

        // Refrescar en 30 minutos
        let siguienteActualizacion = Calendar.current.date(
            byAdding: .minute, value: 30, to: .now
        )!

        let timeline = Timeline(
            entries: [entry],
            policy: .after(siguienteActualizacion)
        )

        completion(timeline)
    }
}
```

### Vista del Widget

```swift
import WidgetKit
import SwiftUI

// MARK: - 3. Vista del widget

struct TareaWidgetView: View {
    let entry: TareaWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            vistaCompacta
        case .systemMedium:
            vistaMedia
        case .systemLarge:
            vistaGrande
        default:
            vistaCompacta
        }
    }

    // MARK: - Small

    var vistaCompacta: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("\(entry.tareasCompletadas)/\(entry.tareasTotales)")
                    .font(.title2.bold())
            }

            ProgressView(value: entry.progreso)
                .tint(.blue)

            Text(entry.siguienteTarea)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium

    var vistaMedia: some View {
        HStack(spacing: 16) {
            // Lado izquierdo — progreso circular
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: entry.progreso)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(entry.progreso * 100))%")
                    .font(.title3.bold())
            }
            .frame(width: 80, height: 80)

            // Lado derecho — detalles
            VStack(alignment: .leading, spacing: 4) {
                Text("Progreso de Hoy")
                    .font(.headline)
                Text("\(entry.tareasCompletadas) de \(entry.tareasTotales) completadas")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                Label(entry.siguienteTarea, systemImage: "arrow.right.circle")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Large

    var vistaGrande: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mis Tareas")
                .font(.title2.bold())

            HStack {
                Label("\(entry.tareasCompletadas) completadas", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Spacer()
                Label("\(entry.tareasTotales - entry.tareasCompletadas) pendientes",
                      systemImage: "circle")
                    .foregroundStyle(.orange)
            }
            .font(.subheadline)

            ProgressView(value: entry.progreso)
                .tint(.blue)

            Divider()

            Text("Siguiente:")
                .font(.headline)
            Text(entry.siguienteTarea)
                .font(.body)

            Spacer()

            Text("Actualizado: \(entry.date.formatted(date: .omitted, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
```

### Definicion del Widget

```swift
import WidgetKit
import SwiftUI

// MARK: - 4. Definicion del Widget

struct TareaWidget: Widget {
    /// Identificador unico — no cambiar despues de publicar
    let kind: String = "TareaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TareaWidgetProvider()
        ) { entry in
            TareaWidgetView(entry: entry)
        }
        .configurationDisplayName("Mis Tareas")
        .description("Muestra tu progreso de tareas del dia.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
        .contentMarginsDisabled()  // Control total de margenes
    }
}

// MARK: - 5. Bundle si tienes multiples widgets

@main
struct MisWidgets: WidgetBundle {
    var body: some Widget {
        TareaWidget()
        // ProgresoWidget()
        // ResumenWidget()
    }
}

// MARK: - 6. Preview

#Preview("Small", as: .systemSmall) {
    TareaWidget()
} timeline: {
    TareaWidgetEntry(date: .now, tareasCompletadas: 3, tareasTotales: 10,
                     siguienteTarea: "Revisar PR", progreso: 0.3)
    TareaWidgetEntry(date: .now, tareasCompletadas: 7, tareasTotales: 10,
                     siguienteTarea: "Deploy", progreso: 0.7)
}
```

### Widgets Interactivos con AppIntents (iOS 17+)

Desde iOS 17, los widgets pueden tener **botones y toggles** que ejecutan `AppIntent`.

```swift
import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Intent para marcar tarea como completada

struct CompletarTareaIntent: AppIntent {
    static var title: LocalizedStringResource = "Completar tarea"

    @Parameter(title: "ID de la tarea")
    var tareaId: String

    func perform() async throws -> some IntentResult {
        // Marcar como completada en la base de datos compartida
        // Recargar el widget
        WidgetCenter.shared.reloadTimelines(ofKind: "TareaWidget")
        return .result()
    }
}

// MARK: - Vista interactiva del widget

struct TareaInteractivaWidgetView: View {
    let entry: TareaWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Siguiente tarea:")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(entry.siguienteTarea)
                .font(.headline)

            // Boton interactivo — ejecuta un AppIntent
            Button(intent: CompletarTareaIntent()) {
                Label("Completar", systemImage: "checkmark.circle")
            }
            .tint(.green)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
```

### Lock Screen Widgets (Accessory Family)

```swift
import WidgetKit
import SwiftUI

// MARK: - Widget para Lock Screen

struct TareaLockScreenWidget: Widget {
    let kind = "TareaLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TareaWidgetProvider()) { entry in
            TareaLockScreenView(entry: entry)
        }
        .configurationDisplayName("Tareas")
        .description("Progreso rapido en Lock Screen")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct TareaLockScreenView: View {
    let entry: TareaWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            // Circulo con progreso
            Gauge(value: entry.progreso) {
                Image(systemName: "checkmark")
            }
            .gaugeStyle(.accessoryCircularCapacity)

        case .accessoryRectangular:
            // Rectangulo con detalles
            VStack(alignment: .leading) {
                Text("\(entry.tareasCompletadas)/\(entry.tareasTotales) tareas")
                    .font(.headline)
                    .widgetAccentable()
                Text(entry.siguienteTarea)
                    .font(.caption)
                ProgressView(value: entry.progreso)
            }

        case .accessoryInline:
            // Linea simple de texto
            Text("\(entry.tareasCompletadas)/\(entry.tareasTotales) tareas completadas")

        default:
            Text("--")
        }
    }
}
```

### Compartir Datos entre App y Widget

Los widgets corren en un proceso separado. Para compartir datos, usa **App Groups**.

```swift
import Foundation

// MARK: - Compartir datos via App Group

/// Usar el mismo App Group ID en el target de la app y del widget
/// Configurar en Signing & Capabilities > App Groups
let appGroupID = "group.com.tuapp.datos"

// Escribir desde la app principal
func guardarDatosParaWidget(completadas: Int, total: Int, siguiente: String) {
    let defaults = UserDefaults(suiteName: appGroupID)
    defaults?.set(completadas, forKey: "tareasCompletadas")
    defaults?.set(total, forKey: "tareasTotales")
    defaults?.set(siguiente, forKey: "siguienteTarea")

    // Notificar al widget para que recargue
    WidgetCenter.shared.reloadTimelines(ofKind: "TareaWidget")
}

// Leer desde el widget
func leerDatosDeApp() -> (completadas: Int, total: Int, siguiente: String) {
    let defaults = UserDefaults(suiteName: appGroupID)
    return (
        completadas: defaults?.integer(forKey: "tareasCompletadas") ?? 0,
        total: defaults?.integer(forKey: "tareasTotales") ?? 0,
        siguiente: defaults?.string(forKey: "siguienteTarea") ?? "Sin tareas"
    )
}
```

### Live Activities con ActivityKit

Las Live Activities muestran informacion **en tiempo real** en la Lock Screen y Dynamic Island. Ideales para: entregas, deportes en vivo, temporizadores, viajes en curso.

```swift
import ActivityKit
import SwiftUI

// MARK: - 1. Definir los atributos de la actividad

struct PedidoAttributes: ActivityAttributes {

    /// Datos estaticos — no cambian durante la actividad
    var numeroPedido: String
    var restaurante: String

    /// Datos dinamicos — se actualizan en tiempo real
    struct ContentState: Codable, Hashable {
        var estado: EstadoPedido
        var tiempoEstimado: Int  // minutos
        var mensajeRepartidor: String?
    }
}

enum EstadoPedido: String, Codable {
    case confirmado = "Confirmado"
    case preparando = "Preparando"
    case enCamino = "En camino"
    case entregado = "Entregado"

    var icono: String {
        switch self {
        case .confirmado: return "checkmark.circle"
        case .preparando: return "flame"
        case .enCamino: return "bicycle"
        case .entregado: return "bag.fill"
        }
    }

    var color: Color {
        switch self {
        case .confirmado: return .blue
        case .preparando: return .orange
        case .enCamino: return .green
        case .entregado: return .purple
        }
    }
}
```

### Vista de la Live Activity

```swift
import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - 2. Widget para Live Activity

struct PedidoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PedidoAttributes.self) { context in

            // MARK: Lock Screen / Banner
            lockScreenView(context: context)

        } dynamicIsland: { context in

            // MARK: Dynamic Island
            DynamicIsland {
                // Expanded — cuando el usuario toca la isla
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.estado.icono)
                        .font(.title2)
                        .foregroundStyle(context.state.estado.color)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.tiempoEstimado) min")
                        .font(.title2.bold())
                        .foregroundStyle(context.state.estado.color)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.estado.rawValue)
                        .font(.headline)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    // Barra de progreso del pedido
                    HStack(spacing: 4) {
                        ForEach(EstadoPedido.allCases, id: \.self) { paso in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(paso <= context.state.estado ? context.state.estado.color : .gray.opacity(0.3))
                                .frame(height: 6)
                        }
                    }
                    .padding(.top, 8)

                    if let mensaje = context.state.mensajeRepartidor {
                        Text(mensaje)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                // Compact — lado izquierdo de la isla
                Image(systemName: context.state.estado.icono)
                    .foregroundStyle(context.state.estado.color)
            } compactTrailing: {
                // Compact — lado derecho de la isla
                Text("\(context.state.tiempoEstimado)m")
                    .font(.caption.bold())
            } minimal: {
                // Minimal — cuando hay multiples actividades
                Image(systemName: context.state.estado.icono)
                    .foregroundStyle(context.state.estado.color)
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    func lockScreenView(context: ActivityViewContext<PedidoAttributes>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: context.state.estado.icono)
                .font(.largeTitle)
                .foregroundStyle(context.state.estado.color)

            VStack(alignment: .leading, spacing: 4) {
                Text("Pedido #\(context.attributes.numeroPedido)")
                    .font(.headline)
                Text(context.state.estado.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(context.state.estado.color)
                Text("\(context.attributes.restaurante) — \(context.state.tiempoEstimado) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}

// Necesario para usar allCases y comparacion
extension EstadoPedido: CaseIterable, Comparable {
    static func < (lhs: EstadoPedido, rhs: EstadoPedido) -> Bool {
        let orden: [EstadoPedido] = [.confirmado, .preparando, .enCamino, .entregado]
        return (orden.firstIndex(of: lhs) ?? 0) < (orden.firstIndex(of: rhs) ?? 0)
    }
}
```

### Iniciar, Actualizar y Finalizar Live Activities

```swift
import ActivityKit

// MARK: - 3. Gestionar el ciclo de vida de la actividad

actor GestorPedido {
    private var actividad: Activity<PedidoAttributes>?

    /// Iniciar una Live Activity
    func iniciarSeguimiento(pedido: String, restaurante: String) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities no estan habilitadas")
            return
        }

        let atributos = PedidoAttributes(
            numeroPedido: pedido,
            restaurante: restaurante
        )

        let estadoInicial = PedidoAttributes.ContentState(
            estado: .confirmado,
            tiempoEstimado: 45,
            mensajeRepartidor: nil
        )

        actividad = try Activity.request(
            attributes: atributos,
            content: .init(state: estadoInicial, staleDate: nil),
            pushType: nil  // Usar .token para actualizaciones push
        )

        print("Live Activity iniciada: \(actividad?.id ?? "?")")
    }

    /// Actualizar el estado
    func actualizar(estado: EstadoPedido, tiempoEstimado: Int, mensaje: String? = nil) async {
        let nuevoEstado = PedidoAttributes.ContentState(
            estado: estado,
            tiempoEstimado: tiempoEstimado,
            mensajeRepartidor: mensaje
        )

        await actividad?.update(
            ActivityContent(state: nuevoEstado, staleDate: nil)
        )
    }

    /// Finalizar la actividad
    func finalizar() async {
        let estadoFinal = PedidoAttributes.ContentState(
            estado: .entregado,
            tiempoEstimado: 0,
            mensajeRepartidor: "Entregado. ¡Buen provecho!"
        )

        await actividad?.end(
            ActivityContent(state: estadoFinal, staleDate: nil),
            dismissalPolicy: .after(.now + 60 * 5)  // Permanece 5 min
        )
    }
}

// MARK: - Uso

let gestor = GestorPedido()

Task {
    try gestor.iniciarSeguimiento(pedido: "A-1234", restaurante: "Pizzeria Roma")

    // Simular actualizaciones
    try await Task.sleep(for: .seconds(10))
    await gestor.actualizar(estado: .preparando, tiempoEstimado: 30)

    try await Task.sleep(for: .seconds(10))
    await gestor.actualizar(estado: .enCamino, tiempoEstimado: 15,
                            mensaje: "Carlos esta en camino con tu pedido")

    try await Task.sleep(for: .seconds(10))
    await gestor.finalizar()
}
```

---

## Ejercicio 1: Widget de Clima (Basico)

**Objetivo**: Crear un widget con tres tamanos que muestre informacion del clima.

**Requisitos**:
1. `ClimaEntry` con: fecha, temperatura, condicion (soleado/nublado/lluvia), ciudad
2. `TimelineProvider` con datos simulados y actualizacion cada hora
3. Vista para `.systemSmall` (solo temperatura e icono), `.systemMedium` (detalles) y `.systemLarge` (pronostico)
4. Preview con datos de ejemplo

---

## Ejercicio 2: Widget Interactivo con AppIntents (Intermedio)

**Objetivo**: Crear un widget con botones que ejecutan acciones.

**Requisitos**:
1. Widget de contador con valor almacenado en App Group (`UserDefaults(suiteName:)`)
2. Dos botones: incrementar y decrementar, cada uno con su `AppIntent`
3. Los intents deben llamar `WidgetCenter.shared.reloadTimelines` al ejecutarse
4. Lock Screen widget con `.accessoryCircular` mostrando el valor actual
5. `WidgetBundle` que agrupe el widget de Home Screen y Lock Screen

---

## Ejercicio 3: Live Activity de Temporizador (Avanzado)

**Objetivo**: Implementar una Live Activity que muestre un temporizador en tiempo real.

**Requisitos**:
1. `TemporizadorAttributes` con nombre de la actividad (estatico) y segundos restantes, estado (dinamico)
2. Lock Screen view con barra de progreso y tiempo restante
3. Dynamic Island con todas las regiones: expanded, compact, minimal
4. Boton para pausar/reanudar usando `AppIntent` en la vista expandida
5. Logica completa: iniciar, actualizar cada segundo, pausar y finalizar
6. El temporizador debe usar `Text(.now + TimeInterval, style: .timer)` para countdown nativo

---

## 5 Errores Comunes

### 1. Intentar usar estado mutable (@State, @Observable) en widgets

```swift
// MAL — los widgets no mantienen estado en memoria
struct MiWidgetView: View {
    @State private var contador = 0  // Nunca se incrementara

    var body: some View {
        Button("Tap: \(contador)") {
            contador += 1  // No funciona — el widget se renderiza una vez
        }
    }
}

// BIEN — todo el estado viene del TimelineEntry
struct MiWidgetView: View {
    let entry: MiEntry  // Datos pre-calculados por el provider

    var body: some View {
        // Botones interactivos usan AppIntent, no @State
        Button(intent: IncrementarIntent()) {
            Text("Incrementar (\(entry.valor))")
        }
    }
}
```

### 2. No configurar App Group para compartir datos

```swift
// MAL — UserDefaults standard no es accesible desde el widget
UserDefaults.standard.set(42, forKey: "valor")  // Solo visible en la app

// BIEN — usar App Group compartido
let grupoCompartido = UserDefaults(suiteName: "group.com.miapp.datos")
grupoCompartido?.set(42, forKey: "valor")
// Accesible desde app Y widget
```

### 3. Pedir reloads del widget con demasiada frecuencia

```swift
// MAL — recargar cada segundo agota el budget del sistema
Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    WidgetCenter.shared.reloadTimelines(ofKind: "MiWidget")
    // El sistema eventualmente ignorara tus reloads
}

// BIEN — recargar solo cuando los datos cambien realmente
func guardarTarea(_ tarea: Tarea) {
    // Guardar datos
    baseDeDatos.guardar(tarea)
    // Recargar solo despues de un cambio real
    WidgetCenter.shared.reloadTimelines(ofKind: "TareaWidget")
}
```

### 4. Olvidar containerBackground en iOS 17+

```swift
// MAL — el widget se ve sin fondo en iOS 17+
struct MiWidgetView: View {
    var body: some View {
        Text("Hola")
            .background(.blue)  // No funciona como fondo del widget
    }
}

// BIEN — usar containerBackground
struct MiWidgetView: View {
    var body: some View {
        Text("Hola")
            .containerBackground(.blue.gradient, for: .widget)
    }
}
```

### 5. No manejar el caso de Live Activities deshabilitadas

```swift
// MAL — asumir que Live Activities siempre estan disponibles
func iniciarActividad() throws {
    let actividad = try Activity.request(attributes: attrs, content: content)
    // Crashea si el usuario las deshabilito
}

// BIEN — verificar antes de iniciar
func iniciarActividad() throws {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        print("El usuario deshabilito Live Activities en Configuracion")
        // Mostrar alerta sugiriendo activarlas
        return
    }

    let actividad = try Activity.request(
        attributes: attrs,
        content: .init(state: estadoInicial, staleDate: nil)
    )
}
```

---

## Checklist

- [ ] Crear un Widget Extension target en Xcode
- [ ] Implementar TimelineProvider con placeholder, snapshot y timeline
- [ ] Disenar vistas para .systemSmall, .systemMedium y .systemLarge
- [ ] Usar containerBackground para fondos del widget
- [ ] Configurar App Groups para compartir datos entre app y widget
- [ ] Recargar widgets con WidgetCenter.shared.reloadTimelines
- [ ] Agregar widgets interactivos con Button(intent:) y AppIntent
- [ ] Crear Lock Screen widgets con accessory families
- [ ] Definir ActivityAttributes con datos estaticos y ContentState
- [ ] Implementar Dynamic Island con todas las regiones
- [ ] Gestionar ciclo de vida de Live Activity (iniciar, actualizar, finalizar)
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Widgets y Live Activities seran features diferenciadores de tu app:
- **Widget de progreso**: Mostrar resumen del estado actual de tu app en la pantalla de inicio
- **Lock Screen**: Informacion rapida sin desbloquear — ideal para datos que se consultan frecuentemente
- **Widgets interactivos**: Acciones rapidas sin abrir la app (marcar completado, agregar elemento)
- **Live Activities**: Si tu app tiene procesos en tiempo real (descarga, temporizador, seguimiento)
- **Dynamic Island**: Presencia constante mientras un proceso esta activo
- **App Groups + SwiftData**: Compartir la misma base de datos entre app y widget

---

*Leccion 29 | Widgets y Live Activities | Semana 37 | Modulo 07: Integracion con el Sistema*
*Siguiente: Leccion 30 — Notificaciones*
