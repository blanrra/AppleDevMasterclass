# Leccion 19: SwiftData

**Modulo 04: Datos y Persistencia** | Semanas 23-24

---

## TL;DR — Resumen en 2 minutos

- **@Model**: Macro que convierte una clase en persistente — SwiftData genera el esquema automaticamente
- **ModelContainer**: La base de datos completa — configuracion, almacenamiento y esquema
- **ModelContext**: Tu conexion activa a la base de datos — donde haces CRUD (crear, leer, actualizar, eliminar)
- **@Query**: Property wrapper que observa cambios automaticamente y refresca la vista SwiftUI
- **#Predicate**: Macro type-safe para filtrar datos — adios a los NSPredicate con strings magicos

---

## Cupertino MCP

```bash
cupertino search "SwiftData"
cupertino search "@Model SwiftData"
cupertino search "ModelContainer"
cupertino search "ModelContext"
cupertino search "@Query SwiftData"
cupertino search "#Predicate"
cupertino search "SwiftData migration"
cupertino search --source samples "SwiftData"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC23 | [Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/) | **Esencial** — Introduccion oficial |
| WWDC23 | [Build an app with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10154/) | **Esencial** — App completa |
| WWDC23 | [Model your schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195/) | Relaciones y esquema |
| WWDC24 | [What's new in SwiftData](https://developer.apple.com/videos/play/wwdc2024/10137/) | Novedades iOS 18 |
| WWDC24 | [Create a custom data store with SwiftData](https://developer.apple.com/videos/play/wwdc2024/10138/) | Almacenamiento custom |
| :es: | [Julio Cesar Fernandez — SwiftData](https://www.youtube.com/@AppleCodingAcademy) | Serie en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que SwiftData?

Core Data fue el framework de persistencia de Apple durante casi 20 anos. Funcionaba, pero era doloroso: `NSManagedObject`, `NSFetchRequest`, archivos `.xcdatamodeld`, y un monton de boilerplate. SwiftData nacio para resolver todo eso con una premisa simple: **tus modelos Swift SON tu esquema**.

SwiftData no es un wrapper sobre Core Data — es un framework nuevo que comparte el mismo motor de almacenamiento (SQLite), pero con una API completamente moderna, type-safe, y disenada para SwiftUI.

```
  ┌──────────────────────────────────────────────────────────┐
  │                    ARQUITECTURA SWIFTDATA                │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   @Model Tarea         SwiftUI View                      │
  │   ├─ titulo: String    ├─ @Query var tareas: [Tarea]     │
  │   ├─ fecha: Date       ├─ @Environment(\.modelContext)   │
  │   └─ completada: Bool  └─ modelContext.insert(tarea)     │
  │          │                        │                      │
  │          ▼                        ▼                      │
  │   ┌─────────────────────────────────────┐                │
  │   │          ModelContainer              │                │
  │   │  ┌─────────────────────────────┐    │                │
  │   │  │       ModelContext           │    │                │
  │   │  │  (insert/delete/save/fetch)  │    │                │
  │   │  └──────────┬──────────────────┘    │                │
  │   │             ▼                       │                │
  │   │        SQLite Store                 │                │
  │   └─────────────────────────────────────┘                │
  └──────────────────────────────────────────────────────────┘
```

### @Model — Tu Modelo es tu Esquema

La macro `@Model` transforma una clase Swift comun en un modelo persistente. No necesitas archivos de esquema, ni descriptores, ni generacion de codigo.

```swift
import SwiftData

// MARK: - Modelo basico

@Model
class Tarea {
    var titulo: String
    var detalle: String
    var fechaCreacion: Date
    var completada: Bool
    var prioridad: Int

    init(titulo: String, detalle: String = "", prioridad: Int = 0) {
        self.titulo = titulo
        self.detalle = detalle
        self.fechaCreacion = .now
        self.completada = false
        self.prioridad = prioridad
    }
}
```

> **Nota importante**: `@Model` solo funciona con `class`, no con `struct`. Esto es porque SwiftData necesita identidad de referencia para rastrear cambios y relaciones.

#### Atributos y personalizacion

```swift
import SwiftData

@Model
class Contacto {
    // Unico — no se permiten duplicados
    @Attribute(.unique) var email: String

    var nombre: String
    var telefono: String?

    // Datos grandes se almacenan externamente (imagenes, archivos)
    @Attribute(.externalStorage) var foto: Data?

    // Propiedades transitorias — no se persisten
    @Transient var esFavorito: Bool = false

    // Propiedades computadas — tampoco se persisten
    var iniciales: String {
        let partes = nombre.split(separator: " ")
        return partes.map { String($0.prefix(1)) }.joined()
    }

    init(nombre: String, email: String, telefono: String? = nil) {
        self.nombre = nombre
        self.email = email
        self.telefono = telefono
    }
}
```

### Relaciones

SwiftData infiere relaciones automaticamente a partir de las propiedades de tu modelo.

```swift
import SwiftData

@Model
class Proyecto {
    var nombre: String
    var descripcion: String

    // Relacion uno-a-muchos: un proyecto tiene muchas tareas
    // .cascade = si borras el proyecto, se borran sus tareas
    @Relationship(deleteRule: .cascade) var tareas: [Tarea] = []

    init(nombre: String, descripcion: String = "") {
        self.nombre = nombre
        self.descripcion = descripcion
    }
}

@Model
class Tarea {
    var titulo: String
    var completada: Bool
    var fechaLimite: Date?

    // Relacion inversa — SwiftData la conecta automaticamente
    var proyecto: Proyecto?

    init(titulo: String, proyecto: Proyecto? = nil) {
        self.titulo = titulo
        self.completada = false
        self.proyecto = proyecto
    }
}
```

#### Reglas de borrado

| Regla | Comportamiento |
|-------|----------------|
| `.nullify` (default) | Pone la referencia en nil |
| `.cascade` | Borra los objetos relacionados |
| `.deny` | Impide borrar si hay relaciones |
| `.noAction` | No hace nada (puede dejar huerfanos) |

### ModelContainer — La Base de Datos

`ModelContainer` es el contenedor que gestiona todo: esquema, almacenamiento y configuracion.

```swift
import SwiftUI
import SwiftData

// MARK: - Configuracion basica en la App

@main
struct MiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Esto crea el container y lo inyecta en el environment
        .modelContainer(for: [Proyecto.self, Tarea.self])
    }
}
```

#### Configuracion avanzada

```swift
import SwiftData

// MARK: - Container con configuracion personalizada

let esquema = Schema([Proyecto.self, Tarea.self])

let configuracion = ModelConfiguration(
    "MiBaseDatos",
    schema: esquema,
    isStoredInMemoryOnly: false,  // true para tests o previews
    allowsSave: true
)

let container = try ModelContainer(
    for: esquema,
    configurations: [configuracion]
)
```

### ModelContext — Operaciones CRUD

`ModelContext` es tu conexion activa a la base de datos. Aqui es donde creas, lees, actualizas y borras datos.

```swift
import SwiftData

// MARK: - CRUD con ModelContext

func demoCRUD(contexto: ModelContext) throws {
    // CREATE — Insertar
    let proyecto = Proyecto(nombre: "App de Fitness", descripcion: "Tracking de ejercicios")
    contexto.insert(proyecto)

    let tarea1 = Tarea(titulo: "Disenar pantalla principal", proyecto: proyecto)
    let tarea2 = Tarea(titulo: "Implementar HealthKit", proyecto: proyecto)
    contexto.insert(tarea1)
    contexto.insert(tarea2)

    // READ — Consultar
    let descriptor = FetchDescriptor<Tarea>(
        predicate: #Predicate { tarea in
            tarea.completada == false
        },
        sortBy: [SortDescriptor(\.titulo)]
    )
    let tareasPendientes = try contexto.fetch(descriptor)

    // UPDATE — Actualizar (simplemente modifica la propiedad)
    tarea1.completada = true
    // SwiftData detecta el cambio automaticamente

    // DELETE — Eliminar
    contexto.delete(tarea2)

    // SAVE — Guardar cambios (SwiftData guarda automaticamente,
    // pero puedes forzar el guardado)
    try contexto.save()
}
```

### @Query — Observar Datos en SwiftUI

`@Query` es el puente entre SwiftData y SwiftUI. Funciona como un `@State` que se actualiza automaticamente cuando los datos cambian.

```swift
import SwiftUI
import SwiftData

// MARK: - Vista con @Query

struct ListaTareasView: View {
    // Query basico — todas las tareas ordenadas por fecha
    @Query(sort: \.fechaCreacion, order: .reverse)
    private var tareas: [Tarea]

    @Environment(\.modelContext) private var contexto

    var body: some View {
        NavigationStack {
            List {
                ForEach(tareas) { tarea in
                    HStack {
                        Image(systemName: tarea.completada
                            ? "checkmark.circle.fill"
                            : "circle")
                        Text(tarea.titulo)
                            .strikethrough(tarea.completada)
                    }
                    .onTapGesture {
                        tarea.completada.toggle()
                    }
                }
                .onDelete(perform: eliminarTareas)
            }
            .navigationTitle("Tareas")
        }
    }

    private func eliminarTareas(en offsets: IndexSet) {
        for index in offsets {
            contexto.delete(tareas[index])
        }
    }
}
```

#### @Query con filtros y ordenamiento

```swift
import SwiftUI
import SwiftData

struct TareasFiltradas: View {
    // Query con predicado — solo tareas pendientes
    @Query(
        filter: #Predicate<Tarea> { !$0.completada },
        sort: [SortDescriptor(\.prioridad, order: .reverse),
               SortDescriptor(\.titulo)]
    )
    private var tareasPendientes: [Tarea]

    var body: some View {
        List(tareasPendientes) { tarea in
            VStack(alignment: .leading) {
                Text(tarea.titulo)
                    .font(.headline)
                if let fecha = tarea.fechaLimite {
                    Text(fecha, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
```

### #Predicate — Filtros Type-Safe

`#Predicate` es una macro que genera predicados en tiempo de compilacion. Si escribes algo invalido, Xcode te avisa — nada de crashes en runtime.

```swift
import SwiftData
import Foundation

// MARK: - Predicados comunes

// Tareas de alta prioridad
let altaPrioridad = #Predicate<Tarea> { tarea in
    tarea.prioridad >= 3
}

// Tareas con fecha limite proxima (7 dias)
let proximaFechaLimite = #Predicate<Tarea> { tarea in
    if let fecha = tarea.fechaLimite {
        return fecha <= Date.now.addingTimeInterval(7 * 24 * 3600)
    }
    return false
}

// Busqueda por texto
func buscarTareas(texto: String) -> Predicate<Tarea> {
    #Predicate<Tarea> { tarea in
        tarea.titulo.localizedStandardContains(texto)
    }
}

// Combinar predicados en FetchDescriptor
func obtenerTareasUrgentes(contexto: ModelContext) throws -> [Tarea] {
    var descriptor = FetchDescriptor<Tarea>(
        predicate: #Predicate { tarea in
            tarea.prioridad >= 3 && !tarea.completada
        },
        sortBy: [SortDescriptor(\.fechaLimite)]
    )
    descriptor.fetchLimit = 10  // Limitar resultados
    return try contexto.fetch(descriptor)
}
```

### Migraciones

Cuando cambias tu esquema (agregas, renombras o eliminas propiedades), necesitas migraciones.

```swift
import SwiftData

// MARK: - Migraciones

// Version 1 del esquema
enum EsquemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Tarea.self]
    }

    @Model
    class Tarea {
        var titulo: String
        var completada: Bool
        init(titulo: String) {
            self.titulo = titulo
            self.completada = false
        }
    }
}

// Version 2 — agregamos prioridad
enum EsquemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Tarea.self]
    }

    @Model
    class Tarea {
        var titulo: String
        var completada: Bool
        var prioridad: Int  // NUEVA propiedad
        init(titulo: String, prioridad: Int = 0) {
            self.titulo = titulo
            self.completada = false
            self.prioridad = prioridad
        }
    }
}

// Plan de migracion
enum PlanMigracion: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [EsquemaV1.self, EsquemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migracionV1aV2]
    }

    static let migracionV1aV2 = MigrationStage.lightweight(
        fromVersion: EsquemaV1.self,
        toVersion: EsquemaV2.self
    )
}
```

### SwiftData vs Core Data

| Aspecto | Core Data | SwiftData |
|---------|-----------|-----------|
| Definicion de modelo | Editor visual + NSManagedObject | Macro @Model en codigo Swift |
| Consultas | NSFetchRequest + NSPredicate (strings) | @Query + #Predicate (type-safe) |
| Observacion | NSFetchedResultsController | @Query automatico |
| Relaciones | Manual en editor | Inferidas del codigo |
| Concurrencia | viewContext/performBackgroundTask | @ModelActor |
| Migraciones | NSMappingModel | VersionedSchema |
| SwiftUI | Wrappers manuales | Integracion nativa |

---

## Ejercicio 1: Gestor de Notas (Basico)

**Objetivo**: Practicar @Model, ModelContainer, @Query y CRUD basico.

**Requisitos**:
1. Modelo `Nota` con: titulo, contenido, fechaCreacion, esImportante (Bool)
2. Vista `ListaNotasView` que muestre todas las notas con @Query, ordenadas por fecha
3. Boton para agregar notas nuevas y deslizar para eliminar
4. Toggle para marcar/desmarcar como importante

---

## Ejercicio 2: Biblioteca con Relaciones (Intermedio)

**Objetivo**: Practicar relaciones, predicados y ordenamiento.

**Requisitos**:
1. Modelos: `Autor` (nombre, nacionalidad) y `Libro` (titulo, anioPublicacion, leido)
2. Relacion uno-a-muchos: un autor tiene muchos libros, con `.cascade`
3. Vista con @Query que filtre libros no leidos usando #Predicate
4. Barra de busqueda que filtre por titulo con `localizedStandardContains`
5. Ordenamiento dinamico (por titulo o por anio)

---

## Ejercicio 3: Sistema de Tareas con Migracion (Avanzado)

**Objetivo**: Practicar migraciones, @ModelActor y operaciones en lote.

**Requisitos**:
1. Version 1: Modelo `Tarea` con titulo, completada, fechaCreacion
2. Version 2: Agregar campo `categoria` (String) y `prioridad` (Int)
3. Implementar `SchemaMigrationPlan` con migracion lightweight
4. Crear un actor con `@ModelActor` para importar 100 tareas en background
5. Vista que muestre tareas agrupadas por categoria usando `SectionedQuery` o agrupacion manual

---

## 5 Errores Comunes

### 1. Usar struct en lugar de class con @Model

```swift
// MAL — @Model requiere class
@Model
struct Tarea {  // Error de compilacion
    var titulo: String
}

// BIEN — @Model solo funciona con class
@Model
class Tarea {
    var titulo: String
    init(titulo: String) { self.titulo = titulo }
}
```

### 2. Olvidar registrar todos los modelos en el container

```swift
// MAL — falta registrar Tarea, que es parte de la relacion
.modelContainer(for: [Proyecto.self])
// Crash: Tarea no tiene esquema registrado

// BIEN — registrar todos los modelos del grafo
.modelContainer(for: [Proyecto.self, Tarea.self])
```

### 3. Modificar datos sin tener un ModelContext

```swift
// MAL — no se puede insertar sin contexto
let tarea = Tarea(titulo: "Test")
// tarea nunca se persiste porque no se inserto en un contexto

// BIEN — usar el contexto del environment
@Environment(\.modelContext) private var contexto
// ...
let tarea = Tarea(titulo: "Test")
contexto.insert(tarea)
```

### 4. Usar tipos no soportados en #Predicate

```swift
// MAL — operaciones complejas no soportadas en #Predicate
let pred = #Predicate<Tarea> { tarea in
    tarea.titulo.count > 5  // Puede fallar en runtime
}

// BIEN — usar operaciones soportadas
let pred = #Predicate<Tarea> { tarea in
    tarea.titulo.localizedStandardContains("urgente")
}
```

### 5. No manejar errores en save()

```swift
// MAL — ignorar errores de guardado
try? contexto.save()

// BIEN — manejar el error apropiadamente
do {
    try contexto.save()
} catch {
    print("Error al guardar: \(error.localizedDescription)")
    // Notificar al usuario o reintentar
}
```

---

## Checklist

- [ ] Crear modelos con @Model y entender sus limitaciones (solo class)
- [ ] Configurar ModelContainer en la App
- [ ] Realizar operaciones CRUD con ModelContext
- [ ] Usar @Query para mostrar datos reactivamente en SwiftUI
- [ ] Filtrar con #Predicate de forma type-safe
- [ ] Implementar relaciones uno-a-muchos con @Relationship
- [ ] Entender las reglas de borrado (cascade, nullify, deny)
- [ ] Configurar migraciones con VersionedSchema
- [ ] Usar @Attribute para unique, externalStorage y transient
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

SwiftData sera la columna vertebral de persistencia de tu app:
- **@Model** para todos los modelos de dominio (usuarios, registros, configuracion)
- **@Query** en cada vista que muestre datos persistentes
- **Relaciones** para modelar el grafo de objetos de tu app
- **Migraciones** cuando evoluciones el esquema entre versiones
- **ModelContainer** compartido entre la app principal y widgets/extensiones

---

*Leccion 19 | SwiftData | Semanas 23-24 | Modulo 04: Datos y Persistencia*
*Siguiente: Leccion 20 — CloudKit*
