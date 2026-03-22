# Leccion 15: Navegacion Avanzada

**Modulo 03: SwiftUI Avanzado** | Semanas 17-18

---

## TL;DR — Resumen en 2 minutos

- **NavigationStack** reemplaza a NavigationView — maneja pilas de vistas con tipado seguro
- **NavigationPath** permite navegacion programatica con rutas heterogeneas tipo-seguras
- **NavigationSplitView** para interfaces sidebar/detail en iPad y Mac
- **Deep linking** convierte URLs externas en rutas de navegacion dentro de la app
- **Coordinator pattern** centraliza la logica de navegacion fuera de las vistas

> Herramienta: **Xcode 26** con SwiftUI Previews para probar flujos de navegacion

---

## Cupertino MCP

```bash
cupertino search "NavigationStack"
cupertino search "NavigationPath"
cupertino search "NavigationSplitView"
cupertino search "navigationDestination"
cupertino search --source apple-docs "NavigationLink"
cupertino search --source hig "navigation"
cupertino search --source updates "NavigationStack iOS 26"
cupertino search --source samples "Navigation"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC23 | [The SwiftUI Cookbook for Navigation](https://developer.apple.com/videos/play/wwdc2023/10054/) | **Esencial** — Patrones avanzados |
| WWDC22 | [The SwiftUI Cookbook for Navigation](https://developer.apple.com/videos/play/wwdc2022/10054/) | Introduccion NavigationStack |
| WWDC25 | What's New in SwiftUI | Novedades navegacion iOS 26 |
| EN | [Kavsoft — NavigationStack](https://www.youtube.com/@Kavsoft) | Implementaciones paso a paso |
| EN | [Paul Hudson — NavigationStack](https://www.hackingwithswift.com) | Tutoriales practicos |
| EN | [Stewart Lynch — Navigation](https://www.youtube.com/@StewartLynch) | Deep linking patterns |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que NavigationStack?

NavigationView tenia un problema fundamental: **la navegacion estaba acoplada a las vistas**. No podias navegar programaticamente sin hacks, no podias guardar/restaurar el estado de navegacion, y deep linking era una pesadilla.

NavigationStack invierte el modelo: **la pila de navegacion es estado**, representada por un `NavigationPath` o un array tipado. Esto permite:
- Navegar programaticamente desde cualquier lugar
- Guardar y restaurar el stack completo (state restoration)
- Implementar deep linking de forma nativa
- Testear la logica de navegacion sin UI

### NavigationStack Basico

NavigationStack usa `navigationDestination(for:)` para definir que vista mostrar para cada tipo de dato.

```swift
import SwiftUI

struct Producto: Identifiable, Hashable {
    let id = UUID()
    let nombre: String
    let precio: Double
    let categoria: String
}

struct CatalogoView: View {
    let productos = [
        Producto(nombre: "iPhone 17", precio: 999, categoria: "Telefono"),
        Producto(nombre: "MacBook Air", precio: 1299, categoria: "Laptop"),
        Producto(nombre: "AirPods Pro", precio: 249, categoria: "Audio")
    ]

    var body: some View {
        NavigationStack {
            List(productos) { producto in
                NavigationLink(value: producto) {
                    HStack {
                        Text(producto.nombre)
                        Spacer()
                        Text("$\(producto.precio, specifier: "%.0f")")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Catalogo")
            .navigationDestination(for: Producto.self) { producto in
                DetalleProductoView(producto: producto)
            }
        }
    }
}

struct DetalleProductoView: View {
    let producto: Producto

    var body: some View {
        VStack(spacing: 20) {
            Text(producto.nombre)
                .font(.largeTitle)
            Text("$\(producto.precio, specifier: "%.2f")")
                .font(.title2)
                .foregroundStyle(.green)
            Text("Categoria: \(producto.categoria)")
                .foregroundStyle(.secondary)
        }
        .navigationTitle(producto.nombre)
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

**Clave**: El `NavigationLink(value:)` no contiene la vista destino. El `navigationDestination(for:)` define como renderizar cada tipo. Esto separa la navegacion de la presentacion.

### NavigationPath — Navegacion Programatica

`NavigationPath` es un array heterogeneo tipo-seguro que representa la pila de navegacion.

```swift
import SwiftUI

// Tipos de destino
enum Destino: Hashable {
    case categoria(String)
    case producto(Producto)
    case carrito
    case checkout
}

@Observable
class NavegacionStore {
    var path = NavigationPath()

    func irAProducto(_ producto: Producto) {
        path.append(Destino.producto(producto))
    }

    func irACarrito() {
        path.append(Destino.carrito)
    }

    func irACheckout() {
        path.append(Destino.checkout)
    }

    func volverAlInicio() {
        path = NavigationPath()
    }

    func volverAtras() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func volverNPantallas(_ n: Int) {
        let cantidad = min(n, path.count)
        path.removeLast(cantidad)
    }
}

struct TiendaView: View {
    @State private var navegacion = NavegacionStore()

    var body: some View {
        NavigationStack(path: $navegacion.path) {
            List {
                Section("Categorias") {
                    NavigationLink("Telefonos", value: Destino.categoria("Telefono"))
                    NavigationLink("Laptops", value: Destino.categoria("Laptop"))
                }

                Section("Acciones") {
                    Button("Ir al Carrito") {
                        navegacion.irACarrito()
                    }
                }
            }
            .navigationTitle("Tienda")
            .navigationDestination(for: Destino.self) { destino in
                switch destino {
                case .categoria(let nombre):
                    CategoriaView(nombre: nombre, navegacion: navegacion)
                case .producto(let producto):
                    DetalleProductoView(producto: producto)
                case .carrito:
                    CarritoView(navegacion: navegacion)
                case .checkout:
                    CheckoutView(navegacion: navegacion)
                }
            }
        }
    }
}

struct CarritoView: View {
    let navegacion: NavegacionStore

    var body: some View {
        VStack(spacing: 20) {
            Text("Tu Carrito")
                .font(.largeTitle)

            Button("Proceder al Checkout") {
                navegacion.irACheckout()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Carrito")
    }
}

struct CheckoutView: View {
    let navegacion: NavegacionStore

    var body: some View {
        VStack(spacing: 20) {
            Text("Checkout Completado!")
                .font(.largeTitle)

            Button("Volver al Inicio") {
                navegacion.volverAlInicio()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Checkout")
    }
}
```

### NavigationSplitView — Sidebar para iPad y Mac

`NavigationSplitView` crea interfaces de dos o tres columnas adaptativas.

```swift
import SwiftUI

struct Categoria: Identifiable, Hashable {
    let id = UUID()
    let nombre: String
    let icono: String
}

struct CorreoView: View {
    let categorias = [
        Categoria(nombre: "Entrada", icono: "tray.fill"),
        Categoria(nombre: "Enviados", icono: "paperplane.fill"),
        Categoria(nombre: "Borradores", icono: "doc.fill"),
        Categoria(nombre: "Papelera", icono: "trash.fill")
    ]

    @State private var categoriaSeleccionada: Categoria?
    @State private var mensajeSeleccionado: String?
    @State private var visibilidadColumna: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $visibilidadColumna) {
            // Sidebar
            List(categorias, selection: $categoriaSeleccionada) { categoria in
                Label(categoria.nombre, systemImage: categoria.icono)
            }
            .navigationTitle("Correo")
        } content: {
            // Lista de mensajes
            if let categoria = categoriaSeleccionada {
                List(1...10, id: \.self, selection: $mensajeSeleccionado) { i in
                    Text("Mensaje \(i) de \(categoria.nombre)")
                        .tag("mensaje-\(i)")
                }
                .navigationTitle(categoria.nombre)
            } else {
                ContentUnavailableView("Selecciona una categoria",
                    systemImage: "tray",
                    description: Text("Elige una categoria del sidebar"))
            }
        } detail: {
            // Detalle del mensaje
            if let mensaje = mensajeSeleccionado {
                Text("Contenido de: \(mensaje)")
                    .font(.title)
                    .navigationTitle("Detalle")
            } else {
                ContentUnavailableView("Selecciona un mensaje",
                    systemImage: "envelope",
                    description: Text("Elige un mensaje para ver su contenido"))
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
```

### Deep Linking

Deep linking permite abrir la app en una pantalla especifica desde una URL externa.

```swift
import SwiftUI

@Observable
class DeepLinkHandler {
    var path = NavigationPath()

    func manejar(url: URL) {
        guard let componentes = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = componentes.host else { return }

        // Limpiar stack actual
        path = NavigationPath()

        // Parsear la URL: miapp://producto/123
        switch host {
        case "producto":
            if let idString = componentes.path.split(separator: "/").first,
               let id = Int(idString) {
                path.append(Destino.producto(
                    Producto(nombre: "Producto \(id)", precio: 99, categoria: "General")
                ))
            }
        case "carrito":
            path.append(Destino.carrito)
        case "categoria":
            if let nombre = componentes.queryItems?.first(where: { $0.name == "nombre" })?.value {
                path.append(Destino.categoria(nombre))
            }
        default:
            break
        }
    }
}

struct AppConDeepLink: View {
    @State private var handler = DeepLinkHandler()

    var body: some View {
        NavigationStack(path: $handler.path) {
            ContentView()
                .navigationDestination(for: Destino.self) { destino in
                    // ... resolver destinos
                    Text("Destino: \(String(describing: destino))")
                }
        }
        .onOpenURL { url in
            handler.manejar(url: url)
        }
    }
}
```

### Coordinator Pattern

El Coordinator centraliza toda la logica de navegacion, separandola de las vistas.

```swift
import SwiftUI

// MARK: - Rutas tipadas
enum AppRoute: Hashable {
    case listaProductos
    case detalleProducto(id: UUID)
    case perfil
    case configuracion
    case editarPerfil
}

// MARK: - Coordinator
@Observable
class AppCoordinator {
    var path = NavigationPath()
    var sheetItem: AppRoute?
    var alertMensaje: String?

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func presentSheet(_ route: AppRoute) {
        sheetItem = route
    }

    func dismissSheet() {
        sheetItem = nil
    }

    @ViewBuilder
    func resolver(ruta: AppRoute) -> some View {
        switch ruta {
        case .listaProductos:
            Text("Lista de Productos")
        case .detalleProducto(let id):
            Text("Detalle: \(id)")
        case .perfil:
            Text("Perfil")
        case .configuracion:
            Text("Configuracion")
        case .editarPerfil:
            Text("Editar Perfil")
        }
    }
}

struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(coordinator: coordinator)
                .navigationDestination(for: AppRoute.self) { ruta in
                    coordinator.resolver(ruta: ruta)
                }
        }
        .sheet(item: $coordinator.sheetItem) { ruta in
            coordinator.resolver(ruta: ruta)
        }
        .environment(coordinator)
    }
}

// Hacer AppRoute compatible con sheet
extension AppRoute: Identifiable {
    var id: Self { self }
}
```

#### Diagrama de Navegacion

```
  ┌──────────────────────────────────────────────────────┐
  │              NAVEGACION EN SWIFTUI                    │
  │                                                       │
  │  NavigationStack          NavigationSplitView         │
  │  (Push/Pop)               (Sidebar/Detail)            │
  │                                                       │
  │  ┌─────────────────┐     ┌───┬────────┬──────────┐   │
  │  │ Vista Raiz       │     │ S │ Content│  Detail  │   │
  │  │    ▼ push        │     │ i │        │          │   │
  │  │ Vista A          │     │ d │ Lista  │ Detalle  │   │
  │  │    ▼ push        │     │ e │   de   │   del    │   │
  │  │ Vista B          │     │ b │ items  │  item    │   │
  │  │    ▲ pop         │     │ a │        │          │   │
  │  │ Vista A          │     │ r │        │          │   │
  │  └─────────────────┘     └───┴────────┴──────────┘   │
  │                                                       │
  │  NavigationPath = [RouteA, RouteB, RouteC]            │
  │  path.removeLast()  → pop                             │
  │  path.append(route) → push                            │
  │  path = .init()     → pop to root                     │
  │                                                       │
  │  Deep Link: URL → Parser → path.append(rutas)         │
  │  Coordinator: Centraliza logica de navegacion          │
  └──────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: Navegacion con NavigationPath (Basico)

**Objetivo**: Implementar navegacion programatica con NavigationPath.

**Requisitos**:
1. Crear una app con 3 pantallas: Inicio, Lista de Categorias, Detalle de Categoria
2. Usar `NavigationPath` para la pila de navegacion
3. Boton "Volver al Inicio" en la pantalla de detalle que haga `popToRoot`
4. Usar `navigationDestination(for:)` con un enum `Hashable`

---

## Ejercicio 2: NavigationSplitView con Datos (Intermedio)

**Objetivo**: Crear una interfaz sidebar/detail adaptativa.

**Requisitos**:
1. `NavigationSplitView` con 3 columnas: Sidebar, Content, Detail
2. Sidebar con categorias (Favoritos, Recientes, Archivados)
3. Content con lista filtrada por categoria seleccionada
4. Detail con informacion completa del item seleccionado
5. Manejar estado vacio con `ContentUnavailableView`
6. Probar comportamiento en iPhone (colapsa) vs iPad (sidebar visible)

---

## Ejercicio 3: Deep Linking con Coordinator (Avanzado)

**Objetivo**: Implementar deep linking completo con Coordinator pattern.

**Requisitos**:
1. `AppCoordinator` con `@Observable` que maneje toda la navegacion
2. Enum `AppRoute` con al menos 5 rutas diferentes
3. Deep link handler que parsee URLs: `miapp://seccion/id?param=valor`
4. Soporte para `.sheet` y `.fullScreenCover` desde el coordinator
5. Metodo `resolver(ruta:)` con `@ViewBuilder` para cada ruta
6. State restoration: guardar y restaurar el path en `@AppStorage`

---

## 5 Errores Comunes

### 1. Poner navigationDestination dentro de NavigationLink
```swift
// MAL — el destination se registra cada vez que aparece el link
NavigationLink(value: item) {
    Text(item.nombre)
}
.navigationDestination(for: Item.self) { item in
    DetalleView(item: item)
}

// BIEN — registrar en la List o en el contenedor padre
List(items) { item in
    NavigationLink(value: item) {
        Text(item.nombre)
    }
}
.navigationDestination(for: Item.self) { item in
    DetalleView(item: item)
}
```

### 2. Olvidar Hashable en los tipos de navegacion
```swift
// MAL — no compila sin Hashable
struct Producto {
    let id: UUID
    let nombre: String
}

// BIEN — Hashable es obligatorio para NavigationLink(value:)
struct Producto: Hashable {
    let id: UUID
    let nombre: String
}
```

### 3. Modificar NavigationPath fuera del hilo principal
```swift
// MAL — puede causar crashes
Task {
    let datos = await fetchDatos()
    navegacion.path.append(datos) // posible crash
}

// BIEN — asegurar MainActor
Task { @MainActor in
    let datos = await fetchDatos()
    navegacion.path.append(datos)
}
```

### 4. Usar NavigationView en lugar de NavigationStack
```swift
// MAL — NavigationView esta deprecado desde iOS 16
NavigationView {
    List { ... }
}

// BIEN — usar NavigationStack o NavigationSplitView
NavigationStack {
    List { ... }
}
```

### 5. No manejar el estado vacio en NavigationSplitView
```swift
// MAL — pantalla en blanco cuando no hay seleccion
NavigationSplitView {
    List(items, selection: $seleccion) { ... }
} detail: {
    DetalleView(item: seleccion!) // crash si nil
}

// BIEN — manejar estado vacio
NavigationSplitView {
    List(items, selection: $seleccion) { ... }
} detail: {
    if let seleccion {
        DetalleView(item: seleccion)
    } else {
        ContentUnavailableView("Selecciona un item",
            systemImage: "list.bullet")
    }
}
```

---

## Checklist

- [ ] Entender NavigationStack y navigationDestination(for:)
- [ ] Implementar NavigationPath para navegacion programatica
- [ ] Usar NavigationSplitView para interfaces adaptativas
- [ ] Crear un enum de rutas tipadas (Hashable)
- [ ] Implementar deep linking con onOpenURL
- [ ] Aplicar Coordinator pattern para centralizar navegacion
- [ ] Manejar popToRoot, pop y push programaticamente
- [ ] Usar ContentUnavailableView para estados vacios
- [ ] Probar navegacion en iPhone, iPad y Mac
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

La navegacion avanzada es el esqueleto del Proyecto Integrador:
- **NavigationStack + NavigationPath** como sistema central de navegacion
- **Coordinator pattern** para separar logica de navegacion de las vistas
- **Deep linking** para abrir la app desde notificaciones push o widgets
- **NavigationSplitView** para la version iPad/Mac de la app
- **State restoration** para que el usuario vuelva donde estaba

---

*Leccion 15 | Navegacion Avanzada | Semanas 17-18 | Modulo 03: SwiftUI Avanzado*
*Siguiente: Leccion 16 — Composicion de Vistas*
