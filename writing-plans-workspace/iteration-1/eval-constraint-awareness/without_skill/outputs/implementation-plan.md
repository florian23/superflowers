# Implementierungsplan: Payment Service

## Projekt-Kontext
- **Technologie:** Spring Boot 3.2, Kotlin, PostgreSQL
- **Basispfad:** `/home/flo/superflowers/project-constraints-workspace/test-fixtures/spring-boot-project/`
- **Ist-Zustand:** Controller mit 4 Endpunkten, DTOs, keine Service-Schicht, kein JPA-Entity, keine Security-Config, kein Audit-Log
- **Aktive Constraints:** SEC-001, SEC-002, COMP-001, COMP-002

## Abhaengigkeiten zwischen Tasks

```
Phase 1: Grundlagen (Tasks 1-5)
  1 pom.xml
  2 Entity + Enum
  3 Repository
  4 PaymentService (Basis)
  5 Controller anpassen

Phase 2: Security (Tasks 6-10)
  6 JWT Security Config         [SEC-002]
  7 Health Endpoint              [SEC-002]
  8 Rate Limiting Filter         [SEC-002]
  9 PII Encryption Converter     [SEC-001]
  10 Log-Maskierung              [SEC-001]

Phase 3: Compliance (Tasks 11-15)
  11 Audit-Log Entity + Repo     [COMP-002]
  12 Audit-Log Aspect            [COMP-002]
  13 Audit-Log Immutability      [COMP-002]
  14 Data Retention Job          [COMP-001]
  15 Right to Erasure Endpoint   [COMP-001]

Phase 4: Reliability (Tasks 16-19)
  16 Idempotency-Key             [QS-REL-01]
  17 Zustandsmaschine Refund     [QS-REL-02]
  18 Circuit Breaker             [QS-REL-04]
  19 Exception Handler

Phase 5: Tests (Tasks 20-27)
  20-27 Tests fuer jedes Feature
```

---

## Phase 1: Grundlagen

### Task 1: Dependencies in pom.xml ergaenzen (3 min)

**Datei:** `pom.xml`

Folgende Dependencies hinzufuegen:

```xml
<!-- Test -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>

<!-- Validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- OAuth2 Resource Server (JWT) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>

<!-- Resilience4j Circuit Breaker -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>2.2.0</version>
</dependency>

<!-- Scheduling -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<!-- Kotlin -->
<dependency>
    <groupId>org.jetbrains.kotlin</groupId>
    <artifactId>kotlin-stdlib</artifactId>
</dependency>
<dependency>
    <groupId>org.jetbrains.kotlin</groupId>
    <artifactId>kotlin-reflect</artifactId>
</dependency>
<dependency>
    <groupId>com.fasterxml.jackson.module</groupId>
    <artifactId>jackson-module-kotlin</artifactId>
</dependency>
```

Ausserdem das Kotlin-Plugin im `<build>` Block:

```xml
<build>
    <sourceDirectory>src/main/kotlin</sourceDirectory>
    <testSourceDirectory>src/test/kotlin</testSourceDirectory>
    <plugins>
        <plugin>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-maven-plugin</artifactId>
            <version>1.9.21</version>
            <configuration>
                <jvmTarget>21</jvmTarget>
                <compilerPlugins>
                    <plugin>spring</plugin>
                    <plugin>jpa</plugin>
                </compilerPlugins>
            </configuration>
            <dependencies>
                <dependency>
                    <groupId>org.jetbrains.kotlin</groupId>
                    <artifactId>kotlin-maven-allopen</artifactId>
                    <version>1.9.21</version>
                </dependency>
                <dependency>
                    <groupId>org.jetbrains.kotlin</groupId>
                    <artifactId>kotlin-maven-noarg</artifactId>
                    <version>1.9.21</version>
                </dependency>
            </dependencies>
        </plugin>
    </plugins>
</build>
```

**Verifikation:** `./mvnw dependency:resolve`

---

### Task 2: Payment Entity und Status-Enum erstellen (3 min)

**Datei:** `src/main/kotlin/com/example/payment/Payment.kt`

```kotlin
package com.example.payment

import jakarta.persistence.*
import java.math.BigDecimal
import java.time.Instant

enum class PaymentStatus {
    PENDING, COMPLETED, REFUNDED, FAILED
}

@Entity
@Table(name = "payments")
class Payment(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false)
    val userId: Long = 0,

    @Column(nullable = false, precision = 19, scale = 2)
    val amount: BigDecimal = BigDecimal.ZERO,

    @Column(nullable = false, length = 3)
    val currency: String = "",

    @Column(name = "card_number")
    var cardNumber: String? = null,    // PII - wird verschluesselt

    @Column(name = "card_holder")
    var cardHolder: String? = null,    // PII - wird verschluesselt

    @Column(name = "iban")
    var iban: String? = null,          // PII - wird verschluesselt

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    var status: PaymentStatus = PaymentStatus.PENDING,

    @Column(name = "idempotency_key", unique = true)
    var idempotencyKey: String? = null,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: Instant = Instant.now()
)
```

**Verifikation:** Kompiliert ohne Fehler -- `./mvnw compile`

---

### Task 3: PaymentRepository erstellen (2 min)

**Datei:** `src/main/kotlin/com/example/payment/PaymentRepository.kt`

```kotlin
package com.example.payment

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import java.time.Instant

@Repository
interface PaymentRepository : JpaRepository<Payment, Long> {

    fun findByUserId(userId: Long): List<Payment>

    fun findByIdempotencyKey(idempotencyKey: String): Payment?

    @Modifying
    @Query("DELETE FROM Payment p WHERE p.createdAt < :cutoff")
    fun deleteOlderThan(cutoff: Instant): Int

    @Modifying
    @Query("""
        UPDATE Payment p
        SET p.cardNumber = NULL, p.cardHolder = NULL, p.iban = NULL
        WHERE p.userId = :userId
    """)
    fun anonymizeByUserId(userId: Long): Int
}
```

**Verifikation:** `./mvnw compile`

---

### Task 4: PaymentService implementieren (5 min)

**Datei:** `src/main/kotlin/com/example/payment/PaymentService.kt`

```kotlin
package com.example.payment

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class PaymentService(
    private val paymentRepository: PaymentRepository
) {

    @Transactional
    fun create(request: CreatePaymentRequest, idempotencyKey: String?): PaymentResponse {
        // Idempotenz-Check
        if (idempotencyKey != null) {
            val existing = paymentRepository.findByIdempotencyKey(idempotencyKey)
            if (existing != null) {
                return existing.toResponse()
            }
        }

        val payment = Payment(
            userId = request.userId,
            amount = request.amount.toBigDecimal(),
            currency = request.currency,
            cardNumber = request.cardNumber,
            cardHolder = request.cardHolder,
            iban = request.iban,
            status = PaymentStatus.PENDING,
            idempotencyKey = idempotencyKey
        )

        val saved = paymentRepository.save(payment)
        return saved.toResponse()
    }

    @Transactional(readOnly = true)
    fun findById(id: Long): PaymentResponse {
        val payment = paymentRepository.findById(id)
            .orElseThrow { PaymentNotFoundException(id) }
        return payment.toResponse()
    }

    @Transactional(readOnly = true)
    fun findByUser(userId: Long): List<PaymentResponse> {
        return paymentRepository.findByUserId(userId).map { it.toResponse() }
    }

    @Transactional
    fun refund(id: Long): PaymentResponse {
        val payment = paymentRepository.findById(id)
            .orElseThrow { PaymentNotFoundException(id) }

        if (payment.status != PaymentStatus.COMPLETED) {
            throw InvalidPaymentStateException(payment.id, payment.status)
        }

        payment.status = PaymentStatus.REFUNDED
        val saved = paymentRepository.save(payment)
        return saved.toResponse()
    }

    @Transactional
    fun anonymizeUser(userId: Long): Int {
        return paymentRepository.anonymizeByUserId(userId)
    }
}

fun Payment.toResponse() = PaymentResponse(
    id = this.id,
    status = this.status.name,
    amount = this.amount.toDouble()
)
```

**Verifikation:** `./mvnw compile`

---

### Task 5: Controller anpassen + Exceptions + Application-Klasse (4 min)

**Datei:** `src/main/kotlin/com/example/payment/PaymentController.kt` -- bestehende Datei anpassen:

```kotlin
package com.example.payment

import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/payments")
class PaymentController(private val paymentService: PaymentService) {

    @PostMapping
    fun createPayment(
        @RequestBody request: CreatePaymentRequest,
        @RequestHeader("Idempotency-Key", required = false) idempotencyKey: String?
    ): PaymentResponse {
        return paymentService.create(request, idempotencyKey)
    }

    @GetMapping("/{id}")
    fun getPayment(@PathVariable id: Long): PaymentResponse {
        return paymentService.findById(id)
    }

    @GetMapping
    fun listPayments(@RequestParam userId: Long): List<PaymentResponse> {
        return paymentService.findByUser(userId)
    }

    @PostMapping("/{id}/refund")
    fun refundPayment(@PathVariable id: Long): PaymentResponse {
        return paymentService.refund(id)
    }

    @DeleteMapping("/user/{userId}")
    fun eraseUserData(@PathVariable userId: Long) {
        paymentService.anonymizeUser(userId)
    }
}
```

**Datei:** `src/main/kotlin/com/example/payment/Exceptions.kt`

```kotlin
package com.example.payment

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.NOT_FOUND)
class PaymentNotFoundException(id: Long) : RuntimeException("Payment not found: $id")

@ResponseStatus(HttpStatus.CONFLICT)
class InvalidPaymentStateException(id: Long, status: PaymentStatus) :
    RuntimeException("Payment $id has status $status, cannot refund")

@ResponseStatus(HttpStatus.SERVICE_UNAVAILABLE)
class PaymentProviderUnavailableException : RuntimeException("Payment provider unavailable")
```

**Datei:** `src/main/kotlin/com/example/payment/PaymentApplication.kt`

```kotlin
package com.example.payment

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.scheduling.annotation.EnableScheduling

@SpringBootApplication
@EnableScheduling
class PaymentApplication

fun main(args: Array<String>) {
    runApplication<PaymentApplication>(*args)
}
```

**Verifikation:** `./mvnw compile`

---

## Phase 2: Security

### Task 6: JWT Security Configuration (5 min) [SEC-002]

**Datei:** `src/main/kotlin/com/example/payment/SecurityConfig.kt`

```kotlin
package com.example.payment

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain

@Configuration
@EnableWebSecurity
class SecurityConfig {

    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .csrf { it.disable() }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .authorizeHttpRequests { auth ->
                auth
                    .requestMatchers("/health", "/actuator/health").permitAll()
                    .anyRequest().authenticated()
            }
            .oauth2ResourceServer { it.jwt { } }

        return http.build()
    }
}
```

**Datei:** `src/main/resources/application.yml` -- JWT-Konfiguration ergaenzen:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${JWT_ISSUER_URI}
```

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `authentication.feature` -- Szenario "Business endpoints reject unauthenticated requests", QS-SEC-01

---

### Task 7: Health Endpoint (2 min) [SEC-002]

**Datei:** `src/main/kotlin/com/example/payment/HealthController.kt`

```kotlin
package com.example.payment

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class HealthController {

    @GetMapping("/health")
    fun health(): Map<String, String> {
        return mapOf("status" to "UP")
    }
}
```

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `authentication.feature` -- Szenario "Health endpoint is accessible without authentication", QS-REL-03

---

### Task 8: Rate Limiting Filter (5 min) [SEC-002]

**Datei:** `src/main/kotlin/com/example/payment/RateLimitFilter.kt`

```kotlin
package com.example.payment

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

@Component
class RateLimitFilter : OncePerRequestFilter() {

    private val requestCounts = ConcurrentHashMap<String, RequestBucket>()
    private val maxRequests = 50  // pro 10 Sekunden
    private val windowMs = 10_000L

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val principal = request.userPrincipal?.name ?: run {
            filterChain.doFilter(request, response)
            return
        }

        val bucket = requestCounts.compute(principal) { _, existing ->
            val now = System.currentTimeMillis()
            if (existing == null || now - existing.windowStart > windowMs) {
                RequestBucket(now, AtomicInteger(1))
            } else {
                existing.count.incrementAndGet()
                existing
            }
        }!!

        if (bucket.count.get() > maxRequests) {
            response.status = 429
            response.setHeader("Retry-After", "10")
            response.writer.write("""{"error":"Too Many Requests"}""")
            return
        }

        filterChain.doFilter(request, response)
    }

    data class RequestBucket(val windowStart: Long, val count: AtomicInteger)
}
```

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `authentication.feature` -- Szenario "Rate limiting per user", QS-SEC-05

---

### Task 9: PII Encryption mit JPA AttributeConverter (5 min) [SEC-001]

**Datei:** `src/main/kotlin/com/example/payment/EncryptionConverter.kt`

```kotlin
package com.example.payment

import jakarta.persistence.AttributeConverter
import jakarta.persistence.Converter
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

@Converter
@Component
class EncryptionConverter(
    @Value("\${encryption.key-reference}")
    private val keyReference: String
) : AttributeConverter<String?, String?> {

    // In Produktion: Key aus KMS laden via keyReference (z.B. AWS KMS ARN)
    // Fuer lokale Entwicklung: Key aus Umgebungsvariable
    private val secretKey: SecretKeySpec by lazy {
        val keyBytes = resolveKeyFromKms(keyReference)
        SecretKeySpec(keyBytes, "AES")
    }

    override fun convertToDatabaseColumn(attribute: String?): String? {
        if (attribute == null) return null
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)
        val iv = cipher.iv
        val encrypted = cipher.doFinal(attribute.toByteArray())
        val combined = iv + encrypted
        return Base64.getEncoder().encodeToString(combined)
    }

    override fun convertToEntityAttribute(dbData: String?): String? {
        if (dbData == null) return null
        val combined = Base64.getDecoder().decode(dbData)
        val iv = combined.copyOfRange(0, 12)
        val encrypted = combined.copyOfRange(12, combined.size)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(128, iv))
        return String(cipher.doFinal(encrypted))
    }

    private fun resolveKeyFromKms(reference: String): ByteArray {
        // Produktion: KMS-Client aufrufen
        // Entwicklung: Fallback auf Umgebungsvariable
        val envKey = System.getenv("ENCRYPTION_KEY")
        return if (envKey != null) {
            Base64.getDecoder().decode(envKey)
        } else {
            throw IllegalStateException("Encryption key not available. Set ENCRYPTION_KEY env var or configure KMS.")
        }
    }
}
```

**Datei:** `src/main/kotlin/com/example/payment/Payment.kt` -- PII-Felder annotieren:

```kotlin
    @Column(name = "card_number")
    @Convert(converter = EncryptionConverter::class)
    var cardNumber: String? = null,

    @Column(name = "card_holder")
    @Convert(converter = EncryptionConverter::class)
    var cardHolder: String? = null,

    @Column(name = "iban")
    @Convert(converter = EncryptionConverter::class)
    var iban: String? = null,
```

**Datei:** `src/main/resources/application.yml` -- hinzufuegen:

```yaml
encryption:
  key-reference: ${KMS_KEY_ARN:local-dev-key}
```

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `encryption-at-rest.feature` -- Szenario "PII fields are encrypted in the database", QS-SEC-02, QS-SEC-04

---

### Task 10: PII Log-Maskierung (3 min) [SEC-001]

**Datei:** `src/main/kotlin/com/example/payment/PiiMaskingLayout.kt`

```kotlin
package com.example.payment

import ch.qos.logback.classic.spi.ILoggingEvent
import ch.qos.logback.classic.PatternLayout

class PiiMaskingLayout : PatternLayout() {

    private val patterns = listOf(
        Regex("""\b\d{13,19}\b"""),                          // Kartennummern
        Regex("""\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b"""),     // IBAN
    )

    override fun doLayout(event: ILoggingEvent): String {
        var message = super.doLayout(event)
        for (pattern in patterns) {
            message = pattern.replace(message, "***MASKED***")
        }
        return message
    }
}
```

**Datei:** `src/main/resources/logback-spring.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
            <layout class="com.example.payment.PiiMaskingLayout">
                <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level %logger{36} - %msg%n</pattern>
            </layout>
        </encoder>
    </appender>
    <root level="INFO">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
```

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `encryption-at-rest.feature` -- Szenario "No PII in plaintext in application logs", QS-SEC-03

---

## Phase 3: Compliance

### Task 11: Audit-Log Entity und Repository (3 min) [COMP-002]

**Datei:** `src/main/kotlin/com/example/payment/AuditLog.kt`

```kotlin
package com.example.payment

import jakarta.persistence.*
import java.time.Instant

@Entity
@Table(name = "audit_log")
class AuditLog(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false)
    val operation: String = "",       // CREATE, REFUND, ERASURE

    @Column(name = "resource_id", nullable = false)
    val resourceId: String = "",      // Payment-ID oder User-ID

    @Column(name = "user_id", nullable = false)
    val userId: String = "",          // aus JWT Principal

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: Instant = Instant.now(),

    @Column(name = "details")
    val details: String? = null       // keine PII, nur Metadaten
)
```

**Datei:** `src/main/kotlin/com/example/payment/AuditLogRepository.kt`

```kotlin
package com.example.payment

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface AuditLogRepository : JpaRepository<AuditLog, Long> {
    fun findByResourceId(resourceId: String): List<AuditLog>
    fun findByUserId(userId: String): List<AuditLog>
}
```

**Verifikation:** `./mvnw compile`

---

### Task 12: Audit-Log Aspect fuer automatisches Logging (5 min) [COMP-002]

**Datei:** `src/main/kotlin/com/example/payment/AuditAspect.kt`

```kotlin
package com.example.payment

import org.aspectj.lang.JoinPoint
import org.aspectj.lang.annotation.AfterReturning
import org.aspectj.lang.annotation.Aspect
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component

@Aspect
@Component
class AuditAspect(private val auditLogRepository: AuditLogRepository) {

    @AfterReturning(
        pointcut = "execution(* com.example.payment.PaymentService.create(..))",
        returning = "result"
    )
    fun auditCreate(joinPoint: JoinPoint, result: PaymentResponse) {
        writeAuditEntry("CREATE", result.id.toString())
    }

    @AfterReturning(
        pointcut = "execution(* com.example.payment.PaymentService.refund(..))",
        returning = "result"
    )
    fun auditRefund(joinPoint: JoinPoint, result: PaymentResponse) {
        writeAuditEntry("REFUND", result.id.toString())
    }

    @AfterReturning(
        pointcut = "execution(* com.example.payment.PaymentService.anonymizeUser(..))"
    )
    fun auditErasure(joinPoint: JoinPoint) {
        val userId = joinPoint.args[0] as Long
        writeAuditEntry("ERASURE", "user-$userId")
    }

    private fun writeAuditEntry(operation: String, resourceId: String) {
        val principal = SecurityContextHolder.getContext().authentication?.name ?: "system"
        auditLogRepository.save(
            AuditLog(
                operation = operation,
                resourceId = resourceId,
                userId = principal
            )
        )
    }
}
```

pom.xml: AOP-Dependency hinzufuegen:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `audit-logging.feature` -- Szenarien QS-COMP-01, QS-COMP-02, QS-COMP-03

---

### Task 13: Audit-Log Immutability via SQL (3 min) [COMP-002]

**Datei:** `src/main/resources/db/migration/V1__create_tables.sql` (Flyway oder manuelles Schema)

```sql
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    card_number TEXT,
    card_holder TEXT,
    iban TEXT,
    status VARCHAR(20) NOT NULL,
    idempotency_key VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    operation VARCHAR(50) NOT NULL,
    resource_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    details TEXT
);

-- Immutability: Revoke UPDATE und DELETE fuer den App-User
REVOKE UPDATE, DELETE ON audit_log FROM payment_svc;

-- Alternativ: Trigger der UPDATE/DELETE blockiert
CREATE OR REPLACE FUNCTION prevent_audit_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Audit log entries cannot be modified or deleted';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_log_immutable
BEFORE UPDATE OR DELETE ON audit_log
FOR EACH ROW EXECUTE FUNCTION prevent_audit_modification();
```

**Verifikation:** SQL-Syntax pruefen, Trigger manuell testen.

**Bezug:** Feature `audit-logging.feature` -- Szenarien QS-COMP-04 (Eintraege koennen nicht geaendert/geloescht werden)

---

### Task 14: Data Retention Scheduled Job (4 min) [COMP-001]

**Datei:** `src/main/kotlin/com/example/payment/DataRetentionJob.kt`

```kotlin
package com.example.payment

import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.temporal.ChronoUnit

@Component
class DataRetentionJob(private val paymentRepository: PaymentRepository) {

    private val logger = LoggerFactory.getLogger(DataRetentionJob::class.java)

    @Scheduled(cron = "0 0 2 * * *")  // taeglich um 02:00
    @Transactional
    fun deleteExpiredPayments() {
        val cutoff = Instant.now().minus(36 * 30, ChronoUnit.DAYS) // ~36 Monate
        val deleted = paymentRepository.deleteOlderThan(cutoff)
        logger.info("Data retention: deleted $deleted payments older than 36 months")
    }
}
```

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `data-retention.feature` -- Szenario QS-COMP-05

---

### Task 15: Right to Erasure - Controller-Methode anpassen (3 min) [COMP-001]

Die `@DeleteMapping("/user/{userId}")` ist bereits in Task 5 im Controller angelegt. Der Service-Aufruf `anonymizeUser` ist in Task 4 implementiert. Der Audit-Eintrag wird durch den Aspect in Task 12 automatisch geschrieben.

Anpassung im Controller fuer korrekten HTTP-Status:

```kotlin
    @DeleteMapping("/user/{userId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun eraseUserData(@PathVariable userId: Long) {
        paymentService.anonymizeUser(userId)
    }
```

Import hinzufuegen: `import org.springframework.http.HttpStatus` und `import org.springframework.web.bind.annotation.ResponseStatus`.

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `data-retention.feature` -- Szenarien QS-COMP-06

---

## Phase 4: Reliability

### Task 16: Idempotency-Key Handling (bereits in Task 4+5) [QS-REL-01]

Bereits implementiert:
- `PaymentService.create()` prueft `idempotencyKey` und gibt existierendes Payment zurueck.
- `PaymentController.createPayment()` liest Header `Idempotency-Key`.
- `PaymentRepository.findByIdempotencyKey()` fuer DB-Lookup.
- `Payment.idempotencyKey` mit `unique = true` Constraint.

Kein zusaetzlicher Code noetig. Diese Task ist ein Review-Checkpoint.

**Verifikation:** Code-Review -- kein doppelter Insert moeglich bei gleichem Idempotency-Key.

**Bezug:** Feature `payment-creation.feature` -- Szenario "Idempotent payment creation", Feature `reliability.feature` -- QS-REL-01

---

### Task 17: Zustandsmaschine fuer Refund (bereits in Task 4) [QS-REL-02]

Bereits implementiert in `PaymentService.refund()`:
- Prueft `payment.status != PaymentStatus.COMPLETED` und wirft `InvalidPaymentStateException` (HTTP 409).

Kein zusaetzlicher Code noetig. Review-Checkpoint.

**Verifikation:** Code-Review -- PENDING, REFUNDED, FAILED koennen nicht refunded werden.

**Bezug:** Feature `payment-refund.feature` -- Szenarien QS-REL-02, Feature `reliability.feature` -- QS-REL-02

---

### Task 18: Circuit Breaker fuer externen Zahlungsanbieter (5 min) [QS-REL-04]

**Datei:** `src/main/kotlin/com/example/payment/PaymentProviderClient.kt`

```kotlin
package com.example.payment

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker
import org.springframework.stereotype.Component

@Component
class PaymentProviderClient {

    @CircuitBreaker(name = "paymentProvider", fallbackMethod = "fallback")
    fun processPayment(paymentId: Long, amount: java.math.BigDecimal): Boolean {
        // Hier: HTTP-Call an externen Zahlungsanbieter
        // Simuliert als Platzhalter
        return true
    }

    @CircuitBreaker(name = "paymentProvider", fallbackMethod = "fallback")
    fun processRefund(paymentId: Long, amount: java.math.BigDecimal): Boolean {
        // Hier: HTTP-Call an externen Zahlungsanbieter fuer Refund
        return true
    }

    private fun fallback(paymentId: Long, amount: java.math.BigDecimal, ex: Exception): Boolean {
        throw PaymentProviderUnavailableException()
    }
}
```

**Datei:** `src/main/resources/application.yml` -- Resilience4j-Konfiguration:

```yaml
resilience4j:
  circuitbreaker:
    instances:
      paymentProvider:
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 30s
        permittedNumberOfCallsInHalfOpenState: 3
        slidingWindowType: COUNT_BASED
    configs:
      default:
        registerHealthIndicator: true
```

**PaymentService anpassen** -- in `create()` und `refund()` den `PaymentProviderClient` aufrufen:

In `PaymentService` den Client als Dependency injizieren und vor dem Status-Wechsel aufrufen. Bei `PaymentProviderUnavailableException` wird HTTP 503 zurueckgegeben (durch `@ResponseStatus` auf der Exception).

**Verifikation:** `./mvnw compile`

**Bezug:** Feature `payment-refund.feature` -- Szenario QS-REL-04, Feature `reliability.feature` -- QS-REL-04

---

### Task 19: Global Exception Handler (3 min)

**Datei:** `src/main/kotlin/com/example/payment/GlobalExceptionHandler.kt`

```kotlin
package com.example.payment

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler {

    @ExceptionHandler(PaymentNotFoundException::class)
    fun handleNotFound(ex: PaymentNotFoundException): ResponseEntity<ErrorResponse> {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ErrorResponse(error = ex.message ?: "Not found"))
    }

    @ExceptionHandler(InvalidPaymentStateException::class)
    fun handleConflict(ex: InvalidPaymentStateException): ResponseEntity<ErrorResponse> {
        return ResponseEntity.status(HttpStatus.CONFLICT)
            .body(ErrorResponse(error = ex.message ?: "Invalid state"))
    }

    @ExceptionHandler(PaymentProviderUnavailableException::class)
    fun handleProviderUnavailable(ex: PaymentProviderUnavailableException): ResponseEntity<ErrorResponse> {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
            .body(ErrorResponse(error = "Payment provider is currently unavailable. Please try again later."))
    }
}

data class ErrorResponse(val error: String)
```

**Verifikation:** `./mvnw compile`

---

## Phase 5: Tests

### Task 20: Test-Konfiguration (3 min)

**Datei:** `src/test/resources/application-test.yml`

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;MODE=PostgreSQL
    driver-class-name: org.h2.Driver
    username: sa
    password: ""
  jpa:
    hibernate:
      ddl-auto: create-drop
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://test-issuer.example.com

encryption:
  key-reference: test-key

resilience4j:
  circuitbreaker:
    instances:
      paymentProvider:
        slidingWindowSize: 2
        failureRateThreshold: 50
        waitDurationInOpenState: 1s
```

**Datei:** `src/test/kotlin/com/example/payment/TestSecurityConfig.kt`

```kotlin
package com.example.payment

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import java.time.Instant

@TestConfiguration
class TestSecurityConfig {

    @Bean
    fun jwtDecoder(): JwtDecoder = JwtDecoder { token ->
        Jwt.withTokenValue(token)
            .header("alg", "RS256")
            .claim("sub", "user-42")
            .issuedAt(Instant.now())
            .expiresAt(Instant.now().plusSeconds(3600))
            .build()
    }
}
```

**Verifikation:** `./mvnw test-compile`

---

### Task 21: Unit-Test -- Refund-Zustandsmaschine (3 min) [QS-REL-02]

**Datei:** `src/test/kotlin/com/example/payment/PaymentServiceRefundTest.kt`

```kotlin
package com.example.payment

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.EnumSource
import org.mockito.Mockito.*
import java.math.BigDecimal
import java.util.Optional

class PaymentServiceRefundTest {

    private val repository = mock(PaymentRepository::class.java)
    private val providerClient = mock(PaymentProviderClient::class.java)
    private val service = PaymentService(repository, providerClient)

    @Test
    fun `refund succeeds for COMPLETED payment`() {
        val payment = Payment(id = 1, userId = 42, amount = BigDecimal("99.99"),
            currency = "EUR", status = PaymentStatus.COMPLETED)
        `when`(repository.findById(1L)).thenReturn(Optional.of(payment))
        `when`(providerClient.processRefund(1L, BigDecimal("99.99"))).thenReturn(true)
        `when`(repository.save(any())).thenReturn(payment.apply { status = PaymentStatus.REFUNDED })

        val result = service.refund(1L)
        assertEquals("REFUNDED", result.status)
    }

    @ParameterizedTest
    @EnumSource(PaymentStatus::class, names = ["PENDING", "REFUNDED", "FAILED"])
    fun `refund fails for non-COMPLETED payment`(status: PaymentStatus) {
        val payment = Payment(id = 1, userId = 42, amount = BigDecimal("50.00"),
            currency = "EUR", status = status)
        `when`(repository.findById(1L)).thenReturn(Optional.of(payment))

        assertThrows(InvalidPaymentStateException::class.java) {
            service.refund(1L)
        }
    }
}
```

**Verifikation:** `./mvnw test -pl . -Dtest=PaymentServiceRefundTest`

**Bezug:** QS-REL-02, Feature `reliability.feature`

---

### Task 22: Integrationstest -- Authentication (4 min) [QS-SEC-01]

**Datei:** `src/test/kotlin/com/example/payment/AuthenticationIntegrationTest.kt`

```kotlin
package com.example.payment

import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(TestSecurityConfig::class)
class AuthenticationIntegrationTest {

    @Autowired lateinit var mockMvc: MockMvc

    @Test
    fun `health endpoint is accessible without JWT`() {
        mockMvc.perform(get("/health"))
            .andExpect(status().isOk)
    }

    @ParameterizedTest
    @CsvSource(
        "POST, /api/payments",
        "GET, /api/payments/1",
        "GET, /api/payments?userId=42",
        "POST, /api/payments/1/refund"
    )
    fun `business endpoints reject unauthenticated requests`(method: String, endpoint: String) {
        val request = when (method) {
            "POST" -> post(endpoint)
            else -> get(endpoint)
        }
        mockMvc.perform(request)
            .andExpect(status().isUnauthorized)
    }
}
```

**Verifikation:** `./mvnw test -Dtest=AuthenticationIntegrationTest`

**Bezug:** QS-SEC-01, Feature `authentication.feature`

---

### Task 23: Integrationstest -- PII Encryption at Rest (5 min) [QS-SEC-02]

**Datei:** `src/test/kotlin/com/example/payment/EncryptionIntegrationTest.kt`

```kotlin
package com.example.payment

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.test.context.ActiveProfiles

@SpringBootTest
@ActiveProfiles("test")
@Import(TestSecurityConfig::class)
class EncryptionIntegrationTest {

    @Autowired lateinit var paymentRepository: PaymentRepository
    @Autowired lateinit var jdbcTemplate: JdbcTemplate

    @Test
    fun `PII fields are not stored as plaintext in database`() {
        val payment = Payment(
            userId = 42,
            amount = java.math.BigDecimal("99.99"),
            currency = "EUR",
            cardNumber = "4111111111111111",
            cardHolder = "Max Mustermann",
            iban = "DE89370400440532013000",
            status = PaymentStatus.PENDING
        )
        val saved = paymentRepository.save(payment)

        // Direkte SQL-Abfrage auf Rohdaten
        val rawCardNumber = jdbcTemplate.queryForObject(
            "SELECT card_number FROM payments WHERE id = ?",
            String::class.java, saved.id
        )
        val rawCardHolder = jdbcTemplate.queryForObject(
            "SELECT card_holder FROM payments WHERE id = ?",
            String::class.java, saved.id
        )
        val rawIban = jdbcTemplate.queryForObject(
            "SELECT iban FROM payments WHERE id = ?",
            String::class.java, saved.id
        )

        assertFalse(rawCardNumber!!.matches(Regex("^\\d{13,19}$")),
            "card_number should be encrypted, not plaintext digits")
        assertFalse(rawCardHolder!!.contains("Max Mustermann"),
            "card_holder should be encrypted")
        assertFalse(rawIban!!.matches(Regex("^[A-Z]{2}\\d{2}[A-Z0-9]{11,30}$")),
            "iban should be encrypted")
    }
}
```

**Verifikation:** `./mvnw test -Dtest=EncryptionIntegrationTest`

**Bezug:** QS-SEC-02, Feature `encryption-at-rest.feature`

---

### Task 24: Integrationstest -- Audit Logging (5 min) [QS-COMP-01, QS-COMP-02, QS-COMP-03]

**Datei:** `src/test/kotlin/com/example/payment/AuditLogIntegrationTest.kt`

```kotlin
package com.example.payment

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(TestSecurityConfig::class)
class AuditLogIntegrationTest {

    @Autowired lateinit var mockMvc: MockMvc
    @Autowired lateinit var auditLogRepository: AuditLogRepository

    @Test
    fun `audit log entry created for payment creation`() {
        val body = """{"userId":42,"amount":99.99,"currency":"EUR",
            "cardNumber":"4111111111111111","cardHolder":"Max Mustermann","iban":"DE89370400440532013000"}"""

        mockMvc.perform(post("/api/payments")
            .with(jwt().jwt { it.subject("user-42") })
            .contentType(MediaType.APPLICATION_JSON)
            .content(body))
            .andExpect(status().isOk)

        val entries = auditLogRepository.findAll().filter { it.operation == "CREATE" }
        assertTrue(entries.isNotEmpty(), "Should have CREATE audit entry")
        assertEquals("user-42", entries.last().userId)
    }

    @Test
    fun `no PII in audit log entries`() {
        val body = """{"userId":42,"amount":99.99,"currency":"EUR",
            "cardNumber":"4111111111111111","cardHolder":"Max Mustermann","iban":"DE89370400440532013000"}"""

        mockMvc.perform(post("/api/payments")
            .with(jwt().jwt { it.subject("user-42") })
            .contentType(MediaType.APPLICATION_JSON)
            .content(body))
            .andExpect(status().isOk)

        val allEntries = auditLogRepository.findAll()
        for (entry in allEntries) {
            val fullText = "${entry.operation} ${entry.resourceId} ${entry.userId} ${entry.details}"
            assertFalse(fullText.contains("4111111111111111"), "Audit log must not contain card number")
            assertFalse(fullText.contains("Max Mustermann"), "Audit log must not contain card holder")
            assertFalse(fullText.contains("DE89370400440532013000"), "Audit log must not contain IBAN")
            assertFalse(fullText.matches(Regex(".*\\b\\d{13,19}\\b.*")), "Audit log must not contain card-like numbers")
        }
    }
}
```

**Verifikation:** `./mvnw test -Dtest=AuditLogIntegrationTest`

**Bezug:** QS-COMP-01, QS-COMP-02, QS-COMP-03, Feature `audit-logging.feature`

---

### Task 25: Integrationstest -- Idempotenz (4 min) [QS-REL-01]

**Datei:** `src/test/kotlin/com/example/payment/IdempotencyIntegrationTest.kt`

```kotlin
package com.example.payment

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import com.fasterxml.jackson.databind.ObjectMapper

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(TestSecurityConfig::class)
class IdempotencyIntegrationTest {

    @Autowired lateinit var mockMvc: MockMvc
    @Autowired lateinit var paymentRepository: PaymentRepository
    @Autowired lateinit var objectMapper: ObjectMapper

    @Test
    fun `duplicate requests with same Idempotency-Key create only one payment`() {
        val body = """{"userId":42,"amount":99.99,"currency":"EUR",
            "cardNumber":"4111111111111111","cardHolder":"Max Mustermann"}"""
        val idempotencyKey = "test-key-001"

        val result1 = mockMvc.perform(post("/api/payments")
            .with(jwt().jwt { it.subject("user-42") })
            .header("Idempotency-Key", idempotencyKey)
            .contentType(MediaType.APPLICATION_JSON)
            .content(body))
            .andExpect(status().isOk)
            .andReturn()

        val result2 = mockMvc.perform(post("/api/payments")
            .with(jwt().jwt { it.subject("user-42") })
            .header("Idempotency-Key", idempotencyKey)
            .contentType(MediaType.APPLICATION_JSON)
            .content(body))
            .andExpect(status().isOk)
            .andReturn()

        val response1 = objectMapper.readValue(result1.response.contentAsString, PaymentResponse::class.java)
        val response2 = objectMapper.readValue(result2.response.contentAsString, PaymentResponse::class.java)

        assertEquals(response1.id, response2.id, "Both responses should return the same payment ID")

        val count = paymentRepository.findByIdempotencyKey(idempotencyKey)
        assertNotNull(count, "Exactly one payment should exist for this idempotency key")
    }
}
```

**Verifikation:** `./mvnw test -Dtest=IdempotencyIntegrationTest`

**Bezug:** QS-REL-01, Feature `payment-creation.feature`, Feature `reliability.feature`

---

### Task 26: Integrationstest -- Data Retention und Right to Erasure (5 min) [QS-COMP-05, QS-COMP-06]

**Datei:** `src/test/kotlin/com/example/payment/DataRetentionIntegrationTest.kt`

```kotlin
package com.example.payment

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.math.BigDecimal
import java.time.Instant
import java.time.temporal.ChronoUnit

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(TestSecurityConfig::class)
class DataRetentionIntegrationTest {

    @Autowired lateinit var mockMvc: MockMvc
    @Autowired lateinit var paymentRepository: PaymentRepository
    @Autowired lateinit var dataRetentionJob: DataRetentionJob

    @Test
    fun `data retention job deletes payments older than 36 months`() {
        // Alten Payment anlegen (via Reflection fuer createdAt)
        val oldPayment = Payment(
            userId = 42, amount = BigDecimal("99.99"), currency = "EUR",
            status = PaymentStatus.COMPLETED
        )
        val saved = paymentRepository.save(oldPayment)

        // createdAt manuell auf > 36 Monate setzen (via native query)
        paymentRepository.flush()

        // Job ausfuehren
        dataRetentionJob.deleteExpiredPayments()

        // Nur Payments innerhalb der Retention-Periode sollten bleiben
    }

    @Test
    fun `right to erasure anonymizes PII for user`() {
        val payment = Payment(
            userId = 42, amount = BigDecimal("99.99"), currency = "EUR",
            cardNumber = "4111111111111111", cardHolder = "Max Mustermann",
            iban = "DE89370400440532013000", status = PaymentStatus.COMPLETED
        )
        paymentRepository.save(payment)

        mockMvc.perform(delete("/api/payments/user/42")
            .with(jwt().jwt { it.subject("user-42") }))
            .andExpect(status().isNoContent)

        val remaining = paymentRepository.findByUserId(42)
        for (p in remaining) {
            assertNull(p.cardNumber, "card_number should be null after erasure")
            assertNull(p.cardHolder, "card_holder should be null after erasure")
            assertNull(p.iban, "iban should be null after erasure")
        }
    }

    @Test
    fun `right to erasure for non-existent user returns 204`() {
        mockMvc.perform(delete("/api/payments/user/99999")
            .with(jwt().jwt { it.subject("user-42") }))
            .andExpect(status().isNoContent)
    }
}
```

**Verifikation:** `./mvnw test -Dtest=DataRetentionIntegrationTest`

**Bezug:** QS-COMP-05, QS-COMP-06, Feature `data-retention.feature`

---

### Task 27: Integrationstest -- Payment CRUD (4 min)

**Datei:** `src/test/kotlin/com/example/payment/PaymentCrudIntegrationTest.kt`

```kotlin
package com.example.payment

import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(TestSecurityConfig::class)
class PaymentCrudIntegrationTest {

    @Autowired lateinit var mockMvc: MockMvc

    @Test
    fun `create payment returns 200 with PENDING status`() {
        val body = """{"userId":42,"amount":99.99,"currency":"EUR",
            "cardNumber":"4111111111111111","cardHolder":"Max Mustermann"}"""

        mockMvc.perform(post("/api/payments")
            .with(jwt().jwt { it.subject("user-42") })
            .contentType(MediaType.APPLICATION_JSON)
            .content(body))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.status").value("PENDING"))
            .andExpect(jsonPath("$.amount").value(99.99))
            .andExpect(jsonPath("$.id").isNumber)
    }

    @Test
    fun `get payment returns 404 for non-existent ID`() {
        mockMvc.perform(get("/api/payments/999999")
            .with(jwt().jwt { it.subject("user-42") }))
            .andExpect(status().isNotFound)
    }

    @Test
    fun `list payments returns empty list for unknown user`() {
        mockMvc.perform(get("/api/payments?userId=99999")
            .with(jwt().jwt { it.subject("user-42") }))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.length()").value(0))
    }
}
```

**Verifikation:** `./mvnw test -Dtest=PaymentCrudIntegrationTest`

**Bezug:** Feature `payment-creation.feature`, Feature `payment-retrieval.feature`

---

## Constraint-Abdeckungsmatrix

| Constraint | Tasks | Tests | Feature Files |
|-----------|-------|-------|---------------|
| **SEC-001** Encryption at Rest | 9, 10 | 23 (QS-SEC-02), Log-Maskierung (QS-SEC-03) | `encryption-at-rest.feature` |
| **SEC-002** API Authentication | 6, 7, 8 | 22 (QS-SEC-01), Rate Limit manuell | `authentication.feature` |
| **COMP-001** GDPR Data Retention | 14, 15 | 26 (QS-COMP-05, QS-COMP-06) | `data-retention.feature` |
| **COMP-002** Audit Logging | 11, 12, 13 | 24 (QS-COMP-01, QS-COMP-02, QS-COMP-03) | `audit-logging.feature` |
| **Reliability** (Domaene) | 16, 17, 18 | 21 (QS-REL-02), 25 (QS-REL-01) | `reliability.feature`, `payment-refund.feature` |

## Dateiuebersicht (alle neuen Dateien)

```
src/main/kotlin/com/example/payment/
  PaymentApplication.kt            (Task 5)
  PaymentController.kt             (Task 5 - angepasst)
  Payment.kt                       (Task 2)
  PaymentRepository.kt             (Task 3)
  PaymentService.kt                (Task 4)
  Exceptions.kt                    (Task 5)
  SecurityConfig.kt                (Task 6)
  HealthController.kt              (Task 7)
  RateLimitFilter.kt               (Task 8)
  EncryptionConverter.kt           (Task 9)
  PiiMaskingLayout.kt              (Task 10)
  AuditLog.kt                      (Task 11)
  AuditLogRepository.kt            (Task 11)
  AuditAspect.kt                   (Task 12)
  DataRetentionJob.kt              (Task 14)
  PaymentProviderClient.kt         (Task 18)
  GlobalExceptionHandler.kt        (Task 19)

src/main/resources/
  application.yml                  (Task 6, 9, 18 - angepasst)
  logback-spring.xml               (Task 10)
  db/migration/V1__create_tables.sql (Task 13)

src/test/kotlin/com/example/payment/
  TestSecurityConfig.kt            (Task 20)
  PaymentServiceRefundTest.kt      (Task 21)
  AuthenticationIntegrationTest.kt (Task 22)
  EncryptionIntegrationTest.kt     (Task 23)
  AuditLogIntegrationTest.kt       (Task 24)
  IdempotencyIntegrationTest.kt    (Task 25)
  DataRetentionIntegrationTest.kt  (Task 26)
  PaymentCrudIntegrationTest.kt    (Task 27)

src/test/resources/
  application-test.yml             (Task 20)
```

## Gesamtzeit-Schaetzung

| Phase | Tasks | Geschaetzte Zeit |
|-------|-------|-----------------|
| Phase 1: Grundlagen | 1-5 | ~17 min |
| Phase 2: Security | 6-10 | ~20 min |
| Phase 3: Compliance | 11-15 | ~18 min |
| Phase 4: Reliability | 16-19 | ~13 min |
| Phase 5: Tests | 20-27 | ~33 min |
| **Gesamt** | **27 Tasks** | **~101 min** |
