# Leccion 39: StoreKit 2

**Modulo 11: Monetizacion y Distribucion** | Semana 49

---

## TL;DR — Resumen en 2 minutos

- **StoreKit 2**: API moderna con async/await que reemplaza las callbacks de StoreKit 1
- **Product.products()**: Carga los productos configurados en App Store Connect usando sus IDs
- **purchase()**: Inicia el flujo de compra y retorna un `Product.PurchaseResult` verificado criptograficamente
- **Transaction.currentEntitlements**: Itera sobre todo lo que el usuario ha comprado y sigue vigente
- **Suscripciones**: `Product.SubscriptionInfo` gestiona renovacion automatica, status y ofertas promocionales

---

## Cupertino MCP

```bash
cupertino search "StoreKit 2"
cupertino search "Product StoreKit"
cupertino search "Transaction StoreKit"
cupertino search "Product.PurchaseResult"
cupertino search "Transaction.currentEntitlements"
cupertino search "SubscriptionInfo"
cupertino search "StoreKit Testing Xcode"
cupertino search "SubscriptionStoreView"
cupertino search --source samples "StoreKit"
cupertino search --source updates "StoreKit"
```

---

## Videos

| Tipo | Video | Notas |
|------|-------|-------|
| WWDC22 | [What's new in StoreKit 2 and StoreKit Testing](https://developer.apple.com/videos/play/wwdc2022/10007/) | **Esencial** — Novedades del framework |
| WWDC23 | [Meet StoreKit for SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10013/) | SubscriptionStoreView y ProductView |
| WWDC21 | [Meet StoreKit 2](https://developer.apple.com/videos/play/wwdc2021/10114/) | Introduccion al framework moderno |
| WWDC21 | [Manage in-app purchases on your server](https://developer.apple.com/videos/play/wwdc2021/10174/) | Server-side verification |
| WWDC23 | [Explore testing in-app purchases](https://developer.apple.com/videos/play/wwdc2023/10142/) | Testing en Xcode |
| :es: | [Julio Cesar Fernandez — StoreKit 2](https://www.youtube.com/@AppleCodingAcademy) | En espanol |

> Ver guia completa: [Recursos/VideosRecomendados.md](../Recursos/VideosRecomendados.md)

---

## Teoria

### Por que StoreKit 2?

StoreKit 1 era notoriamente dificil de implementar. Requeria un `SKPaymentTransactionObserver`, manejar colas de transacciones manualmente, y la verificacion de recibos era un proceso oscuro que involucraba enviar receipts a tu servidor y validar con Apple. Muchos desarrolladores usaban librerias de terceros solo para compras in-app.

StoreKit 2, introducido en iOS 15, resuelve todo esto con un API moderna basada en async/await, verificacion automatica con JWS (JSON Web Signature), y tipos Swift nativos. Ya no necesitas un observer ni manejar colas — simplemente llamas `await` y obtienes el resultado.

```
  ┌────────────────────────────────────────────────────────────────┐
  │                    STOREKIT 2 vs STOREKIT 1                    │
  ├──────────────────────────┬─────────────────────────────────────┤
  │      STOREKIT 1          │          STOREKIT 2                 │
  ├──────────────────────────┼─────────────────────────────────────┤
  │ SKProductsRequest        │ Product.products(for:)              │
  │ SKPaymentQueue           │ product.purchase()                  │
  │ SKPaymentTransaction     │ Transaction (verificado con JWS)    │
  │ Observer + delegate      │ async/await                         │
  │ Receipt validation       │ Transaction.currentEntitlements     │
  │   (manual, servidor)     │   (automatico, on-device)           │
  │ SKReceiptRefreshRequest  │ Transaction.latest(for:)            │
  │ Callbacks complejos      │ Flujo lineal y predecible           │
  └──────────────────────────┴─────────────────────────────────────┘
```

### Tipos de Producto

Antes de escribir codigo, necesitas entender los cuatro tipos de producto que puedes vender:

```swift
import StoreKit

// MARK: - Tipos de producto en StoreKit 2

/*
 1. CONSUMABLE (Consumible)
    - Se puede comprar multiples veces
    - Desaparece al usarse (monedas, vidas, tokens)
    - No se restaura en otros dispositivos

 2. NON-CONSUMABLE (No consumible)
    - Se compra una vez, dura para siempre
    - Se restaura en todos los dispositivos del usuario
    - Ejemplo: desbloquear version premium, quitar anuncios

 3. AUTO-RENEWABLE SUBSCRIPTION (Suscripcion con renovacion automatica)
    - Cobro recurrente (semanal, mensual, anual)
    - Se renueva automaticamente hasta que el usuario cancela
    - Soporte para periodos de prueba y ofertas

 4. NON-RENEWING SUBSCRIPTION (Suscripcion sin renovacion)
    - Acceso temporal que NO se renueva
    - Debes gestionar la logica de expiracion tu mismo
    - Ejemplo: pase de temporada, acceso por 3 meses
*/
```

### Configurar Productos en Xcode — StoreKit Configuration File

Antes de conectar con App Store Connect, puedes probar compras localmente con un archivo de configuracion.

```swift
// MARK: - Crear StoreKit Configuration File
// File > New > File > StoreKit Configuration File

/*
 En el archivo .storekit puedes definir:
 - Productos consumibles y no consumibles
 - Suscripciones con grupos y niveles
 - Precios por region
 - Ofertas introductorias y promocionales

 Para usarlo en testing:
 Edit Scheme > Run > Options > StoreKit Configuration > seleccionar tu archivo
*/

// MARK: - Definir IDs de producto (constantes centralizadas)

enum ProductoID {
    // No consumibles
    static let premium = "com.tuapp.premium"
    static let sinAnuncios = "com.tuapp.removead"

    // Consumibles
    static let monedas100 = "com.tuapp.coins.100"
    static let monedas500 = "com.tuapp.coins.500"

    // Suscripciones
    static let suscripcionMensual = "com.tuapp.sub.monthly"
    static let suscripcionAnual = "com.tuapp.sub.yearly"

    // Grupo de suscripciones
    static let grupoSuscripciones = "com.tuapp.sub.group"

    static var todos: [String] {
        [premium, sinAnuncios, monedas100, monedas500,
         suscripcionMensual, suscripcionAnual]
    }
}
```

### Cargar Productos

```swift
import StoreKit

// MARK: - Cargar productos desde App Store Connect

class TiendaManager {

    // Productos cargados del App Store
    private(set) var productos: [Product] = []

    // Productos comprados (entitlements activos)
    private(set) var productosComprados: Set<String> = []

    // MARK: - Cargar productos

    func cargarProductos() async throws {
        // Product.products(for:) consulta App Store Connect
        // y retorna los productos con precios localizados
        productos = try await Product.products(for: ProductoID.todos)

        // Ordenar por precio
        productos.sort { $0.price < $1.price }

        for producto in productos {
            print("""
            Producto: \(producto.displayName)
            Descripcion: \(producto.description)
            Precio: \(producto.displayPrice)
            Tipo: \(producto.type)
            ID: \(producto.id)
            ---
            """)
        }
    }

    // MARK: - Filtrar por tipo

    var noConsumibles: [Product] {
        productos.filter { $0.type == .nonConsumable }
    }

    var consumibles: [Product] {
        productos.filter { $0.type == .consumable }
    }

    var suscripciones: [Product] {
        productos.filter { $0.type == .autoRenewable }
    }
}
```

### Flujo de Compra

```swift
import StoreKit

// MARK: - Realizar una compra

extension TiendaManager {

    func comprar(_ producto: Product) async throws -> Transaction? {
        // 1. Iniciar la compra — muestra el sheet nativo de Apple
        let resultado = try await producto.purchase()

        // 2. Evaluar el resultado
        switch resultado {
        case .success(let verificacion):
            // 3. Verificar la transaccion (JWS)
            let transaccion = try verificarTransaccion(verificacion)

            // 4. Entregar el contenido al usuario
            await entregarProducto(transaccion)

            // 5. IMPORTANTE: Finalizar la transaccion
            // Sin esto, StoreKit reintentara la entrega
            await transaccion.finish()

            return transaccion

        case .userCancelled:
            // El usuario cancelo — no es un error
            print("Compra cancelada por el usuario")
            return nil

        case .pending:
            // Compra pendiente de aprobacion (Ask to Buy, SCA)
            // Se resolvera en Transaction.updates
            print("Compra pendiente de aprobacion")
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Verificar transaccion con JWS

    private func verificarTransaccion(
        _ resultado: VerificationResult<Transaction>
    ) throws -> Transaction {
        switch resultado {
        case .verified(let transaccion):
            // Apple ha verificado que la transaccion es legitima
            return transaccion

        case .unverified(_, let error):
            // La verificacion fallo — posible fraude o manipulacion
            throw ErrorTienda.verificacionFallida(error)
        }
    }

    // MARK: - Entregar contenido segun tipo de producto

    private func entregarProducto(_ transaccion: Transaction) async {
        switch transaccion.productType {
        case .nonConsumable:
            // Desbloquear feature permanentemente
            productosComprados.insert(transaccion.productID)
            print("Desbloqueado: \(transaccion.productID)")

        case .consumable:
            // Agregar monedas/vidas al balance
            if transaccion.productID == ProductoID.monedas100 {
                // agregarMonedas(100)
                print("Agregadas 100 monedas")
            }

        case .autoRenewable:
            // Activar suscripcion
            productosComprados.insert(transaccion.productID)
            print("Suscripcion activada: \(transaccion.productID)")

        default:
            break
        }
    }
}

// MARK: - Errores de tienda

enum ErrorTienda: LocalizedError {
    case verificacionFallida(Error)
    case productoNoEncontrado

    var errorDescription: String? {
        switch self {
        case .verificacionFallida(let error):
            return "Verificacion fallida: \(error.localizedDescription)"
        case .productoNoEncontrado:
            return "El producto no fue encontrado"
        }
    }
}
```

### Verificar Entitlements — Que ha comprado el usuario?

Este es uno de los conceptos mas importantes. Cada vez que tu app inicia, necesitas verificar que tiene acceso el usuario.

```swift
import StoreKit

// MARK: - Verificar entitlements actuales

extension TiendaManager {

    /// Verifica todas las compras activas del usuario
    func verificarEntitlements() async {
        // Transaction.currentEntitlements itera sobre TODAS
        // las transacciones activas (no consumibles + suscripciones vigentes)
        // Los consumibles NO aparecen aqui porque ya se "consumieron"

        var comprasActivas: Set<String> = []

        for await resultado in Transaction.currentEntitlements {
            do {
                let transaccion = try verificarTransaccion(resultado)
                comprasActivas.insert(transaccion.productID)
            } catch {
                print("Transaccion no verificada: \(error)")
            }
        }

        productosComprados = comprasActivas
        print("Productos activos: \(productosComprados)")
    }

    /// Verificar si el usuario tiene un producto especifico
    func tieneAcceso(a productoID: String) -> Bool {
        productosComprados.contains(productoID)
    }

    /// Verificar si es usuario premium (cualquier forma)
    var esPremium: Bool {
        tieneAcceso(a: ProductoID.premium) ||
        tieneAcceso(a: ProductoID.suscripcionMensual) ||
        tieneAcceso(a: ProductoID.suscripcionAnual)
    }
}
```

### Escuchar Actualizaciones de Transacciones

Las transacciones pueden llegar en cualquier momento: una compra pendiente se aprueba, una suscripcion se renueva, o el usuario compra desde otro dispositivo.

```swift
import StoreKit

// MARK: - Escuchar transacciones en tiempo real

extension TiendaManager {

    /// Debe llamarse al iniciar la app y mantener la Task activa
    func escucharTransacciones() -> Task<Void, Never> {
        Task.detached { [weak self] in
            // Transaction.updates es un AsyncSequence infinito
            // que emite cada nueva transaccion
            for await resultado in Transaction.updates {
                do {
                    let transaccion = try self?.verificarTransaccion(resultado)
                    guard let transaccion else { continue }

                    await self?.entregarProducto(transaccion)
                    await transaccion.finish()

                    // Refrescar entitlements
                    await self?.verificarEntitlements()
                } catch {
                    print("Error procesando transaccion: \(error)")
                }
            }
        }
    }
}

// MARK: - Uso en App struct

/*
@main
struct MiApp: App {
    let tienda = TiendaManager()
    let taskTransacciones: Task<Void, Never>

    init() {
        taskTransacciones = tienda.escucharTransacciones()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await tienda.verificarEntitlements()
                    try? await tienda.cargarProductos()
                }
        }
    }
}
*/
```

### Suscripciones — Status y RenewalInfo

```swift
import StoreKit

// MARK: - Gestion de suscripciones

extension TiendaManager {

    /// Obtener el estado actual de una suscripcion
    func estadoSuscripcion(productoID: String) async throws -> Product.SubscriptionInfo.Status? {
        guard let producto = productos.first(where: { $0.id == productoID }),
              let suscripcionInfo = producto.subscription else {
            return nil
        }

        // Obtener el estado mas reciente del grupo de suscripcion
        let estados = try await suscripcionInfo.status

        // Buscar el estado activo
        for estado in estados {
            switch estado.state {
            case .subscribed:
                print("Suscrito activamente")
                // Verificar informacion de renovacion
                if case .verified(let renovacion) = estado.renewalInfo {
                    print("Renovara automaticamente: \(renovacion.willAutoRenew)")
                    print("Producto actual: \(renovacion.currentProductID)")
                    if let fecha = renovacion.expirationDate {
                        print("Expira: \(fecha)")
                    }
                }
                return estado

            case .expired:
                print("Suscripcion expirada")
                if case .verified(let renovacion) = estado.renewalInfo {
                    if let razon = renovacion.expirationReason {
                        switch razon {
                        case .autoRenewDisabled:
                            print("El usuario cancelo la renovacion")
                        case .billingError:
                            print("Error de facturacion")
                        case .didNotConsentToPriceIncrease:
                            print("No acepto aumento de precio")
                        case .productUnavailable:
                            print("Producto ya no disponible")
                        default:
                            break
                        }
                    }
                }
                return estado

            case .revoked:
                print("Suscripcion revocada (reembolso)")
                return estado

            case .inGracePeriod:
                print("Periodo de gracia — problema de pago")
                return estado

            case .inBillingRetryPeriod:
                print("Reintentando cobro")
                return estado

            default:
                break
            }
        }

        return nil
    }

    /// Verificar si alguna suscripcion del grupo esta activa
    func suscripcionActiva() async -> Bool {
        for await resultado in Transaction.currentEntitlements {
            if case .verified(let transaccion) = resultado,
               transaccion.productType == .autoRenewable {
                return true
            }
        }
        return false
    }
}
```

### Restaurar Compras

```swift
import StoreKit

// MARK: - Restaurar compras

extension TiendaManager {

    /// Restaurar compras del usuario (forzar sincronizacion con App Store)
    func restaurarCompras() async throws {
        // En StoreKit 2, las compras se sincronizan automaticamente
        // Pero a veces el usuario necesita forzar la sincronizacion
        // (ej: nuevo dispositivo, reinstalacion)

        try await AppStore.sync()

        // Despues de sync, refrescar entitlements
        await verificarEntitlements()

        print("Compras restauradas exitosamente")
    }
}
```

### Vistas de StoreKit para SwiftUI

A partir de iOS 17, StoreKit ofrece vistas preconstruidas que manejan toda la UI de compra.

```swift
import SwiftUI
import StoreKit

// MARK: - SubscriptionStoreView — Vista de suscripcion completa

struct PantallaSuscripcion: View {
    var body: some View {
        SubscriptionStoreView(groupID: ProductoID.grupoSuscripciones) {
            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)

                Text("Desbloquea Premium")
                    .font(.title.bold())

                VStack(alignment: .leading, spacing: 8) {
                    beneficio("Sin anuncios")
                    beneficio("Contenido exclusivo")
                    beneficio("Sincronizacion en la nube")
                    beneficio("Soporte prioritario")
                }
            }
            .padding()
        }
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.visible, for: .restorePurchases)
    }

    private func beneficio(_ texto: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(texto)
        }
    }
}

// MARK: - ProductView — Vista individual de producto

struct TiendaView: View {
    let productIDs = [
        ProductoID.premium,
        ProductoID.sinAnuncios,
        ProductoID.monedas100
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(productIDs, id: \.self) { id in
                        ProductView(id: id)
                            .productViewStyle(.large)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Tienda")
            .storeButton(.visible, for: .restorePurchases)
        }
    }
}

// MARK: - StoreView — Vista completa con multiples productos

struct TiendaCompletaView: View {
    var body: some View {
        StoreView(ids: ProductoID.todos) { producto in
            // Decoracion personalizada para cada producto
            VStack {
                iconoParaProducto(producto)
            }
        }
        .storeButton(.visible, for: .restorePurchases)
        .storeButton(.visible, for: .redeemCode)
    }

    @ViewBuilder
    private func iconoParaProducto(_ producto: Product) -> some View {
        switch producto.id {
        case ProductoID.premium:
            Image(systemName: "crown.fill")
                .foregroundStyle(.yellow)
        case ProductoID.monedas100:
            Image(systemName: "bitcoinsign.circle.fill")
                .foregroundStyle(.orange)
        default:
            Image(systemName: "bag.fill")
        }
    }
}
```

### Offer Codes y Ofertas Promocionales

```swift
import StoreKit
import SwiftUI

// MARK: - Offer Codes (codigos de oferta)

struct RedeemCodeView: View {
    var body: some View {
        Button("Canjear codigo") {
            // Presenta la hoja nativa de canje de codigo
        }
        // Metodo declarativo con StoreKit SwiftUI
        .offerCodeRedemption(isPresented: .constant(false)) { resultado in
            switch resultado {
            case .success:
                print("Codigo canjeado exitosamente")
            case .failure(let error):
                print("Error canjeando codigo: \(error)")
            }
        }
    }
}

// MARK: - Ofertas promocionales (requieren firma del servidor)

extension TiendaManager {

    func comprarConOferta(_ producto: Product, ofertaID: String) async throws -> Transaction? {
        // Las ofertas promocionales requieren generar una firma
        // en tu servidor usando la App Store Server API

        guard let oferta = producto.subscription?.promotionalOffers
            .first(where: { $0.id == ofertaID }) else {
            print("Oferta no encontrada")
            return nil
        }

        // En produccion, obtendrias la firma de tu servidor
        // let firma = try await tuServidor.generarFirma(para: ofertaID)

        // Nota: esto es simplificado — en produccion necesitas
        // Product.PurchaseOption.promotionalOffer con firma del servidor
        print("Oferta disponible: \(oferta.id)")
        print("Tipo: \(oferta.type)")  // introductory, promotional
        print("Periodo: \(oferta.period)")

        return nil
    }
}
```

### StoreKit Testing en Xcode

```swift
// MARK: - Testing de compras en Xcode

/*
 CONFIGURAR STOREKIT TESTING:

 1. Crear archivo: File > New > File > StoreKit Configuration File

 2. Definir productos en el archivo:
    - Click "+" para agregar productos
    - Configurar tipo, precio, nombre, descripcion
    - Para suscripciones: definir grupo, duracion, trial

 3. Activar en scheme:
    Edit Scheme > Run > Options > StoreKit Configuration
    Seleccionar tu archivo .storekit

 4. Controlar desde Xcode:
    Debug > StoreKit > Manage Transactions
    - Ver todas las transacciones
    - Aprobar/rechazar compras pendientes (Ask to Buy)
    - Forzar renovacion de suscripciones
    - Simular interrupciones (billing error, revoke)
    - Acelerar el tiempo para suscripciones

 5. Transaction Manager:
    - Refund transacciones
    - Modificar suscripciones
    - Simular problemas de red

 IMPORTANTE: El testing local funciona sin App Store Connect.
 No necesitas una cuenta de desarrollador pagada para probar.
*/

// MARK: - Ejemplo de Unit Test con StoreKit

/*
import Testing
import StoreKit

@Test("Cargar productos retorna todos los IDs esperados")
func testCargarProductos() async throws {
    let tienda = TiendaManager()
    try await tienda.cargarProductos()

    #expect(tienda.productos.isEmpty == false)
    #expect(tienda.productos.count == ProductoID.todos.count)

    // Verificar que los precios estan localizados
    for producto in tienda.productos {
        #expect(producto.displayPrice.isEmpty == false)
    }
}

@Test("Compra exitosa de producto no consumible")
func testCompraExitosa() async throws {
    let tienda = TiendaManager()
    try await tienda.cargarProductos()

    guard let premium = tienda.productos.first(where: { $0.id == ProductoID.premium }) else {
        Issue.record("Producto premium no encontrado")
        return
    }

    // En StoreKit Testing, la compra se aprueba automaticamente
    let transaccion = try await tienda.comprar(premium)
    #expect(transaccion != nil)
    #expect(tienda.tieneAcceso(a: ProductoID.premium))
}
*/
```

---

## Ejercicio 1: Tienda Basica con Productos (Basico)

**Objetivo**: Crear un gestor de tienda que cargue y muestre productos.

**Requisitos**:
1. Definir al menos 4 IDs de producto (2 no consumibles, 2 consumibles)
2. Crear una clase `TiendaBasica` con funcion `cargarProductos()` usando `Product.products(for:)`
3. Funcion `mostrarProductos()` que imprima nombre, descripcion y precio localizado
4. Filtrar productos por tipo (consumible vs no consumible)
5. Manejar el caso donde `Product.products(for:)` retorna vacio (IDs incorrectos)

---

## Ejercicio 2: Flujo de Compra Completo (Intermedio)

**Objetivo**: Implementar compra, verificacion y entitlements.

**Requisitos**:
1. Funcion `comprar(_ producto: Product)` que maneje los tres casos de `PurchaseResult` (success, userCancelled, pending)
2. Verificacion de `VerificationResult` (verified vs unverified) con errores descriptivos
3. Funcion `verificarEntitlements()` que itere `Transaction.currentEntitlements`
4. Propiedad computada `esPremium` que verifique acceso a cualquier producto premium
5. Task de `Transaction.updates` para escuchar transacciones en tiempo real
6. Configurar StoreKit Configuration File en Xcode con al menos 3 productos

---

## Ejercicio 3: Sistema de Suscripciones con SwiftUI (Avanzado)

**Objetivo**: Construir un paywall completo con suscripciones.

**Requisitos**:
1. Grupo de suscripcion con 3 niveles: semanal, mensual, anual
2. `SubscriptionStoreView` personalizada con marketing content (icono, titulo, beneficios)
3. Verificar estado de suscripcion con `Product.SubscriptionInfo.Status`
4. Manejar estados: subscribed, expired, inGracePeriod, inBillingRetryPeriod
5. Mostrar informacion de renovacion (fecha, si auto-renew esta activo)
6. Boton de restaurar compras con `AppStore.sync()`
7. Vista condicional: si es premium, mostrar contenido; si no, mostrar paywall
8. Testing con StoreKit Configuration File — simular renovacion, cancelacion y reembolso

---

## 5 Errores Comunes

### 1. No llamar finish() en la transaccion

```swift
// MAL — la transaccion queda pendiente y StoreKit la reintenta
func comprar(_ producto: Product) async throws {
    let resultado = try await producto.purchase()
    if case .success(let verificacion) = resultado {
        let transaccion = try checkVerified(verificacion)
        entregarContenido(transaccion)
        // Falta: await transaccion.finish()
        // StoreKit seguira intentando entregar esta transaccion
    }
}

// BIEN — siempre finalizar la transaccion
func comprar(_ producto: Product) async throws {
    let resultado = try await producto.purchase()
    if case .success(let verificacion) = resultado {
        let transaccion = try checkVerified(verificacion)
        entregarContenido(transaccion)
        await transaccion.finish()  // CRITICO
    }
}
```

### 2. Verificar entitlements solo al iniciar la app

```swift
// MAL — solo verificar una vez
struct MiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { await tienda.verificarEntitlements() }
        }
    }
    // Si la suscripcion se renueva o expira mientras la app esta abierta,
    // no te enteras
}

// BIEN — escuchar Transaction.updates continuamente
struct MiApp: App {
    let tienda = TiendaManager()
    let taskActualizaciones: Task<Void, Never>

    init() {
        // Escuchar cambios en tiempo real
        taskActualizaciones = tienda.escucharTransacciones()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { await tienda.verificarEntitlements() }
        }
    }
}
```

### 3. No manejar el caso .pending (Ask to Buy)

```swift
// MAL — asumir que solo hay success o cancel
let resultado = try await producto.purchase()
if case .success = resultado {
    // desbloquear
} else {
    mostrarError("Compra fallida")  // Incorrecto para .pending
}

// BIEN — manejar los tres casos correctamente
let resultado = try await producto.purchase()
switch resultado {
case .success(let verificacion):
    let transaccion = try verificarTransaccion(verificacion)
    await entregarProducto(transaccion)
    await transaccion.finish()

case .userCancelled:
    // No hacer nada — decision del usuario
    break

case .pending:
    // Mostrar mensaje: "Tu compra esta pendiente de aprobacion"
    // Se resolvera en Transaction.updates
    mostrarMensaje("Compra pendiente de aprobacion parental")

@unknown default:
    break
}
```

### 4. Usar IDs de producto hardcodeados y mal escritos

```swift
// MAL — strings sueltos por toda la app, propenso a typos
let productos = try await Product.products(for: ["com.app.premum"])  // typo!
// Retorna array vacio sin error

// BIEN — centralizar IDs en un enum con constantes
enum ProductoID {
    static let premium = "com.tuapp.premium"
    static let mensual = "com.tuapp.sub.monthly"

    static var todos: [String] { [premium, mensual] }
}

let productos = try await Product.products(for: ProductoID.todos)
if productos.isEmpty {
    print("ADVERTENCIA: ningun producto encontrado — verificar IDs")
}
```

### 5. No ofrecer restaurar compras

```swift
// MAL — no hay forma de restaurar compras
struct TiendaView: View {
    var body: some View {
        List(productos) { producto in
            BotonCompra(producto: producto)
        }
        // Apple rechazara tu app si no hay opcion de restaurar
    }
}

// BIEN — incluir boton de restaurar (requerido por App Store)
struct TiendaView: View {
    @State private var restaurando = false

    var body: some View {
        List {
            ForEach(productos) { producto in
                BotonCompra(producto: producto)
            }

            Section {
                Button("Restaurar compras") {
                    Task {
                        restaurando = true
                        try? await AppStore.sync()
                        await tienda.verificarEntitlements()
                        restaurando = false
                    }
                }
                .disabled(restaurando)
            }
        }
        // O usando el modifier de StoreKit:
        .storeButton(.visible, for: .restorePurchases)
    }
}
```

---

## Checklist

- [ ] Entender la diferencia entre StoreKit 1 y StoreKit 2
- [ ] Conocer los 4 tipos de producto (consumable, non-consumable, auto-renewable, non-renewing)
- [ ] Configurar un StoreKit Configuration File en Xcode para testing local
- [ ] Cargar productos con Product.products(for:) y manejar precios localizados
- [ ] Implementar flujo de compra con purchase() y manejar los 3 resultados
- [ ] Verificar transacciones con VerificationResult (verified vs unverified)
- [ ] Llamar finish() en cada transaccion procesada
- [ ] Verificar entitlements con Transaction.currentEntitlements al iniciar la app
- [ ] Escuchar Transaction.updates para transacciones en tiempo real
- [ ] Gestionar suscripciones: status, renewalInfo, expiracion
- [ ] Restaurar compras con AppStore.sync()
- [ ] Usar SubscriptionStoreView y ProductView para UI nativa (iOS 17+)
- [ ] Probar compras con StoreKit Testing en Xcode (Transaction Manager)
- [ ] Completar al menos los ejercicios 1 y 2

---

## Notas Personales

_(Espacio para tus notas durante el aprendizaje)_

---

## Conexion con Proyecto Integrador

StoreKit 2 sera el motor de monetizacion del proyecto:
- **Modelo freemium**: Usar no consumibles para desbloquear la version premium con todas las funcionalidades
- **Suscripciones**: Implementar plan mensual y anual con periodo de prueba gratuito de 7 dias
- **Paywall**: Crear una pantalla de suscripcion atractiva con `SubscriptionStoreView` y marketing content
- **Entitlements**: Verificar acceso premium en cada vista que requiera funcionalidades avanzadas
- **Testing**: Configurar StoreKit Configuration File con todos los productos del proyecto para probar sin App Store Connect
- **Restaurar compras**: Obligatorio para aprobacion en App Store — incluir boton visible en la seccion de configuracion

---

*Leccion 39 | StoreKit 2 | Semana 49 | Modulo 11: Monetizacion y Distribucion*
*Siguiente: Leccion 40 — App Store y TestFlight*
