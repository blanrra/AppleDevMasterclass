import Foundation

// MARK: - Leccion 04: Concurrencia Moderna
// Ejecutar: swift Modulo00-Fundamentos/Codigo/ConcurrencyDemo.swift

// MARK: - Actor: Cache Thread-Safe

actor ImageCache {
    private var cache: [String: Data] = [:]

    func obtener(clave: String) -> Data? {
        cache[clave]
    }

    func guardar(_ datos: Data, clave: String) {
        cache[clave] = datos
        print("  💾 Cache: guardado '\(clave)' (\(datos.count) bytes)")
    }

    var cantidadItems: Int { cache.count }
}

// MARK: - Servicio Asincrono

struct ServicioClima {
    func obtenerTemperatura(ciudad: String) async throws -> Double {
        // Simular latencia de red
        try await Task.sleep(for: .milliseconds(300))

        let temperaturas: [String: Double] = [
            "Madrid": 22.5,
            "Barcelona": 25.0,
            "Sevilla": 30.2,
            "Valencia": 27.1
        ]

        guard let temp = temperaturas[ciudad] else {
            throw ErrorClima.ciudadNoEncontrada(ciudad)
        }
        return temp
    }
}

enum ErrorClima: Error, CustomStringConvertible {
    case ciudadNoEncontrada(String)

    var description: String {
        switch self {
        case .ciudadNoEncontrada(let ciudad):
            return "Ciudad '\(ciudad)' no encontrada"
        }
    }
}

// MARK: - Medir Tiempo

func medir(_ label: String, bloque: () async throws -> Void) async rethrows {
    let inicio = ContinuousClock.now
    try await bloque()
    let duracion = ContinuousClock.now - inicio
    print("  ⏱️ \(label): \(duracion)")
}

// MARK: - Demos

func demoSecuencial() async {
    print("\n--- 1. Secuencial (una tras otra) ---")
    let servicio = ServicioClima()

    await medir("Secuencial") {
        do {
            let madrid = try await servicio.obtenerTemperatura(ciudad: "Madrid")
            let barcelona = try await servicio.obtenerTemperatura(ciudad: "Barcelona")
            let sevilla = try await servicio.obtenerTemperatura(ciudad: "Sevilla")
            print("  Madrid: \(madrid)°C, Barcelona: \(barcelona)°C, Sevilla: \(sevilla)°C")
        } catch {
            print("  ❌ Error: \(error)")
        }
    }
}

func demoParalelo() async {
    print("\n--- 2. Paralelo (async let) ---")
    let servicio = ServicioClima()

    await medir("Paralelo") {
        do {
            async let madrid = servicio.obtenerTemperatura(ciudad: "Madrid")
            async let barcelona = servicio.obtenerTemperatura(ciudad: "Barcelona")
            async let sevilla = servicio.obtenerTemperatura(ciudad: "Sevilla")

            let temps = try await (madrid, barcelona, sevilla)
            print("  Madrid: \(temps.0)°C, Barcelona: \(temps.1)°C, Sevilla: \(temps.2)°C")
        } catch {
            print("  ❌ Error: \(error)")
        }
    }
}

func demoTaskGroup() async {
    print("\n--- 3. TaskGroup (paralelismo dinamico) ---")
    let servicio = ServicioClima()
    let ciudades = ["Madrid", "Barcelona", "Sevilla", "Valencia"]

    await medir("TaskGroup") {
        let resultados = await withTaskGroup(of: (String, Double?).self) { group in
            for ciudad in ciudades {
                group.addTask {
                    let temp = try? await servicio.obtenerTemperatura(ciudad: ciudad)
                    return (ciudad, temp)
                }
            }

            var map: [(String, Double)] = []
            for await (ciudad, temp) in group {
                if let temp {
                    map.append((ciudad, temp))
                }
            }
            return map
        }

        for (ciudad, temp) in resultados.sorted(by: { $0.1 > $1.1 }) {
            print("  🌡️ \(ciudad): \(temp)°C")
        }
    }
}

func demoActor() async {
    print("\n--- 4. Actor (estado compartido thread-safe) ---")
    let cache = ImageCache()

    // Multiples tareas escribiendo al cache simultaneamente
    await withTaskGroup(of: Void.self) { group in
        for i in 1...5 {
            group.addTask {
                let datos = Data("imagen_\(i)_contenido".utf8)
                await cache.guardar(datos, clave: "foto_\(i)")
            }
        }
    }

    let total = await cache.cantidadItems
    print("  📊 Items en cache: \(total)")

    if let datos = await cache.obtener(clave: "foto_1") {
        print("  🔍 foto_1: \(datos.count) bytes")
    }
}

func demoCancelacion() async {
    print("\n--- 5. Task Cancellation ---")

    let task = Task {
        for i in 1...10 {
            guard !Task.isCancelled else {
                print("  🛑 Tarea cancelada en iteracion \(i)")
                return
            }
            print("  🔄 Procesando \(i)/10...")
            try await Task.sleep(for: .milliseconds(100))
        }
        print("  ✅ Tarea completada")
    }

    // Cancelar despues de 350ms
    try? await Task.sleep(for: .milliseconds(350))
    task.cancel()
    _ = await task.result
}

// MARK: - Entry Point

print("========================================")
print("  DEMO: Concurrencia Moderna en Swift")
print("========================================")

Task {
    await demoSecuencial()
    await demoParalelo()
    await demoTaskGroup()
    await demoActor()
    await demoCancelacion()

    print("\n========================================")
    print("  Demo completada")
    print("========================================")

    exit(0)
}

RunLoop.main.run()
