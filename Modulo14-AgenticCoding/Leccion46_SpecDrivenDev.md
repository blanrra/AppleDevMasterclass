# Leccion 46: Spec Driven Development

**Modulo 14: Agentic Coding y MCP** | Bonus

---

## TL;DR — Resumen en 2 minutos

- **Spec Driven Development (SDD)**: escribes la especificacion, el agente implementa el codigo
- **CLAUDE.md es tu spec principal**: define reglas, estilo, arquitectura y comportamiento del agente
- **Skills**: comandos reutilizables que el agente ejecuta (/commit, /test, /review)
- **Hooks**: automatizaciones que se disparan antes/despues de acciones del agente
- **El ciclo SDD**: Spec → Generate → Review → Refine → Accept

> Filosofia: Tu eres el arquitecto, el agente es el constructor. No colocas ladrillos — dibujas planos.

---

## Cupertino MCP

```bash
cupertino search "Swift Package Manager"
cupertino search "Xcode build settings"
cupertino search --source swift-book "concurrency"
cupertino search --source updates "Swift 6"
cupertino search "SwiftUI App protocol"
cupertino search "Swift Testing framework"
```

---

## Videos y Recursos

| Tipo | Recurso | Notas |
|------|---------|-------|
| Docs | [Claude Code Overview](https://docs.anthropic.com/en/docs/claude-code) | Documentacion oficial de Claude Code |
| Docs | [CLAUDE.md Best Practices](https://docs.anthropic.com/en/docs/claude-code/memory) | Como escribir specs efectivas |
| Docs | [Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) | Automatizaciones pre/post accion |
| Docs | [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills) | Comandos reutilizables |
| Blog | [Anthropic — Best Practices for Agentic Coding](https://www.anthropic.com/engineering) | Patrones probados en produccion |
| Video | [WWDC25 — What's New in Xcode](https://developer.apple.com/videos/play/wwdc2025/) | Integracion de herramientas AI en Xcode |

---

## Teoria

### La Evolucion del Desarrollo de Software

Antes de entender SDD, necesitas ver la progresion historica de como escribimos software. Cada paso resuelve un problema del anterior:

```
  ┌──────────────────────────────────────────────────────────┐
  │          EVOLUCION DE METODOLOGIAS                        │
  │                                                           │
  │  1. DESARROLLO TRADICIONAL                                │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  Tu → Escribes codigo → Pruebas manualmente        │ │
  │  │  Problema: bugs descubiertos tarde                  │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  2. TEST DRIVEN DEVELOPMENT (TDD)                         │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  Tu → Escribes test → Escribes codigo → Test pasa  │ │
  │  │  Problema: tu sigues escribiendo todo               │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  3. SPEC DRIVEN DEVELOPMENT (SDD)                         │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  Tu → Escribes spec → Agente escribe codigo Y tests│ │
  │  │  Tu revisas → Refinas spec → Agente regenera       │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                                                           │
  │  CAMBIO CLAVE:                                            │
  │  Tu rol pasa de IMPLEMENTADOR a ARQUITECTO/REVIEWER       │
  └──────────────────────────────────────────────────────────┘
```

### Por que existe SDD

La pregunta no es "como uso un agente para escribir codigo". La pregunta es: si un agente puede escribir codigo, cual es tu rol como desarrollador?

La respuesta es que tu rol se eleva. En lugar de pensar en sintaxis, piensas en arquitectura. En lugar de escribir for loops, defines contratos. En lugar de debuggear semicolons, revisas decisiones de diseno. SDD formaliza este cambio: la especificacion es el artefacto principal, no el codigo.

Piensa en la construccion de edificios. Un arquitecto no coloca ladrillos ni mezcla cemento. Dibuja planos detallados que dicen exactamente que debe construirse, con que materiales, siguiendo que normas. Si el plano es ambiguo, el constructor tomara decisiones que quizas no te gusten. Si el plano es preciso, el resultado sera exactamente lo que quieres.

Tu CLAUDE.md es ese plano. Tu prompt es la orden de trabajo. El agente es el constructor.

### Que es una Especificacion

Una especificacion no es un comentario vago diciendo "haz una app bonita". Es un documento preciso que define:

```swift
// MARK: - Anatomia de una buena especificacion

/*
 UNA SPEC TIENE 6 COMPONENTES:

 1. CONTEXTO
    Que es este proyecto? Para quien es? Que problema resuelve?
    "App de gestion de tareas para equipos remotos de 5-15 personas"

 2. RESTRICCIONES TECNICAS
    Que tecnologias usar y cuales evitar.
    "SwiftUI + SwiftData. No usar UIKit. No usar Combine. iOS 26+."

 3. ARQUITECTURA
    Como se organiza el codigo.
    "MVVM con Repository pattern. ViewModels son @Observable.
     Views no contienen logica de negocio."

 4. ESTILO DE CODIGO
    Convenciones que el agente debe seguir.
    "Nombres en ingles. MARK comments para secciones.
     Funciones de maximo 20 lineas. Sin force unwrap."

 5. COMPORTAMIENTO ESPERADO
    Que debe hacer exactamente la funcionalidad.
    "Al tocar 'Agregar', se crea una tarea con titulo, fecha
     y prioridad. Si el titulo esta vacio, mostrar alerta."

 6. LO QUE NO DEBE HACER (tan importante como lo anterior)
    "No usar singletons. No hacer networking en la View.
     No crear archivos de documentacion."
*/
```

---

### CLAUDE.md como Especificacion

CLAUDE.md es el archivo que Claude Code lee automaticamente al iniciar una sesion. Es tu contrato con el agente. Todo lo que escribas ahi se convierte en una regla que el agente seguira.

Veamos la estructura de un CLAUDE.md efectivo:

```
  ┌──────────────────────────────────────────────────────────┐
  │              ESTRUCTURA DE CLAUDE.md                       │
  │                                                           │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  1. DESCRIPCION DEL PROYECTO                        │ │
  │  │     Que es, para quien, que problema resuelve        │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  2. STACK TECNICO                                    │ │
  │  │     iOS 26, Swift 6.2, SwiftUI, SwiftData            │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  3. ARQUITECTURA                                     │ │
  │  │     MVVM, Repository, DI por protocolo               │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  4. REGLAS DE ESTILO                                 │ │
  │  │     Naming, organizacion, patrones                   │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  5. PROHIBICIONES                                    │ │
  │  │     Lo que el agente NUNCA debe hacer                │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  6. TESTING                                          │ │
  │  │     Swift Testing, cobertura minima, que testear     │ │
  │  └─────────────────────────────────────────────────────┘ │
  │                          ↓                                │
  │  ┌─────────────────────────────────────────────────────┐ │
  │  │  7. HERRAMIENTAS Y COMANDOS                          │ │
  │  │     Como ejecutar, compilar, testear                 │ │
  │  └─────────────────────────────────────────────────────┘ │
  └──────────────────────────────────────────────────────────┘
```

Veamos un ejemplo concreto de CLAUDE.md para un proyecto real:

```markdown
# CLAUDE.md — TaskFlow App

## Proyecto
App de gestion de tareas colaborativa para equipos remotos.
iOS 26+ unicamente. Sin soporte legacy.

## Stack
- Swift 6.2 con strict concurrency
- SwiftUI (no UIKit)
- SwiftData (no Core Data, no Realm)
- async/await (no Combine, no DispatchQueue)
- @Observable (no ObservableObject)

## Arquitectura
- MVVM con Repository pattern
- ViewModels: clases @Observable, reciben repositorios por init (DI)
- Views: solo presentacion, cero logica de negocio
- Models: structs con @Model para SwiftData
- Repositories: protocolos con implementacion concreta

## Estructura de carpetas
```
TaskFlow/
  Features/
    TaskList/
      TaskListView.swift
      TaskListViewModel.swift
    TaskDetail/
      TaskDetailView.swift
      TaskDetailViewModel.swift
  Models/
    Task.swift
    Project.swift
  Repositories/
    TaskRepository.swift
    ProjectRepository.swift
  App/
    TaskFlowApp.swift
```

## Reglas de codigo
- Nombres de tipos y funciones en ingles
- Comentarios en espanol
- MARK comments para organizar secciones
- Funciones de maximo 25 lineas
- Sin force unwrap (!)
- Sin Any ni AnyObject
- Preferir value types (struct) sobre reference types (class)
- Preferir composicion sobre herencia

## Prohibiciones
- NO crear archivos README ni documentacion
- NO usar singletons
- NO hacer networking en Views
- NO usar @State para datos compartidos entre vistas
- NO crear clases cuando un struct es suficiente
- NO usar print() para logging (usar os.Logger)

## Testing
- Framework: Swift Testing (no XCTest)
- Todo ViewModel debe tener tests
- Repositorios testeados con implementaciones mock
- Naming: test + que_se_testea + resultado_esperado
```

Observa la seccion de **Prohibiciones**. Es igual de importante que las reglas positivas. Si no dices al agente que NO use singletons, y es una solucion rapida para algo, lo hara. Si no dices que NO cree archivos README, lo hara cada vez que cree un modulo.

La regla es: **cuanto mas precisa la spec, mejor el resultado del agente.**

---

### Skills — Comandos Reutilizables

Un skill es un comando personalizado que puedes invocar con `/nombre`. Piensa en los skills como macros inteligentes: defines una instruccion compleja una vez y la ejecutas con un atajo.

```
  ┌──────────────────────────────────────────────────────────┐
  │                    SKILLS                                  │
  │                                                           │
  │  BUILT-IN:                                                │
  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
  │  │  /commit      │  │  /review-pr  │  │  /init        │  │
  │  │  Crea commit  │  │  Revisa PR   │  │  Crea         │  │
  │  │  con mensaje  │  │  en GitHub   │  │  CLAUDE.md    │  │
  │  │  descriptivo  │  │              │  │              │  │
  │  └──────────────┘  └──────────────┘  └──────────────┘  │
  │                                                           │
  │  CUSTOM (tu los defines en .claude/skills/):             │
  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
  │  │  /create-view │  │  /add-test   │  │  /new-feature │  │
  │  │  Genera vista │  │  Genera test │  │  Crea feature │  │
  │  │  + ViewModel  │  │  para un     │  │  completa     │  │
  │  │  con tu arch  │  │  ViewModel   │  │  MVVM         │  │
  │  └──────────────┘  └──────────────┘  └──────────────┘  │
  └──────────────────────────────────────────────────────────┘
```

Los skills custom se almacenan como archivos Markdown en `.claude/skills/`. Cada archivo contiene las instrucciones que el agente ejecuta cuando invocas el skill.

Ejemplo de un skill custom para crear una vista SwiftUI:

```markdown
<!-- .claude/skills/create-view.md -->

# /create-view

Crea una nueva vista SwiftUI con su ViewModel siguiendo la arquitectura del proyecto.

## Instrucciones

Dado el nombre de una feature (ej: "TaskDetail"):

1. Crear `Features/{Nombre}/{Nombre}View.swift` con:
   - Un struct que conforma View
   - @State var viewModel: {Nombre}ViewModel
   - MARK comments para secciones (Body, Subviews, Actions)
   - Preview con datos mock

2. Crear `Features/{Nombre}/{Nombre}ViewModel.swift` con:
   - Clase @Observable
   - Repositorio inyectado por init
   - Funciones async para operaciones de datos
   - Estado de loading/error

3. Seguir TODAS las reglas de CLAUDE.md sin excepcion
```

Cuando escribes `/create-view TaskDetail`, el agente lee este archivo, sigue las instrucciones y genera ambos archivos respetando tu arquitectura.

La clave es que el skill captura tu decision arquitectonica UNA vez. Sin el skill, tendrias que explicar la estructura cada vez que creas una nueva vista. Con el skill, es un comando.

---

### Hooks — Automatizaciones

Los hooks son comandos de shell que se ejecutan automaticamente antes o despues de ciertas acciones del agente. Son tu red de seguridad automatizada.

```
  ┌──────────────────────────────────────────────────────────┐
  │                    HOOKS                                   │
  │                                                           │
  │  CUANDO SE DISPARAN:                                      │
  │                                                           │
  │  ┌──────────────────────────────────────────────────┐    │
  │  │  PreEdit     → Antes de que el agente edite      │    │
  │  │  PostEdit    → Despues de editar un archivo       │    │
  │  │  PreCommit   → Antes de hacer commit              │    │
  │  │  PostCommit  → Despues de hacer commit            │    │
  │  └──────────────────────────────────────────────────┘    │
  │                                                           │
  │  EJEMPLO DE FLUJO:                                        │
  │                                                           │
  │  Agente edita View.swift                                  │
  │       ↓                                                   │
  │  [PostEdit Hook] → swiftlint --fix View.swift            │
  │       ↓                                                   │
  │  Agente hace commit                                       │
  │       ↓                                                   │
  │  [PreCommit Hook] → swift build (verifica que compila)   │
  │       ↓                                                   │
  │  Si falla → commit cancelado, agente intenta corregir    │
  └──────────────────────────────────────────────────────────┘
```

Los hooks se configuran en `.claude/settings.json`:

```json
{
  "hooks": {
    "PostEdit": [
      {
        "command": "swiftlint lint --strict --path $EDITED_FILE",
        "description": "Ejecutar SwiftLint despues de cada edicion"
      }
    ],
    "PreCommit": [
      {
        "command": "swift build 2>&1",
        "description": "Verificar que el proyecto compila antes de commit"
      },
      {
        "command": "swift test 2>&1",
        "description": "Ejecutar tests antes de commit"
      }
    ]
  }
}
```

Con esta configuracion, cada vez que el agente edita un archivo Swift, SwiftLint verifica el estilo. Cada vez que intenta un commit, el proyecto se compila y los tests se ejecutan. Si algo falla, el agente recibe el error y lo corrige.

Esto es poderoso porque **no dependes de tu memoria para verificar calidad**. El sistema lo hace automaticamente.

---

### Subagentes

Cuando el agente principal recibe una tarea compleja, puede lanzar subagentes especializados para resolverla en paralelo. Piensa en un equipo de desarrollo: no todos trabajan en el mismo archivo al mismo tiempo. Uno investiga, otro implementa, otro testea.

```
  ┌──────────────────────────────────────────────────────────┐
  │                   SUBAGENTES                               │
  │                                                           │
  │  TAREA: "Implementar modulo de autenticacion"             │
  │                                                           │
  │  ┌──────────────────┐                                     │
  │  │  AGENTE PRINCIPAL │                                     │
  │  │  (Coordinador)    │                                     │
  │  └────────┬─────────┘                                     │
  │       ┌───┼───────────────┐                               │
  │       ↓   ↓               ↓                               │
  │  ┌────────┐  ┌────────┐  ┌────────┐                      │
  │  │ Sub 1  │  │ Sub 2  │  │ Sub 3  │                      │
  │  │Investig│  │Implemen│  │Testing │                      │
  │  │        │  │tacion  │  │        │                      │
  │  │Lee docs│  │Escribe │  │Escribe │                      │
  │  │de      │  │modelos │  │tests   │                      │
  │  │AuthKit │  │y views │  │para    │                      │
  │  │        │  │        │  │todo    │                      │
  │  └───┬────┘  └───┬────┘  └───┬────┘                      │
  │      └───────────┼───────────┘                            │
  │                  ↓                                         │
  │  ┌──────────────────────────┐                             │
  │  │  AGENTE PRINCIPAL        │                             │
  │  │  Integra resultados      │                             │
  │  │  Verifica coherencia     │                             │
  │  └──────────────────────────┘                             │
  └──────────────────────────────────────────────────────────┘
```

Claude Code usa la herramienta `Agent` internamente para esto. Cuando le pides algo complejo como "implementa un modulo de autenticacion con login, registro, recuperacion de contrasena y tests", el agente puede:

1. Lanzar un subagente que investiga la documentacion de las APIs necesarias
2. Lanzar otro que implementa los modelos y repositorios
3. Lanzar otro que crea las vistas y ViewModels
4. Integrar todo al final

No necesitas pedirlo explicitamente — el agente decide cuando paralelizar. Pero puedes ayudarlo siendo explicito: "Investiga primero la API de AuthenticationServices y luego implementa basandote en esa investigacion."

---

### El Ciclo SDD Completo

Este es el flujo completo de Spec Driven Development en la practica:

```
  ┌──────────────────────────────────────────────────────────┐
  │              CICLO SDD COMPLETO                            │
  │                                                           │
  │  ┌──────────┐                                             │
  │  │ 1. SPEC  │  Escribes CLAUDE.md + descripcion de tarea  │
  │  └────┬─────┘                                             │
  │       ↓                                                   │
  │  ┌──────────┐                                             │
  │  │ 2. GEN   │  El agente genera implementacion            │
  │  └────┬─────┘                                             │
  │       ↓                                                   │
  │  ┌──────────┐    ┌─────────────────────────────────┐     │
  │  │ 3. REVIEW│───→│ Revisas con mentalidad de        │     │
  │  └────┬─────┘    │ code review, no de implementador │     │
  │       ↓          └─────────────────────────────────┘     │
  │  ┌──────────┐                                             │
  │  │ Correcto?│                                             │
  │  └──┬───┬───┘                                             │
  │  NO │   │ SI                                              │
  │     ↓   ↓                                                 │
  │  ┌──────┐  ┌──────────┐                                  │
  │  │4. REF│  │ 6. ACCEPT│                                  │
  │  │INE   │  └────┬─────┘                                  │
  │  │SPEC  │       ↓                                         │
  │  └──┬───┘  ┌──────────┐                                  │
  │     │      │ 7. COMMIT│                                  │
  │     ↓      └──────────┘                                  │
  │  ┌──────────┐                                             │
  │  │ 5. REGEN │  El agente regenera con spec mejorada       │
  │  └────┬─────┘                                             │
  │       ↓                                                   │
  │    (vuelve a paso 3)                                      │
  └──────────────────────────────────────────────────────────┘
```

El paso mas importante es el **4: Refinar la spec, no el codigo**. Este es el cambio mental mas dificil de SDD.

```swift
// MARK: - Ejemplo del ciclo SDD en accion

/*
 INTENTO 1:
 ==========
 Tu spec dice: "Crear una vista de lista de tareas"

 El agente genera una vista con NavigationView (deprecated),
 un ViewModel con @Published (Combine), y sin tests.

 REACCION INCORRECTA:
 Abrir el codigo y cambiar NavigationView por NavigationStack,
 @Published por @Observable, y escribir los tests tu mismo.
 → Esto es desarrollo tradicional disfrazado de SDD.

 REACCION CORRECTA:
 Actualizar tu CLAUDE.md:
 - "Usar NavigationStack, NO NavigationView"
 - "Usar @Observable, NO ObservableObject/@Published"
 - "Todo ViewModel debe tener tests con Swift Testing"

 Y pedirle al agente que regenere.


 INTENTO 2:
 ==========
 Ahora el agente genera con NavigationStack, @Observable y tests.
 Pero el ViewModel tiene 200 lineas y hace networking directamente.

 REFINAR SPEC:
 - "ViewModels max 100 lineas"
 - "Networking solo a traves de Repository (protocolo)"
 - "Inyectar dependencias por init, no por singleton"


 INTENTO 3:
 ==========
 El agente genera codigo limpio, con la arquitectura correcta,
 tests incluidos, y siguiendo todas las reglas.

 ACEPTAR y COMMIT.


 RESULTADO:
 Tu CLAUDE.md ahora tiene reglas tan precisas que la proxima
 feature se genera correcta al primer intento.
 La spec MEJORA con cada iteracion.
*/
```

---

### Errores Comunes en SDD

```swift
// MARK: - 5 Errores que arruinan tu flujo SDD

/*
 ERROR 1: SPEC DEMASIADO VAGA
 ============================
 MAL:  "Haz una buena app de tareas"
 BIEN: "Crea TaskListView con NavigationStack que muestra
        tareas desde SwiftData, agrupadas por prioridad,
        con swipe-to-delete y pull-to-refresh"

 Una spec vaga produce codigo generico. Una spec precisa
 produce exactamente lo que necesitas.


 ERROR 2: CORREGIR CODIGO EN VEZ DE CORREGIR LA SPEC
 ====================================================
 Si el agente genera algo incorrecto, el problema no es
 el codigo — es la spec. Corregir el codigo es un parche.
 Corregir la spec es una solucion permanente.

 Cada correccion manual es una regla que falta en tu CLAUDE.md.


 ERROR 3: NO REVISAR EL OUTPUT DEL AGENTE
 ==========================================
 "Compilo, ship it" es peligroso. El agente puede generar
 codigo que compila pero:
 - Tiene vulnerabilidades de seguridad
 - No maneja errores correctamente
 - Tiene race conditions
 - Usa patrones anti-idomiaticos

 SDD no elimina code review — lo hace mas importante.


 ERROR 4: MICROMANAGING AL AGENTE
 =================================
 Si le dictas cada linea de codigo al agente, no estas
 haciendo SDD — estas usando el agente como autocomplete.

 MAL:  "Crea un struct llamado Task con var title: String,
        var isCompleted: Bool, luego crea una funcion
        toggle que cambie isCompleted..."

 BIEN: "Crea el modelo Task con las propiedades necesarias
        para una app de tareas. Incluir operaciones CRUD."

 Dale espacio al agente para tomar decisiones tacticas.
 Tu controlas la estrategia.


 ERROR 5: NO USAR CONTROL DE VERSIONES
 ======================================
 SIEMPRE haz commit antes de dejar que el agente haga
 cambios grandes. Si algo sale mal, necesitas poder volver.

 Flujo seguro:
 1. git commit (estado actual)
 2. Pedirle al agente que implemente
 3. Revisar cambios con git diff
 4. Si esta bien → commit
 5. Si esta mal → git checkout . y refinar spec
*/
```

---

### SDD con Swift y Xcode — Ejemplo Practico

Veamos como aplicar SDD a un flujo real de desarrollo iOS:

```swift
// MARK: - Ejemplo: Crear un modulo de Networking con SDD

/*
 PASO 1: ESCRIBIR LA SPEC
 =========================
 En tu CLAUDE.md ya tienes las reglas generales.
 Ahora escribes la tarea especifica:

 "Crea un NetworkClient que:
  - Use URLSession con async/await
  - Soporte GET, POST, PUT, DELETE
  - Decodifique respuestas con JSONDecoder
  - Maneje errores con un enum NetworkError
  - Sea un protocolo (para testing con mocks)
  - Incluya una implementacion concreta
  - Incluya tests con Swift Testing usando mock"


 PASO 2: EL AGENTE GENERA
 =========================
 El agente crea:
 - NetworkClient.swift (protocolo)
 - URLSessionNetworkClient.swift (implementacion)
 - NetworkError.swift (enum de errores)
 - MockNetworkClient.swift (para tests)
 - NetworkClientTests.swift (tests)


 PASO 3: TU REVISAS
 ===================
 Preguntas clave durante el review:
 - Sigue la arquitectura de mi CLAUDE.md?
 - Los errores son descriptivos y utiles?
 - Los tests cubren happy path Y edge cases?
 - Puedo inyectar esto facilmente en mis ViewModels?
 - Es Sendable para uso con concurrencia?


 PASO 4: REFINAR SI ES NECESARIO
 ================================
 "El NetworkClient no es Sendable. Agrega conformancia
  a Sendable. Tambien agrega retry con exponential backoff
  configurable. Y un interceptor para headers de auth."


 PASO 5: ACEPTAR Y COMMIT
 ==========================
 /commit
*/
```

El resultado de este flujo no es solo codigo funcional — es un CLAUDE.md cada vez mas preciso que produce mejores resultados con cada iteracion.

---

## Ejercicio 1: Escribir CLAUDE.md para una Todo App (Basico)

**Objetivo**: Practicar la escritura de especificaciones precisas creando un CLAUDE.md completo.

**Requisitos**:
1. Crear un archivo CLAUDE.md para una aplicacion de tareas (Todo App) que incluya:
   - Descripcion del proyecto (que es, para quien, problema que resuelve)
   - Stack tecnico exacto (iOS 26, Swift 6.2, SwiftUI, SwiftData)
   - Arquitectura (MVVM con Repository pattern)
   - Estructura de carpetas completa
   - Al menos 10 reglas de estilo de codigo
   - Al menos 8 prohibiciones explicitas
   - Requisitos de testing (framework, cobertura, naming)
   - Comandos para compilar y ejecutar tests
2. Cada seccion debe ser lo suficientemente precisa para que un agente genere codigo correcto sin ambiguedad
3. Incluir al menos 3 ejemplos concretos de lo que SI y lo que NO hacer
4. Probar tu CLAUDE.md dandole al agente la tarea: "Crea el modelo Task y su ViewModel con tests"
5. Evaluar si el resultado cumple tus expectativas — si no, refinar la spec y probar de nuevo

**Criterios de exito**: El agente genera codigo que sigue tu arquitectura sin que tengas que corregir nada manualmente.

---

## Ejercicio 2: Ciclo SDD para un Networking Layer (Intermedio)

**Objetivo**: Experimentar el ciclo completo de SDD con tres iteraciones de refinamiento.

**Requisitos**:
1. Escribir una spec para un networking layer:
   - Protocolo `APIClient` con metodos para GET, POST, PUT, DELETE
   - Implementacion con URLSession y async/await
   - Manejo de errores con enum tipado
   - Soporte para interceptores (auth headers, logging)
   - Tests con mock client
2. **Iteracion 1**: Dar la spec al agente y evaluar el resultado
   - Anotar que salio bien y que salio mal
   - NO corregir el codigo manualmente
3. **Iteracion 2**: Refinar la spec basandote en los problemas del intento 1
   - Agregar reglas que falten al CLAUDE.md
   - Pedir regeneracion completa
   - Evaluar mejoras
4. **Iteracion 3**: Ultimo refinamiento
   - La spec debe ser tan precisa que el resultado sea aceptable
   - Documentar que reglas agregaste en cada iteracion
5. Crear un archivo `sdd-log.md` que documente las 3 iteraciones: spec usada, resultado, problemas, refinamientos

**Criterio de exito**: En la iteracion 3, el codigo generado necesita cero correcciones manuales.

---

## Ejercicio 3: Crear un Custom Skill para MVVM Features (Avanzado)

**Objetivo**: Crear un skill reutilizable que genere una feature MVVM completa desde una sola descripcion.

**Requisitos**:
1. Crear el directorio `.claude/skills/` en tu proyecto
2. Crear el archivo `.claude/skills/new-feature.md` que defina un skill `/new-feature` con estas instrucciones:
   - Recibe: nombre de feature y descripcion breve
   - Genera: `{Feature}View.swift`, `{Feature}ViewModel.swift`, `{Feature}Tests.swift`
   - La View debe usar NavigationStack, tener Preview con datos mock
   - El ViewModel debe ser @Observable, recibir repositorio por init
   - Los tests deben usar Swift Testing con mock del repositorio
   - Todo debe seguir las reglas de CLAUDE.md
3. Probar el skill con 3 features diferentes:
   - `/new-feature TaskList "Lista de tareas con filtro por prioridad"`
   - `/new-feature TaskDetail "Detalle de tarea con edicion inline"`
   - `/new-feature Settings "Configuracion con toggle de notificaciones"`
4. Verificar que las 3 features siguen exactamente la misma arquitectura
5. Configurar un hook PostEdit que ejecute SwiftLint en cada archivo editado:
   - Crear `.claude/settings.json` con la configuracion del hook
   - Verificar que el hook se ejecuta cuando el agente edita archivos
6. Documentar el proceso: que funciono, que ajustaste en el skill, que harias diferente

**Criterio de exito**: Invocar `/new-feature` genera una feature completa, consistente con el resto del proyecto, sin intervencion manual.

---

## Checklist

- [ ] Entender la diferencia entre desarrollo tradicional, TDD y SDD
- [ ] Comprender que la spec es la fuente de verdad, no el codigo
- [ ] Conocer la estructura de un CLAUDE.md efectivo (7 secciones)
- [ ] Saber escribir prohibiciones tan precisas como las reglas positivas
- [ ] Entender que son los skills y como crear custom skills
- [ ] Saber configurar hooks en `.claude/settings.json`
- [ ] Conocer los tipos de hooks: PreEdit, PostEdit, PreCommit, PostCommit
- [ ] Entender el concepto de subagentes y cuando se activan
- [ ] Dominar el ciclo SDD: Spec → Generate → Review → Refine → Accept
- [ ] Internalizar la regla: si el output es incorrecto, corrige la spec — no el codigo
- [ ] Conocer los 5 errores comunes de SDD y como evitarlos
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Spec Driven Development transforma como construyes tu Proyecto Integrador:

- **CLAUDE.md del proyecto** define toda la arquitectura, reglas y prohibiciones — es el blueprint completo
- **Skills personalizados** para generar features nuevas con un solo comando, manteniendo consistencia
- **Hooks de calidad** que ejecutan SwiftLint y tests automaticamente en cada cambio del agente
- **Ciclo iterativo** donde cada feature mejora tu spec, y tu spec mejora la siguiente feature
- **Subagentes** para tareas complejas como "implementar sincronizacion con CloudKit" que requieren investigacion + implementacion + testing en paralelo
- **Version control como red de seguridad** — siempre commit antes de pedirle al agente cambios grandes
- **Tu rol como arquitecto** se refleja en la calidad de tu spec, no en la cantidad de codigo que escribes

---

*Leccion 46 (L46) | Spec Driven Development | Modulo 14*
