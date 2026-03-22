# Flashcards — Modulo 06: IA y Machine Learning

---

### Tarjeta 1
**Pregunta:** Que son los Foundation Models de Apple y en que se diferencian de APIs cloud como OpenAI?
**Respuesta:** Los Foundation Models son modelos de lenguaje que corren **localmente** en el dispositivo Apple (a partir de iOS 26). Diferencias clave: 1) **Privacidad**: los datos nunca salen del dispositivo. 2) **Sin costo** por uso. 3) **Sin conexion** a internet necesaria. 4) Optimizados para tareas practicas (resumir, extraer, generar) en lugar de conversaciones generales.

---

### Tarjeta 2
**Pregunta:** Que es `LanguageModelSession` y como se usa?
**Respuesta:** `LanguageModelSession` es la API para interactuar con los Foundation Models. Se crea una sesion, se envia un prompt y se recibe la respuesta: `let session = LanguageModelSession()`, `let respuesta = try await session.respond(to: "mi prompt")`. Soporta streaming con `respondStreaming(to:)` que devuelve un `AsyncSequence` de tokens parciales.

---

### Tarjeta 3
**Pregunta:** Que es la macro `@Generable` y para que sirve?
**Respuesta:** `@Generable` permite que el modelo de lenguaje genere instancias de un tipo Swift directamente. Se aplica a structs con propiedades simples: `@Generable struct Receta { var nombre: String; var ingredientes: [String] }`. Al pedir al modelo que genere una Receta, el resultado se devuelve como un objeto Swift tipado, no como texto sin estructura.

---

### Tarjeta 4
**Pregunta:** Que es ImagePlayground y como se integra en una app?
**Respuesta:** ImagePlayground es la API de generacion de imagenes con IA de Apple. Se presenta como una sheet del sistema con `ImagePlaygroundSheet(isPresented:concepts:onCompletion:)`. El usuario puede ajustar el estilo y contenido. Los conceptos iniciales se pasan como `ImagePlaygroundConcept` (texto o imagen de referencia). La imagen generada se devuelve como `URL` al archivo local.

---

### Tarjeta 5
**Pregunta:** Que es CoreML y cual es su flujo de trabajo basico?
**Respuesta:** CoreML es el framework para ejecutar modelos de machine learning en dispositivos Apple. Flujo: 1) Entrenar o convertir un modelo a formato `.mlmodel` (con Create ML o coremltools). 2) Agregar el modelo al proyecto Xcode. 3) Xcode genera una clase Swift automaticamente. 4) Crear instancia del modelo y llamar `prediction(input:)`. Todo corre en el dispositivo, optimizado para Neural Engine, GPU o CPU.

---

### Tarjeta 6
**Pregunta:** Que es el framework Vision y que tareas puede realizar?
**Respuesta:** Vision es el framework de Apple para analisis de imagenes con ML. Tareas: 1) **Deteccion de texto** (OCR) con `RecognizeTextRequest`. 2) **Deteccion de rostros** con `DetectFaceRectanglesRequest`. 3) **Clasificacion de imagenes** con `ClassifyImageRequest`. 4) **Deteccion de objetos**. 5) **Deteccion de poses corporales**. 6) **Seguimiento de objetos** en video. Todas las peticiones son asincronas.

---

### Tarjeta 7
**Pregunta:** Como se realiza OCR (reconocimiento de texto) con Vision en Swift moderno?
**Respuesta:** Se crea un `RecognizeTextRequest`, se configura el nivel de reconocimiento (`.accurate` o `.fast`), y se ejecuta con una imagen. En Swift concurrency: `let request = RecognizeTextRequest()`, `let observations = try await request.perform(on: cgImage)`. Cada observation contiene `topCandidates` con el texto reconocido y su nivel de confianza.

---

### Tarjeta 8
**Pregunta:** Que es Create ML y como se diferencia de CoreML?
**Respuesta:** **Create ML** es para **entrenar** modelos directamente en Mac, sin escribir codigo de ML. Tiene app grafica y framework programatico. Soporta: clasificacion de imagenes/texto/sonido, deteccion de objetos, recomendaciones. **CoreML** es para **ejecutar** modelos ya entrenados en dispositivos. Create ML genera modelos `.mlmodel` que CoreML consume.

---

### Tarjeta 9
**Pregunta:** Que son los `ImagePlaygroundConcept` y que tipos existen?
**Respuesta:** Son los conceptos que guian la generacion de imagenes en ImagePlayground. Tipos: 1) `.text("descripcion")` — concepto descrito con texto. 2) `.image(url:)` — imagen de referencia para estilo o contenido. Se pueden combinar multiples conceptos para guiar al modelo. El usuario siempre tiene control final sobre la imagen generada en la interfaz del sistema.

---

### Tarjeta 10
**Pregunta:** Como se optimiza un modelo CoreML para diferentes chips Apple?
**Respuesta:** CoreML optimiza automaticamente eligiendo Neural Engine, GPU o CPU segun el dispositivo. Para control: 1) Especificar `MLComputeUnits` al cargar (`.all`, `.cpuAndNeuralEngine`, `.cpuOnly`). 2) Usar cuantizacion (reducir precision de Float32 a Int8) con coremltools para modelos mas rapidos y pequenos. 3) Usar `MLModelConfiguration` para ajustar el comportamiento.
