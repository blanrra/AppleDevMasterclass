# Leccion 42: Metal y Graficos

**Modulo 12: Extras y Especializacion** | Semana 51

---

## TL;DR — Resumen en 2 minutos

- **Metal** es la API de graficos de bajo nivel de Apple — acceso directo a la GPU para rendimiento maximo
- **Shaders** se escriben en Metal Shading Language (MSL) — C++ adaptado para GPU con tipos SIMD
- **SpriteKit** simplifica juegos 2D — SKScene, SKNode, SKAction y fisicas integradas
- **SceneKit** maneja 3D sin Metal directo — SCNScene, SCNNode, materiales PBR y fisicas
- **RealityKit** es el framework moderno para AR/VR — integrado con visionOS y ARKit

> Herramienta: **Metal System Trace** en Instruments para analizar rendimiento GPU

---

## Cupertino MCP

```bash
cupertino search "Metal framework"
cupertino search "MTLDevice"
cupertino search "MTLRenderPipelineDescriptor"
cupertino search "SpriteKit"
cupertino search "SceneKit"
cupertino search "RealityKit"
cupertino search --source apple-docs "Metal Shading Language"
cupertino search --source hig "graphics performance"
cupertino search --source samples "Metal"
cupertino search --source updates "Metal 4"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | What's New in Metal | Novedades Metal 4 |
| WWDC24 | [Bring your Metal app to Apple Vision Pro](https://developer.apple.com/videos/play/wwdc2024/) | Metal en visionOS |
| WWDC23 | [Discover Metal for immersive apps](https://developer.apple.com/videos/play/wwdc2023/) | Metal moderno |
| WWDC22 | [Optimize Metal performance for Apple silicon](https://developer.apple.com/videos/play/wwdc2022/) | **Esencial** — rendimiento |
| EN | [Metal by Example](https://metalbyexample.com) | Tutoriales Metal paso a paso |
| EN | [Ray Wenderlich — Metal](https://www.kodeco.com) | Graficos 2D/3D con Metal |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Aprender Graficos?

Incluso si no vas a crear juegos, entender graficos te convierte en un desarrollador mas completo. Metal es la base sobre la que corre SwiftUI, MapKit, Core Animation y cualquier cosa visual en Apple. Cuando animas una vista con `.animation()`, Metal esta trabajando debajo. Cuando usas `Canvas` en SwiftUI para dibujo custom, estas a un paso de Metal. Y con visionOS, la demanda de habilidades 3D solo crece.

La pregunta correcta no es "Metal vs SpriteKit vs SceneKit" sino "cual es el nivel de abstraccion que necesito?" Metal te da control total pero requiere mas codigo. SpriteKit y SceneKit te dan productividad a cambio de control.

### Metal — La Base de Todo

Metal es la API de bajo nivel que habla directamente con la GPU. Todo empieza con un `MTLDevice` — la representacion de la GPU fisica.

```swift
import Metal
import MetalKit
import SwiftUI

// MARK: - Setup basico de Metal
class RendererBasico: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState

    init?(metalKitView: MTKView) {
        // 1. Obtener la GPU
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal no esta soportado en este dispositivo")
            return nil
        }
        self.device = device
        metalKitView.device = device

        // 2. Crear command queue — cola de comandos para la GPU
        guard let queue = device.makeCommandQueue() else {
            return nil
        }
        self.commandQueue = queue

        // 3. Configurar el pipeline de renderizado
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat

        do {
            self.pipelineState = try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor
            )
        } catch {
            print("Error creando pipeline: \(error)")
            return nil
        }

        super.init()
    }
}

// MARK: - Rendering loop
extension RendererBasico: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Actualizar cuando cambia el tamano de la vista
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        // Color de fondo
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0
        )

        // Crear command buffer y encoder
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                  descriptor: renderPassDescriptor
              ) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)

        // Dibujar un triangulo (3 vertices)
        renderEncoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 3
        )

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
```

### Metal Shading Language — Programar la GPU

Los shaders son programas que corren en la GPU. El vertex shader posiciona los vertices, el fragment shader les da color.

```metal
// Shaders.metal — Metal Shading Language (MSL)
#include <metal_stdlib>
using namespace metal;

// Estructura de vertice
struct VertexOut {
    float4 position [[position]];
    float4 color;
};

// MARK: - Vertex Shader
// Se ejecuta una vez por cada vertice
vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
    // Definir un triangulo directamente en el shader
    float2 positions[3] = {
        float2( 0.0,  0.5),  // arriba
        float2(-0.5, -0.5),  // abajo izquierda
        float2( 0.5, -0.5)   // abajo derecha
    };

    float4 colors[3] = {
        float4(1.0, 0.0, 0.0, 1.0),  // rojo
        float4(0.0, 1.0, 0.0, 1.0),  // verde
        float4(0.0, 0.0, 1.0, 1.0)   // azul
    };

    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.color = colors[vertexID];
    return out;
}

// MARK: - Fragment Shader
// Se ejecuta una vez por cada pixel
fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return in.color; // interpola colores entre vertices
}
```

### Metal en SwiftUI — Integracion con MetalKit

```swift
import SwiftUI
import MetalKit

// MARK: - MetalView para SwiftUI
struct MetalView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = false // render continuo

        if let renderer = RendererBasico(metalKitView: view) {
            view.delegate = renderer
            context.coordinator.renderer = renderer
        }
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var renderer: RendererBasico?
    }
}

// Uso en SwiftUI
struct MetalDemoView: View {
    var body: some View {
        VStack {
            Text("Triangulo Metal")
                .font(.title)
            MetalView()
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}
```

### SpriteKit — Juegos 2D Simplificados

SpriteKit abstrae Metal para juegos 2D. No necesitas manejar shaders ni buffers directamente.

```swift
import SpriteKit
import SwiftUI

// MARK: - Escena SpriteKit
class JuegoEspacialScene: SKScene, SKPhysicsContactDelegate {

    // Categorias de fisicas (bitmask)
    struct Categoria {
        static let nave: UInt32      = 0x1 << 0  // 1
        static let asteroide: UInt32 = 0x1 << 1  // 2
        static let disparo: UInt32   = 0x1 << 2  // 4
    }

    private var nave: SKSpriteNode!
    private var puntuacion = 0
    private var labelPuntuacion: SKLabelNode!

    override func didMove(to view: SKView) {
        // Fondo estrellado
        backgroundColor = .black
        crearEstrellas()

        // Configurar fisicas
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        // Crear nave
        nave = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 50))
        nave.position = CGPoint(x: size.width / 2, y: 100)
        nave.physicsBody = SKPhysicsBody(rectangleOf: nave.size)
        nave.physicsBody?.isDynamic = false
        nave.physicsBody?.categoryBitMask = Categoria.nave
        nave.physicsBody?.contactTestBitMask = Categoria.asteroide
        addChild(nave)

        // Label de puntuacion
        labelPuntuacion = SKLabelNode(text: "Puntos: 0")
        labelPuntuacion.fontName = "Menlo-Bold"
        labelPuntuacion.fontSize = 20
        labelPuntuacion.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(labelPuntuacion)

        // Generar asteroides periodicamente
        let generarAsteroide = SKAction.run { [weak self] in
            self?.crearAsteroide()
        }
        let esperar = SKAction.wait(forDuration: 1.0, withRange: 0.5)
        run(SKAction.repeatForever(SKAction.sequence([generarAsteroide, esperar])))
    }

    private func crearEstrellas() {
        if let estrellas = SKEmitterNode(fileNamed: "Estrellas") {
            estrellas.position = CGPoint(x: size.width / 2, y: size.height)
            estrellas.zPosition = -1
            addChild(estrellas)
        }
    }

    private func crearAsteroide() {
        let tamano = CGFloat.random(in: 20...50)
        let asteroide = SKSpriteNode(color: .gray, size: CGSize(width: tamano, height: tamano))
        asteroide.position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: size.height + tamano
        )

        asteroide.physicsBody = SKPhysicsBody(rectangleOf: asteroide.size)
        asteroide.physicsBody?.categoryBitMask = Categoria.asteroide
        asteroide.physicsBody?.contactTestBitMask = Categoria.disparo
        addChild(asteroide)

        // Mover hacia abajo y eliminar
        let mover = SKAction.moveTo(y: -tamano, duration: Double.random(in: 3...6))
        let eliminar = SKAction.removeFromParent()
        asteroide.run(SKAction.sequence([mover, eliminar]))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let posicion = touch.location(in: self)
        nave.position.x = posicion.x
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        disparar()
    }

    private func disparar() {
        let disparo = SKSpriteNode(color: .yellow, size: CGSize(width: 4, height: 12))
        disparo.position = CGPoint(x: nave.position.x, y: nave.position.y + 30)

        disparo.physicsBody = SKPhysicsBody(rectangleOf: disparo.size)
        disparo.physicsBody?.categoryBitMask = Categoria.disparo
        disparo.physicsBody?.contactTestBitMask = Categoria.asteroide
        disparo.physicsBody?.isDynamic = true
        addChild(disparo)

        let mover = SKAction.moveTo(y: size.height + 20, duration: 0.5)
        disparo.run(SKAction.sequence([mover, .removeFromParent()]))
    }

    // Deteccion de colisiones
    func didBegin(_ contact: SKPhysicsContact) {
        let mascaras = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if mascaras == Categoria.disparo | Categoria.asteroide {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            puntuacion += 10
            labelPuntuacion.text = "Puntos: \(puntuacion)"
        }
    }
}

// MARK: - SpriteKit en SwiftUI
struct JuegoEspacialView: View {
    var body: some View {
        SpriteView(
            scene: {
                let scene = JuegoEspacialScene()
                scene.size = CGSize(width: 390, height: 844)
                scene.scaleMode = .aspectFill
                return scene
            }(),
            options: [.ignoresSiblingOrder, .shouldCullNonVisibleNodes]
        )
        .ignoresSafeArea()
    }
}
```

### SceneKit — 3D sin Metal Directo

```swift
import SceneKit
import SwiftUI

// MARK: - Escena 3D con SceneKit
struct Escena3DView: View {
    var body: some View {
        SceneView(
            scene: crearEscena(),
            pointOfView: crearCamara(),
            options: [.autoenablesDefaultLighting, .allowsCameraControl]
        )
    }

    private func crearEscena() -> SCNScene {
        let escena = SCNScene()

        // Esfera con material PBR
        let esfera = SCNSphere(radius: 1.0)
        let materialEsfera = SCNMaterial()
        materialEsfera.lightingModel = .physicallyBased
        materialEsfera.diffuse.contents = UIColor.systemBlue
        materialEsfera.metalness.contents = 0.8
        materialEsfera.roughness.contents = 0.2
        esfera.materials = [materialEsfera]

        let nodoEsfera = SCNNode(geometry: esfera)
        nodoEsfera.position = SCNVector3(0, 0.5, 0)
        escena.rootNode.addChildNode(nodoEsfera)

        // Animacion de rotacion
        let rotacion = SCNAction.rotateBy(
            x: 0, y: .pi * 2, z: 0,
            duration: 4
        )
        nodoEsfera.runAction(SCNAction.repeatForever(rotacion))

        // Piso
        let piso = SCNFloor()
        piso.reflectivity = 0.3
        let materialPiso = SCNMaterial()
        materialPiso.diffuse.contents = UIColor.darkGray
        piso.materials = [materialPiso]
        escena.rootNode.addChildNode(SCNNode(geometry: piso))

        // Luz
        let luz = SCNLight()
        luz.type = .directional
        luz.intensity = 1000
        let nodoLuz = SCNNode()
        nodoLuz.light = luz
        nodoLuz.position = SCNVector3(5, 10, 5)
        nodoLuz.look(at: SCNVector3(0, 0, 0))
        escena.rootNode.addChildNode(nodoLuz)

        return escena
    }

    private func crearCamara() -> SCNNode {
        let camara = SCNCamera()
        camara.fieldOfView = 60
        let nodoCamara = SCNNode()
        nodoCamara.camera = camara
        nodoCamara.position = SCNVector3(3, 3, 5)
        nodoCamara.look(at: SCNVector3(0, 0.5, 0))
        return nodoCamara
    }
}
```

#### Diagrama — Elegir el Framework Correcto

```
  ┌──────────────────────────────────────────────────────────┐
  │          ELEGIR EL FRAMEWORK DE GRAFICOS                  │
  │                                                           │
  │  NIVEL DE ABSTRACCION:                                    │
  │                                                           │
  │  Alto    ┌─────────────┐  ┌─────────────┐               │
  │          │  SpriteKit  │  │  SceneKit   │               │
  │          │  Juegos 2D  │  │  3D general │               │
  │          │  UI custom  │  │  Visualiz.  │               │
  │          └──────┬──────┘  └──────┬──────┘               │
  │                 │                │                        │
  │  Medio   ┌──────┴────────────────┴──────┐               │
  │          │        RealityKit            │               │
  │          │   AR/VR, visionOS, 3D        │               │
  │          │   con Entity-Component       │               │
  │          └──────────────┬───────────────┘               │
  │                         │                                │
  │  Bajo    ┌──────────────┴───────────────┐               │
  │          │          Metal               │               │
  │          │   Control total de GPU       │               │
  │          │   Shaders custom, compute    │               │
  │          │   Rendimiento maximo         │               │
  │          └──────────────────────────────┘               │
  │                                                           │
  │  DECISION:                                                │
  │  - Juego 2D casual → SpriteKit                           │
  │  - Visualizacion 3D → SceneKit                           │
  │  - AR/VR, visionOS → RealityKit                          │
  │  - Rendimiento critico, post-processing → Metal          │
  │  - Filtros de imagen → Core Image (usa Metal internamente)│
  └──────────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: Triangulo Animado con Metal (Basico)

**Objetivo**: Crear una vista Metal que dibuje un triangulo que cambie de color con el tiempo.

**Requisitos**:
1. Configurar MTLDevice, command queue y render pipeline
2. Escribir vertex shader que posicione un triangulo centrado
3. Escribir fragment shader que use un uniform `time` para animar el color
4. Integrar la vista Metal en SwiftUI con `UIViewRepresentable`
5. El triangulo debe rotar suavemente (pasar tiempo como uniform al vertex shader)
6. Mostrar FPS en una label superpuesta

---

## Ejercicio 2: Juego 2D con SpriteKit (Intermedio)

**Objetivo**: Crear un juego simple de plataformas con SpriteKit.

**Requisitos**:
1. Personaje controlable con gestos (tap para saltar, swipe para mover)
2. Plataformas generadas proceduralmente que suben desde abajo
3. Sistema de fisicas con gravedad y colisiones
4. Sistema de puntuacion basado en altura alcanzada
5. Particulas (SKEmitterNode) para efectos visuales al saltar y al perder
6. Integracion con SwiftUI usando `SpriteView` y controles de pausa/reinicio
7. Al menos 3 tipos de plataformas: normal, rompible y con resorte

---

## Ejercicio 3: Escena 3D Interactiva con SceneKit (Avanzado)

**Objetivo**: Crear un visor 3D interactivo con materiales PBR y animaciones.

**Requisitos**:
1. Escena con al menos 5 objetos 3D diferentes (esfera, cubo, cilindro, cono, torus)
2. Materiales PBR con metalness, roughness y diferentes colores
3. Sistema de iluminacion con luz ambiental, direccional y spot
4. Control de camara libre con gestos (rotar, zoom, pan)
5. Tap en un objeto para seleccionarlo y mostrar un panel de propiedades en SwiftUI
6. Animaciones de objetos: rotacion, traslacion y escala
7. Exportar la escena como imagen con `SCNRenderer.snapshot()`

---

## 5 Errores Comunes

### 1. No verificar soporte de Metal
```swift
// MAL — asumir que Metal esta disponible
let device = MTLCreateSystemDefaultDevice()! // crash en simulador antiguo

// BIEN — verificar disponibilidad
guard let device = MTLCreateSystemDefaultDevice() else {
    // Fallback a software rendering o mostrar mensaje
    print("Metal no esta disponible")
    return
}
```

### 2. No liberar command buffers en SpriteKit
```swift
// MAL — crear nodos sin limpiar
override func update(_ currentTime: TimeInterval) {
    crearParticula() // crea un nodo cada frame = memory leak
}

// BIEN — limpiar nodos fuera de pantalla
override func update(_ currentTime: TimeInterval) {
    enumerateChildNodes(withName: "particula") { nodo, _ in
        if nodo.position.y < -100 {
            nodo.removeFromParent()
        }
    }
}
```

### 3. Render loop innecesario en Metal
```swift
// MAL — renderizar a 60fps cuando la escena es estatica
let view = MTKView()
view.preferredFramesPerSecond = 60
view.isPaused = false // siempre renderizando

// BIEN — renderizar solo cuando hay cambios
let view = MTKView()
view.enableSetNeedsDisplay = true // render bajo demanda
view.isPaused = true
// Cuando algo cambia:
view.setNeedsDisplay() // solicitar un solo frame
```

### 4. No usar el coordinate system correcto en SpriteKit
```swift
// MAL — posicionar relativo a la esquina sin considerar escala
nodo.position = CGPoint(x: 200, y: 400) // posicion absoluta, se rompe en otros dispositivos

// BIEN — posicionar relativo al tamano de la escena
nodo.position = CGPoint(
    x: size.width / 2,   // centrado horizontal
    y: size.height * 0.8  // 80% de la altura
)
```

### 5. Mezclar SceneKit y Metal sin cuidado
```swift
// MAL — crear un MTLDevice diferente al de SceneKit
let miDevice = MTLCreateSystemDefaultDevice()! // nuevo device
let scnRenderer = SCNRenderer(device: miDevice) // puede no ser el mismo GPU

// BIEN — reutilizar el device de SceneKit
let scnView = SCNView()
let device = scnView.device! // el device que SceneKit ya usa
// Usar este device para operaciones Metal custom
```

---

## Checklist

- [ ] Entender el pipeline de renderizado: CPU → Command Buffer → GPU → Framebuffer
- [ ] Configurar Metal basico: MTLDevice, CommandQueue, RenderPipeline
- [ ] Escribir un vertex shader y fragment shader en MSL
- [ ] Integrar MetalKit (MTKView) con SwiftUI
- [ ] Crear una escena SpriteKit con nodos, acciones y fisicas
- [ ] Usar SpriteView para integrar SpriteKit en SwiftUI
- [ ] Crear una escena SceneKit con geometria, materiales y luces
- [ ] Implementar control de camara en SceneKit
- [ ] Decidir correctamente entre Metal, SpriteKit, SceneKit y RealityKit
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Los graficos enriquecen el Proyecto Integrador de varias formas:
- **Metal shaders custom** para efectos visuales unicos — gradientes animados, transiciones, filtros
- **SpriteKit** para elementos gamificados — confetti al completar tareas, animaciones de logros
- **SceneKit** para visualizaciones 3D de datos — graficos tridimensionales interactivos
- **Canvas de SwiftUI** para dibujo vectorial custom — charts personalizados, indicadores
- **Core Image con Metal** para filtros de imagen en tiempo real si tu app maneja fotos
- **RealityKit** para la version visionOS del proyecto — contenido espacial inmersivo
- **Performance profiling** con Metal System Trace para garantizar 60fps en animaciones

---

*Leccion 42 | Metal y Graficos | Semana 51 | Modulo 12: Extras y Especializacion*
*Siguiente: Leccion 43 — Combine (Legacy Reference)*
