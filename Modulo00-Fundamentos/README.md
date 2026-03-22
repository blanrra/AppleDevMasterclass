# Modulo 00: Fundamentos (Semanas 1-12)

## Descripcion

El modulo mas extenso del curriculum. Establece las bases solidas de Swift 6, Protocol-Oriented Programming, concurrencia moderna, Xcode 26 y los fundamentos de SwiftUI. Todo lo aprendido aqui es prerequisito para los modulos siguientes.

---

## Lecciones

| # | Leccion | Semanas | Archivo |
|---|---------|---------|---------|
| L01 | Tu Primer Programa | 1 | [Leccion01_PrimerPrograma.md](Leccion01_PrimerPrograma.md) |
| L02 | Control de Flujo | 2 | [Leccion02_ControlFlujo.md](Leccion02_ControlFlujo.md) |
| L03 | Funciones y Closures | 3 | [Leccion03_FuncionesClosures.md](Leccion03_FuncionesClosures.md) |
| L04 | Structs, Clases y Enums | 4 | [Leccion04_StructsClasesEnums.md](Leccion04_StructsClasesEnums.md) |
| L05 | Swift 6 Language | 5-6 | [Leccion05_Swift6Language.md](Leccion05_Swift6Language.md) |
| L06 | POP y Genericos Avanzados | 6-7 | [Leccion06_POP_Generics.md](Leccion06_POP_Generics.md) |
| L07 | Manejo de Errores y Memoria | 7-8 | [Leccion07_ErrorHandling_Memory.md](Leccion07_ErrorHandling_Memory.md) |
| L08 | Concurrencia Moderna | 8-10 | [Leccion08_Concurrency.md](Leccion08_Concurrency.md) |
| L09 | Xcode 26 | 10-11 | [Leccion09_Xcode26.md](Leccion09_Xcode26.md) |
| L10 | SwiftUI Fundamentos | 11-12 | [Leccion10_SwiftUIFundamentals.md](Leccion10_SwiftUIFundamentals.md) |

---

## Objetivos del Modulo

Al completar este modulo seras capaz de:

- [ ] Escribir tu primer programa Swift y entender tipos basicos
- [ ] Dominar control de flujo: if, switch, for, while, guard
- [ ] Crear funciones, closures y entender captura de valores
- [ ] Diferenciar structs, clases y enums; saber cuando usar cada uno
- [ ] Dominar Swift 6: optionals, closures, structs/classes, enums, genericos
- [ ] Aplicar Protocol-Oriented Programming con extensions y composicion
- [ ] Manejar errores robustamente con Result, typed throws y do-catch
- [ ] Entender ARC, retain cycles y value vs reference semantics
- [ ] Usar async/await, Task, TaskGroup y actors para concurrencia segura
- [ ] Configurar y debuggear proyectos en Xcode 26
- [ ] Crear interfaces basicas con SwiftUI: @State, @Binding, @Observable

---

## Prerequisitos

- Nivel 1: Ninguno. Nivel 2+: Conocimiento basico de programacion
- Se recomienda Swift Playgrounds para las lecciones L01-L04 (Nivel 1-2)
- Conceptos basicos de programacion orientada a objetos (para L05 en adelante)

---

## Codigo

Los archivos ejecutables de practica estan en la carpeta `Codigo/`:

```bash
# Ejecutar ejemplos
swift Modulo00-Fundamentos/Codigo/PaymentSystem.swift
swift Modulo00-Fundamentos/Codigo/Swift6Basics.swift
swift Modulo00-Fundamentos/Codigo/POPGenerics.swift
swift Modulo00-Fundamentos/Codigo/ErrorMemory.swift
swift Modulo00-Fundamentos/Codigo/ConcurrencyDemo.swift
```

---

## Comandos Cupertino Clave

```bash
cupertino search --source swift-book "language guide"
cupertino search "protocol oriented programming"
cupertino search "automatic reference counting"
cupertino search "swift concurrency"
cupertino search --source updates "Xcode 26"
cupertino search "SwiftUI fundamentals"
```

---

## Proyecto Practico del Modulo

Al finalizar las 10 lecciones, crear una **libreria de networking type-safe** que use:
- Genericos para requests/responses
- async/await para llamadas de red
- Manejo robusto de errores con Result
- Protocol-Oriented Design

---

## Mini-Proyecto: Calculadora CLI

Construir una **calculadora en terminal** que evoluciona con cada bloque:
- **Bloque A** (L01-L04): Calculadora basica con operaciones y historial
- **Bloque B** (L05-L08): Refactorizar con protocolos, genericos y async
- **Bloque C** (L09-L10): Convertir a app SwiftUI con interfaz grafica

> Este mini-proyecto se conecta con el Proyecto Integrador como base para la capa de logica de negocio.

---

*Modulo 00 — Fundamentos | Semanas 1-12 | 10 lecciones*
