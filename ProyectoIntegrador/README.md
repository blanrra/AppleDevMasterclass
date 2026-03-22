# Proyecto Integrador

## Descripcion

El Proyecto Integrador es una app completa que se construye incrementalmente desde la **semana 20** del curriculum. Integra las tecnologias aprendidas en cada modulo para crear una aplicacion real publicable en el App Store.

---

## Requisitos Minimos

- [ ] **SwiftData** para persistencia local
- [ ] **CloudKit** para sincronizacion (opcional)
- [ ] **Minimo 2 plataformas**: iOS + (watchOS o visionOS)
- [ ] **Tests unitarios y de UI** con cobertura > 80%
- [ ] **Al menos 1 sensor/API de hardware** (HealthKit, Location, Camera)
- [ ] **Widget o App Intent** para integracion con el sistema
- [ ] **Arquitectura Clean/MVVM** bien definida
- [ ] **Publicacion en TestFlight**

---

## Hitos por Modulo

| Semana | Hito | Modulo | Entregable |
|--------|------|--------|------------|
| 20 | Setup del proyecto | Datos y Persistencia | Proyecto Xcode con estructura base |
| 22 | Persistencia local | Datos y Persistencia | Modelos SwiftData funcionando |
| 26 | Hardware/Sensores | Hardware y Sensores | Feature de sensor integrada |
| 30 | Features de IA | IA y ML | Feature de IA/ML integrada |
| 34 | Widgets/Siri | Integracion Sistema | Widget y/o App Intent funcionando |
| 38 | Multiplataforma | Plataformas | Version watchOS o visionOS |
| 42 | Tests completos | Testing y Calidad | Suite de tests > 80% cobertura |
| 44 | Optimizacion | Seguridad y Performance | App optimizada con Instruments |
| 46 | TestFlight | Monetizacion y Distribucion | Build publicado en TestFlight |
| 48 | Version final | Extras | App completa y pulida |

---

## Estructura Sugerida del Proyecto

```
MiApp/
  Sources/
    App/                    # @main, App entry point
    Features/               # Features por pantalla
    Models/                 # SwiftData models
    Services/               # Networking, HealthKit, etc.
    ViewModels/             # @Observable ViewModels
    Views/                  # Vistas SwiftUI
    Extensions/             # Extensiones utiles
  Tests/
    UnitTests/
    UITests/
  Widgets/                  # WidgetKit extension
  WatchApp/                 # watchOS companion (si aplica)
```

---

## Ideas de Proyecto

1. **App de Fitness/Salud**: HealthKit + watchOS + SwiftData + Widgets
2. **App de Viajes**: MapKit + Camera + CloudKit + visionOS spatial photos
3. **App de Productividad**: SwiftData + Widgets + App Intents + Siri
4. **App de Recetas**: Foundation Models (IA) + Camera + SwiftData + Share extension

---

## Notas

- El proyecto se define en la semana 20 cuando ya se tienen bases solidas
- No es obligatorio incluir TODAS las tecnologias, pero si las marcadas como requisito minimo
- Se puede cambiar de idea de proyecto si es necesario, pero intentar mantener uno solo
- El objetivo es tener una app real en el App Store al final del curriculum

---

*Proyecto Integrador — Curriculum Apple Developer 48 Semanas*
