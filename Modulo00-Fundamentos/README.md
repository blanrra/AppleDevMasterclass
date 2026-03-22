# Modulo 00: Fundamentos (Semanas 1-8)

## Descripcion

El modulo mas extenso del curriculum. Establece las bases solidas de Swift 6, Protocol-Oriented Programming, concurrencia moderna, Xcode 26 y los fundamentos de SwiftUI. Todo lo aprendido aqui es prerequisito para los modulos siguientes.

---

## Lecciones

| # | Leccion | Semanas | Archivo |
|---|---------|---------|---------|
| L01 | Swift 6 Language | 1-2 | [Leccion01_Swift6Language.md](Leccion01_Swift6Language.md) |
| L02 | POP y Genericos Avanzados | 2-3 | [Leccion02_POP_Generics.md](Leccion02_POP_Generics.md) |
| L03 | Manejo de Errores y Memoria | 3-4 | [Leccion03_ErrorHandling_Memory.md](Leccion03_ErrorHandling_Memory.md) |
| L04 | Concurrencia Moderna | 4-6 | [Leccion04_Concurrency.md](Leccion04_Concurrency.md) |
| L05 | Xcode 26 | 6-7 | [Leccion05_Xcode26.md](Leccion05_Xcode26.md) |
| L06 | SwiftUI Fundamentos | 7-8 | [Leccion06_SwiftUIFundamentals.md](Leccion06_SwiftUIFundamentals.md) |

---

## Objetivos del Modulo

Al completar este modulo seras capaz de:

- [ ] Dominar Swift 6: optionals, closures, structs/classes, enums, genericos
- [ ] Aplicar Protocol-Oriented Programming con extensions y composicion
- [ ] Manejar errores robustamente con Result, typed throws y do-catch
- [ ] Entender ARC, retain cycles y value vs reference semantics
- [ ] Usar async/await, Task, TaskGroup y actors para concurrencia segura
- [ ] Configurar y debuggear proyectos en Xcode 26
- [ ] Crear interfaces basicas con SwiftUI: @State, @Binding, @Observable

---

## Prerequisitos

- Conocimiento basico de Swift (variables, funciones, control flow)
- Haber creado al menos una vista simple en SwiftUI
- Conceptos basicos de programacion orientada a objetos

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

Al finalizar las 6 lecciones, crear una **libreria de networking type-safe** que use:
- Genericos para requests/responses
- async/await para llamadas de red
- Manejo robusto de errores con Result
- Protocol-Oriented Design

---

*Modulo 00 — Fundamentos | Semanas 1-8 | 6 lecciones*
