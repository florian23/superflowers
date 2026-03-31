package com.example.payment

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.time.LocalDateTime
import kotlin.test.assertEquals

class PaymentServiceTest {

    private val paymentRepository = mockk<PaymentRepository>(relaxed = true)
    private val paymentService = PaymentServiceImpl(paymentRepository)

    @Test
    fun `cancel sets status to cancelled and returns response`() {
        val payment = Payment(id = 1L, status = "pending", amount = 99.99)
        every { paymentRepository.findById(1L) } returns java.util.Optional.of(payment)
        every { paymentRepository.save(any()) } answers { firstArg() }

        val result = paymentService.cancel(1L)

        assertEquals("cancelled", result.status)
        assertEquals(1L, result.id)
        assertEquals(99.99, result.amount)
    }

    @Test
    fun `cancel saves the updated payment`() {
        val payment = Payment(id = 1L, status = "pending", amount = 99.99)
        every { paymentRepository.findById(1L) } returns java.util.Optional.of(payment)
        every { paymentRepository.save(any()) } answers { firstArg() }

        paymentService.cancel(1L)

        verify { paymentRepository.save(match { it.status == "cancelled" && it.cancelledAt != null }) }
    }

    @Test
    fun `cancel throws PaymentNotFoundException when payment does not exist`() {
        every { paymentRepository.findById(999L) } returns java.util.Optional.empty()

        assertThrows<PaymentNotFoundException> {
            paymentService.cancel(999L)
        }
    }

    @Test
    fun `cancel throws InvalidPaymentStateException when status is not pending`() {
        val payment = Payment(id = 2L, status = "completed", amount = 50.00)
        every { paymentRepository.findById(2L) } returns java.util.Optional.of(payment)

        val exception = assertThrows<InvalidPaymentStateException> {
            paymentService.cancel(2L)
        }
        assertEquals(
            "Payment can only be cancelled in pending status, current status: completed",
            exception.message
        )
    }

    @Test
    fun `cancel throws InvalidPaymentStateException for failed status`() {
        val payment = Payment(id = 3L, status = "failed", amount = 25.00)
        every { paymentRepository.findById(3L) } returns java.util.Optional.of(payment)

        assertThrows<InvalidPaymentStateException> {
            paymentService.cancel(3L)
        }
    }

    @Test
    fun `cancel throws InvalidPaymentStateException for refunded status`() {
        val payment = Payment(id = 4L, status = "refunded", amount = 25.00)
        every { paymentRepository.findById(4L) } returns java.util.Optional.of(payment)

        assertThrows<InvalidPaymentStateException> {
            paymentService.cancel(4L)
        }
    }

    @Test
    fun `cancel throws InvalidPaymentStateException for cancelled status`() {
        val payment = Payment(id = 5L, status = "cancelled", amount = 25.00)
        every { paymentRepository.findById(5L) } returns java.util.Optional.of(payment)

        assertThrows<InvalidPaymentStateException> {
            paymentService.cancel(5L)
        }
    }
}
