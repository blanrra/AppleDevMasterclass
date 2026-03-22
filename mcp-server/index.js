import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Find all Leccion*.md files across every Modulo* directory.
 */
function findLessonFiles() {
  const moduleDirs = fs
    .readdirSync(ROOT)
    .filter((d) => d.startsWith("Modulo") && fs.statSync(path.join(ROOT, d)).isDirectory());

  const lessons = [];
  for (const mod of moduleDirs) {
    const modPath = path.join(ROOT, mod);
    const files = fs.readdirSync(modPath).filter((f) => f.startsWith("Leccion") && f.endsWith(".md"));
    for (const file of files) {
      const match = file.match(/Leccion(\d+)/);
      if (match) {
        lessons.push({
          id: `L${match[1]}`,
          num: parseInt(match[1], 10),
          file: path.join(modPath, file),
          module: mod,
          fileName: file,
        });
      }
    }
  }
  return lessons.sort((a, b) => a.num - b.num);
}

/**
 * Extract the TL;DR and Checklist sections from a lesson file.
 */
function extractLessonSummary(filePath) {
  try {
    const content = fs.readFileSync(filePath, "utf-8");
    const lines = content.split("\n");

    const titleLine = lines.find((l) => l.startsWith("# "));
    const title = titleLine ? titleLine.replace(/^#\s+/, "") : path.basename(filePath);

    let tldr = "";
    let inTldr = false;
    for (const line of lines) {
      if (line.match(/^##\s+TL;DR/)) {
        inTldr = true;
        continue;
      }
      if (inTldr && line.match(/^##\s/) && !line.match(/TL;DR/)) {
        break;
      }
      if (inTldr) {
        tldr += line + "\n";
      }
    }

    let checklist = "";
    let inChecklist = false;
    for (const line of lines) {
      if (line.match(/^##\s+Checklist/)) {
        inChecklist = true;
        continue;
      }
      if (inChecklist && line.match(/^##\s/) && !line.match(/Checklist/)) {
        break;
      }
      if (inChecklist) {
        checklist += line + "\n";
      }
    }

    return { title, tldr: tldr.trim(), checklist: checklist.trim() };
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Curriculum data
// ---------------------------------------------------------------------------

const MODULES = [
  { id: "00", name: "Fundamentos", weeks: "1-12", lessons: "L01-L10", topics: "Programacion desde cero, Swift 6, POP, Genericos, Errores, Memoria, Concurrencia, Xcode, SwiftUI basico" },
  { id: "01", name: "Arquitectura", weeks: "13-14", lessons: "L11-L12", topics: "MVVM, Clean Architecture, Inyeccion de dependencias" },
  { id: "02", name: "Diseno y UX", weeks: "15-16", lessons: "L13-L14", topics: "HIG, Liquid Glass, SF Symbols, Accesibilidad" },
  { id: "03", name: "SwiftUI Avanzado", weeks: "17-22", lessons: "L15-L18", topics: "Navegacion, Composicion, Listas, Animaciones" },
  { id: "04", name: "Datos y Persistencia", weeks: "23-26", lessons: "L19-L21", topics: "SwiftData, CloudKit, Networking" },
  { id: "05", name: "Hardware y Sensores", weeks: "27-30", lessons: "L22-L24", topics: "HealthKit, Location/Maps, Camera/Photos" },
  { id: "06", name: "IA y ML", weeks: "31-34", lessons: "L25-L27", topics: "Foundation Models, ImagePlayground, CoreML/Vision" },
  { id: "07", name: "Integracion Sistema", weeks: "35-38", lessons: "L28-L30", topics: "App Intents, Siri, Widgets, Live Activities, Notificaciones" },
  { id: "08", name: "Plataformas", weeks: "39-42", lessons: "L31-L33", topics: "watchOS, visionOS, macOS, iPadOS" },
  { id: "09", name: "Testing y Calidad", weeks: "43-46", lessons: "L34-L36", topics: "XCTest, Swift Testing, UI Testing, SwiftLint" },
  { id: "10", name: "Seguridad y Performance", weeks: "47-48", lessons: "L37-L38", topics: "CryptoKit, Privacy Manifests, Instruments" },
  { id: "11", name: "Monetizacion y Distribucion", weeks: "49-50", lessons: "L39-L40", topics: "StoreKit 2, App Store, TestFlight" },
  { id: "12", name: "Extras y Especializacion", weeks: "51-52", lessons: "L41-L44", topics: "Server-Side Swift, Metal, Combine, Open Source" },
];

const ENTRY_POINTS = [
  { level: 1, profile: "Nunca ha programado", entry: "Modulo 00, Leccion L01", weeks: "~60 semanas" },
  { level: 2, profile: "Programa en otro lenguaje", entry: "Modulo 00, Leccion L03+", weeks: "~52 semanas" },
  { level: 3, profile: "Conoce Swift y SwiftUI basico", entry: "Modulo 01+", weeks: "~44 semanas" },
  { level: 4, profile: "Dev iOS experimentado", entry: "Modulo 05+", weeks: "~30 semanas" },
];

// ---------------------------------------------------------------------------
// MCP Server
// ---------------------------------------------------------------------------

const server = new Server(
  { name: "appledevmasterclass", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "curriculum_overview",
      description:
        "Devuelve la vista general del curriculum AppleDevMasterclass: todos los modulos con sus semanas, lecciones y temas clave.",
      inputSchema: { type: "object", properties: {}, required: [] },
    },
    {
      name: "lesson_detail",
      description:
        "Devuelve el detalle de una leccion: titulo, TL;DR y checklist de objetivos. Acepta un lesson_id como 'L15' o '15'.",
      inputSchema: {
        type: "object",
        properties: {
          lesson_id: {
            type: "string",
            description: "Identificador de la leccion, por ejemplo 'L15' o '15'",
          },
        },
        required: ["lesson_id"],
      },
    },
    {
      name: "search_topic",
      description:
        "Busca un tema o palabra clave en todo el curriculum (archivos de lecciones). Devuelve las lecciones que mencionan el termino.",
      inputSchema: {
        type: "object",
        properties: {
          query: {
            type: "string",
            description: "Palabra clave o tema a buscar, por ejemplo 'SwiftData', 'concurrencia', 'animation'",
          },
        },
        required: ["query"],
      },
    },
    {
      name: "student_level",
      description:
        "Recomienda el punto de entrada al curriculum segun la experiencia del estudiante.",
      inputSchema: {
        type: "object",
        properties: {
          experience: {
            type: "string",
            description: "Descripcion de la experiencia del estudiante, por ejemplo 'nunca he programado', '5 anos de iOS', 'se Python pero no Swift'",
          },
        },
        required: ["experience"],
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "curriculum_overview": {
      let text = "# AppleDevMasterclass — Curriculum Overview\n\n";
      text += "Duracion: ~60 semanas | 14 modulos | 48 lecciones | iOS 26 / Swift 6.2\n\n";
      text += "| Modulo | Nombre | Semanas | Lecciones | Temas |\n";
      text += "|--------|--------|---------|-----------|-------|\n";
      for (const m of MODULES) {
        text += `| ${m.id} | ${m.name} | ${m.weeks} | ${m.lessons} | ${m.topics} |\n`;
      }
      text += "\n## Proyecto Integrador\n";
      text += "App completa que se construye incrementalmente desde la semana 24, integrando SwiftData, sensores, IA, widgets, testing y publicacion en TestFlight.\n";
      return { content: [{ type: "text", text }] };
    }

    case "lesson_detail": {
      const rawId = args.lesson_id || "";
      const numStr = rawId.replace(/^L/i, "");
      const num = parseInt(numStr, 10);
      if (isNaN(num)) {
        return {
          content: [{ type: "text", text: `Error: lesson_id invalido '${rawId}'. Usa formato como 'L15' o '15'.` }],
          isError: true,
        };
      }

      const lessons = findLessonFiles();
      const lesson = lessons.find((l) => l.num === num);
      if (!lesson) {
        const available = lessons.map((l) => l.id).join(", ");
        return {
          content: [{ type: "text", text: `No se encontro la leccion L${num}. Lecciones disponibles: ${available}` }],
          isError: true,
        };
      }

      const summary = extractLessonSummary(lesson.file);
      if (!summary) {
        return {
          content: [{ type: "text", text: `No se pudo leer el archivo de la leccion L${num}.` }],
          isError: true,
        };
      }

      let text = `# ${summary.title}\n`;
      text += `**Modulo**: ${lesson.module} | **Archivo**: ${lesson.fileName}\n\n`;
      if (summary.tldr) {
        text += `## TL;DR\n${summary.tldr}\n\n`;
      }
      if (summary.checklist) {
        text += `## Checklist\n${summary.checklist}\n`;
      }
      if (!summary.tldr && !summary.checklist) {
        const content = fs.readFileSync(lesson.file, "utf-8");
        text += content.split("\n").slice(0, 50).join("\n");
      }

      return { content: [{ type: "text", text }] };
    }

    case "search_topic": {
      const query = (args.query || "").toLowerCase();
      if (!query) {
        return {
          content: [{ type: "text", text: "Error: se requiere un parametro 'query'." }],
          isError: true,
        };
      }

      const lessons = findLessonFiles();
      const matches = [];

      for (const lesson of lessons) {
        try {
          const content = fs.readFileSync(lesson.file, "utf-8").toLowerCase();
          if (content.includes(query)) {
            const count = content.split(query).length - 1;
            const lines = fs.readFileSync(lesson.file, "utf-8").split("\n");
            const titleLine = lines.find((l) => l.startsWith("# "));
            const title = titleLine ? titleLine.replace(/^#\s+/, "") : lesson.fileName;
            matches.push({ id: lesson.id, title, module: lesson.module, count });
          }
        } catch {
          // skip unreadable files
        }
      }

      const moduleMatches = [];
      for (const m of MODULES) {
        if (m.topics.toLowerCase().includes(query) || m.name.toLowerCase().includes(query)) {
          moduleMatches.push(m);
        }
      }

      let text = `# Resultados para "${args.query}"\n\n`;

      if (moduleMatches.length > 0) {
        text += "## Modulos relacionados\n";
        for (const m of moduleMatches) {
          text += `- **Modulo ${m.id}: ${m.name}** (Semanas ${m.weeks}) — ${m.topics}\n`;
        }
        text += "\n";
      }

      if (matches.length > 0) {
        text += "## Lecciones que mencionan el tema\n";
        matches.sort((a, b) => b.count - a.count);
        for (const m of matches) {
          text += `- **${m.id}**: ${m.title} (${m.module}) — ${m.count} menciones\n`;
        }
      }

      if (matches.length === 0 && moduleMatches.length === 0) {
        text += "No se encontraron resultados. Intenta con otro termino o en ingles/espanol.\n";
      }

      return { content: [{ type: "text", text }] };
    }

    case "student_level": {
      const exp = (args.experience || "").toLowerCase();

      let recommendation;

      // Primero verificar si conoce otros lenguajes (Nivel 2 tiene prioridad sobre "nunca" si hay contexto de programacion)
      const knowsOtherLanguage =
        exp.includes("python") ||
        exp.includes("javascript") ||
        exp.includes("java") ||
        exp.includes("kotlin") ||
        exp.includes("c#") ||
        exp.includes("c++") ||
        exp.includes("react") ||
        exp.includes("web") ||
        exp.includes("backend") ||
        exp.includes("otro lenguaje");

      if (knowsOtherLanguage) {
        recommendation = ENTRY_POINTS[1];
      } else if (
        exp.includes("nunca") ||
        exp.includes("no se programar") ||
        exp.includes("sin experiencia") ||
        exp.includes("cero") ||
        exp.includes("never programmed") ||
        exp.includes("beginner") ||
        exp.includes("principiante")
      ) {
        recommendation = ENTRY_POINTS[0];
      } else if (
        exp.includes("swift") &&
        !exp.includes("avanzado") &&
        !exp.includes("senior") &&
        !exp.includes("10 ano") &&
        !exp.includes("experto")
      ) {
        recommendation = ENTRY_POINTS[2];
      } else if (
        exp.includes("ios") ||
        exp.includes("senior") ||
        exp.includes("avanzado") ||
        exp.includes("experto") ||
        exp.includes("experiencia") ||
        exp.includes("10 ano") ||
        exp.includes("profesional")
      ) {
        recommendation = ENTRY_POINTS[3];
      } else {
        recommendation = ENTRY_POINTS[2];
      }

      let text = `# Recomendacion de Punto de Entrada\n\n`;
      text += `**Experiencia descrita**: ${args.experience}\n\n`;
      text += `## Recomendacion\n`;
      text += `- **Nivel ${recommendation.level}**: ${recommendation.profile}\n`;
      text += `- **Punto de entrada**: ${recommendation.entry}\n`;
      text += `- **Duracion estimada**: ${recommendation.weeks}\n\n`;
      text += `## Todos los niveles disponibles\n\n`;
      text += `| Nivel | Perfil | Punto de Entrada | Duracion |\n`;
      text += `|-------|--------|------------------|----------|\n`;
      for (const ep of ENTRY_POINTS) {
        const marker = ep.level === recommendation.level ? " **<--**" : "";
        text += `| ${ep.level} | ${ep.profile} | ${ep.entry} | ${ep.weeks}${marker} |\n`;
      }

      return { content: [{ type: "text", text }] };
    }

    default:
      return {
        content: [{ type: "text", text: `Herramienta desconocida: ${name}` }],
        isError: true,
      };
  }
});

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("AppleDevMasterclass MCP server running on stdio");
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
