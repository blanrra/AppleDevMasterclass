# Leccion 48: MCP desde Cero — Servidor Completo

**Modulo 14: Agentic Coding y MCP** | Bonus

---

## TL;DR — Resumen en 2 minutos

- **Tools avanzados**: parametros complejos, validacion, errores tipados
- **Resources**: exponer datos (archivos, bases de datos) para que el agente los lea
- **MCP en Swift**: construir un servidor nativo en Swift usando stdin/stdout directo
- **Embeddings**: busqueda semantica con NLEmbedding de Apple para un MCP inteligente
- **Testing**: como verificar que tu MCP funciona correctamente

> Herramienta: **MCP Inspector** (`npx @modelcontextprotocol/inspector`) para depurar servidores MCP visualmente

---

## Recursos

| Tipo | Recurso | Notas |
|------|---------|-------|
| Oficial | [MCP Spec — Resources](https://modelcontextprotocol.io/docs/concepts/resources) | Documentacion de resources |
| Oficial | [MCP Inspector](https://github.com/modelcontextprotocol/inspector) | Herramienta de depuracion |
| Apple | [NLEmbedding — Apple Docs](https://developer.apple.com/documentation/naturallanguage/nlembedding) | Embeddings on-device |
| Apple | [NaturalLanguage Framework](https://developer.apple.com/documentation/naturallanguage) | Framework completo |
| Repo | [swift-mcp-sample](https://github.com/search?q=swift+mcp+server) | Ejemplos de MCP en Swift |

---

## Teoria

### Tools avanzados — Mas alla del "Hola Mundo"

En la leccion anterior creamos tools con parametros simples (un string, un numero). En la realidad, tus herramientas necesitaran parametros complejos: objetos anidados, arrays, campos opcionales, enums con multiples valores. Veamos como manejar todo esto.

#### Parametros complejos con Zod

```javascript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
    name: "servidor-avanzado",
    version: "1.0.0"
});

// Tool con parametros complejos: buscar archivos
server.tool(
    "buscar_archivos",

    "Busca archivos en un directorio. Soporta filtros por extension, " +
    "tamano y fecha de modificacion.",

    {
        // String obligatorio
        directorio: z.string()
            .describe("Ruta al directorio donde buscar, ej: /Users/jose/proyecto"),

        // String opcional con valor por defecto
        extension: z.string().optional()
            .describe("Extension de archivo a filtrar, ej: '.swift', '.js'. Si se omite, busca todos"),

        // Numero opcional
        tamano_max_kb: z.number().optional()
            .describe("Tamano maximo en KB. Solo devuelve archivos menores a este tamano"),

        // Boolean opcional
        incluir_ocultos: z.boolean().optional()
            .describe("Si es true, incluye archivos que empiezan con punto. Por defecto false"),

        // Enum: solo acepta valores especificos
        ordenar_por: z.enum(["nombre", "tamano", "fecha"])
            .optional()
            .describe("Criterio de ordenacion de los resultados")
    },

    async ({ directorio, extension, tamano_max_kb, incluir_ocultos, ordenar_por }) => {
        // fs es un modulo de Node.js para manejar archivos
        const fs = await import("fs/promises");
        const path = await import("path");

        try {
            let archivos = await fs.readdir(directorio);

            // Aplicar filtros
            if (!incluir_ocultos) {
                archivos = archivos.filter(a => !a.startsWith("."));
            }

            if (extension) {
                archivos = archivos.filter(a => a.endsWith(extension));
            }

            if (tamano_max_kb) {
                const filtrados = [];
                for (const archivo of archivos) {
                    const ruta = path.join(directorio, archivo);
                    const stats = await fs.stat(ruta);
                    if (stats.size / 1024 <= tamano_max_kb) {
                        filtrados.push(archivo);
                    }
                }
                archivos = filtrados;
            }

            // Formatear resultado
            if (archivos.length === 0) {
                return {
                    content: [{ type: "text", text: "No se encontraron archivos con esos criterios." }]
                };
            }

            const lista = archivos.map(a => `  - ${a}`).join("\n");
            return {
                content: [{
                    type: "text",
                    text: `Encontrados ${archivos.length} archivos en ${directorio}:\n${lista}`
                }]
            };

        } catch (error) {
            return {
                content: [{ type: "text", text: `Error: ${error.message}` }],
                isError: true
            };
        }
    }
);
```

Puntos clave:

1. **`.optional()`** marca un parametro como no obligatorio. El agente puede omitirlo. En tu handler, el valor sera `undefined` si no se paso.
2. **Descripciones ricas**: incluye ejemplos concretos en `.describe()`. "Ruta al directorio, ej: /Users/jose/proyecto" es mucho mejor que solo "directorio".
3. **Validacion automatica**: Zod rechaza valores invalidos antes de que lleguen a tu handler. Si el agente pasa `tamano_max_kb: "grande"`, Zod lo rechaza con un error claro.

#### Devolviendo datos estructurados

No todo es texto plano. Puedes devolver datos formateados como tablas, listas o JSON:

```javascript
server.tool(
    "estadisticas_proyecto",
    "Analiza un proyecto y devuelve estadisticas: archivos por extension, lineas de codigo, etc.",
    {
        directorio: z.string().describe("Ruta al directorio del proyecto")
    },
    async ({ directorio }) => {
        // ... logica de analisis ...

        // Devolver multiples bloques de contenido
        return {
            content: [
                {
                    type: "text",
                    text: "## Estadisticas del Proyecto\n"
                },
                {
                    type: "text",
                    text: [
                        "| Extension | Archivos | Lineas |",
                        "|-----------|----------|--------|",
                        "| .swift    | 45       | 12,340 |",
                        "| .json     | 12       | 890    |",
                        "| .md       | 8        | 1,200  |",
                    ].join("\n")
                },
                {
                    type: "text",
                    text: "\nTotal: 65 archivos, 14,430 lineas de codigo"
                }
            ]
        };
    }
);
```

El agente recibe todos los bloques y puede presentarlos al usuario de forma coherente.

#### Manejo de errores con isError

Cuando algo sale mal, hay dos niveles de error:

**Nivel 1: Error en la ejecucion del tool** — Usa `isError: true`

```javascript
// El tool se ejecuto pero la operacion fallo (archivo no existe, etc.)
return {
    content: [{
        type: "text",
        text: "Error: el archivo /ruta/archivo.txt no existe"
    }],
    isError: true   // Le dice al agente que el resultado es un error
};
```

**Nivel 2: Error inesperado (excepcion)** — El SDK lo captura

```javascript
// Si tu handler lanza una excepcion no capturada,
// el SDK la convierte en un error JSON-RPC automaticamente.
// PERO es mejor capturarla tu mismo para dar mensajes utiles.
async ({ ruta }) => {
    try {
        // ... logica que puede fallar ...
    } catch (error) {
        return {
            content: [{
                type: "text",
                text: `Error inesperado: ${error.message}\n` +
                      `Sugerencia: verifica que la ruta sea correcta y tengas permisos.`
            }],
            isError: true
        };
    }
}
```

La diferencia para el agente: con `isError: true`, sabe que el tool fallo y puede intentar corregir (por ejemplo, pedir la ruta correcta al usuario). Sin `isError`, el agente interpreta el texto de error como un resultado exitoso.

#### Tool que llama a una API externa

```javascript
server.tool(
    "clima",
    "Consulta el clima actual de una ciudad usando la API de wttr.in",
    {
        ciudad: z.string().describe("Nombre de la ciudad, ej: 'Madrid', 'Mexico City'")
    },
    async ({ ciudad }) => {
        try {
            // wttr.in es una API gratuita que no requiere API key
            const url = `https://wttr.in/${encodeURIComponent(ciudad)}?format=j1`;
            const response = await fetch(url);

            if (!response.ok) {
                return {
                    content: [{ type: "text", text: `Error HTTP: ${response.status}` }],
                    isError: true
                };
            }

            const data = await response.json();
            const actual = data.current_condition[0];

            const texto = [
                `Clima en ${ciudad}:`,
                `  Temperatura: ${actual.temp_C}°C`,
                `  Sensacion: ${actual.FeelsLikeC}°C`,
                `  Humedad: ${actual.humidity}%`,
                `  Descripcion: ${actual.weatherDesc[0].value}`,
            ].join("\n");

            return { content: [{ type: "text", text: texto }] };

        } catch (error) {
            return {
                content: [{ type: "text", text: `Error consultando clima: ${error.message}` }],
                isError: true
            };
        }
    }
);
```

#### Tool que consulta una base de datos SQLite

```javascript
// Necesitas: npm install better-sqlite3
import Database from "better-sqlite3";

server.tool(
    "consultar_db",
    "Ejecuta una consulta SELECT en la base de datos del proyecto. " +
    "Solo lectura — no permite INSERT, UPDATE o DELETE.",
    {
        query: z.string()
            .describe("Consulta SQL SELECT. Ej: SELECT * FROM usuarios WHERE activo = 1"),
        limite: z.number().optional()
            .describe("Maximo de filas a devolver. Por defecto 50")
    },
    async ({ query, limite = 50 }) => {
        // Validacion de seguridad: solo permitir SELECT
        const queryNormalizada = query.trim().toUpperCase();
        if (!queryNormalizada.startsWith("SELECT")) {
            return {
                content: [{ type: "text", text: "Error: solo se permiten consultas SELECT" }],
                isError: true
            };
        }

        try {
            const db = new Database("./mi-proyecto.db", { readonly: true });
            const filas = db.prepare(`${query} LIMIT ?`).all(limite);
            db.close();

            if (filas.length === 0) {
                return {
                    content: [{ type: "text", text: "La consulta no devolvio resultados." }]
                };
            }

            // Formatear como tabla
            const columnas = Object.keys(filas[0]);
            const header = "| " + columnas.join(" | ") + " |";
            const separador = "| " + columnas.map(() => "---").join(" | ") + " |";
            const cuerpo = filas.map(fila =>
                "| " + columnas.map(col => String(fila[col])).join(" | ") + " |"
            ).join("\n");

            return {
                content: [{
                    type: "text",
                    text: `Resultados (${filas.length} filas):\n\n${header}\n${separador}\n${cuerpo}`
                }]
            };

        } catch (error) {
            return {
                content: [{ type: "text", text: `Error SQL: ${error.message}` }],
                isError: true
            };
        }
    }
);
```

Observa la validacion de seguridad: solo permitimos SELECT. Sin esta validacion, el agente podria ejecutar `DROP TABLE usuarios` (accidentalmente o por un prompt injection).

---

### Resources — Exponiendo datos al agente

Hasta ahora hemos visto Tools: funciones que el agente ejecuta. Los **Resources** son diferentes: son datos que el agente puede leer. Piensa en la diferencia entre POST y GET en una API REST:

- **Tool** = POST — ejecuta una accion, puede tener side effects
- **Resource** = GET — lee datos, sin side effects

#### Cuando usar Resources vs Tools?

| Situacion | Usar |
|-----------|------|
| Leer el contenido de un archivo | Resource |
| Buscar archivos por patron | Tool |
| Obtener configuracion actual | Resource |
| Modificar configuracion | Tool |
| Listar tablas de una base de datos | Resource |
| Ejecutar una consulta SQL | Tool |

La regla simple: si es **lectura pura sin parametros complejos**, usa Resource. Si necesita **parametros, logica o side effects**, usa Tool.

#### Implementar un Resource

```javascript
import { McpServer, ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import fs from "fs/promises";
import path from "path";

const server = new McpServer({
    name: "servidor-con-resources",
    version: "1.0.0"
});

// ============================================================
// RESOURCE ESTATICO: exponer un archivo especifico
// ============================================================

// server.resource() registra un resource.
// Parametros:
//   1. Nombre del resource
//   2. URI que lo identifica (como una URL)
//   3. Handler que devuelve el contenido

server.resource(
    "readme",                          // Nombre
    "file:///proyecto/README.md",      // URI unica
    async (uri) => ({
        contents: [{
            uri: uri.href,
            mimeType: "text/markdown",
            text: await fs.readFile("/ruta/al/proyecto/README.md", "utf-8")
        }]
    })
);

// ============================================================
// RESOURCE TEMPLATE: patron dinamico con variables
// ============================================================

// Un ResourceTemplate permite URIs con parametros.
// Es como una ruta parametrica en Express: /archivos/:nombre

server.resource(
    "archivo-proyecto",
    // El {nombre} entre llaves es un parametro variable
    new ResourceTemplate("file:///proyecto/{nombre}", { list: undefined }),
    async (uri, { nombre }) => {
        try {
            const ruta = path.join("/ruta/al/proyecto", nombre);
            const contenido = await fs.readFile(ruta, "utf-8");

            return {
                contents: [{
                    uri: uri.href,
                    mimeType: nombre.endsWith(".swift") ? "text/x-swift" :
                              nombre.endsWith(".json") ? "application/json" :
                              "text/plain",
                    text: contenido
                }]
            };
        } catch (error) {
            // Si el archivo no existe, devolver contenido vacio con nota
            return {
                contents: [{
                    uri: uri.href,
                    mimeType: "text/plain",
                    text: `Error: no se pudo leer '${nombre}': ${error.message}`
                }]
            };
        }
    }
);
```

El agente puede pedir `file:///proyecto/Package.swift` o `file:///proyecto/Sources/main.swift` y el template resuelve el parametro `nombre` automaticamente.

#### Resource con listado dinamico

Si quieres que el agente pueda descubrir que resources existen, implementa el callback `list`:

```javascript
server.resource(
    "archivos-swift",
    new ResourceTemplate("file:///proyecto/swift/{archivo}", {
        // El callback list devuelve todos los resources disponibles
        list: async () => {
            const archivos = await fs.readdir("/ruta/al/proyecto/Sources");
            const swiftFiles = archivos.filter(a => a.endsWith(".swift"));

            return {
                resources: swiftFiles.map(archivo => ({
                    uri: `file:///proyecto/swift/${archivo}`,
                    name: archivo,
                    description: `Archivo Swift: ${archivo}`,
                    mimeType: "text/x-swift"
                }))
            };
        }
    }),
    async (uri, { archivo }) => {
        const contenido = await fs.readFile(
            path.join("/ruta/al/proyecto/Sources", archivo),
            "utf-8"
        );
        return {
            contents: [{ uri: uri.href, mimeType: "text/x-swift", text: contenido }]
        };
    }
);
```

Con `list`, el agente puede hacer `resources/list` y descubrir todos los archivos Swift disponibles antes de decidir cual leer.

---

### MCP en Swift — El siguiente nivel

Hasta ahora hemos usado Node.js, pero como desarrolladores Swift, queremos construir servidores MCP en nuestro lenguaje nativo. La buena noticia: un servidor MCP es simplemente un programa que lee JSON de stdin y escribe JSON a stdout. Podemos hacerlo en cualquier lenguaje.

#### Por que Swift para un MCP?

1. **Acceso nativo** a frameworks de Apple: NaturalLanguage, CoreML, Vision, Foundation
2. **Performance**: binario compilado, sin overhead de runtime como Node.js
3. **Type safety**: Codable + el compilador atrapan errores antes de ejecutar
4. **Un solo lenguaje**: si tu app es Swift, tu MCP tambien puede serlo

#### Paso 1: Crear el Swift Package

```bash
mkdir mcp-swift-server
cd mcp-swift-server
swift package init --type executable
```

#### Paso 2: Package.swift

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MCPSwiftServer",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "MCPSwiftServer")
    ]
)
```

No necesitamos dependencias externas. Vamos a implementar el protocolo JSON-RPC manualmente usando solo Foundation.

#### Paso 3: Modelos Codable para JSON-RPC

```swift
// Sources/MCPSwiftServer/Models.swift

import Foundation

// MARK: - JSON-RPC Request
// Representa un mensaje que el agente envia al servidor.
// El campo "method" dice que quiere hacer, "params" son los argumentos.

struct JSONRPCRequest: Codable {
    let jsonrpc: String        // Siempre "2.0"
    let id: RequestID?         // Identificador unico (puede ser Int o String)
    let method: String         // "initialize", "tools/list", "tools/call", etc.
    let params: AnyCodable?    // Parametros del metodo (varia segun el method)
}

// MARK: - JSON-RPC Response
// Representa la respuesta que el servidor envia al agente.

struct JSONRPCResponse: Codable {
    let jsonrpc: String = "2.0"
    let id: RequestID?
    let result: AnyCodable?
    let error: JSONRPCError?
}

struct JSONRPCError: Codable {
    let code: Int
    let message: String
}

// MARK: - RequestID
// El id puede ser Int o String segun la spec JSON-RPC 2.0.
// Necesitamos un tipo custom para manejar ambos.

enum RequestID: Codable {
    case int(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(
                RequestID.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Expected Int or String")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        }
    }
}

// MARK: - AnyCodable
// Un wrapper para manejar JSON arbitrario con Codable.
// Necesario porque los params y results de JSON-RPC son dinamicos.

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if container.decodeNil() {
            value = NSNull()
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported type"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case is NSNull:
            try container.encodeNil()
        default:
            try container.encode(String(describing: value))
        }
    }
}
```

El tipo `AnyCodable` es el mas complejo aqui. Lo necesitamos porque JSON-RPC usa objetos dinamicos — los `params` pueden tener cualquier estructura dependiendo del metodo. En un SDK maduro, esto se resolveria con tipos genericos, pero para aprender es mejor ver la mecanica completa.

#### Paso 4: El servidor principal

```swift
// Sources/MCPSwiftServer/main.swift

import Foundation

// MARK: - Configuracion del servidor
let serverName = "mcp-swift-server"
let serverVersion = "1.0.0"

// MARK: - Definicion de herramientas
// Cada tool tiene nombre, descripcion y un JSON Schema para sus parametros.

let herramientas: [[String: Any]] = [
    [
        "name": "contar_palabras",
        "description": "Cuenta las palabras en un texto. Usa esta herramienta cuando " +
                       "el usuario quiera saber cuantas palabras tiene un texto.",
        "inputSchema": [
            "type": "object",
            "properties": [
                "texto": [
                    "type": "string",
                    "description": "El texto del cual contar palabras"
                ]
            ],
            "required": ["texto"]
        ]
    ],
    [
        "name": "invertir_texto",
        "description": "Invierte un texto caracter por caracter. Usa esta herramienta " +
                       "para invertir strings o verificar palindromos.",
        "inputSchema": [
            "type": "object",
            "properties": [
                "texto": [
                    "type": "string",
                    "description": "El texto a invertir"
                ]
            ],
            "required": ["texto"]
        ]
    ],
    [
        "name": "analizar_texto",
        "description": "Analiza un texto y devuelve estadisticas: palabras, caracteres, " +
                       "oraciones, y las 5 palabras mas frecuentes.",
        "inputSchema": [
            "type": "object",
            "properties": [
                "texto": [
                    "type": "string",
                    "description": "El texto a analizar"
                ]
            ],
            "required": ["texto"]
        ]
    ]
]

// MARK: - Ejecutar herramientas

func ejecutarTool(nombre: String, argumentos: [String: Any]) -> (String, Bool) {
    switch nombre {

    case "contar_palabras":
        guard let texto = argumentos["texto"] as? String else {
            return ("Error: parametro 'texto' es requerido", true)
        }
        let palabras = texto.split(separator: " ").count
        return ("El texto tiene \(palabras) palabras.", false)

    case "invertir_texto":
        guard let texto = argumentos["texto"] as? String else {
            return ("Error: parametro 'texto' es requerido", true)
        }
        let invertido = String(texto.reversed())
        let esPalindromo = texto.lowercased() == invertido.lowercased()
        var resultado = "Texto invertido: \(invertido)"
        if esPalindromo {
            resultado += "\n(Es un palindromo!)"
        }
        return (resultado, false)

    case "analizar_texto":
        guard let texto = argumentos["texto"] as? String else {
            return ("Error: parametro 'texto' es requerido", true)
        }

        let palabras = texto.split(separator: " ")
        let caracteres = texto.count
        let oraciones = texto.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .count

        // Contar frecuencia de palabras
        var frecuencia: [String: Int] = [:]
        for palabra in palabras {
            let limpia = palabra.lowercased()
                .trimmingCharacters(in: .punctuationCharacters)
            frecuencia[limpia, default: 0] += 1
        }

        let topPalabras = frecuencia
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { "  \($0.key): \($0.value) veces" }
            .joined(separator: "\n")

        let resultado = """
        Analisis del texto:
          Palabras: \(palabras.count)
          Caracteres: \(caracteres)
          Oraciones: \(oraciones)

        Top 5 palabras:
        \(topPalabras)
        """

        return (resultado, false)

    default:
        return ("Error: herramienta '\(nombre)' no encontrada", true)
    }
}

// MARK: - Manejar requests JSON-RPC

func manejarRequest(_ request: JSONRPCRequest) -> JSONRPCResponse? {

    switch request.method {

    // ---- INITIALIZE ----
    // El agente se presenta. Respondemos con nuestras capacidades.
    case "initialize":
        let result: [String: Any] = [
            "protocolVersion": "2025-03-26",
            "capabilities": [
                "tools": [:]    // Declaramos que soportamos tools
            ],
            "serverInfo": [
                "name": serverName,
                "version": serverVersion
            ]
        ]
        return JSONRPCResponse(
            id: request.id,
            result: AnyCodable(result),
            error: nil
        )

    // ---- INITIALIZED (notificacion) ----
    // El agente confirma la conexion. No requiere respuesta.
    case "notifications/initialized":
        return nil  // Las notificaciones no tienen respuesta

    // ---- TOOLS/LIST ----
    // El agente pide la lista de herramientas disponibles.
    case "tools/list":
        let result: [String: Any] = ["tools": herramientas]
        return JSONRPCResponse(
            id: request.id,
            result: AnyCodable(result),
            error: nil
        )

    // ---- TOOLS/CALL ----
    // El agente quiere ejecutar una herramienta.
    case "tools/call":
        guard let params = request.params?.value as? [String: Any],
              let toolName = params["name"] as? String else {
            return JSONRPCResponse(
                id: request.id,
                result: nil,
                error: JSONRPCError(code: -32602, message: "Parametros invalidos: falta 'name'")
            )
        }

        let argumentos = params["arguments"] as? [String: Any] ?? [:]
        let (resultado, esError) = ejecutarTool(nombre: toolName, argumentos: argumentos)

        let content: [[String: Any]] = [
            ["type": "text", "text": resultado]
        ]

        var resultDict: [String: Any] = ["content": content]
        if esError {
            resultDict["isError"] = true
        }

        return JSONRPCResponse(
            id: request.id,
            result: AnyCodable(resultDict),
            error: nil
        )

    // ---- METODO DESCONOCIDO ----
    default:
        // Si el method no tiene id, es una notificacion — no responder
        guard request.id != nil else { return nil }

        return JSONRPCResponse(
            id: request.id,
            result: nil,
            error: JSONRPCError(code: -32601, message: "Metodo no encontrado: \(request.method)")
        )
    }
}

// MARK: - Loop principal: leer stdin, escribir stdout

// Configurar JSON encoder/decoder
let decoder = JSONDecoder()
let encoder = JSONEncoder()
// No queremos pretty print — cada respuesta debe ser UNA linea
encoder.outputFormatting = []

// Mensaje de debug a stderr (NUNCA a stdout)
FileHandle.standardError.write(
    "[\(serverName)] Servidor MCP iniciado. Esperando mensajes en stdin...\n"
        .data(using: .utf8)!
)

// Leer stdin linea por linea
// readLine() bloquea hasta que llega una linea o stdin se cierra (EOF)
while let linea = readLine() {
    // Ignorar lineas vacias
    guard !linea.isEmpty else { continue }

    // Intentar decodificar como JSON-RPC request
    guard let data = linea.data(using: .utf8) else {
        FileHandle.standardError.write(
            "[\(serverName)] Error: linea no es UTF-8 valido\n".data(using: .utf8)!
        )
        continue
    }

    do {
        let request = try decoder.decode(JSONRPCRequest.self, from: data)

        // Debug: loguear el metodo recibido (a stderr!)
        FileHandle.standardError.write(
            "[\(serverName)] Recibido: \(request.method)\n".data(using: .utf8)!
        )

        // Procesar el request
        if let response = manejarRequest(request) {
            // Serializar la respuesta a JSON
            let responseData = try encoder.encode(response)

            // Escribir a stdout como UNA linea
            // stdout es el canal MCP — solo JSON valido aqui
            FileHandle.standardOutput.write(responseData)
            FileHandle.standardOutput.write("\n".data(using: .utf8)!)
        }

    } catch {
        FileHandle.standardError.write(
            "[\(serverName)] Error decodificando: \(error)\n".data(using: .utf8)!
        )
    }
}
```

#### Paso 5: Compilar y probar

```bash
# Compilar
swift build

# Probar manualmente (igual que con Node.js)
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}
{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"contar_palabras","arguments":{"texto":"Hola mundo desde Swift MCP"}}}' | swift run
```

#### Paso 6: Conectar a Claude Code

```json
{
    "mcpServers": {
        "mcp-swift-server": {
            "command": "/ruta/al/mcp-swift-server/.build/debug/MCPSwiftServer"
        }
    }
}
```

Observa que con Swift usamos el binario compilado directamente. No necesitamos `node` ni ningun runtime. El binario es autocontenido.

---

### Embeddings y busqueda semantica — MCP inteligente

Esta es la parte mas emocionante: combinar MCP con inteligencia artificial on-device usando el framework NaturalLanguage de Apple.

#### Que son los embeddings?

Un embedding es una representacion numerica del significado de un texto. Imagina que puedes convertir cualquier frase en un punto en un espacio de 512 dimensiones, donde frases con significado similar quedan cerca unas de otras:

```
"perro" → [0.2, -0.1, 0.8, ...]   (512 numeros)
"can"   → [0.19, -0.12, 0.79, ...]  (muy similar a "perro"!)
"gato"  → [0.3, -0.2, 0.7, ...]     (similar pero no igual)
"avion" → [-0.5, 0.9, 0.1, ...]     (muy diferente)
```

Esto permite hacer **busqueda semantica**: buscar por significado en vez de por palabras exactas. Si buscas "mascota", encuentras documentos que hablan de "perro" y "gato" aunque no contengan la palabra "mascota".

#### NLEmbedding de Apple

Apple incluye modelos de embeddings pre-entrenados en macOS e iOS a traves del framework NaturalLanguage. No necesitas internet ni API keys — todo corre on-device.

```swift
import NaturalLanguage

// Obtener el modelo de embeddings para espanol
// Apple incluye modelos para multiples idiomas
guard let embedding = NLEmbedding.wordEmbedding(for: .spanish) else {
    print("Modelo de embeddings no disponible")
    return
}

// Obtener el vector de una palabra
if let vector = embedding.vector(for: "programar") {
    print("Dimensiones: \(vector.count)")  // 300 o 512 segun el modelo
}

// Calcular distancia semantica entre dos palabras
let distancia = embedding.distance(
    between: "veloz",
    and: "rapido"
)
print("Distancia veloz-rapido: \(distancia)")  // ~0.3 (cercanos)

let distanciaLejana = embedding.distance(
    between: "veloz",
    and: "biblioteca"
)
print("Distancia veloz-biblioteca: \(distanciaLejana)")  // ~1.5 (lejanos)

// Buscar palabras similares
let similares = embedding.neighbors(for: "programar", maximumCount: 5)
// Resultado: [("desarrollar", 0.4), ("codificar", 0.5), ("compilar", 0.6), ...]
```

#### Sentence Embeddings para textos completos

Los word embeddings funcionan para palabras individuales. Para frases y parrafos, usamos **sentence embeddings**:

```swift
import NaturalLanguage

guard let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .spanish) else {
    print("Sentence embeddings no disponibles")
    return
}

// Embeddings de oraciones completas
let textos = [
    "Como crear una vista en SwiftUI",
    "Disenar interfaces de usuario con Swift",
    "Configurar un servidor web con Vapor",
    "Patterns de navegacion en apps iOS",
    "Compilar y distribuir en App Store"
]

// Calcular distancia entre dos oraciones
let distancia = sentenceEmbedding.distance(
    between: "quiero hacer una pantalla bonita",
    and: "Como crear una vista en SwiftUI"
)
// Distancia baja = significados similares (aunque las palabras sean diferentes!)
```

#### MCP con busqueda semantica

Ahora combinemos todo: un servidor MCP en Swift que busca documentacion por significado.

```swift
// Agregar al servidor Swift anterior

import NaturalLanguage

// MARK: - Base de conocimiento
// En un caso real, esto vendria de archivos .md o una base de datos

struct Documento {
    let titulo: String
    let contenido: String
    let ruta: String
}

let documentos: [Documento] = [
    Documento(
        titulo: "NavigationStack en SwiftUI",
        contenido: "NavigationStack es el contenedor principal para navegacion " +
                   "jerarquica en SwiftUI. Reemplaza a NavigationView.",
        ruta: "Modulo03/Leccion15_Navegacion.md"
    ),
    Documento(
        titulo: "SwiftData modelos",
        contenido: "SwiftData usa el macro @Model para definir modelos persistentes. " +
                   "Es el reemplazo moderno de Core Data.",
        ruta: "Modulo04/Leccion19_SwiftData.md"
    ),
    Documento(
        titulo: "Async await concurrencia",
        contenido: "async/await permite escribir codigo asincrono de forma secuencial. " +
                   "Los Task groups permiten paralelismo estructurado.",
        ruta: "Modulo00/Leccion08_Concurrency.md"
    ),
    // ... mas documentos
]

// MARK: - Busqueda semantica

func busquedaSemantica(query: String, topK: Int = 3) -> [(Documento, Double)] {
    guard let embedding = NLEmbedding.sentenceEmbedding(for: .spanish) else {
        return []
    }

    // Calcular distancia del query a cada documento
    var resultados: [(Documento, Double)] = []

    for doc in documentos {
        // Combinamos titulo + contenido para mejor matching
        let textoCompleto = "\(doc.titulo). \(doc.contenido)"
        let distancia = embedding.distance(between: query, and: textoCompleto)
        resultados.append((doc, distancia))
    }

    // Ordenar por distancia (menor = mas relevante)
    resultados.sort { $0.1 < $1.1 }

    // Devolver los topK mas relevantes
    return Array(resultados.prefix(topK))
}
```

Y el tool que expone esta busqueda:

```swift
// Agregar a la lista de herramientas
let toolBuscar: [String: Any] = [
    "name": "buscar_documentacion",
    "description": "Busca en la documentacion del curso por significado, no por palabras " +
                   "exactas. Usa esta herramienta cuando el usuario pregunte sobre un tema " +
                   "y quieras encontrar las lecciones mas relevantes.",
    "inputSchema": [
        "type": "object",
        "properties": [
            "consulta": [
                "type": "string",
                "description": "Lo que quieres buscar, en lenguaje natural. " +
                               "Ej: 'como guardar datos en la app'"
            ],
            "cantidad": [
                "type": "number",
                "description": "Cuantos resultados devolver (1-10). Por defecto 3"
            ]
        ],
        "required": ["consulta"]
    ]
]

// En el switch de ejecutarTool:
case "buscar_documentacion":
    guard let consulta = argumentos["consulta"] as? String else {
        return ("Error: parametro 'consulta' requerido", true)
    }
    let cantidad = argumentos["cantidad"] as? Int ?? 3

    let resultados = busquedaSemantica(query: consulta, topK: cantidad)

    if resultados.isEmpty {
        return ("No se encontraron documentos relevantes.", false)
    }

    var texto = "Resultados para: \"\(consulta)\"\n\n"
    for (i, (doc, distancia)) in resultados.enumerated() {
        let relevancia = max(0, (2.0 - distancia) / 2.0 * 100)  // Convertir a porcentaje
        texto += "\(i + 1). **\(doc.titulo)** (relevancia: \(Int(relevancia))%)\n"
        texto += "   \(doc.contenido)\n"
        texto += "   Ruta: \(doc.ruta)\n\n"
    }

    return (texto, false)
```

La magia aqui es que si el usuario pregunta "como guardar datos en mi app", el MCP encuentra la leccion de SwiftData aunque la palabra "guardar" no aparezca literalmente en la documentacion. Los embeddings entienden que "guardar datos" y "persistencia" y "SwiftData modelos" estan relacionados semanticamente.

---

### Testing tu MCP

Un MCP sin tests es un MCP que va a fallar en produccion. Veamos las diferentes estrategias de testing.

#### 1. Testing manual con scripts

Ya vimos esto en la Leccion 47, pero hagamoslo mas robusto:

```bash
#!/bin/bash
# test_completo.sh — Test suite manual para MCP

SERVER_CMD="swift run"  # o "node index.js" para Node.js

echo "=== Test 1: Initialize ==="
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | $SERVER_CMD 2>/dev/null

echo ""
echo "=== Test 2: Tools List ==="
(
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}'
echo '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
) | $SERVER_CMD 2>/dev/null

echo ""
echo "=== Test 3: Tool Call ==="
(
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}'
echo '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"contar_palabras","arguments":{"texto":"uno dos tres cuatro cinco"}}}'
) | $SERVER_CMD 2>/dev/null
# Debe devolver "5 palabras"
```

#### 2. MCP Inspector — Testing visual

MCP Inspector es una herramienta oficial que te da una interfaz web para probar tu servidor:

```bash
# Instalar y ejecutar Inspector
npx @modelcontextprotocol/inspector

# O para un servidor especifico
npx @modelcontextprotocol/inspector node index.js
```

Inspector te muestra:
- Lista de tools, resources y prompts
- Formularios para probar cada tool con diferentes parametros
- Respuestas formateadas
- Log de todos los mensajes JSON-RPC

Es especialmente util cuando estas desarrollando porque te permite probar interactivamente sin necesitar a Claude Code.

#### 3. Tests automatizados en Node.js

```javascript
// test.js — Test suite para tu MCP server
import { spawn } from "child_process";

// Helper: enviar un mensaje JSON-RPC al servidor y leer la respuesta
function sendMessage(process, message) {
    return new Promise((resolve) => {
        process.stdout.once("data", (data) => {
            resolve(JSON.parse(data.toString()));
        });
        process.stdin.write(JSON.stringify(message) + "\n");
    });
}

async function runTests() {
    // Arrancar el servidor como proceso hijo
    const server = spawn("node", ["index.js"], {
        stdio: ["pipe", "pipe", "pipe"]
    });

    let passed = 0;
    let failed = 0;

    // Test 1: Initialize
    const initResponse = await sendMessage(server, {
        jsonrpc: "2.0", id: 1, method: "initialize",
        params: {
            protocolVersion: "2025-03-26",
            capabilities: {},
            clientInfo: { name: "test", version: "1.0.0" }
        }
    });

    if (initResponse.result?.serverInfo?.name) {
        console.log("PASS: Initialize");
        passed++;
    } else {
        console.log("FAIL: Initialize", initResponse);
        failed++;
    }

    // Enviar initialized (no esperar respuesta — es notificacion)
    server.stdin.write(JSON.stringify({
        jsonrpc: "2.0", method: "notifications/initialized", params: {}
    }) + "\n");

    // Test 2: Tools List
    const listResponse = await sendMessage(server, {
        jsonrpc: "2.0", id: 2, method: "tools/list", params: {}
    });

    if (listResponse.result?.tools?.length > 0) {
        console.log(`PASS: Tools List (${listResponse.result.tools.length} tools)`);
        passed++;
    } else {
        console.log("FAIL: Tools List", listResponse);
        failed++;
    }

    // Test 3: Tool Call exitoso
    const callResponse = await sendMessage(server, {
        jsonrpc: "2.0", id: 3, method: "tools/call",
        params: { name: "saludar", arguments: { nombre: "Test" } }
    });

    if (callResponse.result?.content?.[0]?.text?.includes("Test")) {
        console.log("PASS: Tool Call");
        passed++;
    } else {
        console.log("FAIL: Tool Call", callResponse);
        failed++;
    }

    // Test 4: Tool Call con error
    const errorResponse = await sendMessage(server, {
        jsonrpc: "2.0", id: 4, method: "tools/call",
        params: { name: "tool_inexistente", arguments: {} }
    });

    if (errorResponse.result?.isError || errorResponse.error) {
        console.log("PASS: Error handling");
        passed++;
    } else {
        console.log("FAIL: Error handling", errorResponse);
        failed++;
    }

    // Resumen
    console.log(`\nResultados: ${passed} passed, ${failed} failed`);

    server.kill();
    process.exit(failed > 0 ? 1 : 0);
}

runTests();
```

#### 4. Testing de integracion con Claude Code

El test final es usar tu MCP con Claude Code en una conversacion real:

1. Configura el MCP en `.mcp.json`
2. Reinicia Claude Code
3. Verifica que Claude detecta las herramientas: "Que herramientas MCP tienes disponibles?"
4. Pide que use cada tool con inputs normales
5. Pide que use tools con inputs problematicos (strings vacios, numeros negativos)
6. Observa los logs de tu servidor (stderr) para verificar que todo funciona

---

## Errores Comunes

### 1. Mezclar stdout y debug prints

```swift
// MAL — print() en Swift escribe a stdout, rompiendo el canal MCP
print("Debug: procesando request...")

// BIEN — escribir a stderr para debug
FileHandle.standardError.write(
    "Debug: procesando request...\n".data(using: .utf8)!
)

// BIEN — en Node.js
console.error("Debug: procesando request...");
```

Este es el error #1 mas comun. Una sola linea de `print()` o `console.log()` rompe toda la comunicacion.

### 2. No manejar respuestas grandes

```javascript
// MAL — devolver un archivo de 10MB como texto
// El agente tiene limite de contexto y esto puede causar problemas
async ({ ruta }) => {
    const contenido = await fs.readFile(ruta, "utf-8");
    return { content: [{ type: "text", text: contenido }] };  // 10MB de texto!
}

// BIEN — truncar o paginar
async ({ ruta }) => {
    const contenido = await fs.readFile(ruta, "utf-8");
    const MAX_CHARS = 50000;  // ~50KB es un limite razonable

    if (contenido.length > MAX_CHARS) {
        const truncado = contenido.substring(0, MAX_CHARS);
        return {
            content: [{
                type: "text",
                text: truncado + `\n\n[... truncado, ${contenido.length - MAX_CHARS} caracteres restantes]`
            }]
        };
    }

    return { content: [{ type: "text", text: contenido }] };
}
```

### 3. No validar parametros de entrada

```swift
// MAL — confiar ciegamente en los argumentos
case "leer_archivo":
    let ruta = argumentos["ruta"] as! String  // Crashea si no es String
    let contenido = try! String(contentsOfFile: ruta)  // Crashea si no existe

// BIEN — validar todo
case "leer_archivo":
    guard let ruta = argumentos["ruta"] as? String else {
        return ("Error: parametro 'ruta' es requerido y debe ser un string", true)
    }

    guard FileManager.default.fileExists(atPath: ruta) else {
        return ("Error: el archivo '\(ruta)' no existe", true)
    }

    do {
        let contenido = try String(contentsOfFile: ruta, encoding: .utf8)
        return (contenido, false)
    } catch {
        return ("Error leyendo archivo: \(error.localizedDescription)", true)
    }
```

### 4. Un tool gigante en vez de tools pequenos y enfocados

```javascript
// MAL — un super-tool que hace todo
server.tool("gestionar_proyecto", "Hace todo: buscar, leer, crear, borrar, analizar...", ...);
// El agente no sabe cuando usarlo y los parametros son confusos

// BIEN — tools pequenos y enfocados
server.tool("buscar_archivos", "Busca archivos por patron...", ...);
server.tool("leer_archivo", "Lee el contenido de un archivo...", ...);
server.tool("crear_archivo", "Crea un nuevo archivo...", ...);
server.tool("analizar_proyecto", "Devuelve estadisticas del proyecto...", ...);
// El agente sabe exactamente cuando usar cada uno
```

La regla: cada tool debe hacer UNA cosa y hacerla bien. Es el principio de Single Responsibility aplicado a herramientas MCP.

### 5. Olvidar manejar la senal de shutdown

```swift
// MAL — el servidor no limpia recursos cuando se cierra
// Si el agente cierra la conexion, procesos hijos o archivos temporales
// pueden quedar abiertos

// BIEN — manejar el cierre limpio
import Foundation

// Capturar senales de terminacion
signal(SIGINT) { _ in
    FileHandle.standardError.write(
        "[servidor] Recibido SIGINT, cerrando...\n".data(using: .utf8)!
    )
    // Cerrar bases de datos, limpiar archivos temporales, etc.
    exit(0)
}

signal(SIGTERM) { _ in
    FileHandle.standardError.write(
        "[servidor] Recibido SIGTERM, cerrando...\n".data(using: .utf8)!
    )
    exit(0)
}
```

---

## Ejercicios

### Ejercicio 1 — Basico: Resource de archivos en Node.js

Agrega resources a tu servidor Node.js de la Leccion 47. Implementa:

1. Un resource estatico que expone el contenido de tu `package.json`
2. Un resource template `file:///docs/{nombre}` que lee archivos de un directorio `docs/`
3. Verifica que `resources/list` devuelve ambos resources

**Pista:**

```javascript
import { ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";

server.resource(
    "package-json",
    "file:///package.json",
    async (uri) => ({
        contents: [{
            uri: uri.href,
            mimeType: "application/json",
            text: await fs.readFile("./package.json", "utf-8")
        }]
    })
);
```

**Criterio de exito:** El MCP Inspector muestra tus resources y puedes leer su contenido.

---

### Ejercicio 2 — Intermedio: MCP completo en Swift

Construye un servidor MCP en Swift con tres herramientas:

1. `contar_palabras(texto)` — cuenta palabras
2. `invertir_texto(texto)` — invierte texto y detecta palindromos
3. `analizar_texto(texto)` — estadisticas completas (palabras, caracteres, oraciones, top 5 palabras)

Usa el codigo de la seccion "MCP en Swift" como base. Asegurate de:
- Manejar errores correctamente (nunca force unwrap)
- Escribir debug a stderr, nunca a stdout
- Probar manualmente con echo | swift run

**Criterio de exito:** Los tres tools funcionan correctamente cuando los pruebas con mensajes JSON-RPC manuales y cuando los conectas a Claude Code.

---

### Ejercicio 3 — Avanzado: Busqueda semantica con NLEmbedding

Extiende tu servidor Swift con busqueda semantica:

1. Crea una "base de conocimiento" con 10-15 documentos sobre temas del curriculum (SwiftUI, SwiftData, Concurrencia, etc.)
2. Implementa un tool `buscar_documentacion(consulta, cantidad)` que use NLEmbedding para encontrar los documentos mas relevantes
3. El tool debe devolver titulo, resumen, ruta del archivo y porcentaje de relevancia
4. Prueba con consultas como:
   - "como guardar datos" → debe encontrar la leccion de SwiftData
   - "hacer pantallas bonitas" → debe encontrar lecciones de SwiftUI y HIG
   - "codigo que no se traba" → debe encontrar la leccion de Concurrencia

**Nota:** NLEmbedding requiere macOS. Si `sentenceEmbedding(for: .spanish)` devuelve nil, prueba con `.english` o usa `wordEmbedding` como fallback.

**Criterio de exito:** La busqueda semantica devuelve resultados relevantes incluso cuando las palabras exactas no coinciden con el contenido de los documentos.

---

## Checklist

- [ ] Implementar tools con parametros complejos (opcionales, enums, anidados)
- [ ] Devolver datos estructurados (tablas, listas, multiples content blocks)
- [ ] Manejar errores correctamente con isError: true y mensajes descriptivos
- [ ] Entender la diferencia entre Resources y Tools y cuando usar cada uno
- [ ] Implementar resources estaticos y templates con URIs parametricas
- [ ] Construir un servidor MCP funcional en Swift puro (sin dependencias)
- [ ] Entender que son los embeddings y como capturan significado semantico
- [ ] Usar NLEmbedding de Apple para busqueda semantica on-device
- [ ] Probar un MCP con scripts manuales y MCP Inspector
- [ ] Escribir tests automatizados que verifican el flujo completo

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Con las tecnicas de esta leccion, tu Proyecto Integrador puede tener su propio ecosistema MCP:
- **Servidor Swift MCP** que expone la logica de negocio del proyecto como herramientas
- **Busqueda semantica** en la documentacion del proyecto para que Claude encuentre lo relevante
- **Resources** que exponen el estado de la base de datos SwiftData para debugging
- **Tools de analisis** que calculan estadisticas del codigo (cobertura, complejidad, dependencias)
- **Integracion CI/CD** donde el MCP ejecuta tests y reporta resultados directamente en Claude Code
- **Generacion de codigo** donde Claude usa tus MCPs para crear modelos, vistas y tests que siguen tus patrones

---

*Leccion 48 (L48) | MCP Servidor Completo | Modulo 14: Agentic Coding y MCP*
