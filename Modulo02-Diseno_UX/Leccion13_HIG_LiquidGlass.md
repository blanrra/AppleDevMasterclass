# Leccion 13: HIG, Liquid Glass y SF Symbols

**Modulo 02: Diseno y UX** | Semana 15

---

## TL;DR — Resumen en 2 minutos

- **HIG (Human Interface Guidelines)**: las reglas de diseno de Apple — seguirlas te da una app que se siente nativa y familiar
- **Liquid Glass**: el nuevo sistema visual de iOS 26 que unifica todo el ecosistema con superficies translucidas y profundidad
- **SF Symbols 6**: mas de 6,000 iconos vectoriales integrados con el sistema — se escalan, colorean y animan automaticamente
- **Dynamic Type**: tipografia del sistema que respeta las preferencias del usuario — usarla es gratis y obligatorio
- **Colores semanticos**: `.primary`, `.secondary`, `.accent` se adaptan a Light/Dark mode sin codigo extra

> Regla de oro: **si Apple ya lo diseno, usalo**. Personalizar cuando no es necesario solo empeora la experiencia.

---

## Cupertino MCP

```bash
cupertino search --source hig "design principles"
cupertino search --source hig "liquid glass"
cupertino search --source hig "typography"
cupertino search --source hig "color"
cupertino search --source hig "layout"
cupertino search --source hig "icons"
cupertino search "SF Symbols"
cupertino search "liquid-glass"
cupertino search --source updates "iOS 26 design"
cupertino search "GlassEffectContainer"
cupertino search "symbolEffect"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC25 | Design for Liquid Glass | **Esencial** — Nuevo sistema visual |
| WWDC25 | What's New in SF Symbols 6 | Nuevos simbolos y efectos |
| WWDC25 | Get to know the Human Interface Guidelines | Actualizacion HIG |
| WWDC24 | [Design with SF Symbols](https://developer.apple.com/videos/play/wwdc2024/) | Mejores practicas |
| WWDC23 | [Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/) | Fundamentos de diseno |
| EN | [Sean Allen — SF Symbols](https://www.youtube.com/@seanallen) | Tutorial practico |
| EN | [Paul Hudson — Dynamic Type](https://www.hackingwithswift.com/) | Tipografia accesible |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que importa el diseno en Apple?

Apple es la unica empresa que controla hardware, software y ecosistema. Esto significa que los usuarios tienen **expectativas muy altas** de como debe verse y sentirse una app. Una app que no sigue las convenciones de la plataforma se siente rota, aunque funcione perfectamente.

Las HIG no son sugerencias — son el contrato entre tu app y el usuario. Cuando un usuario toca un boton en iOS, espera una respuesta haptica, una animacion especifica y un comportamiento predecible. Romper ese contrato genera friccion.

### Human Interface Guidelines — Principios Fundamentales

Las HIG se organizan alrededor de principios que Apple ha refinado durante decadas:

```
  ┌─────────────────────────────────────────────────────────┐
  │              PRINCIPIOS HIG DE APPLE                     │
  │                                                          │
  │  1. CLARIDAD                                             │
  │     └─ El contenido es lo mas importante                 │
  │     └─ Tipografia legible, iconos precisos               │
  │     └─ Espaciado que separa jerarquias                   │
  │                                                          │
  │  2. DEFERENCIA                                           │
  │     └─ La UI ayuda al contenido, no compite              │
  │     └─ Liquid Glass: superficies que revelan contenido   │
  │     └─ Animaciones con proposito, no decoracion          │
  │                                                          │
  │  3. PROFUNDIDAD                                          │
  │     └─ Capas visuales que comunican jerarquia            │
  │     └─ Transiciones que mantienen contexto espacial      │
  │     └─ Touch y gestos que se sienten fisicos             │
  │                                                          │
  │  4. CONSISTENCIA                                         │
  │     └─ Patrones familiares entre apps                    │
  │     └─ Controles estandar con comportamiento esperado    │
  │     └─ Navegacion predecible                             │
  └─────────────────────────────────────────────────────────┘
```

### Liquid Glass — El Nuevo Paradigma Visual de iOS 26

Liquid Glass es la evolucion mas significativa del diseno visual de Apple desde iOS 7. En lugar de superficies opacas, Liquid Glass introduce **materiales translucidos que reaccionan al contenido debajo de ellos**.

**Por que Liquid Glass?** Apple quiere que el contenido sea protagonista. Las barras de navegacion, tab bars y controles se convierten en superficies de vidrio que dejan ver lo que hay detras, creando una sensacion de profundidad y continuidad.

```swift
import SwiftUI

// MARK: - Liquid Glass en Barras del Sistema

struct LiquidGlassNavDemo: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(1...20, id: \.self) { index in
                        TarjetaContenido(numero: index)
                    }
                }
                .padding()
            }
            .navigationTitle("Liquid Glass")
            // En iOS 26, NavigationStack aplica Liquid Glass
            // automaticamente a la barra de navegacion
        }
    }
}

struct TarjetaContenido: View {
    let numero: Int

    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("Elemento \(numero)")
                .font(.body)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)  // Material translucido
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

#### Materiales del Sistema

Los materiales son la base de Liquid Glass. SwiftUI los ofrece como modificadores:

```swift
import SwiftUI

// MARK: - Materiales Disponibles

struct MaterialesDemo: View {
    var body: some View {
        ZStack {
            // Fondo con contenido
            LinearGradient(
                colors: [.blue, .purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                textoConMaterial("Ultra Thin", material: .ultraThinMaterial)
                textoConMaterial("Thin", material: .thinMaterial)
                textoConMaterial("Regular", material: .regularMaterial)
                textoConMaterial("Thick", material: .thickMaterial)
                textoConMaterial("Ultra Thick", material: .ultraThickMaterial)
            }
            .padding()
        }
    }

    func textoConMaterial(_ nombre: String, material: some ShapeStyle) -> some View {
        Text(nombre)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(material, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

#### GlassEffectContainer (iOS 26)

iOS 26 introduce contenedores de efecto de vidrio explícitos:

```swift
import SwiftUI

// MARK: - Glass Effect Container

struct GlassDemo: View {
    @State private var seleccion = 0

    var body: some View {
        TabView(selection: $seleccion) {
            Tab("Inicio", systemImage: "house", value: 0) {
                ContenidoInicio()
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: 1) {
                ContenidoBuscar()
            }
            Tab("Perfil", systemImage: "person", value: 2) {
                ContenidoPerfil()
            }
        }
        // En iOS 26, TabView usa Liquid Glass automaticamente
        // El tab bar se vuelve translucido y reacciona al contenido
    }
}

struct ContenidoInicio: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<30) { i in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hue: Double(i) / 30, saturation: 0.6, brightness: 0.9))
                        .frame(height: 120)
                        .overlay(Text("Tarjeta \(i + 1)").font(.title2).bold())
                }
            }
            .padding()
        }
    }
}

struct ContenidoBuscar: View {
    var body: some View { Text("Buscar") }
}

struct ContenidoPerfil: View {
    var body: some View { Text("Perfil") }
}
```

### SF Symbols 6

SF Symbols es la biblioteca de iconos de Apple. Con mas de 6,000 simbolos, cubre practicamente cualquier necesidad. La ventaja clave: **se comportan como texto**, lo que significa que se escalan con Dynamic Type, se alinean con el texto y respetan las preferencias del usuario.

```swift
import SwiftUI

// MARK: - SF Symbols Basico

struct SFSymbolsDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            // Uso basico — se comportan como texto
            Label("Favoritos", systemImage: "heart.fill")
                .font(.title)

            // Tamanos relativos al texto
            HStack(spacing: 20) {
                Image(systemName: "star.fill").font(.caption)
                Image(systemName: "star.fill").font(.body)
                Image(systemName: "star.fill").font(.title)
                Image(systemName: "star.fill").font(.largeTitle)
            }
            .foregroundStyle(.yellow)

            // Variantes de peso
            HStack(spacing: 20) {
                Image(systemName: "bolt").fontWeight(.ultraLight)
                Image(systemName: "bolt").fontWeight(.regular)
                Image(systemName: "bolt").fontWeight(.bold)
                Image(systemName: "bolt").fontWeight(.black)
            }
            .font(.largeTitle)
        }
    }
}
```

#### Rendering Modes

SF Symbols soporta multiples modos de renderizado:

```swift
import SwiftUI

// MARK: - Rendering Modes

struct RenderingModesDemo: View {
    var body: some View {
        VStack(spacing: 32) {
            // Monocromatico — un solo color
            Label("Monochrome", systemImage: "cloud.sun.rain.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.blue)

            // Jerarquico — un color con opacidades
            Label("Hierarchical", systemImage: "cloud.sun.rain.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)

            // Palette — colores personalizados por capa
            Label("Palette", systemImage: "cloud.sun.rain.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.gray, .yellow, .blue)

            // Multicolor — colores definidos por Apple
            Label("Multicolor", systemImage: "cloud.sun.rain.fill")
                .symbolRenderingMode(.multicolor)
        }
        .font(.title)
    }
}
```

#### Symbol Effects (Animaciones)

```swift
import SwiftUI

// MARK: - Symbol Effects

struct SymbolEffectsDemo: View {
    @State private var esFavorito = false
    @State private var descargando = false
    @State private var notificaciones = 3

    var body: some View {
        VStack(spacing: 40) {
            // Bounce — efecto de rebote al tocar
            Button {
                esFavorito.toggle()
            } label: {
                Image(systemName: esFavorito ? "heart.fill" : "heart")
                    .symbolEffect(.bounce, value: esFavorito)
                    .foregroundStyle(esFavorito ? .red : .gray)
            }
            .font(.system(size: 44))

            // Pulse — pulsacion continua
            Image(systemName: "antenna.radiowaves.left.and.right")
                .symbolEffect(.pulse, isActive: descargando)
                .font(.system(size: 44))
                .foregroundStyle(.green)

            Button(descargando ? "Detener" : "Iniciar") {
                descargando.toggle()
            }

            // Variable color — colores que cambian
            Image(systemName: "wifi")
                .symbolEffect(.variableColor.iterative, isActive: descargando)
                .font(.system(size: 44))

            // Replace — transicion entre simbolos
            Button {
                notificaciones = notificaciones > 0 ? 0 : 3
            } label: {
                Image(systemName: notificaciones > 0
                    ? "\(notificaciones).circle.fill"
                    : "bell")
                    .contentTransition(.symbolEffect(.replace))
            }
            .font(.system(size: 44))
        }
    }
}
```

### Sistema Tipografico — Dynamic Type

Apple define una escala tipografica que se adapta automaticamente al tamano de texto que el usuario elige en Configuracion:

```swift
import SwiftUI

// MARK: - Escala Tipografica del Sistema

struct TipografiaDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Large Title").font(.largeTitle)
                Text("Title").font(.title)
                Text("Title 2").font(.title2)
                Text("Title 3").font(.title3)
                Text("Headline").font(.headline)
                Text("Subheadline").font(.subheadline)
                Text("Body (default)").font(.body)
                Text("Callout").font(.callout)
                Text("Footnote").font(.footnote)
                Text("Caption").font(.caption)
                Text("Caption 2").font(.caption2)
            }
            .padding()
        }
    }
}
```

**Regla**: Nunca uses tamanos fijos como `.font(.system(size: 17))` para texto de contenido. Usa los estilos semanticos `.body`, `.headline`, etc. Esto garantiza que tu app respeta Dynamic Type.

### Colores Semanticos

Los colores semanticos se adaptan automaticamente a Light y Dark mode:

```swift
import SwiftUI

// MARK: - Colores Semanticos

struct ColoresSemanticosDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            // Colores de texto — se adaptan a Light/Dark
            Text("Primary").foregroundStyle(.primary)
            Text("Secondary").foregroundStyle(.secondary)
            Text("Tertiary").foregroundStyle(.tertiary)

            Divider()

            // Colores del sistema — vibrantes y adaptivos
            HStack(spacing: 12) {
                circuloColor(.red, nombre: "Red")
                circuloColor(.blue, nombre: "Blue")
                circuloColor(.green, nombre: "Green")
                circuloColor(.orange, nombre: "Orange")
                circuloColor(.purple, nombre: "Purple")
            }

            Divider()

            // Fondos del sistema — diferentes niveles
            VStack(spacing: 8) {
                fondo("Background", color: Color(.systemBackground))
                fondo("Secondary BG", color: Color(.secondarySystemBackground))
                fondo("Tertiary BG", color: Color(.tertiarySystemBackground))
                fondo("Grouped BG", color: Color(.systemGroupedBackground))
            }

            Divider()

            // Tint/Accent color — identidad de tu app
            Button("Boton con Tint") { }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
        }
        .padding()
    }

    func circuloColor(_ color: Color, nombre: String) -> some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
            Text(nombre)
                .font(.caption2)
        }
    }

    func fondo(_ nombre: String, color: Color) -> some View {
        Text(nombre)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
```

### Espaciado y Layout

Apple recomienda usar multiplos de 8 puntos para espaciado:

```swift
import SwiftUI

// MARK: - Sistema de Espaciado

struct EspaciadoDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Espaciado consistente")
                .font(.title2)
                .bold()

            // 8pt grid
            VStack(alignment: .leading, spacing: 8) {
                Text("8pt — separacion minima entre elementos relacionados")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    etiqueta("Swift")
                    etiqueta("iOS")
                    etiqueta("SwiftUI")
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("16pt — separacion estandar entre secciones")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    campoTexto("Nombre")
                    campoTexto("Email")
                    campoTexto("Telefono")
                }
            }
        }
        .padding(16) // Margenes exteriores: 16pt o 20pt
    }

    func etiqueta(_ texto: String) -> some View {
        Text(texto)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.1))
            .clipShape(Capsule())
    }

    func campoTexto(_ placeholder: String) -> some View {
        TextField(placeholder, text: .constant(""))
            .textFieldStyle(.roundedBorder)
    }
}
```

---

## Ejercicio 1: Perfil con Liquid Glass (Basico)

**Objetivo**: Aplicar materiales, SF Symbols y tipografia del sistema.

**Requisitos**:
1. Pantalla de perfil de usuario con foto (SF Symbol `person.circle.fill`), nombre y bio
2. Usar al menos 2 materiales diferentes (`.regularMaterial`, `.thinMaterial`)
3. Barra de estadisticas con 3 metricas (posts, seguidores, siguiendo) usando SF Symbols
4. Todos los textos deben usar estilos tipograficos del sistema (`.title`, `.body`, `.caption`)
5. Colores semanticos — no usar colores hardcodeados
6. Botones de accion con `Label` y SF Symbols

---

## Ejercicio 2: Galeria con Symbol Effects (Intermedio)

**Objetivo**: Dominar SF Symbols rendering modes y animaciones.

**Requisitos**:
1. Grid de tarjetas (3 columnas) donde cada tarjeta tiene un SF Symbol diferente
2. Al tocar una tarjeta, el simbolo hace `.bounce` y cambia de color
3. Un boton de favorito por tarjeta con transicion `.replace` entre `heart` y `heart.fill`
4. Un indicador de carga usando `.pulse` cuando se simula una descarga
5. Usar `.symbolRenderingMode(.palette)` en al menos 3 simbolos
6. Aplicar `.regularMaterial` como fondo de las tarjetas

---

## Ejercicio 3: Design System Mini (Avanzado)

**Objetivo**: Crear un sistema de diseno reutilizable basado en HIG.

**Requisitos**:
1. Crear un `enum DesignTokens` con constantes para spacing (8, 12, 16, 24, 32), corner radius y tamanos de iconos
2. Crear 3 ViewModifiers reutilizables: `.cardGlass`, `.sectionHeader`, `.actionButton`
3. Crear un `enum AppIcon` que envuelva SF Symbols frecuentes de tu app con rendering mode predeterminado
4. Pantalla de demo que muestre todos los componentes juntos en un ScrollView
5. Que funcione correctamente en Light y Dark mode (usar Preview con `.preferredColorScheme`)
6. Respetar Dynamic Type — probarlo con `@Environment(\.dynamicTypeSize)`

---

## 5 Errores Comunes

### Error 1: Usar tamanos de fuente fijos en contenido

```swift
// MAL — ignora las preferencias del usuario
Text("Titulo")
    .font(.system(size: 28))

// BIEN — respeta Dynamic Type
Text("Titulo")
    .font(.title)
```

### Error 2: Colores hardcodeados que no se adaptan a Dark Mode

```swift
// MAL — invisible en Dark Mode
Text("Contenido")
    .foregroundColor(.black)
    .background(Color.white)

// BIEN — se adapta automaticamente
Text("Contenido")
    .foregroundStyle(.primary)
    .background(Color(.systemBackground))
```

### Error 3: No usar SF Symbols cuando existen

```swift
// MAL — icono custom innecesario
Image("mi-icono-settings")
    .resizable()
    .frame(width: 24, height: 24)

// BIEN — SF Symbol que escala con el texto
Image(systemName: "gear")
    .font(.title2)
```

### Error 4: Ignorar los materiales del sistema

```swift
// MAL — fondo opaco que bloquea contenido
.background(Color.gray.opacity(0.5))

// BIEN — material que integra con Liquid Glass
.background(.regularMaterial)
```

### Error 5: Espaciado inconsistente sin sistema

```swift
// MAL — numeros magicos sin logica
VStack(spacing: 13) {
    Text("A").padding(7)
    Text("B").padding(11)
}

// BIEN — grid de 8pt consistente
VStack(spacing: 16) {
    Text("A").padding(8)
    Text("B").padding(8)
}
```

---

## Checklist

- [ ] Conocer los 4 principios HIG: Claridad, Deferencia, Profundidad, Consistencia
- [ ] Entender Liquid Glass y cuando se aplica automaticamente (NavigationStack, TabView)
- [ ] Usar materiales del sistema (`.thinMaterial`, `.regularMaterial`, etc.)
- [ ] Dominar SF Symbols: busqueda, rendering modes y symbol effects
- [ ] Usar la escala tipografica del sistema (`.title`, `.body`, `.caption`, etc.)
- [ ] Aplicar colores semanticos que se adapten a Light/Dark mode
- [ ] Seguir el grid de 8pt para espaciado consistente
- [ ] Crear ViewModifiers reutilizables para un design system
- [ ] Probar en Light y Dark mode
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

El diseno visual es la primera impresion de tu app. En el Proyecto Integrador:
- **Liquid Glass** se aplicara automaticamente a NavigationStack y TabView — asegurate de que tu contenido se vea bien con superficies translucidas
- **SF Symbols** seran los iconos de toda la app — define un `enum AppIcon` desde el inicio
- **Design Tokens** (spacing, colores, corner radius) garantizan consistencia en todas las pantallas
- **Dynamic Type** es requisito para accesibilidad — probarlo en cada pantalla
- **Materiales** se usaran en tarjetas, overlays y controles personalizados

---

*Leccion 13 | HIG, Liquid Glass y SF Symbols | Semana 15 | Modulo 02: Diseno y UX*
*Siguiente: Leccion 14 — Accesibilidad*
