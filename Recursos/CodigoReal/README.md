# Analisis de Codigo Real — Samples de Apple

Aprender leyendo codigo profesional es una de las mejores formas de crecer como desarrollador. Aqui recopilamos samples oficiales de Apple y proyectos open source para analizar.

---

## Como usar esta seccion

1. Pide al profesor: *"Codigo real de [tema]"*
2. Claude buscara en Cupertino MCP: `cupertino list-samples` y `cupertino read-sample "nombre"`
3. Analizareis juntos el codigo: estructura, patrones, decisiones de diseno
4. El profesor te hara preguntas sobre el codigo (metodo socratico)

---

## Samples Oficiales de Apple por Modulo

### Modulo 00: Fundamentos
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| Swift Playgrounds Learn to Code | Swift basico | `cupertino search --source samples "learn to code"` |

### Modulo 01: Arquitectura
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| Fruta: Building a Feature-Rich App with SwiftUI | MVVM + SwiftData | `cupertino search --source samples "Fruta"` |
| Food Truck: Building a SwiftUI Multiplatform App | Arquitectura | `cupertino search --source samples "Food Truck"` |

### Modulo 03: SwiftUI
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| Landmarks | SwiftUI navigation + lists | `cupertino search --source samples "Landmarks"` |
| Scrumdinger | SwiftUI app completa | `cupertino search --source samples "Scrumdinger"` |

### Modulo 04: Datos
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| SwiftData sample | Persistencia | `cupertino search --source samples "SwiftData"` |
| CloudKit Sharing | CloudKit | `cupertino search --source samples "CloudKit"` |

### Modulo 05: Hardware
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| SpeedySloth | HealthKit workouts | `cupertino search --source samples "SpeedySloth"` |
| MapKit for SwiftUI | Mapas | `cupertino search --source samples "MapKit"` |

### Modulo 06: IA
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| Foundation Models sample | IA on-device | `cupertino search --source samples "Foundation Models"` |
| Classifying Images | Vision + CoreML | `cupertino search --source samples "classifying images"` |

### Modulo 07: Sistema
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| App Intents sample | Intents + Siri | `cupertino search --source samples "App Intents"` |
| Emoji Rangers | Widgets | `cupertino search --source samples "Emoji Rangers"` |

### Modulo 08: Plataformas
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| Hello World visionOS | visionOS basico | `cupertino search --source samples "Hello World visionOS"` |
| Backyard Birds | Multiplataforma | `cupertino search --source samples "Backyard Birds"` |

### Modulo 09: Testing
| Sample | Tema | Comando Cupertino |
|--------|------|-------------------|
| Swift Testing sample | Testing moderno | `cupertino search --source samples "Swift Testing"` |

---

## Proyectos Open Source Recomendados

| Proyecto | Autor | Por que analizarlo | Link |
|----------|-------|-------------------|------|
| Ice Cubes (Mastodon client) | @dimillian | SwiftUI + SwiftData + Networking | github.com/Dimillian/IceCubesApp |
| NetNewsWire (RSS reader) | @brentsimmons | Arquitectura limpia, multiplataforma | github.com/Ranchero-Software/NetNewsWire |
| Wikipedia iOS | Wikimedia | App a gran escala, accesibilidad | github.com/wikimedia/wikipedia-ios |
| Signal iOS | Signal Foundation | Seguridad, criptografia | github.com/nicklama/Signal-iOS |
| Telegram iOS | Telegram | Performance, networking | github.com/nicklama/Telegram-iOS |

---

## Ejercicios de Lectura de Codigo

Para cada sample, el profesor puede proponer:

1. **Encuentra el patron**: "¿Que patron arquitectonico usa esta app? ¿Donde esta el ViewModel?"
2. **Sigue el flujo**: "¿Que pasa cuando el usuario pulsa este boton? Sigue el codigo desde la View hasta el Model"
3. **Identifica el error**: "Este codigo tiene un retain cycle. ¿Donde esta?"
4. **Refactoriza**: "¿Como mejorarias esta funcion? ¿Que patron aplicarias?"
5. **Compara**: "Este sample usa Combine. ¿Como lo reescribirias con async/await?"

---

*Los samples se consultan en tiempo real via Cupertino MCP — siempre tendras la version mas actualizada.*
