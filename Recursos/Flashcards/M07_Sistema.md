# Flashcards — Modulo 07: Integracion con el Sistema

---

### Tarjeta 1
**Pregunta:** Que es un `AppIntent` y para que sirve?
**Respuesta:** `AppIntent` es un protocolo que define una accion que tu app expone al sistema. Permite que Siri, Shortcuts, Spotlight y el sistema ejecuten acciones de tu app. Se define con `title`, `description`, parametros y un metodo `perform()` async. Ejemplo: "Agregar tarea", "Iniciar temporizador". Es el reemplazo moderno de SiriKit Intents.

---

### Tarjeta 2
**Pregunta:** Que es un `AppEntity` y como se relaciona con AppIntent?
**Respuesta:** `AppEntity` representa un objeto de tu app que el sistema puede referenciar (un contacto, una lista, un proyecto). Define: `id`, `displayRepresentation` (nombre e icono), y un `EntityQuery` para buscar entidades. Los AppIntents usan AppEntities como parametros, permitiendo que Siri diga "Agrega tarea a **Lista de Compras**".

---

### Tarjeta 3
**Pregunta:** Como funciona WidgetKit y cuales son sus componentes principales?
**Respuesta:** WidgetKit muestra contenido de tu app en el Home Screen. Componentes: 1) **Widget** (struct con `WidgetConfiguration`): define metadata y tipo. 2) **TimelineProvider**: genera snapshots y timelines con entradas futuras. 3) **Entry** (struct con `date`): datos para un momento. 4) **EntryView**: la vista SwiftUI del widget. Los widgets son **estaticos**: no soportan interacciones complejas, pero si `AppIntent` para botones.

---

### Tarjeta 4
**Pregunta:** Que es un `TimelineProvider` y como funciona su ciclo de vida?
**Respuesta:** `TimelineProvider` genera el contenido del widget. Metodos: 1) `placeholder()`: vista de esqueleto con datos ficticios. 2) `snapshot()`: entrada rapida para la galeria de widgets. 3) `timeline()`: array de entradas con fechas futuras + politica de recarga (`.atEnd`, `.after(date)`, `.never`). WidgetKit llama a `timeline()` periodicamente para obtener contenido actualizado.

---

### Tarjeta 5
**Pregunta:** Que es ActivityKit y para que sirven las Live Activities?
**Respuesta:** ActivityKit permite mostrar **Live Activities** en la pantalla de bloqueo y la Dynamic Island. Muestran informacion en tiempo real de eventos en curso: delivery, deportes, timers. Se crean con `Activity.request(attributes:content:)`, se actualizan con `activity.update(content:)` y se finalizan con `activity.end()`. Los datos se envian via push tokens o actualizaciones locales.

---

### Tarjeta 6
**Pregunta:** Como se estructura una Live Activity con sus vistas?
**Respuesta:** Se necesitan: 1) **ActivityAttributes**: struct con datos estaticos (nombre del restaurante) y un `ContentState` con datos dinamicos (estado del pedido). 2) **Vistas**: `LockScreenLiveActivityView` para pantalla de bloqueo, y vistas para Dynamic Island en formato `compactLeading`, `compactTrailing`, `minimal` y `expanded`.

---

### Tarjeta 7
**Pregunta:** Como se configuran notificaciones locales con `UNUserNotificationCenter`?
**Respuesta:** 1) Solicitar permiso: `UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])`. 2) Crear contenido: `UNMutableNotificationContent()` con titulo, body, sound. 3) Crear trigger: `UNTimeIntervalNotificationTrigger`, `UNCalendarNotificationTrigger`, o `UNLocationNotificationTrigger`. 4) Crear request con id unico. 5) Agregar con `center.add(request)`.

---

### Tarjeta 8
**Pregunta:** Que son las notificaciones push y que se necesita para implementarlas?
**Respuesta:** Las notificaciones push se envian desde un servidor remoto al dispositivo. Requisitos: 1) Certificado APNs (Apple Push Notification service) o clave p8. 2) Registrar para push con `UIApplication.shared.registerForRemoteNotifications()`. 3) Obtener el device token en `didRegisterForRemoteNotificationsWithDeviceToken`. 4) Enviar el token a tu servidor. 5) El servidor envia JSON a APNs.

---

### Tarjeta 9
**Pregunta:** Como se integra Siri con App Intents y que es un App Shortcut?
**Respuesta:** Al definir un `AppIntent`, Siri puede ejecutarlo por voz. Un **App Shortcut** (`AppShortcutsProvider`) pre-registra frases de Siri sin que el usuario configure nada. Define `appShortcuts` con frases como "Abre mi lista en \(.applicationName)". Los shortcuts aparecen automaticamente en Spotlight y la app de Shortcuts.

---

### Tarjeta 10
**Pregunta:** Cuales son los tamanos de widgets disponibles y en que plataformas?
**Respuesta:** 1) **systemSmall**: cuadrado pequeno (todas las plataformas). 2) **systemMedium**: rectangular horizontal (iPhone, iPad). 3) **systemLarge**: cuadrado grande (iPhone, iPad). 4) **systemExtraLarge**: solo iPad. 5) **accessoryCircular/Rectangular/Inline**: para pantalla de bloqueo y complicaciones de watchOS. Se especifican con `supportedFamilies` en la configuracion del widget.
