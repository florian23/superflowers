package com.example.payment

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

interface PaymentService {
    fun create(request: CreatePaymentRequest): PaymentResponse
    fun findById(id: Long): PaymentResponse
    fun findByUser(userId: Long): List<PaymentResponse>
    fun refund(id: Long): PaymentResponse
    fun cancel(id: Long): CancelPaymentResponse
}

@Service
class PaymentServiceImpl(private val paymentRepository: PaymentRepository) : PaymentService {

    override fun create(request: CreatePaymentRequest): PaymentResponse {
        TODO("Not yet implemented")
    }

    override fun findById(id: Long): PaymentResponse {
        TODO("Not yet implemented")
    }

    override fun findByUser(userId: Long): List<PaymentResponse> {
        TODO("Not yet implemented")
    }

    override fun refund(id: Long): PaymentResponse {
        TODO("Not yet implemented")
    }

    @Transactional
    override fun cancel(id: Long): CancelPaymentResponse {
        val payment = paymentRepository.findById(id)
            .orElseThrow { PaymentNotFoundException(id) }

        if (payment.status != "pending") {
            throw InvalidPaymentStateException(payment.status)
        }

        payment.status = "cancelled"
        payment.cancelledAt = LocalDateTime.now()
        paymentRepository.save(payment)

        return CancelPaymentResponse(
            id = payment.id,
            status = payment.status,
            amount = payment.amount,
            cancelledAt = payment.cancelledAt!!
        )
    }
}
