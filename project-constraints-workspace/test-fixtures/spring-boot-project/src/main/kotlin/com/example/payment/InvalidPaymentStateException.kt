package com.example.payment

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.CONFLICT)
class InvalidPaymentStateException(currentStatus: String) :
    RuntimeException("Payment can only be cancelled in pending status, current status: $currentStatus")
