# Leccion 24: Camera y Photos

**Modulo 05: Hardware y Sensores** | Semana 30

---

## TL;DR — Resumen en 2 minutos

- **PhotosPicker**: Componente SwiftUI nativo para seleccionar fotos/videos sin pedir permiso de acceso completo a la libreria
- **AVCaptureSession**: Pipeline de captura de camara — configuras inputs (camara, micro) y outputs (foto, video, datos)
- **Transferable**: Protocolo que permite cargar fotos seleccionadas como Data, Image o tipos personalizados de forma asincrona
- **PHPhotoLibrary**: Acceso programatico a la libreria de fotos cuando necesitas mas control que PhotosPicker
- **Privacidad primero**: PhotosPicker no requiere permisos porque opera en un proceso separado — Apple maneja el acceso

---

## Cupertino MCP

```bash
cupertino search "PhotosPicker SwiftUI"
cupertino search "AVCaptureSession"
cupertino search "AVFoundation camera"
cupertino search "Transferable"
cupertino search "PHPhotoLibrary"
cupertino search "AVCapturePhotoOutput"
cupertino search "AVCaptureVideoPreviewLayer"
cupertino search --source samples "camera"
cupertino search --source samples "PhotosPicker"
cupertino search --source updates "AVFoundation"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [Build a great Lock Screen camera capture experience](https://developer.apple.com/videos/play/wwdc2024/10204/) | Captura avanzada |
| WWDC23 | [What's new in camera capture](https://developer.apple.com/videos/play/wwdc2023/10105/) | Novedades |
| WWDC22 | [What's new in PhotoKit](https://developer.apple.com/videos/play/wwdc2022/10023/) | **Esencial** — PhotosPicker |
| WWDC22 | [Discover advancements in iOS camera capture](https://developer.apple.com/videos/play/wwdc2022/110429/) | AVFoundation |
| WWDC21 | [Capture and process ProRAW images](https://developer.apple.com/videos/play/wwdc2021/10048/) | Fotos profesionales |
| :es: | [Julio Cesar Fernandez — Camera](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que importa la privacidad en Camera y Photos?

Apple ha redefinido como las apps acceden a fotos y camara. El cambio filosofico es fundamental: **la app no necesita ver toda tu libreria para que selecciones una foto**. PhotosPicker (introducido en iOS 16) opera en un proceso separado del sistema — tu app recibe solo las fotos que el usuario selecciona explicitamente, sin necesidad de pedir permiso alguno.

Para la camara, el modelo es mas directo: siempre necesitas `NSCameraUsageDescription` en Info.plist y el permiso explicito del usuario. No hay "acceso parcial" a la camara.

```
  ┌──────────────────────────────────────────────────────────┐
  │          NIVELES DE ACCESO A FOTOS Y CAMARA              │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │  Nivel 1: PhotosPicker (SIN permiso)                     │
  │  ┌──────────────────────────────────────┐                │
  │  │ Usuario selecciona → App recibe foto │                │
  │  │ Proceso del sistema, no de tu app    │                │
  │  └──────────────────────────────────────┘                │
  │                                                          │
  │  Nivel 2: PHPhotoLibrary Limited (permiso parcial)       │
  │  ┌──────────────────────────────────────┐                │
  │  │ Usuario elige fotos especificas      │                │
  │  │ Tu app solo ve las seleccionadas     │                │
  │  └──────────────────────────────────────┘                │
  │                                                          │
  │  Nivel 3: PHPhotoLibrary Full (permiso completo)         │
  │  ┌──────────────────────────────────────┐                │
  │  │ Acceso a TODA la libreria            │                │
  │  │ Solo si realmente lo necesitas       │                │
  │  └──────────────────────────────────────┘                │
  │                                                          │
  │  Camara: AVCaptureSession (siempre requiere permiso)     │
  │  ┌──────────────────────────────────────┐                │
  │  │ NSCameraUsageDescription obligatorio │                │
  │  └──────────────────────────────────────┘                │
  └──────────────────────────────────────────────────────────┘
```

### PhotosPicker — Seleccion de Fotos en SwiftUI

PhotosPicker es la forma recomendada de seleccionar fotos. No necesita permisos, es nativo de SwiftUI y soporta seleccion multiple, filtros por tipo de contenido y carga asincrona.

```swift
import SwiftUI
import PhotosUI

// MARK: - Seleccion de una sola foto

struct SelectorFotoSimple: View {
    @State private var itemSeleccionado: PhotosPickerItem?
    @State private var imagenCargada: Image?

    var body: some View {
        VStack(spacing: 20) {
            if let imagenCargada {
                imagenCargada
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ContentUnavailableView(
                    "Sin foto",
                    systemImage: "photo",
                    description: Text("Selecciona una foto de tu libreria")
                )
            }

            PhotosPicker(
                selection: $itemSeleccionado,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Seleccionar Foto", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.borderedProminent)
        }
        .onChange(of: itemSeleccionado) { _, nuevoItem in
            Task {
                if let data = try? await nuevoItem?.loadTransferable(
                    type: Data.self
                ) {
                    if let uiImage = UIImage(data: data) {
                        imagenCargada = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
}
```

### PhotosPicker — Seleccion Multiple

```swift
import SwiftUI
import PhotosUI

// MARK: - Seleccion multiple con galeria

struct SelectorMultiple: View {
    @State private var itemsSeleccionados: [PhotosPickerItem] = []
    @State private var imagenes: [Image] = []
    @State private var cargando = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100))],
                    spacing: 8
                ) {
                    ForEach(imagenes.indices, id: \.self) { indice in
                        imagenes[indice]
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .navigationTitle("Mi Galeria")
            .toolbar {
                PhotosPicker(
                    selection: $itemsSeleccionados,
                    maxSelectionCount: 10,
                    matching: .images,
                    preferredItemEncoding: .automatic
                ) {
                    Label("Agregar", systemImage: "plus")
                }
            }
            .overlay {
                if cargando {
                    ProgressView("Cargando fotos...")
                }
            }
            .onChange(of: itemsSeleccionados) { _, nuevos in
                Task {
                    cargando = true
                    defer { cargando = false }

                    var nuevasImagenes: [Image] = []
                    for item in nuevos {
                        if let data = try? await item.loadTransferable(
                            type: Data.self
                        ),
                           let uiImage = UIImage(data: data) {
                            nuevasImagenes.append(Image(uiImage: uiImage))
                        }
                    }
                    imagenes = nuevasImagenes
                }
            }
        }
    }
}
```

### Transferable — Carga Tipada de Fotos

```swift
import SwiftUI
import PhotosUI
import CoreTransferable

// MARK: - Modelo con Transferable para carga eficiente

struct FotoPerfil: Transferable {
    let imagen: Image
    let datos: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw ErrorFoto.formatoNoSoportado
            }
            return FotoPerfil(
                imagen: Image(uiImage: uiImage),
                datos: data
            )
        }
    }
}

enum ErrorFoto: LocalizedError {
    case formatoNoSoportado
    case sinDatos
    case camaraNoDisponible

    var errorDescription: String? {
        switch self {
        case .formatoNoSoportado:
            return "El formato de imagen no es compatible."
        case .sinDatos:
            return "No se pudieron obtener los datos de la imagen."
        case .camaraNoDisponible:
            return "La camara no esta disponible en este dispositivo."
        }
    }
}

// MARK: - Uso con Transferable

struct EditorPerfil: View {
    @State private var itemSeleccionado: PhotosPickerItem?
    @State private var fotoPerfil: FotoPerfil?

    var body: some View {
        VStack {
            if let foto = fotoPerfil {
                foto.imagen
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.blue, lineWidth: 3))

                Text("Tamano: \(foto.datos.count / 1024) KB")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            PhotosPicker(
                selection: $itemSeleccionado,
                matching: .images
            ) {
                Label("Cambiar Foto", systemImage: "camera")
            }
        }
        .onChange(of: itemSeleccionado) { _, nuevo in
            Task {
                fotoPerfil = try? await nuevo?.loadTransferable(
                    type: FotoPerfil.self
                )
            }
        }
    }
}
```

### AVCaptureSession — Captura de Camara

AVCaptureSession es el pipeline central de AVFoundation para captura. Configuras **inputs** (que dispositivos usar) y **outputs** (que producir). Es mas complejo que PhotosPicker, pero te da control total sobre la camara.

```swift
import AVFoundation
import SwiftUI

// MARK: - Gestor de camara

@Observable
class GestorCamara: NSObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var dispositivoActual: AVCaptureDevice?

    var fotoCapturada: UIImage?
    var errorMensaje: String?
    var camaraAutorizada = false

    // MARK: - Verificar y solicitar permiso
    func verificarPermiso() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            camaraAutorizada = true
        case .notDetermined:
            camaraAutorizada = await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            camaraAutorizada = false
            errorMensaje = "Permiso de camara denegado. Ve a Ajustes."
        @unknown default:
            break
        }
    }

    // MARK: - Configurar sesion de captura
    func configurarSesion() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Input — camara trasera
        guard let dispositivo = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            errorMensaje = "No se encontro camara"
            session.commitConfiguration()
            return
        }

        dispositivoActual = dispositivo

        do {
            let input = try AVCaptureDeviceInput(device: dispositivo)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            errorMensaje = "Error configurando camara: \(error.localizedDescription)"
            session.commitConfiguration()
            return
        }

        // Output — fotos
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        }

        session.commitConfiguration()
    }

    // MARK: - Iniciar/Detener
    func iniciar() {
        guard !session.isRunning else { return }
        Task.detached(priority: .userInitiated) {
            self.session.startRunning()
        }
    }

    func detener() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    // MARK: - Capturar foto
    func capturarFoto() {
        let configuracion = AVCapturePhotoSettings()
        configuracion.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: configuracion, delegate: self)
    }

    // MARK: - Cambiar camara (frontal/trasera)
    func cambiarCamara() {
        session.beginConfiguration()

        // Remover input actual
        if let inputActual = session.inputs.first {
            session.removeInput(inputActual)
        }

        // Determinar nueva posicion
        let nuevaPosicion: AVCaptureDevice.Position =
            dispositivoActual?.position == .back ? .front : .back

        guard let nuevoDispositivo = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: nuevaPosicion
        ) else {
            session.commitConfiguration()
            return
        }

        do {
            let nuevoInput = try AVCaptureDeviceInput(device: nuevoDispositivo)
            if session.canAddInput(nuevoInput) {
                session.addInput(nuevoInput)
                dispositivoActual = nuevoDispositivo
            }
        } catch {
            errorMensaje = error.localizedDescription
        }

        session.commitConfiguration()
    }
}

// MARK: - Delegate para recibir la foto capturada

extension GestorCamara: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            errorMensaje = error.localizedDescription
            return
        }

        guard let datos = photo.fileDataRepresentation(),
              let imagen = UIImage(data: datos) else {
            errorMensaje = "No se pudo procesar la foto"
            return
        }

        fotoCapturada = imagen
    }
}
```

### Preview de Camara en SwiftUI

```swift
import SwiftUI
import AVFoundation

// MARK: - UIViewRepresentable para el preview de camara

struct VistaPreviaCamara: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let vista = UIView(frame: .zero)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        vista.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer
        return vista
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Vista completa de camara

struct VistaCamara: View {
    @State private var gestor = GestorCamara()
    @State private var mostrandoFoto = false

    var body: some View {
        ZStack {
            if gestor.camaraAutorizada {
                VistaPreviaCamara(session: gestor.session)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    HStack(spacing: 40) {
                        // Boton cambiar camara
                        Button {
                            gestor.cambiarCamara()
                        } label: {
                            Image(systemName: "camera.rotate")
                                .font(.title)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Circle().fill(.black.opacity(0.5)))
                        }

                        // Boton capturar
                        Button {
                            gestor.capturarFoto()
                        } label: {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.5), lineWidth: 4)
                                        .frame(width: 80, height: 80)
                                )
                        }

                        // Thumbnail de ultima foto
                        if let foto = gestor.fotoCapturada {
                            Button {
                                mostrandoFoto = true
                            } label: {
                                Image(uiImage: foto)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        } else {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 50, height: 50)
                        }
                    }
                    .padding(.bottom, 30)
                }
            } else {
                ContentUnavailableView(
                    "Camara no disponible",
                    systemImage: "camera.slash",
                    description: Text(gestor.errorMensaje ?? "Permite el acceso en Ajustes")
                )
            }
        }
        .task {
            await gestor.verificarPermiso()
            if gestor.camaraAutorizada {
                gestor.configurarSesion()
                gestor.iniciar()
            }
        }
        .onDisappear {
            gestor.detener()
        }
        .fullScreenCover(isPresented: $mostrandoFoto) {
            if let foto = gestor.fotoCapturada {
                VistaFotoCapturada(imagen: foto)
            }
        }
    }
}

struct VistaFotoCapturada: View {
    let imagen: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Image(uiImage: imagen)
                .resizable()
                .scaledToFit()
                .navigationTitle("Foto Capturada")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cerrar") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(
                            item: Image(uiImage: imagen),
                            preview: SharePreview("Foto", image: Image(uiImage: imagen))
                        )
                    }
                }
        }
    }
}
```

### Guardar Fotos en la Libreria

```swift
import Photos

// MARK: - Guardar imagen en la libreria de fotos

func guardarEnLibreria(imagen: UIImage) async throws {
    // Verificar permiso de escritura
    let estado = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

    guard estado == .authorized || estado == .limited else {
        throw ErrorFoto.formatoNoSoportado
    }

    try await PHPhotoLibrary.shared().performChanges {
        PHAssetCreationRequest.forAsset().addResource(
            with: .photo,
            data: imagen.jpegData(compressionQuality: 0.9)!,
            options: nil
        )
    }
}
```

### Filtros con CoreImage

```swift
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - Aplicar filtros a imagenes

@Observable
class EditorImagenes {
    var imagenOriginal: UIImage?
    var imagenEditada: UIImage?

    private let contexto = CIContext()

    func aplicarFiltroSepia(intensidad: Double = 0.8) {
        guard let original = imagenOriginal,
              let ciImage = CIImage(image: original) else { return }

        let filtro = CIFilter.sepiaTone()
        filtro.inputImage = ciImage
        filtro.intensity = Float(intensidad)

        guard let resultado = filtro.outputImage,
              let cgImage = contexto.createCGImage(resultado, from: resultado.extent) else {
            return
        }

        imagenEditada = UIImage(cgImage: cgImage)
    }

    func aplicarFiltroBlur(radio: Double = 10) {
        guard let original = imagenOriginal,
              let ciImage = CIImage(image: original) else { return }

        let filtro = CIFilter.gaussianBlur()
        filtro.inputImage = ciImage
        filtro.radius = Float(radio)

        guard let resultado = filtro.outputImage,
              let cgImage = contexto.createCGImage(resultado, from: resultado.extent) else {
            return
        }

        imagenEditada = UIImage(cgImage: cgImage)
    }

    func aplicarFiltroVignette(intensidad: Double = 2, radio: Double = 1) {
        guard let original = imagenOriginal,
              let ciImage = CIImage(image: original) else { return }

        let filtro = CIFilter.vignette()
        filtro.inputImage = ciImage
        filtro.intensity = Float(intensidad)
        filtro.radius = Float(radio)

        guard let resultado = filtro.outputImage,
              let cgImage = contexto.createCGImage(resultado, from: resultado.extent) else {
            return
        }

        imagenEditada = UIImage(cgImage: cgImage)
    }

    func resetear() {
        imagenEditada = nil
    }
}
```

---

## Ejercicio 1: Selector de Avatar con PhotosPicker (Basico)

**Objetivo**: Crear un flujo de seleccion de foto de perfil usando PhotosPicker.

**Requisitos**:
1. PhotosPicker que permita seleccionar solo imagenes (no videos)
2. Mostrar la imagen seleccionada en un circulo como avatar
3. Permitir eliminar la foto seleccionada con un boton
4. Manejar el estado de carga con un ProgressView mientras se procesa la imagen

---

## Ejercicio 2: Galeria con Filtros (Intermedio)

**Objetivo**: Implementar seleccion multiple de fotos con aplicacion de filtros CoreImage.

**Requisitos**:
1. PhotosPicker con seleccion multiple (maximo 5 fotos)
2. Mostrar las fotos en un grid con LazyVGrid
3. Al seleccionar una foto del grid, mostrar editor con 3 filtros (sepia, blur, vignette)
4. Sliders para controlar la intensidad de cada filtro
5. Boton para guardar la imagen editada en la libreria de fotos

---

## Ejercicio 3: App de Camara Personalizada (Avanzado)

**Objetivo**: Construir una experiencia de camara completa con AVCaptureSession.

**Requisitos**:
1. Preview de camara en tiempo real con VistaPreviaCamara
2. Boton para cambiar entre camara frontal y trasera
3. Captura de foto con AVCapturePhotoOutput y preview de la foto tomada
4. Opcion para aplicar un filtro CoreImage antes de guardar
5. Guardar la foto en la libreria con PHPhotoLibrary y confirmacion visual al usuario

---

## 5 Errores Comunes

### 1. Pedir permiso de fotos cuando solo necesitas PhotosPicker

```swift
// MAL — pedir acceso completo a la libreria
import Photos
PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
    // El usuario ve un dialogo aterrador pidiendo acceso a TODAS sus fotos
}

// BIEN — usar PhotosPicker que NO requiere permisos
PhotosPicker(selection: $item, matching: .images) {
    Text("Seleccionar foto")
}
// El sistema maneja el acceso, tu app solo recibe lo seleccionado
```

### 2. No detener AVCaptureSession al salir de la vista

```swift
// MAL — la sesion sigue corriendo en background
struct VistaCamara: View {
    @State var gestor = GestorCamara()

    var body: some View {
        VistaPreviaCamara(session: gestor.session)
            .onAppear { gestor.iniciar() }
        // Nunca se detiene — consume bateria y recursos
    }
}

// BIEN — detener al desaparecer
struct VistaCamara: View {
    @State var gestor = GestorCamara()

    var body: some View {
        VistaPreviaCamara(session: gestor.session)
            .onAppear { gestor.iniciar() }
            .onDisappear { gestor.detener() }
    }
}
```

### 3. Configurar AVCaptureSession en el main thread

```swift
// MAL — configurar en main thread bloquea la UI
func viewDidLoad() {
    super.viewDidLoad()
    session.beginConfiguration()
    // ... configuracion pesada ...
    session.commitConfiguration()
    session.startRunning()  // Bloquea la UI durante la inicializacion
}

// BIEN — configurar y arrancar en background
Task.detached(priority: .userInitiated) {
    self.gestor.configurarSesion()
    self.gestor.iniciar()
}
```

### 4. No manejar el caso donde loadTransferable falla

```swift
// MAL — asumir que loadTransferable siempre funciona
.onChange(of: itemSeleccionado) { _, nuevo in
    Task {
        let data = try! await nuevo!.loadTransferable(type: Data.self)
        imagen = Image(uiImage: UIImage(data: data!)!)
        // Cadena de force unwraps — crashea con archivos corruptos o HEIF
    }
}

// BIEN — manejar cada punto de fallo
.onChange(of: itemSeleccionado) { _, nuevo in
    Task {
        guard let nuevo else { return }

        do {
            guard let data = try await nuevo.loadTransferable(type: Data.self) else {
                print("No se pudieron obtener datos")
                return
            }
            guard let uiImage = UIImage(data: data) else {
                print("Formato de imagen no soportado")
                return
            }
            imagen = Image(uiImage: uiImage)
        } catch {
            print("Error cargando imagen: \(error)")
        }
    }
}
```

### 5. Olvidar NSCameraUsageDescription en Info.plist

```swift
// MAL — intentar usar la camara sin descripcion de uso
AVCaptureDevice.requestAccess(for: .video) { granted in
    // CRASH: "This app has crashed because it attempted to access
    // privacy-sensitive data without a usage description."
}

// BIEN — agregar en Info.plist ANTES de compilar
// <key>NSCameraUsageDescription</key>
// <string>Necesitamos la camara para tomar fotos de tus productos.</string>

// Para guardar fotos:
// <key>NSPhotoLibraryAddUsageDescription</key>
// <string>Para guardar las fotos editadas en tu libreria.</string>
```

---

## Checklist

- [ ] Usar PhotosPicker para seleccion de fotos sin requerir permisos
- [ ] Cargar fotos con loadTransferable de forma asincrona y segura
- [ ] Implementar seleccion multiple con maxSelectionCount
- [ ] Crear un modelo Transferable personalizado para fotos
- [ ] Configurar AVCaptureSession con input de camara y output de foto
- [ ] Mostrar preview de camara en SwiftUI con UIViewRepresentable
- [ ] Capturar fotos con AVCapturePhotoOutput y delegate
- [ ] Cambiar entre camara frontal y trasera
- [ ] Guardar fotos en la libreria con PHPhotoLibrary
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Camera y Photos aportan funcionalidad visual esencial a tu app:
- **PhotosPicker** para que el usuario seleccione imagenes de perfil, portadas o contenido
- **Camara personalizada** para capturar fotos dentro del flujo de tu app (ej: escanear recibos)
- **CoreImage filtros** para edicion basica de imagenes antes de guardar o compartir
- **SwiftData + fotos** para guardar referencias a imagenes junto con otros datos del modelo
- **ShareLink** para compartir fotos capturadas o editadas con otros usuarios
- **Vision + camara** (Modulo 06) para analisis de imagenes en tiempo real con CoreML

---

*Leccion 24 | Camera y Photos | Semana 30 | Modulo 05: Hardware y Sensores*
*Siguiente: Leccion 25 — IA y Machine Learning (Modulo 06)*
