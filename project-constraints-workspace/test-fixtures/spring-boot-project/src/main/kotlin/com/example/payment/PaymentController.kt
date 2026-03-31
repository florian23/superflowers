package com.example.payment

import java.time.LocalDateTime
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/payments")
class PaymentController(private val paymentService: PaymentService) {

    @PostMapping
    fun createPayment(@RequestBody request: CreatePaymentRequest): PaymentResponse {
        return paymentService.create(request)
    }

    @GetMapping("/{id}")
    fun getPayment(@PathVariable id: Long): PaymentResponse {
        return paymentService.findById(id)
    }

    @GetMapping
    fun listPayments(@RequestParam userId: Long): List<PaymentResponse> {
        return paymentService.findByUser(userId)
    }

    @PostMapping("/{id}/refund")
    fun refundPayment(@PathVariable id: Long): PaymentResponse {
        return paymentService.refund(id)
    }

    @PostMapping("/{id}/cancel")
    fun cancelPayment(@PathVariable id: Long): CancelPaymentResponse {
        return paymentService.cancel(id)
    }
}

data class CreatePaymentRequest(
    val userId: Long,
    val amount: Double,
    val currency: String,
    val cardNumber: String,   // PII
    val cardHolder: String,   // PII
    val iban: String?         // PII
)

data class PaymentResponse(
    val id: Long,
    val status: String,
    val amount: Double
)

data class CancelPaymentResponse(
    val id: Long,
    val status: String,
    val amount: Double,
    val cancelledAt: LocalDateTime
)
