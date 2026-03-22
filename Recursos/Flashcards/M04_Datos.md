# Flashcards — Modulo 04: Datos y Persistencia

---

### Tarjeta 1
**Pregunta:** Que es la macro `@Model` en SwiftData y que genera automaticamente?
**Respuesta:** `@Model` convierte una clase Swift en un modelo persistente de SwiftData. Genera automaticamente: 1) Conformancia a `PersistentModel` y `Observable`. 2) Esquema de almacenamiento. 3) Tracking de cambios. 4) Soporte para relaciones. Solo funciona con clases, no con structs.

---

### Tarjeta 2
**Pregunta:** Que es un `ModelContainer` y como se configura en una app SwiftUI?
**Respuesta:** `ModelContainer` es el contenedor que gestiona el almacenamiento de SwiftData. Contiene el esquema y la configuracion (en memoria, persistente, URL custom). Se configura en el `App` con `.modelContainer(for: [MiModelo.self])`. Crea automaticamente el `ModelContext` principal e lo inyecta en el environment.

---

### Tarjeta 3
**Pregunta:** Que es un `ModelContext` y cuales son sus operaciones principales?
**Respuesta:** `ModelContext` es el espacio de trabajo donde se crean, leen, modifican y eliminan objetos de SwiftData. Operaciones: 1) `context.insert(objeto)` — insertar. 2) `context.delete(objeto)` — eliminar. 3) `try context.save()` — persistir cambios. 4) `try context.fetch(descriptor)` — consultar. Se obtiene con `@Environment(\.modelContext)`.

---

### Tarjeta 4
**Pregunta:** Como funciona `@Query` en SwiftUI con SwiftData?
**Respuesta:** `@Query` es un property wrapper que ejecuta una consulta reactiva a SwiftData. Se actualiza automaticamente cuando los datos cambian. Soporta: ordenamiento (`sort:`), filtros (`filter:`), y animacion. Ejemplo: `@Query(sort: \Tarea.fecha) var tareas: [Tarea]`. Vive en la View y reemplaza `@FetchRequest` de Core Data.

---

### Tarjeta 5
**Pregunta:** Que es `#Predicate` y como se usa para filtrar datos?
**Respuesta:** `#Predicate` es una macro que crea filtros type-safe para SwiftData. Ejemplo: `#Predicate<Tarea> { $0.completada == false && $0.prioridad > 3 }`. Ventajas sobre NSPredicate: 1) Se verifica en compilacion. 2) Autocompletado de propiedades. 3) Sintaxis Swift nativa. Se pasa a `@Query(filter:)` o a `FetchDescriptor`.

---

### Tarjeta 6
**Pregunta:** Como se definen relaciones en SwiftData?
**Respuesta:** Las relaciones se definen como propiedades del modelo. SwiftData las infiere automaticamente. Para uno-a-muchos: `var tareas: [Tarea] = []`. Para configurar reglas de borrado: `@Relationship(deleteRule: .cascade) var tareas: [Tarea]`. Las reglas son: `.cascade` (borrar hijos), `.nullify` (desvincular), `.deny` (impedir si tiene hijos).

---

### Tarjeta 7
**Pregunta:** Que es CloudKit y como se integra con SwiftData?
**Respuesta:** CloudKit es el servicio de sincronizacion en la nube de Apple usando el iCloud del usuario. Con SwiftData se integra simplemente usando `ModelConfiguration` con `cloudKitDatabase: .automatic`. Los datos se sincronizan automaticamente entre dispositivos. Requisitos: 1) Capability de iCloud + CloudKit. 2) Un CKContainer configurado. 3) Los modelos deben tener valores por defecto opcionales.

---

### Tarjeta 8
**Pregunta:** Que es un `CKContainer` y cuales son sus tipos?
**Respuesta:** `CKContainer` es el contenedor logico de CloudKit que agrupa los datos. Tipos de base de datos: 1) **Private**: datos del usuario, cuenta iCloud propia. 2) **Shared**: datos compartidos entre usuarios. 3) **Public**: datos visibles para todos los usuarios de la app. Se accede con `CKContainer.default()` o `CKContainer(identifier:)`.

---

### Tarjeta 9
**Pregunta:** Como se hace una peticion de red con `URLSession` y `async/await`?
**Respuesta:** `let (data, response) = try await URLSession.shared.data(from: url)`. Luego verificas el status code del response y decodificas: `let resultado = try JSONDecoder().decode(MiTipo.self, from: data)`. Todo en codigo lineal y legible, sin callbacks. Para POST, creas un `URLRequest` y usas `.data(for: request)`.

---

### Tarjeta 10
**Pregunta:** Que es el protocolo `Codable` y de que se compone?
**Respuesta:** `Codable` es un typealias de `Encodable & Decodable`. Permite convertir tipos Swift a/desde formatos como JSON. Si las propiedades del tipo ya son Codable y los nombres coinciden con las claves JSON, Swift genera la conformancia automaticamente. Se usa con `JSONEncoder` y `JSONDecoder`.

---

### Tarjeta 11
**Pregunta:** Para que sirven los `CodingKeys` y cuando son necesarios?
**Respuesta:** `CodingKeys` es un enum que mapea entre nombres de propiedades Swift y claves del formato externo (JSON). Son necesarios cuando: 1) La clave JSON es diferente al nombre de la propiedad (ej: `user_name` -> `userName`). 2) Quieres excluir propiedades de la codificacion (omitirlas del enum). 3) Necesitas mapear estructuras anidadas.

---

### Tarjeta 12
**Pregunta:** Como se maneja la paginacion de datos en una lista con SwiftUI?
**Respuesta:** Se detecta cuando el usuario llega al final con `.onAppear` en el ultimo elemento o usando `.task` con un `id` que cambia. Al detectarlo, se llama al ViewModel para cargar la siguiente pagina. El ViewModel mantiene el offset/cursor, un flag `hayMasPaginas`, y agrega los nuevos elementos al array existente (no lo reemplaza).
