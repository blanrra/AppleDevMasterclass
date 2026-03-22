# Leccion 33: macOS e iPadOS — Productividad Multi-Plataforma

**Modulo 08: Plataformas** | Semana 42

---

## TL;DR — Resumen en 2 minutos

- **SwiftUI comparte codigo** entre plataformas — misma logica, presentacion adaptada con `#if os()`
- **NavigationSplitView** es la estructura natural para iPad y Mac — sidebar, content, detail
- **Keyboard shortcuts** con `.keyboardShortcut()` transforman tu app en una herramienta productiva
- **MenuBarExtra** crea apps de barra de menu en macOS — ideal para utilidades
- **iPad multitasking** soporta Split View, Slide Over y Stage Manager — tu app debe adaptarse

> Herramienta: **Xcode 26** con "My Mac (Designed for iPad)" para probar adaptaciones

---

## Cupertino MCP

```bash
cupertino search "macOS SwiftUI"
cupertino search "NavigationSplitView"
cupertino search "MenuBarExtra"
cupertino search --source apple-docs "keyboardShortcut"
cupertino search "Settings SwiftUI macOS"
cupertino search "toolbar SwiftUI"
cupertino search --source hig "iPad layout"
cupertino search --source hig "macOS design"
cupertino search "iPad multitasking"
cupertino search --source updates "macOS 26"
cupertino search "Stage Manager"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in SwiftUI | Novedades multi-plataforma |
| WWDC24 | [Bring your app to the Mac](https://developer.apple.com/videos/play/wwdc2024/) | **Esencial** — Mac Catalyst vs nativo |
| WWDC23 | [Design for iPad](https://developer.apple.com/videos/play/wwdc2023/) | Diseno adaptativo iPad |
| WWDC22 | [Bring multiple windows to your SwiftUI app](https://developer.apple.com/videos/play/wwdc2022/10061/) | Multi-window macOS |
| EN | [Stewart Lynch — macOS](https://www.youtube.com/@StewartLynch) | macOS con SwiftUI |
| EN | [Paul Hudson — Mac](https://www.hackingwithswift.com) | Fundamentos Mac |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Multi-Plataforma?

SwiftUI fue creado para compartir codigo entre todas las plataformas Apple. Pero compartir codigo no significa crear una sola UI para todo. La pantalla de 6.1" del iPhone, la de 13" del iPad y la de 16" del MacBook son contextos completamente diferentes. El usuario de Mac espera atajos de teclado, menus y ventanas redimensionables. El de iPad espera multitasking con Split View. Tu trabajo es adaptar la experiencia, no reducirla.

La estrategia correcta: una sola codebase con adaptaciones por plataforma usando `#if os()` para codigo especifico y `.environment` para deteccion de tamano.

### NavigationSplitView — La Estructura Natural

NavigationSplitView es el patron principal para apps productivas en iPad y Mac. Ofrece sidebar + contenido + detalle con colapso automatico en iPhone.

```swift
import SwiftUI
import SwiftData

// MARK: - App Multi-Plataforma
struct AppMultiPlataforma: View {
    @State private var categoriaSeleccionada: Categoria?
    @State private var itemSeleccionado: ItemProyecto?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // SIDEBAR — navegacion principal
            SidebarView(seleccion: $categoriaSeleccionada)
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
                #endif
        } content: {
            // CONTENT — lista filtrada
            if let categoria = categoriaSeleccionada {
                ListaItemsView(
                    categoria: categoria,
                    seleccion: $itemSeleccionado
                )
            } else {
                ContentUnavailableView(
                    "Selecciona una categoria",
                    systemImage: "sidebar.left",
                    description: Text("Elige una categoria del sidebar para ver sus items")
                )
            }
        } detail: {
            // DETAIL — item seleccionado
            if let item = itemSeleccionado {
                DetalleItemView(item: item)
            } else {
                ContentUnavailableView(
                    "Sin seleccion",
                    systemImage: "doc.text",
                    description: Text("Selecciona un item para ver su detalle")
                )
            }
        }
        #if os(macOS)
        .frame(minWidth: 700, minHeight: 400)
        #endif
    }
}

// MARK: - Sidebar
struct SidebarView: View {
    @Binding var seleccion: Categoria?

    let categorias: [Categoria] = [
        Categoria(nombre: "Tareas", icono: "checklist", color: .blue),
        Categoria(nombre: "Notas", icono: "note.text", color: .yellow),
        Categoria(nombre: "Archivos", icono: "folder.fill", color: .cyan),
        Categoria(nombre: "Favoritos", icono: "star.fill", color: .orange),
    ]

    var body: some View {
        List(categorias, selection: $seleccion) { categoria in
            Label(categoria.nombre, systemImage: categoria.icono)
                .foregroundStyle(categoria.color)
                .tag(categoria)
        }
        .navigationTitle("Proyecto")
        #if os(macOS)
        .listStyle(.sidebar)
        #endif
    }
}

struct Categoria: Identifiable, Hashable {
    let id = UUID()
    let nombre: String
    let icono: String
    let color: Color
}

struct ItemProyecto: Identifiable, Hashable {
    let id = UUID()
    let titulo: String
    let descripcion: String
    let fecha: Date
}

struct ListaItemsView: View {
    let categoria: Categoria
    @Binding var seleccion: ItemProyecto?

    var items: [ItemProyecto] {
        (1...10).map { i in
            ItemProyecto(
                titulo: "\(categoria.nombre) \(i)",
                descripcion: "Descripcion del item \(i)",
                fecha: Date().addingTimeInterval(Double(-i) * 86400)
            )
        }
    }

    var body: some View {
        List(items, selection: $seleccion) { item in
            VStack(alignment: .leading) {
                Text(item.titulo)
                    .font(.headline)
                Text(item.fecha, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tag(item)
        }
        .navigationTitle(categoria.nombre)
    }
}

struct DetalleItemView: View {
    let item: ItemProyecto

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.titulo)
                    .font(.largeTitle.bold())
                Text(item.fecha, style: .date)
                    .foregroundStyle(.secondary)
                Divider()
                Text(item.descripcion)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle(item.titulo)
        #if os(macOS)
        .navigationSubtitle(item.fecha.formatted())
        #endif
    }
}
```

### Keyboard Shortcuts — Productividad con Teclado

Los atajos de teclado son esenciales en iPad con teclado y en Mac. SwiftUI los soporta nativamente.

```swift
import SwiftUI

// MARK: - Keyboard Shortcuts
struct EditorConAtajosView: View {
    @State private var texto: String = ""
    @State private var mostrarInspector = false
    @State private var mostrarBusqueda = false
    @State private var tamanoFuente: CGFloat = 14

    var body: some View {
        NavigationStack {
            TextEditor(text: $texto)
                .font(.system(size: tamanoFuente, design: .monospaced))
                .padding()
                .inspector(isPresented: $mostrarInspector) {
                    InspectorView(tamanoFuente: $tamanoFuente)
                }
                .searchable(text: .constant(""), isPresented: $mostrarBusqueda)
                .navigationTitle("Editor")
                .toolbar {
                    // Toolbar con shortcuts
                    ToolbarItem(placement: .primaryAction) {
                        Button("Inspector") {
                            mostrarInspector.toggle()
                        }
                        .keyboardShortcut("i", modifiers: [.command, .option])
                    }
                }
        }
        // Shortcuts globales
        .keyboardShortcut("n", modifiers: .command) // Cmd+N
        // Atajos personalizados con .onKeyPress (iOS 17+)
        .onKeyPress(.tab) { _ in
            texto += "    " // 4 espacios en lugar de tab
            return .handled
        }
        .onKeyPress(characters: .alphanumerics, phases: .down) { press in
            // Detectar teclas especificas
            return .ignored // dejar que el sistema las maneje
        }
    }
}

struct InspectorView: View {
    @Binding var tamanoFuente: CGFloat

    var body: some View {
        Form {
            Section("Tipografia") {
                Stepper("Tamano: \(Int(tamanoFuente))", value: $tamanoFuente, in: 10...30)
            }
        }
        .inspectorColumnWidth(min: 200, ideal: 250, max: 300)
    }
}
```

### Menu y Commands — Barra de Menu macOS

```swift
import SwiftUI

// MARK: - Commands (Barra de Menu macOS)
@main
struct MiAppMac: App {
    @State private var documentoActual: String = ""

    var body: some Scene {
        WindowGroup {
            ContentViewMac()
        }
        .commands {
            // Reemplazar menu de New
            CommandGroup(replacing: .newItem) {
                Button("Nuevo Documento") {
                    documentoActual = ""
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Nueva Carpeta") {
                    // crear carpeta
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }

            // Menu custom
            CommandMenu("Herramientas") {
                Button("Formatear Codigo") {
                    // formatear
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])

                Button("Ejecutar") {
                    // ejecutar
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()

                Menu("Exportar como...") {
                    Button("PDF") { }
                    Button("HTML") { }
                    Button("Markdown") { }
                }
            }

            // Agregar al menu existente
            CommandGroup(after: .help) {
                Button("Documentacion API") {
                    // abrir docs
                }
            }
        }

        // Ventana de Settings (Preferencias)
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}

struct ContentViewMac: View {
    var body: some View {
        Text("App macOS")
            .frame(minWidth: 600, minHeight: 400)
    }
}
```

### MenuBarExtra — Apps de Barra de Menu

```swift
import SwiftUI

// MARK: - MenuBarExtra (solo macOS)
#if os(macOS)
@main
struct UtilidadMenuBar: App {
    @State private var tiempoRestante: Int = 1500 // 25 min pomodoro
    @State private var estaActivo = false

    var body: some Scene {
        // Menu bar item
        MenuBarExtra {
            // Contenido del menu
            VStack(spacing: 12) {
                Text(tiempoFormateado)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()

                HStack {
                    Button(estaActivo ? "Pausar" : "Iniciar") {
                        estaActivo.toggle()
                    }
                    .keyboardShortcut(.space, modifiers: [])

                    Button("Reiniciar") {
                        tiempoRestante = 1500
                        estaActivo = false
                    }
                    .keyboardShortcut("r", modifiers: .command)
                }

                Divider()

                // Presets
                HStack {
                    Button("25 min") { tiempoRestante = 1500 }
                    Button("15 min") { tiempoRestante = 900 }
                    Button("5 min") { tiempoRestante = 300 }
                }

                Divider()

                Button("Salir") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding()
            .frame(width: 250)

        } label: {
            // Icono en la barra de menu
            HStack(spacing: 4) {
                Image(systemName: estaActivo ? "timer" : "timer.circle")
                Text(tiempoFormateado)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)
    }

    private var tiempoFormateado: String {
        let minutos = tiempoRestante / 60
        let segundos = tiempoRestante % 60
        return String(format: "%02d:%02d", minutos, segundos)
    }
}
#endif
```

### Toolbar Personalizado — Adaptativo por Plataforma

```swift
import SwiftUI

// MARK: - Toolbar Adaptativo
struct ToolbarAdaptativoView: View {
    @State private var ordenamiento: Ordenamiento = .fecha
    @State private var vistaGrid = false
    @State private var mostrarFiltros = false

    var body: some View {
        NavigationStack {
            Text("Contenido")
                .navigationTitle("Biblioteca")
                .toolbar {
                    // Placement automatico por plataforma
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            vistaGrid.toggle()
                        } label: {
                            Image(systemName: vistaGrid ? "list.bullet" : "square.grid.2x2")
                        }
                        .help("Cambiar vista") // tooltip en macOS

                        Button {
                            mostrarFiltros.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .help("Filtros")
                    }

                    // Solo en macOS — barra de busqueda en toolbar
                    #if os(macOS)
                    ToolbarItem(placement: .automatic) {
                        Picker("Ordenar", selection: $ordenamiento) {
                            ForEach(Ordenamiento.allCases) { orden in
                                Text(orden.rawValue).tag(orden)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                    #endif

                    // En iPad — secondary action
                    #if os(iOS)
                    ToolbarItem(placement: .secondaryAction) {
                        Menu("Ordenar") {
                            Picker("Ordenar por", selection: $ordenamiento) {
                                ForEach(Ordenamiento.allCases) { orden in
                                    Text(orden.rawValue).tag(orden)
                                }
                            }
                        }
                    }
                    #endif
                }
                #if os(macOS)
                .toolbarRole(.editor) // estilo editor en macOS
                #endif
        }
    }
}

enum Ordenamiento: String, CaseIterable, Identifiable {
    case fecha = "Fecha"
    case nombre = "Nombre"
    case tamano = "Tamano"
    var id: Self { self }
}
```

### Codigo Especifico por Plataforma con #if os()

```swift
import SwiftUI

// MARK: - Adaptaciones por Plataforma
struct VistaAdaptativa: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        Group {
            #if os(macOS)
            // macOS — ventana con controles nativos
            HSplitView {
                panelIzquierdo
                    .frame(minWidth: 200)
                panelDerecho
                    .frame(minWidth: 400)
            }
            #elseif os(iOS)
            // iOS/iPadOS — adaptarse al size class
            if sizeClass == .regular {
                // iPad — layout amplio
                HStack(spacing: 0) {
                    panelIzquierdo
                        .frame(width: 320)
                    Divider()
                    panelDerecho
                }
            } else {
                // iPhone — layout compacto
                NavigationStack {
                    panelIzquierdo
                }
            }
            #endif
        }
    }

    private var panelIzquierdo: some View {
        List {
            ForEach(1...10, id: \.self) { i in
                Text("Item \(i)")
            }
        }
        .listStyle(.insetGrouped)
    }

    private var panelDerecho: some View {
        VStack {
            Text("Detalle")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Extension con Modifier Condicional
extension View {
    /// Aplica un modifier solo en la plataforma especificada
    @ViewBuilder
    func aplicarSi<Content: View>(
        _ condicion: Bool,
        modificar: (Self) -> Content
    ) -> some View {
        if condicion {
            modificar(self)
        } else {
            self
        }
    }
}
```

### iPad Multitasking y Pointer Support

```swift
import SwiftUI

// MARK: - iPad Multitasking y Pointer
struct iPadMultitaskingView: View {
    @Environment(\.horizontalSizeClass) private var horizontal
    @Environment(\.verticalSizeClass) private var vertical

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Informacion del entorno actual
                GroupBox("Entorno") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Horizontal: \(horizontal == .regular ? "Regular" : "Compact")")
                        Text("Vertical: \(vertical == .regular ? "Regular" : "Compact")")
                        Text(descripcionMultitasking)
                            .foregroundStyle(.secondary)
                    }
                }

                // Grid que se adapta al espacio disponible
                let columnas = horizontal == .regular ? 3 : 2

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: columnas),
                    spacing: 16
                ) {
                    ForEach(1...9, id: \.self) { i in
                        TarjetaAdaptativaView(numero: i)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    private var descripcionMultitasking: String {
        switch (horizontal, vertical) {
        case (.regular, .regular):
            return "Pantalla completa o Split View amplio"
        case (.compact, .regular):
            return "Split View estrecho o Slide Over"
        case (.regular, .compact):
            return "Landscape"
        default:
            return "iPhone o Slide Over compacto"
        }
    }
}

struct TarjetaAdaptativaView: View {
    let numero: Int
    @State private var estaHover = false

    var body: some View {
        VStack {
            Image(systemName: "\(numero).circle.fill")
                .font(.largeTitle)
            Text("Item \(numero)")
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(estaHover ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
        )
        // Soporte para pointer/trackpad en iPad
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                estaHover = hovering
            }
        }
        .hoverEffect(.highlight) // efecto nativo de hover en iPad
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

#### Diagrama de Estrategia Multi-Plataforma

```
  ┌──────────────────────────────────────────────────────┐
  │         ESTRATEGIA MULTI-PLATAFORMA                   │
  │                                                       │
  │  CODIGO COMPARTIDO (80-90%):                          │
  │  ┌─────────────────────────────────────────────────┐ │
  │  │  Models / Domain Logic / ViewModels             │ │
  │  │  SwiftData Models / Networking                  │ │
  │  │  Business Rules / Utilities                     │ │
  │  └─────────────────────────────────────────────────┘ │
  │                                                       │
  │  UI COMPARTIDA CON ADAPTACIONES (10-15%):             │
  │  ┌─────────────────────────────────────────────────┐ │
  │  │  NavigationSplitView → 3 col iPad/Mac, stack iOS│ │
  │  │  Toolbar → placement adaptativo por plataforma  │ │
  │  │  .horizontalSizeClass → layout responsive       │ │
  │  └─────────────────────────────────────────────────┘ │
  │                                                       │
  │  CODIGO ESPECIFICO (5-10%):                           │
  │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
  │  │  macOS   │  │  iPadOS  │  │      iOS         │  │
  │  │          │  │          │  │                   │  │
  │  │ Commands │  │ Pointer  │  │ Compact layout   │  │
  │  │ Settings │  │ Split    │  │ Phone-specific   │  │
  │  │ MenuBar  │  │ Stage Mgr│  │                   │  │
  │  │ NSWindow │  │ Keyboard │  │                   │  │
  │  └──────────┘  └──────────┘  └──────────────────┘  │
  │                                                       │
  │  #if os(macOS)  #if os(iOS)  .horizontalSizeClass    │
  └──────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: App Multi-Plataforma con NavigationSplitView (Basico)

**Objetivo**: Crear una app que funcione en iPhone, iPad y Mac con una sola codebase.

**Requisitos**:
1. NavigationSplitView con sidebar de categorias (al menos 4)
2. Lista de items filtrada por categoria seleccionada
3. Vista de detalle completa con titulo, fecha, descripcion
4. En iPhone: colapso automatico a NavigationStack
5. En iPad/Mac: tres columnas visibles simultaneamente
6. Usar `#if os()` para al menos una diferencia visual entre plataformas

---

## Ejercicio 2: App macOS con Commands y MenuBarExtra (Intermedio)

**Objetivo**: Crear una app macOS con barra de menu y atajos de teclado.

**Requisitos**:
1. Menu custom "Herramientas" con al menos 4 items y keyboard shortcuts
2. Settings window con al menos 3 opciones configurables (fuente, tema, idioma)
3. MenuBarExtra con un timer pomodoro funcional (25/15/5 minutos)
4. El MenuBarExtra debe mostrar el tiempo restante en la barra de menu
5. Keyboard shortcuts globales: Cmd+N (nuevo), Cmd+S (guardar), Cmd+F (buscar)
6. Toolbar personalizado con controles segmentados

---

## Ejercicio 3: iPad Pro con Stage Manager y Pointer (Avanzado)

**Objetivo**: App iPad optimizada para productividad con teclado y trackpad.

**Requisitos**:
1. Detectar y adaptarse a `horizontalSizeClass` y `verticalSizeClass`
2. Grid responsive: 2 columnas en compact, 3 en regular, 4 en landscape amplio
3. Hover effects nativos con `.hoverEffect()` en todos los elementos interactivos
4. Inspector panel con `.inspector()` que se muestra/oculta con Cmd+I
5. Atajos de teclado para navegacion: flechas para mover seleccion, Enter para abrir, Escape para cerrar
6. Soporte para drag and drop entre secciones de la app
7. Context menu con opciones relevantes en cada item

---

## 5 Errores Comunes

### 1. No respetar el tamano minimo de ventana en macOS
```swift
// MAL — ventana que se puede hacer demasiado pequena
WindowGroup {
    ContentView()
    // sin restricciones de tamano
}

// BIEN — tamano minimo y default apropiados
WindowGroup {
    ContentView()
        .frame(minWidth: 600, idealWidth: 900, minHeight: 400, idealHeight: 600)
}
.defaultSize(width: 900, height: 600)
```

### 2. Ignorar horizontalSizeClass en iPad
```swift
// MAL — asumir que iPad siempre tiene pantalla amplia
NavigationSplitView {
    sidebar
} detail: {
    detail // en Slide Over esto queda enorme
}

// BIEN — adaptarse al size class
@Environment(\.horizontalSizeClass) private var sizeClass

var body: some View {
    if sizeClass == .regular {
        NavigationSplitView { sidebar } detail: { detail }
    } else {
        NavigationStack { sidebar } // compacto como iPhone
    }
}
```

### 3. Keyboard shortcuts que conflictan con el sistema
```swift
// MAL — Cmd+Q es del sistema en macOS, no lo uses en tu app
Button("Mi Accion") { }
    .keyboardShortcut("q", modifiers: .command) // conflicto con Quit

// MAL — Cmd+C es Copy, no lo sobreescribas
Button("Categorias") { }
    .keyboardShortcut("c", modifiers: .command) // conflicto con Copy

// BIEN — usar combinaciones que no conflicten
Button("Categorias") { }
    .keyboardShortcut("c", modifiers: [.command, .shift]) // Cmd+Shift+C
```

### 4. MenuBarExtra sin forma de salir
```swift
// MAL — no hay forma de cerrar la app
MenuBarExtra("Timer", systemImage: "timer") {
    Text("25:00")
    Button("Iniciar") { }
    // el usuario no puede salir!
}

// BIEN — siempre incluir opcion de salir
MenuBarExtra("Timer", systemImage: "timer") {
    Text("25:00")
    Button("Iniciar") { }
    Divider()
    Button("Salir") {
        NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q", modifiers: .command)
}
```

### 5. No probar en todos los modos de multitasking
```swift
// MAL — layout fijo que se rompe en Split View
HStack {
    panelIzquierdo
        .frame(width: 400) // fijo — se desborda en Split View 33%
    panelDerecho
}

// BIEN — layout flexible que se adapta
HStack {
    panelIzquierdo
        .frame(minWidth: 200, idealWidth: 300, maxWidth: 400)
    panelDerecho
        .frame(maxWidth: .infinity) // toma el espacio restante
}
```

---

## Checklist

- [ ] Crear una app con NavigationSplitView que funcione en iPhone, iPad y Mac
- [ ] Usar `#if os()` para adaptaciones por plataforma
- [ ] Implementar keyboard shortcuts con `.keyboardShortcut()`
- [ ] Crear Commands custom para la barra de menu de macOS
- [ ] Implementar Settings window en macOS
- [ ] Crear un MenuBarExtra funcional
- [ ] Manejar `.horizontalSizeClass` para iPad multitasking
- [ ] Implementar hover effects para pointer/trackpad en iPad
- [ ] Usar toolbar con placement adaptativo por plataforma
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

macOS e iPadOS extienden el alcance del Proyecto Integrador:
- **NavigationSplitView** como estructura principal — funciona en las tres plataformas automaticamente
- **Keyboard shortcuts** para usuarios productivos en iPad con teclado y Mac
- **Commands** para integrar las acciones del proyecto en la barra de menu de macOS
- **MenuBarExtra** para utilidades complementarias (timer, estado, quick actions)
- **iPad multitasking** asegura que tu app funciona en Split View y Stage Manager
- **Codigo compartido** al 80-90% — mismos modelos, ViewModels y logica de negocio
- **`#if os()`** para detalles especificos que hagan cada plataforma sentirse nativa

---

*Leccion 33 | macOS e iPadOS — Productividad Multi-Plataforma | Semana 42 | Modulo 08: Plataformas*
*Siguiente: Modulo 09 — Leccion 34: Testing con Swift Testing*
