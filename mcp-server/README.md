# AppleDevMasterclass MCP Server

Servidor MCP que expone el curriculum AppleDevMasterclass como herramienta para agentes IA.

## Instalacion

```bash
cd mcp-server
npm install
```

## Uso con Claude Code

Anadir a tu configuracion de Claude Code como MCP server:

```json
{
  "mcpServers": {
    "appledevmasterclass": {
      "command": "node",
      "args": ["/ruta/a/AppleDevMasterclass/mcp-server/index.js"]
    }
  }
}
```

## Herramientas disponibles

| Herramienta | Descripcion | Parametros |
|-------------|-------------|------------|
| curriculum_overview | Vista general de todos los modulos | ninguno |
| lesson_detail | Detalle de una leccion | lesson_id (ej: "L15") |
| search_topic | Buscar un tema en el curriculum | query (ej: "SwiftData") |
| student_level | Recomendar punto de entrada | experience (descripcion de experiencia) |

## Ejemplo

Un agente IA puede consultar:
- "Que modulo cubre SwiftData?" → search_topic("SwiftData")
- "Que se aprende en L25?" → lesson_detail("L25")
- "Nunca he programado, por donde empiezo?" → student_level("sin experiencia")

---

*Creado por @blanrra*
