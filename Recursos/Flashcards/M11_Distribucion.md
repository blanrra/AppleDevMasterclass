# Flashcards — Modulo 11: Monetizacion y Distribucion

---

### Tarjeta 1
**Pregunta:** Que es StoreKit 2 y como se diferencia del StoreKit original?
**Respuesta:** StoreKit 2 es la API moderna de Apple para compras in-app y suscripciones. Diferencias: 1) Usa `async/await` (sin delegates). 2) Transacciones verificadas con JWS en el dispositivo (sin servidor propio). 3) API declarativa con `Product`, `Transaction`. 4) `StoreView` y `SubscriptionStoreView` para UI integrada. 5) Testing en Xcode sin App Store Connect.

---

### Tarjeta 2
**Pregunta:** Cuales son los tipos de producto en StoreKit 2?
**Respuesta:** 1) **Consumible**: se usa y se puede comprar de nuevo (monedas, vidas). 2) **No consumible**: se compra una vez para siempre (desbloquear feature, eliminar anuncios). 3) **Suscripcion auto-renovable**: cobro recurrente (mensual/anual) con gestion automatica. 4) **Suscripcion no renovable**: acceso temporal sin renovacion automatica (pase de temporada).

---

### Tarjeta 3
**Pregunta:** Como se obtienen y muestran productos con StoreKit 2?
**Respuesta:** 1) Definir product IDs en App Store Connect o en un archivo StoreKit Configuration (testing). 2) Cargar productos: `let productos = try await Product.products(for: ["premium_monthly", "premium_annual"])`. 3) Mostrar con `StoreView(ids:)` para UI automatica, o crear UI custom iterando los productos y mostrando `.displayName`, `.displayPrice`.

---

### Tarjeta 4
**Pregunta:** Como se procesa una compra con `Transaction` en StoreKit 2?
**Respuesta:** 1) Iniciar compra: `let resultado = try await producto.purchase()`. 2) Verificar resultado: `case .success(let verificacion)` -> `let transaccion = try verificacion.payloadValue`. 3) Entregar contenido al usuario. 4) Finalizar transaccion: `await transaccion.finish()`. Siempre escuchar `Transaction.updates` para compras restauradas o cambios de suscripcion.

---

### Tarjeta 5
**Pregunta:** Que son los entitlements y como se verifican con StoreKit 2?
**Respuesta:** Los entitlements representan a que tiene derecho el usuario (features premium, nivel de suscripcion). Se verifican con: `for await entitlement in Transaction.currentEntitlements { ... }` que devuelve todas las transacciones activas. Para un producto especifico: `Transaction.currentEntitlement(for: "product_id")`. La verificacion es criptografica en el dispositivo (JWS).

---

### Tarjeta 6
**Pregunta:** Que es TestFlight y cuales son sus tres tipos de testers?
**Respuesta:** TestFlight es la plataforma de Apple para distribuir builds beta. Tipos: 1) **Interno** (hasta 100): miembros del equipo en App Store Connect, acceso inmediato sin review. 2) **Externo individual** (hasta 10,000): invitados por email, requiere beta review. 3) **Externo con enlace publico**: cualquiera con el link, limite configurable. Los builds expiran a los 90 dias.

---

### Tarjeta 7
**Pregunta:** Cuales son las razones mas comunes de rechazo en App Review?
**Respuesta:** 1) **Bugs y crashes**: la app no funciona correctamente. 2) **Metadata incorrecta**: screenshots o descripcion no reflejan la app real. 3) **Compras fuera de IAP**: intentar cobrar sin usar el sistema de Apple. 4) **Privacidad**: recopilar datos sin consentimiento o sin Privacy Manifest. 5) **Contenido inapropiado**. 6) **Performance**: la app es demasiado lenta o consume demasiada bateria.

---

### Tarjeta 8
**Pregunta:** Como se configura un StoreKit Configuration File para testing local?
**Respuesta:** 1) File > New > StoreKit Configuration File en Xcode. 2) Agregar productos con sus IDs, precios y tipo. 3) En el scheme de la app, seleccionar el archivo de configuracion en Options > StoreKit Configuration. 4) Las compras se simulan localmente sin App Store Connect. 5) Se puede simular renovaciones, cancelaciones, y reembolsos desde el Transaction Manager.

---

### Tarjeta 9
**Pregunta:** Que es `SubscriptionStoreView` y como simplifica la UI de suscripciones?
**Respuesta:** `SubscriptionStoreView` es una vista SwiftUI que muestra automaticamente los planes de suscripcion de un grupo. Se crea con `SubscriptionStoreView(groupID: "grupo_id")`. Apple maneja: 1) Mostrar precios localizados. 2) Indicar el plan actual. 3) Comparar planes. 4) Proceso de compra completo. 5) Restaurar compras. Se puede personalizar con marketing content y estilos.

---

### Tarjeta 10
**Pregunta:** Que informacion debe incluirse en la pagina de App Store para una revision exitosa?
**Respuesta:** 1) **Screenshots** reales de la app (no mockups genericos). 2) **Descripcion** clara de funcionalidad. 3) **Politica de privacidad** URL obligatoria. 4) **Credenciales de demo** si tiene login. 5) **Notas para el revisor** explicando funcionalidad no obvia. 6) **Categoria** correcta. 7) **Clasificacion de edad** (content rating) precisa. 8) **Privacy Nutrition Labels** completas y exactas.
