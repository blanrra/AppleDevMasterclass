# Leccion 32: visionOS — Apps Espaciales

**Modulo 08: Plataformas** | Semana 41

---

## TL;DR — Resumen en 2 minutos

- **visionOS** permite crear apps espaciales que coexisten con el mundo real del usuario
- **Windows** son tu punto de entrada — se comportan como ventanas flotantes de SwiftUI en el espacio
- **Volumes** muestran contenido 3D acotado en un cubo — ideal para modelos y visualizaciones
- **Immersive Spaces** permiten experiencias completas que rodean al usuario (mixed o full)
- **RealityKit** es el motor 3D con Entity Component System para crear y manipular entidades

> Herramienta: **Xcode 26** con visionOS Simulator — soporta gestos de mano simulados con mouse

---

## Cupertino MCP

```bash
cupertino search "visionOS"
cupertino search "RealityKit"
cupertino search --source apple-docs "ImmersiveSpace"
cupertino search "WindowGroup visionOS"
cupertino search "Volume3D"
cupertino search "Entity RealityKit"
cupertino search "SpatialTapGesture"
cupertino search "hand tracking visionOS"
cupertino search --source hig "spatial design"
cupertino search --source samples "visionOS"
cupertino search --source updates "visionOS 26"
cupertino search "RealityView"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in visionOS 26 | Novedades visionOS 26 |
| WWDC24 | [Build a spatial app](https://developer.apple.com/videos/play/wwdc2024/) | **Esencial** — windows, volumes, spaces |
| WWDC24 | [Dive into RealityKit](https://developer.apple.com/videos/play/wwdc2024/) | Entity Component System |
| WWDC23 | [Meet SwiftUI for spatial computing](https://developer.apple.com/videos/play/wwdc2023/10109/) | Fundamentos visionOS |
| WWDC23 | [Build spatial experiences with RealityKit](https://developer.apple.com/videos/play/wwdc2023/10080/) | RealityKit basico |
| EN | [Reality School](https://www.youtube.com/@realityschool) | Tutoriales visionOS practicos |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que visionOS?

visionOS representa un cambio de paradigma. Por primera vez, las apps no viven en una pantalla plana — viven en el espacio que rodea al usuario. Esto no significa que todo deba ser 3D. La mayoria de apps comienzan como **windows** (ventanas flotantes) usando SwiftUI estandar, y solo incorporan 3D cuando agrega valor real.

Apple define tres niveles de inmersion:
1. **Shared Space**: multiples apps coexisten, como un escritorio espacial
2. **Mixed Immersion**: tu contenido se mezcla con el mundo real
3. **Full Immersion**: reemplazas completamente el entorno del usuario

La regla de oro: comienza con una window, agrega un volume si necesitas mostrar algo 3D, y usa immersive space solo cuando la experiencia lo requiera.

### Arquitectura de una App visionOS

```swift
import SwiftUI
import RealityKit

// MARK: - App Entry Point
@main
struct MiAppEspacial: App {
    @State private var modeloApp = AppModel()

    var body: some Scene {
        // Window — punto de entrada principal
        WindowGroup {
            ContentView()
                .environment(modeloApp)
        }

        // Volume — contenido 3D acotado
        WindowGroup(id: "volumen-3d") {
            VolumenView()
                .environment(modeloApp)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)

        // Immersive Space — experiencia inmersiva
        ImmersiveSpace(id: "espacio-inmersivo") {
            EspacioInmersivoView()
                .environment(modeloApp)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .full)
    }
}

// MARK: - App Model
@Observable
class AppModel {
    var mostrarVolumen = false
    var mostrarEspacioInmersivo = false
    var estiloInmersion: ImmersionStyle = .mixed
}
```

### Windows — Ventanas Flotantes en el Espacio

Las windows son SwiftUI puro. Tu app de iOS se puede ejecutar casi sin cambios como window en visionOS. Las diferencias principales son la profundidad visual y los gestos espaciales.

```swift
import SwiftUI

// MARK: - Contenido Principal (Window)
struct ContentView: View {
    @Environment(AppModel.self) private var modelo
    @Environment(\.openWindow) private var abrirVentana
    @Environment(\.openImmersiveSpace) private var abrirEspacio
    @Environment(\.dismissImmersiveSpace) private var cerrarEspacio

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List {
                NavigationLink("Planetas", value: Seccion.planetas)
                NavigationLink("Estrellas", value: Seccion.estrellas)
                NavigationLink("Galaxias", value: Seccion.galaxias)
            }
            .navigationTitle("Cosmos")
        } detail: {
            VStack(spacing: 20) {
                Text("Explora el Universo")
                    .font(.largeTitle)

                Text("Selecciona una categoria o abre una vista 3D")
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    // Abrir Volume
                    Button {
                        abrirVentana(id: "volumen-3d")
                    } label: {
                        Label("Ver en 3D", systemImage: "cube")
                    }
                    .buttonStyle(.borderedProminent)

                    // Abrir Immersive Space
                    Button {
                        Task {
                            await abrirEspacio(id: "espacio-inmersivo")
                        }
                    } label: {
                        Label("Experiencia Inmersiva", systemImage: "visionpro")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
}

enum Seccion: Hashable {
    case planetas, estrellas, galaxias
}
```

### Volumes — Contenido 3D Acotado

Un Volume es un cubo 3D donde puedes colocar entidades de RealityKit. El usuario puede mirar alrededor del volumen pero no entrar en el.

```swift
import SwiftUI
import RealityKit

// MARK: - Volume View
struct VolumenView: View {
    @State private var angulo: Angle = .zero
    @State private var estaRotando = false

    var body: some View {
        RealityView { content in
            // Crear una esfera como planeta
            let planeta = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(
                    color: .blue,
                    roughness: 0.3,
                    isMetallic: false
                )]
            )
            planeta.position = SIMD3(0, 0, 0)
            planeta.name = "planeta"

            // Agregar componente de interaccion
            planeta.components.set(InputTargetComponent())
            planeta.components.set(CollisionComponent(
                shapes: [.generateSphere(radius: 0.1)]
            ))

            // Crear un anillo alrededor
            let anillo = ModelEntity(
                mesh: .generateCylinder(height: 0.005, radius: 0.15),
                materials: [SimpleMaterial(
                    color: .init(white: 0.8, alpha: 0.6),
                    roughness: 0.5,
                    isMetallic: true
                )]
            )
            anillo.position = SIMD3(0, 0, 0)

            content.add(planeta)
            content.add(anillo)

        } update: { content in
            // Actualizar rotacion
            if let planeta = content.entities.first(where: { $0.name == "planeta" }) {
                planeta.transform.rotation = simd_quatf(
                    angle: Float(angulo.radians),
                    axis: SIMD3(0, 1, 0)
                )
            }
        }
        .gesture(
            // Tap espacial para interactuar
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { valor in
                    withAnimation(.spring(duration: 0.5)) {
                        estaRotando.toggle()
                    }
                }
        )
        .gesture(
            // Drag para rotar
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { valor in
                    let delta = valor.translation3D.x
                    angulo = .degrees(Double(delta) * 0.5)
                }
        )
        .onAppear {
            // Auto-rotacion
            if estaRotando {
                // Iniciar animacion continua
            }
        }
    }
}
```

### RealityKit — Entity Component System

RealityKit usa el patron Entity Component System (ECS): las entidades son contenedores, los componentes definen comportamiento, y los sistemas procesan logica.

```swift
import SwiftUI
import RealityKit

// MARK: - Componente Custom
struct InfoPlanetaComponent: Component {
    var nombre: String
    var radio: Float      // en km
    var distanciaSol: Float // en millones de km
    var tieneAnillos: Bool
}

// MARK: - Crear Sistema Solar Simplificado
struct SistemaSolarView: View {
    var body: some View {
        RealityView { content in
            // Sol
            let sol = crearEstrella(radio: 0.08, color: .yellow, nombre: "Sol")
            sol.position = SIMD3(0, 0, 0)
            content.add(sol)

            // Tierra
            let tierra = crearPlaneta(
                radio: 0.02,
                color: .systemBlue,
                nombre: "Tierra",
                distancia: 0.25
            )
            content.add(tierra)

            // Marte
            let marte = crearPlaneta(
                radio: 0.015,
                color: .init(red: 0.8, green: 0.3, blue: 0.1, alpha: 1),
                nombre: "Marte",
                distancia: 0.35
            )
            content.add(marte)

            // Jupiter
            let jupiter = crearPlaneta(
                radio: 0.04,
                color: .orange,
                nombre: "Jupiter",
                distancia: 0.5
            )
            content.add(jupiter)

            // Iluminacion
            let luz = DirectionalLight()
            luz.light.intensity = 1000
            luz.position = SIMD3(0, 0.5, 0.5)
            content.add(luz)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { valor in
                    let entidad = valor.entity
                    if let info = entidad.components[InfoPlanetaComponent.self] {
                        print("Tocaste: \(info.nombre)")
                    }
                }
        )
    }

    private func crearEstrella(radio: Float, color: UIColor, nombre: String) -> ModelEntity {
        let entidad = ModelEntity(
            mesh: .generateSphere(radius: radio),
            materials: [UnlitMaterial(color: color)]
        )
        entidad.name = nombre
        entidad.components.set(InputTargetComponent())
        entidad.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: radio)]
        ))
        return entidad
    }

    private func crearPlaneta(
        radio: Float,
        color: UIColor,
        nombre: String,
        distancia: Float
    ) -> ModelEntity {
        let entidad = ModelEntity(
            mesh: .generateSphere(radius: radio),
            materials: [SimpleMaterial(color: color, roughness: 0.5, isMetallic: false)]
        )
        entidad.name = nombre
        entidad.position = SIMD3(distancia, 0, 0)

        // Componentes de interaccion
        entidad.components.set(InputTargetComponent())
        entidad.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: radio)]
        ))

        // Componente custom
        entidad.components.set(InfoPlanetaComponent(
            nombre: nombre,
            radio: radio * 1000,
            distanciaSol: distancia * 100,
            tieneAnillos: nombre == "Jupiter"
        ))

        return entidad
    }
}
```

### Immersive Spaces — Experiencias Completas

```swift
import SwiftUI
import RealityKit

// MARK: - Espacio Inmersivo
struct EspacioInmersivoView: View {
    @Environment(\.dismissImmersiveSpace) private var cerrar
    @State private var estrellas: [Entity] = []

    var body: some View {
        RealityView { content in
            // Crear campo de estrellas
            for _ in 0..<200 {
                let estrella = ModelEntity(
                    mesh: .generateSphere(radius: 0.005),
                    materials: [UnlitMaterial(color: .white)]
                )

                // Posicion aleatoria en una esfera alrededor del usuario
                let theta = Float.random(in: 0...(2 * .pi))
                let phi = Float.random(in: 0...Float.pi)
                let radio: Float = Float.random(in: 3...8)

                estrella.position = SIMD3(
                    radio * sin(phi) * cos(theta),
                    radio * cos(phi),
                    radio * sin(phi) * sin(theta)
                )

                content.add(estrella)
            }

            // Agregar un planeta cercano
            let planetaCercano = ModelEntity(
                mesh: .generateSphere(radius: 0.5),
                materials: [SimpleMaterial(
                    color: .systemTeal,
                    roughness: 0.4,
                    isMetallic: false
                )]
            )
            planetaCercano.position = SIMD3(0, 1, -3)
            planetaCercano.name = "planetaCercano"
            planetaCercano.components.set(InputTargetComponent(allowedInputTypes: .all))
            planetaCercano.components.set(CollisionComponent(
                shapes: [.generateSphere(radius: 0.5)]
            ))

            content.add(planetaCercano)

        } update: { content in
            // Animaciones de actualizacion
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { valor in
                    // Interaccion con entidades en espacio inmersivo
                    let entidad = valor.entity
                    print("Interaccion con: \(entidad.name)")
                }
        )
    }
}
```

### Gestos Espaciales — Hand Tracking

visionOS usa eye tracking para apuntar y gestos de mano para interactuar. No hay cursor ni raton.

```swift
import SwiftUI
import RealityKit

// MARK: - Gestos en visionOS
struct GestosEspacialesView: View {
    @State private var escala: Float = 1.0
    @State private var rotacion: Angle = .zero

    var body: some View {
        RealityView { content in
            let cubo = ModelEntity(
                mesh: .generateBox(size: 0.2),
                materials: [SimpleMaterial(color: .purple, roughness: 0.3, isMetallic: true)]
            )
            cubo.name = "cubo"
            cubo.components.set(InputTargetComponent())
            cubo.components.set(CollisionComponent(
                shapes: [.generateBox(size: SIMD3(repeating: 0.2))]
            ))
            cubo.components.set(HoverEffectComponent())

            content.add(cubo)
        } update: { content in
            if let cubo = content.entities.first(where: { $0.name == "cubo" }) {
                cubo.transform.scale = SIMD3(repeating: escala)
            }
        }
        // Tap — mirar y pellizcar
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    print("Tap espacial detectado")
                }
        )
        // Drag — pellizcar y mover
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { valor in
                    // Mover entidad
                    let traduccion = valor.translation3D
                    valor.entity.position = SIMD3(
                        Float(traduccion.x) * 0.001,
                        Float(traduccion.y) * 0.001,
                        Float(traduccion.z) * 0.001
                    )
                }
        )
        // Magnify — pellizcar con dos manos para escalar
        .gesture(
            MagnifyGesture()
                .targetedToAnyEntity()
                .onChanged { valor in
                    escala = Float(valor.magnification)
                }
        )
        // Rotate — rotar con dos manos
        .gesture(
            RotateGesture3D()
                .targetedToAnyEntity()
                .onChanged { valor in
                    rotacion = valor.rotation.angle
                }
        )
    }
}
```

### Ornaments — UI Flotante Vinculada a Windows

```swift
import SwiftUI

// MARK: - Ornaments
struct VentanaConOrnamentos: View {
    @State private var mostrarInfo = false

    var body: some View {
        VStack {
            Text("Contenido Principal")
                .font(.title)

            Image(systemName: "globe.americas.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
        }
        .padding(40)
        // Ornament — UI flotante en el borde de la window
        .ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.bottom)
        ) {
            HStack(spacing: 16) {
                Button("Info") { mostrarInfo.toggle() }
                Button("Rotar") { /* accion */ }
                Button("Escala") { /* accion */ }
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}
```

#### Diagrama de Arquitectura visionOS

```
  ┌──────────────────────────────────────────────────────┐
  │            NIVELES DE INMERSION visionOS              │
  │                                                       │
  │  SHARED SPACE          MIXED            FULL          │
  │  ┌──────────┐    ┌──────────────┐  ┌──────────────┐ │
  │  │ Window 1 │    │ Mundo Real   │  │ Entorno      │ │
  │  │ Window 2 │    │ + Contenido  │  │ Virtual      │ │
  │  │ Volume   │    │   3D tuyo    │  │ Completo     │ │
  │  └──────────┘    └──────────────┘  └──────────────┘ │
  │  Multiples apps    Tu app + real     Solo tu app     │
  │                                                       │
  │  CONTENEDORES DE ESCENA:                              │
  │  ┌────────────────────────────────────────────────┐  │
  │  │ WindowGroup        → SwiftUI 2D flotante       │  │
  │  │ WindowGroup         → Contenido 3D acotado     │  │
  │  │  .volumetric                                    │  │
  │  │ ImmersiveSpace     → Experiencia completa       │  │
  │  └────────────────────────────────────────────────┘  │
  │                                                       │
  │  INTERACCION:                                         │
  │  ┌────────────────────────────────────────────────┐  │
  │  │  Ojos (apuntar) + Manos (actuar)               │  │
  │  │                                                 │  │
  │  │  SpatialTapGesture  → Mirar + pellizcar        │  │
  │  │  DragGesture        → Pellizcar y mover        │  │
  │  │  MagnifyGesture     → Dos manos, escalar       │  │
  │  │  RotateGesture3D    → Dos manos, rotar         │  │
  │  │  HoverEffect        → Highlight al mirar       │  │
  │  └────────────────────────────────────────────────┘  │
  │                                                       │
  │  REALITYKIT (Entity Component System):                │
  │  Entity ← Component[] ← System procesa logica        │
  │  ModelEntity: mesh + material + transform             │
  └──────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: App con Window y Ornaments (Basico)

**Objetivo**: Crear una app visionOS con ventana principal y ornamentos.

**Requisitos**:
1. Ventana principal con NavigationSplitView (sidebar + detail)
2. Sidebar con lista de elementos (ej: planetas, monumentos, o productos)
3. Vista de detalle con imagen, titulo y descripcion
4. Ornament inferior con controles: favorito, compartir, info
5. Usar `.glassBackgroundEffect()` para efecto de cristal
6. Hover effects en elementos interactivos

---

## Ejercicio 2: Volume con Modelo 3D Interactivo (Intermedio)

**Objetivo**: Crear un volumen con contenido 3D manipulable.

**Requisitos**:
1. Boton en la window principal para abrir el volumen (`openWindow`)
2. RealityView con al menos 3 entidades (esferas, cubos, o modelos)
3. SpatialTapGesture para seleccionar entidades y mostrar info
4. DragGesture para mover entidades en el espacio
5. MagnifyGesture para escalar el contenido
6. Componente custom (Component) con datos asociados a cada entidad

---

## Ejercicio 3: Immersive Space con Sistema Solar (Avanzado)

**Objetivo**: Crear una experiencia inmersiva completa con RealityKit.

**Requisitos**:
1. Boton para abrir ImmersiveSpace desde la window principal
2. Campo de estrellas generado proceduralmente (100+ entidades pequenas)
3. Al menos 4 planetas con tamanos y colores distintos
4. Tap en un planeta muestra panel informativo (window overlay)
5. Soporte para mixed y full immersion (selector en la window)
6. Boton para cerrar el espacio inmersivo y volver a la window
7. Iluminacion direccional que simule una estrella central

---

## 5 Errores Comunes

### 1. Abrir multiples ImmersiveSpaces simultaneamente
```swift
// MAL — solo puede haber un ImmersiveSpace a la vez
Button("Abrir Espacio 1") {
    Task { await openImmersiveSpace(id: "espacio1") }
}
Button("Abrir Espacio 2") {
    Task { await openImmersiveSpace(id: "espacio2") } // falla si espacio1 esta abierto
}

// BIEN — cerrar el anterior antes de abrir otro
Button("Cambiar a Espacio 2") {
    Task {
        await dismissImmersiveSpace()
        await openImmersiveSpace(id: "espacio2")
    }
}
```

### 2. Entidades sin InputTargetComponent ni CollisionComponent
```swift
// MAL — la entidad no responde a gestos
let cubo = ModelEntity(mesh: .generateBox(size: 0.2))
content.add(cubo)
// SpatialTapGesture nunca detecta este cubo

// BIEN — agregar componentes de interaccion
let cubo = ModelEntity(mesh: .generateBox(size: 0.2))
cubo.components.set(InputTargetComponent())
cubo.components.set(CollisionComponent(
    shapes: [.generateBox(size: SIMD3(repeating: 0.2))]
))
content.add(cubo) // ahora responde a gestos
```

### 3. Usar .targetedToAnyEntity() sin necesidad
```swift
// MAL — captura gestos de TODAS las entidades
.gesture(
    SpatialTapGesture()
        .targetedToAnyEntity() // puede causar conflictos
        .onEnded { _ in }
)

// BIEN — cuando necesitas saber cual entidad, usa el valor
.gesture(
    SpatialTapGesture()
        .targetedToAnyEntity()
        .onEnded { valor in
            let entidadTocada = valor.entity // identificar cual
            print("Tocaste: \(entidadTocada.name)")
        }
)
```

### 4. Ignorar las guias de diseno espacial (HIG)
```swift
// MAL — texto demasiado pequeno, colores sin contraste
Text("Informacion importante")
    .font(.caption2)        // ilegible a distancia
    .foregroundStyle(.gray) // bajo contraste en entorno mixto

// BIEN — texto legible, contraste apropiado
Text("Informacion importante")
    .font(.title2)           // legible a distancia tipica (~1.5m)
    .foregroundStyle(.primary)
    .padding()
    .glassBackgroundEffect() // fondo que asegura legibilidad
```

### 5. No manejar el ciclo de vida del ImmersiveSpace
```swift
// MAL — no limpiar recursos al cerrar
ImmersiveSpace(id: "mi-espacio") {
    RealityView { content in
        cargarModelos(content) // carga pesada
    }
    // nunca se limpian los modelos al cerrar
}

// BIEN — limpiar con onDisappear
ImmersiveSpace(id: "mi-espacio") {
    RealityView { content in
        cargarModelos(content)
    }
    .onDisappear {
        limpiarRecursos()
        liberarModelos()
    }
}
```

---

## Checklist

- [ ] Entender los tres niveles de inmersion: shared, mixed, full
- [ ] Crear una app con WindowGroup como punto de entrada
- [ ] Usar RealityView para mostrar contenido 3D
- [ ] Implementar un Volume con `.windowStyle(.volumetric)`
- [ ] Crear un ImmersiveSpace y manejarlo con open/dismiss
- [ ] Usar SpatialTapGesture, DragGesture y MagnifyGesture
- [ ] Crear entidades con InputTargetComponent y CollisionComponent
- [ ] Implementar componentes custom (Component) para datos
- [ ] Usar ornaments para UI flotante vinculada a windows
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

visionOS abre nuevas dimensiones para el Proyecto Integrador:
- **Windows** como punto de entrada principal — tu app iOS funciona como window sin cambios
- **Volumes** para visualizar datos 3D del proyecto (graficas, modelos, estadisticas espaciales)
- **ImmersiveSpace** para experiencias premium (recorridos, visualizaciones inmersivas)
- **Ornaments** para controles contextuales flotantes sin ocupar espacio de contenido
- **Gestos espaciales** para interacciones naturales con el contenido del proyecto
- **Codigo compartido** con iOS/iPadOS — misma logica de negocio, presentacion adaptada

---

*Leccion 32 | visionOS — Apps Espaciales | Semana 41 | Modulo 08: Plataformas*
*Siguiente: Leccion 33 — macOS e iPadOS: Productividad Multi-Plataforma*
