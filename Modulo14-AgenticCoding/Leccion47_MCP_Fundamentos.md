# Leccion 47: MCP desde Cero — Fundamentos

**Modulo 14: Agentic Coding y MCP** | Bonus

---

## TL;DR — Resumen en 2 minutos

- **MCP (Model Context Protocol)**: protocolo abierto que conecta agentes IA con herramientas externas
- **Analogia**: MCP es a los agentes lo que HTTP es a la web — un idioma comun para comunicarse
- **JSON-RPC 2.0**: el formato de mensajes que usa MCP (request/response en JSON)
- **stdio**: el canal de comunicacion — el agente habla con tu servidor por la terminal
- **Tools**: funciones que tu servidor expone y el agente puede llamar

> Herramienta: **MCP SDK** (`@modelcontextprotocol/sdk`) para crear servidores MCP en Node.js

---

## Recursos

| Tipo | Recurso | Notas |
|------|---------|-------|
| Oficial | [Model Context Protocol — Spec](https://modelcontextprotocol.io) | **Esencial** — especificacion completa |
| Oficial | [MCP SDK para TypeScript](https://github.com/modelcontextprotocol/typescript-sdk) | SDK oficial para Node.js |
| Oficial | [MCP Servers Repository](https://github.com/modelcontextprotocol/servers) | Ejemplos de servidores reales |
| Blog | [Anthropic — Introducing MCP](https://www.anthropic.com/news/model-context-protocol) | Contexto y motivacion |
| Video | [Building MCP Servers](https://www.youtube.com/results?search_query=building+mcp+servers) | Tutoriales practicos |

---

## Teoria

### Que problema resuelve MCP?

Antes de MCP, cada agente de IA tenia su propia manera de conectarse a datos externos. Si querias que Claude accediera a tu base de datos, escribias un plugin. Si querias que GPT accediera a la misma base de datos, escribias OTRO plugin con una API diferente. Cada combinacion de agente + herramienta requeria codigo custom.

Esto es exactamente lo que pasaba en la web antes de HTTP. Cada navegador hablaba un protocolo diferente con cada servidor. La solucion fue crear un protocolo estandar — HTTP — y de repente cualquier navegador podia hablar con cualquier servidor.

**MCP hace lo mismo para los agentes de IA.** Un protocolo estandar para que cualquier agente pueda usar cualquier herramienta.

```
SIN MCP:
  Claude ──plugin_claude──> Tu base de datos
  GPT ────plugin_gpt─────> Tu base de datos  (codigo diferente!)
  Gemini ──plugin_gemini──> Tu base de datos  (otro codigo mas!)

CON MCP:
  Claude ──MCP──> Tu servidor MCP ──> Tu base de datos
  GPT ────MCP──> Tu servidor MCP ──> Tu base de datos  (mismo servidor!)
  Gemini ──MCP──> Tu servidor MCP ──> Tu base de datos  (mismo servidor!)
```

La ventaja es clara: escribes UN servidor y funciona con TODOS los agentes que soporten MCP.

### Como se comunican? — El flujo completo

Veamos el dialogo completo entre un agente (Claude Code) y tu servidor MCP:

```
Agente IA (Claude Code)              Tu MCP Server
      |                                    |
      |─── 1. initialize ────────────────>│  "Hola, soy Claude Code v1.0"
      |<── 1. response ──────────────────│  "Hola, soy MiServidor v1.0, soporto tools"
      |                                    |
      |─── 2. initialized (notificacion) ─>│  "OK, estamos conectados"
      |                                    |
      |─── 3. tools/list ────────────────>│  "Que herramientas tienes?"
      |<── 3. response ──────────────────│  "Tengo: saludar, buscar, calcular"
      |                                    |
      |─── 4. tools/call ────────────────>│  "Ejecuta: saludar('Jose')"
      |<── 4. response ──────────────────│  "Resultado: Hola, Jose!"
      |                                    |
      |    ... (mas llamadas) ...          |
      |                                    |
      |─── N. shutdown ─────────────────>│  "Adios"
      |                                    |
```

Paso a paso:

1. **initialize**: El agente se presenta. Dice quien es y que version del protocolo habla. El servidor responde con sus capacidades ("yo soporto tools", "yo soporto resources", etc.)
2. **initialized**: El agente confirma que recibio las capacidades. A partir de aqui, la conexion esta activa.
3. **tools/list**: El agente pide la lista de herramientas disponibles. El servidor responde con nombre, descripcion y parametros de cada tool.
4. **tools/call**: El agente invoca una herramienta especifica con argumentos. El servidor ejecuta la funcion y devuelve el resultado.

Este ciclo de tools/call se repite tantas veces como sea necesario. El agente decide cuando y que herramientas usar basandose en la conversacion con el usuario.

### Anatomia del protocolo — JSON-RPC 2.0

MCP usa JSON-RPC 2.0 como formato de mensajes. No inventa nada nuevo — reutiliza un estandar que ya existe desde 2010. Vamos a desmenuzarlo:

**Un request (agente envia al servidor):**

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list",
    "params": {}
}
```

Cada campo tiene un proposito:

| Campo | Significado |
|-------|-------------|
| `jsonrpc` | Siempre "2.0" — indica la version del protocolo JSON-RPC |
| `id` | Numero unico que identifica esta peticion. El servidor lo devuelve en la respuesta para que el agente sepa a que peticion corresponde |
| `method` | El "verbo" — que quieres hacer. Ejemplos: `initialize`, `tools/list`, `tools/call` |
| `params` | Los argumentos del metodo. Puede ser un objeto vacio `{}` o tener datos |

**Un response (servidor responde al agente):**

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "tools": [
            {
                "name": "saludar",
                "description": "Saluda a una persona por su nombre",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "nombre": {
                            "type": "string",
                            "description": "Nombre de la persona a saludar"
                        }
                    },
                    "required": ["nombre"]
                }
            }
        ]
    }
}
```

Observa que el `id: 1` de la respuesta coincide con el `id: 1` del request. Asi el agente sabe que esta respuesta corresponde a su pregunta "tools/list".

**Un error (cuando algo sale mal):**

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32601,
        "message": "Method not found: tools/llamar"
    }
}
```

Los errores tienen un codigo numerico y un mensaje descriptivo. Los codigos negativos estan definidos por JSON-RPC (por ejemplo, -32601 = metodo no encontrado).

### Transport Layer — Como viajan los mensajes

Los mensajes JSON-RPC necesitan un "canal" para viajar entre el agente y tu servidor. MCP soporta tres transportes:

**1. stdio (Standard Input/Output)** — El mas comun para desarrollo local

```
Agente                          Tu Servidor (proceso hijo)
   |                                  |
   |── escribe en stdin del proceso ─>│  (el agente envia JSON por stdin)
   |<── lee de stdout del proceso ───│  (el servidor responde por stdout)
```

El agente lanza tu servidor como un proceso hijo y se comunica por la terminal. Cada mensaje es una linea de JSON. Es como un chat por texto donde cada mensaje es un JSON.

**Por que stdio?** Porque es el transporte mas simple. No necesitas un servidor web, ni puertos, ni configuracion de red. Solo un programa que lee de stdin y escribe a stdout.

**Regla critica:** Si tu servidor imprime algo por `stdout` que NO sea un mensaje JSON-RPC valido, el agente se confunde y la conexion se rompe. Todo output de debug va a `stderr`.

**2. SSE (Server-Sent Events)** — Para servidores web

El servidor corre como un servicio HTTP. El agente se conecta por HTTP y recibe eventos. Util para servidores remotos.

**3. Streamable HTTP** — El mas nuevo

Similar a SSE pero mas eficiente. Soporta streaming bidireccional.

Para esta leccion usaremos **stdio** — es el transporte que usa Claude Code por defecto.

### Las 3 primitivas de MCP

MCP define tres tipos de cosas que tu servidor puede exponer:

#### 1. Tools — Funciones que el agente ejecuta

Los tools son el corazon de MCP. Son funciones que el agente puede llamar para realizar acciones.

```
Tool = funcion con nombre + descripcion + parametros + resultado
```

Ejemplos reales:
- `buscar_archivos(patron)` — busca archivos en el sistema
- `ejecutar_query(sql)` — ejecuta una consulta SQL
- `crear_ticket(titulo, descripcion)` — crea un ticket en Jira

El agente decide cuando llamar a un tool basandose en la conversacion. Si el usuario dice "busca archivos Python", el agente llama a `buscar_archivos("*.py")`.

#### 2. Resources — Datos que el agente lee

Los resources son como endpoints GET de una API REST. El agente los lee para obtener informacion, pero no ejecuta acciones.

```
Resource = URI + nombre + descripcion + contenido
```

Ejemplos:
- `file:///proyecto/README.md` — contenido de un archivo
- `db://usuarios/123` — datos de un usuario
- `config://settings` — configuracion actual

#### 3. Prompts — Plantillas reutilizables

Los prompts son plantillas de texto que el agente puede usar. Son menos comunes pero utiles para workflows estandarizados.

```
Prompt = nombre + descripcion + argumentos + template
```

Ejemplo: un prompt "code-review" que genera instrucciones estandarizadas para revisar codigo.

**En la practica, el 90% de los servidores MCP solo usan Tools.** Resources y Prompts son utiles pero opcionales. Esta leccion se enfoca en Tools.

### Tu primer MCP Server — Paso a paso

Vamos a construir el servidor MCP mas simple posible. Un servidor con una sola herramienta: `saludar`, que recibe un nombre y devuelve "Hola, {nombre}!".

#### Paso 1: Crear el proyecto

```bash
# Crear directorio del proyecto
mkdir mi-primer-mcp
cd mi-primer-mcp

# Inicializar proyecto Node.js
npm init -y

# Instalar el SDK oficial de MCP
npm install @modelcontextprotocol/sdk
```

El SDK de MCP te da todas las clases y tipos necesarios para crear un servidor. Sin el, tendrias que parsear JSON-RPC manualmente (posible, pero tedioso).

#### Paso 2: Configurar package.json

Abre `package.json` y asegurate de que tenga el campo `type: "module"` para poder usar `import`:

```json
{
    "name": "mi-primer-mcp",
    "version": "1.0.0",
    "type": "module",
    "main": "index.js",
    "dependencies": {
        "@modelcontextprotocol/sdk": "^1.12.0"
    }
}
```

El campo `"type": "module"` le dice a Node.js que use ES modules (`import/export`) en lugar de CommonJS (`require`). El SDK de MCP usa ES modules.

#### Paso 3: Crear index.js — El servidor completo

Este es el archivo completo. Leelo primero de corrido y luego lo desmenuzamos linea por linea:

```javascript
// index.js — Mi primer servidor MCP
// Este servidor expone una herramienta "saludar" que saluda a una persona

// ============================================================
// IMPORTS
// ============================================================

// McpServer: la clase principal que representa tu servidor MCP.
// Maneja el ciclo de vida (initialize, list tools, call tools).
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";

// StdioServerTransport: el "canal" de comunicacion.
// Lee JSON de stdin, escribe JSON a stdout.
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

// z: libreria Zod para definir esquemas de validacion.
// MCP la usa para describir los parametros de cada tool.
import { z } from "zod";

// ============================================================
// CREAR EL SERVIDOR
// ============================================================

// Creamos una instancia del servidor con su nombre y version.
// Estos datos se envian al agente durante el "initialize".
const server = new McpServer({
    name: "mi-primer-mcp",    // Nombre que el agente vera
    version: "1.0.0"          // Version de tu servidor
});

// ============================================================
// REGISTRAR HERRAMIENTAS (TOOLS)
// ============================================================

// server.tool() registra una herramienta.
// Parametros:
//   1. Nombre del tool (string unico)
//   2. Descripcion (el agente la lee para decidir cuando usarlo)
//   3. Esquema de parametros (define que datos necesita el tool)
//   4. Funcion handler (que hace el tool cuando lo llaman)

server.tool(
    // Nombre: identificador unico de la herramienta
    "saludar",

    // Descripcion: el agente lee esto para entender CUANDO usar esta herramienta.
    // Debe ser clara y especifica. Si la descripcion es vaga, el agente no sabra
    // cuando invocarla.
    "Saluda a una persona por su nombre. Usa esta herramienta cuando el usuario " +
    "pida saludar o dar la bienvenida a alguien.",

    // Esquema de parametros usando Zod.
    // Esto se convierte internamente en JSON Schema, que es lo que MCP
    // usa para describir los parametros al agente.
    {
        nombre: z.string().describe("Nombre de la persona a saludar")
    },

    // Handler: la funcion que se ejecuta cuando el agente llama a este tool.
    // Recibe un objeto con los parametros ya validados por Zod.
    // DEBE retornar un objeto con { content: [{ type: "text", text: "..." }] }
    async ({ nombre }) => {
        // Toda la logica de tu herramienta va aqui.
        // En este caso es trivial, pero podria ser una consulta a una DB,
        // una llamada a una API, lectura de archivos, etc.
        const saludo = `Hola, ${nombre}! Bienvenido al mundo de MCP.`;

        // El formato de respuesta es SIEMPRE un array de content blocks.
        // Cada block tiene un type ("text", "image", "resource") y su contenido.
        // Para la mayoria de casos, un solo block de texto es suficiente.
        return {
            content: [
                {
                    type: "text",     // Tipo de contenido
                    text: saludo      // El texto que el agente recibira
                }
            ]
        };
    }
);

// ============================================================
// CONECTAR Y ARRANCAR
// ============================================================

// Crear el transporte stdio.
// Este objeto maneja la lectura de stdin y escritura a stdout.
const transport = new StdioServerTransport();

// Conectar el servidor al transporte.
// A partir de este momento, el servidor esta escuchando mensajes JSON-RPC
// por stdin y respondiendo por stdout.
// await porque connect() es async — espera a que la conexion se establezca.
await server.connect(transport);

// NOTA IMPORTANTE: No uses console.log() en un servidor MCP.
// console.log escribe a stdout, que es el canal de MCP.
// Si imprimes algo que no sea JSON-RPC, rompes la comunicacion.
// Para debug, usa console.error() que escribe a stderr.
console.error("Servidor MCP iniciado correctamente");
```

#### Paso 4: Entender cada pieza

Repasemos los conceptos clave del codigo anterior:

**McpServer** es la clase que maneja todo el protocolo por ti:
- Responde automaticamente a `initialize` con tu nombre y version
- Responde a `tools/list` con las herramientas que registraste
- Despacha `tools/call` al handler correcto basandose en el nombre del tool
- Maneja errores y los formatea como JSON-RPC errors

**StdioServerTransport** es el "cable" que conecta tu servidor con el agente:
- Lee lineas de texto de stdin
- Parsea cada linea como JSON
- Pasa el JSON al McpServer
- Toma la respuesta del McpServer y la escribe a stdout como JSON

**z (Zod)** describe los parametros de tus herramientas:
- `z.string()` = el parametro es un string
- `z.number()` = el parametro es un numero
- `z.boolean()` = el parametro es un booleano
- `z.enum(["a", "b"])` = el parametro solo acepta "a" o "b"
- `.describe("...")` = descripcion que el agente lee para saber que poner
- `.optional()` = el parametro no es obligatorio

**El formato de respuesta** es siempre el mismo:

```javascript
{
    content: [
        { type: "text", text: "tu resultado aqui" }
    ]
}
```

Puedes devolver multiples blocks:

```javascript
{
    content: [
        { type: "text", text: "Titulo del resultado" },
        { type: "text", text: "Detalle adicional..." }
    ]
}
```

#### Paso 5: Probar manualmente

Podemos probar el servidor sin necesidad de un agente. Simplemente enviamos JSON-RPC por stdin:

```bash
# Primero, probemos que el servidor arranca sin errores
node index.js < /dev/null
# Deberia imprimir "Servidor MCP iniciado correctamente" en stderr y salir
```

Para una prueba completa, necesitamos enviar el handshake de inicializacion y luego las peticiones. Creemos un archivo de test:

```bash
# test_manual.sh — Script para probar el servidor manualmente
# Cada linea es un mensaje JSON-RPC separado

# Paso 1: initialize — el agente se presenta
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}'

# Paso 2: notificacion initialized — confirmar conexion
echo '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'

# Paso 3: listar herramientas
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'

# Paso 4: llamar a saludar
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"saludar","arguments":{"nombre":"Jose"}}}'
```

Ejecutalo asi:

```bash
# Ejecutar los mensajes de test y ver las respuestas
bash test_manual.sh | node index.js
```

Veras tres respuestas JSON (una por cada request con `id`):

1. La respuesta a `initialize` con las capacidades del servidor
2. La respuesta a `tools/list` con la herramienta "saludar"
3. La respuesta a `tools/call` con "Hola, Jose! Bienvenido al mundo de MCP."

La notificacion `initialized` no genera respuesta porque las notificaciones en JSON-RPC no tienen `id` y no esperan respuesta.

#### Paso 6: Conectar a Claude Code

Para que Claude Code use tu servidor MCP, necesitas configurarlo. Hay dos opciones:

**Opcion A: Configuracion por proyecto** (recomendado para desarrollo)

Crea un archivo `.mcp.json` en la raiz de tu proyecto:

```json
{
    "mcpServers": {
        "mi-primer-mcp": {
            "command": "node",
            "args": ["/ruta/completa/a/mi-primer-mcp/index.js"]
        }
    }
}
```

**Opcion B: Configuracion global**

Edita `~/.claude/claude_desktop_config.json`:

```json
{
    "mcpServers": {
        "mi-primer-mcp": {
            "command": "node",
            "args": ["/ruta/completa/a/mi-primer-mcp/index.js"]
        }
    }
}
```

Despues de configurarlo, reinicia Claude Code. Deberia detectar automaticamente tu servidor MCP y la herramienta "saludar" estara disponible. Puedes verificarlo diciendo: "Saluda a Maria usando tu herramienta".

### Expandiendo el servidor — Un segundo tool

Agreguemos una segunda herramienta para ver como conviven multiples tools en un mismo servidor:

```javascript
// Agregar despues del tool "saludar" y antes del transport

server.tool(
    "calcular",

    "Realiza operaciones matematicas basicas. Usa esta herramienta cuando el usuario " +
    "pida calcular, sumar, restar, multiplicar o dividir numeros.",

    {
        operacion: z.enum(["sumar", "restar", "multiplicar", "dividir"])
            .describe("La operacion matematica a realizar"),
        a: z.number().describe("Primer numero"),
        b: z.number().describe("Segundo numero")
    },

    async ({ operacion, a, b }) => {
        let resultado;

        switch (operacion) {
            case "sumar":
                resultado = a + b;
                break;
            case "restar":
                resultado = a - b;
                break;
            case "multiplicar":
                resultado = a * b;
                break;
            case "dividir":
                if (b === 0) {
                    // Cuando algo sale mal, devolvemos isError: true
                    // Esto le dice al agente que la operacion fallo
                    return {
                        content: [{ type: "text", text: "Error: division por cero" }],
                        isError: true
                    };
                }
                resultado = a / b;
                break;
        }

        return {
            content: [
                {
                    type: "text",
                    text: `${a} ${operacion} ${b} = ${resultado}`
                }
            ]
        };
    }
);
```

Puntos clave de este segundo tool:

1. **z.enum()** restringe los valores posibles. El agente solo puede pasar "sumar", "restar", "multiplicar" o "dividir".
2. **z.number()** valida que `a` y `b` sean numeros. Si el agente pasa un string, Zod lo rechaza antes de que llegue a tu handler.
3. **isError: true** es la forma correcta de reportar errores al agente. No lances excepciones — devuelve una respuesta con `isError: true`.

### Como piensa el agente

Un punto crucial para disenar buenos tools: el agente lee las **descripciones** de tus herramientas para decidir cual usar. Si el usuario dice "cuanto es 5 por 3", el agente:

1. Lee la lista de tools disponibles
2. Ve que "calcular" dice "operaciones matematicas... multiplicar"
3. Decide invocar `calcular` con `{ operacion: "multiplicar", a: 5, b: 3 }`
4. Recibe "5 multiplicar 3 = 15"
5. Presenta el resultado al usuario

Por eso las descripciones deben ser **claras, especificas y con ejemplos de cuando usar el tool**. Una descripcion vaga como "hace cosas con numeros" no le da suficiente contexto al agente.

---

## Errores Comunes

### 1. Olvidar el handshake de initialize

```javascript
// MAL — enviar tools/call sin haber hecho initialize primero
// El servidor rechazara la peticion porque no se ha establecido la conexion

// BIEN — siempre respetar el orden:
// 1. initialize (request/response)
// 2. initialized (notificacion)
// 3. tools/list, tools/call, etc.
```

### 2. inputSchema mal definido

```javascript
// MAL — sin descripcion, el agente no sabe que poner en cada campo
{
    x: z.string(),
    y: z.string()
}

// BIEN — descripciones claras que guian al agente
{
    ruta_archivo: z.string().describe("Ruta absoluta al archivo a leer, ej: /Users/jose/mi-archivo.txt"),
    codificacion: z.string().optional().describe("Codificacion del archivo: utf-8, latin1, etc. Por defecto utf-8")
}
```

### 3. Formato de respuesta incorrecto

```javascript
// MAL — devolver un string directamente
async ({ nombre }) => {
    return `Hola, ${nombre}!`;  // ERROR: MCP espera un objeto con content
}

// MAL — devolver content como string
async ({ nombre }) => {
    return { content: `Hola, ${nombre}!` };  // ERROR: content debe ser un ARRAY
}

// BIEN — formato correcto
async ({ nombre }) => {
    return {
        content: [{ type: "text", text: `Hola, ${nombre}!` }]
    };
}
```

### 4. Usar console.log en lugar de console.error

```javascript
// MAL — console.log escribe a stdout, que es el canal MCP
// Esto inyecta texto no-JSON en el flujo de mensajes y rompe todo
console.log("Procesando peticion...");

// BIEN — console.error escribe a stderr, que es seguro para debug
console.error("Procesando peticion...");

// BIEN — tambien puedes usar process.stderr directamente
process.stderr.write("Debug: parametros recibidos: " + JSON.stringify(params) + "\n");
```

### 5. No manejar errores en el handler

```javascript
// MAL — si readFile falla, el servidor crashea y el agente pierde la conexion
async ({ ruta }) => {
    const contenido = fs.readFileSync(ruta, "utf-8");  // puede lanzar excepcion!
    return { content: [{ type: "text", text: contenido }] };
}

// BIEN — capturar errores y devolver respuesta con isError
async ({ ruta }) => {
    try {
        const contenido = fs.readFileSync(ruta, "utf-8");
        return { content: [{ type: "text", text: contenido }] };
    } catch (error) {
        return {
            content: [{ type: "text", text: `Error leyendo archivo: ${error.message}` }],
            isError: true
        };
    }
}
```

---

## Ejercicios

### Ejercicio 1 — Basico: Tu primer servidor MCP

Construye el servidor "saludar" exactamente como se describe en la leccion y pruebaolo manualmente.

**Objetivo:** Verificar que entiendes el flujo completo desde crear el proyecto hasta ver la respuesta.

```bash
# 1. Crear el proyecto
mkdir mi-primer-mcp && cd mi-primer-mcp
npm init -y
npm install @modelcontextprotocol/sdk

# 2. Crear index.js con el codigo de la leccion

# 3. Probar con el script test_manual.sh

# 4. Verificar que ves la respuesta "Hola, Jose!"
```

**Criterio de exito:** Ves la respuesta JSON con "Hola, Jose! Bienvenido al mundo de MCP." en la terminal.

---

### Ejercicio 2 — Intermedio: Servidor con multiples herramientas

Extiende tu servidor para incluir tres herramientas:

1. `saludar(nombre)` — la que ya tienes
2. `calcular(operacion, a, b)` — operaciones matematicas
3. `fecha_actual(formato)` — devuelve la fecha actual en formato corto ("23/03/2026") o largo ("lunes 23 de marzo de 2026")

**Pista para `fecha_actual`:**

```javascript
server.tool(
    "fecha_actual",
    "Devuelve la fecha y hora actual...",
    {
        formato: z.enum(["corto", "largo"])
            .describe("Formato: 'corto' = DD/MM/AAAA, 'largo' = dia completo con nombre del mes")
    },
    async ({ formato }) => {
        const ahora = new Date();
        let texto;

        if (formato === "corto") {
            texto = ahora.toLocaleDateString("es-ES");
        } else {
            texto = ahora.toLocaleDateString("es-ES", {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric"
            });
        }

        return { content: [{ type: "text", text: texto }] };
    }
);
```

**Criterio de exito:** `tools/list` devuelve 3 herramientas y todas funcionan correctamente.

---

### Ejercicio 3 — Avanzado: Conectar a Claude Code

1. Configura tu servidor MCP en Claude Code creando `.mcp.json`
2. Reinicia Claude Code
3. Pide a Claude que use tus herramientas:
   - "Saluda a Maria"
   - "Cuanto es 145 multiplicado por 23?"
   - "Que dia es hoy en formato largo?"

**Criterio de exito:** Claude Code usa tus herramientas automaticamente sin que tengas que pedirle explicitamente que las use. Veras en el output que Claude invoca `saludar`, `calcular` y `fecha_actual`.

---

## Checklist

- [ ] Entender que problema resuelve MCP y por que se creo
- [ ] Explicar la analogia MCP/HTTP con tus propias palabras
- [ ] Describir el formato JSON-RPC 2.0 (request, response, error)
- [ ] Entender los tres transportes (stdio, SSE, streamable HTTP) y cuando usar cada uno
- [ ] Diferenciar las tres primitivas (Tools, Resources, Prompts)
- [ ] Crear un proyecto Node.js con el SDK de MCP desde cero
- [ ] Registrar un tool con nombre, descripcion, esquema Zod y handler
- [ ] Probar el servidor manualmente con JSON por stdin
- [ ] Conectar el servidor a Claude Code via `.mcp.json`
- [ ] Evitar los 5 errores comunes (initialize, schema, formato, console.log, errores)

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

MCP abre una dimension completamente nueva para tu Proyecto Integrador:
- **Herramientas custom** que Claude Code puede usar para interactuar con tu proyecto
- **Automatizacion** de tareas repetitivas (generar modelos, crear vistas, ejecutar tests)
- **Acceso a datos** del proyecto desde el agente (buscar en SwiftData, leer configuraciones)
- **Integracion con APIs** externas que el agente puede invocar durante el desarrollo
- **Workflow de desarrollo** donde Claude Code usa tus MCPs para ser mas eficiente en tu proyecto especifico

---

*Leccion 47 (L47) | MCP Fundamentos | Modulo 14: Agentic Coding y MCP*
*Siguiente: Leccion 48 — MCP Servidor Completo*
