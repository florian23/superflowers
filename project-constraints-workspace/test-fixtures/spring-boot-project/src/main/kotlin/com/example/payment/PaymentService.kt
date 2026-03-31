package com.example.payment

interface PaymentService {
    fun create(request: CreatePaymentRequest): PaymentResponse
    fun findById(id: Long): PaymentResponse
    fun findByUser(userId: Long): List<PaymentResponse>
    fun refund(id: Long): PaymentResponse
    fun cancel(id: Long): CancelPaymentResponse
}
