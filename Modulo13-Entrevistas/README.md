# Modulo 13: Entrevistas iOS (Bonus)

## Descripcion

Modulo bonus de preparacion para entrevistas tecnicas iOS. No forma parte del curriculum secuencial — se puede usar en cualquier momento. El Profesor Apple simula entrevistas reales adaptadas al nivel del alumno.

---

## Niveles de Entrevista

| Nivel | Perfil | Temas Principales |
|-------|--------|-------------------|
| **Junior** | 0-2 anos exp. | Swift basico, UIKit/SwiftUI fundamentos, ciclo de vida, Auto Layout, MVC |
| **Mid** | 2-5 anos exp. | Arquitectura, concurrencia, networking, testing, SwiftUI avanzado, debugging |
| **Senior** | 5+ anos exp. | System design, performance, seguridad, liderazgo tecnico, code review, mentoring |
| **FAANG** | Big Tech | Algoritmos, estructuras de datos, system design a escala, behavioral, coding en vivo |

---

## Formato de Entrevista Simulada

El alumno puede pedir: *"Modo entrevista [nivel]"* y Claude simula una entrevista de 30-45 min:

### Estructura

1. **Warm-up (5 min)** — Presentacion y preguntas sobre experiencia
2. **Conceptual (10 min)** — Preguntas teoricas sobre Swift y frameworks
3. **Coding (15 min)** — Resolver un problema en vivo con Swift
4. **System Design (10 min)** — Solo para Senior/FAANG: disenar una feature o sistema
5. **Feedback** — Claude evalua respuestas, da puntuacion y areas de mejora

---

## Banco de Preguntas por Categoria

### Swift Language
- ¿Cual es la diferencia entre struct y class? ¿Cuando usarias cada uno?
- Explica el ciclo de vida de ARC. ¿Que es un retain cycle y como lo evitas?
- ¿Que son los optionals y por que existen? ¿Diferencia entre if let, guard let y force unwrap?
- Explica some vs any. ¿Cuando usarias cada uno?
- ¿Que es Sendable y por que es importante en Swift 6?
- ¿Que es copy-on-write y que tipos lo implementan?
- Explica la diferencia entre escaping y non-escaping closures

### Concurrencia
- Explica async/await vs GCD. ¿Por que Apple hizo el cambio?
- ¿Que es un actor? ¿En que se diferencia de una clase con un lock?
- ¿Que es structured concurrency y por que importa?
- ¿Que pasa si llamas a una funcion @MainActor desde un Task en background?
- ¿Como cancelarias una tarea en Swift concurrency?
- Explica TaskGroup y da un caso de uso real

### SwiftUI
- ¿Como funciona el sistema de diffing de SwiftUI?
- ¿Diferencia entre @State, @Binding, @Observable y @Environment?
- ¿Que es un ViewModifier y cuando crearias uno custom?
- ¿Como manejas navegacion programatica con NavigationStack?
- ¿Que problemas tiene List con datasets grandes y como los resuelves?
- Explica el ciclo de vida de una View en SwiftUI

### Arquitectura
- ¿Que patron arquitectonico usas y por que? Comparalo con alternativas
- ¿Como implementas inyeccion de dependencias en SwiftUI sin librerias externas?
- ¿Como separas la logica de negocio de la UI en SwiftUI?
- ¿Que es el Repository Pattern y cuando lo usarias?
- ¿Como manejas el estado global de una app?

### System Design (Senior/FAANG)
- Disena la arquitectura de una app de mensajeria tipo iMessage
- ¿Como diseñarias un sistema de cache offline-first para una app de noticias?
- Disena un feed infinito con paginacion, imagenes y videos
- ¿Como sincronizarias datos entre iOS y watchOS en tiempo real?
- Disena una app que funcione sin conexion y sincronice cuando vuelva la red

### Behavioral (FAANG)
- Cuentame un bug dificil que resolviste y como lo abordaste
- ¿Como manejas desacuerdos tecnicos con el equipo?
- Describe un proyecto del que estes orgulloso y por que
- ¿Como priorizas deuda tecnica vs features nuevas?

---

## Evaluacion

Despues de la entrevista simulada, Claude da:

| Aspecto | Puntuacion |
|---------|------------|
| Conocimiento tecnico | _/10 |
| Comunicacion | _/10 |
| Resolucion de problemas | _/10 |
| Codigo limpio | _/10 |
| **Total** | _/40 |

### Criterios
- **30-40**: Listo para la entrevista
- **20-29**: Necesita reforzar areas especificas
- **<20**: Revisar modulos del curriculum relacionados

---

## Comandos

```bash
# Pedir entrevista simulada
"Modo entrevista junior"
"Modo entrevista senior"
"Modo entrevista FAANG"

# Pedir preguntas especificas
"Dame preguntas de concurrencia nivel senior"
"Preguntame sobre system design"
"Simula un coding challenge de arrays"
```

---

## Recursos Complementarios

| Recurso | Link | Tipo |
|---------|------|------|
| Sean Allen — iOS Interview Tips | YouTube | Video |
| Paul Hudson — Swift Coding Challenges | hackingwithswift.com | Ejercicios |
| Designing Data-Intensive Applications | Libro | System Design |
| LeetCode Swift | leetcode.com | Coding Challenges |

---

## Mini-Proyecto: Mock Interview

El alumno graba (en texto) una entrevista simulada completa y la revisa:
1. Hacer la entrevista con Claude en "Modo entrevista"
2. Revisar el feedback
3. Estudiar las areas debiles
4. Repetir en 1 semana y comparar puntuaciones

> Objetivo: mejorar la puntuacion en cada iteracion hasta estar listo.

---

*Modulo 13 | Entrevistas iOS | Bonus | No secuencial*
