# Flashcards — Modulo 05: Hardware y Sensores

---

### Tarjeta 1
**Pregunta:** Que es `HKHealthStore` y cual es el primer paso para usarlo?
**Respuesta:** `HKHealthStore` es el punto de entrada a HealthKit para leer y escribir datos de salud. El primer paso es verificar disponibilidad con `HKHealthStore.isHealthDataAvailable()` (no disponible en iPad). Luego se solicitan permisos con `requestAuthorization(toShare:read:)` especificando los tipos de datos que necesitas.

---

### Tarjeta 2
**Pregunta:** Como funciona el modelo de autorizacion de HealthKit?
**Respuesta:** HealthKit usa un modelo de permisos granular: 1) Se solicitan permisos por **tipo de dato** individual (pasos, frecuencia cardiaca, etc.). 2) Los permisos de **lectura y escritura son independientes**. 3) El usuario puede negar permisos individuales. 4) No puedes saber si el usuario denego la lectura (por privacidad, simplemente no recibes datos). 5) Los permisos se solicitan una sola vez.

---

### Tarjeta 3
**Pregunta:** Como se muestran mapas en SwiftUI con MapKit?
**Respuesta:** Se usa la vista `Map` con bindings: `Map(position: $posicion) { Marker("Titulo", coordinate: coordenada) }`. Soporta: `Marker` (pin), `Annotation` (vista custom), `MapPolyline` (rutas), `MapCircle` (areas). La posicion se controla con `MapCameraPosition` que puede ser `.automatic`, `.region()`, `.camera()`.

---

### Tarjeta 4
**Pregunta:** Como se obtiene la ubicacion del usuario con `CLLocationManager` en Swift moderno?
**Respuesta:** 1) Crear instancia de `CLLocationManager`. 2) Configurar `desiredAccuracy`. 3) Solicitar permiso: `requestWhenInUseAuthorization()`. 4) En Swift concurrency, usar `CLLocationUpdate.liveUpdates()` que devuelve un `AsyncSequence` de ubicaciones: `for try await update in CLLocationUpdate.liveUpdates() { ... }`. Requiere clave `NSLocationWhenInUseUsageDescription` en Info.plist.

---

### Tarjeta 5
**Pregunta:** Cuales son los niveles de permiso de ubicacion y cuando usar cada uno?
**Respuesta:** 1) **When In Use**: acceso solo cuando la app esta visible. Usar por defecto. 2) **Always**: acceso en segundo plano. Solo si necesitas geofencing o tracking continuo. 3) **Temporary (iOS 17+)**: acceso puntual para una sesion. Apple recomienda siempre empezar con "When In Use" y escalar solo si es necesario.

---

### Tarjeta 6
**Pregunta:** Como se usa `PhotosPicker` en SwiftUI?
**Respuesta:** `PhotosPicker(selection: $seleccion, matching: .images) { Label("Elegir foto", systemImage: "photo") }`. El binding es de tipo `PhotosPickerItem?`. Para obtener la imagen: `if let data = try await item.loadTransferable(type: Data.self)`. Soporta filtros: `.images`, `.videos`, `.screenshots`, `.livePhotos`.

---

### Tarjeta 7
**Pregunta:** Que es `AVCaptureSession` y cuales son sus componentes principales?
**Respuesta:** `AVCaptureSession` coordina el flujo de datos de captura de camara/microfono. Componentes: 1) **Input** (`AVCaptureDeviceInput`): fuente (camara frontal/trasera, microfono). 2) **Output** (`AVCapturePhotoOutput`, `AVCaptureVideoDataOutput`): destino de los datos. 3) **Preview** (`AVCaptureVideoPreviewLayer`): vista previa en pantalla. Se configura, se agregan inputs/outputs, y se inicia con `startRunning()`.

---

### Tarjeta 8
**Pregunta:** Como se accede al acelerometro y giroscopio con CoreMotion?
**Respuesta:** Se usa `CMMotionManager`. Para acelerometro: `manager.startAccelerometerUpdates(to: .main) { data, error in ... }`. Para datos fusionados (acelerometro + giroscopio + magnetometro): `manager.startDeviceMotionUpdates()`. Los datos incluyen actitud (rotacion), gravedad, aceleracion del usuario y velocidad de rotacion. Siempre llamar `stopUpdates()` cuando no se necesiten.

---

### Tarjeta 9
**Pregunta:** Que permisos de Info.plist son necesarios para los principales sensores?
**Respuesta:** 1) **Camara**: `NSCameraUsageDescription`. 2) **Microfono**: `NSMicrophoneUsageDescription`. 3) **Ubicacion**: `NSLocationWhenInUseUsageDescription`. 4) **HealthKit**: `NSHealthShareUsageDescription` + `NSHealthUpdateUsageDescription`. 5) **Fotos**: `NSPhotoLibraryUsageDescription`. Cada clave requiere un string explicando al usuario POR QUE necesitas acceso.

---

### Tarjeta 10
**Pregunta:** Cual es la diferencia entre `Transferable` y el antiguo enfoque de cargar datos de Photos?
**Respuesta:** `Transferable` es el protocolo moderno para transferir datos entre apps y componentes. `PhotosPickerItem.loadTransferable(type:)` usa async/await y funciona con tipos como `Image`, `Data`, o custom types. El enfoque antiguo usaba `PHImageManager` con callbacks, era mas complejo y requeria permiso completo a la libreria de fotos. `PhotosPicker` no necesita permiso.
