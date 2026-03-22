# Template — Proyecto Integrador: HabitTracker

Este template te da la estructura base para tu Proyecto Integrador. Es un punto de partida — tu lo expandiras a lo largo del curriculum.

---

## Estructura Sugerida

```
HabitTracker/
├── HabitTrackerApp.swift          # @main entry point
├── Models/
│   ├── Habit.swift                # @Model SwiftData
│   ├── HabitEntry.swift           # Registro de completado
│   └── Category.swift             # Categorias de habitos
├── Views/
│   ├── HomeView.swift             # Vista principal
│   ├── HabitDetailView.swift      # Detalle de habito
│   ├── StatsView.swift            # Estadisticas
│   └── SettingsView.swift         # Configuracion
├── ViewModels/
│   ├── HomeViewModel.swift        # @Observable
│   └── StatsViewModel.swift       # @Observable
├── Services/
│   ├── HabitService.swift         # Logica de negocio
│   ├── NotificationService.swift  # Notificaciones
│   └── HealthService.swift        # HealthKit
├── Components/
│   ├── HabitCard.swift            # Componente reutilizable
│   ├── StreakBadge.swift           # Badge de racha
│   └── ProgressRing.swift         # Anillo de progreso
├── Extensions/
│   └── Date+Extensions.swift      # Extensiones utiles
├── Resources/
│   └── Assets.xcassets/           # Imagenes y colores
├── Widget/                         # WidgetKit (Modulo 07)
├── Watch/                          # watchOS (Modulo 08)
└── Tests/
    ├── HabitServiceTests.swift
    └── ViewModelTests.swift
```

---

## Hitos por Modulo

| Modulo | Que agregas | Archivos clave |
|--------|-------------|----------------|
| M04 | SwiftData, modelos, persistencia | Models/, Services/HabitService |
| M05 | HealthKit, MapKit, Camera | Services/HealthService |
| M06 | IA para sugerencias | Services/AIService |
| M07 | Widget, App Intents, Siri | Widget/, AppIntents |
| M08 | watchOS companion | Watch/ |
| M09 | Tests completos | Tests/ |
| M10 | Seguridad, optimizacion | Privacy manifest, Instruments |
| M11 | StoreKit, TestFlight | StoreKit config |

---

## Como empezar

1. Crea un nuevo proyecto Xcode: File > New > Project > App
2. Nombre: HabitTracker (o el que prefieras)
3. Usa esta estructura de carpetas como guia
4. Empieza con Models/ y un HomeView basico
5. Cada modulo anade una capa nueva

---

## Ideas de Habitos para probar

- Meditar 10 minutos
- Leer 20 paginas
- Hacer ejercicio
- Beber 8 vasos de agua
- Escribir un diario
- Estudiar Swift (meta!)

---

*Template creado por @blanrra — Modifica y hazlo tuyo!*
