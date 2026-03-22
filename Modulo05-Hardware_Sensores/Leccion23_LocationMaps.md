# Leccion 23: Location y Maps

**Modulo 05: Hardware y Sensores** | Semana 29

---

## TL;DR — Resumen en 2 minutos

- **CLLocationManager**: Gestiona permisos y actualizaciones de ubicacion — siempre pedir autorizacion antes de acceder
- **Map en SwiftUI**: Vista nativa para mapas interactivos con soporte para anotaciones, rutas y camaras personalizadas
- **Annotation y Marker**: Marcar puntos de interes en el mapa con vistas SwiftUI personalizadas
- **Geofencing**: Detectar cuando el usuario entra o sale de una region geografica sin consumir bateria constantemente
- **MapCamera y MKRoute**: Controlar la perspectiva del mapa y calcular rutas entre dos puntos

---

## Cupertino MCP

```bash
cupertino search "MapKit SwiftUI"
cupertino search "Core Location"
cupertino search "CLLocationManager"
cupertino search "Map SwiftUI"
cupertino search "MapCamera"
cupertino search "MKRoute"
cupertino search "CLMonitor"
cupertino search --source samples "MapKit"
cupertino search --source hig "maps"
cupertino search --source updates "MapKit"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC24 | [What's new in MapKit](https://developer.apple.com/videos/play/wwdc2024/10094/) | Novedades recientes |
| WWDC23 | [Meet MapKit for SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10043/) | **Esencial** — API moderna |
| WWDC23 | [Discover Observation in Swift](https://developer.apple.com/videos/play/wwdc2023/10149/) | Patron para Location |
| WWDC22 | [What's new in MapKit](https://developer.apple.com/videos/play/wwdc2022/10035/) | Fundamentos |
| WWDC20 | [What's new in location](https://developer.apple.com/videos/play/wwdc2020/10660/) | Precision y autorizacion |
| :es: | [Julio Cesar Fernandez — MapKit](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que CoreLocation + MapKit?

La ubicacion es uno de los superpoderes del iPhone. Pero con ese poder viene una gran responsabilidad: **la privacidad del usuario**. Apple ha iterado agresivamente en el modelo de permisos de ubicacion, pasando de un simple "permitir/denegar" a un sistema con precision aproximada, permisos temporales y autorizacion condicional.

MapKit para SwiftUI (introducido en WWDC 2023) reemplaza completamente la necesidad de usar MKMapView con UIViewRepresentable. Ahora tienes una API declarativa, type-safe y que se integra naturalmente con el resto de SwiftUI.

```
  ┌──────────────────────────────────────────────────────────┐
  │             STACK DE UBICACION Y MAPAS                   │
  ├──────────────────────────────────────────────────────────┤
  │                                                          │
  │   ┌──────────────────────────────────────┐               │
  │   │           SwiftUI View               │               │
  │   │   Map { Annotation, Marker, Route }  │               │
  │   └──────────────┬───────────────────────┘               │
  │                  │                                       │
  │   ┌──────────────▼───────────────────────┐               │
  │   │           MapKit                     │               │
  │   │   MapCamera, MKRoute, MKDirections   │               │
  │   └──────────────┬───────────────────────┘               │
  │                  │                                       │
  │   ┌──────────────▼───────────────────────┐               │
  │   │        Core Location                 │               │
  │   │  CLLocationManager, CLMonitor        │               │
  │   │  GPS, Wi-Fi, Cell, Bluetooth         │               │
  │   └──────────────────────────────────────┘               │
  └──────────────────────────────────────────────────────────┘
```

### CLLocationManager — Obtener Ubicacion

El primer paso siempre es pedir permiso. CoreLocation tiene varios niveles de autorizacion:

- **When In Use**: La app accede a ubicacion solo mientras esta en primer plano
- **Always**: La app accede a ubicacion en segundo plano (geofencing, tracking)
- **Precision reducida**: El usuario puede dar ubicacion aproximada (~5km) en vez de exacta

```swift
import CoreLocation

// MARK: - Gestor de ubicacion con @Observable

@Observable
class GestorUbicacion: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var ubicacionActual: CLLocation?
    var estadoAutorizacion: CLAuthorizationStatus = .notDetermined
    var errorMensaje: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Solicitar permiso
    func solicitarPermiso() {
        manager.requestWhenInUseAuthorization()
    }

    func solicitarPermisoSiempre() {
        manager.requestAlwaysAuthorization()
    }

    // MARK: - Iniciar/Detener actualizaciones
    func iniciarActualizaciones() {
        manager.startUpdatingLocation()
    }

    func detenerActualizaciones() {
        manager.stopUpdatingLocation()
    }

    // MARK: - Una sola ubicacion (mas eficiente)
    func obtenerUbicacionUnica() {
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        ubicacionActual = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        estadoAutorizacion = manager.authorizationStatus
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        errorMensaje = error.localizedDescription
    }
}
```

### Info.plist — Permisos Obligatorios

Sin estas claves, la app crashea al pedir permisos:

```xml
<!-- Para "When In Use" -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicacion para mostrarte lugares cercanos.</string>

<!-- Para "Always" (requiere tambien When In Use) -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos ubicacion en segundo plano para notificarte al llegar a tus lugares favoritos.</string>
```

### Map en SwiftUI — Mapas Declarativos

```swift
import SwiftUI
import MapKit

// MARK: - Mapa basico con posicion controlada

struct VistaMapa: View {
    @State private var posicionCamara: MapCameraPosition = .automatic
    @State private var gestor = GestorUbicacion()

    var body: some View {
        Map(position: $posicionCamara) {
            // Mostrar ubicacion del usuario
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
        .mapStyle(.standard(elevation: .realistic))
        .onAppear {
            gestor.solicitarPermiso()
        }
    }
}
```

### Annotations y Markers — Marcar Puntos de Interes

```swift
import SwiftUI
import MapKit

// MARK: - Modelo de lugar

struct Lugar: Identifiable {
    let id = UUID()
    let nombre: String
    let descripcion: String
    let coordenada: CLLocationCoordinate2D
    let categoria: Categoria

    enum Categoria: String, CaseIterable {
        case restaurante = "fork.knife"
        case cafe = "cup.and.saucer.fill"
        case tienda = "bag.fill"
        case parque = "leaf.fill"
    }
}

// MARK: - Mapa con anotaciones

struct MapaConLugares: View {
    @State private var posicion: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var lugarSeleccionado: Lugar?

    let lugares: [Lugar] = [
        Lugar(
            nombre: "Restaurante La Barraca",
            descripcion: "Paella valenciana autentica",
            coordenada: CLLocationCoordinate2D(latitude: 40.4200, longitude: -3.7050),
            categoria: .restaurante
        ),
        Lugar(
            nombre: "Cafe Central",
            descripcion: "Mejor cafe de la ciudad",
            coordenada: CLLocationCoordinate2D(latitude: 40.4150, longitude: -3.7000),
            categoria: .cafe
        ),
        Lugar(
            nombre: "Retiro",
            descripcion: "Parque historico",
            coordenada: CLLocationCoordinate2D(latitude: 40.4153, longitude: -3.6844),
            categoria: .parque
        )
    ]

    var body: some View {
        Map(position: $posicion, selection: $lugarSeleccionado) {
            ForEach(lugares) { lugar in
                // Marker simple con icono del sistema
                Marker(
                    lugar.nombre,
                    systemImage: lugar.categoria.rawValue,
                    coordinate: lugar.coordenada
                )
                .tint(colorParaCategoria(lugar.categoria))
            }
        }
        .mapStyle(.standard(pointsOfInterest: .including([.restaurant, .cafe])))
        .sheet(item: $lugarSeleccionado) { lugar in
            DetalleLugar(lugar: lugar)
                .presentationDetents([.medium])
        }
    }

    private func colorParaCategoria(_ categoria: Lugar.Categoria) -> Color {
        switch categoria {
        case .restaurante: return .orange
        case .cafe: return .brown
        case .tienda: return .purple
        case .parque: return .green
        }
    }
}

struct DetalleLugar: View {
    let lugar: Lugar

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(lugar.nombre, systemImage: lugar.categoria.rawValue)
                .font(.title2.bold())
            Text(lugar.descripcion)
                .foregroundStyle(.secondary)
            Text("Lat: \(lugar.coordenada.latitude, specifier: "%.4f"), Lon: \(lugar.coordenada.longitude, specifier: "%.4f")")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}
```

### Annotation Personalizada — Vistas SwiftUI en el Mapa

```swift
import SwiftUI
import MapKit

// MARK: - Anotaciones con vista personalizada

struct MapaConAnotacionesPersonalizadas: View {
    @State private var posicion: MapCameraPosition = .automatic

    let lugares: [Lugar] // Reutilizar del ejemplo anterior

    var body: some View {
        Map(position: $posicion) {
            ForEach(lugares) { lugar in
                Annotation(
                    lugar.nombre,
                    coordinate: lugar.coordenada,
                    anchor: .bottom
                ) {
                    VStack(spacing: 0) {
                        Image(systemName: lugar.categoria.rawValue)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Circle().fill(.blue.gradient))
                            .shadow(radius: 4)

                        Image(systemName: "triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                            .rotationEffect(.degrees(180))
                            .offset(y: -4)
                    }
                }
            }
        }
    }
}
```

### MKRoute — Calcular Rutas

```swift
import MapKit

// MARK: - Calcular ruta entre dos puntos

@Observable
class GestorRutas {
    var ruta: MKRoute?
    var tiempoEstimado: TimeInterval = 0
    var distanciaMetros: Double = 0
    var calculando = false

    func calcularRuta(
        desde origen: CLLocationCoordinate2D,
        hasta destino: CLLocationCoordinate2D,
        transporte: MKDirectionsTransportType = .automobile
    ) async throws {
        calculando = true
        defer { calculando = false }

        let solicitud = MKDirections.Request()
        solicitud.source = MKMapItem(
            placemark: MKPlacemark(coordinate: origen)
        )
        solicitud.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: destino)
        )
        solicitud.transportType = transporte

        let direcciones = MKDirections(request: solicitud)
        let respuesta = try await direcciones.calculate()

        guard let rutaPrincipal = respuesta.routes.first else { return }

        ruta = rutaPrincipal
        tiempoEstimado = rutaPrincipal.expectedTravelTime
        distanciaMetros = rutaPrincipal.distance
    }
}

// MARK: - Mostrar ruta en el mapa

struct MapaConRuta: View {
    @State private var posicion: MapCameraPosition = .automatic
    @State private var gestorRutas = GestorRutas()

    let origen = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
    let destino = CLLocationCoordinate2D(latitude: 40.4531, longitude: -3.6883)

    var body: some View {
        VStack {
            Map(position: $posicion) {
                Marker("Origen", coordinate: origen)
                    .tint(.green)
                Marker("Destino", coordinate: destino)
                    .tint(.red)

                if let ruta = gestorRutas.ruta {
                    MapPolyline(ruta.polyline)
                        .stroke(.blue, lineWidth: 5)
                }
            }

            if gestorRutas.calculando {
                ProgressView("Calculando ruta...")
            } else if let _ = gestorRutas.ruta {
                HStack {
                    Label(
                        formatearTiempo(gestorRutas.tiempoEstimado),
                        systemImage: "clock"
                    )
                    Spacer()
                    Label(
                        formatearDistancia(gestorRutas.distanciaMetros),
                        systemImage: "car"
                    )
                }
                .padding()
            }
        }
        .task {
            try? await gestorRutas.calcularRuta(
                desde: origen,
                hasta: destino
            )
        }
    }

    private func formatearTiempo(_ segundos: TimeInterval) -> String {
        let minutos = Int(segundos) / 60
        return "\(minutos) min"
    }

    private func formatearDistancia(_ metros: Double) -> String {
        if metros >= 1000 {
            return String(format: "%.1f km", metros / 1000)
        }
        return "\(Int(metros)) m"
    }
}
```

### MapCamera — Control de la Perspectiva

```swift
import SwiftUI
import MapKit

// MARK: - Control avanzado de camara

struct MapaCamara: View {
    @State private var posicion: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(
                latitude: 40.4168,
                longitude: -3.7038
            ),
            distance: 1000,    // metros desde el centro
            heading: 45,       // orientacion en grados
            pitch: 60          // angulo de inclinacion (3D)
        )
    )

    var body: some View {
        Map(position: $posicion)
            .mapStyle(.standard(elevation: .realistic))
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button("Vista Cenital") {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            posicion = .camera(MapCamera(
                                centerCoordinate: CLLocationCoordinate2D(
                                    latitude: 40.4168, longitude: -3.7038
                                ),
                                distance: 5000,
                                heading: 0,
                                pitch: 0
                            ))
                        }
                    }

                    Button("Vista 3D") {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            posicion = .camera(MapCamera(
                                centerCoordinate: CLLocationCoordinate2D(
                                    latitude: 40.4168, longitude: -3.7038
                                ),
                                distance: 800,
                                heading: 90,
                                pitch: 70
                            ))
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
    }
}
```

### Geofencing — Regiones Monitoreadas

```swift
import CoreLocation

// MARK: - Geofencing con CLMonitor (iOS 17+)

extension GestorUbicacion {
    func iniciarGeofencing() async {
        let monitor = await CLMonitor("mis-geofences")

        // Agregar region a monitorear
        let condicion = CLMonitor.CircularGeographicCondition(
            center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            radius: 200  // metros
        )

        await monitor.add(condicion, identifier: "oficina")

        // Escuchar eventos
        for try await evento in await monitor.events {
            switch evento.state {
            case .satisfied:
                print("Entraste a: \(evento.identifier)")
                // Enviar notificacion local
            case .unsatisfied:
                print("Saliste de: \(evento.identifier)")
            case .unknown:
                break
            default:
                break
            }
        }
    }

    func detenerGeofencing() async {
        let monitor = await CLMonitor("mis-geofences")
        await monitor.remove("oficina")
    }
}
```

### Busqueda de Lugares — MKLocalSearch

```swift
import MapKit

// MARK: - Buscar lugares cercanos

@Observable
class BuscadorLugares {
    var resultados: [MKMapItem] = []
    var buscando = false

    func buscar(texto: String, en region: MKCoordinateRegion) async throws {
        buscando = true
        defer { buscando = false }

        let solicitud = MKLocalSearch.Request()
        solicitud.naturalLanguageQuery = texto
        solicitud.region = region
        solicitud.resultTypes = .pointOfInterest

        let busqueda = MKLocalSearch(request: solicitud)
        let respuesta = try await busqueda.start()

        resultados = respuesta.mapItems
    }
}
```

---

## Ejercicio 1: Mapa con Ubicacion del Usuario (Basico)

**Objetivo**: Crear un mapa interactivo que muestre la ubicacion actual del usuario.

**Requisitos**:
1. Solicitar permiso de ubicacion "When In Use"
2. Mostrar un Map con UserAnnotation y controles de mapa
3. Boton para centrar el mapa en la ubicacion actual del usuario
4. Mostrar coordenadas actuales (latitud, longitud) en un overlay inferior

---

## Ejercicio 2: Buscador de Lugares con Rutas (Intermedio)

**Objetivo**: Implementar busqueda de lugares y calculo de rutas.

**Requisitos**:
1. Campo de busqueda que use MKLocalSearch para encontrar lugares
2. Mostrar resultados como Markers en el mapa con colores por categoria
3. Al seleccionar un lugar, calcular ruta desde la ubicacion del usuario con MKDirections
4. Mostrar la ruta en el mapa con MapPolyline y panel con tiempo/distancia estimados
5. Selector de tipo de transporte (auto, caminando, transporte publico)

---

## Ejercicio 3: Sistema de Geofencing con Notificaciones (Avanzado)

**Objetivo**: Crear un sistema completo de geofences con notificaciones y persistencia.

**Requisitos**:
1. Permitir al usuario marcar puntos en el mapa con long press para crear geofences
2. Usar CLMonitor para monitorear entrada/salida de regiones
3. Enviar notificacion local al entrar o salir de una geofence
4. Guardar las geofences en SwiftData para persistencia
5. Visualizar las geofences como circulos semitransparentes en el mapa con MapCircle

---

## 5 Errores Comunes

### 1. No agregar las claves en Info.plist

```swift
// MAL — pedir permiso sin descripcion de uso
manager.requestWhenInUseAuthorization()
// La app crashea inmediatamente con:
// "NSLocationWhenInUseUsageDescription key must be present in Info.plist"

// BIEN — agregar en Info.plist ANTES de pedir permiso
// NSLocationWhenInUseUsageDescription = "Necesitamos tu ubicacion para..."
// Explicar CLARAMENTE por que necesitas la ubicacion
```

### 2. Usar startUpdatingLocation cuando no es necesario

```swift
// MAL — actualizaciones continuas para mostrar una sola vez
manager.startUpdatingLocation()
// Consume bateria constantemente

// BIEN — una sola peticion si solo necesitas la ubicacion actual
manager.requestLocation()
// Un solo callback y se detiene automaticamente

// O usar startUpdatingLocation SOLO si necesitas tracking continuo
// y siempre llamar stopUpdatingLocation al terminar
```

### 3. No manejar precision reducida

```swift
// MAL — asumir que siempre tienes ubicacion precisa
let ubicacion = manager.location!
mostrarEnMapa(lat: ubicacion.coordinate.latitude, lon: ubicacion.coordinate.longitude)
// En iOS 14+ el usuario puede dar precision reducida (~5km)

// BIEN — verificar nivel de precision
switch manager.accuracyAuthorization {
case .fullAccuracy:
    // Ubicacion precisa disponible
    mostrarPuntoExacto(ubicacion)
case .reducedAccuracy:
    // Solo ubicacion aproximada
    mostrarAreaGeneral(ubicacion)
    // Opcionalmente pedir precision temporal
    manager.requestTemporaryFullAccuracyAuthorization(
        withPurposeKey: "NavigationAccuracy"
    )
@unknown default:
    break
}
```

### 4. Crear multiples instancias de CLLocationManager

```swift
// MAL — un manager por vista
struct VistaA: View {
    let manager = CLLocationManager()  // Instancia 1
}
struct VistaB: View {
    let manager = CLLocationManager()  // Instancia 2 — conflicto
}

// BIEN — un unico gestor compartido
@Observable
class GestorUbicacion: NSObject, CLLocationManagerDelegate {
    static let compartido = GestorUbicacion()
    private let manager = CLLocationManager()
    // ...
}
```

### 5. Ignorar el estado de autorizacion al navegar

```swift
// MAL — mostrar el mapa sin verificar permisos
struct VistaMapa: View {
    var body: some View {
        Map { UserAnnotation() }
        // No muestra nada si no hay permiso
    }
}

// BIEN — verificar estado y guiar al usuario
struct VistaMapa: View {
    @State private var gestor = GestorUbicacion()

    var body: some View {
        Group {
            switch gestor.estadoAutorizacion {
            case .notDetermined:
                VistaPermisoUbicacion(gestor: gestor)
            case .denied, .restricted:
                VistaSinPermiso()
            case .authorizedWhenInUse, .authorizedAlways:
                Map { UserAnnotation() }
            @unknown default:
                EmptyView()
            }
        }
    }
}
```

---

## Checklist

- [ ] Solicitar permiso de ubicacion con CLLocationManager y manejar todos los estados
- [ ] Configurar Info.plist con NSLocationWhenInUseUsageDescription
- [ ] Mostrar Map en SwiftUI con UserAnnotation y controles
- [ ] Agregar Marker y Annotation con datos personalizados
- [ ] Calcular rutas con MKDirections y mostrar con MapPolyline
- [ ] Controlar la camara del mapa con MapCamera y animaciones
- [ ] Implementar busqueda de lugares con MKLocalSearch
- [ ] Configurar geofencing con CLMonitor
- [ ] Manejar precision reducida y solicitar precision temporal
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Location y Maps pueden aportar funcionalidades clave a tu app:
- **Mapa interactivo** como pantalla principal o secundaria para explorar contenido geolocalizado
- **Geofencing** para disparar acciones automaticas al entrar/salir de zonas relevantes
- **Rutas y navegacion** entre puntos de interes guardados en SwiftData
- **Busqueda de lugares** integrada con la experiencia de usuario
- **Widget con mapa** mostrando ubicacion o destino usando App Intents
- **HealthKit + Location** para trackear rutas de ejercicio con distancia y elevacion

---

*Leccion 23 | Location y Maps | Semana 29 | Modulo 05: Hardware y Sensores*
*Siguiente: Leccion 24 — Camera y Photos*
