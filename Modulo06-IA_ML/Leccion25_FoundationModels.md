# Leccion 25: Foundation Models

**Modulo 06: IA y ML** | Semanas 31-32

---

## TL;DR — Resumen en 2 minutos

- **Foundation Models**: Framework de IA on-device de Apple — modelos de lenguaje que corren localmente sin enviar datos a ningun servidor
- **LanguageModelSession**: La sesion para interactuar con el modelo — enviar prompts, recibir respuestas, mantener contexto
- **@Generable**: Macro que convierte un struct en salida estructurada — el modelo devuelve tipos Swift, no solo texto
- **Streaming**: Respuestas progresivas token a token — UX fluida sin esperar a que termine la generacion completa
- **Tool Calling**: El modelo puede invocar funciones de tu app — buscar datos, ejecutar logica, conectar con APIs

---

## Cupertino MCP

```bash
cupertino search "Foundation Models"
cupertino search "LanguageModelSession"
cupertino search "@Generable"
cupertino search "SystemLanguageModel"
cupertino search "GenerableContent"
cupertino search "Tool foundation models"
cupertino search "@Guide"
cupertino search --source samples "Foundation Models"
cupertino search --source updates "Foundation Models"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | [Introducing Foundation Models](https://developer.apple.com/videos/play/wwdc2025/10604/) | **Esencial** — Introduccion oficial |
| WWDC25 | [Build app features with Foundation Models](https://developer.apple.com/videos/play/wwdc2025/10605/) | **Esencial** — Implementacion practica |
| WWDC25 | [Structured generation with Foundation Models](https://developer.apple.com/videos/play/wwdc2025/10606/) | @Generable y salida estructurada |
| WWDC25 | [Tool calling with Foundation Models](https://developer.apple.com/videos/play/wwdc2025/10607/) | Herramientas y agentes |
| :es: | [Apple Coding — Foundation Models](https://www.youtube.com/@AppleCodingAcademy) | Serie en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que Foundation Models?

Hasta ahora, usar IA en apps iOS significaba depender de APIs externas (OpenAI, Google) o cargar modelos pesados con CoreML. Apple cambio las reglas con Foundation Models: un framework que expone el modelo de lenguaje del sistema (el mismo que usa Apple Intelligence) directamente a los desarrolladores.

La clave es que todo corre **on-device**. Ningun dato sale del iPhone/iPad/Mac. Esto significa privacidad total, sin costos de API, funciona offline, y latencia minima.

```
  ┌──────────────────────────────────────────────────────────┐
  │              ARQUITECTURA FOUNDATION MODELS               │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   Tu App                                                 │
  │   ├─ LanguageModelSession                                │
  │   │  ├─ .respond(to: prompt)     → String               │
  │   │  ├─ .streamResponse(to:)     → AsyncSequence        │
  │   │  └─ .respond(to:, generating: Tipo.self) → Tipo     │
  │   │                                                      │
  │   ▼                                                      │
  │   ┌─────────────────────────────────────────┐            │
  │   │     SystemLanguageModel                 │            │
  │   │     (Apple Intelligence on-device)      │            │
  │   │  ┌─────────────────────────────────┐    │            │
  │   │  │  Guardrails (seguridad)         │    │            │
  │   │  │  Context Window (gestion)       │    │            │
  │   │  │  Tool Calling (extensibilidad)  │    │            │
  │   │  └─────────────────────────────────┘    │            │
  │   └─────────────────────────────────────────┘            │
  │                                                          │
  │   Todo on-device — ningun dato sale del dispositivo      │
  └──────────────────────────────────────────────────────────┘
```

### SystemLanguageModel — Verificar Disponibilidad

No todos los dispositivos soportan Foundation Models. Necesitas verificar disponibilidad antes de usar el modelo.

```swift
import FoundationModels

// MARK: - Verificar disponibilidad del modelo

func verificarModelo() async {
    let disponibilidad = SystemLanguageModel.default.availability

    switch disponibilidad {
    case .available:
        print("Modelo listo para usar")
    case .unavailable(.deviceNotSupported):
        print("Este dispositivo no soporta Apple Intelligence")
    case .unavailable(.appleIntelligenceNotEnabled):
        print("El usuario no ha habilitado Apple Intelligence")
    case .unavailable(.modelNotReady):
        print("El modelo se esta descargando, intentar mas tarde")
    default:
        print("Modelo no disponible")
    }
}
```

> **Importante**: Foundation Models requiere dispositivos con Apple Intelligence (iPhone 15 Pro+, iPad con M1+, Mac con M1+). Siempre ten un fallback para dispositivos no soportados.

### LanguageModelSession — Tu Puerta de Entrada

`LanguageModelSession` es el objeto principal. Creas una sesion, envias un prompt, y recibes una respuesta.

```swift
import FoundationModels

// MARK: - Sesion basica

func generarRespuesta() async throws {
    let sesion = LanguageModelSession()

    // Prompt simple — respuesta completa
    let respuesta = try await sesion.respond(to: "Resume en una oracion que es SwiftUI")
    print(respuesta.content) // "SwiftUI es el framework declarativo de Apple..."
}
```

#### Instrucciones del sistema

Puedes configurar el comportamiento del modelo con instrucciones de sistema que definen el rol y las reglas.

```swift
import FoundationModels

// MARK: - Sesion con instrucciones

func asistenteFitness() async throws {
    let instrucciones = """
    Eres un asistente de fitness. Responde de forma concisa y motivadora.
    No des consejos medicos. Siempre recomienda consultar a un profesional.
    Responde en espanol.
    """

    let sesion = LanguageModelSession(instructions: instrucciones)

    let respuesta = try await sesion.respond(
        to: "Dame una rutina de 15 minutos para principiantes"
    )
    print(respuesta.content)
}
```

### Streaming — Respuestas Progresivas

Para UX fluida, usa streaming. El texto aparece token a token, como en ChatGPT.

```swift
import FoundationModels
import SwiftUI

// MARK: - Vista con streaming

struct ChatStreamView: View {
    @State private var textoGenerado = ""
    @State private var generando = false

    var body: some View {
        VStack {
            ScrollView {
                Text(textoGenerado)
                    .padding()
            }

            Button(generando ? "Generando..." : "Generar") {
                Task { await generar() }
            }
            .disabled(generando)
        }
    }

    func generar() async {
        generando = true
        textoGenerado = ""

        let sesion = LanguageModelSession()

        do {
            let stream = sesion.streamResponse(
                to: "Explica 3 beneficios de Swift sobre Objective-C"
            )

            for try await fragmento in stream {
                textoGenerado = fragmento.content
            }
        } catch {
            textoGenerado = "Error: \(error.localizedDescription)"
        }

        generando = false
    }
}
```

### @Generable — Salida Estructurada

Aqui es donde Foundation Models brilla frente a otras APIs de IA. Con `@Generable`, el modelo no devuelve texto libre — devuelve **tipos Swift**.

```swift
import FoundationModels

// MARK: - Salida estructurada con @Generable

@Generable
struct Receta {
    @Guide(description: "Nombre del plato")
    var nombre: String

    @Guide(description: "Lista de ingredientes con cantidades")
    var ingredientes: [String]

    @Guide(description: "Pasos de preparacion ordenados")
    var pasos: [String]

    @Guide(description: "Tiempo total en minutos", .range(5...180))
    var tiempoMinutos: Int

    @Guide(description: "Nivel de dificultad", .options(.easy, .medium, .hard))
    var dificultad: Dificultad
}

@Generable
enum Dificultad: String {
    case easy = "Facil"
    case medium = "Media"
    case hard = "Dificil"
}
```

#### Usar @Generable en una sesion

```swift
import FoundationModels

// MARK: - Generar contenido estructurado

func generarReceta() async throws {
    let sesion = LanguageModelSession()

    // El modelo devuelve un struct Receta, no texto libre
    let receta: Receta = try await sesion.respond(
        to: "Dame una receta mexicana facil con pollo",
        generating: Receta.self
    )

    print("Plato: \(receta.nombre)")
    print("Tiempo: \(receta.tiempoMinutos) minutos")
    print("Dificultad: \(receta.dificultad.rawValue)")

    for (i, paso) in receta.pasos.enumerated() {
        print("\(i + 1). \(paso)")
    }
}
```

### @Guide — Guiar la Generacion

`@Guide` le da contexto al modelo sobre que esperas en cada campo. Puedes agregar descripciones y restricciones.

```swift
import FoundationModels

// MARK: - Restricciones con @Guide

@Generable
struct ResumenPelicula {
    @Guide(description: "Titulo original de la pelicula")
    var titulo: String

    @Guide(description: "Anio de estreno", .range(1900...2026))
    var anio: Int

    @Guide(description: "Generos principales, maximo 3")
    var generos: [String]

    @Guide(description: "Puntuacion de 1 a 10", .range(1...10))
    var puntuacion: Int

    @Guide(description: "Resumen sin spoilers en maximo 2 oraciones")
    var resumen: String
}
```

### Tool Calling — El Modelo Ejecuta Codigo

Tool calling permite que el modelo invoque funciones de tu app. El modelo decide CUANDO usar una herramienta basandose en el contexto.

```swift
import FoundationModels

// MARK: - Definir una herramienta

struct BuscarClima: Tool {
    let name = "buscar_clima"
    let description = "Busca el clima actual de una ciudad"

    @Generable
    struct Parametros {
        @Guide(description: "Nombre de la ciudad")
        var ciudad: String
    }

    @Generable
    struct Resultado {
        var temperatura: Int
        var condicion: String
    }

    func call(_ parametros: Parametros) async throws -> Resultado {
        // Aqui conectarias con tu API de clima
        // Simulacion para el ejemplo
        return Resultado(
            temperatura: 24,
            condicion: "Soleado"
        )
    }
}
```

#### Usar tools en una sesion

```swift
import FoundationModels

// MARK: - Sesion con herramientas

func asistenteConHerramientas() async throws {
    let sesion = LanguageModelSession(
        instructions: "Eres un asistente de viajes. Usa las herramientas disponibles.",
        tools: [BuscarClima()]
    )

    // El modelo decide automaticamente usar BuscarClima
    let respuesta = try await sesion.respond(
        to: "Que ropa debo llevar para un viaje a Madrid manana?"
    )
    print(respuesta.content)
    // "Segun el clima actual en Madrid (24°C, soleado),
    //  te recomiendo ropa ligera..."
}
```

### Guardrails — Seguridad Integrada

Foundation Models incluye guardrails que filtran contenido danino automaticamente. No necesitas implementar filtros manualmente.

```swift
import FoundationModels

// MARK: - Manejo de guardrails

func manejarGuardrails() async {
    let sesion = LanguageModelSession()

    do {
        let respuesta = try await sesion.respond(to: "prompt aqui")
        print(respuesta.content)
    } catch let error as LanguageModelSession.GenerationError {
        switch error {
        case .guardrailViolation:
            print("El contenido fue bloqueado por seguridad")
        case .contextWindowExceeded:
            print("El contexto excedio el limite del modelo")
        default:
            print("Error de generacion: \(error)")
        }
    } catch {
        print("Error inesperado: \(error)")
    }
}
```

### Gestion de Contexto

El modelo tiene una ventana de contexto limitada. Gestiona las conversaciones largas de forma inteligente.

```swift
import FoundationModels

// MARK: - Conversacion multi-turno

func conversacionMultiTurno() async throws {
    let sesion = LanguageModelSession(
        instructions: "Eres un tutor de programacion Swift."
    )

    // Turno 1
    let r1 = try await sesion.respond(to: "Que es un optional?")
    print("Turno 1: \(r1.content)")

    // Turno 2 — el modelo recuerda el contexto anterior
    let r2 = try await sesion.respond(to: "Dame un ejemplo practico")
    print("Turno 2: \(r2.content)")

    // Turno 3 — seguimos en la misma conversacion
    let r3 = try await sesion.respond(to: "Y como se usa con guard let?")
    print("Turno 3: \(r3.content)")

    // Si el contexto crece demasiado, crear nueva sesion
    // con un resumen de la conversacion anterior
}
```

---

## Ejercicio 1: Chat Simple con Streaming (Basico)

**Objetivo**: Crear una interfaz de chat que use LanguageModelSession con streaming.

**Requisitos**:
1. Vista con un `TextField` para el prompt y un `ScrollView` para la respuesta
2. Boton de enviar que inicie la generacion con `streamResponse`
3. Mostrar el texto generado progresivamente (token a token)
4. Verificar disponibilidad del modelo antes de mostrar la UI de chat
5. Manejar errores con mensajes claros al usuario

---

## Ejercicio 2: Generador de Contenido Estructurado (Intermedio)

**Objetivo**: Usar @Generable para generar contenido tipado desde un prompt.

**Requisitos**:
1. Definir un struct `@Generable` para `PlanDeEstudio` con: tema, objetivos ([String]), duracion (Int), nivel (enum), recursos ([String])
2. Usar `@Guide` con descripciones y restricciones en cada campo
3. Vista SwiftUI que pida un tema y genere un plan de estudio estructurado
4. Mostrar el resultado en una vista formateada con secciones
5. Permitir regenerar el plan con un boton de "Intentar de nuevo"

---

## Ejercicio 3: Asistente con Tool Calling (Avanzado)

**Objetivo**: Implementar un asistente que use tools para acceder a datos de la app.

**Requisitos**:
1. Definir 2 herramientas: `BuscarContacto` (busca en una lista local) y `CrearRecordatorio` (crea un recordatorio simulado)
2. Cada herramienta con sus structs `Parametros` y `Resultado` usando `@Generable`
3. Sesion con instrucciones de sistema y ambas herramientas registradas
4. Vista de chat donde el usuario pueda pedir "recuerdame llamar a Juan manana"
5. Mostrar al usuario que herramienta uso el modelo y con que parametros

---

## 5 Errores Comunes

### 1. No verificar disponibilidad del modelo

```swift
// MAL — asumir que el modelo siempre esta disponible
let sesion = LanguageModelSession()
let respuesta = try await sesion.respond(to: "Hola")
// Crash en dispositivos sin Apple Intelligence

// BIEN — verificar antes de usar
guard SystemLanguageModel.default.availability == .available else {
    mostrarAlternativa()
    return
}
let sesion = LanguageModelSession()
let respuesta = try await sesion.respond(to: "Hola")
```

### 2. No manejar guardrailViolation

```swift
// MAL — solo catch generico
do {
    let respuesta = try await sesion.respond(to: prompt)
} catch {
    print("Error")  // No sabes que paso
}

// BIEN — manejar errores especificos
do {
    let respuesta = try await sesion.respond(to: prompt)
} catch let error as LanguageModelSession.GenerationError {
    switch error {
    case .guardrailViolation:
        mostrarMensajeSeguridad()
    case .contextWindowExceeded:
        reiniciarSesion()
    default:
        mostrarErrorGeneral(error)
    }
}
```

### 3. Olvidar @Guide en campos de @Generable

```swift
// MAL — sin guias, el modelo no sabe que esperas
@Generable
struct Resultado {
    var campo1: String  // Que es esto?
    var campo2: Int     // Que rango?
}

// BIEN — guias descriptivas con restricciones
@Generable
struct Resultado {
    @Guide(description: "Nombre del producto")
    var nombre: String

    @Guide(description: "Precio en dolares", .range(1...10000))
    var precio: Int
}
```

### 4. Crear una nueva sesion por cada mensaje en un chat

```swift
// MAL — pierde contexto entre mensajes
func enviarMensaje(_ texto: String) async throws {
    let sesion = LanguageModelSession()  // Nueva sesion cada vez!
    let respuesta = try await sesion.respond(to: texto)
}

// BIEN — reutilizar la sesion para mantener contexto
class ChatVM {
    private let sesion = LanguageModelSession()

    func enviarMensaje(_ texto: String) async throws -> String {
        let respuesta = try await sesion.respond(to: texto)
        return respuesta.content
    }
}
```

### 5. Bloquear la UI durante la generacion

```swift
// MAL — usar respond sin streaming para textos largos
let respuesta = try await sesion.respond(to: promptLargo)
// La UI se congela hasta que termina

// BIEN — usar streaming para UX fluida
let stream = sesion.streamResponse(to: promptLargo)
for try await fragmento in stream {
    textoMostrado = fragmento.content  // Actualiza progresivamente
}
```

---

## Checklist

- [ ] Verificar disponibilidad de SystemLanguageModel antes de usar el framework
- [ ] Crear LanguageModelSession con instrucciones de sistema apropiadas
- [ ] Generar respuestas simples con respond(to:)
- [ ] Implementar streaming con streamResponse(to:) para UX fluida
- [ ] Definir structs @Generable para salida estructurada
- [ ] Usar @Guide con descripciones y restricciones en cada campo
- [ ] Implementar al menos una Tool con parametros y resultado
- [ ] Manejar errores de guardrails y context window
- [ ] Gestionar conversaciones multi-turno reutilizando la sesion
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Foundation Models sera la capa de inteligencia de tu app:
- **LanguageModelSession** para funciones de asistente inteligente (resumir, sugerir, explicar)
- **@Generable** para extraer datos estructurados de texto libre (parsear recibos, clasificar entradas)
- **Streaming** para cualquier UI donde el usuario espere respuestas del modelo
- **Tool Calling** para que el asistente interactue con los datos de la app (buscar, crear, modificar registros en SwiftData)
- **Guardrails** para garantizar que el contenido generado sea seguro y apropiado

---

*Leccion 25 | Foundation Models | Semanas 31-32 | Modulo 06: IA y ML*
*Siguiente: Leccion 26 — ImagePlayground*
