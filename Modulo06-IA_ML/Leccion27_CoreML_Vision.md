# Leccion 27: CoreML y Vision

**Modulo 06: IA y ML** | Semana 34

---

## TL;DR — Resumen en 2 minutos

- **CoreML**: Framework para ejecutar modelos de machine learning on-device — clasificacion, prediccion, generacion, todo offline
- **Vision**: Framework de analisis de imagenes — deteccion de caras, OCR, clasificacion de objetos, poses corporales
- **Create ML**: Herramienta de Xcode para entrenar modelos sin escribir codigo — arrastra datos y obtiene un .mlmodel
- **Pipeline CoreML + Vision**: Combinas ambos para analisis visual potente — Vision preprocesa, CoreML clasifica
- **Todo on-device**: Sin servidor, sin latencia de red, sin costos por inferencia, privacidad total

---

## Cupertino MCP

```bash
cupertino search "CoreML"
cupertino search "MLModel"
cupertino search "Vision framework"
cupertino search "VNClassifyImageRequest"
cupertino search "VNRecognizeTextRequest"
cupertino search "VNDetectFaceRectanglesRequest"
cupertino search "Create ML"
cupertino search --source samples "CoreML"
cupertino search --source samples "Vision"
cupertino search --source updates "CoreML"
cupertino search --source updates "Vision"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [What's new in Core ML](https://developer.apple.com/videos/play/wwdc2024/10161/) | **Esencial** — Novedades recientes |
| WWDC24 | [Discover machine learning enhancements in Vision](https://developer.apple.com/videos/play/wwdc2024/10163/) | Vision actualizado |
| WWDC23 | [Improve Core ML integration with async prediction](https://developer.apple.com/videos/play/wwdc2023/10049/) | async/await en CoreML |
| WWDC24 | [Train a model with Create ML](https://developer.apple.com/videos/play/wwdc2024/10169/) | Entrenar sin codigo |
| WWDC25 | [What's new in Vision](https://developer.apple.com/videos/play/wwdc2025/10609/) | Vision iOS 26 |
| :es: | [Apple Coding — CoreML y Vision](https://www.youtube.com/@AppleCodingAcademy) | Serie en espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que CoreML y Vision?

La IA no es solo chatbots y texto. Muchas apps necesitan analizar imagenes, clasificar contenido, detectar objetos o reconocer texto. CoreML y Vision son los frameworks de Apple para esto — llevan anos maduros y funcionan completamente on-device.

Foundation Models (Leccion 25) es genial para texto y contenido generativo, pero para **analisis visual** (detectar caras, leer texto de fotos, clasificar imagenes), CoreML y Vision son las herramientas correctas.

```
  ┌──────────────────────────────────────────────────────────┐
  │         ECOSISTEMA DE ML EN APPLE                         │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   Foundation Models    CoreML          Vision             │
  │   ├─ Texto generativo  ├─ Modelos      ├─ Caras          │
  │   ├─ Chat              │  custom       ├─ Texto (OCR)    │
  │   ├─ Structured output ├─ Clasificacion├─ Objetos        │
  │   └─ Tool calling      ├─ Prediccion   ├─ Poses          │
  │                        └─ On-device    ├─ Clasificacion  │
  │   Create ML                            └─ Barcodes       │
  │   ├─ Entrenar modelos                                    │
  │   ├─ Sin codigo                                          │
  │   └─ Exportar .mlmodel                                   │
  │                                                          │
  │   Todos on-device — privacidad y rendimiento             │
  └──────────────────────────────────────────────────────────┘
```

### CoreML — Modelos de ML en tu App

CoreML permite cargar y ejecutar modelos de machine learning. Apple proporciona modelos pre-entrenados, o puedes entrenar los tuyos con Create ML.

#### Cargar y usar un modelo

```swift
import CoreML

// MARK: - Cargar un modelo CoreML

func cargarModelo() async throws {
    // CoreML usa async/await desde iOS 17+
    let configuracion = MLModelConfiguration()
    configuracion.computeUnits = .all  // CPU + GPU + Neural Engine

    // Cargar modelo (asumiendo que MiClasificador.mlmodel esta en el proyecto)
    let modelo = try await MiClasificador.load(configuration: configuracion)

    print("Modelo cargado exitosamente")
    print("Descripcion: \(modelo.model.modelDescription)")
}
```

#### Hacer predicciones

```swift
import CoreML
import UIKit

// MARK: - Prediccion con un modelo de clasificacion de imagenes

func clasificarImagen(_ imagen: UIImage) async throws -> String {
    let configuracion = MLModelConfiguration()
    let modelo = try await MobileNetV2.load(configuration: configuracion)

    // Convertir UIImage a CVPixelBuffer (formato que espera CoreML)
    guard let pixelBuffer = imagen.toPixelBuffer(
        width: 224, height: 224  // Tamano que espera MobileNetV2
    ) else {
        throw ErrorML.conversionFallida
    }

    // Hacer la prediccion
    let prediccion = try await modelo.prediction(image: pixelBuffer)

    print("Clase: \(prediccion.classLabel)")
    print("Confianza: \(prediccion.classLabelProbs[prediccion.classLabel] ?? 0)")

    return prediccion.classLabel
}

enum ErrorML: Error {
    case conversionFallida
    case modeloNoDisponible
}
```

#### Modelos disponibles de Apple

Apple ofrece modelos pre-entrenados en [developer.apple.com/machine-learning/models](https://developer.apple.com/machine-learning/models/):

```
  ┌────────────────────────────────────────────────────┐
  │          MODELOS PRE-ENTRENADOS DE APPLE            │
  ├────────────────────────────────────────────────────┤
  │                                                    │
  │  MobileNetV2   — Clasificacion de imagenes (1000   │
  │                  categorias, 6.3 MB)               │
  │  Resnet50      — Clasificacion de imagenes (alta   │
  │                  precision, 102 MB)                 │
  │  YOLOv3        — Deteccion de objetos en tiempo    │
  │                  real (80 categorias)               │
  │  DeepLabV3     — Segmentacion semantica            │
  │  BERT          — Procesamiento de lenguaje natural  │
  │  PoseNet       — Estimacion de poses corporales    │
  │                                                    │
  └────────────────────────────────────────────────────┘
```

### Vision — Analisis de Imagenes

Vision es el framework especializado en analisis visual. Incluye detectores pre-construidos que no requieren modelos externos.

#### Reconocimiento de Texto (OCR)

```swift
import Vision
import UIKit

// MARK: - OCR con Vision

func reconocerTexto(en imagen: UIImage) async throws -> [String] {
    guard let cgImage = imagen.cgImage else {
        throw ErrorML.conversionFallida
    }

    // Crear la request de reconocimiento de texto
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate  // .fast para velocidad
    request.recognitionLanguages = ["es", "en"]  // Espanol e ingles
    request.usesLanguageCorrection = true

    // Ejecutar la request
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    // Extraer resultados
    guard let observaciones = request.results else {
        return []
    }

    let textos = observaciones.compactMap { observacion in
        observacion.topCandidates(1).first?.string
    }

    for texto in textos {
        print("Texto encontrado: \(texto)")
    }

    return textos
}
```

#### Deteccion de Caras

```swift
import Vision
import UIKit

// MARK: - Deteccion de caras

func detectarCaras(en imagen: UIImage) async throws -> [VNFaceObservation] {
    guard let cgImage = imagen.cgImage else {
        throw ErrorML.conversionFallida
    }

    let request = VNDetectFaceRectanglesRequest()

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    guard let resultados = request.results else {
        return []
    }

    for (i, cara) in resultados.enumerated() {
        let rect = cara.boundingBox
        print("Cara \(i + 1): posicion=(\(rect.origin.x), \(rect.origin.y)) tamano=\(rect.size)")
        print("  Confianza: \(cara.confidence)")
    }

    return resultados
}
```

#### Clasificacion de Imagenes (Vision integrado)

Vision incluye un clasificador de imagenes integrado que no requiere modelos externos.

```swift
import Vision
import UIKit

// MARK: - Clasificacion con Vision

func clasificarConVision(imagen: UIImage) async throws -> [(String, Float)] {
    guard let cgImage = imagen.cgImage else {
        throw ErrorML.conversionFallida
    }

    let request = VNClassifyImageRequest()

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    guard let resultados = request.results else {
        return []
    }

    // Filtrar resultados con alta confianza
    let clasificaciones = resultados
        .filter { $0.confidence > 0.5 }
        .map { ($0.identifier, $0.confidence) }
        .sorted { $0.1 > $1.1 }

    for (etiqueta, confianza) in clasificaciones.prefix(5) {
        print("\(etiqueta): \(String(format: "%.1f", confianza * 100))%")
    }

    return clasificaciones
}
```

#### Deteccion de Codigos de Barras y QR

```swift
import Vision
import UIKit

// MARK: - Deteccion de codigos

func detectarCodigos(en imagen: UIImage) async throws -> [String] {
    guard let cgImage = imagen.cgImage else {
        throw ErrorML.conversionFallida
    }

    let request = VNDetectBarcodesRequest()
    request.symbologies = [.qr, .ean13, .code128]  // Tipos de codigos

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    guard let resultados = request.results else {
        return []
    }

    let codigos = resultados.compactMap { observacion -> String? in
        guard let payload = observacion.payloadStringValue else { return nil }
        print("Codigo \(observacion.symbology.rawValue): \(payload)")
        return payload
    }

    return codigos
}
```

### Pipeline CoreML + Vision

El patron mas poderoso: Vision preprocesa la imagen y CoreML ejecuta tu modelo custom.

```swift
import Vision
import CoreML
import UIKit

// MARK: - Pipeline Vision + CoreML

func clasificarConModeloCustom(imagen: UIImage) async throws -> String {
    guard let cgImage = imagen.cgImage else {
        throw ErrorML.conversionFallida
    }

    // 1. Cargar tu modelo CoreML
    let configuracion = MLModelConfiguration()
    let modelo = try await MiClasificadorCustom.load(configuration: configuracion)

    // 2. Crear un VNCoreMLRequest que usa tu modelo
    let modeloVision = try VNCoreMLModel(for: modelo.model)

    // Variable para capturar resultado
    var clasificacion = "Desconocido"

    let request = VNCoreMLRequest(model: modeloVision) { request, error in
        guard let resultados = request.results as? [VNClassificationObservation],
              let mejor = resultados.first else {
            return
        }
        clasificacion = "\(mejor.identifier) (\(String(format: "%.1f", mejor.confidence * 100))%)"
    }

    // 3. Vision maneja el preprocesamiento (redimension, normalizacion)
    request.imageCropAndScaleOption = .centerCrop

    // 4. Ejecutar
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    return clasificacion
}
```

### Integracion con SwiftUI

```swift
import SwiftUI
import Vision

// MARK: - Vista de analisis de imagen

struct AnalizadorImagenView: View {
    @State private var imagenSeleccionada: UIImage?
    @State private var textoDetectado: [String] = []
    @State private var analizando = false
    @State private var mostrarPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Imagen
                if let imagen = imagenSeleccionada {
                    Image(uiImage: imagen)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ContentUnavailableView(
                        "Sin imagen",
                        systemImage: "photo",
                        description: Text("Selecciona una imagen para analizar")
                    )
                }

                // Botones
                HStack {
                    Button("Seleccionar") {
                        mostrarPicker = true
                    }

                    Button("Analizar OCR") {
                        Task { await analizarTexto() }
                    }
                    .disabled(imagenSeleccionada == nil || analizando)
                }
                .buttonStyle(.borderedProminent)

                // Resultados
                if analizando {
                    ProgressView("Analizando...")
                } else if !textoDetectado.isEmpty {
                    List(textoDetectado, id: \.self) { texto in
                        Text(texto)
                    }
                }
            }
            .padding()
            .navigationTitle("Analizador")
        }
    }

    func analizarTexto() async {
        guard let imagen = imagenSeleccionada,
              let cgImage = imagen.cgImage else { return }

        analizando = true
        defer { analizando = false }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["es", "en"]

        do {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])

            textoDetectado = request.results?.compactMap {
                $0.topCandidates(1).first?.string
            } ?? []
        } catch {
            print("Error: \(error)")
        }
    }
}
```

### Create ML — Entrenar sin Codigo

Create ML es una herramienta de Xcode que permite entrenar modelos de ML sin escribir codigo. Solo necesitas datos organizados.

```
  ┌──────────────────────────────────────────────────────────┐
  │              FLUJO DE CREATE ML                           │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │  1. Organizar datos                                      │
  │     DatosEntrenamiento/                                  │
  │     ├── Gatos/                                           │
  │     │   ├── gato1.jpg                                    │
  │     │   ├── gato2.jpg                                    │
  │     │   └── ...                                          │
  │     └── Perros/                                          │
  │         ├── perro1.jpg                                   │
  │         ├── perro2.jpg                                   │
  │         └── ...                                          │
  │                                                          │
  │  2. Abrir Create ML en Xcode                             │
  │     Xcode > Open Developer Tool > Create ML              │
  │                                                          │
  │  3. Elegir plantilla (Image Classifier, etc.)            │
  │                                                          │
  │  4. Arrastrar datos de entrenamiento                     │
  │                                                          │
  │  5. Entrenar (el tiempo depende del tamano de datos)     │
  │                                                          │
  │  6. Evaluar precision con datos de prueba                │
  │                                                          │
  │  7. Exportar como .mlmodel e incluir en tu proyecto      │
  │                                                          │
  └──────────────────────────────────────────────────────────┘
```

#### Create ML programatico

Tambien puedes entrenar modelos desde codigo Swift.

```swift
import CreateML
import Foundation

// MARK: - Entrenar clasificador de imagenes programaticamente

func entrenarClasificador() async throws {
    // Directorio con imagenes organizadas en subcarpetas
    let datosEntrenamiento = URL(fileURLWithPath: "/ruta/DatosEntrenamiento")
    let datosValidacion = URL(fileURLWithPath: "/ruta/DatosValidacion")

    // Crear y entrenar el modelo
    let modelo = try MLImageClassifier(
        trainingData: .labeledDirectories(at: datosEntrenamiento),
        parameters: MLImageClassifier.ModelParameters(
            maxIterations: 20,
            augmentationOptions: [.crop, .blur, .rotate]  // Data augmentation
        )
    )

    // Evaluar precision
    let evaluacion = modelo.evaluation(
        on: .labeledDirectories(at: datosValidacion)
    )
    print("Precision: \(evaluacion.classificationError)")

    // Guardar modelo
    let metadata = MLModelMetadata(
        author: "Mi App",
        shortDescription: "Clasificador de mascotas",
        version: "1.0"
    )

    try modelo.write(
        to: URL(fileURLWithPath: "/ruta/ClasificadorMascotas.mlmodel"),
        metadata: metadata
    )
}
```

### Vision vs CoreML — Cuando Usar Cada Uno

| Tarea | Framework | Notas |
|-------|-----------|-------|
| OCR / Leer texto | Vision | VNRecognizeTextRequest, integrado |
| Detectar caras | Vision | VNDetectFaceRectanglesRequest, integrado |
| Clasificar imagenes (general) | Vision | VNClassifyImageRequest, integrado |
| Detectar codigos QR/barras | Vision | VNDetectBarcodesRequest, integrado |
| Clasificacion custom | CoreML + Vision | Modelo entrenado con Create ML |
| Prediccion tabular | CoreML | Datos numericos/categoricos |
| NLP custom | CoreML | Modelos de texto personalizados |
| Poses corporales | Vision | VNDetectHumanBodyPoseRequest |

---

## Ejercicio 1: Scanner de Texto (Basico)

**Objetivo**: Crear una app que extraiga texto de imagenes usando Vision.

**Requisitos**:
1. Vista con PhotosPicker para seleccionar una imagen de la galeria
2. Boton para ejecutar OCR con VNRecognizeTextRequest
3. Mostrar los textos detectados en una lista ordenada
4. Configurar reconocimiento en espanol e ingles
5. Boton para copiar todo el texto detectado al portapapeles (UIPasteboard)

---

## Ejercicio 2: Detector Multi-Proposito (Intermedio)

**Objetivo**: Combinar multiples capacidades de Vision en una sola app.

**Requisitos**:
1. Vista con seleccion de imagen y 3 modos de analisis: Texto (OCR), Caras, Clasificacion
2. Segmented picker para elegir el modo de analisis
3. Para caras: mostrar cuantas se detectaron y dibujar rectangulos sobre la imagen
4. Para clasificacion: mostrar las 5 categorias principales con porcentaje de confianza
5. Para texto: listar todos los bloques de texto encontrados con su nivel de confianza

---

## Ejercicio 3: Pipeline Completo con CoreML (Avanzado)

**Objetivo**: Implementar un pipeline Vision + CoreML con un modelo pre-entrenado de Apple.

**Requisitos**:
1. Descargar MobileNetV2 de la pagina de modelos de Apple e integrarlo al proyecto
2. Crear VNCoreMLRequest que use el modelo para clasificar imagenes
3. Vista con camara en vivo (AVCaptureSession) que clasifique en tiempo real
4. Mostrar la clasificacion sobre la imagen con overlay transparente
5. Guardar un historial de las ultimas 10 clasificaciones con fecha y resultado en SwiftData

---

## 5 Errores Comunes

### 1. No usar el hilo correcto para Vision requests

```swift
// MAL — ejecutar Vision en el main thread
func analizar(imagen: UIImage) {
    let handler = VNImageRequestHandler(cgImage: imagen.cgImage!, options: [:])
    try! handler.perform([request])  // Bloquea la UI!
}

// BIEN — ejecutar en un Task (background thread)
func analizar(imagen: UIImage) async throws {
    let handler = VNImageRequestHandler(cgImage: imagen.cgImage!, options: [:])
    try handler.perform([request])  // En un Task, no bloquea UI
}
```

### 2. Ignorar el sistema de coordenadas de Vision

```swift
// MAL — usar boundingBox directamente como coordenadas UIKit
let rect = caraDetectada.boundingBox
// Vision usa coordenadas normalizadas (0-1) con origen abajo-izquierda!

// BIEN — convertir coordenadas de Vision a UIKit
let rect = caraDetectada.boundingBox
let x = rect.origin.x * imagenWidth
let y = (1 - rect.origin.y - rect.size.height) * imagenHeight  // Invertir Y
let width = rect.size.width * imagenWidth
let height = rect.size.height * imagenHeight
let rectUIKit = CGRect(x: x, y: y, width: width, height: height)
```

### 3. No configurar computeUnits en CoreML

```swift
// MAL — dejar la configuracion por defecto
let modelo = try await MiModelo.load()
// Puede no usar Neural Engine

// BIEN — especificar que use todos los recursos
let config = MLModelConfiguration()
config.computeUnits = .all  // CPU + GPU + Neural Engine
let modelo = try await MiModelo.load(configuration: config)
```

### 4. No manejar modelos grandes correctamente

```swift
// MAL — cargar el modelo cada vez que se hace una prediccion
func clasificar(imagen: UIImage) async throws -> String {
    let modelo = try await MiModelo.load()  // Carga pesada cada vez!
    return try await modelo.prediction(...)
}

// BIEN — cargar una vez y reutilizar
class ClasificadorService {
    private var modelo: MiModelo?

    func cargar() async throws {
        modelo = try await MiModelo.load(
            configuration: MLModelConfiguration()
        )
    }

    func clasificar(imagen: UIImage) async throws -> String {
        guard let modelo else { throw ErrorML.modeloNoDisponible }
        return try await modelo.prediction(...)
    }
}
```

### 5. No validar resultados de OCR por confianza

```swift
// MAL — aceptar todos los resultados sin filtrar
let textos = request.results?.compactMap {
    $0.topCandidates(1).first?.string
}

// BIEN — filtrar por nivel de confianza
let textos = request.results?.compactMap { observacion -> String? in
    guard let candidato = observacion.topCandidates(1).first,
          candidato.confidence > 0.7 else {  // Minimo 70% confianza
        return nil
    }
    return candidato.string
}
```

---

## Checklist

- [ ] Entender las diferencias entre CoreML, Vision y Foundation Models
- [ ] Usar VNRecognizeTextRequest para OCR en imagenes
- [ ] Detectar caras con VNDetectFaceRectanglesRequest
- [ ] Clasificar imagenes con VNClassifyImageRequest
- [ ] Cargar y ejecutar un modelo CoreML con async/await
- [ ] Crear un pipeline Vision + CoreML con VNCoreMLRequest
- [ ] Conocer los modelos pre-entrenados disponibles de Apple
- [ ] Entender el flujo de Create ML para entrenar modelos custom
- [ ] Convertir coordenadas de Vision a UIKit correctamente
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

CoreML y Vision anadiran capacidades de analisis visual a tu app:
- **OCR** para escanear documentos, recibos, tarjetas de presentacion
- **Deteccion de caras** para funciones de fotografia o verificacion
- **Clasificacion de imagenes** para organizar fotos automaticamente por categoria
- **CoreML custom** si tu dominio necesita clasificacion especializada (ej: tipos de ejercicio, alimentos)
- **Pipeline Vision + CoreML** para analisis en tiempo real desde la camara
- Combinado con **Foundation Models** (Leccion 25) para describir textualmente lo que Vision detecta

---

*Leccion 27 | CoreML y Vision | Semana 34 | Modulo 06: IA y ML*
*Siguiente: Leccion 28 — App Intents y Siri*
