# Modulo 01: Arquitectura (Semanas 13-14)

## Descripcion

Patrones arquitectonicos para apps SwiftUI escalables. MVVM como patron principal, Clean Architecture para separacion de capas, e inyeccion de dependencias para testabilidad.

## Lecciones

| # | Leccion | Semana | Archivo |
|---|---------|--------|---------|
| L11 | MVVM en SwiftUI | 13 | Leccion11_MVVM.md |
| L12 | Clean Architecture y DI | 14 | Leccion12_CleanArchitecture.md |

## Objetivos

- [ ] Implementar MVVM con @Observable ViewModels
- [ ] Separar app en capas: Presentation, Domain, Data
- [ ] Aplicar inyeccion de dependencias con protocolos
- [ ] Usar Environment para inyeccion en SwiftUI

## Prerequisitos

- Modulo 00 completo (Swift 6, POP, SwiftUI basico)

## Comandos Cupertino

```bash
cupertino search "MVVM SwiftUI"
cupertino search "dependency injection SwiftUI"
cupertino search "SwiftUI architecture"
```

## Proyecto Practico

Refactorizar la app del Modulo 00 aplicando Clean Architecture con capas bien definidas.

---

## Mini-Proyecto: Refactorizar la Calculadora

Tomar la calculadora del Modulo 00 y aplicar:
- **MVVM**: Separar logica en ViewModel con @Observable
- **Clean Architecture**: Crear capas Presentation/Domain/Data
- **DI**: Inyectar dependencias via protocolos y Environment

> Resultado: una app bien arquitecturada lista para crecer.

---

*Modulo 01 | Arquitectura | Semanas 13-14 | 2 lecciones*
