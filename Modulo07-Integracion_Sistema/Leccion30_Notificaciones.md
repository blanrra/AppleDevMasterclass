# Leccion 30: Notificaciones

**Modulo 07: Integracion con el Sistema** | Semana 38

---

## TL;DR — Resumen en 2 minutos

- **UNUserNotificationCenter**: El gestor central de todas las notificaciones — locales y remotas
- **Locales**: Se programan en el dispositivo con triggers de tiempo, calendario o ubicacion
- **Push (APNs)**: Llegan desde tu servidor via Apple Push Notification service — requieren configuracion de certificados
- **Rich Notifications**: Pueden incluir imagenes, video, acciones interactivas y UI personalizada
- **Categorias y Acciones**: Permiten al usuario responder directamente desde la notificacion sin abrir la app

---

## Cupertino MCP

```bash
cupertino search "UserNotifications"
cupertino search "UNUserNotificationCenter"
cupertino search "UNNotificationContent"
cupertino search "UNNotificationTrigger"
cupertino search "UNNotificationAction"
cupertino search "UNNotificationCategory"
cupertino search "UNNotificationServiceExtension"
cupertino search "UNNotificationContentExtension"
cupertino search --source samples "notifications"
cupertino search --source updates "UserNotifications"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC21 | [Send communication and Time Sensitive notifications](https://developer.apple.com/videos/play/wwdc2021/10091/) | **Esencial** — Niveles de interrupcion |
| WWDC22 | [What's new in Notification Center](https://developer.apple.com/videos/play/wwdc2022/10115/) | Agrupacion y resumen |
| WWDC20 | [The Push Notifications primer](https://developer.apple.com/videos/play/wwdc2020/10095/) | Fundamentos de push |
| WWDC18 | [Using Grouped Notifications](https://developer.apple.com/videos/play/wwdc2018/711/) | Agrupacion avanzada |
| WWDC23 | [Meet Push Notifications Console](https://developer.apple.com/videos/play/wwdc2023/10025/) | Herramienta de testing |
| :es: | [Julio Cesar Fernandez — Notificaciones](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que entender Notificaciones a fondo?

Las notificaciones son el canal mas directo entre tu app y el usuario cuando la app no esta abierta. Pero son un arma de doble filo: bien usadas aumentan la retencion; mal usadas hacen que el usuario desactive todas las notificaciones o desinstale tu app.

Desde iOS 15, Apple introdujo niveles de interrupcion (`UNNotificationInterruptionLevel`) que le dan al usuario control granular. Entender esto es clave para no ser invasivo.

```
  ┌──────────────────────────────────────────────────────────┐
  │            TIPOS DE NOTIFICACIONES                       │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   LOCALES                      REMOTAS (Push)            │
  │   ┌──────────────┐            ┌──────────────┐           │
  │   │ Tu App       │            │ Tu Servidor  │           │
  │   │ programa     │            │ envia a APNs │           │
  │   │ el trigger   │            │              │           │
  │   └──────┬───────┘            └──────┬───────┘           │
  │          │                           │                   │
  │   ┌──────▼───────┐            ┌──────▼───────┐           │
  │   │ Triggers:    │            │ Apple Push   │           │
  │   │ • Tiempo     │            │ Notification │           │
  │   │ • Calendario │            │ service      │           │
  │   │ • Ubicacion  │            │ (APNs)       │           │
  │   └──────┬───────┘            └──────┬───────┘           │
  │          │                           │                   │
  │          └──────────┬────────────────┘                   │
  │                     ▼                                    │
  │          ┌───────────────────┐                           │
  │          │  UNUserNotif.     │                           │
  │          │  Center           │                           │
  │          │  → Muestra al     │                           │
  │          │    usuario        │                           │
  │          └───────────────────┘                           │
  └──────────────────────────────────────────────────────────┘
```

### Solicitar Permisos

Antes de enviar cualquier notificacion, necesitas permiso del usuario. Pide permiso en un momento contextual (no al iniciar la app).

```swift
import UserNotifications

// MARK: - Solicitar permisos de notificacion

func solicitarPermisoNotificaciones() async -> Bool {
    let centro = UNUserNotificationCenter.current()

    do {
        let concedido = try await centro.requestAuthorization(
            options: [.alert, .badge, .sound, .provisional]
        )
        // .provisional permite enviar notificaciones silenciosas
        // sin pedir permiso explicitamente — aparecen en el centro
        // de notificaciones sin sonido ni banner

        print("Permiso concedido: \(concedido)")
        return concedido
    } catch {
        print("Error solicitando permiso: \(error)")
        return false
    }
}

// MARK: - Verificar estado actual de permisos

func verificarPermisos() async {
    let centro = UNUserNotificationCenter.current()
    let configuracion = await centro.notificationSettings()

    switch configuracion.authorizationStatus {
    case .notDetermined:
        print("Aun no se ha pedido permiso")
    case .denied:
        print("El usuario denego las notificaciones")
        // Mostrar UI explicando el valor y como activar en Configuracion
    case .authorized:
        print("Notificaciones autorizadas")
    case .provisional:
        print("Permiso provisional (silencioso)")
    case .ephemeral:
        print("Permiso efimero (App Clip)")
    @unknown default:
        break
    }

    // Verificar capacidades individuales
    print("Alertas: \(configuracion.alertSetting == .enabled)")
    print("Sonido: \(configuracion.soundSetting == .enabled)")
    print("Badge: \(configuracion.badgeSetting == .enabled)")
}
```

### Notificaciones Locales — Trigger por Tiempo

```swift
import UserNotifications

// MARK: - Notificacion con trigger de tiempo

func programarRecordatorio(titulo: String, cuerpo: String, segundos: TimeInterval) async throws {
    let centro = UNUserNotificationCenter.current()

    // 1. Crear el contenido
    let contenido = UNMutableNotificationContent()
    contenido.title = titulo
    contenido.body = cuerpo
    contenido.sound = .default
    contenido.badge = 1

    // Nivel de interrupcion (iOS 15+)
    contenido.interruptionLevel = .timeSensitive

    // Datos adicionales que tu app puede leer al abrirse
    contenido.userInfo = [
        "tipo": "recordatorio",
        "pantalla": "tareas"
    ]

    // 2. Crear el trigger
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: segundos,
        repeats: false
    )

    // 3. Crear la request con ID unico
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: contenido,
        trigger: trigger
    )

    // 4. Programar
    try await centro.add(request)
    print("Recordatorio programado en \(segundos) segundos")
}

// Uso
Task {
    try await programarRecordatorio(
        titulo: "Hora de estudiar",
        cuerpo: "Leccion 30: Notificaciones te espera",
        segundos: 10
    )
}
```

### Notificaciones Locales — Trigger por Calendario

```swift
import UserNotifications

// MARK: - Notificacion diaria a una hora especifica

func programarNotificacionDiaria(hora: Int, minuto: Int, titulo: String, cuerpo: String) async throws {
    let centro = UNUserNotificationCenter.current()

    let contenido = UNMutableNotificationContent()
    contenido.title = titulo
    contenido.body = cuerpo
    contenido.sound = .default

    // Trigger basado en componentes de fecha
    var dateComponents = DateComponents()
    dateComponents.hour = hora
    dateComponents.minute = minuto
    // No especificar dia/mes para que se repita diariamente

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: dateComponents,
        repeats: true  // Se repite todos los dias
    )

    let request = UNNotificationRequest(
        identifier: "recordatorio-diario",  // ID fijo = reemplaza la anterior
        content: contenido,
        trigger: trigger
    )

    try await centro.add(request)
    print("Notificacion diaria programada a las \(hora):\(minuto)")
}

// MARK: - Notificacion en una fecha exacta

func programarParaFecha(_ fecha: Date, titulo: String, cuerpo: String) async throws {
    let centro = UNUserNotificationCenter.current()

    let contenido = UNMutableNotificationContent()
    contenido.title = titulo
    contenido.body = cuerpo
    contenido.sound = UNNotificationSound(named: UNNotificationSoundName("alerta.wav"))

    let componentes = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute],
        from: fecha
    )

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: componentes,
        repeats: false
    )

    let request = UNNotificationRequest(
        identifier: "evento-\(fecha.timeIntervalSince1970)",
        content: contenido,
        trigger: trigger
    )

    try await centro.add(request)
}
```

### Notificaciones Locales — Trigger por Ubicacion

```swift
import UserNotifications
import CoreLocation

// MARK: - Notificacion al entrar o salir de una zona

func programarNotificacionUbicacion(
    latitud: Double,
    longitud: Double,
    radio: Double,
    titulo: String,
    alEntrar: Bool = true
) async throws {
    let centro = UNUserNotificationCenter.current()

    let contenido = UNMutableNotificationContent()
    contenido.title = titulo
    contenido.body = alEntrar
        ? "Has llegado a la zona"
        : "Has salido de la zona"
    contenido.sound = .default

    // Region geografica
    let coordenada = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    let region = CLCircularRegion(
        center: coordenada,
        radius: radio,
        identifier: "zona-\(titulo)"
    )
    region.notifyOnEntry = alEntrar
    region.notifyOnExit = !alEntrar

    let trigger = UNLocationNotificationTrigger(
        region: region,
        repeats: true
    )

    let request = UNNotificationRequest(
        identifier: "ubicacion-\(titulo)",
        content: contenido,
        trigger: trigger
    )

    try await centro.add(request)
    print("Notificacion de ubicacion configurada")
}

// Ejemplo: notificar al llegar al gimnasio
Task {
    try await programarNotificacionUbicacion(
        latitud: 40.4168,
        longitud: -3.7038,
        radio: 100,  // metros
        titulo: "Gimnasio",
        alEntrar: true
    )
}
```

### Acciones y Categorias — Responder sin Abrir la App

Las categorias definen **acciones** que aparecen en la notificacion. El usuario puede responder directamente.

```swift
import UserNotifications

// MARK: - Definir categorias y acciones

func configurarCategoriasNotificacion() {
    let centro = UNUserNotificationCenter.current()

    // Accion: Marcar como completada
    let accionCompletar = UNNotificationAction(
        identifier: "COMPLETAR",
        title: "Completar",
        options: []  // .foreground abre la app, .destructive muestra en rojo
    )

    // Accion: Posponer
    let accionPosponer = UNNotificationAction(
        identifier: "POSPONER",
        title: "Posponer 1 hora",
        options: []
    )

    // Accion: Responder con texto
    let accionResponder = UNTextInputNotificationAction(
        identifier: "RESPONDER",
        title: "Responder",
        options: .foreground,
        textInputButtonTitle: "Enviar",
        textInputPlaceholder: "Escribe tu respuesta..."
    )

    // Accion destructiva: Eliminar
    let accionEliminar = UNNotificationAction(
        identifier: "ELIMINAR",
        title: "Eliminar",
        options: [.destructive, .authenticationRequired]
    )

    // Categoria de tarea
    let categoriaTarea = UNNotificationCategory(
        identifier: "TAREA",
        actions: [accionCompletar, accionPosponer, accionEliminar],
        intentIdentifiers: [],
        options: [.customDismissAction]
    )

    // Categoria de mensaje
    let categoriaMensaje = UNNotificationCategory(
        identifier: "MENSAJE",
        actions: [accionResponder],
        intentIdentifiers: [],
        options: []
    )

    // Registrar todas las categorias
    centro.setNotificationCategories([categoriaTarea, categoriaMensaje])
}

// MARK: - Enviar notificacion con categoria

func enviarNotificacionTarea(titulo: String, cuerpo: String) async throws {
    let contenido = UNMutableNotificationContent()
    contenido.title = titulo
    contenido.body = cuerpo
    contenido.sound = .default
    contenido.categoryIdentifier = "TAREA"  // Vincula con la categoria

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(
        identifier: "tarea-\(UUID().uuidString)",
        content: contenido,
        trigger: trigger
    )

    try await UNUserNotificationCenter.current().add(request)
}
```

### UNUserNotificationCenterDelegate — Manejar Respuestas

```swift
import UserNotifications

// MARK: - Delegate para manejar acciones del usuario

class GestorNotificaciones: NSObject, UNUserNotificationCenterDelegate {

    static let compartido = GestorNotificaciones()

    func configurar() {
        UNUserNotificationCenter.current().delegate = self
        configurarCategoriasNotificacion()
    }

    /// Se llama cuando el usuario interactua con una notificacion
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let categoria = response.notification.request.content.categoryIdentifier

        switch response.actionIdentifier {
        case "COMPLETAR":
            print("Usuario completo la tarea")
            // Marcar tarea como completada en SwiftData

        case "POSPONER":
            print("Usuario pospuso la tarea")
            // Reprogramar notificacion para dentro de 1 hora
            try? await programarRecordatorio(
                titulo: response.notification.request.content.title,
                cuerpo: response.notification.request.content.body,
                segundos: 3600
            )

        case "ELIMINAR":
            print("Usuario elimino la tarea")
            // Eliminar de la base de datos

        case "RESPONDER":
            if let textoResponse = response as? UNTextInputNotificationResponse {
                print("Usuario respondio: \(textoResponse.userText)")
                // Procesar la respuesta
            }

        case UNNotificationDefaultActionIdentifier:
            // El usuario toco la notificacion (abrir app)
            print("Abrir pantalla: \(userInfo["pantalla"] ?? "inicio")")

        case UNNotificationDismissActionIdentifier:
            // El usuario descarto la notificacion
            print("Notificacion descartada")

        default:
            break
        }
    }

    /// Se llama cuando la notificacion llega con la app en foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Decidir como mostrar la notificacion cuando la app esta abierta
        return [.banner, .badge, .sound]
        // Retornar [] para manejarla silenciosamente
    }
}
```

### Gestionar Notificaciones Pendientes

```swift
import UserNotifications

// MARK: - Administrar notificaciones programadas

func listarNotificacionesPendientes() async {
    let centro = UNUserNotificationCenter.current()
    let pendientes = await centro.pendingNotificationRequests()

    print("Notificaciones pendientes: \(pendientes.count)")
    for notif in pendientes {
        print("  - [\(notif.identifier)] \(notif.content.title)")
    }
}

func cancelarNotificacion(id: String) {
    UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: [id])
}

func cancelarTodasLasNotificaciones() {
    UNUserNotificationCenter.current()
        .removeAllPendingNotificationRequests()
}

func limpiarNotificacionesEntregadas() {
    UNUserNotificationCenter.current()
        .removeAllDeliveredNotifications()
}

// MARK: - Actualizar el badge

func actualizarBadge(cantidad: Int) async throws {
    try await UNUserNotificationCenter.current()
        .setBadgeCount(cantidad)
}
```

### Push Notifications — Configuracion de APNs

Las push notifications requieren un servidor que envie mensajes a Apple Push Notification service (APNs).

```swift
import UIKit

// MARK: - Registrar para push notifications

// En tu App struct o AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configurar delegate de notificaciones
        GestorNotificaciones.compartido.configurar()

        // Registrar para push
        application.registerForRemoteNotifications()

        return true
    }

    /// Token de dispositivo para push — enviarlo a tu servidor
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
        // Enviar este token a tu servidor backend
        // para que pueda enviar push a este dispositivo
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Error registrando push: \(error)")
        // Push no funciona en el simulador
    }
}
```

### Rich Notifications — Imagenes y Media

Para notificaciones con contenido multimedia, necesitas un **Notification Service Extension**.

```swift
import UserNotifications

// MARK: - Notification Service Extension
// Target separado: File > New > Target > Notification Service Extension

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Descargar imagen adjunta
        if let urlString = bestAttemptContent.userInfo["imagen_url"] as? String,
           let url = URL(string: urlString) {

            descargarAdjunto(url: url) { adjunto in
                if let adjunto {
                    bestAttemptContent.attachments = [adjunto]
                }
                contentHandler(bestAttemptContent)
            }
        } else {
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Se llama si el proceso tarda demasiado (30 segundos max)
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func descargarAdjunto(
        url: URL,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL, error == nil else {
                completion(nil)
                return
            }

            // Mover a ubicacion con extension correcta
            let destino = tempURL.appendingPathExtension("jpg")
            try? FileManager.default.moveItem(at: tempURL, to: destino)

            let adjunto = try? UNNotificationAttachment(
                identifier: UUID().uuidString,
                url: destino,
                options: nil
            )
            completion(adjunto)
        }
        task.resume()
    }
}
```

### Notificacion Local con Imagen

```swift
import UserNotifications

// MARK: - Notificacion local con imagen adjunta

func enviarNotificacionConImagen(titulo: String, cuerpo: String, imagenNombre: String) async throws {
    let centro = UNUserNotificationCenter.current()

    let contenido = UNMutableNotificationContent()
    contenido.title = titulo
    contenido.body = cuerpo
    contenido.sound = .default

    // Adjuntar imagen local desde el bundle
    if let imagenURL = Bundle.main.url(forResource: imagenNombre, withExtension: "jpg") {
        // Copiar a directorio temporal (requerido por el framework)
        let tempDir = FileManager.default.temporaryDirectory
        let destino = tempDir.appendingPathComponent("\(UUID().uuidString).jpg")
        try FileManager.default.copyItem(at: imagenURL, to: destino)

        let adjunto = try UNNotificationAttachment(
            identifier: "imagen",
            url: destino,
            options: [
                UNNotificationAttachmentOptionsThumbnailClippingRectKey:
                    CGRect(x: 0, y: 0, width: 1, height: 1).dictionaryRepresentation
            ]
        )
        contenido.attachments = [adjunto]
    }

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
    let request = UNNotificationRequest(
        identifier: "notif-imagen-\(UUID().uuidString)",
        content: contenido,
        trigger: trigger
    )

    try await centro.add(request)
}
```

### Niveles de Interrupcion (iOS 15+)

```swift
import UserNotifications

// MARK: - Niveles de interrupcion

func enviarConNivel(titulo: String, nivel: UNNotificationInterruptionLevel) async throws {
    let contenido = UNMutableNotificationContent()
    contenido.title = titulo
    contenido.sound = .default

    // Niveles disponibles:
    switch nivel {
    case .passive:
        // Sin sonido ni vibracion — solo aparece en el centro
        contenido.body = "Informacion no urgente"
        contenido.interruptionLevel = .passive

    case .active:
        // Comportamiento por defecto — sonido y banner
        contenido.body = "Informacion relevante"
        contenido.interruptionLevel = .active

    case .timeSensitive:
        // Atraviesa Focus/No Molestar — requiere entitlement
        contenido.body = "Requiere atencion pronto"
        contenido.interruptionLevel = .timeSensitive

    case .critical:
        // Siempre suena incluso en silencio — requiere aprobacion de Apple
        contenido.body = "Emergencia"
        contenido.interruptionLevel = .critical
        contenido.sound = UNNotificationSound.defaultCritical

    @unknown default:
        contenido.interruptionLevel = .active
    }

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: contenido,
        trigger: trigger
    )

    try await UNUserNotificationCenter.current().add(request)
}
```

---

## Ejercicio 1: Sistema de Recordatorios Locales (Basico)

**Objetivo**: Crear un gestor de recordatorios con los tres tipos de trigger.

**Requisitos**:
1. Funcion para programar recordatorio por tiempo (en X minutos)
2. Funcion para programar recordatorio por calendario (hora y dia de la semana)
3. Funcion para listar todos los recordatorios pendientes
4. Funcion para cancelar un recordatorio por su ID

---

## Ejercicio 2: Notificaciones con Acciones Interactivas (Intermedio)

**Objetivo**: Implementar categorias con acciones que el usuario pueda ejecutar desde la notificacion.

**Requisitos**:
1. Categoria "TAREA" con acciones: Completar, Posponer (1h), Eliminar (destructiva)
2. Categoria "MENSAJE" con accion de texto: Responder (UNTextInputNotificationAction)
3. Implementar `UNUserNotificationCenterDelegate` para manejar cada accion
4. Al posponer, reprogramar la notificacion 1 hora despues
5. Al responder, imprimir el texto del usuario en consola

---

## Ejercicio 3: Sistema Completo de Notificaciones (Avanzado)

**Objetivo**: Construir un sistema de notificaciones robusto para produccion.

**Requisitos**:
1. `GestorNotificaciones` como clase singleton con delegate configurado
2. Solicitud de permisos con manejo de todos los estados (denied, provisional, etc.)
3. Programar notificaciones con diferentes niveles de interrupcion (passive, active, timeSensitive)
4. Notificaciones con imagen adjunta (local desde bundle)
5. Agrupacion de notificaciones con `threadIdentifier`
6. Vista SwiftUI con lista de notificaciones pendientes, boton para agregar y swipe para eliminar
7. Badge count sincronizado con las tareas pendientes

---

## 5 Errores Comunes

### 1. Pedir permisos al iniciar la app sin contexto

```swift
// MAL — pedir permiso en didFinishLaunching
func application(_ app: UIApplication,
    didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    // El usuario no sabe por que ni para que
    return true
}

// BIEN — pedir en un momento contextual
struct ConfiguracionView: View {
    var body: some View {
        Section("Recordatorios") {
            Button("Activar recordatorios diarios") {
                Task {
                    let concedido = await solicitarPermisoNotificaciones()
                    if concedido {
                        // Programar recordatorios
                    }
                }
            }
        }
    }
}
```

### 2. No asignar delegate antes de que llegue la notificacion

```swift
// MAL — delegate se asigna tarde y se pierden notificaciones
class MiViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        // Si una notificacion llego antes, se perdio
    }
}

// BIEN — asignar delegate lo mas pronto posible
// En App struct o AppDelegate.didFinishLaunching
func application(_ app: UIApplication,
    didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().delegate = GestorNotificaciones.compartido
    return true
}
```

### 3. Usar IDs aleatorios cuando quieres reemplazar notificaciones

```swift
// MAL — cada vez se crea una notificacion nueva
let request = UNNotificationRequest(
    identifier: UUID().uuidString,  // ID unico cada vez
    content: contenido,
    trigger: trigger
)
// Resultado: 50 notificaciones duplicadas

// BIEN — usar ID fijo para reemplazar la anterior
let request = UNNotificationRequest(
    identifier: "recordatorio-diario",  // Mismo ID = reemplaza
    content: contenido,
    trigger: trigger
)
```

### 4. Olvidar manejar willPresent para notificaciones en foreground

```swift
// MAL — sin delegate, las notificaciones no se muestran con la app abierta
// El usuario no ve nada

// BIEN — implementar willPresent
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
) async -> UNNotificationPresentationOptions {
    // Mostrar banner y reproducir sonido incluso con la app abierta
    return [.banner, .sound, .badge]
}
```

### 5. No actualizar el badge count correctamente

```swift
// MAL — hardcodear el badge
contenido.badge = 1  // Siempre muestra 1, sin importar cuantas hay

// BIEN — calcular el badge basado en datos reales
let tareasPendientes = await contarTareasPendientes()
try await UNUserNotificationCenter.current().setBadgeCount(tareasPendientes)

// Y limpiar cuando el usuario abre la app
func sceneDidBecomeActive(_ scene: UIScene) {
    Task {
        try? await UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
```

---

## Checklist

- [ ] Solicitar permisos con requestAuthorization y verificar el estado
- [ ] Programar notificacion local con UNTimeIntervalNotificationTrigger
- [ ] Programar notificacion con UNCalendarNotificationTrigger (hora/dia)
- [ ] Programar notificacion con UNLocationNotificationTrigger
- [ ] Definir categorias con UNNotificationCategory y acciones
- [ ] Implementar UNUserNotificationCenterDelegate (didReceive + willPresent)
- [ ] Manejar acciones del usuario (completar, posponer, responder con texto)
- [ ] Listar y cancelar notificaciones pendientes
- [ ] Registrar para push notifications y obtener device token
- [ ] Entender los niveles de interrupcion (passive, active, timeSensitive)
- [ ] Agregar imagen adjunta a una notificacion (UNNotificationAttachment)
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Las notificaciones seran un canal esencial de comunicacion con el usuario:
- **Recordatorios locales**: Avisar al usuario de tareas pendientes, citas, o plazos
- **Acciones rapidas**: El usuario puede completar o posponer acciones sin abrir la app
- **Push notifications**: Si tu app tiene backend, notificar cambios en tiempo real
- **Rich notifications**: Mostrar previews con imagenes para mayor engagement
- **Niveles de interrupcion**: Respetar al usuario — no todo es urgente
- **Integracion con Live Activities**: Las push pueden actualizar Live Activities (Leccion 29)

---

*Leccion 30 | Notificaciones | Semana 38 | Modulo 07: Integracion con el Sistema*
*Siguiente: Leccion 31 — Plataformas (Modulo 08)*
