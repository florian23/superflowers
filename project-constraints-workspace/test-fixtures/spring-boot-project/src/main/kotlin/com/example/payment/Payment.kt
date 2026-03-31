package com.example.payment

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "payments")
data class Payment(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    var status: String = "pending",

    val amount: Double = 0.0,

    var cancelledAt: LocalDateTime? = null
)
