# Flashcards — Modulo 08: Plataformas

---

### Tarjeta 1
**Pregunta:** Cual es la arquitectura recomendada para una app de watchOS?
**Respuesta:** watchOS usa una arquitectura ligera centrada en interacciones rapidas. Componentes: 1) **App principal** con `@main` y `WindowGroup`. 2) **Vistas SwiftUI** (misma API que iOS). 3) **Complicaciones** con WidgetKit. 4) **Notificaciones** locales/push. La app debe ser independiente (no depender de la app de iPhone). El WatchConnectivity framework permite comunicacion entre Watch e iPhone cuando es necesario.

---

### Tarjeta 2
**Pregunta:** Que son las complicaciones de watchOS y como se implementan?
**Respuesta:** Las complicaciones son widgets en la esfera del reloj que muestran datos de tu app. Desde watchOS 9+, se implementan con **WidgetKit** (mismo framework que widgets de iPhone). Usan `TimelineProvider`, familias como `.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline`, `.accessoryCorner`. Se actualizan via timelines, igual que los widgets.

---

### Tarjeta 3
**Pregunta:** Cuales son los niveles de inmersion en visionOS?
**Respuesta:** 1) **Shared Space** (por defecto): tu app coexiste con otras en el espacio compartido. Ventanas 2D con profundidad. 2) **Full Space** (`.immersionStyle(.full)`): tu app es la unica visible, puedes colocar contenido en todo el espacio. 3) **Mixed** (`.immersionStyle(.mixed)`): full space pero el passthrough sigue visible. 4) **Progressive**: el usuario controla cuanta inmersion quiere.

---

### Tarjeta 4
**Pregunta:** Como se usa RealityKit en visionOS para contenido 3D?
**Respuesta:** Se usa `RealityView` como contenedor SwiftUI para contenido 3D. Dentro, se agregan `Entity` al `content`: `RealityView { content in let esfera = ModelEntity(mesh: .generateSphere(radius: 0.1)); content.add(esfera) }`. Soporta gestos con `.gesture(DragGesture())`, animaciones, y carga de modelos USDZ. Los `attachments` permiten mezclar UI SwiftUI con entidades 3D.

---

### Tarjeta 5
**Pregunta:** Que es `NavigationSplitView` y en que plataformas se usa?
**Respuesta:** `NavigationSplitView` crea una interfaz de columnas adaptable. Puede tener 2 columnas (sidebar + detail) o 3 (sidebar + content + detail). En iPad muestra columnas lado a lado; en iPhone se comporta como una pila de navegacion. Es el patron principal para apps de iPad, macOS y visionOS donde necesitas navegacion jerarquica.

---

### Tarjeta 6
**Pregunta:** Que es `MenuBarExtra` en macOS y como se implementa?
**Respuesta:** `MenuBarExtra` crea un icono en la barra de menus de macOS con contenido asociado. Se define en el `@main App`: `MenuBarExtra("Titulo", systemImage: "icono") { MiVista() }`. Con `.menuBarExtraStyle(.window)` muestra una ventana; con `.menu` muestra un menu desplegable. Ideal para apps utilitarias que viven en la barra de menus.

---

### Tarjeta 7
**Pregunta:** Como se adapta una app de iPhone a iPad usando las APIs modernas?
**Respuesta:** 1) Usar `NavigationSplitView` en lugar de `NavigationStack` solo. 2) Soportar **multitasking** (Slide Over, Split View) con layouts flexibles. 3) Agregar **keyboard shortcuts** con `.keyboardShortcut()`. 4) Soportar **drag and drop** con `.draggable()` y `.dropDestination()`. 5) Aprovechar el espacio extra con grids y columnas. 6) Soportar **Apple Pencil** si aplica.

---

### Tarjeta 8
**Pregunta:** Que APIs son exclusivas de visionOS y no existen en otras plataformas?
**Respuesta:** 1) `RealityView` y `RealityKit` con tracking espacial. 2) `ImmersiveSpace` para espacios inmersivos. 3) Gestos espaciales: `.onTapGesture` funciona con la mirada + pinch. 4) `SpatialTapGesture`, `DragGesture` en 3D. 5) `AnchorEntity` para anclar al mundo real. 6) Hand tracking con ARKit. Las ventanas 2D de SwiftUI funcionan directamente sin cambios.

---

### Tarjeta 9
**Pregunta:** Como se usa `#if os()` para compilacion condicional por plataforma?
**Respuesta:** `#if os(iOS)`, `#if os(watchOS)`, `#if os(macOS)`, `#if os(visionOS)`. Se pueden combinar: `#if os(iOS) || os(visionOS)`. Tambien: `#if canImport(UIKit)` para verificar frameworks disponibles. Esto permite compartir codigo entre plataformas y solo especializar lo necesario. Es una directiva de compilacion, no runtime.

---

### Tarjeta 10
**Pregunta:** Cual es la estrategia recomendada para crear una app multiplataforma?
**Respuesta:** 1) **Compartir**: modelos de datos, logica de negocio, ViewModels y servicios. 2) **Adaptar**: vistas de navegacion (NavigationStack vs NavigationSplitView). 3) **Especializar**: features unicas por plataforma (complicaciones en watchOS, inmersion en visionOS). Usar un solo target con `#if os()` para apps simples, o targets separados con un paquete Swift compartido para apps complejas.
