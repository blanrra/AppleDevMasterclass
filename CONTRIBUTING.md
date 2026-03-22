# Contribuir a AppleDevMasterclass

Gracias por tu interes en contribuir. Este proyecto es open source y toda ayuda es bienvenida.

---

## Como contribuir

### Reportar errores
- Abre un [Issue](https://github.com/blanrra/AppleDevMasterclass/issues) describiendo el error
- Incluye: leccion afectada, que esperabas, que paso

### Mejorar contenido existente
1. Fork el repositorio
2. Crea una rama: `git checkout -b mejora/descripcion`
3. Haz tus cambios
4. Abre un Pull Request con descripcion clara

### Tipos de contribucion bienvenidos

| Tipo | Ejemplo |
|------|---------|
| **Correccion de errores** | Typos, codigo que no compila, links rotos |
| **Nuevos ejercicios** | Ejercicios adicionales para lecciones existentes |
| **Mejores explicaciones** | Reescribir secciones confusas |
| **Traducciones** | Traducir CLAUDE.md a otros idiomas (ver `i18n/`) |
| **Retos/katas** | Nuevos retos para la carpeta Retos/ |
| **Showcase** | Anadir tu proyecto al Showcase |
| **Recursos** | Videos, articulos o herramientas utiles |

### Lo que NO aceptamos
- Contenido de tecnologias legacy (DispatchQueue, Combine como primario, Core Data, ObservableObject)
- Contenido en idiomas sin plantilla en `i18n/`
- Cambios al CLAUDE.md sin discusion previa en un Issue
- Codigo que no compile con Swift 6.2

---

## Study Buddy Mode

¿Quieres aprender con alguien mas? Asi se usa el modo Study Buddy:

1. Ambos clonan el mismo repo
2. Cada uno avanza a su ritmo con su propio Claude Code
3. Comparten progreso via PROGRESO.md (cada uno el suyo)
4. Semanalmente hacen una sesion conjunta donde:
   - Se explican mutuamente lo aprendido (mejor forma de retener)
   - Se evaluan con las preguntas del modo examen
   - Revisan el codigo del otro (code review)
5. Abren Issues en el repo compartido con dudas para discutir

### Setup
```bash
# Persona A
git clone https://github.com/blanrra/AppleDevMasterclass.git AppleDevMasterclass-PersonaA
cd AppleDevMasterclass-PersonaA
claude

# Persona B
git clone https://github.com/blanrra/AppleDevMasterclass.git AppleDevMasterclass-PersonaB
cd AppleDevMasterclass-PersonaB
claude
```

> El Profesor Apple es personal — cada uno tiene su propia experiencia adaptada a su nivel.

---

## Codigo de Conducta

- Se respetuoso y constructivo
- Las contribuciones son en espanol (o en el idioma de la traduccion correspondiente)
- Sigue el estilo de codigo del proyecto (ver CLAUDE.md > Guia de Estilo)

---

*Creado por [@blanrra](https://github.com/blanrra) — Gracias por contribuir!*
