# Changelog de Apple — Novedades por Beta

Esta seccion documenta los cambios relevantes para el curriculum cuando Apple publica nuevas betas de iOS, Xcode o Swift.

---

## Como funciona

1. Cuando salga una nueva beta, pide al profesor: *"Que cambio en la ultima beta?"*
2. Claude consultara Cupertino MCP: `cupertino search --source updates "iOS 26"`
3. Documentaremos aqui los cambios que afecten al curriculum

---

## Como consultar novedades

```bash
# Novedades generales
cupertino search --source updates "iOS 26"
cupertino search --source updates "Xcode 26"
cupertino search --source updates "Swift 6.2"

# Novedades por framework
cupertino search --source updates "SwiftUI"
cupertino search --source updates "SwiftData"
cupertino search --source updates "Foundation Models"

# Release notes
cupertino search "release notes iOS 26"
cupertino search "release notes Xcode 26"
```

---

## Registro de Cambios

### iOS 26 / Xcode 26 / Swift 6.2 (WWDC 2025)

| Cambio | Afecta a | Impacto |
|--------|----------|---------|
| Liquid Glass design system | M02 (Diseno) | Nuevo sistema visual |
| Foundation Models framework | M06 (IA) | IA on-device nativa |
| @Generable macro | M06 (IA) | Structured output para LLM |
| Swift 6.2 strict concurrency | M00 (Concurrencia) | Sendable por defecto |
| New SwiftUI APIs | M03 (SwiftUI) | Nuevos controles y modifiers |
| HealthKit Medications | M05 (Hardware) | Nuevas APIs de medicacion |

---

## Plantilla para Nuevas Betas

Cuando salga una beta nueva, documentar asi:

```markdown
### iOS 26 Beta X (Fecha)

| Cambio | Afecta a | Impacto |
|--------|----------|---------|
| Descripcion del cambio | Modulo afectado | Alto/Medio/Bajo |

**Lecciones a actualizar**: L##, L##
**Accion requerida**: Descripcion de que cambiar
```

---

*Este changelog se actualiza manualmente cuando salen nuevas betas. Consulta Cupertino MCP para la informacion mas reciente.*
