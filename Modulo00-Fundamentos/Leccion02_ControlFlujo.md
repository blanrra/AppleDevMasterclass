# Leccion 02: Control de Flujo y Colecciones

**Modulo 00: Fundamentos — Bloque A: Iniciacion** | Semana 2

---

## TL;DR — Resumen en 2 minutos

- **if/else**: el ordenador toma decisiones — "si llueve, coge paraguas; si no, gafas de sol"
- **switch**: para multiples opciones — como un menu de restaurante con muchos platos
- **for-in**: repetir algo N veces — "para cada item en la lista, haz esto"
- **Arrays y Dictionaries**: listas ordenadas y diccionarios clave-valor — tus primeras estructuras de datos
- **Optionals (intro)**: el concepto mas importante de Swift — un valor que PUEDE no existir

> Herramienta recomendada: **Swift Playgrounds** en iPad o Mac

---

## Cupertino MCP

```bash
# Consultar antes de iniciar la leccion
cupertino search --source swift-book "control flow"
cupertino search --source swift-book "collection types"
cupertino search "Swift optionals"
cupertino search "Swift arrays"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| ES | [Julio Cesar Fernandez — Colecciones y Control de Flujo](https://www.youtube.com/@jcfmunoz) | En espanol, muy claro |
| EN | [Paul Hudson — Day 3-5: Conditions & Loops](https://www.hackingwithswift.com/100/swiftui/3) | 100 Days of SwiftUI |
| EN | [CodeWithChris — Optionals Explained](https://www.youtube.com/@CodeWithChris) | Optionals paso a paso |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### if / else / else if — El Ordenador Toma Decisiones

Hasta ahora tu programa era como un tren: iba recto, linea por linea, sin desviarse.
Pero en la vida real necesitamos tomar decisiones. Piensa en un **semaforo**:

```
  Si la luz es roja    -->  parar
  Si la luz es amarilla -->  precaucion
  Si la luz es verde   -->  avanzar
```

En Swift esto se escribe asi:

```swift
let colorSemaforo = "verde"

if colorSemaforo == "rojo" {
    print("PARA! Espera.")
} else if colorSemaforo == "amarillo" {
    print("Precaucion, va a cambiar.")
} else if colorSemaforo == "verde" {
    print("Adelante, puedes pasar.")
} else {
    print("Color no reconocido.")
}
```

**Anatomia de un if**:

```
if condicion {         <-- si la condicion es true...
    // haz esto        <-- ...ejecuta este bloque
} else {               <-- si no...
    // haz esto otro   <-- ...ejecuta este otro
}
```

La condicion siempre es algo que da `true` o `false`. Aqui es donde usas los operadores
de comparacion que aprendiste en la Leccion 01:

```swift
let edad = 20

if edad >= 18 {
    print("Eres mayor de edad")
} else {
    print("Eres menor de edad")
}

// Puedes combinar condiciones con && (y) y || (o)
let tieneEntrada = true

if edad >= 18 && tieneEntrada {
    print("Puedes entrar al concierto")
}
```

```
               edad >= 18?
              /          \
           SI             NO
            |              |
    "Mayor de edad"   "Menor de edad"
```

#### Operadores logicos

- `&&` — Y (ambas deben ser true): `edad >= 18 && tieneEntrada`
- `||` — O (al menos una true): `esEstudiante || esMilitar`
- `!`  — NO (invierte el valor): `!estaLloviendo`

```swift
let temperatura = 25
let estaSoleado = true

if temperatura > 20 && estaSoleado {
    print("Dia perfecto para ir a la playa")
} else if temperatura > 20 || estaSoleado {
    print("Buen dia, pero no perfecto")
} else {
    print("Mejor quedarse en casa")
}
```

---

### switch — El Menu de Opciones

Cuando tienes muchas opciones posibles, `if/else if/else if...` se vuelve feo y dificil
de leer. Para eso existe `switch`. Piensa en el **menu de un restaurante**: eliges UNA
opcion de muchas.

```swift
let diaDeLaSemana = "miercoles"

switch diaDeLaSemana {
case "lunes":
    print("Inicio de semana, animo!")
case "martes", "miercoles", "jueves":
    print("Mitad de semana, sigue asi")
case "viernes":
    print("Casi fin de semana!")
case "sabado", "domingo":
    print("Fin de semana, a descansar")
default:
    print("Ese dia no existe")
}
```

**Regla importante**: el `switch` en Swift debe cubrir TODOS los casos posibles. Por eso
existe `default`: es el "si no es ninguno de los anteriores". Swift no te deja olvidar
opciones — es parte de su filosofia de seguridad.

Tambien puedes usar rangos:

```swift
let nota = 7

switch nota {
case 0..<5:
    print("Suspenso")
case 5..<7:
    print("Aprobado")
case 7..<9:
    print("Notable")
case 9...10:
    print("Sobresaliente")
default:
    print("Nota no valida")
}
```

---

### Bucles: for-in y while — Repetir Acciones

#### for-in — Para cada elemento, haz algo

Imagina que tienes una **lista de la compra** y quieres leer cada elemento en voz alta.
No lees toda la lista de golpe; lees uno, luego el siguiente, luego el siguiente:

```swift
let listaCompra = ["Pan", "Leche", "Huevos", "Tomates"]

for producto in listaCompra {
    print("Necesito comprar: \(producto)")
}
// Necesito comprar: Pan
// Necesito comprar: Leche
// Necesito comprar: Huevos
// Necesito comprar: Tomates
```

Tambien puedes repetir algo un numero de veces con **rangos**:

```swift
// Del 1 al 5 (incluyendo el 5)
for numero in 1...5 {
    print("Numero: \(numero)")
}

// Del 1 al 4 (sin incluir el 5)
for numero in 1..<5 {
    print("Numero: \(numero)")
}
```

```
  for producto in listaCompra:

  Iteracion 1: producto = "Pan"      --> print
  Iteracion 2: producto = "Leche"    --> print
  Iteracion 3: producto = "Huevos"   --> print
  Iteracion 4: producto = "Tomates"  --> print
  FIN del bucle
```

#### while — Mientras se cumpla, sigue

`while` repite algo mientras una condicion sea verdadera. Piensa en un **despertador
con snooze**: mientras sigas dormido, sigue sonando.

```swift
var cuentaAtras = 5

while cuentaAtras > 0 {
    print("\(cuentaAtras)...")
    cuentaAtras -= 1  // Resta 1 cada vez (5, 4, 3, 2, 1)
}
print("Despegue!")
```

**Cuidado**: si la condicion nunca se vuelve `false`, el bucle no para nunca (bucle infinito).
Asegurate siempre de que algo cambie dentro del bucle.

#### break y continue

- `break` — "Para completamente, sal del bucle"
- `continue` — "Salta esta vuelta, pero sigue con la siguiente"

```swift
for numero in 1...10 {
    if numero == 3 {
        continue  // Salta el 3, va directamente al 4
    }
    if numero == 7 {
        break     // Para completamente al llegar al 7
    }
    print(numero)  // Imprime: 1, 2, 4, 5, 6
}
```

---

### Arrays — Listas Ordenadas

Un **Array** es una lista ordenada de elementos del mismo tipo. Piensa en una **lista de
la compra**: tiene un orden (el primer item, el segundo...) y puedes anadir o quitar cosas.

```swift
// Crear un array
var frutas = ["Manzana", "Platano", "Naranja"]
let numeros = [10, 20, 30, 40, 50]

// Acceder por posicion (el indice empieza en 0, no en 1!)
print(frutas[0])  // "Manzana"  (el primero)
print(frutas[1])  // "Platano"  (el segundo)
print(frutas[2])  // "Naranja"  (el tercero)
```

```
  Indice:    0          1          2
         +----------+----------+----------+
  frutas | Manzana  | Platano  | Naranja  |
         +----------+----------+----------+

  OJO: El primer elemento tiene indice 0, no 1.
  Esto confunde a todos los principiantes. Es normal.
```

#### Operaciones basicas con Arrays

```swift
var tareas = ["Comprar pan", "Llamar al medico"]

// Anadir
tareas.append("Estudiar Swift")
// ["Comprar pan", "Llamar al medico", "Estudiar Swift"]

// Cuantos elementos hay?
print(tareas.count)  // 3

// Esta vacio?
print(tareas.isEmpty)  // false

// Contiene un elemento?
print(tareas.contains("Comprar pan"))  // true

// Primer y ultimo elemento
print(tareas.first ?? "Vacia")  // "Comprar pan"
print(tareas.last ?? "Vacia")   // "Estudiar Swift"

// Eliminar por posicion
tareas.remove(at: 0)
// ["Llamar al medico", "Estudiar Swift"]

// Recorrer con for-in
for tarea in tareas {
    print("Pendiente: \(tarea)")
}
```

#### map, filter, reduce — Operaciones Poderosas (vista previa)

Estas funciones son muy utiles. Aqui solo una introduccion; las veremos a fondo mas
adelante:

```swift
let numeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

// filter: quedarse solo con los que cumplen una condicion
let pares = numeros.filter { $0 % 2 == 0 }
print(pares)  // [2, 4, 6, 8, 10]

// map: transformar cada elemento
let dobles = numeros.map { $0 * 2 }
print(dobles)  // [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

// reduce: combinar todos en un solo valor
let suma = numeros.reduce(0) { $0 + $1 }
print(suma)  // 55
```

No te preocupes si no entiendes la sintaxis de `{ $0 ... }` todavia. Lo veremos en detalle
cuando hablemos de closures. Por ahora solo recuerda que existen.

---

### Dictionaries — Buscar por Clave

Un **Dictionary** es como una **agenda de contactos**: cada nombre (clave) tiene asociado
un numero de telefono (valor). No importa el orden, lo que importa es poder buscar por
el nombre.

```swift
// Crear un diccionario [Clave: Valor]
var contactos = [
    "Ana": "612345678",
    "Carlos": "698765432",
    "Lucia": "655555555"
]

// Buscar por clave
print(contactos["Ana"] ?? "No encontrado")  // "612345678"

// Anadir un contacto nuevo
contactos["Pedro"] = "677777777"

// Modificar un contacto existente
contactos["Ana"] = "611111111"

// Eliminar un contacto
contactos["Carlos"] = nil

// Recorrer todos los contactos
for (nombre, telefono) in contactos {
    print("\(nombre): \(telefono)")
}

// Cuantos contactos hay?
print("Total contactos: \(contactos.count)")
```

```
  Diccionario "contactos":

  Clave (nombre)    Valor (telefono)
  +--------------+------------------+
  | "Ana"        | "612345678"      |
  | "Carlos"     | "698765432"      |
  | "Lucia"      | "655555555"      |
  +--------------+------------------+

  contactos["Ana"] --> "612345678"
  contactos["Pedro"] --> nil (no existe)
```

**Diferencia clave entre Array y Dictionary**:
- Array: accedes por posicion numerica (`frutas[0]`)
- Dictionary: accedes por clave (`contactos["Ana"]`)

---

### Sets — Colecciones sin Duplicados

Un **Set** es como una bolsa de canicas de colores: no importa el orden y no puede haber
dos iguales. Se usa poco comparado con Array y Dictionary, pero es util cuando necesitas
valores unicos.

```swift
var colores: Set<String> = ["Rojo", "Azul", "Verde"]
colores.insert("Amarillo")
colores.insert("Rojo")  // No pasa nada, ya existe, lo ignora

print(colores.count)        // 4
print(colores.contains("Azul"))  // true
```

---

### Optionals — El Concepto Mas Importante de Swift

Esta es la idea mas importante que vas a aprender. Prestale atencion especial.

Imagina que recibes un **regalo envuelto**. Puede haber algo dentro... o puede estar vacio.
No lo sabes hasta que lo abres. Un **optional** en Swift es exactamente eso: un valor que
**puede o no existir**.

#### Por que existen?

En muchos lenguajes, si intentas acceder a algo que no existe, tu programa explota
(un "crash"). Swift te obliga a considerar la posibilidad de que un valor no exista,
y eso evita crashes.

```swift
// Un String normal SIEMPRE tiene un valor
let nombre: String = "Maria"

// Un String opcional PUEDE tener un valor... o ser nil
var apodo: String? = nil     // No tiene valor (la caja esta vacia)
var ciudad: String? = "Madrid"  // Tiene valor (la caja tiene algo)
```

`nil` significa "nada, no hay valor". Es diferente de `""` (texto vacio) o `0` (cero).
`nil` es la ausencia total de valor.

```
  String normal          String?  (opcional)
  +----------+           +----------+
  | "Maria"  |           |   nil    |   <-- caja vacia
  +----------+           +----------+
  SIEMPRE tiene              O
  un valor              +----------+
                        | "Madrid" |   <-- caja con algo
                        +----------+
                        PUEDE estar vacia
```

#### if let — Abrir el regalo con cuidado

No puedes usar un optional directamente. Primero tienes que "abrirlo" para ver si hay
algo dentro. La forma mas segura es `if let`:

```swift
var nombreUsuario: String? = "Carlos"

if let nombre = nombreUsuario {
    // Aqui dentro, "nombre" es un String normal (ya sin el ?)
    print("Bienvenido, \(nombre)!")
} else {
    // Aqui entramos si nombreUsuario era nil
    print("Usuario no identificado")
}
```

Swift 5.7 trajo una forma mas corta (si el nombre es el mismo):

```swift
if let nombreUsuario {
    print("Bienvenido, \(nombreUsuario)!")
}
```

#### guard let — Salir rapido si no hay valor

`guard let` es lo contrario: "si NO hay valor, sal de aqui".

```swift
func saludar(nombre: String?) {
    guard let nombre else {
        print("No se proporciono nombre")
        return  // Salimos de la funcion
    }
    // A partir de aqui, "nombre" es un String normal
    print("Hola, \(nombre)!")
}

saludar(nombre: "Ana")    // "Hola, Ana!"
saludar(nombre: nil)      // "No se proporciono nombre"
```

#### Nil-coalescing: valor por defecto

El operador `??` dice: "usa este valor si el optional es nil":

```swift
let colorFavorito: String? = nil
let color = colorFavorito ?? "Azul"  // Si es nil, usa "Azul"
print(color)  // "Azul"
```

**Resumen de optionals**:
- `String?` = puede tener un String o ser nil
- `if let` = "si tiene valor, usalo"
- `guard let` = "si NO tiene valor, sal de aqui"
- `??` = "si es nil, usa este valor por defecto"

---

## Ejemplos de Codigo

### Archivo: `Codigo/ControlFlujo.swift`

```swift
// MARK: - Control de Flujo y Colecciones
// Ejecutar con: swift Modulo00-Fundamentos/Codigo/ControlFlujo.swift

// MARK: - 1. Decisiones con if/else

let temperatura = 32

print("=== Recomendacion del dia ===")
if temperatura > 35 {
    print("Hace mucho calor. Quedate en casa con aire acondicionado.")
} else if temperatura > 25 {
    print("Buen dia para la playa o la piscina.")
} else if temperatura > 15 {
    print("Temperatura agradable. Buen dia para pasear.")
} else {
    print("Hace frio. Abrigate bien.")
}

// MARK: - 2. Switch con notas

let nota = 8

print("\n=== Calificacion ===")
switch nota {
case 0..<5:
    print("Nota \(nota): Suspenso. Hay que estudiar mas.")
case 5..<7:
    print("Nota \(nota): Aprobado. Bien, pero puedes mejorar.")
case 7..<9:
    print("Nota \(nota): Notable. Muy buen trabajo!")
case 9...10:
    print("Nota \(nota): Sobresaliente. Excelente!")
default:
    print("Nota no valida.")
}

// MARK: - 3. Bucles

print("\n=== Lista de la compra ===")
let compra = ["Pan", "Leche", "Huevos", "Aceite", "Tomates"]

for (indice, producto) in compra.enumerated() {
    print("\(indice + 1). \(producto)")
}

print("\n=== Tabla del 7 ===")
for i in 1...10 {
    print("7 x \(i) = \(7 * i)")
}

// MARK: - 4. Arrays

print("\n=== Gestion de tareas ===")
var tareas = ["Estudiar Swift", "Hacer ejercicio", "Leer un libro"]
tareas.append("Cocinar la cena")
print("Tareas pendientes (\(tareas.count)):")
for tarea in tareas {
    print("  - \(tarea)")
}

// MARK: - 5. Diccionarios

print("\n=== Capitales ===")
let capitales = [
    "Espana": "Madrid",
    "Francia": "Paris",
    "Italia": "Roma",
    "Portugal": "Lisboa"
]

for (pais, capital) in capitales {
    print("La capital de \(pais) es \(capital)")
}

// Buscar un pais
let paisBuscado = "Alemania"
if let capital = capitales[paisBuscado] {
    print("\(paisBuscado): \(capital)")
} else {
    print("\(paisBuscado) no esta en el diccionario")
}

// MARK: - 6. Optionals

print("\n=== Optionals ===")
var email: String? = "ana@email.com"
var telefono: String? = nil

if let email {
    print("Email: \(email)")
} else {
    print("No tiene email registrado")
}

let telefonoContacto = telefono ?? "No proporcionado"
print("Telefono: \(telefonoContacto)")
```

---

## Ejercicio 1: Clasificador de Edades (Basico)

**Objetivo**: Practicar if/else y comparaciones.

**Requisitos**:
1. Crea una variable `edad` con un valor numerico
2. Usa if/else if/else para clasificar:
   - 0-2: "Bebe"
   - 3-12: "Nino/a"
   - 13-17: "Adolescente"
   - 18-64: "Adulto/a"
   - 65+: "Senior"
3. Anade una segunda verificacion: si es mayor de 18 Y menor de 30, imprime tambien "Joven adulto"
4. Repite lo mismo con un `switch` usando rangos
5. Prueba con al menos 3 edades diferentes

---

## Ejercicio 2: Lista de Alumnos (Intermedio)

**Objetivo**: Practicar arrays, diccionarios y bucles.

**Requisitos**:
1. Crea un array de nombres de alumnos (minimo 5)
2. Crea un diccionario que asocie cada alumno con su nota (Int de 0 a 10)
3. Recorre el diccionario e imprime el nombre y nota de cada alumno
4. Calcula la nota media de la clase
5. Usa filter para encontrar los alumnos aprobados (nota >= 5)
6. Encuentra al alumno con la nota mas alta
7. Muestra un resumen: total alumnos, aprobados, suspensos, nota media

**Ejemplo de salida**:
```
=== Notas de la clase ===
Ana: 8
Carlos: 4
Lucia: 9
Pedro: 6
Maria: 3

Media: 6.0
Aprobados: Ana, Lucia, Pedro (3)
Suspensos: Carlos, Maria (2)
Mejor nota: Lucia con un 9
```

---

## Ejercicio 3: Agenda de Contactos con Optionals (Avanzado)

**Objetivo**: Combinar diccionarios, optionals y control de flujo.

**Requisitos**:
1. Crea un diccionario `agenda` de tipo `[String: [String: String?]]` donde cada contacto
   tiene nombre, telefono (opcional), email (opcional) y ciudad (opcional)
2. Implementa una funcion `buscarContacto(nombre:)` que:
   - Use `guard let` para verificar que el contacto existe
   - Imprima toda la informacion disponible
   - Use `??` para mostrar "No disponible" en campos opcionales
3. Implementa una funcion `contactosEnCiudad(ciudad:)` que filtre contactos por ciudad
4. Muestra un resumen: cuantos contactos tienen telefono, email, ambos, o ninguno

**Pista**: Puedes simplificar usando `[String: String]` para los datos de cada contacto
y tratar los valores faltantes como claves que no existen en el diccionario.

---

## Checklist

- [ ] Usar if/else para tomar decisiones simples
- [ ] Combinar condiciones con && (y), || (o), ! (no)
- [ ] Usar switch para multiples opciones (y entender que es exhaustivo)
- [ ] Crear bucles for-in con arrays y rangos
- [ ] Saber cuando usar while (y evitar bucles infinitos)
- [ ] Crear, modificar y recorrer Arrays
- [ ] Crear, modificar y recorrer Dictionaries
- [ ] Entender que es un optional y por que existe
- [ ] Desempaquetar optionals con if let y guard let
- [ ] Usar el operador ?? para valores por defecto
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

Todo lo que has aprendido en esta leccion aparecera constantemente en el Proyecto Integrador:

- **if/else y switch**: para manejar estados de la app (cargando, exito, error)
- **for-in**: para mostrar listas de datos en pantalla (SwiftUI usa ForEach, que es similar)
- **Arrays**: las listas de la app (tareas, contactos, productos) seran arrays
- **Dictionaries**: para organizar datos agrupados (categorias, configuraciones)
- **Optionals**: los datos que vienen de internet pueden no existir — siempre seran opcionales

Con las Lecciones 01 y 02 ya tienes las herramientas basicas para leer y entender codigo
Swift. En la Leccion 03 aprenderemos funciones y closures, que te permitiran organizar
tu codigo de forma profesional.

---

*Leccion 02 (L02) | Control de Flujo y Colecciones | Semana 2 | Modulo 00: Fundamentos*
*Siguiente: Leccion 03 (L03) — Funciones y Closures*
