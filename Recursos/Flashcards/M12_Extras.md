# Flashcards — Modulo 12: Extras y Especializacion

---

### Tarjeta 1
**Pregunta:** Que es Vapor y por que es relevante para un desarrollador iOS?
**Respuesta:** Vapor es el framework mas popular de Server-Side Swift. Permite escribir backends en Swift, compartiendo modelos y logica con tu app iOS. Beneficios: 1) Un solo lenguaje para cliente y servidor. 2) Modelos `Codable` compartidos. 3) Type safety end-to-end. 4) Alto rendimiento (basado en SwiftNIO). Se usa para APIs REST, WebSockets, y microservicios.

---

### Tarjeta 2
**Pregunta:** Que es Fluent en el contexto de Vapor?
**Respuesta:** Fluent es el ORM (Object-Relational Mapping) de Vapor. Permite interactuar con bases de datos usando modelos Swift en lugar de SQL directo. Soporta: PostgreSQL, MySQL, SQLite, MongoDB. Define modelos con `@ID`, `@Field`, `@Parent`, `@Children`. Las migraciones se escriben en Swift. Es similar en concepto a SwiftData pero para el servidor.

---

### Tarjeta 3
**Pregunta:** Que es Metal y cuando deberia usarse en lugar de SwiftUI o SpriteKit?
**Respuesta:** Metal es la API de bajo nivel de Apple para GPU (graficos y computacion). Usarlo cuando: 1) Necesitas renderizado 3D personalizado de alto rendimiento. 2) Procesamiento paralelo masivo (ML custom, simulaciones). 3) Efectos graficos avanzados (shaders custom). 4) Juegos AAA. **No usarlo** para UI standard (SwiftUI), juegos 2D simples (SpriteKit) o 3D basico (SceneKit/RealityKit).

---

### Tarjeta 4
**Pregunta:** Que es SpriteKit y para que tipo de apps es ideal?
**Respuesta:** SpriteKit es el framework 2D de Apple para juegos y animaciones. Ideal para: juegos casuales 2D, efectos de particulas, simulaciones fisicas simples. Componentes: `SKScene` (escena), `SKSpriteNode` (sprites), `SKAction` (animaciones), `SKPhysicsBody` (fisica). Se integra con SwiftUI usando `SpriteView`. Es de alto nivel: Apple maneja el render loop y la GPU.

---

### Tarjeta 5
**Pregunta:** Que es Combine y por que se estudia aunque se prefiera async/await?
**Respuesta:** Combine es el framework reactivo de Apple basado en publishers y subscribers. Se estudia porque: 1) Mucho codigo existente lo usa. 2) Algunas APIs de Apple aun lo requieren (ej: `NotificationCenter.publisher`). 3) Es util para transformar y combinar streams de datos. Sin embargo, para nuevo codigo, `async/await` y `AsyncSequence` son preferidos por ser mas simples y seguros.

---

### Tarjeta 6
**Pregunta:** Cuales son los publishers mas comunes de Combine?
**Respuesta:** 1) `Just(valor)` — emite un valor y completa. 2) `CurrentValueSubject` — tiene valor actual, emite cambios. 3) `PassthroughSubject` — emite valores sin almacenar. 4) `@Published` — property wrapper que crea un publisher. 5) `Timer.publish()` — emite en intervalos. 6) `NotificationCenter.publisher()` — observa notificaciones. 7) `URLSession.dataTaskPublisher()` — peticiones de red.

---

### Tarjeta 7
**Pregunta:** Que es Swift Evolution y como funciona el proceso de propuestas?
**Respuesta:** Swift Evolution es el proceso abierto para proponer cambios al lenguaje Swift. Etapas: 1) **Pitch**: idea informal en los foros. 2) **Proposal** (SE-NNNN): documento formal con motivacion, diseno y alternativas. 3) **Review**: la comunidad debate. 4) **Decision**: el Core Team acepta, rechaza o pide cambios. Cualquiera puede proponer. El codigo esta en github.com/swiftlang/swift.

---

### Tarjeta 8
**Pregunta:** Que es SwiftNIO y por que es importante para Server-Side Swift?
**Respuesta:** SwiftNIO es el framework de networking asincrono de bajo nivel de Apple (similar a Netty en Java). Proporciona: event loops, channels, buffers y handlers para protocolos de red. Es la base sobre la que se construye Vapor y otros frameworks de servidor. No se usa directamente en la mayoria de los casos, pero entenderlo ayuda a depurar performance del servidor.

---

### Tarjeta 9
**Pregunta:** Como se contribuye a un proyecto Open Source Swift?
**Respuesta:** 1) Encontrar el repositorio en github.com/swiftlang o github.com/apple. 2) Leer CONTRIBUTING.md. 3) Buscar issues etiquetados "good first issue" o "help wanted". 4) Fork, crear branch, implementar cambio. 5) Escribir tests. 6) Enviar Pull Request con descripcion clara. 7) Responder a code review. Para Swift mismo: firmar el CLA (Contributor License Agreement) y seguir el proceso de swift-evolution.

---

### Tarjeta 10
**Pregunta:** Cuales son los Swift packages mas importantes del ecosistema?
**Respuesta:** 1) **swift-algorithms**: algoritmos de colecciones (chunks, combinations). 2) **swift-collections**: OrderedDictionary, Deque, Heap. 3) **swift-argument-parser**: CLIs con parsing de argumentos. 4) **swift-format**: formateo automatico de codigo. 5) **swift-protobuf**: Protocol Buffers. 6) **swift-log**: logging estandarizado. 7) **swift-nio**: networking asincrono. Todos mantenidos por Apple o la comunidad core.
