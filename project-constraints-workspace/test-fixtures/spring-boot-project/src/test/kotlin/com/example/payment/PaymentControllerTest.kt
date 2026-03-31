package com.example.payment

import io.mockk.every
import io.mockk.mockk
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.time.LocalDateTime
import kotlin.test.assertEquals

class PaymentControllerTest {

    private val paymentService = mockk<PaymentService>()
    private val controller = PaymentController(paymentService)

    @Test
    fun `cancelPayment returns CancelPaymentResponse on success`() {
        val cancelledAt = LocalDateTime.of(2026, 3, 31, 12, 0, 0)
        val expected = CancelPaymentResponse(
            id = 1L,
            status = "cancelled",
            amount = 99.99,
            cancelledAt = cancelledAt
        )
        every { paymentService.cancel(1L) } returns expected

        val result = controller.cancelPayment(1L)

        assertEquals(expected, result)
    }

    @Test
    fun `cancelPayment propagates PaymentNotFoundException`() {
        every { paymentService.cancel(999L) } throws PaymentNotFoundException(999L)

        assertThrows<PaymentNotFoundException> {
            controller.cancelPayment(999L)
        }
    }

    @Test
    fun `cancelPayment propagates InvalidPaymentStateException`() {
        every { paymentService.cancel(2L) } throws InvalidPaymentStateException("completed")

        assertThrows<InvalidPaymentStateException> {
            controller.cancelPayment(2L)
        }
    }
}
