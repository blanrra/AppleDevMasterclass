# Leccion 20: CloudKit

**Modulo 04: Datos y Persistencia** | Semana 25

---

## TL;DR — Resumen en 2 minutos

- **CloudKit**: Framework de Apple para sincronizar datos entre dispositivos via iCloud — sin servidor propio
- **CKContainer**: Tu espacio en iCloud — cada app tiene uno por defecto
- **CKDatabase**: Tres bases de datos — privada (del usuario), publica (compartida), shared (entre usuarios)
- **SwiftData + CloudKit**: Activar sincronizacion es casi automatico — solo necesitas iCloud capability y configuracion minima
- **Conflict Resolution**: Cuando dos dispositivos cambian lo mismo, necesitas una estrategia para resolver conflictos

---

## Cupertino MCP

```bash
cupertino search "CloudKit"
cupertino search "CKContainer"
cupertino search "CKRecord"
cupertino search "CKDatabase"
cupertino search "SwiftData CloudKit"
cupertino search "CKShare"
cupertino search "NSPersistentCloudKitContainer"
cupertino search --source samples "CloudKit"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC21 | [What's new in CloudKit](https://developer.apple.com/videos/play/wwdc2021/10086/) | Cambios modernos |
| WWDC22 | [Optimize your use of CloudKit](https://developer.apple.com/videos/play/wwdc2022/10119/) | Performance |
| WWDC23 | [Build an app with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10154/) | Incluye CloudKit sync |
| WWDC24 | [What's new in SwiftData](https://developer.apple.com/videos/play/wwdc2024/10137/) | Sync mejorado |
| WWDC19 | [Using Core Data with CloudKit](https://developer.apple.com/videos/play/wwdc2019/202/) | Fundamentos del sync |
| :es: | [Julio Cesar Fernandez — CloudKit](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que CloudKit?

Cuando un usuario usa tu app en su iPhone, iPad y Mac, espera que sus datos esten sincronizados. Podrias montar un servidor con Firebase, AWS o tu propio backend... o puedes usar **CloudKit**, que ya esta integrado en cada dispositivo Apple, usa la cuenta iCloud del usuario (sin login extra), y es **gratis** para volumenes razonables.

CloudKit no es solo un backend — es parte del ecosistema. Funciona con notificaciones push, compartir datos entre usuarios, y tiene una integracion profunda con SwiftData.

```
  ┌──────────────────────────────────────────────────────────┐
  │                  ARQUITECTURA CLOUDKIT                   │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   iPhone         iPad           Mac                      │
  │   ┌─────┐       ┌─────┐       ┌─────┐                   │
  │   │ App │       │ App │       │ App │                    │
  │   │     │       │     │       │     │                    │
  │   │ SwiftData   │ SwiftData   │ SwiftData                │
  │   └──┬──┘       └──┬──┘       └──┬──┘                    │
  │      │             │             │                       │
  │      └─────────────┼─────────────┘                       │
  │                    │                                     │
  │            ┌───────▼───────┐                             │
  │            │    iCloud     │                             │
  │            │  ┌─────────┐  │                             │
  │            │  │ Private │  │ ← Datos del usuario         │
  │            │  │   DB    │  │                             │
  │            │  ├─────────┤  │                             │
  │            │  │ Public  │  │ ← Datos compartidos global  │
  │            │  │   DB    │  │                             │
  │            │  ├─────────┤  │                             │
  │            │  │ Shared  │  │ ← Datos entre usuarios     │
  │            │  │   DB    │  │                             │
  │            │  └─────────┘  │                             │
  │            └───────────────┘                             │
  └──────────────────────────────────────────────────────────┘
```

### Las Tres Bases de Datos

CloudKit organiza los datos en tres bases de datos distintas:

```swift
import CloudKit

// MARK: - Las tres bases de datos de CloudKit

let container = CKContainer.default()

// Base de datos PRIVADA — datos del usuario actual
// Solo el usuario puede leer/escribir
let privateDB = container.privateCloudDatabase

// Base de datos PUBLICA — datos visibles para todos los usuarios
// Cualquiera puede leer, solo usuarios autenticados pueden escribir
let publicDB = container.publicCloudDatabase

// Base de datos COMPARTIDA — datos compartidos entre usuarios especificos
// Requiere CKShare para gestionar permisos
let sharedDB = container.sharedCloudDatabase
```

| Base de datos | Lectura | Escritura | Cuota | Uso tipico |
|---------------|---------|-----------|-------|------------|
| Private | Solo el usuario | Solo el usuario | Cuenta del usuario | Datos personales |
| Public | Todos | Usuarios autenticados | Cuenta del desarrollador | Catalogo, contenido global |
| Shared | Invitados | Segun permisos | Cuenta del propietario | Documentos colaborativos |

### CKRecord — La Unidad de Datos

`CKRecord` es el equivalente a una fila en una base de datos. Tiene un tipo (como una tabla) y campos clave-valor.

```swift
import CloudKit

// MARK: - Crear y guardar un CKRecord

func crearReceta() async throws {
    let record = CKRecord(recordType: "Receta")
    record["nombre"] = "Paella Valenciana"
    record["ingredientes"] = ["arroz", "pollo", "judias verdes", "azafran"]
    record["tiempoMinutos"] = 45
    record["fechaCreacion"] = Date.now
    record["esVegetariana"] = false

    let db = CKContainer.default().privateCloudDatabase
    let savedRecord = try await db.save(record)
    print("Receta guardada: \(savedRecord.recordID)")
}
```

### Consultas con CKQuery

```swift
import CloudKit

// MARK: - Consultar registros

func buscarRecetas(vegetarianas: Bool) async throws -> [CKRecord] {
    let predicate = NSPredicate(format: "esVegetariana == %d", vegetarianas)
    let query = CKQuery(recordType: "Receta", predicate: predicate)
    query.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]

    let db = CKContainer.default().privateCloudDatabase
    let (resultados, _) = try await db.records(matching: query)

    return resultados.compactMap { _, result in
        try? result.get()
    }
}

// MARK: - Obtener un registro por ID

func obtenerReceta(id: CKRecord.ID) async throws -> CKRecord {
    let db = CKContainer.default().privateCloudDatabase
    return try await db.record(for: id)
}
```

### Operaciones CRUD Completas

```swift
import CloudKit

// MARK: - CRUD con CloudKit

actor GestorRecetas {
    private let db = CKContainer.default().privateCloudDatabase

    // CREATE
    func crear(nombre: String, ingredientes: [String], tiempo: Int) async throws -> CKRecord {
        let record = CKRecord(recordType: "Receta")
        record["nombre"] = nombre
        record["ingredientes"] = ingredientes
        record["tiempoMinutos"] = tiempo
        record["fechaCreacion"] = Date.now
        return try await db.save(record)
    }

    // READ
    func listar() async throws -> [CKRecord] {
        let query = CKQuery(recordType: "Receta", predicate: NSPredicate(value: true))
        let (resultados, _) = try await db.records(matching: query)
        return resultados.compactMap { _, result in try? result.get() }
    }

    // UPDATE
    func actualizar(recordID: CKRecord.ID, nuevoNombre: String) async throws -> CKRecord {
        let record = try await db.record(for: recordID)
        record["nombre"] = nuevoNombre
        return try await db.save(record)
    }

    // DELETE
    func eliminar(recordID: CKRecord.ID) async throws {
        try await db.deleteRecord(withID: recordID)
    }
}
```

### SwiftData + CloudKit — La Integracion Magica

Esta es la forma moderna y recomendada. Con SwiftData, la sincronizacion con CloudKit es casi automatica.

#### Paso 1: Activar iCloud en Xcode

```
Target → Signing & Capabilities → + Capability → iCloud
  ✅ CloudKit
  Container: iCloud.com.tuempresa.tuapp
```

#### Paso 2: Configurar tu modelo compatible

```swift
import SwiftData

// MARK: - Modelo compatible con CloudKit

// Requisitos para CloudKit:
// 1. Todas las propiedades deben tener valor por defecto o ser opcionales
// 2. Las relaciones deben ser opcionales
// 3. No usar @Attribute(.unique) — CloudKit no lo soporta

@Model
class Receta {
    var nombre: String = ""
    var ingredientes: [String] = []
    var tiempoMinutos: Int = 0
    var fechaCreacion: Date = Date.now
    var esVegetariana: Bool = false

    @Attribute(.externalStorage) var foto: Data?

    // Relacion opcional — requerido para CloudKit
    @Relationship(deleteRule: .cascade) var pasos: [PasoReceta]?

    init(nombre: String, tiempoMinutos: Int = 0) {
        self.nombre = nombre
        self.tiempoMinutos = tiempoMinutos
    }
}

@Model
class PasoReceta {
    var numero: Int = 0
    var descripcion: String = ""
    var receta: Receta?

    init(numero: Int, descripcion: String) {
        self.numero = numero
        self.descripcion = descripcion
    }
}
```

#### Paso 3: Configurar el container

```swift
import SwiftUI
import SwiftData

@main
struct RecetasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Receta.self, PasoReceta.self])
        // SwiftData detecta la capability de iCloud y sincroniza automaticamente
    }
}
```

### Conflict Resolution

Cuando dos dispositivos modifican el mismo registro sin conexion, se produce un conflicto al sincronizar.

```swift
import CloudKit

// MARK: - Resolucion de conflictos

// CloudKit usa "last writer wins" por defecto.
// Para logica personalizada, necesitas manejar CKError.serverRecordChanged

func guardarConResolucion(record: CKRecord) async throws -> CKRecord {
    let db = CKContainer.default().privateCloudDatabase

    do {
        return try await db.save(record)
    } catch let error as CKError where error.code == .serverRecordChanged {
        // El servidor tiene una version mas reciente
        guard let serverRecord = error.serverRecord,
              let clientRecord = error.clientRecord else {
            throw error
        }

        // Estrategia: merge manual
        // Tomar el titulo del cliente y los ingredientes del servidor
        serverRecord["nombre"] = clientRecord["nombre"]
        // Los ingredientes del servidor son mas recientes, los mantenemos

        return try await db.save(serverRecord)
    }
}
```

#### Estrategias comunes de resolucion

```
  ┌────────────────────────────────────────────────────────┐
  │           ESTRATEGIAS DE CONFLICTO                     │
  ├──────────────────┬─────────────────────────────────────┤
  │  Last Writer     │ El cambio mas reciente gana         │
  │  Wins            │ Simple pero puede perder datos      │
  ├──────────────────┼─────────────────────────────────────┤
  │  Merge           │ Combinar campos de ambas versiones  │
  │  Manual          │ Mas control, mas complejidad        │
  ├──────────────────┼─────────────────────────────────────┤
  │  User            │ Preguntar al usuario cual conservar │
  │  Decision        │ Mejor UX, interrupcion al usuario   │
  ├──────────────────┼─────────────────────────────────────┤
  │  Operational     │ Transformar operaciones, no estados │
  │  Transform       │ Avanzado (tipo Google Docs)         │
  └──────────────────┴─────────────────────────────────────┘
```

### CKShare — Compartir Datos entre Usuarios

```swift
import CloudKit
import SwiftUI

// MARK: - Compartir con CKShare

func compartirReceta(record: CKRecord) async throws -> CKShare {
    let db = CKContainer.default().privateCloudDatabase

    let share = CKShare(rootRecord: record)
    share.publicPermission = .readOnly
    share[CKShare.SystemFieldKey.title] = "Receta compartida"

    let operation = CKModifyRecordsOperation(
        recordsToSave: [record, share],
        recordIDsToDelete: nil
    )

    return try await withCheckedThrowingContinuation { continuation in
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success:
                continuation.resume(returning: share)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
        db.add(operation)
    }
}
```

### Sincronizacion en Background

```swift
import CloudKit

// MARK: - Suscripciones para sync en background

func configurarSuscripcion() async throws {
    let db = CKContainer.default().privateCloudDatabase

    let suscripcion = CKDatabaseSubscription(subscriptionID: "cambios-recetas")

    let infoNotificacion = CKSubscription.NotificationInfo()
    infoNotificacion.shouldSendContentAvailable = true  // Silent push
    suscripcion.notificationInfo = infoNotificacion

    try await db.save(suscripcion)
    print("Suscripcion activa — recibiras cambios en background")
}

// En AppDelegate o similar:
func procesarNotificacionRemota(userInfo: [AnyHashable: Any]) async {
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)

    if notification?.subscriptionID == "cambios-recetas" {
        // Fetch cambios incrementales
        await sincronizarCambios()
    }
}

func sincronizarCambios() async {
    let db = CKContainer.default().privateCloudDatabase

    do {
        let cambios = try await db.recordZoneChanges(
            inZoneWith: .default,
            since: nil  // Usar token guardado en produccion
        )

        for modificacion in cambios.modificationResultsByID {
            // Procesar cada cambio
            print("Registro modificado: \(modificacion.key)")
        }
    } catch {
        print("Error sincronizando: \(error)")
    }
}
```

---

## Ejercicio 1: Notas Sincronizadas (Basico)

**Objetivo**: Practicar SwiftData con CloudKit activado.

**Requisitos**:
1. Modelo `Nota` compatible con CloudKit (propiedades con valores por defecto)
2. Configurar el proyecto con iCloud capability en Xcode
3. CRUD completo en una vista SwiftUI con @Query
4. Verificar que los datos aparecen en el CloudKit Dashboard

---

## Ejercicio 2: Recetario Compartido (Intermedio)

**Objetivo**: Practicar CKRecord, consultas y compartir datos.

**Requisitos**:
1. Modelo `Receta` con nombre, ingredientes, tiempo, categoria
2. Guardar y consultar recetas en la base de datos privada
3. Implementar busqueda por categoria usando CKQuery
4. Crear una funcion para compartir una receta con CKShare
5. Manejar el error `serverRecordChanged` con merge basico

---

## Ejercicio 3: Sincronizacion Offline-First (Avanzado)

**Objetivo**: Construir un sistema robusto de sincronizacion.

**Requisitos**:
1. SwiftData como store local con modelos compatibles con CloudKit
2. Detectar estado de red y mostrar indicador de sincronizacion
3. Implementar cola de operaciones pendientes para modo offline
4. Resolver conflictos con estrategia "merge por campo" (campo mas reciente gana)
5. Suscripcion a cambios remotos con CKDatabaseSubscription

---

## 5 Errores Comunes

### 1. Usar @Attribute(.unique) con CloudKit

```swift
// MAL — CloudKit no soporta restriccion unique
@Model
class Receta {
    @Attribute(.unique) var nombre: String = ""  // Crash al sincronizar
}

// BIEN — CloudKit necesita que no haya unique constraints
@Model
class Receta {
    var nombre: String = ""
    // Manejar unicidad en la logica de la app, no en el esquema
}
```

### 2. Propiedades sin valor por defecto

```swift
// MAL — CloudKit necesita valores por defecto
@Model
class Receta {
    var nombre: String      // Sin valor por defecto
    var tiempo: Int          // Sin valor por defecto
}

// BIEN — todas las propiedades con valor por defecto o opcionales
@Model
class Receta {
    var nombre: String = ""
    var tiempo: Int = 0
    var foto: Data?          // Opcional tambien funciona
}
```

### 3. No manejar el caso sin cuenta iCloud

```swift
// MAL — asumir que siempre hay cuenta iCloud
func guardar() async throws {
    let record = CKRecord(recordType: "Receta")
    try await CKContainer.default().privateCloudDatabase.save(record)
    // Crash si el usuario no tiene iCloud configurado
}

// BIEN — verificar estado de la cuenta
func guardar() async throws {
    let estado = try await CKContainer.default().accountStatus()
    guard estado == .available else {
        throw AppError.sinCuentaICloud
    }
    // Proceder con la operacion
}
```

### 4. Ignorar limites de tamano de CKRecord

```swift
// MAL — guardar datos grandes directamente
record["video"] = datosVideo  // Puede superar el limite de 1MB por campo

// BIEN — usar CKAsset para archivos grandes
let urlTemporal = FileManager.default.temporaryDirectory
    .appendingPathComponent("video.mp4")
try datosVideo.write(to: urlTemporal)
record["video"] = CKAsset(fileURL: urlTemporal)
```

### 5. No implementar resolucion de conflictos

```swift
// MAL — asumir que save() siempre funciona
try await db.save(record)

// BIEN — manejar conflictos explicitamente
do {
    try await db.save(record)
} catch let error as CKError where error.code == .serverRecordChanged {
    guard let serverRecord = error.serverRecord else { throw error }
    // Aplicar tus cambios sobre la version del servidor
    serverRecord["nombre"] = record["nombre"]
    try await db.save(serverRecord)
}
```

---

## Checklist

- [ ] Entender las tres bases de datos de CloudKit (private, public, shared)
- [ ] Crear y guardar CKRecords en la base de datos privada
- [ ] Consultar registros con CKQuery y NSPredicate
- [ ] Configurar SwiftData para sincronizar con CloudKit
- [ ] Hacer modelos compatibles con CloudKit (valores por defecto, sin unique)
- [ ] Verificar el estado de la cuenta iCloud antes de operar
- [ ] Manejar conflictos con serverRecordChanged
- [ ] Compartir datos con CKShare
- [ ] Configurar suscripciones para sync en background
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

CloudKit sera clave para la experiencia multi-dispositivo de tu app:
- **Sincronizacion automatica** via SwiftData + CloudKit para datos del usuario
- **CKShare** para funcionalidades de compartir (listas, registros, planes)
- **Base de datos publica** para contenido compartido (catalogos, plantillas)
- **Background sync** para mantener datos frescos sin abrir la app
- **Offline-first** para que la app funcione sin conexion y sincronice despues

---

*Leccion 20 | CloudKit | Semana 25 | Modulo 04: Datos y Persistencia*
*Siguiente: Leccion 21 — Networking*
