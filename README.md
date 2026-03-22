# AppleDevMasterclass — Guia Maestra Apple Developer

> Creado por [@blanrra](https://github.com/blanrra) | [Web del proyecto](https://blanrra.github.io/AppleDevMasterclass/)

Tu **profesor IA personal** para aprender desarrollo Apple desde cero hasta nivel experto. Creado por Blanrra, powered by [Claude Code](https://claude.ai/claude-code) + [Cupertino MCP](https://github.com/nicklama/cupertino-mcp).

---

## Que es esto

AppleDevMasterclass es un curriculum de ~60 semanas que convierte a Claude Code en un **profesor particular de desarrollo Apple** que:

- Se **adapta a tu nivel** — desde tu primera linea de codigo hasta arquitecturas avanzadas
- Usa **documentacion oficial de Apple** en tiempo real via Cupertino MCP
- Te ensena con el **metodo socratico** — pregunta antes de avanzar
- Te guia con **ejercicios progresivos** y un **proyecto integrador**
- Cubre **todo el ecosistema**: iOS, iPadOS, watchOS, visionOS, macOS

### Que NO es

- No es un curso en video
- No es documentacion estatica
- Es una **experiencia interactiva 1-a-1** con una IA que enseña en espanol

---

## Requisitos

| Requisito | Detalle |
|-----------|---------|
| **macOS** | Ventura 13+ (recomendado: Tahoe 26) |
| **Xcode** | 16+ (recomendado: 26) |
| **Swift Playgrounds** | Para Nivel 1-2 (disponible en iPad y Mac) |
| **Claude Code** | CLI de Anthropic |
| **Cupertino MCP** | Servidor MCP para docs de Apple |
| **Node.js** | 18+ (para Cupertino MCP) |

> **Nivel 1-2**: Puedes empezar solo con **Swift Playgrounds** en iPad o Mac — no necesitas Xcode hasta el Modulo 00 Bloque C (semana 9).

---

## Instalacion paso a paso

### 1. Instalar Claude Code

```bash
# Con npm
npm install -g @anthropic-ai/claude-code

# O con Homebrew
brew install claude-code
```

Necesitas una cuenta de Anthropic con acceso a Claude. Mas info en [claude.ai/claude-code](https://claude.ai/claude-code).

### 2. Instalar Cupertino MCP

Cupertino MCP es el servidor que da acceso a la documentacion oficial de Apple. Es la **base de conocimiento** del profesor.

```bash
# Instalar globalmente
npm install -g cupertino-mcp
```

Mas info en [github.com/nicklama/cupertino-mcp](https://github.com/nicklama/cupertino-mcp).

### 3. Configurar Cupertino como MCP Server en Claude Code

Abre tu configuracion de Claude Code y anade Cupertino como servidor MCP:

```bash
# Abrir configuracion de Claude Code
claude config
```

Anade la configuracion del MCP server segun las instrucciones de Cupertino MCP.

### 4. Clonar este repositorio

```bash
git clone https://github.com/blanrra/AppleDevMasterclass.git
cd AppleDevMasterclass
```

### 5. Iniciar tu primera leccion

```bash
claude
```

Claude Code leera automaticamente el `CLAUDE.md` y se activara como **Profesor Apple**. Te preguntara tu nivel de experiencia y te guiara desde ahi.

---

## Como funciona

```
Tu (estudiante)
    |
    v
Claude Code (Profesor Apple)  <-- CLAUDE.md configura el comportamiento
    |
    v
Cupertino MCP  <-- Documentacion oficial de Apple en tiempo real
    |
    v
Lecciones adaptadas a tu nivel con codigo ejecutable
```

1. **Abres Claude Code** en esta carpeta
2. El `CLAUDE.md` activa el **modo Profesor Apple**
3. Claude **evalua tu nivel** con preguntas
4. Te **recomienda donde empezar** en el curriculum
5. Te ensena con **teoria + codigo + ejercicios**
6. **Consulta Cupertino MCP** para documentacion actualizada
7. Tu **progreso se guarda** en `PROGRESO.md`

---

## Niveles

El profesor se adapta a ti:

| Nivel | Para quien | Punto de entrada |
|-------|-----------|------------------|
| **Iniciacion** | Nunca has programado | Modulo 00, desde el principio |
| **Principiante Swift** | Programas en otro lenguaje | Modulo 00, lecciones intermedias |
| **Intermedio** | Conoces Swift y SwiftUI | Modulo 01+ |
| **Avanzado** | Dev iOS experimentado | Modulo 05+ |

---

## Estructura del Curriculum

| Modulo | Nombre | Temas |
|--------|--------|-------|
| 00 | **Fundamentos** | Swift desde cero, POP, Concurrencia, Xcode, SwiftUI basico |
| 01 | **Arquitectura** | MVVM, Clean Architecture, DI |
| 02 | **Diseno y UX** | HIG, Liquid Glass, SF Symbols, Accesibilidad |
| 03 | **SwiftUI Avanzado** | Navegacion, Composicion, Listas, Animaciones |
| 04 | **Datos y Persistencia** | SwiftData, CloudKit, Networking |
| 05 | **Hardware y Sensores** | HealthKit, Location/Maps, Camera/Photos |
| 06 | **IA y ML** | Foundation Models, ImagePlayground, CoreML/Vision |
| 07 | **Integracion Sistema** | App Intents, Siri, Widgets, Notificaciones |
| 08 | **Plataformas** | watchOS, visionOS, macOS, iPadOS |
| 09 | **Testing y Calidad** | XCTest, Swift Testing, UI Testing |
| 10 | **Seguridad y Performance** | CryptoKit, Privacy Manifests, Instruments |
| 11 | **Monetizacion** | StoreKit 2, App Store, TestFlight |
| 12 | **Extras** | Server-Side Swift, Metal, Combine, Open Source |
| 13 | **Entrevistas iOS** | (Bonus) Preguntas Junior→FAANG, mock interviews, system design |

Mas un **Proyecto Integrador** que construyes incrementalmente a lo largo del curriculum.

---

## Archivos clave

| Archivo | Que hace |
|---------|----------|
| `CLAUDE.md` | El cerebro del profesor — instrucciones para Claude |
| `PLAN_MAESTRO.md` | Curriculum completo con todas las lecciones |
| `PROGRESO.md` | Tu tracking personal de avance + logros |
| `GUIA_RAPIDA.md` | Referencia rapida de comandos y estado |
| `Retos/` | Katas diarias de 5 minutos como warm-up |
| `Showcase/` | Proyectos de alumnos que completaron el curriculum |
| `i18n/` | Traducciones del profesor a otros idiomas |
| `CONTRIBUTING.md` | Guia para contribuir + Study Buddy Mode |
| `Recursos/` | Cheatsheets y material complementario |

---

## Comandos utiles durante las lecciones

Una vez dentro de Claude Code, puedes pedirle al profesor cosas como:

- *"Empecemos con la leccion 1"*
- *"Explicame por que existen los optionals"*
- *"Dame un ejercicio mas dificil"*
- *"No entiendo este concepto, explicamelo de otra forma"*
- *"Explicame como si tuviera 5 anos"*
- *"Saltemos a SwiftUI, ya se lo basico de Swift"*
- *"Muestra mi progreso"*
- *"Dame el reto del dia"* — kata de 5 minutos
- *"Modo entrevista senior"* — simula entrevista tecnica iOS
- *"Flashcards"* — genera tarjetas de repaso
- *"Modo examen"* — examen del modulo actual
- *"Errores comunes"* — los 5 errores tipicos del tema
- *"Muestra mis logros"* — tu coleccion de badges

---

## Tecnologias que cubre

Solo tecnologias **modernas de Apple** — nada legacy:

| Usar | En lugar de |
|------|-------------|
| `async/await` | DispatchQueue, callbacks |
| `@Observable` | ObservableObject, Combine |
| `SwiftData` | Core Data |
| `Swift Testing` | Solo XCTest |
| `NavigationStack` | NavigationView |

---

## Contribuir

Este proyecto esta en desarrollo activo. Si quieres contribuir:

1. Fork el repositorio
2. Crea una rama para tu mejora
3. Abre un Pull Request

Ideas de contribucion:
- Nuevos ejercicios practicos
- Mejoras en explicaciones
- Traducciones
- Lecciones adicionales

---

## Licencia

MIT — usa, modifica y comparte libremente.

---

*Creado por [@blanrra](https://github.com/blanrra) con Claude Code*
