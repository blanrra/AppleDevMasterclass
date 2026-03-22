# Flashcards — Modulo 01: Arquitectura

---

### Tarjeta 1
**Pregunta:** Que significa MVVM y cuales son sus tres componentes?
**Respuesta:** Model-View-ViewModel. 1) **Model**: datos y logica de negocio. 2) **View**: interfaz de usuario (SwiftUI Views). 3) **ViewModel**: intermediario que transforma datos del Model para la View y maneja la logica de presentacion. En SwiftUI moderno, el ViewModel usa `@Observable`.

---

### Tarjeta 2
**Pregunta:** Como funciona `@Observable` y por que reemplaza a `ObservableObject`?
**Respuesta:** `@Observable` (macro de Observation framework) convierte una clase en observable automaticamente. Detecta que propiedades lee cada View y solo la actualiza cuando esas propiedades cambian. Reemplaza a `ObservableObject` porque: 1) No necesita `@Published`. 2) Es mas eficiente (observacion granular por propiedad). 3) Menos boilerplate.

---

### Tarjeta 3
**Pregunta:** Cuales son las responsabilidades de un ViewModel en MVVM con SwiftUI?
**Respuesta:** 1) Exponer datos formateados para la View. 2) Manejar acciones del usuario (metodos que la View invoca). 3) Coordinar con servicios y repositorios. 4) Manejar estados de carga, error y exito. **No debe**: importar SwiftUI, conocer detalles de la UI, ni acceder directamente a la base de datos.

---

### Tarjeta 4
**Pregunta:** Cuales son las capas de Clean Architecture y que direccion tienen las dependencias?
**Respuesta:** 1) **Dominio** (centro): entidades y casos de uso, sin dependencias externas. 2) **Datos**: repositorios, data sources, networking. 3) **Presentacion**: Views y ViewModels. Las dependencias apuntan **hacia adentro**: Presentacion depende de Dominio, Datos depende de Dominio, pero Dominio no depende de nadie.

---

### Tarjeta 5
**Pregunta:** Que es un caso de uso (Use Case) en Clean Architecture?
**Respuesta:** Es una clase o struct que encapsula **una sola operacion de negocio**. Ejemplo: `ObtenerProductosUseCase`. Recibe datos de entrada, ejecuta logica de negocio usando repositorios, y devuelve un resultado. Vive en la capa de Dominio y no conoce detalles de implementacion (base de datos, red, UI).

---

### Tarjeta 6
**Pregunta:** Que es el patron Repository y que problema resuelve?
**Respuesta:** El Repository es una abstraccion (protocolo) que oculta el origen de los datos. La capa de Dominio define el protocolo (`ProductoRepository`), y la capa de Datos lo implementa (desde red, SwiftData, cache, etc.). Resuelve: 1) Desacoplar logica de negocio de la fuente de datos. 2) Facilitar testing con mocks. 3) Poder cambiar la fuente sin afectar el dominio.

---

### Tarjeta 7
**Pregunta:** Que es la Inyeccion de Dependencias (DI) y cuales son sus formas principales?
**Respuesta:** DI es un patron donde un objeto recibe sus dependencias desde fuera en lugar de crearlas internamente. Formas: 1) **Inicializador** (preferida): se pasan en el `init`. 2) **Environment** de SwiftUI: `.environment()`. 3) **Contenedor DI**: un registro central resuelve dependencias. Beneficio principal: facilita el testing y reduce el acoplamiento.

---

### Tarjeta 8
**Pregunta:** Como se implementa DI en SwiftUI usando el Environment?
**Respuesta:** Se define una `EnvironmentKey` con un valor por defecto, se extiende `EnvironmentValues` con una propiedad computed, y se inyecta con `.environment(\.clave, valor)`. Las Views hijas acceden con `@Environment(\.clave)`. Ideal para servicios compartidos en todo el arbol de vistas.

---

### Tarjeta 9
**Pregunta:** Por que no se debe usar Singleton para dependencias y cual es la alternativa?
**Respuesta:** Singleton crea acoplamiento oculto, dificulta el testing (no puedes reemplazarlo con un mock facilmente) y oculta las dependencias reales de una clase. La alternativa es **Inyeccion de Dependencias**: declaras la dependencia como protocolo en el `init`, permitiendo inyectar implementaciones reales o mocks segun el contexto.

---

### Tarjeta 10
**Pregunta:** Como se estructura un proyecto SwiftUI con MVVM + Clean Architecture en carpetas?
**Respuesta:** ```
App/
  Domain/
    Models/          (entidades)
    UseCases/        (logica de negocio)
    Repositories/    (protocolos)
  Data/
    Repositories/    (implementaciones)
    DataSources/     (red, SwiftData)
    DTOs/            (objetos de transferencia)
  Presentation/
    Screens/         (Views + ViewModels por pantalla)
    Components/      (vistas reutilizables)
```
La clave es que Domain no importa Data ni Presentation.
