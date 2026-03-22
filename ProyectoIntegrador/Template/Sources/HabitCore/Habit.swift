import Foundation

/// Modelo basico de un habito
/// Se convertira en @Model de SwiftData en el Modulo 04
struct Habit: Identifiable, Codable {
    let id: UUID
    var nombre: String
    var descripcion: String
    var icono: String  // SF Symbol name
    var color: String
    var frecuencia: Frecuencia
    var fechaCreacion: Date
    var completadoHoy: Bool
    var rachaActual: Int

    enum Frecuencia: String, Codable, CaseIterable {
        case diario = "Diario"
        case semanal = "Semanal"
        case entreSeamana = "Entre semana"
        case finDeSemana = "Fin de semana"
    }

    init(
        id: UUID = UUID(),
        nombre: String,
        descripcion: String = "",
        icono: String = "star.fill",
        color: String = "blue",
        frecuencia: Frecuencia = .diario,
        fechaCreacion: Date = Date(),
        completadoHoy: Bool = false,
        rachaActual: Int = 0
    ) {
        self.id = id
        self.nombre = nombre
        self.descripcion = descripcion
        self.icono = icono
        self.color = color
        self.frecuencia = frecuencia
        self.fechaCreacion = fechaCreacion
        self.completadoHoy = completadoHoy
        self.rachaActual = rachaActual
    }
}

// MARK: - Datos de ejemplo

extension Habit {
    static let ejemplos: [Habit] = [
        Habit(nombre: "Meditar", icono: "brain.head.profile", color: "purple"),
        Habit(nombre: "Leer", icono: "book.fill", color: "orange"),
        Habit(nombre: "Ejercicio", icono: "figure.run", color: "green"),
        Habit(nombre: "Beber agua", icono: "drop.fill", color: "blue", frecuencia: .diario),
        Habit(nombre: "Estudiar Swift", icono: "swift", color: "red"),
    ]
}
