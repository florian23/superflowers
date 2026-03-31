package com.example.payment

import org.junit.jupiter.api.Test
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.http.HttpStatus
import kotlin.test.assertEquals

class InvalidPaymentStateExceptionTest {

    @Test
    fun `exception has 409 response status`() {
        val annotation = InvalidPaymentStateException::class.java
            .getAnnotation(ResponseStatus::class.java)
        assertEquals(HttpStatus.CONFLICT, annotation.value)
    }

    @Test
    fun `exception contains current status in message`() {
        val exception = InvalidPaymentStateException("completed")
        assertEquals(
            "Payment can only be cancelled in pending status, current status: completed",
            exception.message
        )
    }
}
