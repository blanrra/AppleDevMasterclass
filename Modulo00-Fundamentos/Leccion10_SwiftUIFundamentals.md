# Leccion 06: SwiftUI Fundamentos

**Modulo 00: Fundamentos** | Semanas 11-12

---

## TL;DR — Resumen en 2 minutos

- **SwiftUI = UI como funcion del estado**: cuando el estado cambia, la UI se actualiza sola — no mas bugs de sincronizacion
- **@State**: estado local de una vista — SwiftUI lo gestiona y re-renderiza cuando cambia
- **@Binding**: una vista hija puede leer y modificar el estado de su padre con `$variable`
- **@Observable**: la forma moderna de crear ViewModels — reemplaza a ObservableObject/Combine
- **Stacks + Modifiers**: VStack/HStack/ZStack para layout, `.font()/.padding()/.background()` para estilo

> Herramienta: **Xcode 26** con SwiftUI Previews para ver cambios en tiempo real

---

## Cupertino MCP

```bash
cupertino search "SwiftUI fundamentals"
cupertino search "SwiftUI View"
cupertino search "State SwiftUI"
cupertino search "Binding SwiftUI"
cupertino search "Observable macro"
cupertino search "SwiftUI modifiers"
cupertino search --source samples "SwiftUI"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [SwiftUI Essentials](https://developer.apple.com/videos/play/wwdc2024/10150/) | **Esencial** — Vision general |
| WWDC23 | [Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/) | **Esencial** — @Observable |
| WWDC25 | What's New in SwiftUI | Novedades iOS 26 |
| EN | [Kavsoft — SwiftUI Basics](https://www.youtube.com/@Kavsoft) | UI paso a paso |
| EN | [Paul Hudson — 100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui) | Fundamentos practicos |
| EN | [Karin Prater — State Management](https://www.youtube.com/@swiftyplace) | @State, @Binding |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que SwiftUI?

UIKit sirvio a Apple durante 15 anos, pero tenia un problema fundamental: **el estado y la UI vivian separados**. Mantenerlos sincronizados era responsabilidad del desarrollador, lo que causaba bugs de UI constantemente.

SwiftUI invierte el modelo: **la UI es una funcion del estado**. Cuando el estado cambia, SwiftUI recalcula automaticamente que partes de la UI necesitan actualizarse. Esto elimina una categoria entera de bugs.

### View Protocol

Todo en SwiftUI es un View. Una View es un struct que describe como deberia verse la UI.

```swift
struct MiVista: View {
    var body: some View {
        Text("Hola, SwiftUI!")
            .font(.title)
            .foregroundStyle(.blue)
    }
}
```

**Importante**: `body` no se llama una sola vez. SwiftUI lo llama cada vez que el estado cambia. Por eso `body` debe ser puro — sin side effects.

### @State

`@State` es para estado local que pertenece a una vista.

```swift
struct ContadorView: View {
    @State private var contador = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Contador: \(contador)")
                .font(.largeTitle)

            HStack {
                Button("Decrementar") { contador -= 1 }
                Button("Incrementar") { contador += 1 }
            }
        }
        .padding()
    }
}
```

### @Binding

`@Binding` permite que una vista hija lea y modifique el estado de su padre.

```swift
struct ToggleRow: View {
    let titulo: String
    @Binding var estaActivo: Bool

    var body: some View {
        Toggle(titulo, isOn: $estaActivo)
    }
}

struct ConfiguracionView: View {
    @State private var notificaciones = true
    @State private var modoOscuro = false

    var body: some View {
        Form {
            ToggleRow(titulo: "Notificaciones", estaActivo: $notificaciones)
            ToggleRow(titulo: "Modo Oscuro", estaActivo: $modoOscuro)
        }
    }
}
```

### @Observable (Swift 5.9+)

`@Observable` reemplaza a ObservableObject/Combine. Es la forma moderna de crear modelos observables.

```swift
@Observable
class PerfilViewModel {
    var nombre = ""
    var email = ""
    var estaEditando = false

    var esValido: Bool {
        !nombre.isEmpty && email.contains("@")
    }

    func guardar() async {
        // Guardar en backend
        estaEditando = false
    }
}

struct PerfilView: View {
    @State private var viewModel = PerfilViewModel()

    var body: some View {
        Form {
            TextField("Nombre", text: $viewModel.nombre)
            TextField("Email", text: $viewModel.email)

            Button("Guardar") {
                Task { await viewModel.guardar() }
            }
            .disabled(!viewModel.esValido)
        }
    }
}
```

#### Flujo de Datos en SwiftUI

```
  ┌─────────────────────────────────────────────────────────┐
  │                    FLUJO DE DATOS                        │
  │                                                          │
  │  @State         @Binding        @Observable              │
  │  (local)        (referencia)    (modelo compartido)      │
  │                                                          │
  │  ┌─PadreView──────────────────────────────┐             │
  │  │                                         │             │
  │  │  @State var texto = ""                  │             │
  │  │       │                                 │             │
  │  │       │ $texto (Binding)                │             │
  │  │       ▼                                 │             │
  │  │  ┌─HijaView────────────────┐           │             │
  │  │  │ @Binding var texto      │           │             │
  │  │  │      │                  │           │             │
  │  │  │      ▼                  │           │             │
  │  │  │ TextField(text: $texto) │           │             │
  │  │  │      │                  │           │             │
  │  │  │      │ usuario escribe  │           │             │
  │  │  │      ▼                  │           │             │
  │  │  │ Binding actualiza State │           │             │
  │  │  └─────────────────────────┘           │             │
  │  │       │                                 │             │
  │  │       ▼                                 │             │
  │  │  SwiftUI re-renderiza ambas vistas     │             │
  │  └─────────────────────────────────────────┘             │
  │                                                          │
  │  @Observable ViewModel                                   │
  │  ┌──────────────────────┐    ┌────────────────┐         │
  │  │ @Observable          │    │  View           │         │
  │  │ class VM {           │◀──▶│  @State var vm  │         │
  │  │   var nombre = ""    │    │  = VM()         │         │
  │  │   var items = []     │    │                 │         │
  │  │ }                    │    │  vm.nombre      │         │
  │  └──────────────────────┘    └────────────────┘         │
  │  Cambio en VM → SwiftUI detecta → re-render automatico  │
  └─────────────────────────────────────────────────────────┘
```

### Layout: Stacks

```swift
struct LayoutDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Horizontal
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("Carlos Lopez")
                        .font(.headline)
                    Text("iOS Developer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            // Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(1...9, id: \.self) { num in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.opacity(0.2))
                        .frame(height: 80)
                        .overlay(Text("\(num)"))
                }
            }
        }
        .padding()
    }
}
```

### Controles Basicos

```swift
struct ControlesDemo: View {
    @State private var texto = ""
    @State private var valor = 50.0
    @State private var fecha = Date()
    @State private var seleccion = "Opcion 1"
    let opciones = ["Opcion 1", "Opcion 2", "Opcion 3"]

    var body: some View {
        Form {
            Section("Texto") {
                TextField("Nombre", text: $texto)
                SecureField("Password", text: $texto)
                TextEditor(text: $texto)
                    .frame(height: 100)
            }

            Section("Seleccion") {
                Picker("Opciones", selection: $seleccion) {
                    ForEach(opciones, id: \.self) { Text($0) }
                }
                DatePicker("Fecha", selection: $fecha)
                Slider(value: $valor, in: 0...100)
                Stepper("Valor: \(Int(valor))", value: $valor)
            }

            Section("Indicadores") {
                ProgressView(value: valor, total: 100)
                Label("Configuracion", systemImage: "gear")
                Link("Apple", destination: URL(string: "https://apple.com")!)
            }
        }
    }
}
```

### Listas Basicas

```swift
struct Item: Identifiable {
    let id = UUID()
    var nombre: String
    var completado: Bool
}

struct ListaDemo: View {
    @State private var items = [
        Item(nombre: "Aprender SwiftUI", completado: false),
        Item(nombre: "Crear primera app", completado: false),
        Item(nombre: "Publicar en App Store", completado: false)
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach($items) { $item in
                    HStack {
                        Image(systemName: item.completado ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.completado ? .green : .gray)
                            .onTapGesture { item.completado.toggle() }
                        Text(item.nombre)
                            .strikethrough(item.completado)
                    }
                }
                .onDelete { items.remove(atOffsets: $0) }
                .onMove { items.move(fromOffsets: $0, toOffset: $1) }
            }
            .navigationTitle("Mi Lista")
            .toolbar {
                EditButton()
            }
        }
    }
}
```

### Navegacion Basica

```swift
struct AppNavegacion: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Perfil") {
                    Text("Pantalla de Perfil")
                }
                NavigationLink("Configuracion") {
                    Text("Pantalla de Configuracion")
                }
            }
            .navigationTitle("Mi App")
        }
    }
}
```

### Modifiers

```swift
// Los modifiers son funciones que retornan una vista modificada
Text("Hola")
    .font(.title)                    // Tipografia
    .foregroundStyle(.blue)          // Color de texto
    .padding()                       // Espacio interno
    .background(.yellow)             // Fondo
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(radius: 4)               // Sombra

// Custom modifier
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// Uso
Text("Tarjeta").cardStyle()
```

---

## Ejercicio 1: Tarjeta de Contacto (Basico)

**Objetivo**: Practicar layouts, controles y modifiers.

**Requisitos**:
1. Vista con foto (SF Symbol), nombre, email y telefono
2. Botones de accion: Llamar, Email, Mensaje
3. Usar VStack, HStack, Spacer
4. Aplicar modifiers: fonts, colors, padding, background, corner radius

---

## Ejercicio 2: Lista de Compras (Intermedio)

**Objetivo**: Practicar @State, @Binding, List y NavigationStack.

**Requisitos**:
1. Lista de items de compra con nombre, cantidad y completado
2. Agregar nuevos items con TextField y boton
3. Marcar items como completados (toggle)
4. Eliminar items con swipe
5. Navegacion a detalle de cada item
6. Contador de items pendientes en la barra de navegacion

---

## Ejercicio 3: App de Notas con @Observable (Avanzado)

**Objetivo**: Practicar @Observable, @State, @Binding, navegacion y custom modifiers.

**Requisitos**:
1. @Observable NotasViewModel con array de notas
2. Pantalla de lista con busqueda (Searchable)
3. Pantalla de detalle/edicion de nota
4. Crear un custom ViewModifier para estilo de tarjeta
5. Preview con datos de ejemplo
6. Persistencia basica con @AppStorage para preferencias

---

## Recursos Adicionales

- **Cupertino**: `cupertino search "SwiftUI fundamentals"`
- **Kavsoft**: SwiftUI UI components
- **Karin Prater**: SwiftUI layouts and state

---

## Checklist

- [ ] Entender el View protocol y el rol de body
- [ ] Usar @State para estado local de vistas
- [ ] Usar @Binding para pasar estado mutable a vistas hijas
- [ ] Crear @Observable ViewModels
- [ ] Usar VStack, HStack, ZStack y Spacer para layouts
- [ ] Implementar List con ForEach, onDelete, onMove
- [ ] Usar NavigationStack y NavigationLink
- [ ] Aplicar modifiers y crear custom ViewModifiers
- [ ] Usar controles: TextField, Toggle, Picker, Slider, DatePicker
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

SwiftUI sera la base visual de todo tu Proyecto Integrador:
- **@Observable ViewModels** para toda la logica de presentacion
- **NavigationStack** para la navegacion principal
- **List** para pantallas de datos
- **Custom modifiers** para un design system consistente
- **Previews** para desarrollo rapido de UI

---

*Leccion 06 (L10) | SwiftUI Fundamentos | Semanas 11-12 | Modulo 00: Fundamentos*
*Siguiente: Modulo 01 — Leccion 11: MVVM en SwiftUI*
