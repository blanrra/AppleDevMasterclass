import Foundation

// MARK: - 1. PROTOCOLOS BÁSICOS

/// Protocol que define el comportamiento base de cualquier método de pago
protocol Payable {
    var amount: Decimal { get }
    var currency: String { get }
    
    func processPayment() -> PaymentResult
}

/// Protocol para métodos de pago que requieren verificación
protocol Verifiable {
    func verify() async throws -> Bool
}

/// Protocol para pagos que pueden ser reembolsados
protocol Refundable {
    func refund() async -> RefundResult
}

// MARK: - 2. PROTOCOL COMPOSITION (Composición de Protocolos)

/// Combina múltiples protocolos para crear un "super" protocolo
typealias SecurePayment = Payable & Verifiable

// MARK: - 3. TYPES Y RESULTS

enum PaymentResult {
    case success(transactionId: String)
    case failure(error: PaymentError)
}

enum RefundResult {
    case success(refundId: String)
    case failure(reason: String)
}

enum PaymentError: Error {
    case insufficientFunds
    case invalidCard
    case networkError
    case verificationFailed
}

// MARK: - 4. IMPLEMENTACIONES CONCRETAS

/// Implementación con struct (value type)
struct CreditCardPayment: Payable, Verifiable, Refundable {
    let amount: Decimal
    let currency: String
    let cardNumber: String
    let cvv: String
    
    func processPayment() -> PaymentResult {
        print("💳 Processing credit card payment: \(amount) \(currency)")
        // Simulación de procesamiento
        return .success(transactionId: UUID().uuidString)
    }
    
    func verify() async throws -> Bool {
        print("🔒 Verifying credit card...")
        // Simulación de verificación
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
        return !cardNumber.isEmpty && cvv.count == 3
    }
    
    func refund() async -> RefundResult {
        print("↩️ Processing refund for credit card")
        return .success(refundId: UUID().uuidString)
    }
}

/// Otra implementación - PayPal
struct PayPalPayment: Payable, Verifiable {
    let amount: Decimal
    let currency: String
    let email: String
    
    func processPayment() -> PaymentResult {
        print("🅿️ Processing PayPal payment: \(amount) \(currency)")
        return .success(transactionId: "PP-\(UUID().uuidString)")
    }
    
    func verify() async throws -> Bool {
        print("🔒 Verifying PayPal account...")
        try await Task.sleep(nanoseconds: 300_000_000)
        return email.contains("@")
    }
}

/// Cash payment - solo implementa Payable
struct CashPayment: Payable {
    let amount: Decimal
    let currency: String
    
    func processPayment() -> PaymentResult {
        print("💵 Processing cash payment: \(amount) \(currency)")
        return .success(transactionId: "CASH-\(UUID().uuidString)")
    }
}

// MARK: - 5. PROTOCOL EXTENSIONS (¡El poder real!)

/// Extensión que proporciona implementación por defecto
extension Payable {
    /// Método con implementación por defecto
    func formattedAmount() -> String {
        return "\(currency) \(amount)"
    }
    
    /// Validación básica con implementación por defecto
    func isValid() -> Bool {
        return amount > 0
    }
}

/// Extensión condicional - solo para pagos verificables
extension Payable where Self: Verifiable {
    /// Este método solo está disponible para tipos que también son Verifiable
    func processSecurely() async throws -> PaymentResult {
        print("🛡️ Starting secure payment process...")
        
        // Primero verificamos
        let isVerified = try await verify()
        
        guard isVerified else {
            return .failure(error: .verificationFailed)
        }
        
        // Luego procesamos
        return processPayment()
    }
}

// MARK: - 6. USO PRÁCTICO

/// Clase que procesa pagos - acepta cualquier tipo Payable
class PaymentProcessor {
    
    /// Acepta cualquier tipo que conforme a Payable
    func process(_ payment: any Payable) {
        guard payment.isValid() else {
            print("❌ Payment is invalid")
            return
        }
        
        print("\n--- Processing payment of \(payment.formattedAmount()) ---")
        let result = payment.processPayment()
        
        switch result {
        case .success(let transactionId):
            print("✅ Payment successful! Transaction ID: \(transactionId)")
        case .failure(let error):
            print("❌ Payment failed: \(error)")
        }
    }
    
    /// Método específico para pagos seguros
    func processSecure(_ payment: any SecurePayment) async throws {
        print("\n--- Processing SECURE payment ---")
        let result = try await payment.processSecurely()
        
        switch result {
        case .success(let transactionId):
            print("✅ Secure payment successful! Transaction ID: \(transactionId)")
        case .failure(let error):
            print("❌ Secure payment failed: \(error)")
        }
    }
    
    /// Procesa un array de diferentes tipos de pagos
    func processBatch(_ payments: [any Payable]) {
        print("\n========== BATCH PROCESSING ==========")
        for payment in payments {
            process(payment)
        }
    }
}

// MARK: - 7. EJEMPLO DE EJECUCIÓN

func runPaymentDemo() async {
    let processor = PaymentProcessor()
    
    // Diferentes tipos de pagos
    let creditCard = CreditCardPayment(
        amount: 99.99,
        currency: "USD",
        cardNumber: "4532123456789012",
        cvv: "123"
    )
    
    let paypal = PayPalPayment(
        amount: 49.99,
        currency: "EUR",
        email: "user@example.com"
    )
    
    let cash = CashPayment(
        amount: 20.00,
        currency: "USD"
    )
    
    // Procesar pagos individuales
    processor.process(creditCard)
    processor.process(paypal)
    processor.process(cash)
    
    // Procesar de forma segura (solo funciona con tipos Verifiable)
    do {
        try await processor.processSecure(creditCard)
        try await processor.processSecure(paypal)
        // try await processor.processSecure(cash) // ❌ Esto no compilaría!
    } catch {
        print("Error processing secure payment: \(error)")
    }
    
    // Batch processing - array heterogéneo de diferentes tipos
    let allPayments: [any Payable] = [creditCard, paypal, cash]
    processor.processBatch(allPayments)
    
    print("\n========== POLYMORPHISM DEMO ==========")
    demonstratePolymorphism()
}

func demonstratePolymorphism() {
    // Todos estos tipos diferentes pueden tratarse como Payable
    let payments: [any Payable] = [
        CreditCardPayment(amount: 100, currency: "USD", cardNumber: "1234", cvv: "123"),
        PayPalPayment(amount: 50, currency: "EUR", email: "test@test.com"),
        CashPayment(amount: 25, currency: "GBP")
    ]

    // Podemos iterar y llamar métodos del protocol sin saber el tipo concreto
    for payment in payments {
        print("\nType: \(type(of: payment))")
        print("Amount: \(payment.formattedAmount())")
        print("Valid: \(payment.isValid())")
    }
}

// MARK: - Entry Point

Task {
    await runPaymentDemo()
    exit(0)
}

RunLoop.main.run()
