import Foundation

// MARK: - Leccion 03: Manejo de Errores y Memoria
// Ejecutar: swift Modulo00-Fundamentos/Codigo/ErrorMemory.swift

// MARK: - 1. Result Type

enum ErrorAPI: Error, CustomStringConvertible {
    case urlInvalida
    case sinDatos
    case decodificacionFallida(String)

    var description: String {
        switch self {
        case .urlInvalida: return "URL invalida"
        case .sinDatos: return "No se recibieron datos"
        case .decodificacionFallida(let tipo): return "No se pudo decodificar: \(tipo)"
        }
    }
}

struct Usuario {
    let id: Int
    let nombre: String
    let email: String
}

func obtenerUsuario(id: Int) -> Result<Usuario, ErrorAPI> {
    guard id > 0 else {
        return .failure(.urlInvalida)
    }
    guard id != 999 else {
        return .failure(.sinDatos)
    }
    return .success(Usuario(id: id, nombre: "Carlos", email: "carlos@test.com"))
}

// MARK: - 2. ARC y Retain Cycles

class Departamento {
    let nombre: String
    var jefe: EmpleadoRC?

    init(nombre: String) {
        self.nombre = nombre
        print("  🏢 Departamento '\(nombre)' creado")
    }

    deinit {
        print("  🏢 Departamento '\(nombre)' liberado ✓")
    }
}

class EmpleadoRC {
    let nombre: String
    weak var departamento: Departamento?  // weak rompe el retain cycle

    init(nombre: String) {
        self.nombre = nombre
        print("  👤 Empleado '\(nombre)' creado")
    }

    deinit {
        print("  👤 Empleado '\(nombre)' liberado ✓")
    }
}

// MARK: - 3. Closures y Capture Lists

class DescargaManager {
    let nombre: String
    var onComplete: (() -> Void)?

    init(nombre: String) {
        self.nombre = nombre
        print("  📥 Manager '\(nombre)' creado")
    }

    func configurar() {
        // [weak self] evita retain cycle
        onComplete = { [weak self] in
            guard let self else {
                print("  ⚠️ Manager ya fue liberado")
                return
            }
            print("  📥 Descarga '\(self.nombre)' completada")
        }
    }

    deinit {
        print("  📥 Manager '\(nombre)' liberado ✓")
    }
}

// MARK: - 4. Value Types vs Reference Types

struct Coordenada {
    var lat: Double
    var lon: Double
}

class Ubicacion {
    var nombre: String
    var coordenada: Coordenada

    init(nombre: String, lat: Double, lon: Double) {
        self.nombre = nombre
        self.coordenada = Coordenada(lat: lat, lon: lon)
    }
}

// MARK: - Demo

print("========================================")
print("  DEMO: Error Handling y Memoria")
print("========================================\n")

// 1. Result Type
print("--- Result Type ---")
let ids = [1, -5, 999, 42]
for id in ids {
    switch obtenerUsuario(id: id) {
    case .success(let usuario):
        print("✅ ID \(id): \(usuario.nombre) (\(usuario.email))")
    case .failure(let error):
        print("❌ ID \(id): \(error)")
    }
}

// Uso funcional con map
print("\nUso funcional:")
let nombre = obtenerUsuario(id: 1).map { $0.nombre }
print("Nombre: \(nombre)")

// 2. ARC y Retain Cycles
print("\n--- ARC: Sin retain cycle (weak) ---")
do {
    var dept: Departamento? = Departamento(nombre: "Ingenieria")
    var emp: EmpleadoRC? = EmpleadoRC(nombre: "Laura")

    dept?.jefe = emp
    emp?.departamento = dept

    print("  Asignando nil...")
    dept = nil
    emp = nil
    print("  (ambos deben haberse liberado)")
}

// 3. Closures con [weak self]
print("\n--- Closures: Capture List ---")
do {
    var manager: DescargaManager? = DescargaManager(nombre: "Fotos")
    manager?.configurar()

    let callback = manager?.onComplete
    print("  Asignando manager = nil...")
    manager = nil

    print("  Ejecutando callback:")
    callback?()
}

// 4. Value vs Reference
print("\n--- Value Type vs Reference Type ---")

// Struct (value): se copia
print("Struct (copia independiente):")
var coord1 = Coordenada(lat: 40.4168, lon: -3.7038)
var coord2 = coord1
coord2.lat = 41.3874
print("  coord1: lat=\(coord1.lat) (no cambio)")
print("  coord2: lat=\(coord2.lat) (cambio solo aqui)")

// Class (reference): se comparte
print("\nClass (referencia compartida):")
let ub1 = Ubicacion(nombre: "Madrid", lat: 40.4168, lon: -3.7038)
let ub2 = ub1
ub2.nombre = "Barcelona"
print("  ub1.nombre: \(ub1.nombre) (cambio porque es referencia!)")
print("  ub2.nombre: \(ub2.nombre)")

// 5. Copy-on-Write
print("\n--- Copy-on-Write ---")
var array1 = [1, 2, 3, 4, 5]
var array2 = array1  // No se copia aun (COW)
print("Antes de modificar:")
print("  array1: \(array1)")
print("  array2: \(array2)")

array2.append(6)  // AHORA se copia
print("Despues de modificar array2:")
print("  array1: \(array1) (no cambio — COW funciona)")
print("  array2: \(array2)")

print("\n========================================")
print("  Demo completada")
print("========================================")
