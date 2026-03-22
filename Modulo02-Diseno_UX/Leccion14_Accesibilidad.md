# Leccion 14: Accesibilidad

**Modulo 02: Diseno y UX** | Semana 16

---

## TL;DR — Resumen en 2 minutos

- **VoiceOver**: lee tu app en voz alta para personas con discapacidad visual — sin `.accessibilityLabel` tus botones dicen "boton" y nada mas
- **Dynamic Type**: el usuario elige el tamano de texto en Configuracion — si usas `.font(.body)` lo tienes gratis, si usas `.font(.system(size: 17))` lo pierdes
- **Accessibility Modifiers**: `.accessibilityLabel`, `.accessibilityHint`, `.accessibilityValue` describen tu UI para tecnologias asistivas
- **Accesibilidad no es opcional**: en muchos paises es requisito legal, y el 15% de la poblacion mundial tiene alguna discapacidad
- **Accessibility Inspector**: herramienta de Xcode que audita tu app y encuentra problemas automaticamente

> Regla: **si no puedes usar tu app con los ojos cerrados, tu app no es accesible**.

---

## Cupertino MCP

```bash
cupertino search --source hig "accessibility"
cupertino search "accessibilityLabel"
cupertino search "accessibilityHint"
cupertino search "VoiceOver SwiftUI"
cupertino search "Dynamic Type"
cupertino search "AccessibilityTraits"
cupertino search "accessibilityValue"
cupertino search "AXCustomContent"
cupertino search --source hig "color contrast"
cupertino search --source hig "motion"
cupertino search "AccessibilityNotification"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | Build accessible experiences | **Esencial** — Novedades accesibilidad |
| WWDC24 | [Catch up on accessibility in SwiftUI](https://developer.apple.com/videos/play/wwdc2024/) | **Esencial** — Resumen completo |
| WWDC23 | [Perform accessibility audits for your app](https://developer.apple.com/videos/play/wwdc2023/10035/) | Auditorias automaticas |
| WWDC22 | [SwiftUI Accessibility](https://developer.apple.com/videos/play/wwdc2022/) | Fundamentos |
| EN | [Paul Hudson — Accessibility](https://www.hackingwithswift.com/books/ios-swiftui/accessibility) | Tutorial paso a paso |
| EN | [Rob Whitaker — A11y is for Everyone](https://mobilea11y.com/) | Perspectiva practica |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que accesibilidad?

Hay tres razones para hacer tu app accesible, y ninguna es "porque Apple lo dice":

**1. Etica** — El 15% de la poblacion mundial (mas de mil millones de personas) vive con alguna discapacidad. Construir una app que excluye a estas personas es como construir un edificio sin rampa.

**2. Legal** — En EE.UU. (ADA), Europa (EAA 2025) y muchos otros paises, la accesibilidad digital es un requisito legal. Empresas han sido demandadas por apps inaccesibles.

**3. Negocio** — Accesibilidad mejora la UX para TODOS. Un boton con buen contraste es mas facil de leer al sol. Los subtitulos ayudan en ambientes ruidosos. El texto grande ayuda a personas con fatiga visual. Mas usuarios = mas ingresos.

```
  ┌─────────────────────────────────────────────────────────┐
  │            TECNOLOGIAS ASISTIVAS EN iOS                  │
  │                                                          │
  │  VISION                                                  │
  │  ├─ VoiceOver: lector de pantalla                        │
  │  ├─ Dynamic Type: texto mas grande                       │
  │  ├─ Bold Text: texto en negrita                          │
  │  ├─ Increase Contrast: mayor contraste                   │
  │  └─ Reduce Transparency: menos transparencias            │
  │                                                          │
  │  MOTOR                                                   │
  │  ├─ Switch Control: control por interruptores            │
  │  ├─ Voice Control: control por voz                       │
  │  └─ AssistiveTouch: boton virtual                        │
  │                                                          │
  │  AUDITIVO                                                │
  │  ├─ Subtitulos y Closed Captions                         │
  │  └─ Haptics: retroalimentacion tactil                    │
  │                                                          │
  │  COGNITIVO                                               │
  │  ├─ Guided Access: limitar interacciones                 │
  │  ├─ Reduce Motion: menos animaciones                     │
  │  └─ Per-App Settings: configuracion individual           │
  └─────────────────────────────────────────────────────────┘
```

### VoiceOver — El Lector de Pantalla

VoiceOver es la tecnologia asistiva mas importante de iOS. Lee en voz alta cada elemento de la UI cuando el usuario lo toca. Para que VoiceOver funcione bien, necesita tres cosas de cada elemento:

1. **Label**: Que ES este elemento (nombre)
2. **Value**: Que VALOR tiene actualmente (estado)
3. **Hint**: Que PASA si interactuo con el (accion)

```swift
import SwiftUI

// MARK: - VoiceOver Basico

struct VoiceOverBasicoDemo: View {
    @State private var calificacion = 3
    @State private var esFavorito = false

    var body: some View {
        VStack(spacing: 32) {
            // SwiftUI genera labels automaticos para controles estandar
            // Text, Button con texto, Toggle — funcionan sin codigo extra
            Text("Bienvenido a la app")
            // VoiceOver lee: "Bienvenido a la app, texto"

            Button("Guardar cambios") {
                // accion
            }
            // VoiceOver lee: "Guardar cambios, boton"

            Toggle("Modo oscuro", isOn: $esFavorito)
            // VoiceOver lee: "Modo oscuro, interruptor, desactivado"

            Divider()

            // PROBLEMA: Botones con solo icono — VoiceOver no sabe que son
            // MAL: VoiceOver lee "boton" sin mas informacion
            Button {
                esFavorito.toggle()
            } label: {
                Image(systemName: esFavorito ? "heart.fill" : "heart")
                    .font(.largeTitle)
                    .foregroundStyle(esFavorito ? .red : .gray)
            }
            // SIN label, VoiceOver dice: "heart fill, boton" — confuso

            // BIEN: Con accessibilityLabel
            Button {
                esFavorito.toggle()
            } label: {
                Image(systemName: esFavorito ? "heart.fill" : "heart")
                    .font(.largeTitle)
                    .foregroundStyle(esFavorito ? .red : .gray)
            }
            .accessibilityLabel("Favorito")
            .accessibilityValue(esFavorito ? "marcado" : "no marcado")
            .accessibilityHint("Toca dos veces para cambiar")
            // VoiceOver dice: "Favorito, no marcado, boton. Toca dos veces para cambiar"

            // Sistema de calificacion con estrellas
            HStack {
                ForEach(1...5, id: \.self) { estrella in
                    Image(systemName: estrella <= calificacion
                        ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .onTapGesture { calificacion = estrella }
                }
            }
            .font(.title)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Calificacion")
            .accessibilityValue("\(calificacion) de 5 estrellas")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    calificacion = min(5, calificacion + 1)
                case .decrement:
                    calificacion = max(1, calificacion - 1)
                @unknown default:
                    break
                }
            }
            // VoiceOver: "Calificacion, 3 de 5 estrellas, ajustable"
        }
        .padding()
    }
}
```

### Accessibility Modifiers — Referencia Completa

```swift
import SwiftUI

// MARK: - Accessibility Modifiers

struct AccessibilityModifiersDemo: View {
    @State private var progreso = 0.65
    @State private var volumen = 0.5
    @State private var mensajesNoLeidos = 3

    var body: some View {
        VStack(spacing: 24) {

            // MARK: - accessibilityLabel
            // Describe QUE es el elemento
            Image(systemName: "envelope.badge")
                .font(.largeTitle)
                .accessibilityLabel("Bandeja de entrada")

            // MARK: - accessibilityValue
            // Describe el ESTADO actual
            Image(systemName: "envelope.badge")
                .font(.largeTitle)
                .accessibilityLabel("Bandeja de entrada")
                .accessibilityValue("\(mensajesNoLeidos) mensajes no leidos")

            // MARK: - accessibilityHint
            // Describe que PASA al interactuar (opcional pero util)
            Button { } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title)
            }
            .accessibilityLabel("Compartir")
            .accessibilityHint("Abre opciones para compartir este articulo")

            // MARK: - accessibilityAddTraits / accessibilityRemoveTraits
            // Define el TIPO de elemento
            Text("Seccion: Noticias")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
                // VoiceOver anuncia "encabezado" — permite navegar entre secciones

            Image("banner-promo")
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Promocion de verano")
                .accessibilityHint("Toca para ver detalles")

            // MARK: - accessibilityElement
            // Combinar o ignorar hijos
            HStack {
                Image(systemName: "thermometer.medium")
                Text("24°C")
                Text("Soleado")
            }
            .accessibilityElement(children: .combine)
            // VoiceOver lee todo junto: "thermometer medium, 24 grados C, Soleado"

            // Mejor: ignorar hijos y dar un label claro
            HStack {
                Image(systemName: "thermometer.medium")
                Text("24°C")
                Text("Soleado")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Temperatura actual: 24 grados, cielo soleado")

            // MARK: - accessibilityHidden
            // Ocultar elementos decorativos
            Image(systemName: "sparkles")
                .accessibilityHidden(true)
                // VoiceOver ignora este elemento completamente

            // MARK: - Barra de progreso custom
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.3))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.blue)
                        .frame(width: geo.size.width * progreso)
                }
            }
            .frame(height: 8)
            .accessibilityLabel("Progreso de descarga")
            .accessibilityValue("\(Int(progreso * 100)) por ciento")
        }
        .padding()
    }
}
```

### Dynamic Type — Texto que se Adapta

Dynamic Type permite al usuario elegir el tamano de texto que prefiere. Tu responsabilidad es respetar esa preferencia:

```swift
import SwiftUI

// MARK: - Dynamic Type

struct DynamicTypeDemo: View {
    @Environment(\.dynamicTypeSize) var tamanoTexto

    var body: some View {
        VStack(spacing: 16) {
            // BIEN: Usa estilos semanticos — respeta Dynamic Type
            Text("Titulo de Seccion")
                .font(.title2)

            Text("Este texto se adapta al tamano que el usuario eligio.")
                .font(.body)

            Text("Nota al pie con mas informacion")
                .font(.caption)

            // Para layouts que pueden romperse con texto grande
            if tamanoTexto.isAccessibilitySize {
                // Layout vertical para tamanos de accesibilidad
                VStack(alignment: .leading) {
                    etiquetaValor("Nombre", "Carlos Lopez")
                    etiquetaValor("Email", "carlos@ejemplo.com")
                }
            } else {
                // Layout horizontal para tamanos normales
                HStack {
                    etiquetaValor("Nombre", "Carlos Lopez")
                    Spacer()
                    etiquetaValor("Email", "carlos@ejemplo.com")
                }
            }

            // Limitar tamano maximo cuando es necesario
            Text("Este texto tiene un maximo")
                .font(.body)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                // No crece mas alla de xxxLarge

            // Escalar imagenes con texto
            Label("Configuracion", systemImage: "gear")
                .font(.body)
                // SF Symbols escalan automaticamente con Dynamic Type
        }
        .padding()
    }

    func etiquetaValor(_ etiqueta: String, _ valor: String) -> some View {
        VStack(alignment: .leading) {
            Text(etiqueta)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(valor)
                .font(.body)
        }
    }
}
```

### Contraste y Color

El color nunca debe ser el unico indicador de informacion:

```swift
import SwiftUI

// MARK: - Contraste y Color Accesible

struct ContrasteDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            // MAL: Solo color indica el estado
            HStack(spacing: 12) {
                Circle().fill(.green).frame(width: 12, height: 12)
                Text("Servidor activo")
                // Una persona con daltonismo no distingue verde de rojo
            }

            // BIEN: Color + icono + texto indican el estado
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Servidor activo")
                    .bold()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Estado del servidor: activo")

            // MAL: Texto gris claro sobre fondo blanco — bajo contraste
            Text("Texto poco legible")
                .foregroundColor(.gray.opacity(0.3))

            // BIEN: Contraste suficiente (ratio minimo 4.5:1)
            Text("Texto legible")
                .foregroundStyle(.secondary)

            // BIEN: Usar colores semanticos que Apple ya verifico
            Text("Texto principal").foregroundStyle(.primary)
            Text("Texto secundario").foregroundStyle(.secondary)
            Text("Texto terciario").foregroundStyle(.tertiary)

            // Respetar "Increase Contrast"
            // Los colores semanticos lo manejan automaticamente
        }
        .padding()
    }
}
```

### Reduced Motion — Respetar Preferencias de Movimiento

Algunas personas sufren mareos o nauseas con animaciones excesivas:

```swift
import SwiftUI

// MARK: - Reduced Motion

struct ReducedMotionDemo: View {
    @Environment(\.accessibilityReduceMotion) var reducirMovimiento
    @State private var estaExpandido = false

    var body: some View {
        VStack(spacing: 24) {
            Button("Expandir") {
                if reducirMovimiento {
                    // Sin animacion — cambio instantaneo
                    estaExpandido.toggle()
                } else {
                    // Con animacion
                    withAnimation(.spring(duration: 0.5)) {
                        estaExpandido.toggle()
                    }
                }
            }

            RoundedRectangle(cornerRadius: 16)
                .fill(.blue)
                .frame(
                    width: estaExpandido ? 300 : 100,
                    height: estaExpandido ? 200 : 100
                )

            // Alternativa mas limpia con transaction
            Button("Expandir (v2)") {
                withAnimation(reducirMovimiento ? nil : .spring()) {
                    estaExpandido.toggle()
                }
            }
        }
    }
}
```

### Accessibility Inspector y Auditorias

Xcode incluye una herramienta para auditar la accesibilidad de tu app:

```
  ┌─────────────────────────────────────────────────────────┐
  │          ACCESSIBILITY INSPECTOR                         │
  │                                                          │
  │  Como abrirlo:                                           │
  │  Xcode > Open Developer Tool > Accessibility Inspector   │
  │                                                          │
  │  Funciones:                                              │
  │  1. INSPECCION: Toca cualquier elemento para ver:        │
  │     - Label, Value, Hint, Traits                         │
  │     - Frame y posicion                                   │
  │     - Acciones disponibles                               │
  │                                                          │
  │  2. AUDIT: Escanea toda la app y reporta:                │
  │     - Elementos sin label                                │
  │     - Contraste insuficiente                             │
  │     - Hit targets muy pequenos (< 44x44 pt)              │
  │     - Elementos ocultos que no deberian estarlo          │
  │                                                          │
  │  3. SIMULACION: Prueba con:                              │
  │     - Dynamic Type (todos los tamanos)                   │
  │     - Invert Colors                                      │
  │     - Reduce Motion                                      │
  │     - Bold Text                                          │
  └─────────────────────────────────────────────────────────┘
```

#### Auditorias Automaticas en Tests (Xcode 15+)

```swift
import XCTest

// MARK: - Accessibility Audit en Tests

class AccesibilidadTests: XCTestCase {

    func testAuditoriaPantallaInicio() throws {
        let app = XCUIApplication()
        app.launch()

        // Ejecuta una auditoria completa de accesibilidad
        // Falla el test si encuentra problemas
        try app.performAccessibilityAudit()
    }

    func testAuditoriaConExcepciones() throws {
        let app = XCUIApplication()
        app.launch()

        // Auditoria ignorando ciertos tipos de problemas
        try app.performAccessibilityAudit(for: [
            .dynamicType,        // Verifica Dynamic Type
            .contrast,           // Verifica contraste
            .hitRegion,          // Verifica tamano de areas tocables
            .sufficientElementDescription  // Verifica labels
        ])
    }
}
```

### Tamano Minimo de Toque

Apple requiere un tamano minimo de 44x44 puntos para areas tocables:

```swift
import SwiftUI

// MARK: - Tamano Minimo de Toque

struct TamanoTocableDemo: View {
    var body: some View {
        VStack(spacing: 32) {
            // MAL: Icono pequeno dificil de tocar
            Button {
                // accion
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    // Tamano visual ~12pt — demasiado pequeno
            }

            // BIEN: Icono pequeno con area tocable grande
            Button {
                // accion
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .frame(minWidth: 44, minHeight: 44)
                    // Area tocable cumple el minimo
            }

            // BIEN: contentShape expande el area tocable sin cambiar visual
            Button {
                // accion
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Eliminar")
                }
                .font(.footnote)
            }
            .contentShape(Rectangle())
            .frame(minHeight: 44)
        }
    }
}
```

---

## Ejercicio 1: Tarjeta de Producto Accesible (Basico)

**Objetivo**: Aplicar accessibility modifiers a una tarjeta de producto.

**Requisitos**:
1. Tarjeta con imagen (SF Symbol), nombre del producto, precio y calificacion (estrellas)
2. Boton de favorito (corazon) con `.accessibilityLabel` y `.accessibilityValue`
3. Las estrellas deben agruparse con `.accessibilityElement(children: .ignore)` y tener un label descriptivo
4. Decoraciones visuales deben ser `.accessibilityHidden(true)`
5. Activar VoiceOver en el Simulador y verificar que cada elemento se lee correctamente
6. Probar con Dynamic Type `.accessibility3` para verificar que el layout no se rompe

---

## Ejercicio 2: Formulario Accesible (Intermedio)

**Objetivo**: Crear un formulario que funcione perfectamente con VoiceOver y Dynamic Type.

**Requisitos**:
1. Formulario con campos: nombre, email, telefono, fecha de nacimiento
2. Cada campo debe tener `.accessibilityLabel` descriptivo
3. Validacion visual (borde rojo) + accesible (`.accessibilityValue("Error: campo requerido")`)
4. Boton de enviar con `.accessibilityHint` que indique que pasa al tocar
5. Mensajes de error accesibles usando `AccessibilityNotification.Announcement`
6. Layout adaptivo: vertical en tamanos de accesibilidad, horizontal en tamanos normales (usar `dynamicTypeSize.isAccessibilitySize`)

---

## Ejercicio 3: Audit Completo de Accesibilidad (Avanzado)

**Objetivo**: Tomar una vista existente y hacerla 100% accesible.

**Requisitos**:
1. Tomar la vista de galeria del Ejercicio 2 de la Leccion 13 (o crear una equivalente)
2. Agregar labels, values y hints a TODOS los elementos interactivos
3. Implementar `.accessibilityAdjustableAction` para al menos un control (slider, calificacion)
4. Respetar `@Environment(\.accessibilityReduceMotion)` en todas las animaciones
5. Respetar `@Environment(\.accessibilityReduceTransparency)` — sustituir materiales por fondos opacos
6. Escribir un test con `performAccessibilityAudit()` que pase sin errores
7. Probar con Accessibility Inspector y documentar los hallazgos

---

## 5 Errores Comunes

### Error 1: Botones con solo icono sin accessibilityLabel

```swift
// MAL — VoiceOver dice "trash, boton"
Button { eliminar() } label: {
    Image(systemName: "trash")
}

// BIEN — VoiceOver dice "Eliminar elemento, boton"
Button { eliminar() } label: {
    Image(systemName: "trash")
}
.accessibilityLabel("Eliminar elemento")
```

### Error 2: Usar color como unica forma de comunicar estado

```swift
// MAL — daltonianos no ven la diferencia
Circle()
    .fill(estaActivo ? .green : .red)

// BIEN — color + icono + label
Image(systemName: estaActivo ? "checkmark.circle.fill" : "xmark.circle.fill")
    .foregroundStyle(estaActivo ? .green : .red)
    .accessibilityLabel(estaActivo ? "Activo" : "Inactivo")
```

### Error 3: Elementos decorativos que VoiceOver lee innecesariamente

```swift
// MAL — VoiceOver lee "sparkles, imagen" sin valor
HStack {
    Image(systemName: "sparkles")  // decorativo
    Text("Oferta especial")
}

// BIEN — ocultar el decorativo
HStack {
    Image(systemName: "sparkles")
        .accessibilityHidden(true)
    Text("Oferta especial")
}
```

### Error 4: Ignorar Reduce Motion y aplicar animaciones siempre

```swift
// MAL — puede causar mareos
withAnimation(.spring(duration: 1.0, bounce: 0.5)) {
    mostrarDetalle = true
}

// BIEN — respetar preferencia del usuario
@Environment(\.accessibilityReduceMotion) var reducirMovimiento

withAnimation(reducirMovimiento ? nil : .spring(duration: 1.0, bounce: 0.5)) {
    mostrarDetalle = true
}
```

### Error 5: Areas tocables menores a 44x44 puntos

```swift
// MAL — icono de 16pt imposible de tocar para personas con temblor
Button { cerrar() } label: {
    Image(systemName: "xmark")
        .font(.system(size: 12))
}

// BIEN — icono pequeno con area tocable amplia
Button { cerrar() } label: {
    Image(systemName: "xmark")
        .font(.system(size: 12))
        .frame(minWidth: 44, minHeight: 44)
}
```

---

## Checklist

- [ ] Entender las tres razones de accesibilidad: etica, legal, negocio
- [ ] Usar `.accessibilityLabel` en todos los elementos interactivos sin texto visible
- [ ] Usar `.accessibilityValue` para comunicar estado actual
- [ ] Usar `.accessibilityHint` para describir la accion de controles no obvios
- [ ] Agrupar elementos relacionados con `.accessibilityElement(children: .combine/.ignore)`
- [ ] Ocultar decoraciones con `.accessibilityHidden(true)`
- [ ] Respetar Dynamic Type — usar estilos semanticos, no tamanos fijos
- [ ] Adaptar layouts con `dynamicTypeSize.isAccessibilitySize`
- [ ] Respetar `accessibilityReduceMotion` en animaciones
- [ ] No depender solo del color para comunicar informacion
- [ ] Verificar areas tocables minimas de 44x44 puntos
- [ ] Ejecutar Accessibility Inspector y corregir problemas reportados
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

La accesibilidad debe incorporarse desde el inicio, no al final. En el Proyecto Integrador:
- **Cada boton de icono** debe tener `.accessibilityLabel` — crear una convencion desde el primer commit
- **Calificaciones y controles custom** necesitan `.accessibilityAdjustableAction` para ser usables con VoiceOver
- **Todas las animaciones** deben respetar `accessibilityReduceMotion`
- **Los materiales Liquid Glass** deben respetar `accessibilityReduceTransparency` con fondos opacos alternativos
- **Dynamic Type** debe probarse en cada pantalla con tamanos de accesibilidad
- **Tests de accesibilidad** (`performAccessibilityAudit()`) deben incluirse en el CI pipeline

---

*Leccion 14 | Accesibilidad | Semana 16 | Modulo 02: Diseno y UX*
*Siguiente: Modulo 03 — Leccion 15: Navegacion Avanzada en SwiftUI*
