# Flashcards — Modulo 02: Diseno y UX

---

### Tarjeta 1
**Pregunta:** Cuales son los principios fundamentales de las Human Interface Guidelines (HIG) de Apple?
**Respuesta:** 1) **Claridad**: el texto es legible, los iconos precisos, la funcion es obvia. 2) **Deferencia**: la UI ayuda a entender el contenido sin competir con el. 3) **Profundidad**: las capas visuales y las transiciones comunican jerarquia e interaccion. El objetivo es que la interfaz se sienta intuitiva y natural.

---

### Tarjeta 2
**Pregunta:** Que es Liquid Glass y como afecta al diseno de apps en iOS 26?
**Respuesta:** Liquid Glass es el nuevo lenguaje visual de Apple introducido en iOS 26. Usa materiales translucidos y dinamicos que reaccionan a la luz y al contenido detras de ellos. Afecta: barras de navegacion, tab bars, sheets y controles del sistema adoptan este estilo automaticamente. Los desarrolladores deben asegurarse de que su contenido se vea bien detras de superficies de vidrio.

---

### Tarjeta 3
**Pregunta:** Que son los SF Symbols y cuantos hay disponibles?
**Respuesta:** SF Symbols es la biblioteca de iconos vectoriales de Apple con mas de 6,000 simbolos. Son escalables, se adaptan automaticamente a Dynamic Type, soportan colores multiples (multicolor, hierarchical, palette) y se alinean con el texto de San Francisco. Se usan con `Image(systemName: "nombre")`.

---

### Tarjeta 4
**Pregunta:** Cuales son los modos de renderizado de SF Symbols?
**Respuesta:** 1) **Monochrome**: un solo color (tint). 2) **Hierarchical**: un color con opacidades para dar profundidad. 3) **Palette**: multiples colores asignados manualmente. 4) **Multicolor**: colores predefinidos por Apple (ej: papelera roja). Se aplican con `.symbolRenderingMode(.hierarchical)`.

---

### Tarjeta 5
**Pregunta:** Que es Dynamic Type y como debe implementarse?
**Respuesta:** Dynamic Type permite al usuario ajustar el tamano del texto del sistema. Se implementa usando: 1) Estilos semanticos de fuente: `.font(.body)`, `.font(.headline)`. 2) Layouts flexibles que se adapten al tamano. 3) Probar con `Environment(\.sizeCategory)` en previews. **Nunca** usar tamanos fijos de fuente que ignoren la preferencia del usuario.

---

### Tarjeta 6
**Pregunta:** Que es VoiceOver y cuales son los 3 modificadores esenciales para soportarlo?
**Respuesta:** VoiceOver es el lector de pantalla de Apple para usuarios con discapacidad visual. Modificadores esenciales: 1) `.accessibilityLabel("texto")` — que ES el elemento. 2) `.accessibilityValue("estado")` — cual es su VALOR actual. 3) `.accessibilityHint("instruccion")` — que PASARA al interactuar. Toda app debe funcionar completamente con VoiceOver.

---

### Tarjeta 7
**Pregunta:** Como se agrupan y ocultan elementos de accesibilidad en SwiftUI?
**Respuesta:** 1) `.accessibilityElement(children: .combine)` — combina hijos en un solo elemento. 2) `.accessibilityElement(children: .ignore)` — ignora hijos y usa la etiqueta del padre. 3) `.accessibilityHidden(true)` — oculta un elemento decorativo de VoiceOver. Agrupar reduce la cantidad de swipes que necesita el usuario para navegar.

---

### Tarjeta 8
**Pregunta:** Que son los espaciados y tamanos recomendados en HIG para areas tactiles?
**Respuesta:** El area minima tactil recomendada es **44x44 puntos**. Los espaciados deben seguir el grid de 8pt (8, 16, 24, 32...). Los margenes laterales estandar son 16pt. Estos valores garantizan que los elementos sean faciles de tocar y que la interfaz tenga ritmo visual consistente.

---

### Tarjeta 9
**Pregunta:** Como se implementa el soporte para modo oscuro (Dark Mode) en SwiftUI?
**Respuesta:** 1) Usar colores semanticos del sistema: `.primary`, `.secondary`, `Color(.systemBackground)`. 2) Definir colores en Asset Catalog con variantes Light/Dark. 3) Usar `@Environment(\.colorScheme)` para logica condicional. 4) Probar siempre ambos modos. **Nunca** usar colores hardcoded como `.white` o `.black` para fondos o texto.

---

### Tarjeta 10
**Pregunta:** Que consideraciones de accesibilidad debe tener toda app como minimo?
**Respuesta:** 1) **VoiceOver**: todos los elementos interactivos tienen labels descriptivos. 2) **Dynamic Type**: el texto escala correctamente de xSmall a AX5. 3) **Contraste**: ratio minimo 4.5:1 para texto, 3:1 para iconos. 4) **Reduce Motion**: respetar `accessibilityReduceMotion` eliminando animaciones complejas. 5) **Reduce Transparency**: ofrecer fondos solidos alternativos.
