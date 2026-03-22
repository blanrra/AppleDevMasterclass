# Leccion 22: HealthKit

**Modulo 05: Hardware y Sensores** | Semanas 27-28

---

## TL;DR — Resumen en 2 minutos

- **HKHealthStore**: Punto de entrada unico a HealthKit — siempre verificar disponibilidad antes de usarlo
- **Autorizacion granular**: El usuario controla que datos compartes — pedir solo lo que necesitas, cuando lo necesitas
- **HKQuantitySample**: Leer y escribir datos como pasos, frecuencia cardiaca, peso — todo con unidades tipadas
- **HKStatisticsQuery**: Calcular promedios, sumas y min/max sobre rangos de tiempo sin procesar datos manualmente
- **HKObserverQuery**: Recibir notificaciones cuando nuevos datos de salud aparecen — ideal para actualizaciones en tiempo real

---

## Cupertino MCP

```bash
cupertino search "HealthKit"
cupertino search "HKHealthStore"
cupertino search "HKQuantitySample"
cupertino search "HKStatisticsQuery"
cupertino search "HKObserverQuery"
cupertino search "HKWorkout"
cupertino search "HKUnit"
cupertino search --source samples "HealthKit"
cupertino search --source updates "HealthKit"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [What's new in HealthKit](https://developer.apple.com/videos/play/wwdc2024/10109/) | Novedades recientes |
| WWDC23 | [Build a multi-device workout app](https://developer.apple.com/videos/play/wwdc2023/10023/) | Workouts avanzados |
| WWDC22 | [What's new in HealthKit](https://developer.apple.com/videos/play/wwdc2022/10005/) | Actualizaciones |
| WWDC20 | [Getting Started with HealthKit](https://developer.apple.com/videos/play/wwdc2020/10664/) | **Esencial** — Fundamentos |
| WWDC20 | [Synchronize health data with HealthKit](https://developer.apple.com/videos/play/wwdc2020/10184/) | Sincronizacion |
| :es: | [Julio Cesar Fernandez — HealthKit](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que HealthKit?

HealthKit no es solo una base de datos de salud — es el hub centralizado donde convergen datos de Apple Watch, apps de terceros, dispositivos medicos y el propio iPhone. Antes de HealthKit, cada app de salud era una isla: tu app de pasos no hablaba con tu app de nutricion, ni con tu bascula inteligente. HealthKit resuelve eso con un repositorio unico y seguro.

La clave filosofica: **Apple trata los datos de salud como los mas sensibles del dispositivo**. Por eso el modelo de autorizacion es granular (permiso por tipo de dato), el usuario puede revocar acceso en cualquier momento, y tu app nunca puede saber si el usuario denego el acceso — solo sabras que no puedes leer.

```
  ┌──────────────────────────────────────────────────────────┐
  │                  ARQUITECTURA HEALTHKIT                   │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   ┌──────────┐  ┌──────────┐  ┌──────────┐              │
  │   │ Apple    │  │ Apps     │  │ Disposit.│              │
  │   │ Watch    │  │ Terceros │  │ Medicos  │              │
  │   └────┬─────┘  └────┬─────┘  └────┬─────┘              │
  │        │              │              │                    │
  │        ▼              ▼              ▼                    │
  │   ┌──────────────────────────────────────┐               │
  │   │         HKHealthStore                │               │
  │   │    (Repositorio centralizado)        │               │
  │   └──────────────┬───────────────────────┘               │
  │                  │                                       │
  │        ┌─────────┼─────────┐                             │
  │        ▼         ▼         ▼                             │
  │   ┌────────┐ ┌────────┐ ┌────────┐                      │
  │   │Quantity│ │Category│ │Workout │                      │
  │   │Samples │ │Samples │ │Sessions│                      │
  │   └────────┘ └────────┘ └────────┘                      │
  └──────────────────────────────────────────────────────────┘
```

### Configuracion Inicial

Antes de escribir una sola linea de codigo, necesitas configurar tu proyecto:

1. **Capability**: Agregar HealthKit en Signing & Capabilities
2. **Info.plist**: Agregar `NSHealthShareUsageDescription` (leer) y `NSHealthUpdateUsageDescription` (escribir)
3. **Entitlement**: HealthKit se activa automaticamente al agregar la capability

```swift
import HealthKit

// MARK: - Verificar disponibilidad

func healthKitDisponible() -> Bool {
    return HKHealthStore.isHealthDataAvailable()
    // false en iPad (sin HealthKit), Simulador limitado
}
```

### HKHealthStore — El Punto de Entrada

```swift
import HealthKit

// MARK: - Gestor de HealthKit

@Observable
class GestorSalud {
    private let store = HKHealthStore()

    var pasosDiarios: Double = 0
    var frecuenciaCardiaca: Double = 0
    var pesoActual: Double = 0
    var errorMensaje: String?

    // MARK: - Tipos de datos que necesitamos
    private var tiposLectura: Set<HKObjectType> {
        let tipos: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.bodyMass),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKCategoryType(.sleepAnalysis)
        ]
        return tipos
    }

    private var tiposEscritura: Set<HKSampleType> {
        let tipos: Set<HKSampleType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.bodyMass),
            HKQuantityType(.activeEnergyBurned)
        ]
        return tipos
    }

    // MARK: - Solicitar autorizacion
    func solicitarAutorizacion() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMensaje = "HealthKit no disponible en este dispositivo"
            return
        }

        try await store.requestAuthorization(
            toShare: tiposEscritura,
            read: tiposLectura
        )
    }
}
```

### Autorizacion — El Flujo Critico

El modelo de autorizacion de HealthKit es unico en iOS. A diferencia de Location o Camera donde el usuario da un "si" o "no" general, en HealthKit el usuario puede elegir **por cada tipo de dato individualmente**. Y lo mas importante: **tu app no puede saber si el usuario denego un tipo especifico** — `authorizationStatus(for:)` solo distingue entre "no determinado" y "compartido disponible". Si el usuario denego, HealthKit simplemente no devuelve datos.

```swift
// MARK: - Verificar estado de autorizacion

extension GestorSalud {
    func verificarAutorizacion(para tipo: HKObjectType) -> HKAuthorizationStatus {
        return store.authorizationStatus(for: tipo)
        // .notDetermined — nunca se pidio
        // .sharingAuthorized — el usuario permitio escribir
        // .sharingDenied — el usuario denego escribir
        // NOTA: Para lectura, NO hay forma de saber si denego
    }

    var necesitaAutorizacion: Bool {
        let tipoPasos = HKQuantityType(.stepCount)
        return store.authorizationStatus(for: tipoPasos) == .notDetermined
    }
}
```

### Leer Datos — HKQuantitySample

```swift
import HealthKit

// MARK: - Leer pasos del dia

extension GestorSalud {
    func leerPasosHoy() async throws -> Double {
        let tipoPasos = HKQuantityType(.stepCount)

        let ahora = Date()
        let inicioDelDia = Calendar.current.startOfDay(for: ahora)
        let predicado = HKQuery.predicateForSamples(
            withStart: inicioDelDia,
            end: ahora,
            options: .strictStartDate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate<HKQuantitySample>(
                sampleType: tipoPasos,
                predicate: predicado
            ),
            options: .cumulativeSum
        )

        let resultado = try await descriptor.result(for: store)
        let pasos = resultado?.sumQuantity()?.doubleValue(
            for: HKUnit.count()
        ) ?? 0

        await MainActor.run {
            self.pasosDiarios = pasos
        }

        return pasos
    }

    // MARK: - Leer frecuencia cardiaca reciente
    func leerFrecuenciaCardiaca() async throws -> Double {
        let tipoFC = HKQuantityType(.heartRate)

        let descriptor = HKSampleQueryDescriptor(
            predicates: [
                .quantitySample(type: tipoFC)
            ],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        let resultados = try await descriptor.result(for: store)

        guard let muestra = resultados.first else { return 0 }

        let bpm = muestra.quantity.doubleValue(
            for: HKUnit.count().unitDivided(by: .minute())
        )

        await MainActor.run {
            self.frecuenciaCardiaca = bpm
        }

        return bpm
    }
}
```

### Escribir Datos — Guardar Muestras

```swift
import HealthKit

// MARK: - Escribir datos en HealthKit

extension GestorSalud {
    func guardarPeso(kilos: Double) async throws {
        let tipoPeso = HKQuantityType(.bodyMass)
        let cantidad = HKQuantity(
            unit: HKUnit.gramUnit(with: .kilo),
            doubleValue: kilos
        )

        let muestra = HKQuantitySample(
            type: tipoPeso,
            quantity: cantidad,
            start: Date(),
            end: Date()
        )

        try await store.save(muestra)
    }

    func guardarPasos(cantidad: Double, inicio: Date, fin: Date) async throws {
        let tipoPasos = HKQuantityType(.stepCount)
        let cantidadHK = HKQuantity(
            unit: HKUnit.count(),
            doubleValue: cantidad
        )

        let muestra = HKQuantitySample(
            type: tipoPasos,
            quantity: cantidadHK,
            start: inicio,
            end: fin
        )

        try await store.save(muestra)
    }

    func guardarCaloriasQuemadas(kcal: Double, inicio: Date, fin: Date) async throws {
        let tipoEnergia = HKQuantityType(.activeEnergyBurned)
        let cantidad = HKQuantity(
            unit: HKUnit.kilocalorie(),
            doubleValue: kcal
        )

        let muestra = HKQuantitySample(
            type: tipoEnergia,
            quantity: cantidad,
            start: inicio,
            end: fin
        )

        try await store.save(muestra)
    }
}
```

### HKStatisticsQuery — Consultas Agregadas

```swift
import HealthKit

// MARK: - Estadisticas por rango de tiempo

extension GestorSalud {
    func pasosPorSemana() async throws -> [(Date, Double)] {
        let tipoPasos = HKQuantityType(.stepCount)
        let calendario = Calendar.current
        let ahora = Date()

        guard let inicioSemana = calendario.date(
            byAdding: .day, value: -7, to: ahora
        ) else { return [] }

        let predicado = HKQuery.predicateForSamples(
            withStart: inicioSemana,
            end: ahora,
            options: .strictStartDate
        )

        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: HKSamplePredicate<HKQuantitySample>(
                sampleType: tipoPasos,
                predicate: predicado
            ),
            options: .cumulativeSum,
            anchorDate: calendario.startOfDay(for: ahora),
            intervalComponents: DateComponents(day: 1)
        )

        let resultados = try await descriptor.result(for: store)
        var pasosPorDia: [(Date, Double)] = []

        resultados.enumerateStatistics(
            from: inicioSemana,
            to: ahora
        ) { estadistica, _ in
            let pasos = estadistica.sumQuantity()?.doubleValue(
                for: HKUnit.count()
            ) ?? 0
            pasosPorDia.append((estadistica.startDate, pasos))
        }

        return pasosPorDia
    }
}
```

### HKObserverQuery — Observar Cambios en Tiempo Real

```swift
import HealthKit

// MARK: - Observar nuevos datos de salud

extension GestorSalud {
    func observarPasos() async {
        let tipoPasos = HKQuantityType(.stepCount)

        let descriptor = HKObserverQueryDescriptor(
            predicate: HKSamplePredicate<HKQuantitySample>(
                sampleType: tipoPasos
            )
        )

        // AsyncSequence — se activa cada vez que hay nuevos pasos
        let observador = descriptor.results(for: store)

        for await _ in observador {
            // Nuevos datos disponibles — recargar
            do {
                let pasos = try await leerPasosHoy()
                print("Pasos actualizados: \(pasos)")
            } catch {
                print("Error al actualizar pasos: \(error)")
            }
        }
    }
}
```

### Workout Sessions

```swift
import HealthKit

// MARK: - Crear y guardar un workout

extension GestorSalud {
    func guardarWorkout(
        tipo: HKWorkoutActivityType,
        inicio: Date,
        fin: Date,
        caloriasQuemadas: Double,
        distanciaMetros: Double?
    ) async throws {
        let configuracion = HKWorkoutConfiguration()
        configuracion.activityType = tipo
        configuracion.locationType = .outdoor

        let builder = HKWorkoutBuilder(
            healthStore: store,
            configuration: configuracion,
            device: .local()
        )

        try await builder.beginCollection(at: inicio)

        // Agregar calorias
        let energiaTipo = HKQuantityType(.activeEnergyBurned)
        let energiaCantidad = HKQuantity(
            unit: .kilocalorie(),
            doubleValue: caloriasQuemadas
        )
        let energiaMuestra = HKQuantitySample(
            type: energiaTipo,
            quantity: energiaCantidad,
            start: inicio,
            end: fin
        )

        try await builder.addSamples([energiaMuestra])

        // Agregar distancia si aplica
        if let distancia = distanciaMetros {
            let distanciaTipo = HKQuantityType(.distanceWalkingRunning)
            let distanciaCantidad = HKQuantity(
                unit: .meter(),
                doubleValue: distancia
            )
            let distanciaMuestra = HKQuantitySample(
                type: distanciaTipo,
                quantity: distanciaCantidad,
                start: inicio,
                end: fin
            )
            try await builder.addSamples([distanciaMuestra])
        }

        try await builder.endCollection(at: fin)
        try await builder.finishWorkout()
    }
}
```

### Vista SwiftUI con HealthKit

```swift
import SwiftUI
import HealthKit

// MARK: - Vista principal de salud

struct VistaSalud: View {
    @State private var gestor = GestorSalud()
    @State private var autorizado = false
    @State private var cargando = false

    var body: some View {
        NavigationStack {
            List {
                Section("Actividad Hoy") {
                    FilaDato(
                        icono: "figure.walk",
                        titulo: "Pasos",
                        valor: "\(Int(gestor.pasosDiarios))",
                        color: .green
                    )
                    FilaDato(
                        icono: "heart.fill",
                        titulo: "Frecuencia Cardiaca",
                        valor: "\(Int(gestor.frecuenciaCardiaca)) BPM",
                        color: .red
                    )
                    FilaDato(
                        icono: "scalemass",
                        titulo: "Peso",
                        valor: String(format: "%.1f kg", gestor.pesoActual),
                        color: .blue
                    )
                }
            }
            .navigationTitle("Mi Salud")
            .task {
                await cargarDatos()
            }
            .refreshable {
                await cargarDatos()
            }
        }
    }

    private func cargarDatos() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        do {
            try await gestor.solicitarAutorizacion()
            _ = try await gestor.leerPasosHoy()
            _ = try await gestor.leerFrecuenciaCardiaca()
        } catch {
            print("Error: \(error)")
        }
    }
}

struct FilaDato: View {
    let icono: String
    let titulo: String
    let valor: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icono)
                .foregroundStyle(color)
                .frame(width: 30)
            Text(titulo)
            Spacer()
            Text(valor)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}
```

---

## Ejercicio 1: Dashboard de Salud (Basico)

**Objetivo**: Crear una vista que muestre datos basicos de HealthKit.

**Requisitos**:
1. Solicitar autorizacion para leer pasos, frecuencia cardiaca y calorias quemadas
2. Mostrar los datos del dia actual en una lista con iconos y colores
3. Manejar el caso donde HealthKit no esta disponible (iPad)
4. Agregar pull-to-refresh para recargar datos

---

## Ejercicio 2: Grafica Semanal de Pasos (Intermedio)

**Objetivo**: Usar HKStatisticsCollectionQuery para obtener datos agregados y mostrarlos en una grafica.

**Requisitos**:
1. Obtener pasos de los ultimos 7 dias usando estadisticas por dia
2. Mostrar los datos en un grafico de barras con Swift Charts
3. Resaltar el dia con mas pasos y el dia actual
4. Calcular el promedio semanal y mostrarlo como linea de referencia
5. Agregar selector de rango: ultima semana, ultimo mes

---

## Ejercicio 3: Registro de Workouts (Avanzado)

**Objetivo**: Implementar un sistema completo de registro y consulta de sesiones de ejercicio.

**Requisitos**:
1. Formulario para registrar workouts con tipo de actividad, duracion, calorias y distancia
2. Guardar workouts usando HKWorkoutBuilder
3. Listar workouts previos ordenados por fecha con filtro por tipo de actividad
4. Usar HKObserverQuery para detectar nuevos workouts registrados desde Apple Watch
5. Mostrar estadisticas mensuales: total calorias, total distancia, numero de sesiones

---

## 5 Errores Comunes

### 1. No verificar disponibilidad de HealthKit

```swift
// MAL — asumir que HealthKit siempre esta disponible
let store = HKHealthStore()
try await store.requestAuthorization(toShare: tipos, read: tipos)
// Crashea en iPad, Mac Catalyst sin soporte

// BIEN — verificar primero
guard HKHealthStore.isHealthDataAvailable() else {
    print("HealthKit no disponible en este dispositivo")
    return
}
let store = HKHealthStore()
```

### 2. Pedir demasiados permisos de golpe

```swift
// MAL — pedir todo al abrir la app
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    // 20 tipos de datos de salud en la primera pantalla
    // El usuario se asusta y deniega todo
}

// BIEN — pedir cuando se necesita, con contexto
// En la pantalla de pasos, pedir solo stepCount
// En la pantalla de nutricion, pedir solo dietaryEnergyConsumed
func abrirSeccionPasos() async throws {
    let soloLectura: Set<HKObjectType> = [HKQuantityType(.stepCount)]
    try await store.requestAuthorization(toShare: [], read: soloLectura)
}
```

### 3. Usar unidades incorrectas

```swift
// MAL — asumir la unidad
let bpm = muestra.quantity.doubleValue(for: HKUnit.count())
// heartRate usa count/minute, no count

// BIEN — usar la unidad correcta para cada tipo
let bpm = muestra.quantity.doubleValue(
    for: HKUnit.count().unitDivided(by: .minute())
)
// Peso: HKUnit.gramUnit(with: .kilo) o .pound()
// Distancia: HKUnit.meter() o .mile()
// Energia: HKUnit.kilocalorie()
```

### 4. No manejar la falta de datos

```swift
// MAL — asumir que siempre hay resultados
let resultado = try await descriptor.result(for: store)
let pasos = resultado.sumQuantity()!.doubleValue(for: .count())
// Force unwrap crashea si no hay datos

// BIEN — manejar nil correctamente
let resultado = try await descriptor.result(for: store)
let pasos = resultado?.sumQuantity()?.doubleValue(
    for: HKUnit.count()
) ?? 0
```

### 5. Ignorar que la autorizacion de lectura es opaca

```swift
// MAL — intentar verificar si el usuario denego lectura
let status = store.authorizationStatus(for: HKQuantityType(.heartRate))
if status == .sharingDenied {
    // Esto es para ESCRITURA, no lectura
    // Para lectura, HealthKit simplemente devuelve 0 resultados
}

// BIEN — asumir que si no hay datos, puede ser que no haya permiso
let resultados = try await descriptor.result(for: store)
if resultados.isEmpty {
    // Puede ser que no hay datos O que el usuario denego acceso
    // Mostrar mensaje generico, no acusar al usuario
    print("No hay datos disponibles. Verifica permisos en Ajustes > Salud.")
}
```

---

## Checklist

- [ ] Verificar disponibilidad con HKHealthStore.isHealthDataAvailable()
- [ ] Solicitar autorizacion granular con requestAuthorization(toShare:read:)
- [ ] Leer HKQuantitySample con HKSampleQueryDescriptor
- [ ] Escribir muestras con HKQuantitySample y store.save()
- [ ] Usar HKStatisticsQuery para datos agregados (suma, promedio)
- [ ] Usar HKStatisticsCollectionQuery para series de tiempo
- [ ] Implementar HKObserverQuery para actualizaciones en tiempo real
- [ ] Crear y guardar workouts con HKWorkoutBuilder
- [ ] Manejar correctamente unidades (HKUnit) para cada tipo de dato
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

HealthKit puede ser un pilar central de tu app si incluye funcionalidad de salud o fitness:
- **Dashboard de salud** con datos en tiempo real del Apple Watch
- **Graficas con Swift Charts** mostrando tendencias semanales/mensuales de actividad
- **Registro de workouts** que se sincronizan entre iPhone y Apple Watch
- **SwiftData + HealthKit** para combinar datos locales con datos de salud del sistema
- **Widgets** que muestran pasos del dia o resumen de actividad usando App Intents
- **Notificaciones** basadas en objetivos de salud alcanzados

---

*Leccion 22 | HealthKit | Semanas 27-28 | Modulo 05: Hardware y Sensores*
*Siguiente: Leccion 23 — Location y Maps*
