# Leccion 28: App Intents y Siri

**Modulo 07: Integracion con el Sistema** | Semanas 35-36

---

## TL;DR — Resumen en 2 minutos

- **AppIntent**: Protocolo que expone acciones de tu app al sistema — Siri, Spotlight, Shortcuts y Action Button
- **AppShortcutsProvider**: Registra frases para que Siri ejecute tus intents por voz sin configuracion del usuario
- **@Parameter + AppEntity**: Permiten intents con parametros dinamicos que el sistema resuelve automaticamente
- **EntityQuery**: Busca y filtra entidades para que Siri pregunte "cual quieres?" de forma inteligente
- **perform()**: El metodo donde vive la logica — devuelve un resultado que Siri puede mostrar o leer en voz alta

---

## Cupertino MCP

```bash
cupertino search "AppIntents"
cupertino search "AppIntent protocol"
cupertino search "AppShortcutsProvider"
cupertino search "AppEntity"
cupertino search "EntityQuery"
cupertino search "IntentParameter"
cupertino search --source samples "AppIntents"
cupertino search --source updates "App Intents"
cupertino search "SiriTipView"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC22 | [Dive into App Intents](https://developer.apple.com/videos/play/wwdc2022/10032/) | **Esencial** — Introduccion al framework |
| WWDC23 | [Explore enhancements to App Intents](https://developer.apple.com/videos/play/wwdc2023/10103/) | Mejoras y patrones avanzados |
| WWDC24 | [Bring your app's core features to users with App Intents](https://developer.apple.com/videos/play/wwdc2024/10210/) | Integracion profunda |
| WWDC23 | [Design Shortcuts for Spotlight](https://developer.apple.com/videos/play/wwdc2023/10193/) | Diseno de frases |
| WWDC24 | [Design App Intents for system experiences](https://developer.apple.com/videos/play/wwdc2024/10211/) | UX del sistema |
| :es: | [Julio Cesar Fernandez — App Intents](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que App Intents?

Antes de App Intents existian SiriKit Intents — un framework basado en Objective-C con dominios limitados (mensajes, pagos, workout). Solo podias implementar intents predefinidos por Apple. Si tu app hacia algo fuera de esos dominios, Siri no podia ayudar.

App Intents cambio todo: ahora **cualquier accion** de tu app puede exponerse al sistema. No es solo Siri — es Spotlight, Shortcuts, Action Button, widgets interactivos y el futuro de la integracion con Apple Intelligence. Es Swift-native, type-safe y declarativo.

```
  ┌──────────────────────────────────────────────────────────┐
  │             ECOSISTEMA DE APP INTENTS                    │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   Tu App                       Sistema                   │
  │   ┌──────────────┐            ┌──────────────┐           │
  │   │  AppIntent   │───────────▶│  Siri        │           │
  │   │  perform()   │            │  Spotlight    │           │
  │   │  @Parameter  │            │  Shortcuts    │           │
  │   └──────┬───────┘            │  Action Btn   │           │
  │          │                    │  Widgets      │           │
  │   ┌──────▼───────┐            │  Focus Filters│           │
  │   │  AppEntity   │◀──────────│  Apple Intel. │           │
  │   │  EntityQuery │  consulta  └──────────────┘           │
  │   └──────────────┘                                       │
  └──────────────────────────────────────────────────────────┘
```

### AppIntent Basico — Tu Primer Intent

Un `AppIntent` es simplemente un struct que conforma el protocolo `AppIntent`. Solo necesita un titulo y un metodo `perform()`.

```swift
import AppIntents

// MARK: - Intent basico sin parametros

struct AbrirPantallaFavoritosIntent: AppIntent {

    /// Titulo que el sistema muestra en Shortcuts y Spotlight
    static var title: LocalizedStringResource = "Abrir Favoritos"

    /// Descripcion opcional para el usuario
    static var description: IntentDescription = IntentDescription(
        "Abre la pantalla de favoritos en la app",
        categoryName: "Navegacion"
    )

    /// Indica que este intent abre la app
    static var openAppWhenRun: Bool = true

    /// La logica del intent
    func perform() async throws -> some IntentResult {
        // Aqui navegarias a la pantalla de favoritos
        // usando un NavigationManager o similar
        return .result()
    }
}
```

### Intent con Valor de Retorno

Siri puede leer el resultado en voz alta o mostrarlo visualmente. Para esto, `perform()` devuelve un valor con `.result(value:)` y un `IntentDialog`.

```swift
import AppIntents

// MARK: - Intent que devuelve informacion

struct ContarTareasCompletadasIntent: AppIntent {

    static var title: LocalizedStringResource = "Contar tareas completadas"

    static var description: IntentDescription = IntentDescription(
        "Muestra cuantas tareas has completado hoy"
    )

    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        // Simulacion — en produccion leerias de SwiftData
        let completadas = 7
        let total = 12

        return .result(
            value: completadas,
            dialog: "Has completado \(completadas) de \(total) tareas hoy. ¡Buen trabajo!"
        )
    }
}
```

### @Parameter — Intents con Parametros

Los parametros permiten que el usuario (o Siri) especifique valores al ejecutar el intent. El sistema genera UI automaticamente para que el usuario elija.

```swift
import AppIntents

// MARK: - Intent con parametros simples

struct CrearTareaRapidaIntent: AppIntent {

    static var title: LocalizedStringResource = "Crear tarea rapida"

    static var description: IntentDescription = IntentDescription(
        "Crea una nueva tarea con titulo y prioridad"
    )

    /// Parametro obligatorio — Siri preguntara si no se proporciona
    @Parameter(title: "Titulo de la tarea")
    var titulo: String

    /// Parametro con enum — Siri muestra las opciones
    @Parameter(title: "Prioridad", default: .media)
    var prioridad: PrioridadTarea

    /// Parametro opcional
    @Parameter(title: "Fecha limite")
    var fechaLimite: Date?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Crear la tarea con los parametros recibidos
        print("Creando: \(titulo) con prioridad \(prioridad)")

        var mensaje = "Tarea '\(titulo)' creada con prioridad \(prioridad.rawValue)"
        if let fecha = fechaLimite {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            mensaje += " para el \(formatter.string(from: fecha))"
        }

        return .result(dialog: "\(mensaje)")
    }
}

// MARK: - Enum compatible con App Intents

enum PrioridadTarea: String, AppEnum {
    case baja, media, alta, urgente

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Prioridad"

    static var caseDisplayRepresentations: [PrioridadTarea: DisplayRepresentation] = [
        .baja: "Baja",
        .media: "Media",
        .alta: "Alta",
        .urgente: "Urgente"
    ]
}
```

### AppEntity — Entidades Dinamicas

Cuando los parametros no son tipos simples (String, Int, Date), necesitas `AppEntity`. Es la forma de exponer tus modelos de datos al sistema para que Siri pueda preguntar "cual proyecto?" y mostrar una lista.

```swift
import AppIntents
import Foundation

// MARK: - Entidad que representa un proyecto

struct ProyectoEntity: AppEntity {

    /// Identificador unico
    var id: UUID
    var nombre: String
    var color: String
    var tareasActivas: Int

    /// Como se muestra en la UI del sistema
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(nombre)",
            subtitle: "\(tareasActivas) tareas activas",
            image: .init(systemName: "folder.fill")
        )
    }

    /// Metadata del tipo
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Proyecto"

    /// Query por defecto para buscar proyectos
    static var defaultQuery = ProyectoQuery()
}

// MARK: - Query para buscar proyectos

struct ProyectoQuery: EntityQuery {

    /// Buscar entidades por ID
    func entities(for identifiers: [UUID]) async throws -> [ProyectoEntity] {
        // En produccion: buscar en SwiftData
        return proyectosDeEjemplo.filter { identifiers.contains($0.id) }
    }

    /// Sugerir entidades al usuario (aparecen como opciones)
    func suggestedEntities() async throws -> [ProyectoEntity] {
        return proyectosDeEjemplo
    }
}

// Datos de ejemplo
let proyectosDeEjemplo = [
    ProyectoEntity(id: UUID(), nombre: "App de Fitness", color: "azul", tareasActivas: 5),
    ProyectoEntity(id: UUID(), nombre: "Sitio Web", color: "verde", tareasActivas: 3),
    ProyectoEntity(id: UUID(), nombre: "API Backend", color: "rojo", tareasActivas: 8)
]

// MARK: - Intent que usa la entidad

struct AgregarTareaAProyectoIntent: AppIntent {

    static var title: LocalizedStringResource = "Agregar tarea a proyecto"

    @Parameter(title: "Proyecto")
    var proyecto: ProyectoEntity

    @Parameter(title: "Nombre de la tarea")
    var nombreTarea: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Agregar la tarea al proyecto seleccionado
        return .result(
            dialog: "Tarea '\(nombreTarea)' agregada a \(proyecto.nombre)"
        )
    }
}
```

### EntityQuery con Busqueda — EntityStringQuery

Para que Siri permita buscar por texto (no solo elegir de una lista), implementa `EntityStringQuery`.

```swift
import AppIntents

// MARK: - Query con busqueda por texto

struct ProyectoBusquedaQuery: EntityStringQuery {

    /// Buscar por IDs
    func entities(for identifiers: [UUID]) async throws -> [ProyectoEntity] {
        return proyectosDeEjemplo.filter { identifiers.contains($0.id) }
    }

    /// Buscar por texto — Siri usa esto cuando el usuario dice un nombre
    func entities(matching query: String) async throws -> [ProyectoEntity] {
        return proyectosDeEjemplo.filter {
            $0.nombre.localizedCaseInsensitiveContains(query)
        }
    }

    /// Sugerencias iniciales
    func suggestedEntities() async throws -> [ProyectoEntity] {
        return Array(proyectosDeEjemplo.prefix(5))
    }
}
```

### AppShortcutsProvider — Siri sin Configuracion

El paso mas importante: `AppShortcutsProvider` registra frases que el usuario puede decir a Siri **sin necesidad de configurar nada**. Estas frases aparecen automaticamente.

```swift
import AppIntents

// MARK: - Proveedor de shortcuts para Siri

struct MisShortcuts: AppShortcutsProvider {

    /// Shortcuts que se registran automaticamente con Siri
    static var appShortcuts: [AppShortcut] {

        AppShortcut(
            intent: ContarTareasCompletadasIntent(),
            phrases: [
                "Cuantas tareas complete en \(.applicationName)",
                "Mis tareas de hoy en \(.applicationName)",
                "Progreso de tareas en \(.applicationName)"
            ],
            shortTitle: "Tareas Completadas",
            systemImageName: "checkmark.circle.fill"
        )

        AppShortcut(
            intent: CrearTareaRapidaIntent(),
            phrases: [
                "Crear tarea en \(.applicationName)",
                "Nueva tarea en \(.applicationName)",
                "Agregar tarea a \(.applicationName)"
            ],
            shortTitle: "Crear Tarea",
            systemImageName: "plus.circle.fill"
        )

        AppShortcut(
            intent: AbrirPantallaFavoritosIntent(),
            phrases: [
                "Abrir favoritos en \(.applicationName)",
                "Mis favoritos en \(.applicationName)"
            ],
            shortTitle: "Favoritos",
            systemImageName: "star.fill"
        )
    }
}
```

### SiriTipView — Guiar al Usuario

Apple proporciona `SiriTipView` para mostrar al usuario que frases puede decir. Es la forma recomendada de descubrir intents.

```swift
import SwiftUI
import AppIntents

// MARK: - Vista con SiriTipView

struct PantallaTareasView: View {
    @State private var mostrarTip = true

    var body: some View {
        NavigationStack {
            VStack {
                if mostrarTip {
                    SiriTipView(
                        intent: ContarTareasCompletadasIntent(),
                        isVisible: $mostrarTip
                    )
                    .padding()
                }

                // Contenido de la pantalla
                List {
                    Text("Tarea 1")
                    Text("Tarea 2")
                    Text("Tarea 3")
                }
            }
            .navigationTitle("Mis Tareas")
        }
    }
}
```

### Shortcuts App — Integracion Automatica

Todos los intents que declaras con `AppIntent` aparecen automaticamente en la app Shortcuts. El usuario puede combinarlos con acciones de otras apps para crear automatizaciones.

```swift
import AppIntents

// MARK: - Intent con confirmacion antes de ejecutar

struct EliminarProyectoIntent: AppIntent {

    static var title: LocalizedStringResource = "Eliminar proyecto"

    static var description: IntentDescription = IntentDescription(
        "Elimina un proyecto y todas sus tareas"
    )

    /// Pedir confirmacion al usuario antes de ejecutar
    static var isDiscoverable: Bool = true

    @Parameter(title: "Proyecto a eliminar")
    var proyecto: ProyectoEntity

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Pedir confirmacion explicitamente
        try await requestConfirmation(
            result: .result(
                dialog: "Seguro que quieres eliminar '\(proyecto.nombre)' con \(proyecto.tareasActivas) tareas?"
            )
        )

        // Si el usuario confirma, ejecutar la eliminacion
        // eliminarProyecto(proyecto.id)

        return .result(dialog: "Proyecto '\(proyecto.nombre)' eliminado.")
    }
}
```

### Intents Parametrizados con Resumen Personalizado

Para intents complejos, puedes personalizar como se muestra el resumen en Shortcuts.

```swift
import AppIntents

// MARK: - Intent con ParameterSummary

struct ProgramarRecordatorioIntent: AppIntent {

    static var title: LocalizedStringResource = "Programar recordatorio"

    @Parameter(title: "Tarea")
    var tarea: String

    @Parameter(title: "En cuantos minutos", default: 30)
    var minutos: Int

    @Parameter(title: "Repetir diariamente", default: false)
    var repetir: Bool

    /// Resumen visual en la app Shortcuts
    static var parameterSummary: some ParameterSummary {
        When(\.$repetir, .equalTo, true) {
            Summary("Recordar \(\.$tarea) en \(\.$minutos) min, repitiendo diariamente")
        } otherwise: {
            Summary("Recordar \(\.$tarea) en \(\.$minutos) min")
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let mensaje = repetir
            ? "Recordatorio para '\(tarea)' en \(minutos) min (se repetira diariamente)"
            : "Recordatorio para '\(tarea)' en \(minutos) min"

        return .result(dialog: "\(mensaje)")
    }
}
```

---

## Ejercicio 1: Intent Basico con Enum (Basico)

**Objetivo**: Crear un intent simple que consulte informacion y la devuelva a Siri.

**Requisitos**:
1. Crear un `AppIntent` llamado `ConsultarClimaIntent`
2. Agregar un `@Parameter` con un `AppEnum` para la ciudad (Madrid, Barcelona, Valencia)
3. El metodo `perform()` debe devolver un `IntentDialog` con el clima simulado
4. Registrar 3 frases en `AppShortcutsProvider`

---

## Ejercicio 2: AppEntity con EntityQuery (Intermedio)

**Objetivo**: Modelar entidades de tu dominio y exponerlas al sistema.

**Requisitos**:
1. Crear `RecetaEntity` conformando `AppEntity` con propiedades: id, nombre, tiempoPreparacion, dificultad
2. Implementar `EntityStringQuery` con busqueda por nombre
3. Crear `BuscarRecetaIntent` que reciba un `RecetaEntity` como parametro
4. Crear `RecetasPorDificultadIntent` con parametro `AppEnum` de dificultad
5. Mostrar `SiriTipView` en una vista SwiftUI

---

## Ejercicio 3: Sistema Completo de Intents (Avanzado)

**Objetivo**: Construir un sistema de intents interconectados para una app de gestion de gastos.

**Requisitos**:
1. `GastoEntity` con propiedades: id, descripcion, monto, categoria, fecha
2. `CategoriaGasto` como `AppEnum` (comida, transporte, entretenimiento, servicios, otros)
3. `RegistrarGastoIntent` con parametros: descripcion, monto, categoria
4. `ConsultarGastosTotalesIntent` con parametro opcional de categoria
5. `EliminarGastoIntent` con confirmacion via `requestConfirmation()`
6. `AppShortcutsProvider` con al menos 5 frases repartidas entre los intents
7. `ParameterSummary` personalizado para el intent de registrar gasto

---

## 5 Errores Comunes

### 1. Olvidar incluir .applicationName en las frases de Siri

```swift
// MAL — la frase no incluye el nombre de la app
AppShortcut(
    intent: MiIntent(),
    phrases: ["Crear tarea nueva"]  // Siri no sabe a que app pertenece
)

// BIEN — siempre incluir .applicationName
AppShortcut(
    intent: MiIntent(),
    phrases: ["Crear tarea nueva en \(.applicationName)"]
)
```

### 2. No implementar suggestedEntities() en EntityQuery

```swift
// MAL — Siri no puede mostrar opciones al usuario
struct MiQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [MiEntity] {
        // Solo esto no es suficiente
    }
}

// BIEN — implementar sugerencias para que Siri muestre opciones
struct MiQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [MiEntity] {
        return buscarPorIds(identifiers)
    }

    func suggestedEntities() async throws -> [MiEntity] {
        return obtenerEntidadesRecientes()  // Siri muestra estas opciones
    }
}
```

### 3. Hacer intents que tardan demasiado en perform()

```swift
// MAL — operacion pesada sin feedback
func perform() async throws -> some IntentResult {
    let datos = try await descargarTodosLosDatos()  // 30 segundos...
    try await procesarCompleto(datos)               // Siri se desespera
    return .result()
}

// BIEN — operaciones rapidas o con progreso
func perform() async throws -> some IntentResult & ProvidesDialog {
    // Iniciar la operacion en background y responder rapido
    let resumen = try await obtenerResumenRapido()
    return .result(dialog: "Procesando \(resumen.total) elementos en segundo plano")
}
```

### 4. No usar @Parameter(default:) para valores opcionales con sentido

```swift
// MAL — Siri pregunta por cada parametro sin necesidad
@Parameter(title: "Prioridad")
var prioridad: PrioridadTarea  // Siri siempre preguntara "Cual prioridad?"

// BIEN — valor por defecto para flujo mas rapido
@Parameter(title: "Prioridad", default: .media)
var prioridad: PrioridadTarea  // Solo pregunta si el usuario quiere cambiarla
```

### 5. Confundir AppIntent con SiriKit Intents (legacy)

```swift
// MAL — framework legacy (INIntent)
import Intents

class MiIntentHandler: INExtension {
    // No uses esto — es el sistema viejo basado en dominios limitados
}

// BIEN — framework moderno (AppIntents)
import AppIntents

struct MiIntent: AppIntent {
    static var title: LocalizedStringResource = "Mi accion"
    func perform() async throws -> some IntentResult { .result() }
}
```

---

## Checklist

- [ ] Crear un AppIntent basico con titulo y perform()
- [ ] Devolver IntentDialog para que Siri lea el resultado
- [ ] Usar @Parameter con tipos simples (String, Int, Date)
- [ ] Crear AppEnum para parametros con opciones fijas
- [ ] Implementar AppEntity con displayRepresentation
- [ ] Escribir EntityQuery con entities(for:) y suggestedEntities()
- [ ] Implementar EntityStringQuery para busqueda por texto
- [ ] Registrar frases en AppShortcutsProvider con .applicationName
- [ ] Mostrar SiriTipView en la UI de tu app
- [ ] Usar requestConfirmation() para acciones destructivas
- [ ] Personalizar ParameterSummary para Shortcuts
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

App Intents sera una capa clave de integracion en tu proyecto:
- **Acciones rapidas**: Exponer las funciones principales (crear, buscar, consultar) a Siri y Spotlight
- **AppEntity**: Modelar tus entidades de dominio para que el sistema las conozca y sugiera
- **Shortcuts**: Los usuarios podran automatizar flujos de tu app con otras apps
- **Action Button**: En iPhone 15 Pro+, el boton de accion puede ejecutar tus intents
- **Widgets interactivos**: Los botones de widgets pueden ejecutar AppIntents directamente
- **Apple Intelligence**: Tus intents seran las acciones que Apple Intelligence puede sugerir proactivamente

---

*Leccion 28 | App Intents y Siri | Semanas 35-36 | Modulo 07: Integracion con el Sistema*
*Siguiente: Leccion 29 — Widgets y Live Activities*
