# Leccion 16: Composicion de Vistas

**Modulo 03: SwiftUI Avanzado** | Semana 19

---

## TL;DR — Resumen en 2 minutos

- **@ViewBuilder** permite crear APIs declarativas que aceptan multiples vistas hijas como closures
- **ViewModifier** encapsula estilos reutilizables — crea tu propio design system con modifiers custom
- **PreferenceKey** comunica datos de hijo a padre (flujo inverso al normal)
- **GeometryReader** da acceso al tamano y posicion del contenedor para layouts adaptativos
- **Layout protocol** (iOS 16+) permite crear contenedores custom con control total del posicionamiento

> Herramienta: **Xcode 26** Previews para iterar rapidamente sobre componentes reutilizables

---

## Cupertino MCP

```bash
cupertino search "ViewBuilder"
cupertino search "ViewModifier"
cupertino search "PreferenceKey"
cupertino search "GeometryReader"
cupertino search "Layout protocol SwiftUI"
cupertino search --source apple-docs "custom container views"
cupertino search --source samples "ViewModifier"
cupertino search --source updates "Layout protocol"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [Demystify SwiftUI containers](https://developer.apple.com/videos/play/wwdc2024/10146/) | **Esencial** — ForEach, Group, custom containers |
| WWDC22 | [Compose custom layouts with SwiftUI](https://developer.apple.com/videos/play/wwdc2022/10056/) | **Esencial** — Layout protocol |
| WWDC23 | [Beyond scroll views](https://developer.apple.com/videos/play/wwdc2023/10159/) | GeometryReader avanzado |
| EN | [Kavsoft — Custom Components](https://www.youtube.com/@Kavsoft) | Componentes reutilizables |
| EN | [Karin Prater — ViewModifiers](https://www.youtube.com/@swiftyplace) | Patrones de composicion |
| EN | [Paul Hudson — PreferenceKey](https://www.hackingwithswift.com) | Comunicacion hijo-padre |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que la Composicion importa?

SwiftUI esta disenado alrededor de la **composicion**: vistas pequenas que se combinan para crear UIs complejas. Pero componer no es solo usar VStack y HStack — es crear **abstracciones reutilizables** que encapsulan comportamiento y estilo.

Sin composicion, terminas con vistas de 500+ lineas, estilos duplicados y codigo imposible de mantener. Con composicion, cada componente es pequeno, testeable y reutilizable.

### @ViewBuilder — APIs Declarativas

`@ViewBuilder` es un result builder que permite que tus funciones y propiedades acepten multiples vistas como si fueran closures de SwiftUI.

```swift
import SwiftUI

// MARK: - Contenedor custom con @ViewBuilder
struct TarjetaContenedor<Contenido: View>: View {
    let titulo: String
    let icono: String
    @ViewBuilder let contenido: () -> Contenido

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(titulo, systemImage: icono)
                .font(.headline)
                .foregroundStyle(.primary)

            contenido()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// Uso declarativo — se siente como SwiftUI nativo
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TarjetaContenedor(titulo: "Estadisticas", icono: "chart.bar") {
                    HStack {
                        EstadisticaView(valor: "1.2K", etiqueta: "Usuarios")
                        EstadisticaView(valor: "89%", etiqueta: "Retencion")
                        EstadisticaView(valor: "$4.5K", etiqueta: "Ingresos")
                    }
                }

                TarjetaContenedor(titulo: "Actividad Reciente", icono: "clock") {
                    Text("Ultimo acceso: hace 5 min")
                    Text("Compras hoy: 12")
                }
            }
            .padding()
        }
    }
}

struct EstadisticaView: View {
    let valor: String
    let etiqueta: String

    var body: some View {
        VStack {
            Text(valor)
                .font(.title2.bold())
            Text(etiqueta)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
```

#### @ViewBuilder en funciones y propiedades computadas

```swift
struct ContenidoCondicional: View {
    let esPremium: Bool
    let tieneContenido: Bool

    var body: some View {
        VStack {
            encabezado
            contenidoPrincipal
        }
    }

    // @ViewBuilder en propiedad computada
    @ViewBuilder
    private var encabezado: some View {
        if esPremium {
            Label("Premium", systemImage: "crown.fill")
                .foregroundStyle(.yellow)
        } else {
            Label("Gratis", systemImage: "person")
        }
    }

    // @ViewBuilder en funcion
    @ViewBuilder
    private func contenidoPrincipal() -> some View {
        if tieneContenido {
            Text("Aqui va el contenido")
        } else {
            ContentUnavailableView("Sin contenido",
                systemImage: "doc",
                description: Text("Agrega contenido para comenzar"))
        }
    }
}
```

### Custom ViewModifiers

ViewModifier encapsula una combinacion de modifiers en un componente reutilizable.

```swift
import SwiftUI

// MARK: - Design System con ViewModifiers

// Modifier para tarjetas elevadas
struct TarjetaElevadaModifier: ViewModifier {
    let esquinaRadius: CGFloat
    let elevacion: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: esquinaRadius))
            .shadow(color: .black.opacity(0.1),
                    radius: elevacion,
                    x: 0,
                    y: elevacion / 2)
    }
}

// Modifier para texto de encabezado
struct EncabezadoSeccionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3.bold())
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
}

// Modifier condicional
struct ShimmerModifier: ViewModifier {
    let estaCargando: Bool

    func body(content: Content) -> some View {
        if estaCargando {
            content
                .redacted(reason: .placeholder)
                .shimmering()
        } else {
            content
        }
    }
}

// Shimmer personalizado
struct ShimmeringModifier: ViewModifier {
    @State private var fase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: fase)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false),
                           value: fase)
            )
            .onAppear { fase = 200 }
            .clipped()
    }
}

// MARK: - Extension para acceso limpio
extension View {
    func tarjetaElevada(radius: CGFloat = 12, elevacion: CGFloat = 8) -> some View {
        modifier(TarjetaElevadaModifier(esquinaRadius: radius, elevacion: elevacion))
    }

    func encabezadoSeccion() -> some View {
        modifier(EncabezadoSeccionModifier())
    }

    func cargando(_ estaCargando: Bool) -> some View {
        modifier(ShimmerModifier(estaCargando: estaCargando))
    }

    func shimmering() -> some View {
        modifier(ShimmeringModifier())
    }
}

// MARK: - Uso
struct DesignSystemDemo: View {
    @State private var cargando = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Mi Dashboard")
                    .encabezadoSeccion()

                VStack(alignment: .leading) {
                    Text("Ventas del Mes")
                        .font(.headline)
                    Text("$12,450")
                        .font(.largeTitle.bold())
                }
                .tarjetaElevada()
                .cargando(cargando)

                VStack(alignment: .leading) {
                    Text("Usuarios Activos")
                        .font(.headline)
                    Text("1,234")
                        .font(.largeTitle.bold())
                }
                .tarjetaElevada(radius: 20, elevacion: 12)
            }
            .padding()
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            cargando = false
        }
    }
}
```

### PreferenceKey — Comunicacion Hijo a Padre

En SwiftUI, los datos fluyen de padre a hijo (via properties y environment). `PreferenceKey` invierte ese flujo: **el hijo comunica datos al padre**.

```swift
import SwiftUI

// MARK: - PreferenceKey para scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollViewConOffset: View {
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            // Header que cambia con el scroll
            HeaderDinamico(offset: scrollOffset)
                .zIndex(1)

            ScrollView {
                // Ancla invisible que reporta la posicion
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("scroll")).minY
                        )
                }
                .frame(height: 0)

                LazyVStack(spacing: 12) {
                    ForEach(0..<30) { i in
                        Text("Item \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                .padding(.top, 60) // Espacio para el header
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { valor in
                scrollOffset = valor
            }
        }
    }
}

struct HeaderDinamico: View {
    let offset: CGFloat

    private var opacidad: Double {
        min(1, max(0, -Double(offset) / 100))
    }

    var body: some View {
        Text("Mi App")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial.opacity(opacidad))
    }
}

// MARK: - PreferenceKey para anchos iguales
struct AnchoPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct EtiquetasIgualesView: View {
    @State private var anchoMaximo: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FilaConEtiqueta(etiqueta: "Nombre:", valor: "Carlos", anchoEtiqueta: anchoMaximo)
            FilaConEtiqueta(etiqueta: "Email:", valor: "carlos@mail.com", anchoEtiqueta: anchoMaximo)
            FilaConEtiqueta(etiqueta: "Telefono:", valor: "+34 612 345 678", anchoEtiqueta: anchoMaximo)
        }
        .onPreferenceChange(AnchoPreferenceKey.self) { valor in
            anchoMaximo = valor
        }
    }
}

struct FilaConEtiqueta: View {
    let etiqueta: String
    let valor: String
    let anchoEtiqueta: CGFloat

    var body: some View {
        HStack {
            Text(etiqueta)
                .bold()
                .frame(width: anchoMaximo > 0 ? anchoMaximo : nil, alignment: .trailing)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: AnchoPreferenceKey.self,
                            value: geo.size.width
                        )
                    }
                )
            Text(valor)
        }
    }
}
```

### GeometryReader — Layouts Adaptativos

`GeometryReader` proporciona el tamano y posicion del contenedor. Usalo con moderacion — es una herramienta poderosa pero que puede complicar el layout.

```swift
import SwiftUI

struct LayoutAdaptativoView: View {
    var body: some View {
        GeometryReader { geometria in
            let ancho = geometria.size.width
            let esHorizontal = ancho > 600

            if esHorizontal {
                // iPad / Landscape
                HStack(spacing: 16) {
                    panelIzquierdo
                        .frame(width: ancho * 0.4)
                    panelDerecho
                }
            } else {
                // iPhone / Portrait
                VStack(spacing: 16) {
                    panelIzquierdo
                    panelDerecho
                }
            }
        }
        .padding()
    }

    private var panelIzquierdo: some View {
        VStack {
            Text("Panel Principal")
                .font(.title)
            Text("Contenido adaptativo")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var panelDerecho: some View {
        VStack {
            Text("Panel Secundario")
                .font(.title2)
            Text("Detalles")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

### Layout Protocol — Contenedores Custom

El protocol `Layout` (iOS 16+) permite crear contenedores con control total del posicionamiento.

```swift
import SwiftUI

// MARK: - Flow Layout (Tag Cloud)
struct FlowLayout: Layout {
    var espaciadoHorizontal: CGFloat = 8
    var espaciadoVertical: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let resultado = calcularPosiciones(proposal: proposal, subviews: subviews)
        return resultado.tamano
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let resultado = calcularPosiciones(proposal: proposal, subviews: subviews)

        for (indice, subview) in subviews.enumerated() {
            let posicion = resultado.posiciones[indice]
            subview.place(
                at: CGPoint(
                    x: bounds.minX + posicion.x,
                    y: bounds.minY + posicion.y
                ),
                proposal: .unspecified
            )
        }
    }

    private struct Resultado {
        var tamano: CGSize
        var posiciones: [CGPoint]
    }

    private func calcularPosiciones(proposal: ProposedViewSize, subviews: Subviews) -> Resultado {
        let anchoDisponible = proposal.width ?? .infinity
        var posiciones: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var alturaFila: CGFloat = 0
        var anchoMaximo: CGFloat = 0

        for subview in subviews {
            let tamano = subview.sizeThatFits(.unspecified)

            if x + tamano.width > anchoDisponible, x > 0 {
                x = 0
                y += alturaFila + espaciadoVertical
                alturaFila = 0
            }

            posiciones.append(CGPoint(x: x, y: y))
            alturaFila = max(alturaFila, tamano.height)
            x += tamano.width + espaciadoHorizontal
            anchoMaximo = max(anchoMaximo, x)
        }

        return Resultado(
            tamano: CGSize(width: anchoMaximo, height: y + alturaFila),
            posiciones: posiciones
        )
    }
}

// MARK: - Uso del FlowLayout
struct TagCloudView: View {
    let tags = ["SwiftUI", "Swift", "iOS", "Xcode", "MVVM",
                "async/await", "SwiftData", "NavigationStack",
                "Observable", "Combine", "UIKit", "CoreML"]

    var body: some View {
        FlowLayout(espaciadoHorizontal: 8, espaciadoVertical: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
}
```

#### Diagrama de Composicion

```
  ┌──────────────────────────────────────────────────────┐
  │            COMPOSICION DE VISTAS                      │
  │                                                       │
  │  @ViewBuilder       ViewModifier     PreferenceKey    │
  │  (contenedores)     (estilos)        (hijo→padre)     │
  │                                                       │
  │  ┌─Padre─────────────────────────────────────┐       │
  │  │                                            │       │
  │  │  @ViewBuilder: acepta vistas hijas         │       │
  │  │  ┌──────┐  ┌──────┐  ┌──────┐             │       │
  │  │  │Vista1│  │Vista2│  │Vista3│             │       │
  │  │  └──┬───┘  └──┬───┘  └──┬───┘             │       │
  │  │     │         │         │                  │       │
  │  │     ▼         ▼         ▼                  │       │
  │  │  .modifier() .modifier() .modifier()       │       │
  │  │  (estilos compartidos via ViewModifier)     │       │
  │  │                                            │       │
  │  │     ▲         ▲         ▲                  │       │
  │  │     │         │         │                  │       │
  │  │  PreferenceKey: datos fluyen HACIA ARRIBA  │       │
  │  └────────────────────────────────────────────┘       │
  │                                                       │
  │  GeometryReader: tamano del contenedor                │
  │  Layout protocol: posicionamiento custom              │
  └──────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: Design System con ViewModifiers (Basico)

**Objetivo**: Crear un mini design system reutilizable.

**Requisitos**:
1. Crear 3 ViewModifiers: `tarjetaPrimaria`, `botonPrincipal`, `textoSecundario`
2. Extension de `View` con funciones para cada modifier
3. Vista demo que use los 3 modifiers en una pantalla de perfil
4. Cada modifier debe aceptar al menos un parametro configurable

---

## Ejercicio 2: Contenedor Custom con @ViewBuilder (Intermedio)

**Objetivo**: Crear un componente contenedor reutilizable.

**Requisitos**:
1. Componente `SeccionColapsable<Content: View>` con titulo, icono y contenido @ViewBuilder
2. Animacion de colapsar/expandir con rotacion del icono
3. Componente `FormularioAgrupado` que use `SeccionColapsable` internamente
4. Al menos 3 secciones con diferentes tipos de contenido
5. Estado de colapso independiente por seccion
6. Transicion animada al colapsar/expandir

---

## Ejercicio 3: Flow Layout con PreferenceKey (Avanzado)

**Objetivo**: Combinar Layout protocol con PreferenceKey.

**Requisitos**:
1. Implementar `FlowLayout` que distribuya tags en filas automaticamente
2. Cada tag debe reportar su tamano via `PreferenceKey` al padre
3. El padre muestra un resumen: "X tags en Y filas, ancho total: Z"
4. Tags seleccionables con estado visual diferenciado
5. Animacion al agregar/eliminar tags
6. Adaptativo: cambiar espaciado segun el ancho disponible con `GeometryReader`

---

## 5 Errores Comunes

### 1. Usar GeometryReader para todo
```swift
// MAL — GeometryReader rompe el layout natural
GeometryReader { geo in
    Text("Hola")
        .frame(width: geo.size.width * 0.5)
}

// BIEN — usar frame con maxWidth cuando sea posible
Text("Hola")
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
```

### 2. ViewModifier sin parametros configurables
```swift
// MAL — modifier rigido, no reutilizable
struct MiModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.blue)
            .cornerRadius(12) // deprecado
    }
}

// BIEN — configurable y usando APIs modernas
struct MiModifier: ViewModifier {
    var padding: CGFloat = 16
    var color: Color = .blue
    var radius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}
```

### 3. PreferenceKey con reduce incorrecto
```swift
// MAL — siempre toma el ultimo valor
static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue() // pierde valores anteriores
}

// BIEN — combinar valores segun la logica necesaria
// Para maximo:
static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
}
// Para acumular:
static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
    value.append(contentsOf: nextValue())
}
```

### 4. @ViewBuilder sin soporte para condicionales
```swift
// MAL — forzar un solo tipo de vista
struct Contenedor<C: View>: View {
    let contenido: C // no soporta if/else en el call site
    ...
}

// BIEN — usar @ViewBuilder para soportar condicionales
struct Contenedor<C: View>: View {
    @ViewBuilder let contenido: () -> C

    var body: some View {
        contenido()
    }
}
```

### 5. GeometryReader con tamano infinito
```swift
// MAL — GeometryReader expande para llenar todo el espacio
VStack {
    GeometryReader { geo in
        Text("Ancho: \(geo.size.width)")
    }
    Text("Este texto se empuja hacia abajo")
}

// BIEN — limitar el tamano del GeometryReader
VStack {
    GeometryReader { geo in
        Text("Ancho: \(geo.size.width)")
    }
    .frame(height: 44) // limitar la expansion
    Text("Este texto mantiene su posicion")
}
```

---

## Checklist

- [ ] Crear contenedores custom con @ViewBuilder
- [ ] Usar @ViewBuilder en propiedades computadas y funciones
- [ ] Implementar ViewModifiers reutilizables
- [ ] Crear extensions de View para acceso limpio a modifiers
- [ ] Entender PreferenceKey y el flujo hijo-padre
- [ ] Usar GeometryReader con moderacion y proposito
- [ ] Implementar el Layout protocol para contenedores custom
- [ ] Crear un FlowLayout funcional
- [ ] Combinar todas las tecnicas en un componente complejo
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

La composicion de vistas es la base del design system del Proyecto Integrador:
- **ViewModifiers** definen el estilo visual consistente de toda la app
- **@ViewBuilder containers** crean componentes reutilizables como tarjetas, secciones y formularios
- **PreferenceKey** permite headers dinamicos que reaccionan al scroll
- **Layout protocol** para layouts especializados como tag clouds o grids adaptativos
- **GeometryReader** para adaptar la UI entre iPhone, iPad y Mac

---

*Leccion 16 | Composicion de Vistas | Semana 19 | Modulo 03: SwiftUI Avanzado*
*Siguiente: Leccion 17 — Listas y Colecciones*
