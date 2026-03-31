package com.example.payment

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.NOT_FOUND)
class PaymentNotFoundException(id: Long) : RuntimeException("Payment not found: $id")
