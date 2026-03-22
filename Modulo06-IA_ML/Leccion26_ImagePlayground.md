# Leccion 26: ImagePlayground

**Modulo 06: IA y ML** | Semana 33

---

## TL;DR — Resumen en 2 minutos

- **ImagePlayground**: Framework de Apple para generar imagenes con IA completamente on-device — privacidad total
- **ImagePlaygroundViewController**: Controlador de UI listo para usar — el usuario describe, elige estilo y genera imagenes
- **Conceptos**: Define el contenido de la imagen con texto, personas o sugerencias predefinidas
- **Estilos**: Animation, Illustration y Sketch — tres estilos visuales para las imagenes generadas
- **Integracion SwiftUI**: Modifier `.imagePlaygroundSheet` para presentar la experiencia con una sola linea

---

## Cupertino MCP

```bash
cupertino search "ImagePlayground"
cupertino search "ImagePlaygroundViewController"
cupertino search "ImagePlaygroundSheet"
cupertino search "ImagePlayground concepts"
cupertino search "ImagePlayground style"
cupertino search --source samples "ImagePlayground"
cupertino search --source updates "ImagePlayground"
cupertino search --source hig "Image Playground"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [Introducing Image Playground](https://developer.apple.com/videos/play/wwdc2024/10136/) | **Esencial** — Introduccion oficial |
| WWDC24 | [Image Playground on the App Store](https://developer.apple.com/videos/play/wwdc2024/10139/) | Integracion en apps |
| WWDC25 | [What's new in Image Playground](https://developer.apple.com/videos/play/wwdc2025/10608/) | Novedades iOS 26 |
| :es: | [Apple Coding — Image Playground](https://www.youtube.com/@AppleCodingAcademy) | Serie en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que ImagePlayground?

Generar imagenes con IA normalmente requiere APIs externas (DALL-E, Midjourney, Stable Diffusion), servidores potentes, y exponer datos del usuario a terceros. Apple resolvio esto con ImagePlayground: generacion de imagenes **completamente on-device**, integrada en el sistema, sin costo por imagen, y con privacidad total.

ImagePlayground no es un framework para entrenar modelos ni para generacion profesional. Es una herramienta disenada para que los usuarios creen imagenes divertidas y expresivas dentro de tu app — avatares, stickers, ilustraciones para notas, imagenes para mensajes.

```
  ┌──────────────────────────────────────────────────────────┐
  │            ARQUITECTURA IMAGE PLAYGROUND                  │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   Tu App                                                 │
  │   ├─ .imagePlaygroundSheet()     → SwiftUI nativo        │
  │   └─ ImagePlaygroundViewController → UIKit               │
  │          │                                               │
  │          ▼                                               │
  │   ┌─────────────────────────────────────────┐            │
  │   │     ImagePlayground Framework           │            │
  │   │  ┌─────────────────────────────────┐    │            │
  │   │  │  Conceptos (texto, personas)    │    │            │
  │   │  │  Estilos (animation, sketch...) │    │            │
  │   │  │  Generacion on-device           │    │            │
  │   │  └─────────────────────────────────┘    │            │
  │   └─────────────────────────────────────────┘            │
  │                                                          │
  │   Resultado: URL de imagen local                         │
  │   Todo on-device — privacidad total                      │
  └──────────────────────────────────────────────────────────┘
```

### Verificar Disponibilidad

No todos los dispositivos soportan ImagePlayground. Verifica antes de mostrar la funcionalidad.

```swift
import ImagePlayground

// MARK: - Verificar soporte

func verificarImagePlayground() -> Bool {
    // Verificar si el dispositivo soporta Image Playground
    if ImagePlaygroundViewController.isAvailable {
        print("Image Playground disponible")
        return true
    } else {
        print("Image Playground no disponible en este dispositivo")
        return false
    }
}
```

### Integracion SwiftUI — imagePlaygroundSheet

La forma mas sencilla de integrar ImagePlayground es con el modifier `.imagePlaygroundSheet`. Una sola linea presenta la experiencia completa.

```swift
import SwiftUI
import ImagePlayground

// MARK: - Integracion basica con SwiftUI

struct CrearImagenView: View {
    @State private var mostrarPlayground = false
    @State private var imagenURL: URL?

    var body: some View {
        VStack(spacing: 20) {
            if let url = imagenURL,
               let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ContentUnavailableView(
                    "Sin imagen",
                    systemImage: "photo.badge.plus",
                    description: Text("Toca el boton para crear una imagen con IA")
                )
            }

            Button("Crear Imagen") {
                mostrarPlayground = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .imagePlaygroundSheet(
            isPresented: $mostrarPlayground
        ) { url in
            // Se llama cuando el usuario termina de crear la imagen
            imagenURL = url
        }
    }
}
```

### Conceptos — Definir el Contenido

Los conceptos le dicen a ImagePlayground que generar. Puedes usar texto libre, sugerencias predefinidas o incluso fotos de personas.

```swift
import SwiftUI
import ImagePlayground

// MARK: - Conceptos de texto

struct ImagenConConceptosView: View {
    @State private var mostrar = false
    @State private var imagenURL: URL?

    var body: some View {
        VStack {
            // ... mostrar imagen ...

            Button("Crear Mascota") {
                mostrar = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $mostrar,
            concepts: [
                // Concepto de texto libre
                .text("Un gato naranja con lentes de sol"),

                // Concepto con categoria tematica
                .text("playa tropical al atardecer")
            ]
        ) { url in
            imagenURL = url
        }
    }
}
```

#### Conceptos con personas

Puedes incluir fotos de personas para que ImagePlayground genere imagenes basadas en su apariencia.

```swift
import SwiftUI
import ImagePlayground

// MARK: - Conceptos con personas

struct AvatarView: View {
    @State private var mostrar = false
    @State private var avatarURL: URL?
    let fotoPersona: URL  // URL de la foto del usuario

    var body: some View {
        VStack {
            // ... mostrar avatar ...

            Button("Crear Avatar") {
                mostrar = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $mostrar,
            concepts: [
                // Persona basada en foto
                .person(photo: fotoPersona),

                // Contexto adicional
                .text("estilo superhéroe")
            ]
        ) { url in
            avatarURL = url
        }
    }
}
```

### Estilos de Generacion

ImagePlayground ofrece tres estilos visuales. El usuario puede elegir en la interfaz, pero tu puedes sugerir uno por defecto.

```swift
import ImagePlayground

// MARK: - Estilos disponibles

// Los tres estilos de Image Playground:
//
// 1. Animation — Estilo 3D tipo Pixar/Disney
//    Ideal para: avatares, personajes, escenas divertidas
//
// 2. Illustration — Estilo ilustracion 2D artistica
//    Ideal para: portadas, fondos, arte conceptual
//
// 3. Sketch — Estilo dibujo a lapiz/tinta
//    Ideal para: bocetos, notas visuales, minimalismo
```

### UIKit — ImagePlaygroundViewController

Para mas control, usa `ImagePlaygroundViewController` directamente. Esto es util en apps UIKit o cuando necesitas personalizacion avanzada.

```swift
import UIKit
import ImagePlayground

// MARK: - UIKit integration

class MiViewController: UIViewController, ImagePlaygroundViewController.Delegate {

    func mostrarPlayground() {
        let playground = ImagePlaygroundViewController()
        playground.delegate = self

        // Agregar conceptos programaticamente
        playground.concepts = [
            .text("paisaje de montanas con nieve"),
            .text("estilo acuarela")
        ]

        present(playground, animated: true)
    }

    // MARK: - Delegate

    func imagePlaygroundViewController(
        _ controller: ImagePlaygroundViewController,
        didCreateImageAt url: URL
    ) {
        // El usuario creo una imagen
        guardarImagen(desde: url)
        controller.dismiss(animated: true)
    }

    func imagePlaygroundViewControllerDidCancel(
        _ controller: ImagePlaygroundViewController
    ) {
        // El usuario cancelo
        controller.dismiss(animated: true)
    }

    private func guardarImagen(desde url: URL) {
        guard let data = try? Data(contentsOf: url),
              let imagen = UIImage(data: data) else { return }
        // Usar la imagen
        print("Imagen guardada: \(imagen.size)")
    }
}
```

### Integracion con SwiftData

Un patron comun es guardar las imagenes generadas en tu modelo de datos.

```swift
import SwiftUI
import SwiftData
import ImagePlayground

// MARK: - Modelo con imagen generada

@Model
class Nota {
    var titulo: String
    var contenido: String
    var fechaCreacion: Date

    // Guardar la imagen como Data
    @Attribute(.externalStorage) var imagenPortada: Data?

    init(titulo: String, contenido: String) {
        self.titulo = titulo
        self.contenido = contenido
        self.fechaCreacion = .now
    }
}

// MARK: - Vista para agregar imagen a una nota

struct NotaDetailView: View {
    @Bindable var nota: Nota
    @State private var mostrarPlayground = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Imagen de portada
                if let data = nota.imagenPortada,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture { mostrarPlayground = true }
                } else {
                    Button {
                        mostrarPlayground = true
                    } label: {
                        Label("Agregar portada con IA", systemImage: "wand.and.stars")
                    }
                }

                Text(nota.titulo).font(.title)
                Text(nota.contenido).font(.body)
            }
            .padding()
        }
        .imagePlaygroundSheet(
            isPresented: $mostrarPlayground,
            concepts: [.text(nota.titulo)]
        ) { url in
            if let data = try? Data(contentsOf: url) {
                nota.imagenPortada = data
            }
        }
    }
}
```

### Buenas Practicas de UX

Apple tiene lineamientos claros sobre como integrar ImagePlayground en tu app.

```swift
import SwiftUI
import ImagePlayground

// MARK: - Buenas practicas

struct BuenasPracticasView: View {
    @State private var mostrar = false

    var body: some View {
        VStack {
            // BIEN — Boton claro que indica la funcionalidad
            Button {
                mostrar = true
            } label: {
                Label("Crear con Image Playground",
                      systemImage: "apple.image.playground")
            }
            .disabled(!ImagePlaygroundViewController.isAvailable)

            // BIEN — Ocultar la funcionalidad si no esta disponible
            if ImagePlaygroundViewController.isAvailable {
                Button("Generar Ilustracion") {
                    mostrar = true
                }
            }
        }
        .imagePlaygroundSheet(isPresented: $mostrar) { url in
            // Procesar imagen
        }
    }
}

// Lineamientos de Apple para Image Playground:
//
// 1. Usar el icono oficial: apple.image.playground (SF Symbol)
// 2. No llamarlo "IA" en la UI — usar "Image Playground"
// 3. No pre-rellenar con conceptos ofensivos o inapropiados
// 4. Siempre verificar isAvailable antes de mostrar la opcion
// 5. Dar al usuario control total — no generar automaticamente
// 6. La imagen es del usuario — no la subas sin permiso
```

### Limitaciones y Consideraciones

```
  ┌──────────────────────────────────────────────────────────┐
  │          LIMITACIONES DE IMAGE PLAYGROUND                 │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │  ✓ Lo que SI puede hacer:                                │
  │  ├─ Generar imagenes artisticas/estilizadas              │
  │  ├─ Crear avatares basados en fotos                      │
  │  ├─ Ilustraciones para notas, mensajes, stickers         │
  │  └─ Todo on-device, sin internet                         │
  │                                                          │
  │  ✗ Lo que NO puede hacer:                                │
  │  ├─ Fotos realistas (no es un generador fotorrealista)   │
  │  ├─ Texto en las imagenes (no renderiza letras)          │
  │  ├─ Generacion programatica sin UI (requiere la sheet)   │
  │  ├─ Control pixel-perfect del resultado                  │
  │  └─ Funcionar en dispositivos sin Apple Intelligence     │
  │                                                          │
  └──────────────────────────────────────────────────────────┘
```

---

## Ejercicio 1: Galeria de Imagenes Generadas (Basico)

**Objetivo**: Integrar ImagePlayground con una galeria simple.

**Requisitos**:
1. Vista principal con un grid de imagenes generadas (LazyVGrid)
2. Boton "+" que presenta `.imagePlaygroundSheet` para crear una nueva imagen
3. Guardar las imagenes generadas en un array de `Data` con `@State`
4. Verificar `isAvailable` y mostrar un mensaje si el dispositivo no soporta la funcionalidad
5. Permitir eliminar imagenes de la galeria con un gesto largo o boton

---

## Ejercicio 2: Notas Ilustradas con SwiftData (Intermedio)

**Objetivo**: Combinar ImagePlayground con SwiftData para persistir notas con portadas generadas.

**Requisitos**:
1. Modelo `@Model NotaIlustrada` con: titulo, contenido, fechaCreacion, imagenData (Data?)
2. Lista de notas con `@Query`, mostrando la imagen como miniatura si existe
3. Detalle de nota con boton para generar/cambiar portada usando ImagePlayground
4. Pre-rellenar los conceptos con el titulo de la nota automaticamente
5. Vista de creacion de nota nueva con opcion de agregar imagen al crearla

---

## Ejercicio 3: Creador de Stickers Personalizados (Avanzado)

**Objetivo**: Crear una experiencia completa de stickers usando ImagePlayground y persistencia.

**Requisitos**:
1. Modelo `@Model StickerPack` con nombre y relacion uno-a-muchos con `Sticker` (imagen, etiqueta, fechaCreacion)
2. Vista de packs con navegacion a la coleccion de stickers de cada pack
3. Generar stickers con ImagePlayground usando conceptos predefinidos por pack (ej: "animales", "comida", "emociones")
4. Compartir stickers individuales con `ShareLink`
5. Exportar un pack completo como PDF o grid de imagenes

---

## 5 Errores Comunes

### 1. No verificar disponibilidad antes de mostrar la UI

```swift
// MAL — el boton aparece pero no funciona
Button("Crear Imagen") {
    mostrarPlayground = true
}

// BIEN — verificar antes de mostrar
if ImagePlaygroundViewController.isAvailable {
    Button("Crear Imagen") {
        mostrarPlayground = true
    }
}
```

### 2. No guardar la imagen correctamente

```swift
// MAL — la URL temporal puede expirar
imagePlaygroundSheet(isPresented: $mostrar) { url in
    self.imagenURL = url  // URL temporal! Puede no existir despues
}

// BIEN — copiar los datos inmediatamente
imagePlaygroundSheet(isPresented: $mostrar) { url in
    if let data = try? Data(contentsOf: url) {
        self.imagenData = data  // Datos copiados, seguros
    }
}
```

### 3. Pre-rellenar conceptos inapropiados

```swift
// MAL — conceptos que Apple puede rechazar
.imagePlaygroundSheet(
    isPresented: $mostrar,
    concepts: [.text("contenido violento o inapropiado")]
)

// BIEN — conceptos creativos y seguros
.imagePlaygroundSheet(
    isPresented: $mostrar,
    concepts: [.text("paisaje colorido con flores")]
)
```

### 4. Ignorar el callback de cancelacion

```swift
// MAL — no manejar cuando el usuario cancela (UIKit)
func imagePlaygroundViewController(
    _ controller: ImagePlaygroundViewController,
    didCreateImageAt url: URL
) {
    // Solo manejas creacion, no cancelacion
    controller.dismiss(animated: true)
}

// BIEN — implementar ambos callbacks
func imagePlaygroundViewControllerDidCancel(
    _ controller: ImagePlaygroundViewController
) {
    controller.dismiss(animated: true)
}
```

### 5. Usar @Attribute(.externalStorage) incorrectamente

```swift
// MAL — guardar imagenes grandes inline en SwiftData
@Model class Nota {
    var imagen: Data?  // Se guarda en la tabla principal, lento
}

// BIEN — usar externalStorage para datos grandes
@Model class Nota {
    @Attribute(.externalStorage) var imagen: Data?  // Archivo separado
}
```

---

## Checklist

- [ ] Verificar disponibilidad con ImagePlaygroundViewController.isAvailable
- [ ] Integrar .imagePlaygroundSheet en una vista SwiftUI
- [ ] Usar conceptos de texto para guiar la generacion
- [ ] Manejar el resultado (URL) copiando los datos inmediatamente
- [ ] Conocer los tres estilos: Animation, Illustration, Sketch
- [ ] Integrar con SwiftData usando @Attribute(.externalStorage)
- [ ] Implementar la version UIKit con ImagePlaygroundViewController si es necesario
- [ ] Seguir los lineamientos de Apple para la UX (icono oficial, nomenclatura)
- [ ] Ocultar la funcionalidad en dispositivos no soportados
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

ImagePlayground enriquecera la experiencia visual de tu app:
- **Portadas generadas** para entradas, notas o registros del usuario
- **Avatares personalizados** usando fotos del usuario como concepto base
- **Ilustraciones de contenido** para hacer la app mas atractiva visualmente
- **Stickers y compartir** para funciones sociales de la app
- **Persistencia con SwiftData** guardando imagenes con `@Attribute(.externalStorage)`

---

*Leccion 26 | ImagePlayground | Semana 33 | Modulo 06: IA y ML*
*Siguiente: Leccion 27 — CoreML y Vision*
