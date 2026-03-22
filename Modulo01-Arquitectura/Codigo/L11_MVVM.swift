// L11_MVVM.swift — Patron MVVM (Model-View-ViewModel)
// Ejecutar: swift L11_MVVM.swift
//
// WHY: MVVM separa la logica de negocio (ViewModel) de la presentacion (View)
// y los datos (Model). Esto permite testear la logica sin necesidad de UI
// y mantener cada capa con una responsabilidad clara.

import Foundation

// MARK: - Model
// Los modelos son structs puros — solo datos, sin logica de presentacion.

struct Tarea: CustomStringConvertible {
    let id: UUID
    var titulo: String
    var completada: Bool
    let fechaCreacion: Date

    var description: String {
        let estado = completada ? "[x]" : "[ ]"
        return "\(estado) \(titulo)"
    }
}

// MARK: - ViewModel
// El ViewModel contiene TODA la logica de negocio.
// En SwiftUI real usariamos @Observable; aqui simulamos las notificaciones.

final class TareaListViewModel {
    // Estado observable (en SwiftUI seria @Observable automaticamente)
    private(set) var tareas: [Tarea] = []
    private(set) var mensajeError: String?

    // Propiedad computada — logica de presentacion vive en el ViewModel
    var totalPendientes: Int {
        tareas.filter { !$0.completada }.count
    }

    var resumen: String {
        let total = tareas.count
        let hechas = tareas.filter { $0.completada }.count
        return "Progreso: \(hechas)/\(total) tareas completadas"
    }

    // MARK: - Acciones (el View llama estas funciones)

    func agregarTarea(titulo: String) {
        guard !titulo.trimmingCharacters(in: .whitespaces).isEmpty else {
            mensajeError = "El titulo no puede estar vacio"
            notificarCambio("Error: \(mensajeError!)")
            return
        }
        let nueva = Tarea(
            id: UUID(),
            titulo: titulo,
            completada: false,
            fechaCreacion: Date()
        )
        tareas.append(nueva)
        mensajeError = nil
        notificarCambio("Tarea agregada: \(titulo)")
    }

    func toggleCompletada(id: UUID) {
        guard let indice = tareas.firstIndex(where: { $0.id == id }) else {
            mensajeError = "Tarea no encontrada"
            return
        }
        tareas[indice].completada.toggle()
        let estado = tareas[indice].completada ? "completada" : "pendiente"
        notificarCambio("'\(tareas[indice].titulo)' marcada como \(estado)")
    }

    func eliminarTarea(id: UUID) {
        guard let indice = tareas.firstIndex(where: { $0.id == id }) else { return }
        let titulo = tareas[indice].titulo
        tareas.remove(at: indice)
        notificarCambio("Tarea eliminada: \(titulo)")
    }

    func filtrarPendientes() -> [Tarea] {
        tareas.filter { !$0.completada }
    }

    // Simulacion de notificacion al View (en SwiftUI esto es automatico con @Observable)
    private func notificarCambio(_ mensaje: String) {
        print("  [ViewModel -> View] \(mensaje)")
    }
}

// MARK: - Vista Simulada
// En una app real, esto seria una SwiftUI View.
// Aqui usamos print() para demostrar el flujo de datos.

func vistaSimulada(viewModel: TareaListViewModel) {
    print("\n--- Lista de Tareas ---")
    if viewModel.tareas.isEmpty {
        print("  (sin tareas)")
    } else {
        for tarea in viewModel.tareas {
            print("  \(tarea)")
        }
    }
    print("  \(viewModel.resumen)")
    print("  Pendientes: \(viewModel.totalPendientes)")
    print("-----------------------")
}

// MARK: - Ejecucion del Demo

print("=== DEMO MVVM: App de Tareas ===\n")

let vm = TareaListViewModel()

// 1. El "View" solicita acciones al ViewModel
print("1. Agregando tareas...")
vm.agregarTarea(titulo: "Estudiar Swift 6")
vm.agregarTarea(titulo: "Practicar async/await")
vm.agregarTarea(titulo: "Leer sobre @Observable")
vistaSimulada(viewModel: vm)

// 2. Validacion — el ViewModel protege la logica
print("\n2. Intentando agregar tarea vacia...")
vm.agregarTarea(titulo: "   ")

// 3. Marcar tarea como completada
print("\n3. Completando una tarea...")
let primeraTarea = vm.tareas[0]
vm.toggleCompletada(id: primeraTarea.id)
vistaSimulada(viewModel: vm)

// 4. Filtrar pendientes
print("\n4. Solo tareas pendientes:")
for tarea in vm.filtrarPendientes() {
    print("  \(tarea)")
}

// 5. Eliminar tarea
print("\n5. Eliminando tarea...")
vm.eliminarTarea(id: vm.tareas[1].id)
vistaSimulada(viewModel: vm)

print("\n--- Punto clave ---")
print("El View NUNCA modifica datos directamente.")
print("Siempre pasa por el ViewModel, que valida y transforma.")
print("Esto permite testear la logica SIN interfaz grafica.")
