# Leccion 45: Agentic Coding

**Modulo 14: Agentic Coding y MCP** | Bonus

---

## TL;DR — Resumen en 2 minutos

- **Agentic Coding**: ya no escribes cada linea — diriges agentes de IA que implementan por ti
- **Claude Code**: agente de terminal que lee tu proyecto, escribe codigo, ejecuta tests y hace commits
- **Coding Intelligence en Xcode 26**: Apple integra IA directamente en el IDE
- **CLAUDE.md**: el archivo que convierte a Claude Code en tu copiloto personalizado
- **El developer no desaparece**: cambia de rol — de escribir codigo a dirigir, revisar y tomar decisiones

---

## Cupertino MCP

```bash
cupertino search --source updates "Xcode 26 Coding Intelligence"
cupertino search "machine learning developer tools"
```

---

## Teoria

### El Cambio de Paradigma

Antes de hablar del *como*, necesitamos entender el *por que*.

La historia de las herramientas de desarrollo sigue un patron claro: cada generacion elimina trabajo manual para que el developer se enfoque en decisiones de mayor valor. Pasamos de ensamblador a lenguajes de alto nivel, de makefiles manuales a IDEs con build systems, de documentacion en papel a autocompletado inteligente. Cada salto no elimino al programador — lo elevo.

El agentic coding es el siguiente salto.

```
  ┌──────────────────────────────────────────────────────────┐
  │            EVOLUCION DE LAS HERRAMIENTAS DE IA           │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │  2023  Autocompletado                                    │
  │        GitHub Copilot, Xcode Predictive Code Completion  │
  │        → Sugiere la siguiente linea                      │
  │                                                          │
  │  2024  Chat con contexto                                 │
  │        Cursor, Claude, ChatGPT                           │
  │        → Conversas sobre tu codigo, genera fragmentos    │
  │                                                          │
  │  2025  Agentes autonomos                                 │
  │        Claude Code, Codex CLI, OpenCode                  │
  │        → Lee tu proyecto, planifica, ejecuta, verifica   │
  │                                                          │
  │  2026  IA integrada en el IDE                            │
  │        Xcode 26 Coding Intelligence                      │
  │        → Agente nativo dentro del flujo de desarrollo    │
  │                                                          │
  └──────────────────────────────────────────────────────────┘
```

La diferencia fundamental: un autocompletado predice la siguiente linea. Un agente **entiende tu proyecto completo**, planifica una solucion de multiples archivos, la implementa, ejecuta tests y te muestra los resultados.

> **Pregunta Socratica**: Si tienes un bug en una app con 50 archivos, ¿que es mas util — que una IA complete la linea donde esta tu cursor, o que una IA lea los 50 archivos, identifique el bug y te proponga el fix? Esa es la diferencia entre autocompletado y un agente.

### ¿Que es un Agente de Codigo?

Un agente de codigo es software que puede **leer contexto, planificar, ejecutar acciones y verificar resultados** de forma autonoma. La palabra clave es *autonoma* — no solo responde preguntas, sino que toma acciones.

La diferencia entre un chatbot y un agente:

| Aspecto | Chatbot | Agente |
|---------|---------|--------|
| **Entrada** | Tu pregunta | Tu proyecto completo |
| **Salida** | Texto | Codigo escrito en archivos reales |
| **Herramientas** | Ninguna | Lee archivos, ejecuta comandos, busca en la web |
| **Verificacion** | Tu copias y pegas | El agente ejecuta tests y compila |
| **Memoria** | Solo la conversacion | CLAUDE.md + git history + archivos del proyecto |
| **Autonomia** | Responde lo que le preguntas | Planifica y ejecuta pasos sin que se lo pidas |

El **bucle del agente** es el concepto central:

```
  ┌──────────────────────────────────────────────────────┐
  │              EL BUCLE DEL AGENTE                     │
  │                                                      │
  │     ┌──────────┐                                     │
  │     │  LEER    │  Lee archivos, git history,         │
  │     │ CONTEXTO │  CLAUDE.md, errores previos         │
  │     └────┬─────┘                                     │
  │          ▼                                           │
  │     ┌──────────┐                                     │
  │     │ PLANIFICAR│  Decide que archivos crear/editar, │
  │     │          │  en que orden, que comandos correr   │
  │     └────┬─────┘                                     │
  │          ▼                                           │
  │     ┌──────────┐                                     │
  │     │ EJECUTAR │  Escribe codigo, edita archivos,    │
  │     │          │  corre comandos bash                 │
  │     └────┬─────┘                                     │
  │          ▼                                           │
  │     ┌──────────┐                                     │
  │     │ VERIFICAR│  Compila, ejecuta tests,            │
  │     │          │  revisa errores                      │
  │     └────┬─────┘                                     │
  │          │                                           │
  │          ▼                                           │
  │     ¿Funciona? ─── Si ──→ Presenta resultado         │
  │          │                                           │
  │          No                                          │
  │          │                                           │
  │          └──────→ Vuelve a LEER CONTEXTO             │
  │                   (ahora con info del error)          │
  └──────────────────────────────────────────────────────┘
```

Este bucle es lo que distingue a un agente: cuando algo falla, no se detiene — analiza el error, ajusta su plan y vuelve a intentar. Exactamente como haria un developer experimentado.

> **Pregunta Socratica**: ¿Que pasaria si le pides a un chatbot "agrega SwiftData a mi proyecto"? Te daria codigo generico. ¿Y un agente? Leeria tu proyecto, veria tus modelos actuales, crearia los schemas de SwiftData compatibles, actualizaria tu App principal con el ModelContainer, migraria los datos y correria los tests. ¿Ves la diferencia en utilidad?

---

### Claude Code — Tu Agente en Terminal

Claude Code es el agente de Anthropic que corre en la terminal. No es un plugin de IDE — es una herramienta de linea de comandos que tiene acceso completo a tu proyecto.

#### ¿Como funciona?

```bash
# Instalacion
npm install -g @anthropic-ai/claude-code

# Iniciar en tu proyecto
cd ~/Developer/MiApp
claude

# Ya puedes hablar con el agente
> "Agrega una pantalla de settings con SwiftUI usando NavigationStack"
```

Al iniciar, Claude Code:
1. **Lee tu proyecto**: archivos, estructura de carpetas, git history
2. **Lee CLAUDE.md**: tus instrucciones personalizadas (idioma, estilo, reglas)
3. **Entiende el contexto**: que frameworks usas, como esta organizado tu codigo
4. **Espera tu instruccion**: y luego planifica, ejecuta y verifica

#### Capacidades principales

```
  ┌──────────────────────────────────────────────────────┐
  │          HERRAMIENTAS DE CLAUDE CODE                 │
  ├──────────────────────────────────────────────────────┤
  │                                                      │
  │  📄 Read      → Lee cualquier archivo del proyecto   │
  │  ✏️  Edit      → Edita archivos existentes (diffs)   │
  │  📝 Write     → Crea archivos nuevos                 │
  │  🔍 Grep      → Busca patrones en el codigo          │
  │  📂 Glob      → Encuentra archivos por nombre        │
  │  💻 Bash      → Ejecuta comandos de terminal         │
  │  🌐 WebFetch  → Lee paginas web y documentacion      │
  │  🔧 MCP       → Conecta con servidores externos      │
  │                                                      │
  │  Combinadas, estas herramientas permiten:            │
  │  • Crear features completas multi-archivo            │
  │  • Ejecutar tests y corregir fallos                  │
  │  • Hacer commits con mensajes descriptivos           │
  │  • Refactorizar codigo existente                     │
  │  • Buscar documentacion en la web                    │
  └──────────────────────────────────────────────────────┘
```

#### CLAUDE.md — El Archivo Mas Importante

CLAUDE.md es el archivo que convierte a Claude Code de un agente generico en **tu copiloto personalizado**. Es como un onboarding document para un developer nuevo en tu equipo.

```markdown
# CLAUDE.md — MiApp

## Contexto
- App de recetas para iOS 26
- Arquitectura MVVM con SwiftData
- Target: iPhone y iPad

## Reglas
- Codigo en espanol para nombres de dominio
- async/await obligatorio, nunca DispatchQueue
- @Observable en lugar de ObservableObject
- Swift Testing para tests nuevos
- Siempre usar NavigationStack, nunca NavigationView

## Estilo
- MARK comments para secciones
- Nombres descriptivos (no abreviar)
- Un ViewModel por View principal

## Estructura
MiApp/
├── Models/          # SwiftData models
├── ViewModels/      # @Observable view models
├── Views/           # SwiftUI views
├── Services/        # Network, storage
└── Resources/       # Assets, strings
```

Sin CLAUDE.md, el agente genera codigo generico. Con CLAUDE.md, genera codigo que **se integra naturalmente** en tu proyecto.

#### Ejemplo real: Este repositorio

Este repositorio — SwiftLearning — fue construido con Claude Code. El CLAUDE.md que estas leyendo configura a Claude como "Profesor Apple" con:
- Metodologia pedagogica (WHY antes del HOW)
- Estructura de modulos y lecciones
- Comandos de Cupertino MCP para documentacion
- Guia de estilo de codigo
- Flujo de trabajo por leccion

El agente no solo escribio el contenido — organizo archivos, mantuvo consistencia entre lecciones, actualizo el progreso y siguio las convenciones establecidas.

---

### Coding Intelligence en Xcode 26

Apple introdujo en Xcode 26 su propia inteligencia artificial integrada directamente en el IDE. No es un plugin de terceros — es una capacidad nativa.

#### Capacidades principales

| Feature | Descripcion |
|---------|-------------|
| **Code Completion** | Sugerencias contextuales multi-linea basadas en tu proyecto |
| **Code Explanation** | Seleccionas codigo y Xcode te explica que hace |
| **Refactoring** | Sugerencias inteligentes para mejorar tu codigo |
| **Error Fixing** | Propuestas de fix para errores de compilacion |
| **Code Generation** | Genera implementaciones a partir de comentarios o protocolos |
| **Chat integrado** | Conversacion sobre tu codigo sin salir del IDE |

#### Privacidad: Todo on-device

La diferencia clave de la solucion de Apple: **todo corre en tu Mac**. Los modelos corren en Apple Silicon sin enviar codigo a servidores externos. Esto es critico para:
- Proyectos con codigo propietario
- Empresas con politicas de seguridad estrictas
- Developers que valoran la privacidad

#### Claude Code + Xcode: Complementarios, no competidores

```
  ┌──────────────────────────────────────────────────────┐
  │       CUANDO USAR CADA HERRAMIENTA                  │
  ├──────────────────────────────────────────────────────┤
  │                                                      │
  │  XCODE CODING INTELLIGENCE                          │
  │  ✓ Autocompletado mientras escribes                  │
  │  ✓ Fix rapido de errores de compilacion              │
  │  ✓ Refactoring puntual de una funcion                │
  │  ✓ Explicar codigo que no entiendes                  │
  │  ✓ Tareas dentro de un solo archivo                  │
  │                                                      │
  │  CLAUDE CODE                                         │
  │  ✓ Features nuevas que tocan multiples archivos      │
  │  ✓ Refactoring de arquitectura (mover a MVVM)        │
  │  ✓ Crear un modulo completo desde cero               │
  │  ✓ Escribir tests para todo un feature               │
  │  ✓ Tareas que requieren ejecutar comandos            │
  │  ✓ Integracion con MCP y herramientas externas       │
  │                                                      │
  └──────────────────────────────────────────────────────┘
```

El flujo ideal: usas Xcode Coding Intelligence para el dia a dia (completar funciones, arreglar errores rapidos) y Claude Code para tareas complejas (crear features completas, refactorizar arquitectura, generar tests).

---

### Otros Agentes del Ecosistema

Claude Code no es la unica opcion. Conocer el ecosistema te ayuda a elegir la herramienta correcta:

| Agente | Creador | Fortaleza | Limitacion |
|--------|---------|-----------|------------|
| **Claude Code** | Anthropic | CLAUDE.md, MCP, ejecucion autonoma | Requiere API key |
| **Codex CLI** | OpenAI | Integracion con ChatGPT | Ecosistema mas cerrado |
| **OpenCode** | Open Source | Gratuito, personalizable | Menor capacidad de razonamiento |
| **Cursor** | Cursor Inc. | IDE completo con IA | No es solo terminal, menos flexible |
| **Windsurf** | Codeium | Buena UX | Menor comunidad |

**¿Por que Claude Code en este curriculum?** Tres razones:
1. **CLAUDE.md** permite configuracion profunda del comportamiento del agente
2. **MCP (Model Context Protocol)** conecta con fuentes externas como Cupertino
3. **Ejecucion autonoma real**: lee, escribe, ejecuta y verifica sin intervencion

---

### Flujo de Trabajo Profesional

Un dia tipico de un developer que usa agentic coding:

#### Manana: Preparacion

```bash
# Revisar estado del proyecto
cd ~/Developer/MiApp
git status
git log --oneline -5

# Actualizar CLAUDE.md si hay nuevas convenciones
# Abrir Claude Code
claude
```

#### Desarrollo: Tareas complejas con Claude Code

```
> "Crea un nuevo feature de favoritos: modelo SwiftData Favorito,
   ViewModel con @Observable, vista con lista y swipe actions.
   Sigue la arquitectura MVVM del proyecto."
```

El agente:
1. Lee la estructura actual del proyecto
2. Revisa modelos existentes para mantener consistencia
3. Crea `Favorito.swift` en Models/
4. Crea `FavoritosViewModel.swift` en ViewModels/
5. Crea `FavoritosView.swift` en Views/
6. Actualiza la navegacion principal
7. Crea tests basicos

#### Desarrollo: Tareas rapidas con Xcode

Mientras tanto, en Xcode usas Coding Intelligence para:
- Completar funciones que estas escribiendo manualmente
- Arreglar warnings del compilador
- Entender codigo legacy que necesitas modificar

#### Review: Siempre revisar

```bash
# Ver que hizo el agente
git diff

# Revisar archivo por archivo
# ¿El codigo sigue tus convenciones?
# ¿La logica es correcta?
# ¿Los tests cubren los casos importantes?
```

**Regla de oro**: nunca hagas commit del output de un agente sin revisarlo. Tu eres el responsable del codigo que entra al repositorio.

#### Testing: El agente ejecuta, tu verificas

```
> "Corre todos los tests del modulo de favoritos y arregla
   cualquier fallo."
```

El agente ejecuta `swift test`, lee los errores, los corrige y vuelve a ejecutar hasta que todos pasen.

---

### Errores Comunes

#### 1. Aceptar todo sin revisar

El error mas peligroso. Los agentes generan codigo que **parece** correcto pero puede tener bugs sutiles, problemas de rendimiento o desviaciones de tu arquitectura.

```
❌  MAL: "Crea el feature" → acepto todo → commit → push
✅  BIEN: "Crea el feature" → reviso cada archivo → ajusto → commit
```

#### 2. CLAUDE.md vacio o generico

Sin instrucciones claras, el agente improvisa. Y cuando improvisa, genera codigo generico que no encaja en tu proyecto.

```
❌  MAL: CLAUDE.md con solo "Este es un proyecto iOS"
✅  BIEN: CLAUDE.md con arquitectura, convenciones, reglas, estructura
```

#### 3. Pedir demasiado en un solo prompt

Los agentes trabajan mejor con tareas enfocadas. Un prompt de 500 palabras pidiendo 10 cosas diferentes genera resultados mediocres.

```
❌  MAL: "Refactoriza toda la app a MVVM, agrega SwiftData,
        implementa networking, crea tests y publica en TestFlight"

✅  BIEN: "Refactoriza el modulo de usuarios a MVVM.
        El modelo Usuario ya existe, crea el ViewModel
        y actualiza la vista."
```

#### 4. No versionar antes de dejar trabajar al agente

Si el agente genera algo que rompe tu proyecto y no tienes un commit previo, perdiste trabajo.

```bash
# SIEMPRE antes de una tarea grande con el agente:
git add -A && git commit -m "checkpoint antes de refactoring"
```

#### 5. Pensar que el agente reemplaza el conocimiento tecnico

El agente es tan util como la persona que lo dirige. Si no sabes Swift, no puedes evaluar si el codigo generado es correcto. Si no entiendes concurrencia, no detectaras race conditions en el output.

**El agentic coding amplifica tu expertise — no la reemplaza.**

---

## Ejercicios

### Ejercicio 1 — Basico: Configura tu CLAUDE.md

**Objetivo**: Crear un CLAUDE.md completo para un proyecto personal.

Elige un proyecto real o imaginario y crea un CLAUDE.md que incluya:

```markdown
# CLAUDE.md — [Nombre de tu App]

## Contexto del Proyecto
# Describe la app: que hace, para quien, que plataformas

## Stack Tecnologico
# iOS version, Swift version, frameworks principales

## Arquitectura
# Patron (MVVM, MV, etc.), estructura de carpetas

## Reglas de Codigo
# Convenciones, prohibiciones, preferencias
# Ejemplo: "Nunca usar DispatchQueue, siempre async/await"
# Ejemplo: "Tests con Swift Testing, no XCTest para tests nuevos"

## Estilo
# Nombres, comentarios, organizacion de archivos

## Comandos Utiles
# Como compilar, como correr tests, como generar builds
```

**Criterios de evaluacion**:
- ¿Un developer nuevo (o un agente) podria entender tu proyecto solo con este archivo?
- ¿Las reglas son especificas y no ambiguas?
- ¿La estructura de carpetas esta documentada?

---

### Ejercicio 2 — Intermedio: Crea un Swift Package con Claude Code

**Objetivo**: Usar Claude Code para generar un Swift Package completo a partir de una especificacion en texto.

Escribe esta especificacion y pidesela a Claude Code:

```
Crea un Swift Package llamado "Validador" que:

1. Tenga un protocolo ValidacionRegla con un metodo
   func validar(_ valor: String) -> ResultadoValidacion

2. ResultadoValidacion sea un enum con casos .valido y
   .invalido(mensaje: String)

3. Incluya estas reglas predefinidas:
   - EmailRegla: valida formato de email
   - LongitudMinimaRegla: valida longitud minima configurable
   - ContieneNumeroRegla: valida que contenga al menos un numero

4. Tenga un struct Validador que reciba un array de reglas
   y las aplique todas, devolviendo todos los errores

5. Incluya tests con Swift Testing para cada regla
   y para el validador combinado

6. Use el Package.swift correcto para Swift 6.2
```

**Pasos**:
1. Inicia Claude Code en un directorio vacio
2. Pega la especificacion
3. Deja que el agente cree todo el package
4. Revisa el codigo generado: ¿sigue buenas practicas?
5. Ejecuta los tests: `swift test`
6. Si algo falla, pide al agente que lo corrija

**Criterios de evaluacion**:
- ¿El package compila sin errores?
- ¿Los tests pasan?
- ¿El codigo es idiomatico Swift? (protocols, value types, generics)
- ¿Usaste solo un prompt o necesitaste varios?

---

### Ejercicio 3 — Avanzado: Claude Code vs Xcode Coding Intelligence

**Objetivo**: Comparar la salida de ambas herramientas para la misma tarea de refactoring.

**Preparacion**: Toma un ViewController o View de un proyecto existente que tenga al menos 100 lineas y que mezcle logica de negocio con UI.

**Tarea para ambas herramientas**: "Refactoriza esta vista para separar la logica de negocio en un ViewModel con @Observable. El ViewModel debe ser testeable de forma independiente."

**Con Xcode Coding Intelligence**:
1. Selecciona el codigo en Xcode
2. Usa la funcion de refactoring de Coding Intelligence
3. Guarda el resultado

**Con Claude Code**:
1. Abre Claude Code en el directorio del proyecto
2. Dale el mismo prompt
3. Guarda el resultado

**Compara**:

| Criterio | Xcode CI | Claude Code |
|----------|----------|-------------|
| ¿Cuantos archivos modifico/creo? | | |
| ¿Detecto todas las dependencias? | | |
| ¿Creo tests para el ViewModel? | | |
| ¿Mantuvo la funcionalidad original? | | |
| ¿El codigo compila sin errores? | | |
| ¿Siguio las convenciones del proyecto? | | |
| ¿Cuanto tiempo tardo? | | |

**Reflexion**: ¿Cual herramienta fue mejor para esta tarea? ¿En que escenarios usarias cada una? Escribe tus conclusiones.

---

## Checklist

- [ ] Entender la diferencia entre autocompletado, chat con IA y agentes autonomos
- [ ] Explicar el bucle del agente: Leer → Planificar → Ejecutar → Verificar
- [ ] Instalar y configurar Claude Code en un proyecto
- [ ] Crear un CLAUDE.md completo con reglas, estilo y estructura
- [ ] Usar Claude Code para crear codigo multi-archivo
- [ ] Conocer las capacidades de Xcode 26 Coding Intelligence
- [ ] Saber cuando usar Claude Code vs Xcode Coding Intelligence
- [ ] Revisar siempre el output del agente antes de hacer commit
- [ ] Versionar con git antes de tareas grandes con el agente
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

*Leccion 45 (L45) | Agentic Coding | Modulo 14*
