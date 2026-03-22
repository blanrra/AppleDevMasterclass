# Retos Diarios — Katas de 5 Minutos

Antes de cada sesion de estudio, el Profesor Apple te propone una **kata de 5 minutos** como calentamiento. Refuerza conceptos y mantiene la practica constante.

---

## Como funcionan

1. Al iniciar una sesion, pide al profesor: *"Dame el reto del dia"*
2. Claude selecciona una kata adaptada a tu nivel y tema actual
3. Tienes **5 minutos** para resolverla
4. El profesor revisa tu solucion y da feedback

---

## Tipos de Retos por Nivel

### Nivel 1 — Completar Codigo
```swift
// Completa el codigo para que imprima "Hola, Swift!"
___ saludo = "Hola, Swift!"
___(saludo)
```

### Nivel 2 — Encontrar el Bug
```swift
// Este codigo tiene un error. Encuentralo y corrigelo.
func dividir(_ a: Int, _ b: Int) -> Int {
    return a / b  // ¿Que pasa si b es 0?
}
```

### Nivel 3 — Refactorizar
```swift
// Refactoriza este callback hell a async/await
func fetchUser(completion: @escaping (User?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data else { completion(nil); return }
        let user = try? JSONDecoder().decode(User.self, from: data)
        completion(user)
    }.resume()
}
```

### Nivel 4 — Disenar desde Cero
```
// Disena un protocolo para un sistema de cache generico que:
// - Soporte cualquier tipo Codable como valor
// - Tenga TTL (time-to-live) configurable
// - Sea thread-safe con actors
// Solo la firma y estructura — no la implementacion completa
```

---

## Organizacion

Los retos se generan dinamicamente por el Profesor Apple, adaptados a:
- **Tu nivel actual** (1-4)
- **El modulo en el que estas** (repaso del tema actual)
- **Temas anteriores** (repaso espaciado para retencion)

### Pedir retos especificos

Puedes pedirle al profesor:
- *"Dame un reto de optionals"*
- *"Quiero practicar concurrencia"*
- *"Dame algo dificil de POP"*
- *"Reto rapido de SwiftUI"*

---

## Racha y Motivacion

El profesor lleva cuenta de tu racha de retos completados:
- 7 dias seguidos → desbloqueado nivel de dificultad extra
- 30 dias seguidos → kata especial de "boss fight" (problema complejo multi-tema)

---

*Los retos se generan en tiempo real. No hay archivos estaticos — cada kata es unica y adaptada a tu progreso.*
