# Leccion 11: MVVM en SwiftUI

**Modulo 01: Arquitectura** | Semana 13

---

## TL;DR — Resumen en 2 minutos

- **MVVM** separa la app en 3 capas: Model (datos), View (UI), ViewModel (logica)
- **@Observable** reemplaza ObservableObject — mas simple, mas eficiente
- La **View** solo describe UI, nunca tiene logica de negocio
- El **ViewModel** expone estado y acciones que la View consume
- **@State** para ViewModels locales, **@Environment** para compartidos

> Principio: si tu View tiene mas de 5 lineas de logica, necesitas un ViewModel.

---

## Cupertino MCP

```bash
cupertino search "Observable macro"
cupertino search "SwiftUI state management"
cupertino search "SwiftUI Environment"
cupertino search "SwiftUI data flow"
cupertino search --source apple-docs "Observation framework"
cupertino search --source samples "MVVM SwiftUI"
cupertino search_property_wrappers "State"
cupertino search_property_wrappers "Environment"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC23 | [Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/) | **Esencial** — @Observable reemplaza Combine |
| WWDC24 | [SwiftUI Essentials](https://developer.apple.com/videos/play/wwdc2024/10150/) | Patrones de datos modernos |
| WWDC25 | What's New in SwiftUI | Novedades iOS 26 |
| EN | [Azamsharp — MVVM in SwiftUI](https://www.youtube.com/@azamsharp) | Debate sobre cuando usar MVVM |
| EN | [Stewart Lynch — @Observable](https://www.youtube.com/@StewartLynch) | Migracion de ObservableObject a @Observable |
| EN | [Vincent Pradeilles — Architecture](https://www.youtube.com/@v_pradeilles) | Patrones arquitectonicos en Swift |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que importa la arquitectura?

Imagina una app con 50 pantallas. Sin arquitectura clara, terminas con lo que llamamos **spaghetti code**: vistas que hacen llamadas de red, manipulan datos, validan formularios y manejan navegacion — todo en el mismo archivo.

Los problemas del spaghetti code son concretos:

- **Bugs invisibles**: un cambio en una pantalla rompe otra sin relacion aparente
- **Imposible de testear**: no puedes probar la logica sin levantar toda la UI
- **Imposible de escalar**: cada nueva feature tarda mas porque hay que entender todo el acoplamiento
- **Onboarding lento**: un nuevo desarrollador necesita semanas para entender el codigo

La arquitectura resuelve estos problemas separando **responsabilidades**. MVVM es el patron mas natural para SwiftUI.

### MVVM: Las 3 capas

```
┌─────────────────────────────────────────────────────┐
│                      VIEW                           │
│   Describe la UI. Solo lee estado y envia acciones. │
│   No contiene logica de negocio.                    │
└───────────────────────┬─────────────────────────────┘
                        │ observa / llama acciones
┌───────────────────────▼─────────────────────────────┐
│                   VIEWMODEL                         │
│   Contiene la logica de presentacion.               │
│   Transforma datos del Model para la View.          │
│   Expone estado (@Observable) y metodos.            │
└───────────────────────┬─────────────────────────────┘
                        │ lee / escribe
┌───────────────────────▼─────────────────────────────┐
│                     MODEL                           │
│   Structs puros con datos.                          │
│   Sin dependencias de UI ni frameworks.             │
└─────────────────────────────────────────────────────┘
```

**Model**: structs puros que representan datos. Sin logica de UI, sin dependencias de frameworks.

```swift
struct Contacto: Identifiable {
    let id = UUID()
    var nombre: String
    var email: String
    var esFavorito: Bool
}
```

**ViewModel**: clase marcada con `@Observable` que contiene la logica. Transforma datos del Model en estado que la View puede consumir.

```swift
import Observation

@Observable
class ContactosViewModel {
    var contactos: [Contacto] = []
    var textoBusqueda = ""

    var contactosFiltrados: [Contacto] {
        if textoBusqueda.isEmpty {
            return contactos
        }
        return contactos.filter { $0.nombre.localizedCaseInsensitiveContains(textoBusqueda) }
    }

    var totalFavoritos: Int {
        contactos.filter(\.esFavorito).count
    }

    func agregarContacto(nombre: String, email: String) {
        let nuevo = Contacto(nombre: nombre, email: email, esFavorito: false)
        contactos.append(nuevo)
    }

    func toggleFavorito(_ contacto: Contacto) {
        guard let index = contactos.firstIndex(where: { $0.id == contacto.id }) else { return }
        contactos[index].esFavorito.toggle()
    }

    func eliminar(at offsets: IndexSet) {
        contactos.remove(atOffsets: offsets)
    }
}
```

**View**: solo describe UI. Lee estado del ViewModel y llama sus metodos.

```swift
import SwiftUI

struct ContactosView: View {
    @State private var viewModel = ContactosViewModel()
    @State private var mostrarFormulario = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.contactosFiltrados) { contacto in
                    ContactoRow(contacto: contacto) {
                        viewModel.toggleFavorito(contacto)
                    }
                }
                .onDelete(perform: viewModel.eliminar)
            }
            .searchable(text: $viewModel.textoBusqueda)
            .navigationTitle("Contactos (\(viewModel.totalFavoritos) ⭐)")
            .toolbar {
                Button("Agregar") { mostrarFormulario = true }
            }
        }
    }
}
```

### @Observable: el motor de MVVM moderno

Antes de Swift 5.9, MVVM en SwiftUI requeria `ObservableObject` con `@Published`:

```swift
// ❌ ANTIGUO — No usar
class MiViewModel: ObservableObject {
    @Published var datos: [String] = []    // Requiere @Published en cada propiedad
    @Published var cargando = false         // Si olvidas @Published, no actualiza la UI
}

// En la View:
@StateObject private var vm = MiViewModel()    // @StateObject vs @ObservedObject era confuso
```

Con `@Observable` todo es mas simple y eficiente:

```swift
// ✅ MODERNO — Usar esto
@Observable
class MiViewModel {
    var datos: [String] = []     // Todas las propiedades son observadas automaticamente
    var cargando = false         // No necesitas @Published
}

// En la View:
@State private var vm = MiViewModel()    // Solo @State, sin confusion
```

**Ventajas de @Observable:**

1. **Tracking granular**: SwiftUI solo re-renderiza cuando cambian las propiedades que la View realmente usa
2. **Sin boilerplate**: no necesitas `@Published` en cada propiedad
3. **Un solo wrapper**: `@State` para todo, no mas `@StateObject` vs `@ObservedObject`
4. **Mejor performance**: el tracking a nivel de propiedad evita re-renders innecesarios

### Estado local vs compartido

**ViewModel local** — cuando solo una vista lo necesita:

```swift
struct PerfilView: View {
    @State private var viewModel = PerfilViewModel()

    var body: some View {
        // Solo esta vista usa el ViewModel
        Text(viewModel.nombreCompleto)
    }
}
```

**ViewModel compartido** — cuando multiples vistas necesitan el mismo estado:

```swift
// En el punto de entrada de la app o una vista padre:
@main
struct MiApp: App {
    @State private var carritoVM = CarritoViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(carritoVM)
        }
    }
}

// Cualquier vista descendiente puede acceder:
struct ProductoDetailView: View {
    @Environment(CarritoViewModel.self) private var carrito

    var body: some View {
        Button("Agregar al carrito") {
            carrito.agregar(producto)
        }
    }
}
```

### Computed properties: la clave de un buen ViewModel

Un error comun es tener propiedades que se calculan a partir de otras y guardarlas como estado separado. Esto causa bugs de sincronizacion.

```swift
@Observable
class PedidoViewModel {
    var items: [ItemPedido] = []
    var descuento: Double = 0.0

    // ✅ Computed — siempre consistente con los datos
    var subtotal: Double {
        items.reduce(0) { $0 + $1.precio * Double($1.cantidad) }
    }

    var totalConDescuento: Double {
        subtotal * (1 - descuento)
    }

    var resumen: String {
        "\(items.count) items — $\(String(format: "%.2f", totalConDescuento))"
    }

    // ❌ MAL — estado duplicado que puede desincronizarse
    // var subtotal: Double = 0.0  // Hay que actualizarlo manualmente cada vez
}
```

### Cuando MVVM es innecesario

No toda vista necesita un ViewModel. Para vistas simples y estaticas, MVVM agrega complejidad sin beneficio:

```swift
// ✅ Esto esta perfecto sin ViewModel
struct AvatarView: View {
    let nombre: String
    let imagen: String

    var body: some View {
        VStack {
            Image(imagen)
                .clipShape(Circle())
            Text(nombre)
                .font(.caption)
        }
    }
}

// ✅ Tambien esta bien — logica minima
struct ToggleRow: View {
    let titulo: String
    @Binding var activo: Bool

    var body: some View {
        Toggle(titulo, isOn: $activo)
    }
}
```

**Regla practica**: si la vista solo muestra datos que recibe por parametro o tiene un `@Binding` simple, no necesita ViewModel. Si tiene logica de negocio, validaciones, llamadas de red o estado complejo, necesita ViewModel.

### Binding con ViewModels

Cuando necesitas pasar un binding desde un ViewModel a una subvista, usa la sintaxis `@Bindable`:

```swift
struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            // @Bindable permite crear bindings desde @Observable
            @Bindable var vm = viewModel

            Toggle("Notificaciones", isOn: $vm.notificacionesActivas)
            Slider(value: $vm.volumen, in: 0...1)
            TextField("Nombre", text: $vm.nombreUsuario)
        }
    }
}

@Observable
class SettingsViewModel {
    var notificacionesActivas = true
    var volumen: Double = 0.5
    var nombreUsuario = ""

    func guardar() {
        // Persistir cambios...
    }
}
```

### Async en ViewModels

Los ViewModels frecuentemente necesitan operaciones asincronas. Usa `async/await` de forma natural:

```swift
@Observable
class ArticulosViewModel {
    var articulos: [Articulo] = []
    var cargando = false
    var mensajeError: String?

    func cargarArticulos() async {
        cargando = true
        mensajeError = nil

        do {
            articulos = try await ServicioArticulos.obtenerTodos()
        } catch {
            mensajeError = "No se pudieron cargar los articulos: \(error.localizedDescription)"
        }

        cargando = false
    }

    func eliminarArticulo(_ articulo: Articulo) async {
        do {
            try await ServicioArticulos.eliminar(articulo)
            articulos.removeAll { $0.id == articulo.id }
        } catch {
            mensajeError = "Error al eliminar: \(error.localizedDescription)"
        }
    }
}

struct ArticulosView: View {
    @State private var viewModel = ArticulosViewModel()

    var body: some View {
        List(viewModel.articulos) { articulo in
            Text(articulo.titulo)
        }
        .overlay {
            if viewModel.cargando {
                ProgressView()
            }
        }
        .task {
            await viewModel.cargarArticulos()
        }
    }
}
```

---

## Ejercicios

### Ejercicio 1 — Basico: De vista monolitica a MVVM

Tienes esta vista monolitica. Separa en Model, ViewModel y View:

```swift
// ❌ Vista monolitica — TODO esta mezclado
struct NotasView: View {
    @State private var notas: [String] = []
    @State private var textoNuevo = ""

    var notasOrdenadas: [String] {
        notas.sorted()
    }

    var totalCaracteres: Int {
        notas.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Nueva nota", text: $textoNuevo)
                    Button("Agregar") {
                        guard !textoNuevo.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        notas.append(textoNuevo)
                        textoNuevo = ""
                    }
                }
                .padding()

                List {
                    ForEach(notasOrdenadas, id: \.self) { nota in
                        Text(nota)
                    }
                    .onDelete { offsets in
                        let ordenadas = notasOrdenadas
                        for offset in offsets {
                            if let index = notas.firstIndex(of: ordenadas[offset]) {
                                notas.remove(at: index)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notas (\(totalCaracteres) chars)")
        }
    }
}
```

**Objetivo**: crear `Nota` (Model), `NotasViewModel` (ViewModel con @Observable), y `NotasView` (View limpia).

### Ejercicio 2 — Intermedio: App de tareas con CRUD completo

Construye una app de lista de tareas con MVVM completo:

**Model:**
```swift
struct Tarea: Identifiable {
    let id = UUID()
    var titulo: String
    var descripcion: String
    var completada: Bool
    var prioridad: Prioridad
    let fechaCreacion: Date

    enum Prioridad: String, CaseIterable {
        case baja, media, alta
    }
}
```

**Requisitos del ViewModel:**
- Agregar, editar, eliminar y toggle completada
- Filtrar por: todas, pendientes, completadas
- Ordenar por: fecha, prioridad, titulo
- Computed properties para estadisticas (total, pendientes, completadas, porcentaje)
- Busqueda por titulo

**Requisitos de la View:**
- Lista con swipe actions (completar, eliminar)
- Sheet para agregar/editar tareas
- Picker para filtro y ordenamiento
- Barra de progreso con porcentaje completado

### Ejercicio 3 — Avanzado: Multi-pantalla con ViewModel compartido

Crea una app de carrito de compras con 3 pantallas que comparten estado:

**Arquitectura:**
```
@main App
  └── .environment(carritoVM)
       ├── CatalogoView      → lista productos, boton agregar
       ├── CarritoView        → items en carrito, editar cantidades
       └── ResumenPedidoView  → total, descuentos, boton confirmar
```

**Requisitos:**
- `CarritoViewModel` compartido via `@Environment`
- `CatalogoViewModel` local para busqueda y filtros del catalogo
- Navegacion con `NavigationStack` y `TabView`
- Badge en tab del carrito mostrando cantidad de items
- Operaciones async: simular carga del catalogo y confirmacion de pedido
- Animaciones al agregar/eliminar del carrito

---

## Errores Comunes

### 1. Poner logica de negocio en la View

```swift
// ❌ MAL — la View calcula, valida y formatea
struct PedidoView: View {
    @State private var items: [Item] = []

    var body: some View {
        let subtotal = items.reduce(0) { $0 + $1.precio }
        let impuesto = subtotal * 0.16
        let total = subtotal + impuesto
        let descuento = items.count > 5 ? total * 0.1 : 0
        // ...mas logica en la vista
    }
}

// ✅ BIEN — la logica vive en el ViewModel
struct PedidoView: View {
    @State private var viewModel = PedidoViewModel()

    var body: some View {
        Text("Total: \(viewModel.totalFormateado)")
        // La View solo lee y muestra
    }
}
```

### 2. Usar ObservableObject en lugar de @Observable

```swift
// ❌ ANTIGUO — no usar en proyectos nuevos (Swift 6+)
class MiVM: ObservableObject {
    @Published var nombre = ""
}
// Requiere @StateObject o @ObservedObject en la View

// ✅ MODERNO — usar @Observable
@Observable
class MiVM {
    var nombre = ""
}
// Solo necesitas @State en la View
```

### 3. ViewModel masivo (God ViewModel)

```swift
// ❌ MAL — un ViewModel que hace TODO
@Observable
class AppViewModel {
    var usuarios: [Usuario] = []
    var productos: [Producto] = []
    var pedidos: [Pedido] = []
    var configuracion: Config = .default
    func cargarUsuarios() async { }
    func buscarProductos() { }
    func crearPedido() async { }
    func actualizarConfig() { }
    // ...200 lineas mas
}

// ✅ BIEN — un ViewModel por pantalla/feature
@Observable class UsuariosViewModel { /* solo usuarios */ }
@Observable class CatalogoViewModel { /* solo productos */ }
@Observable class PedidoViewModel { /* solo pedidos */ }
```

### 4. No aprovechar computed properties

```swift
// ❌ MAL — estado duplicado que puede desincronizarse
@Observable
class VM {
    var items: [Item] = []
    var totalItems: Int = 0  // Se actualiza manualmente

    func agregar(_ item: Item) {
        items.append(item)
        totalItems = items.count  // Si olvidas esta linea, bug silencioso
    }
}

// ✅ BIEN — computed property, siempre correcta
@Observable
class VM {
    var items: [Item] = []
    var totalItems: Int { items.count }  // Imposible que este desincronizado
}
```

### 5. Mutar el Model directamente desde la View

```swift
// ❌ MAL — la View modifica datos directamente
struct ItemView: View {
    @State private var viewModel = ItemViewModel()

    var body: some View {
        Button("Completar") {
            viewModel.item.completada = true  // Bypass del ViewModel
            viewModel.item.fechaCompletado = Date()
        }
    }
}

// ✅ BIEN — la View llama una accion del ViewModel
struct ItemView: View {
    @State private var viewModel = ItemViewModel()

    var body: some View {
        Button("Completar") {
            viewModel.completarItem()  // El ViewModel encapsula la logica
        }
    }
}
```

---

## Checklist de objetivos

- [ ] Entiendo por que la arquitectura previene spaghetti code
- [ ] Puedo explicar las 3 capas de MVVM y la responsabilidad de cada una
- [ ] Se usar @Observable para crear ViewModels modernos
- [ ] Distingo cuando usar @State (local) vs @Environment (compartido) para ViewModels
- [ ] Puedo crear bindings desde @Observable con @Bindable
- [ ] Se cuando MVVM es innecesario (vistas simples)
- [ ] Uso computed properties en lugar de estado duplicado
- [ ] Mis Views no contienen logica de negocio
- [ ] Puedo manejar operaciones async en ViewModels con async/await
- [ ] Complete los 3 ejercicios progresivos

---

## Notas Personales

> Espacio para anotar dudas, descubrimientos o reflexiones durante la leccion.
>
> ---
>
>
>

---

## Conexion con Proyecto Integrador

MVVM es la **columna vertebral** del Proyecto Integrador. Cada pantalla de la app seguira este patron:

- **Models**: entidades como `Usuario`, `Producto`, `Pedido` — structs puros en la capa de datos
- **ViewModels**: un ViewModel por pantalla principal, compartidos via `@Environment` cuando sea necesario
- **Views**: pantallas declarativas que solo leen estado y disparan acciones

En la **Leccion 12** veremos como MVVM se integra dentro de Clean Architecture, anadiendo capas de Repository y Domain que haran el Proyecto Integrador mas robusto y testeable.

> **Accion**: identifica las 3-5 pantallas principales de tu app y define que ViewModel necesitara cada una.

---

*Leccion 11 (L11) | MVVM en SwiftUI | Semana 13 | Modulo 01*