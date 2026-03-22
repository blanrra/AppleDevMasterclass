// ============================================
// Leccion 04: Structs, Clases y Enums
// AppleDevMasterclass — Modulo 00
// ============================================
// Ejecutar: swift Modulo00-Fundamentos/Codigo/L04_StructsClasesEnums.swift

// MARK: - 1. Structs (Estructuras)

// Un struct agrupa datos relacionados en un solo tipo
// En Swift, los structs son VALUE TYPES (tipos por valor)
// Esto significa que al copiar, se crea una copia independiente

struct Persona {
    // Propiedades: los datos que guarda
    let nombre: String
    var edad: Int
    var ciudad: String

    // Metodo: una funcion dentro del struct
    func presentarse() {
        print("Hola, soy \(nombre), tengo \(edad) anos y vivo en \(ciudad)")
    }

    // mutating: necesario para metodos que modifican propiedades
    // (porque los structs son value types)
    mutating func cumplirAnos() {
        edad += 1
        print("\(nombre) ahora tiene \(edad) anos. ¡Feliz cumpleanos!")
    }

    mutating func mudarseA(_ nuevaCiudad: String) {
        print("\(nombre) se muda de \(ciudad) a \(nuevaCiudad)")
        ciudad = nuevaCiudad
    }
}

// Crear una instancia (un "objeto" de tipo Persona)
// Swift genera automaticamente un inicializador con todos los parametros
var maria = Persona(nombre: "Maria", edad: 28, ciudad: "Madrid")
maria.presentarse()
maria.cumplirAnos()

// MARK: - 2. Value Type: copia independiente

// Al asignar un struct a otra variable, se COPIA todo
var copiaDeMaria = maria

// Modificar la copia NO afecta al original
copiaDeMaria.mudarseA("Barcelona")

print("\nDemostracion de VALUE TYPE (copia independiente):")
print("  Original - \(maria.nombre) vive en \(maria.ciudad)")        // Madrid
print("  Copia    - \(copiaDeMaria.nombre) vive en \(copiaDeMaria.ciudad)")  // Barcelona
print("  (Son copias separadas, cada una con sus propios datos)")

// MARK: - 3. Clases (Reference Types)

// Una clase es similar a un struct, pero es un REFERENCE TYPE (tipo por referencia)
// Esto significa que al copiar, ambas variables apuntan al MISMO objeto

class CuentaBancaria {
    // Propiedades
    let titular: String
    var saldo: Double

    // Las clases NECESITAN un init (inicializador) explicito
    // (los structs lo generan automaticamente)
    init(titular: String, saldoInicial: Double) {
        self.titular = titular
        self.saldo = saldoInicial
    }

    // Los metodos de clase NO necesitan "mutating"
    // (porque las clases son reference types)
    func depositar(_ cantidad: Double) {
        saldo += cantidad
        print("\(titular) deposito \(cantidad)€. Saldo: \(saldo)€")
    }

    func retirar(_ cantidad: Double) {
        if cantidad <= saldo {
            saldo -= cantidad
            print("\(titular) retiro \(cantidad)€. Saldo: \(saldo)€")
        } else {
            print("Fondos insuficientes. Saldo actual: \(saldo)€")
        }
    }

    func mostrarSaldo() {
        print("Cuenta de \(titular): \(saldo)€")
    }
}

print("\n--- Cuenta Bancaria ---")
let cuentaCarlos = CuentaBancaria(titular: "Carlos", saldoInicial: 1000.0)
cuentaCarlos.mostrarSaldo()
cuentaCarlos.depositar(500.0)
cuentaCarlos.retirar(200.0)

// MARK: - 4. Reference Type: misma referencia

// Al asignar una clase a otra variable, ambas apuntan al MISMO objeto
let otraReferencia = cuentaCarlos

// Modificar desde cualquier variable afecta al mismo objeto
otraReferencia.depositar(100.0)

print("\nDemostracion de REFERENCE TYPE (misma referencia):")
print("  Desde cuentaCarlos:  ", terminator: "")
cuentaCarlos.mostrarSaldo()
print("  Desde otraReferencia:", terminator: "")
otraReferencia.mostrarSaldo()
print("  (Ambas variables apuntan al MISMO objeto en memoria)")

// MARK: - 5. Resumen: Struct vs Class

print("\n--- Struct vs Class ---")
print("  Struct = Value Type  -> Copiar crea datos INDEPENDIENTES")
print("  Class  = Reference Type -> Copiar comparte el MISMO objeto")
print("  Regla general: usa struct por defecto, class solo si necesitas referencia")

// MARK: - 6. Enums (Enumeraciones)

// Un enum define un conjunto fijo de opciones posibles
// Util para representar estados, categorias, opciones

enum EstadoPedido {
    case pendiente
    case enProceso
    case enviado(codigoSeguimiento: String)   // Valor asociado
    case entregado(fecha: String)              // Valor asociado
    case cancelado(motivo: String)             // Valor asociado
}

// Crear un valor del enum
var miPedido: EstadoPedido = .pendiente
print("\n--- Estado del Pedido ---")

// switch para manejar cada caso del enum
// Swift obliga a cubrir TODOS los casos (o usar default)
func mostrarEstado(_ estado: EstadoPedido) {
    switch estado {
    case .pendiente:
        print("  Pedido pendiente de procesar")
    case .enProceso:
        print("  Pedido en proceso de preparacion")
    case .enviado(let codigo):
        // Extraemos el valor asociado con "let"
        print("  Pedido enviado. Seguimiento: \(codigo)")
    case .entregado(let fecha):
        print("  Pedido entregado el \(fecha)")
    case .cancelado(let motivo):
        print("  Pedido cancelado. Motivo: \(motivo)")
    }
}

// Simular el ciclo de vida del pedido
mostrarEstado(miPedido)

miPedido = .enProceso
mostrarEstado(miPedido)

miPedido = .enviado(codigoSeguimiento: "ES12345678")
mostrarEstado(miPedido)

miPedido = .entregado(fecha: "22 de marzo de 2026")
mostrarEstado(miPedido)

// Otro pedido que se cancela
let pedidoCancelado: EstadoPedido = .cancelado(motivo: "Cliente cambio de opinion")
mostrarEstado(pedidoCancelado)

// MARK: - 7. Ejemplo combinado: Tienda online

// Combinamos struct, class y enum en un ejemplo practico

// Enum para categorias de producto
enum Categoria {
    case electronica
    case ropa
    case alimentacion
}

// Struct para productos (value type, datos simples)
struct Producto {
    let nombre: String
    let precio: Double
    let categoria: Categoria
}

// Class para carrito de compras (reference type, estado compartido)
class Carrito {
    var productos: [Producto] = []

    func agregar(_ producto: Producto) {
        productos.append(producto)
        print("Agregado: \(producto.nombre) (\(producto.precio)€)")
    }

    func calcularTotal() -> Double {
        // Usamos reduce para sumar todos los precios
        productos.reduce(0) { $0 + $1.precio }
    }

    func mostrarResumen() {
        print("\n--- Resumen del Carrito ---")
        if productos.isEmpty {
            print("  El carrito esta vacio")
            return
        }
        for producto in productos {
            print("  - \(producto.nombre): \(producto.precio)€")
        }
        print("  TOTAL: \(calcularTotal())€")
        print("  Articulos: \(productos.count)")
    }
}

// Crear productos
let iphone = Producto(nombre: "iPhone 17", precio: 999.0, categoria: .electronica)
let camiseta = Producto(nombre: "Camiseta Swift", precio: 25.0, categoria: .ropa)
let cafe = Producto(nombre: "Cafe Premium", precio: 12.50, categoria: .alimentacion)

// Crear carrito y agregar productos
print("\n--- Tienda Online ---")
let miCarrito = Carrito()
miCarrito.agregar(iphone)
miCarrito.agregar(camiseta)
miCarrito.agregar(cafe)
miCarrito.mostrarResumen()

print("\n=== ¡Leccion 04 completada! Ya conoces structs, clases y enums ===")
