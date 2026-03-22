# Leccion 17: Listas y Colecciones

**Modulo 03: SwiftUI Avanzado** | Semana 20

---

## TL;DR — Resumen en 2 minutos

- **List** es el componente principal para datos tabulares — soporta secciones, swipe actions, seleccion y edicion
- **LazyVStack/LazyHStack** cargan vistas bajo demanda dentro de ScrollView — mejor rendimiento para listas grandes
- **LazyVGrid/LazyHGrid** crean grids adaptativos con columnas flexibles, fijas o adaptativas
- **.searchable** anade barra de busqueda nativa con sugerencias y tokens
- **Paginacion** con `.onAppear` del ultimo item para cargar mas datos de forma incremental

> Herramienta: **Instruments** (Time Profiler) para verificar rendimiento de listas con 10K+ items

---

## Cupertino MCP

```bash
cupertino search "List SwiftUI"
cupertino search "LazyVStack"
cupertino search "LazyVGrid"
cupertino search "ForEach Identifiable"
cupertino search "searchable modifier"
cupertino search --source apple-docs "Section SwiftUI"
cupertino search --source apple-docs "swipe actions"
cupertino search --source samples "List"
cupertino search --source updates "List iOS 26"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [Get started with Dynamic Type](https://developer.apple.com/videos/play/wwdc2024/10074/) | Listas accesibles |
| WWDC23 | [Beyond scroll views](https://developer.apple.com/videos/play/wwdc2023/10159/) | **Esencial** — ScrollView avanzado |
| WWDC22 | [SwiftUI on iPad: Organize your interface](https://developer.apple.com/videos/play/wwdc2022/10058/) | Listas en iPad |
| WWDC25 | What's New in SwiftUI | Novedades listas iOS 26 |
| EN | [Kavsoft — Custom Lists](https://www.youtube.com/@Kavsoft) | Listas con disenos custom |
| EN | [Sean Allen — Pagination](https://www.youtube.com/@saborostudio) | Paginacion en SwiftUI |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Listas Eficientes?

Una app tipica muestra listas en el 70% de sus pantallas. La diferencia entre una lista que carga 50 items y una que carga 50,000 no deberia ser perceptible para el usuario. SwiftUI ofrece dos estrategias:

1. **List**: componente completo con estilos nativos, swipe actions, seleccion — carga lazy por defecto
2. **LazyVStack en ScrollView**: control total del layout, sin estilos predefinidos — lazy tambien

La regla es simple: usa `List` cuando quieras apariencia nativa, `LazyVStack` cuando necesites control total.

### List — El Componente Completo

```swift
import SwiftUI

struct Contacto: Identifiable {
    let id = UUID()
    var nombre: String
    var email: String
    var telefono: String
    var esFavorito: Bool
    var grupo: String
}

struct ContactosView: View {
    @State private var contactos = Contacto.ejemplos()
    @State private var seleccion: Set<Contacto.ID> = []
    @State private var modoEdicion: EditMode = .inactive

    var contactosAgrupados: [String: [Contacto]] {
        Dictionary(grouping: contactos, by: \.grupo)
    }

    var body: some View {
        NavigationStack {
            List(selection: $seleccion) {
                ForEach(contactosAgrupados.keys.sorted(), id: \.self) { grupo in
                    Section(grupo) {
                        ForEach(contactosAgrupados[grupo] ?? []) { contacto in
                            ContactoRow(contacto: contacto)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        eliminar(contacto)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }

                                    Button {
                                        toggleFavorito(contacto)
                                    } label: {
                                        Label(
                                            contacto.esFavorito ? "Quitar" : "Favorito",
                                            systemImage: contacto.esFavorito ? "star.slash" : "star"
                                        )
                                    }
                                    .tint(.yellow)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        // Archivar
                                    } label: {
                                        Label("Archivar", systemImage: "archivebox")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Contactos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarLeading) {
                    if !seleccion.isEmpty {
                        Button("Eliminar (\(seleccion.count))") {
                            contactos.removeAll { seleccion.contains($0.id) }
                            seleccion.removeAll()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .environment(\.editMode, $modoEdicion)
        }
    }

    private func eliminar(_ contacto: Contacto) {
        contactos.removeAll { $0.id == contacto.id }
    }

    private func toggleFavorito(_ contacto: Contacto) {
        if let indice = contactos.firstIndex(where: { $0.id == contacto.id }) {
            contactos[indice].esFavorito.toggle()
        }
    }
}

struct ContactoRow: View {
    let contacto: Contacto

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading) {
                Text(contacto.nombre)
                    .font(.headline)
                Text(contacto.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if contacto.esFavorito {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }
}

extension Contacto {
    static func ejemplos() -> [Contacto] {
        [
            Contacto(nombre: "Ana Garcia", email: "ana@mail.com", telefono: "+34 611", esFavorito: true, grupo: "Trabajo"),
            Contacto(nombre: "Carlos Lopez", email: "carlos@mail.com", telefono: "+34 622", esFavorito: false, grupo: "Trabajo"),
            Contacto(nombre: "Maria Torres", email: "maria@mail.com", telefono: "+34 633", esFavorito: true, grupo: "Familia"),
            Contacto(nombre: "Pedro Ruiz", email: "pedro@mail.com", telefono: "+34 644", esFavorito: false, grupo: "Amigos"),
        ]
    }
}
```

### LazyVStack y LazyHStack — Carga Bajo Demanda

```swift
import SwiftUI

struct FeedView: View {
    @State private var posts: [Post] = Post.ejemplos(cantidad: 100)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                    Section {
                        ForEach(posts) { post in
                            PostCardView(post: post)
                                .padding(.horizontal)
                        }
                    } header: {
                        Text("Feed Principal")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.ultraThinMaterial)
                    }
                }
            }
            .navigationTitle("Feed")
        }
    }
}

struct Post: Identifiable {
    let id = UUID()
    let autor: String
    let contenido: String
    let likes: Int
    let fecha: Date

    static func ejemplos(cantidad: Int) -> [Post] {
        (0..<cantidad).map { i in
            Post(
                autor: "Usuario \(i)",
                contenido: "Este es el contenido del post numero \(i). Aqui va texto interesante.",
                likes: Int.random(in: 0...500),
                fecha: Date().addingTimeInterval(TimeInterval(-i * 3600))
            )
        }
    }
}

struct PostCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                Text(post.autor)
                    .font(.headline)
                Spacer()
                Text(post.fecha, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(post.contenido)
                .font(.body)

            HStack {
                Label("\(post.likes)", systemImage: "heart")
                Spacer()
                Button("Compartir") {}
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

### LazyVGrid — Grids Adaptativos

```swift
import SwiftUI

struct GaleriaView: View {
    @State private var columnas = 3
    @State private var fotos = Foto.ejemplos(cantidad: 50)

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columnas)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 2) {
                    ForEach(fotos) { foto in
                        FotoThumbnail(foto: foto)
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
            .navigationTitle("Galeria")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("2 Columnas") { withAnimation { columnas = 2 } }
                        Button("3 Columnas") { withAnimation { columnas = 3 } }
                        Button("4 Columnas") { withAnimation { columnas = 4 } }
                    } label: {
                        Image(systemName: "square.grid.3x3")
                    }
                }
            }
        }
    }
}

// Grid con columnas adaptativas — se ajusta automaticamente
struct GridAdaptativoView: View {
    let items = (1...30).map { "Item \($0)" }

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150, maximum: 200))],
                spacing: 16
            ) {
                ForEach(items, id: \.self) { item in
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.gradient)
                            .frame(height: 120)
                        Text(item)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
    }
}

struct Foto: Identifiable {
    let id = UUID()
    let color: Color

    static func ejemplos(cantidad: Int) -> [Foto] {
        (0..<cantidad).map { _ in
            Foto(color: Color(
                hue: Double.random(in: 0...1),
                saturation: 0.7,
                brightness: 0.8
            ))
        }
    }
}

struct FotoThumbnail: View {
    let foto: Foto

    var body: some View {
        Rectangle()
            .fill(foto.color)
    }
}
```

### .searchable — Busqueda Nativa

```swift
import SwiftUI

@Observable
class BusquedaViewModel {
    var items: [Producto] = Producto.catalogo()
    var textoBusqueda = ""
    var tokenSeleccionados: [TokenBusqueda] = []
    var alcance: AlcanceBusqueda = .todos

    enum AlcanceBusqueda: String, CaseIterable {
        case todos = "Todos"
        case nombre = "Nombre"
        case categoria = "Categoria"
    }

    var itemsFiltrados: [Producto] {
        var resultado = items

        // Filtrar por tokens
        for token in tokenSeleccionados {
            resultado = resultado.filter { $0.categoria == token.categoria }
        }

        // Filtrar por texto
        guard !textoBusqueda.isEmpty else { return resultado }

        switch alcance {
        case .todos:
            return resultado.filter {
                $0.nombre.localizedCaseInsensitiveContains(textoBusqueda) ||
                $0.categoria.localizedCaseInsensitiveContains(textoBusqueda)
            }
        case .nombre:
            return resultado.filter {
                $0.nombre.localizedCaseInsensitiveContains(textoBusqueda)
            }
        case .categoria:
            return resultado.filter {
                $0.categoria.localizedCaseInsensitiveContains(textoBusqueda)
            }
        }
    }

    var sugerencias: [String] {
        guard !textoBusqueda.isEmpty else { return [] }
        let categorias = Set(items.map(\.categoria))
        return categorias.filter {
            $0.localizedCaseInsensitiveContains(textoBusqueda)
        }.sorted()
    }
}

struct TokenBusqueda: Identifiable, Hashable {
    let id = UUID()
    let categoria: String
}

struct BusquedaView: View {
    @State private var viewModel = BusquedaViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.itemsFiltrados) { producto in
                HStack {
                    VStack(alignment: .leading) {
                        Text(producto.nombre)
                            .font(.headline)
                        Text(producto.categoria)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("$\(producto.precio, specifier: "%.0f")")
                }
            }
            .navigationTitle("Productos")
            .searchable(
                text: $viewModel.textoBusqueda,
                tokens: $viewModel.tokenSeleccionados,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar productos..."
            ) { token in
                Text(token.categoria)
            }
            .searchScopes($viewModel.alcance) {
                ForEach(BusquedaViewModel.AlcanceBusqueda.allCases, id: \.self) { alcance in
                    Text(alcance.rawValue)
                }
            }
            .searchSuggestions {
                ForEach(viewModel.sugerencias, id: \.self) { sugerencia in
                    Button {
                        viewModel.tokenSeleccionados.append(
                            TokenBusqueda(categoria: sugerencia)
                        )
                        viewModel.textoBusqueda = ""
                    } label: {
                        Label(sugerencia, systemImage: "tag")
                    }
                }
            }
        }
    }
}

struct Producto: Identifiable, Hashable {
    let id = UUID()
    let nombre: String
    let precio: Double
    let categoria: String

    static func catalogo() -> [Producto] {
        [
            Producto(nombre: "iPhone 17", precio: 999, categoria: "Telefonos"),
            Producto(nombre: "iPhone 17 Pro", precio: 1199, categoria: "Telefonos"),
            Producto(nombre: "MacBook Air M5", precio: 1299, categoria: "Laptops"),
            Producto(nombre: "MacBook Pro M5", precio: 1999, categoria: "Laptops"),
            Producto(nombre: "AirPods Pro 3", precio: 249, categoria: "Audio"),
            Producto(nombre: "AirPods Max 2", precio: 549, categoria: "Audio"),
            Producto(nombre: "iPad Air M4", precio: 799, categoria: "Tablets"),
            Producto(nombre: "iPad Pro M5", precio: 1099, categoria: "Tablets"),
            Producto(nombre: "Apple Watch Ultra 3", precio: 799, categoria: "Wearables"),
            Producto(nombre: "Apple Watch Series 11", precio: 399, categoria: "Wearables"),
        ]
    }
}
```

### Paginacion — Carga Incremental

```swift
import SwiftUI

@Observable
class PaginacionViewModel {
    var items: [ItemPaginado] = []
    var estaCargando = false
    var paginaActual = 0
    var hayMasPaginas = true
    private let itemsPorPagina = 20

    func cargarPaginaInicial() async {
        items = []
        paginaActual = 0
        hayMasPaginas = true
        await cargarSiguientePagina()
    }

    func cargarSiguientePagina() async {
        guard !estaCargando, hayMasPaginas else { return }

        estaCargando = true
        defer { estaCargando = false }

        // Simular llamada a API
        try? await Task.sleep(for: .seconds(1))

        let nuevosItems = (0..<itemsPorPagina).map { i in
            let indice = paginaActual * itemsPorPagina + i
            return ItemPaginado(titulo: "Item \(indice)", detalle: "Pagina \(paginaActual)")
        }

        items.append(contentsOf: nuevosItems)
        paginaActual += 1

        // Simular fin de datos en pagina 5
        if paginaActual >= 5 {
            hayMasPaginas = false
        }
    }

    func cargarMasSiNecesario(itemActual: ItemPaginado) async {
        // Cargar mas cuando faltan 5 items para el final
        let umbral = items.index(items.endIndex, offsetBy: -5)
        if let indice = items.firstIndex(where: { $0.id == itemActual.id }),
           indice >= umbral {
            await cargarSiguientePagina()
        }
    }
}

struct ItemPaginado: Identifiable {
    let id = UUID()
    let titulo: String
    let detalle: String
}

struct ListaPaginadaView: View {
    @State private var viewModel = PaginacionViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items) { item in
                    VStack(alignment: .leading) {
                        Text(item.titulo)
                            .font(.headline)
                        Text(item.detalle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .task {
                        await viewModel.cargarMasSiNecesario(itemActual: item)
                    }
                }

                if viewModel.estaCargando {
                    HStack {
                        Spacer()
                        ProgressView("Cargando...")
                        Spacer()
                    }
                }

                if !viewModel.hayMasPaginas {
                    HStack {
                        Spacer()
                        Text("No hay mas items")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Items (\(viewModel.items.count))")
            .refreshable {
                await viewModel.cargarPaginaInicial()
            }
            .task {
                if viewModel.items.isEmpty {
                    await viewModel.cargarPaginaInicial()
                }
            }
        }
    }
}
```

#### Diagrama de Rendimiento

```
  ┌──────────────────────────────────────────────────────┐
  │           LISTAS Y RENDIMIENTO                        │
  │                                                       │
  │  List               LazyVStack          LazyVGrid     │
  │  (nativo)           (custom)            (grid)        │
  │                                                       │
  │  ┌─Pantalla─────────────────┐                        │
  │  │  ╔══════════════════╗    │  Items visibles:        │
  │  │  ║  Item 5  ★       ║    │  Solo estos se          │
  │  │  ║  Item 6          ║    │  renderizan en          │
  │  │  ║  Item 7  ★       ║    │  memoria (Lazy)         │
  │  │  ║  Item 8          ║    │                          │
  │  │  ║  Item 9          ║    │  Items fuera:            │
  │  │  ╚══════════════════╝    │  No existen hasta        │
  │  │    Item 10               │  que el usuario           │
  │  │    Item 11               │  hace scroll              │
  │  │    ...                   │                          │
  │  │    Item 10000            │                          │
  │  └─────────────────────────┘                          │
  │                                                       │
  │  Paginacion:                                          │
  │  [P1: 20 items][P2: 20 items][P3: cargando...]       │
  │       ▲                          ▲                    │
  │       │                          │                    │
  │   Ya cargado              .task { cargarMas() }       │
  └──────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: Lista de Tareas con Secciones (Basico)

**Objetivo**: Crear una lista agrupada con funcionalidad completa.

**Requisitos**:
1. Lista de tareas agrupadas por prioridad: Alta, Media, Baja
2. Swipe actions: eliminar (derecha) y completar (izquierda)
3. Seleccion multiple con `EditButton`
4. Icono de estado: pendiente, completada, vencida

---

## Ejercicio 2: Galeria con Grid Adaptativo (Intermedio)

**Objetivo**: Implementar un grid con columnas configurables y busqueda.

**Requisitos**:
1. `LazyVGrid` con columnas adaptativas (minimo 100, maximo 200)
2. Toolbar con opciones: 2, 3 o 4 columnas fijas
3. `.searchable` con filtro por nombre
4. Pull-to-refresh con `.refreshable`
5. Animacion al cambiar numero de columnas
6. Header con pinnedViews que muestre el conteo de items

---

## Ejercicio 3: Feed con Paginacion Infinita (Avanzado)

**Objetivo**: Implementar paginacion con busqueda y pull-to-refresh.

**Requisitos**:
1. ViewModel con `@Observable` que maneje paginacion
2. Cargar 20 items por pagina automaticamente al acercarse al final
3. Indicador de carga al final de la lista
4. Pull-to-refresh que reinicie la paginacion
5. `.searchable` que filtre los items ya cargados
6. Estado vacio cuando no hay resultados de busqueda con `ContentUnavailableView`

---

## 5 Errores Comunes

### 1. Usar VStack en lugar de LazyVStack para listas grandes
```swift
// MAL — crea TODAS las vistas al inicio (lento con 10K+ items)
ScrollView {
    VStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}

// BIEN — solo crea las vistas visibles
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}
```

### 2. ForEach sin Identifiable o con id inestable
```swift
// MAL — usar indice como id causa bugs de rendimiento y estado
ForEach(Array(items.enumerated()), id: \.offset) { index, item in
    Text(item.nombre) // id cambia al reordenar → crashes
}

// BIEN — conformar a Identifiable con id estable
struct Item: Identifiable {
    let id = UUID()  // id unico y estable
    var nombre: String
}

ForEach(items) { item in
    Text(item.nombre)
}
```

### 3. Poner .searchable fuera de NavigationStack
```swift
// MAL — searchable necesita un NavigationStack padre
List(items) { item in
    Text(item.nombre)
}
.searchable(text: $busqueda) // no funciona

// BIEN — dentro de NavigationStack
NavigationStack {
    List(items) { item in
        Text(item.nombre)
    }
    .searchable(text: $busqueda)
}
```

### 4. No manejar lista vacia
```swift
// MAL — lista en blanco sin feedback
List(itemsFiltrados) { item in
    Text(item.nombre)
}

// BIEN — overlay para estado vacio
List(itemsFiltrados) { item in
    Text(item.nombre)
}
.overlay {
    if itemsFiltrados.isEmpty {
        ContentUnavailableView.search(text: busqueda)
    }
}
```

### 5. Paginacion sin control de concurrencia
```swift
// MAL — multiples llamadas simultaneas
func cargarMas() async {
    let datos = await fetchDatos(pagina: pagina) // puede llamarse 5 veces
    items.append(contentsOf: datos)
}

// BIEN — flag para evitar llamadas duplicadas
func cargarMas() async {
    guard !estaCargando else { return }
    estaCargando = true
    defer { estaCargando = false }

    let datos = await fetchDatos(pagina: pagina)
    items.append(contentsOf: datos)
    pagina += 1
}
```

---

## Checklist

- [ ] Usar List con Section, ForEach y estilos nativos
- [ ] Implementar swipe actions (leading y trailing)
- [ ] Usar seleccion multiple con EditButton
- [ ] Crear LazyVStack dentro de ScrollView para listas custom
- [ ] Implementar LazyVGrid con columnas flexibles y adaptativas
- [ ] Agregar .searchable con sugerencias y scopes
- [ ] Implementar paginacion con carga bajo demanda
- [ ] Usar .refreshable para pull-to-refresh
- [ ] Manejar estados vacios con ContentUnavailableView
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Las listas y colecciones son el corazon de la experiencia de usuario del Proyecto Integrador:
- **List con secciones** para pantallas de configuracion y datos agrupados
- **LazyVGrid** para galerias de fotos o colecciones de items
- **Paginacion** para feeds con datos del servidor
- **.searchable** para busqueda global en la app
- **Swipe actions** para acciones rapidas sobre items
- **Pull-to-refresh** para actualizar datos del backend

---

*Leccion 17 | Listas y Colecciones | Semana 20 | Modulo 03: SwiftUI Avanzado*
*Siguiente: Leccion 18 — Animaciones y Transiciones*
