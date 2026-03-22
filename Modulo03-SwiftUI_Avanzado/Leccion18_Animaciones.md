# Leccion 18: Animaciones y Transiciones

**Modulo 03: SwiftUI Avanzado** | Semanas 21-22

---

## TL;DR — Resumen en 2 minutos

- **withAnimation** envuelve cambios de estado para animarlos — es la forma explicita de animar
- **matchedGeometryEffect** crea transiciones fluidas entre vistas compartiendo identidad geometrica
- **PhaseAnimator** ejecuta secuencias de fases automaticamente — ideal para onboarding y estados
- **KeyframeAnimator** da control preciso frame-a-frame sobre multiples propiedades simultaneamente
- **Canvas** y **TimelineView** permiten dibujo custom de alto rendimiento para animaciones complejas

> Herramienta: **Xcode 26** Previews con "Slow Animations" (Debug > Slow Animations) para depurar timing

---

## Cupertino MCP

```bash
cupertino search "withAnimation"
cupertino search "Animation SwiftUI"
cupertino search "matchedGeometryEffect"
cupertino search "PhaseAnimator"
cupertino search "KeyframeAnimator"
cupertino search "Canvas SwiftUI"
cupertino search "TimelineView"
cupertino search --source apple-docs "transition SwiftUI"
cupertino search --source samples "Animation"
cupertino search --source updates "animation iOS 26"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC23 | [Explore SwiftUI Animation](https://developer.apple.com/videos/play/wwdc2023/10156/) | **Esencial** — PhaseAnimator, KeyframeAnimator |
| WWDC23 | [Wind your way through advanced animations](https://developer.apple.com/videos/play/wwdc2023/10157/) | Animaciones avanzadas |
| WWDC22 | [The craft of SwiftUI API design](https://developer.apple.com/videos/play/wwdc2022/10059/) | matchedGeometryEffect |
| WWDC25 | What's New in SwiftUI | Novedades animaciones iOS 26 |
| EN | [Kavsoft — Animations](https://www.youtube.com/@Kavsoft) | Hero transitions, gestures |
| EN | [Paul Hudson — Animations](https://www.hackingwithswift.com) | Fundamentos de animacion |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que las Animaciones importan?

Las animaciones no son decoracion — son **informacion**. Cuando un elemento se desliza hacia la derecha, el usuario entiende que "se fue". Cuando un boton rebota, comunica "accion completada". Sin animaciones, los cambios de estado son abruptos y confusos.

Apple distingue dos tipos:
1. **Implicitas**: `.animation(.spring, value: estado)` — la vista se anima cuando `estado` cambia
2. **Explicitas**: `withAnimation { estado = nuevoValor }` — tu controlas exactamente que cambio se anima

La regla: usa implicitas para componentes autocontenidos, explicitas cuando quieras controlar exactamente que se anima.

### Tipos de Animacion

```swift
import SwiftUI

struct TiposAnimacionView: View {
    @State private var escala: CGFloat = 1
    @State private var rotacion: Double = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack(spacing: 40) {
            // Spring — la mas natural para UI
            Circle()
                .fill(.blue)
                .frame(width: 60, height: 60)
                .scaleEffect(escala)

            // Linear — velocidad constante
            Circle()
                .fill(.green)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotacion))

            // EaseInOut — suave al inicio y final
            Circle()
                .fill(.orange)
                .frame(width: 60, height: 60)
                .offset(x: offset)

            Button("Animar") {
                // Spring: rebote natural
                withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                    escala = escala == 1 ? 1.5 : 1
                }

                // Linear: rotacion constante
                withAnimation(.linear(duration: 1)) {
                    rotacion += 360
                }

                // EaseInOut: movimiento suave
                withAnimation(.easeInOut(duration: 0.8)) {
                    offset = offset == 0 ? 100 : 0
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

### Animacion Implicita vs Explicita

```swift
import SwiftUI

struct ImplicitaVsExplicitaView: View {
    @State private var estaExpandido = false
    @State private var estaRotado = false

    var body: some View {
        VStack(spacing: 40) {
            // IMPLICITA — la animacion vive en la vista
            // Cualquier cambio en 'estaExpandido' se anima automaticamente
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .frame(
                    width: estaExpandido ? 200 : 100,
                    height: estaExpandido ? 200 : 100
                )
                .animation(.spring(duration: 0.5, bounce: 0.2), value: estaExpandido)
                .onTapGesture {
                    estaExpandido.toggle() // sin withAnimation — la implicita se encarga
                }

            // EXPLICITA — tu controlas que se anima
            RoundedRectangle(cornerRadius: 12)
                .fill(.green)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(estaRotado ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring(duration: 0.8, bounce: 0.4)) {
                        estaRotado.toggle()
                    }
                }

            Text("Azul: Implicita | Verde: Explicita")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

### Transiciones — Aparecer y Desaparecer

```swift
import SwiftUI

struct TransicionesView: View {
    @State private var mostrarDetalle = false
    @State private var mostrarAlerta = false
    @State private var mostrarMenu = false

    var body: some View {
        VStack(spacing: 30) {
            // Transicion por defecto (opacity)
            Button("Toggle Detalle") {
                withAnimation(.spring) {
                    mostrarDetalle.toggle()
                }
            }

            if mostrarDetalle {
                Text("Detalle visible")
                    .padding()
                    .background(.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Transicion asimetrica
            Button("Toggle Alerta") {
                withAnimation(.spring(duration: 0.4)) {
                    mostrarAlerta.toggle()
                }
            }

            if mostrarAlerta {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Atencion: accion requerida")
                }
                .padding()
                .background(.yellow.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .transition(.asymmetric(
                    insertion: .push(from: .top),
                    removal: .push(from: .bottom)
                ))
            }

            // Transicion custom
            Button("Toggle Menu") {
                withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                    mostrarMenu.toggle()
                }
            }

            if mostrarMenu {
                VStack(spacing: 8) {
                    ForEach(["Inicio", "Perfil", "Config"], id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .transition(.scale(scale: 0.5, anchor: .top).combined(with: .opacity))
            }
        }
        .padding()
    }
}
```

### matchedGeometryEffect — Hero Transitions

`matchedGeometryEffect` crea transiciones fluidas entre dos vistas que comparten una identidad.

```swift
import SwiftUI

struct HeroTransitionView: View {
    @Namespace private var animacion
    @State private var itemSeleccionado: ItemHero?

    let items = [
        ItemHero(titulo: "SwiftUI", color: .blue, icono: "swift"),
        ItemHero(titulo: "UIKit", color: .orange, icono: "app"),
        ItemHero(titulo: "CoreData", color: .green, icono: "cylinder.split.1x2"),
        ItemHero(titulo: "Combine", color: .purple, icono: "arrow.triangle.merge"),
    ]

    var body: some View {
        ZStack {
            // Grid de items
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                          spacing: 16) {
                    ForEach(items) { item in
                        if itemSeleccionado?.id != item.id {
                            ItemCardView(item: item, namespace: animacion)
                                .onTapGesture {
                                    withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                                        itemSeleccionado = item
                                    }
                                }
                        } else {
                            Color.clear.frame(height: 150)
                        }
                    }
                }
                .padding()
            }

            // Vista expandida
            if let item = itemSeleccionado {
                ItemExpandidoView(item: item, namespace: animacion) {
                    withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                        itemSeleccionado = nil
                    }
                }
            }
        }
    }
}

struct ItemHero: Identifiable {
    let id = UUID()
    let titulo: String
    let color: Color
    let icono: String
}

struct ItemCardView: View {
    let item: ItemHero
    var namespace: Namespace.ID

    var body: some View {
        VStack {
            Image(systemName: item.icono)
                .font(.largeTitle)
                .matchedGeometryEffect(id: "\(item.id)-icono", in: namespace)

            Text(item.titulo)
                .font(.headline)
                .matchedGeometryEffect(id: "\(item.id)-titulo", in: namespace)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            item.color.opacity(0.2)
                .matchedGeometryEffect(id: "\(item.id)-fondo", in: namespace)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ItemExpandidoView: View {
    let item: ItemHero
    var namespace: Namespace.ID
    let cerrar: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: cerrar) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()

            Image(systemName: item.icono)
                .font(.system(size: 60))
                .matchedGeometryEffect(id: "\(item.id)-icono", in: namespace)

            Text(item.titulo)
                .font(.largeTitle.bold())
                .matchedGeometryEffect(id: "\(item.id)-titulo", in: namespace)

            Text("Descripcion detallada de \(item.titulo). Aqui va contenido extenso sobre esta tecnologia.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            item.color.opacity(0.2)
                .matchedGeometryEffect(id: "\(item.id)-fondo", in: namespace)
        )
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .ignoresSafeArea()
    }
}
```

### PhaseAnimator — Secuencias de Fases

`PhaseAnimator` ejecuta una secuencia de fases automaticamente, ideal para animaciones multi-paso.

```swift
import SwiftUI

// Fases de la animacion
enum FaseNotificacion: CaseIterable {
    case inicio
    case aparece
    case destaca
    case normal

    var escala: CGFloat {
        switch self {
        case .inicio: 0.5
        case .aparece: 1.1
        case .destaca: 1.0
        case .normal: 1.0
        }
    }

    var opacidad: Double {
        switch self {
        case .inicio: 0
        case .aparece: 1
        case .destaca: 1
        case .normal: 0.8
        }
    }

    var rotacion: Double {
        switch self {
        case .inicio: -10
        case .aparece: 3
        case .destaca: -2
        case .normal: 0
        }
    }
}

struct NotificacionAnimadaView: View {
    @State private var activar = false

    var body: some View {
        VStack(spacing: 40) {
            PhaseAnimator(
                FaseNotificacion.allCases,
                trigger: activar
            ) { fase in
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.yellow)
                    Text("Nueva notificacion!")
                        .font(.headline)
                }
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(fase.escala)
                .opacity(fase.opacidad)
                .rotationEffect(.degrees(fase.rotacion))
            } animation: { fase in
                switch fase {
                case .inicio: .spring(duration: 0.3)
                case .aparece: .spring(duration: 0.4, bounce: 0.5)
                case .destaca: .spring(duration: 0.3)
                case .normal: .easeOut(duration: 0.2)
                }
            }

            Button("Activar") {
                activar.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

### KeyframeAnimator — Control Preciso

`KeyframeAnimator` permite animar multiples propiedades con timing independiente.

```swift
import SwiftUI

struct PropiedadesAnimacion {
    var escala: CGFloat = 1
    var rotacion: Double = 0
    var offsetY: CGFloat = 0
    var opacidad: Double = 1
}

struct KeyframeView: View {
    @State private var activar = false

    var body: some View {
        VStack(spacing: 40) {
            KeyframeAnimator(
                initialValue: PropiedadesAnimacion(),
                trigger: activar
            ) { propiedades in
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.red)
                    .scaleEffect(propiedades.escala)
                    .rotationEffect(.degrees(propiedades.rotacion))
                    .offset(y: propiedades.offsetY)
                    .opacity(propiedades.opacidad)
            } keyframes: { _ in
                KeyframeTrack(\.escala) {
                    SpringKeyframe(1.5, duration: 0.3, spring: .bouncy)
                    SpringKeyframe(0.8, duration: 0.2)
                    SpringKeyframe(1.2, duration: 0.2)
                    SpringKeyframe(1.0, duration: 0.3)
                }

                KeyframeTrack(\.rotacion) {
                    LinearKeyframe(0, duration: 0.1)
                    SpringKeyframe(15, duration: 0.15)
                    SpringKeyframe(-15, duration: 0.15)
                    SpringKeyframe(10, duration: 0.1)
                    SpringKeyframe(-10, duration: 0.1)
                    SpringKeyframe(0, duration: 0.2)
                }

                KeyframeTrack(\.offsetY) {
                    SpringKeyframe(-30, duration: 0.3, spring: .bouncy)
                    SpringKeyframe(0, duration: 0.5, spring: .bouncy)
                }
            }

            Button("Like!") {
                activar.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

### Canvas y TimelineView — Dibujo de Alto Rendimiento

```swift
import SwiftUI

struct ParticulasView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let tiempo = timeline.date.timeIntervalSinceReferenceDate

                // Dibujar particulas
                for i in 0..<50 {
                    let semilla = Double(i)
                    let x = (sin(tiempo * 0.5 + semilla) + 1) / 2 * size.width
                    let y = (cos(tiempo * 0.3 + semilla * 1.5) + 1) / 2 * size.height
                    let radio = 3 + sin(tiempo + semilla) * 2

                    let punto = CGPoint(x: x, y: y)
                    let circulo = Path(ellipseIn: CGRect(
                        x: punto.x - radio,
                        y: punto.y - radio,
                        width: radio * 2,
                        height: radio * 2
                    ))

                    let hue = (semilla / 50 + tiempo * 0.1).truncatingRemainder(dividingBy: 1)
                    context.fill(circulo, with: .color(
                        Color(hue: hue, saturation: 0.8, brightness: 0.9)
                    ))
                }
            }
        }
        .ignoresSafeArea()
        .background(.black)
    }
}

// Onda animada
struct OndaView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let tiempo = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                var path = Path()
                let medio = size.height / 2

                path.move(to: CGPoint(x: 0, y: medio))

                for x in stride(from: 0, to: size.width, by: 1) {
                    let porcentaje = x / size.width
                    let seno = sin(porcentaje * .pi * 4 + tiempo * 3)
                    let y = medio + seno * 30

                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.closeSubpath()

                context.fill(path, with: .linearGradient(
                    Gradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.3)]),
                    startPoint: .init(x: 0, y: 0),
                    endPoint: .init(x: 0, y: size.height)
                ))
            }
        }
        .frame(height: 200)
    }
}
```

#### Diagrama de Animaciones

```
  ┌──────────────────────────────────────────────────────┐
  │           TIPOS DE ANIMACION                          │
  │                                                       │
  │  IMPLICITA            EXPLICITA          AVANZADA     │
  │  .animation()         withAnimation{}    Phase/Key    │
  │                                                       │
  │  ┌─────────────┐     ┌─────────────┐                 │
  │  │ Vista        │     │ Accion      │                 │
  │  │  .animation  │     │ withAnim {  │                 │
  │  │  (.spring,   │     │   estado =  │                 │
  │  │   value: x)  │     │   nuevo     │                 │
  │  └─────────────┘     │ }           │                 │
  │  Auto cuando x       └─────────────┘                 │
  │  cambia               Control total                   │
  │                                                       │
  │  matchedGeometryEffect:                               │
  │  ┌──────┐              ┌──────────────────┐          │
  │  │ Card │  ──tap──▶    │   Expanded View  │          │
  │  │  🔵  │    smooth    │       🔵          │          │
  │  └──────┘  transition  │    Title          │          │
  │                        └──────────────────┘          │
  │                                                       │
  │  PhaseAnimator: [Fase1] → [Fase2] → [Fase3] → done  │
  │  KeyframeAnimator: escala|rotacion|offset timeline   │
  │  Canvas + TimelineView: 60fps custom drawing          │
  └──────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: Tarjeta con Animaciones Basicas (Basico)

**Objetivo**: Practicar animaciones implicitas y explicitas.

**Requisitos**:
1. Tarjeta que se expande al tocarla (cambia tamano con animacion spring)
2. Boton de favorito con animacion de escala y rotacion
3. Transicion de aparicion/desaparicion de un banner informativo
4. Usar al menos 3 tipos de animacion diferentes: `.spring`, `.easeInOut`, `.linear`

---

## Ejercicio 2: Hero Transition entre Grid y Detalle (Intermedio)

**Objetivo**: Implementar matchedGeometryEffect para transiciones fluidas.

**Requisitos**:
1. Grid de 6 tarjetas con icono, titulo y color
2. Al tocar una tarjeta, expande a pantalla completa con matchedGeometryEffect
3. Animar icono, titulo y fondo con IDs diferentes de matchedGeometryEffect
4. Boton de cerrar que vuelve a la posicion original
5. Deshabilitar interaccion con el grid cuando hay un item expandido
6. Animacion spring con bounce personalizado

---

## Ejercicio 3: Animacion Compleja con KeyframeAnimator (Avanzado)

**Objetivo**: Combinar PhaseAnimator, KeyframeAnimator y Canvas.

**Requisitos**:
1. Boton de "enviar mensaje" con KeyframeAnimator: escala, rotacion, offset y opacidad
2. Indicador de "enviando" con PhaseAnimator de 4 fases: preparar, subir, confirmar, completar
3. Fondo animado con Canvas + TimelineView que dibuje particulas o una onda
4. Transicion entre estados: componer, enviando, enviado — con animaciones diferentes por estado
5. Haptic feedback simulado con cambios de escala
6. La animacion completa debe durar entre 2-3 segundos

---

## 5 Errores Comunes

### 1. Animar en el hilo incorrecto
```swift
// MAL — cambio de estado desde background thread
Task.detached {
    let resultado = await fetchDatos()
    withAnimation { // puede causar warnings/bugs
        self.items = resultado
    }
}

// BIEN — asegurar MainActor
Task { @MainActor in
    let resultado = await fetchDatos()
    withAnimation {
        self.items = resultado
    }
}
```

### 2. Animacion implicita que anima demasiado
```swift
// MAL — .animation sin value anima TODO (deprecado)
VStack {
    Text(titulo)
    Text(subtitulo)
    Image(systemName: icono)
}
.animation(.spring) // anima cambios no deseados

// BIEN — .animation con value especifico
VStack {
    Text(titulo)
    Text(subtitulo)
    Image(systemName: icono)
}
.animation(.spring, value: estaExpandido) // solo anima cuando estaExpandido cambia
```

### 3. matchedGeometryEffect con IDs duplicados
```swift
// MAL — mismo id para diferentes elementos
Image(systemName: "star")
    .matchedGeometryEffect(id: "item", in: namespace)
Text("Titulo")
    .matchedGeometryEffect(id: "item", in: namespace) // conflicto!

// BIEN — id unico por elemento
Image(systemName: "star")
    .matchedGeometryEffect(id: "item-icono", in: namespace)
Text("Titulo")
    .matchedGeometryEffect(id: "item-titulo", in: namespace)
```

### 4. Transiciones sin withAnimation
```swift
// MAL — if/else sin animacion = cambio abrupto
Button("Toggle") {
    mostrar.toggle() // sin animacion
}
if mostrar {
    Text("Hola").transition(.slide) // el .transition no se ejecuta
}

// BIEN — withAnimation para que la transicion funcione
Button("Toggle") {
    withAnimation(.spring) {
        mostrar.toggle()
    }
}
if mostrar {
    Text("Hola").transition(.slide) // ahora si se anima
}
```

### 5. Canvas sin TimelineView para animaciones
```swift
// MAL — Canvas estatico, no se actualiza
Canvas { context, size in
    let x = sin(Date().timeIntervalSinceReferenceDate) // no se re-evalua
    // ...
}

// BIEN — TimelineView fuerza re-evaluacion cada frame
TimelineView(.animation) { timeline in
    Canvas { context, size in
        let tiempo = timeline.date.timeIntervalSinceReferenceDate
        let x = sin(tiempo) // se actualiza cada frame
        // ...
    }
}
```

---

## Checklist

- [ ] Entender la diferencia entre animacion implicita y explicita
- [ ] Usar withAnimation con diferentes curvas: spring, easeInOut, linear
- [ ] Implementar transiciones: move, opacity, scale, slide, push
- [ ] Crear transiciones asimetricas con .asymmetric
- [ ] Usar matchedGeometryEffect para hero transitions
- [ ] Implementar PhaseAnimator para secuencias multi-fase
- [ ] Usar KeyframeAnimator para control frame-a-frame
- [ ] Crear animaciones con Canvas y TimelineView
- [ ] Siempre especificar `value:` en animaciones implicitas
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Las animaciones dan vida al Proyecto Integrador:
- **withAnimation** para todas las transiciones de estado en la app
- **matchedGeometryEffect** para hero transitions entre lista y detalle
- **PhaseAnimator** para onboarding animado y estados de carga
- **KeyframeAnimator** para micro-interacciones (like, completar tarea, notificaciones)
- **Canvas + TimelineView** para visualizaciones de datos animadas (graficas, progreso)
- **Transiciones custom** para un look and feel unico y pulido

---

*Leccion 18 | Animaciones y Transiciones | Semanas 21-22 | Modulo 03: SwiftUI Avanzado*
*Siguiente: Modulo 04 — Leccion 19: SwiftData Fundamentals*
