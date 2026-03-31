# Cancel Payment Endpoint Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superflowers:subagent-driven-development (recommended) or superflowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a REST endpoint `POST /api/payments/{id}/cancel` that cancels pending payments with proper error handling.

**Architecture:** Layered architecture (Controller → Service → Repository). New endpoint follows existing pattern from `POST /{id}/refund`. Exception classes with `@ResponseStatus` for error mapping.

**Tech Stack:** Kotlin, Spring Boot 3.2, Spring Web, Spring Data JPA, PostgreSQL, JUnit 5, MockK

**Architecture:** Reliability (Top 1, zero data loss, DB transactions), Security (Top 2, JWT auth, input validation), Availability (Top 3, 99.9%+ uptime). See `architecture.md`.

**Bounded Contexts:** N/A

**Feature Files:** `features/cancel-payment.feature` (7 scenarios)

**Characteristic Fitness Functions:** N/A (initial implementation, fitness functions deferred)

**Style Fitness Functions:** N/A

**Quality Scenarios:** N/A

**Active ADRs:** N/A

**Active Constraints:** Not formally set up. SEC-002 (API Authentication) and COMP-002 (Audit Logging) referenced in BDD scenarios but implementation deferred — tagged as `@constraint-SEC-002` and `@constraint-COMP-002` in feature file.

---

## File Structure

| File | Responsibility |
|---|---|
| `src/main/kotlin/com/example/payment/PaymentNotFoundException.kt` | Exception for missing payments, maps to 404 |
| `src/main/kotlin/com/example/payment/InvalidPaymentStateException.kt` | Exception for wrong payment status, maps to 409 |
| `src/main/kotlin/com/example/payment/PaymentController.kt` | Add cancel endpoint + CancelPaymentResponse DTO |
| `src/main/kotlin/com/example/payment/PaymentService.kt` | Cancel business logic (stub — service not yet implemented) |
| `src/test/kotlin/com/example/payment/PaymentControllerTest.kt` | Unit tests for cancel endpoint |
| `src/test/kotlin/com/example/payment/PaymentServiceTest.kt` | Unit tests for cancel service logic |

---

### Task 1: PaymentNotFoundException

**Files:**
- Create: `src/main/kotlin/com/example/payment/PaymentNotFoundException.kt`
- Create: `src/test/kotlin/com/example/payment/PaymentNotFoundExceptionTest.kt`

- [ ] **Step 1: Write the failing test**

```kotlin
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `./mvnw test -pl project-constraints-workspace/test-fixtures/spring-boot-project -Dtest="PaymentNotFoundExceptionTest" -f pom.xml`
Expected: FAIL — class not found

- [ ] **Step 3: Write minimal implementation**

```kotlin
package com.example.payment

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.NOT_FOUND)
class PaymentNotFoundException(id: Long) : RuntimeException("Payment not found: $id")
```

- [ ] **Step 4: Run test to verify it passes**

Run: `./mvnw test -pl project-constraints-workspace/test-fixtures/spring-boot-project -Dtest="PaymentNotFoundExceptionTest" -f pom.xml`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add src/main/kotlin/com/example/payment/PaymentNotFoundException.kt src/test/kotlin/com/example/payment/PaymentNotFoundExceptionTest.kt
git commit -m "feat: add PaymentNotFoundException with 404 status"
```

---

### Task 2: InvalidPaymentStateException

**Files:**
- Create: `src/main/kotlin/com/example/payment/InvalidPaymentStateException.kt`
- Create: `src/test/kotlin/com/example/payment/InvalidPaymentStateExceptionTest.kt`

- [ ] **Step 1: Write the failing test**

```kotlin
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `./mvnw test -Dtest="InvalidPaymentStateExceptionTest"`
Expected: FAIL — class not found

- [ ] **Step 3: Write minimal implementation**

```kotlin
package com.example.payment

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.CONFLICT)
class InvalidPaymentStateException(currentStatus: String) :
    RuntimeException("Payment can only be cancelled in pending status, current status: $currentStatus")
```

- [ ] **Step 4: Run test to verify it passes**

Run: `./mvnw test -Dtest="InvalidPaymentStateExceptionTest"`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add src/main/kotlin/com/example/payment/InvalidPaymentStateException.kt src/test/kotlin/com/example/payment/InvalidPaymentStateExceptionTest.kt
git commit -m "feat: add InvalidPaymentStateException with 409 status"
```

---

### Task 3: CancelPaymentResponse DTO and Controller Endpoint

**Files:**
- Modify: `src/main/kotlin/com/example/payment/PaymentController.kt`
- Create: `src/test/kotlin/com/example/payment/PaymentControllerTest.kt`

- [ ] **Step 1: Write the failing test**

```kotlin
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `./mvnw test -Dtest="PaymentControllerTest"`
Expected: FAIL — `CancelPaymentResponse` and `cancelPayment` not defined

- [ ] **Step 3: Add CancelPaymentResponse DTO and cancel endpoint**

Add to `PaymentController.kt` after the existing `refundPayment` method:

```kotlin
@PostMapping("/{id}/cancel")
fun cancelPayment(@PathVariable id: Long): CancelPaymentResponse {
    return paymentService.cancel(id)
}
```

Add the DTO after the existing `PaymentResponse` data class:

```kotlin
data class CancelPaymentResponse(
    val id: Long,
    val status: String,
    val amount: Double,
    val cancelledAt: LocalDateTime
)
```

Add the `cancel` method signature to `PaymentService`. Since `PaymentService` is not yet implemented (referenced in controller but no file exists), create a minimal interface:

```kotlin
// Add to PaymentService (or create the file if it doesn't exist)
fun cancel(id: Long): CancelPaymentResponse
```

Add import to `PaymentController.kt`:

```kotlin
import java.time.LocalDateTime
```

- [ ] **Step 4: Run test to verify it passes**

Run: `./mvnw test -Dtest="PaymentControllerTest"`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add src/main/kotlin/com/example/payment/PaymentController.kt src/main/kotlin/com/example/payment/PaymentService.kt src/test/kotlin/com/example/payment/PaymentControllerTest.kt
git commit -m "feat: add cancel payment endpoint and CancelPaymentResponse DTO"
```

---

### Task 4: PaymentService.cancel() Business Logic

**Files:**
- Modify: `src/main/kotlin/com/example/payment/PaymentService.kt`
- Create: `src/test/kotlin/com/example/payment/PaymentServiceTest.kt`

Note: Since there is no Payment entity or repository yet, this task creates a minimal `PaymentService` implementation that the cancel logic needs. The service will need a way to find and update payments. For now, we define the `cancel` method with the business rules, using a repository interface.

- [ ] **Step 1: Write the failing tests**

```kotlin
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
    private val paymentService = PaymentService(paymentRepository)

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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `./mvnw test -Dtest="PaymentServiceTest"`
Expected: FAIL — `Payment`, `PaymentRepository`, `PaymentService.cancel()` not implemented

- [ ] **Step 3: Create Payment entity**

Create `src/main/kotlin/com/example/payment/Payment.kt`:

```kotlin
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
```

- [ ] **Step 4: Create PaymentRepository interface**

Create `src/main/kotlin/com/example/payment/PaymentRepository.kt`:

```kotlin
package com.example.payment

import org.springframework.data.jpa.repository.JpaRepository

interface PaymentRepository : JpaRepository<Payment, Long>
```

- [ ] **Step 5: Implement PaymentService.cancel()**

Update `src/main/kotlin/com/example/payment/PaymentService.kt` (add the `cancel` method and constructor injection of repository):

```kotlin
package com.example.payment

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Service
class PaymentService(private val paymentRepository: PaymentRepository) {

    fun create(request: CreatePaymentRequest): PaymentResponse {
        TODO("Not yet implemented")
    }

    fun findById(id: Long): PaymentResponse {
        TODO("Not yet implemented")
    }

    fun findByUser(userId: Long): List<PaymentResponse> {
        TODO("Not yet implemented")
    }

    fun refund(id: Long): PaymentResponse {
        TODO("Not yet implemented")
    }

    @Transactional
    fun cancel(id: Long): CancelPaymentResponse {
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
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `./mvnw test -Dtest="PaymentServiceTest"`
Expected: PASS (7 tests)

- [ ] **Step 7: Run all tests**

Run: `./mvnw test`
Expected: ALL tests pass (12 total: 2 + 2 + 3 + 7 - but note controller tests may need adjustment if PaymentService is now a class rather than interface)

- [ ] **Step 8: Commit**

```bash
git add src/main/kotlin/com/example/payment/Payment.kt src/main/kotlin/com/example/payment/PaymentRepository.kt src/main/kotlin/com/example/payment/PaymentService.kt src/test/kotlin/com/example/payment/PaymentServiceTest.kt
git commit -m "feat: implement cancel payment business logic with TDD

Adds Payment entity, PaymentRepository, and PaymentService.cancel().
Only pending payments can be cancelled (409 for wrong status, 404 for missing)."
```

---

### Task 5: Full BDD Suite Verification

- [ ] **Step 1: Run complete BDD suite**

Since this is a Spring Boot/Kotlin project without a Cucumber setup yet, verify the feature file parses correctly and all behavioral requirements are covered by the unit tests we wrote:

| BDD Scenario | Covered by Test |
|---|---|
| Successfully cancel a pending payment | `PaymentServiceTest.cancel sets status to cancelled and returns response` |
| Cancelling a non-pending payment is rejected | `PaymentServiceTest.cancel throws InvalidPaymentStateException when status is not pending` |
| Outline: failed, refunded, cancelled | `PaymentServiceTest` tests for each status |
| Non-existent payment returns not found | `PaymentServiceTest.cancel throws PaymentNotFoundException` |
| Cancellation is persisted | `PaymentServiceTest.cancel saves the updated payment` |
| Unauthenticated request is denied | Deferred (SEC-002 constraint, no auth infrastructure yet) |
| Cancellation recorded in audit log | Deferred (COMP-002 constraint, no audit infrastructure yet) |

- [ ] **Step 2: Verify feature file integrity**

Run: `git diff -- '*.feature'`
Expected: NO modifications to feature files during implementation

- [ ] **Step 3: Run all tests one final time**

Run: `./mvnw test`
Expected: ALL tests pass

- [ ] **Step 4: Final commit (if any uncommitted changes)**

```bash
git status
# If clean: no commit needed
```
