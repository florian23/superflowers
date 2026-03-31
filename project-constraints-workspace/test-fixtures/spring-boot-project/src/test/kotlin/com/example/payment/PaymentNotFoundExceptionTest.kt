package com.example.payment

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.http.HttpStatus
import kotlin.test.assertEquals

class PaymentNotFoundExceptionTest {

    @Test
    fun `exception has 404 response status`() {
        val annotation = PaymentNotFoundException::class.java
            .getAnnotation(ResponseStatus::class.java)
        assertEquals(HttpStatus.NOT_FOUND, annotation.value)
    }

    @Test
    fun `exception contains payment id in message`() {
        val exception = PaymentNotFoundException(42)
        assertEquals("Payment not found: 42", exception.message)
    }
}
