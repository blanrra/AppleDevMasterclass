// ============================================
// Leccion 02: Control de Flujo
// AppleDevMasterclass — Modulo 00
// ============================================
// Ejecutar: swift Modulo00-Fundamentos/Codigo/L02_ControlFlujo.swift

// MARK: - 1. Condicionales: if / else

// Clasificamos a una persona segun su edad
let edad = 17

if edad < 13 {
    print("Eres un nino")
} else if edad < 18 {
    print("Eres un adolescente")
} else if edad < 65 {
    print("Eres un adulto")
} else {
    print("Eres un adulto mayor")
}

// Tambien podemos combinar condiciones con && (y) y || (o)
let tienePermiso = true

if edad >= 18 && tienePermiso {
    print("Puedes entrar al evento")
} else {
    print("No puedes entrar al evento")
}

// MARK: - 2. Switch: multiples opciones

// switch es mas limpio que muchos if/else
// En Swift, cada caso se detiene automaticamente (no necesita "break")
let diaSemana = "martes"

switch diaSemana {
case "lunes":
    print("Inicio de semana, animo!")
case "martes", "miercoles", "jueves":
    print("Mitad de semana, sigue adelante!")
case "viernes":
    print("¡Ya casi es fin de semana!")
case "sabado", "domingo":
    print("¡A descansar!")
default:
    // default es obligatorio: cubre cualquier otro valor
    print("Dia no reconocido")
}

// Switch con rangos de numeros
let nota = 85

switch nota {
case 0..<50:
    print("Suspenso")
case 50..<70:
    print("Aprobado")
case 70..<90:
    print("Notable")
case 90...100:
    print("Sobresaliente")
default:
    print("Nota fuera de rango")
}

// MARK: - 3. Bucle for-in: recorrer colecciones

// Recorremos un array (lista) de frutas
let frutas = ["manzana", "platano", "naranja", "fresa", "uva"]

print("\nMis frutas favoritas:")
for fruta in frutas {
    print("  - \(fruta)")
}

// for-in con rango de numeros
// 1...5 incluye el 5, 1..<5 NO incluye el 5
print("\nContando del 1 al 5:")
for numero in 1...5 {
    print("  \(numero)")
}

// MARK: - 4. Bucle while: repetir mientras se cumpla una condicion

print("\nCuenta regresiva:")
var contador = 5

while contador > 0 {
    print("  \(contador)...")
    contador -= 1  // Restamos 1 en cada vuelta
}
print("  ¡Despegue!")

// MARK: - 5. Arrays (listas ordenadas)

// Un array guarda multiples valores del mismo tipo, en orden
var compras = ["leche", "pan", "huevos"]

// Agregar un elemento al final
compras.append("mantequilla")

// Acceder por posicion (empieza en 0)
print("\nPrimer articulo: \(compras[0])")  // "leche"

// Saber cuantos elementos tiene
print("Total de articulos: \(compras.count)")

// Verificar si contiene un elemento
if compras.contains("pan") {
    print("El pan esta en la lista")
}

// Eliminar un elemento por posicion
compras.remove(at: 1)  // Elimina "pan"
print("Despues de eliminar: \(compras)")

// MARK: - 6. Diccionarios (pares clave-valor)

// Un diccionario guarda datos asociados a una clave unica
var contactos = [
    "Ana": "612345678",
    "Carlos": "698765432",
    "Lucia": "655112233"
]

// Acceder a un valor por su clave
// Nota: devuelve un Optional porque la clave podria no existir
if let telefonoAna = contactos["Ana"] {
    print("\nTelefono de Ana: \(telefonoAna)")
}

// Agregar un nuevo contacto
contactos["Pedro"] = "677889900"

// Recorrer un diccionario
print("\nTodos los contactos:")
for (nombre, telefono) in contactos {
    print("  \(nombre): \(telefono)")
}

// MARK: - 7. Optionals: valores que pueden ser nil (vacio)

// En Swift, nil significa "sin valor"
// Solo los tipos Optional pueden ser nil
// Se declaran con ? despues del tipo

var apellido: String? = nil  // No tiene valor todavia
print("\nApellido: \(apellido as Any)")  // nil

apellido = "Garcia"
print("Apellido: \(apellido as Any)")  // Optional("Garcia")

// if let: desenvolver un optional de forma segura
// Solo entra al bloque si el optional TIENE valor
if let apellidoSeguro = apellido {
    print("Apellido desenvuelto: \(apellidoSeguro)")  // "Garcia"
} else {
    print("No hay apellido registrado")
}

// MARK: - 8. Guard let: salida temprana

// guard let es como if let, pero al reves:
// Si el valor es nil, DEBE salir de la funcion/bloque
// Es muy util para validar datos al inicio

func mostrarPerfil(nombre: String?, edad: Int?) {
    // Si nombre es nil, salimos inmediatamente
    guard let nombreSeguro = nombre else {
        print("Error: falta el nombre")
        return
    }

    // Si edad es nil, salimos inmediatamente
    guard let edadSegura = edad else {
        print("Error: falta la edad")
        return
    }

    // Aqui sabemos que ambos valores existen
    print("Perfil: \(nombreSeguro), \(edadSegura) anos")
}

print("")
mostrarPerfil(nombre: "Laura", edad: 30)     // Perfil: Laura, 30 anos
mostrarPerfil(nombre: nil, edad: 25)          // Error: falta el nombre
mostrarPerfil(nombre: "Pedro", edad: nil)     // Error: falta la edad

print("\n=== ¡Leccion 02 completada! Ya controlas el flujo de tu programa ===")
