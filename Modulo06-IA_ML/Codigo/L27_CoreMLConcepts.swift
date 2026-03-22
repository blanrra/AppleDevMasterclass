// L27_CoreMLConcepts.swift — Conceptos de ML sin CoreML
// Ejecutar: swift L27_CoreMLConcepts.swift
//
// WHY: Antes de usar CoreML, es fundamental entender QUE hace un modelo
// por dentro. Aqui implementamos regresion lineal desde cero para
// desmitificar la "magia" del machine learning.

import Foundation

// MARK: - Regresion Lineal desde Cero
// Predice un valor continuo: y = mx + b
// Ejemplo: predecir precio de vivienda segun metros cuadrados

struct RegresionLineal {
    var pendiente: Double = 0.0  // m (peso)
    var intercepto: Double = 0.0 // b (bias)

    // Prediccion: y = mx + b
    func predecir(x: Double) -> Double {
        pendiente * x + intercepto
    }

    // Entrenamiento con Gradient Descent
    mutating func entrenar(datos: [(x: Double, y: Double)], epocas: Int, tasaAprendizaje: Double) {
        let n = Double(datos.count)

        for epoca in 1...epocas {
            var gradM = 0.0  // Gradiente de la pendiente
            var gradB = 0.0  // Gradiente del intercepto

            // Calcular gradientes (derivadas parciales del error)
            for punto in datos {
                let prediccion = predecir(x: punto.x)
                let error = prediccion - punto.y
                gradM += (2.0 / n) * error * punto.x
                gradB += (2.0 / n) * error
            }

            // Actualizar parametros en direccion opuesta al gradiente
            pendiente -= tasaAprendizaje * gradM
            intercepto -= tasaAprendizaje * gradB

            if epoca % 200 == 0 || epoca == 1 {
                let mse = calcularMSE(datos: datos)
                print("    Epoca \(epoca): m=\(String(format: "%.4f", pendiente)), b=\(String(format: "%.4f", intercepto)), MSE=\(String(format: "%.2f", mse))")
            }
        }
    }

    // Error cuadratico medio — mide que tan bueno es el modelo
    func calcularMSE(datos: [(x: Double, y: Double)]) -> Double {
        let errores = datos.map { punto in
            let diff = predecir(x: punto.x) - punto.y
            return diff * diff
        }
        return errores.reduce(0, +) / Double(errores.count)
    }
}

// MARK: - Extraccion de Caracteristicas (Feature Extraction)
// Simula como CoreML transforma datos crudos en features numericas

struct ExtractorCaracteristicas {
    /// Extrae features de un texto (simulacion simplificada)
    static func extraerDeTexto(_ texto: String) -> [String: Double] {
        [
            "longitud": Double(texto.count),
            "palabras": Double(texto.split(separator: " ").count),
            "tieneSignos": texto.contains("!") || texto.contains("?") ? 1.0 : 0.0,
            "tieneMayusculas": texto.uppercased() == texto ? 1.0 : 0.0,
        ]
    }
}

// MARK: - Clasificador Simple por Reglas
// Muestra el concepto de clasificacion antes de usar modelos complejos

struct ClasificadorSentimiento {
    let palabrasPositivas = Set(["bien", "genial", "excelente", "bueno", "increible", "perfecto"])
    let palabrasNegativas = Set(["mal", "terrible", "pesimo", "malo", "horrible", "error"])

    func clasificar(_ texto: String) -> (sentimiento: String, confianza: Double) {
        let palabras = texto.lowercased().split(separator: " ").map(String.init)
        let pos = palabras.filter { palabrasPositivas.contains($0) }.count
        let neg = palabras.filter { palabrasNegativas.contains($0) }.count
        let total = max(pos + neg, 1)

        if pos > neg {
            return ("Positivo", Double(pos) / Double(total))
        } else if neg > pos {
            return ("Negativo", Double(neg) / Double(total))
        } else {
            return ("Neutro", 0.5)
        }
    }
}

// MARK: - Ejecucion del Demo

print("=== DEMO CONCEPTOS ML (sin CoreML) ===\n")

// 1. Regresion Lineal — predecir precio por metros cuadrados
print("1. Regresion Lineal — Precio de vivienda")
print("   Datos: metros cuadrados -> precio (miles)")

// Datos de entrenamiento: (metros², precio en miles)
let datos: [(x: Double, y: Double)] = [
    (50, 150), (60, 180), (70, 200), (80, 250),
    (90, 270), (100, 300), (120, 350), (150, 450),
]

var modelo = RegresionLineal()
modelo.entrenar(datos: datos, epocas: 1000, tasaAprendizaje: 0.00001)

print("\n   Predicciones:")
for m2 in [55, 85, 110, 200] {
    let precio = modelo.predecir(x: Double(m2))
    print("   \(m2) m² -> $\(String(format: "%.0f", precio))k")
}

// 2. Feature Extraction
print("\n2. Extraccion de Caracteristicas:")
let textos = ["Hola mundo", "URGENTE COMPRAR YA!!!", "Un texto normal y tranquilo"]
for texto in textos {
    let features = ExtractorCaracteristicas.extraerDeTexto(texto)
    print("   \"\(texto)\"")
    print("   Features: \(features)\n")
}

// 3. Clasificacion de sentimiento
print("3. Clasificador de Sentimiento:")
let clasificador = ClasificadorSentimiento()
let opiniones = [
    "La app funciona genial y excelente diseno",
    "Terrible experiencia con un error horrible",
    "Descargue la app ayer por la tarde",
]
for opinion in opiniones {
    let (sent, conf) = clasificador.clasificar(opinion)
    print("   \"\(opinion)\"")
    print("   -> \(sent) (confianza: \(String(format: "%.0f", conf * 100))%)\n")
}

print("--- Punto clave ---")
print("ML = encontrar patrones en datos con matematicas.")
print("CoreML empaqueta esto en modelos optimizados para Apple Silicon.")
