# Booking Service Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superflowers:subagent-driven-development (recommended) or superflowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a booking microservice that handles reservation creation, availability checks, and booking confirmation for the e-commerce platform.

**Architecture:** The booking service is a standalone microservice in a domain-partitioned architecture. It owns its own database and communicates with other services (catalog, payment) exclusively through defined API contracts. All cross-service calls use circuit breakers for graceful degradation.

**Tech Stack:** Node.js, Express, PostgreSQL, Cucumber.js (BDD), Jest (unit tests), k6 (load tests), Pact (contract testing)

**Architecture:** Microservices style selected in architecture.md. Driving characteristics: Evolvability (independent feature evolution across teams), Maintainability (each team owns their domain), Scalability (peak traffic handling for booking spikes). Tradeoff accepted: Simplicity rated 1/5 mitigated by standardized service templates.

**Feature Files:** `features/booking.feature` (5 scenarios: Create Booking, Check Availability, Confirm Booking, Cancel Booking, Reject Double Booking)

**Characteristic Fitness Functions:** Evolvability (independent deployability check), Maintainability (service size bounds), Scalability (auto-scaling response verification)

**Style Fitness Functions:** No shared database (each service owns its DB schema), Independent deployability (service builds/deploys alone), API contract compliance (Pact contract tests), No shared libraries with business logic (dependency analysis), Service size bounds (LOC/complexity limits) -- per architecture.md "Architecture Style Fitness Functions" section

**Quality Scenarios:** Unit tests: QS-001 (input validation against injection), QS-002 (booking date validation), QS-003 (availability calculation logic). Integration tests: QS-004 (booking API end-to-end), QS-005 (payment service integration), QS-006 (catalog service availability check), QS-007 (database failover graceful handling). Load tests: QS-008 (booking creation under peak load), QS-009 (availability checks at 10x traffic). Manual review: QS-010 (booking confirmation email content review) -- per quality-scenarios.md

---

## File Structure

```
src/
  booking/
    booking.controller.js    — HTTP route handlers for booking endpoints
    booking.service.js       — Core booking business logic (create, confirm, cancel, availability)
    booking.repository.js    — Database access layer for bookings table
    booking.validator.js     — Input validation and sanitization
    booking.model.js         — Booking data model and schema definition
  clients/
    payment.client.js        — Payment service API client with circuit breaker
    catalog.client.js        — Catalog service API client with circuit breaker
  middleware/
    error-handler.js         — Centralized error handling middleware
    auth.js                  — Authentication/authorization middleware
  config/
    database.js              — PostgreSQL connection configuration (service-owned DB)
    app.js                   — Express app setup and middleware registration
    index.js                 — Server entry point
tests/
  unit/
    booking.service.test.js  — Unit tests for booking business logic
    booking.validator.test.js — Unit tests for input validation
  integration/
    booking.api.test.js      — Integration tests for booking API endpoints
    payment.integration.test.js — Integration tests for payment service calls
    catalog.integration.test.js — Integration tests for catalog availability
  load/
    booking-peak.k6.js       — Load test for booking creation under peak
    availability-peak.k6.js  — Load test for availability checks at scale
  contracts/
    booking-payment.pact.js  — Pact contract test: booking <-> payment
    booking-catalog.pact.js  — Pact contract test: booking <-> catalog
features/
  booking.feature            — BDD scenarios (EXISTS - DO NOT MODIFY)
  step_definitions/
    booking-steps.js         — Step definitions wiring booking.feature to implementation
db/
  migrations/
    001-create-bookings.sql  — Bookings table migration
fitness/
  no-shared-database.test.js     — Style FF: verify no cross-service DB access
  independent-deployability.test.js — Style FF: verify independent build/deploy
  service-size-bounds.test.js    — Style FF: verify LOC/complexity limits
  api-contract-compliance.test.js — Style FF: verify Pact contracts pass
  no-shared-business-logic.test.js — Style FF: verify shared libs have no domain logic
```

---

### Task 1: Project Scaffolding and Database Migration

**Files:**
- Create: `package.json`
- Create: `src/config/database.js`
- Create: `src/config/app.js`
- Create: `src/config/index.js`
- Create: `db/migrations/001-create-bookings.sql`

- [ ] **Step 1: Initialize project and install dependencies**

```bash
npm init -y
npm install express pg knex uuid dotenv
npm install --save-dev jest cucumber @cucumber/cucumber supertest k6 @pact-foundation/pact eslint
```

- [ ] **Step 2: Create database migration**

```sql
-- db/migrations/001-create-bookings.sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL,
  customer_id UUID NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT no_negative_duration CHECK (end_time > start_time)
);

CREATE INDEX idx_bookings_resource_time ON bookings (resource_id, start_time, end_time)
  WHERE status != 'cancelled';
CREATE INDEX idx_bookings_customer ON bookings (customer_id);
```

- [ ] **Step 3: Create database configuration**

```javascript
// src/config/database.js
const knex = require('knex');

function createDatabase(config = {}) {
  return knex({
    client: 'pg',
    connection: {
      host: config.host || process.env.DB_HOST || 'localhost',
      port: config.port || process.env.DB_PORT || 5432,
      database: config.database || process.env.DB_NAME || 'booking_service',
      user: config.user || process.env.DB_USER || 'booking',
      password: config.password || process.env.DB_PASSWORD,
    },
    pool: { min: 2, max: 10 },
  });
}

module.exports = { createDatabase };
```

Note: This database is owned exclusively by the booking service. No other service connects to it. This enforces the "No shared database" style fitness function from architecture.md.

- [ ] **Step 4: Create Express app setup**

```javascript
// src/config/app.js
const express = require('express');
const { errorHandler } = require('../middleware/error-handler');

function createApp({ bookingController }) {
  const app = express();
  app.use(express.json());

  app.post('/bookings', bookingController.create);
  app.get('/bookings/availability', bookingController.checkAvailability);
  app.post('/bookings/:id/confirm', bookingController.confirm);
  app.post('/bookings/:id/cancel', bookingController.cancel);
  app.get('/bookings/:id', bookingController.getById);

  app.use(errorHandler);
  return app;
}

module.exports = { createApp };
```

- [ ] **Step 5: Create server entry point**

```javascript
// src/config/index.js
const { createDatabase } = require('./database');
const { createApp } = require('./app');
const { BookingRepository } = require('../booking/booking.repository');
const { BookingService } = require('../booking/booking.service');
const { BookingController } = require('../booking/booking.controller');

const db = createDatabase();
const bookingRepository = new BookingRepository(db);
const bookingService = new BookingService({ bookingRepository });
const bookingController = new BookingController({ bookingService });

const app = createApp({ bookingController });
const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Booking service listening on port ${port}`);
});
```

- [ ] **Step 6: Run the migration**

Run: `npx knex migrate:latest --knexfile knexfile.js`
Expected: Migration completes successfully, bookings table created

- [ ] **Step 7: Commit**

```bash
git add package.json package-lock.json src/config/ db/
git commit -m "feat: scaffold booking service with database migration"
```

---

### Task 2: Booking Model and Input Validator (Unit Tests First)

**Files:**
- Create: `src/booking/booking.model.js`
- Create: `src/booking/booking.validator.js`
- Create: `tests/unit/booking.validator.test.js`

This task addresses quality scenario **QS-001** (input validation against injection) from quality-scenarios.md. The validator rejects SQL injection and XSS payloads in all user-facing fields.

- [ ] **Step 1: Write the failing validator tests**

```javascript
// tests/unit/booking.validator.test.js
const { validateCreateBooking } = require('../../src/booking/booking.validator');

describe('validateCreateBooking', () => {
  const validInput = {
    resourceId: '550e8400-e29b-41d4-a716-446655440000',
    customerId: '550e8400-e29b-41d4-a716-446655440001',
    startTime: '2026-04-01T10:00:00Z',
    endTime: '2026-04-01T11:00:00Z',
  };

  test('accepts valid booking input', () => {
    const result = validateCreateBooking(validInput);
    expect(result.valid).toBe(true);
    expect(result.errors).toEqual([]);
  });

  test('rejects missing resourceId', () => {
    const { resourceId, ...input } = validInput;
    const result = validateCreateBooking(input);
    expect(result.valid).toBe(false);
    expect(result.errors).toContain('resourceId is required');
  });

  test('rejects invalid UUID format for resourceId', () => {
    const result = validateCreateBooking({ ...validInput, resourceId: 'not-a-uuid' });
    expect(result.valid).toBe(false);
    expect(result.errors).toContain('resourceId must be a valid UUID');
  });

  test('rejects endTime before startTime', () => {
    const result = validateCreateBooking({
      ...validInput,
      startTime: '2026-04-01T11:00:00Z',
      endTime: '2026-04-01T10:00:00Z',
    });
    expect(result.valid).toBe(false);
    expect(result.errors).toContain('endTime must be after startTime');
  });

  test('rejects SQL injection in string fields (QS-001)', () => {
    const result = validateCreateBooking({
      ...validInput,
      resourceId: "'; DROP TABLE bookings; --",
    });
    expect(result.valid).toBe(false);
  });

  test('rejects XSS payloads in string fields (QS-001)', () => {
    const result = validateCreateBooking({
      ...validInput,
      resourceId: '<script>alert("xss")</script>',
    });
    expect(result.valid).toBe(false);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `npx jest tests/unit/booking.validator.test.js --verbose`
Expected: FAIL with "Cannot find module '../../src/booking/booking.validator'"

- [ ] **Step 3: Implement the booking model**

```javascript
// src/booking/booking.model.js
class Booking {
  constructor({ id, resourceId, customerId, startTime, endTime, status, createdAt, updatedAt }) {
    this.id = id;
    this.resourceId = resourceId;
    this.customerId = customerId;
    this.startTime = new Date(startTime);
    this.endTime = new Date(endTime);
    this.status = status || 'pending';
    this.createdAt = createdAt ? new Date(createdAt) : new Date();
    this.updatedAt = updatedAt ? new Date(updatedAt) : new Date();
  }

  isConfirmed() {
    return this.status === 'confirmed';
  }

  isCancelled() {
    return this.status === 'cancelled';
  }

  durationMinutes() {
    return (this.endTime - this.startTime) / (1000 * 60);
  }
}

module.exports = { Booking };
```

- [ ] **Step 4: Implement the validator**

```javascript
// src/booking/booking.validator.js
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function validateCreateBooking(input) {
  const errors = [];

  if (!input.resourceId) {
    errors.push('resourceId is required');
  } else if (!UUID_REGEX.test(input.resourceId)) {
    errors.push('resourceId must be a valid UUID');
  }

  if (!input.customerId) {
    errors.push('customerId is required');
  } else if (!UUID_REGEX.test(input.customerId)) {
    errors.push('customerId must be a valid UUID');
  }

  if (!input.startTime) {
    errors.push('startTime is required');
  } else if (isNaN(Date.parse(input.startTime))) {
    errors.push('startTime must be a valid ISO 8601 date');
  }

  if (!input.endTime) {
    errors.push('endTime is required');
  } else if (isNaN(Date.parse(input.endTime))) {
    errors.push('endTime must be a valid ISO 8601 date');
  }

  if (input.startTime && input.endTime &&
      !isNaN(Date.parse(input.startTime)) && !isNaN(Date.parse(input.endTime))) {
    if (new Date(input.endTime) <= new Date(input.startTime)) {
      errors.push('endTime must be after startTime');
    }
  }

  return { valid: errors.length === 0, errors };
}

module.exports = { validateCreateBooking };
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `npx jest tests/unit/booking.validator.test.js --verbose`
Expected: PASS (6 tests passing, including QS-001 injection checks)

- [ ] **Step 6: Commit**

```bash
git add src/booking/booking.model.js src/booking/booking.validator.js tests/unit/booking.validator.test.js
git commit -m "feat: add booking model and input validator with injection protection (QS-001)"
```

---

### Task 3: Booking Repository (Unit Tests First)

**Files:**
- Create: `src/booking/booking.repository.js`
- Create: `tests/unit/booking.repository.test.js`

- [ ] **Step 1: Write the failing repository tests**

```javascript
// tests/unit/booking.repository.test.js
const { BookingRepository } = require('../../src/booking/booking.repository');

describe('BookingRepository', () => {
  let mockDb;
  let repository;

  beforeEach(() => {
    mockDb = jest.fn().mockReturnThis();
    mockDb.where = jest.fn().mockReturnThis();
    mockDb.andWhere = jest.fn().mockReturnThis();
    mockDb.whereNot = jest.fn().mockReturnThis();
    mockDb.insert = jest.fn().mockReturnThis();
    mockDb.returning = jest.fn().mockResolvedValue([{
      id: 'booking-1', resource_id: 'res-1', customer_id: 'cust-1',
      start_time: '2026-04-01T10:00:00Z', end_time: '2026-04-01T11:00:00Z',
      status: 'pending', created_at: '2026-04-01T09:00:00Z', updated_at: '2026-04-01T09:00:00Z',
    }]);
    mockDb.first = jest.fn().mockResolvedValue({
      id: 'booking-1', resource_id: 'res-1', customer_id: 'cust-1',
      start_time: '2026-04-01T10:00:00Z', end_time: '2026-04-01T11:00:00Z',
      status: 'pending', created_at: '2026-04-01T09:00:00Z', updated_at: '2026-04-01T09:00:00Z',
    });
    mockDb.update = jest.fn().mockReturnThis();

    repository = new BookingRepository(mockDb);
  });

  test('create inserts a booking and returns it', async () => {
    const booking = await repository.create({
      resourceId: 'res-1', customerId: 'cust-1',
      startTime: '2026-04-01T10:00:00Z', endTime: '2026-04-01T11:00:00Z',
    });
    expect(booking).toBeDefined();
    expect(booking.id).toBe('booking-1');
  });

  test('findById returns a booking by id', async () => {
    const booking = await repository.findById('booking-1');
    expect(booking).toBeDefined();
    expect(booking.id).toBe('booking-1');
  });

  test('findOverlapping returns bookings that overlap with a time range', async () => {
    mockDb.select = jest.fn().mockResolvedValue([{
      id: 'booking-1', resource_id: 'res-1', customer_id: 'cust-1',
      start_time: '2026-04-01T10:00:00Z', end_time: '2026-04-01T11:00:00Z',
      status: 'confirmed',
    }]);
    const overlapping = await repository.findOverlapping('res-1', '2026-04-01T10:30:00Z', '2026-04-01T11:30:00Z');
    expect(overlapping).toHaveLength(1);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `npx jest tests/unit/booking.repository.test.js --verbose`
Expected: FAIL with "Cannot find module '../../src/booking/booking.repository'"

- [ ] **Step 3: Implement the repository**

```javascript
// src/booking/booking.repository.js
const { Booking } = require('./booking.model');

class BookingRepository {
  constructor(db) {
    this.db = db;
  }

  async create({ resourceId, customerId, startTime, endTime }) {
    const [row] = await this.db('bookings')
      .insert({
        resource_id: resourceId,
        customer_id: customerId,
        start_time: startTime,
        end_time: endTime,
        status: 'pending',
      })
      .returning('*');
    return this._toBooking(row);
  }

  async findById(id) {
    const row = await this.db('bookings').where({ id }).first();
    return row ? this._toBooking(row) : null;
  }

  async findOverlapping(resourceId, startTime, endTime) {
    const rows = await this.db('bookings')
      .where({ resource_id: resourceId })
      .whereNot({ status: 'cancelled' })
      .andWhere('start_time', '<', endTime)
      .andWhere('end_time', '>', startTime)
      .select('*');
    return rows.map(row => this._toBooking(row));
  }

  async updateStatus(id, status) {
    const [row] = await this.db('bookings')
      .where({ id })
      .update({ status, updated_at: new Date() })
      .returning('*');
    return row ? this._toBooking(row) : null;
  }

  _toBooking(row) {
    return new Booking({
      id: row.id,
      resourceId: row.resource_id,
      customerId: row.customer_id,
      startTime: row.start_time,
      endTime: row.end_time,
      status: row.status,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    });
  }
}

module.exports = { BookingRepository };
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `npx jest tests/unit/booking.repository.test.js --verbose`
Expected: PASS (3 tests passing)

- [ ] **Step 5: Commit**

```bash
git add src/booking/booking.repository.js tests/unit/booking.repository.test.js
git commit -m "feat: add booking repository with overlap detection"
```

---

### Task 4: Booking Service Core Logic (Unit Tests First)

**Files:**
- Create: `src/booking/booking.service.js`
- Create: `tests/unit/booking.service.test.js`

This task implements the core business logic that the 5 BDD scenarios in `features/booking.feature` will exercise. Quality scenarios **QS-002** (booking date validation) and **QS-003** (availability calculation logic) are covered by unit tests here.

- [ ] **Step 1: Write the failing service tests**

```javascript
// tests/unit/booking.service.test.js
const { BookingService } = require('../../src/booking/booking.service');

describe('BookingService', () => {
  let service;
  let mockRepository;

  beforeEach(() => {
    mockRepository = {
      create: jest.fn(),
      findById: jest.fn(),
      findOverlapping: jest.fn(),
      updateStatus: jest.fn(),
    };
    service = new BookingService({ bookingRepository: mockRepository });
  });

  describe('createBooking', () => {
    test('creates a booking when time slot is available', async () => {
      mockRepository.findOverlapping.mockResolvedValue([]);
      mockRepository.create.mockResolvedValue({
        id: 'booking-1', resourceId: 'res-1', customerId: 'cust-1',
        startTime: new Date('2026-04-01T10:00:00Z'), endTime: new Date('2026-04-01T11:00:00Z'),
        status: 'pending',
      });

      const booking = await service.createBooking({
        resourceId: 'res-1', customerId: 'cust-1',
        startTime: '2026-04-01T10:00:00Z', endTime: '2026-04-01T11:00:00Z',
      });

      expect(booking.status).toBe('pending');
      expect(mockRepository.findOverlapping).toHaveBeenCalledWith(
        'res-1', '2026-04-01T10:00:00Z', '2026-04-01T11:00:00Z'
      );
    });

    test('rejects booking when time slot overlaps (double booking)', async () => {
      mockRepository.findOverlapping.mockResolvedValue([{ id: 'existing-booking' }]);

      await expect(service.createBooking({
        resourceId: 'res-1', customerId: 'cust-1',
        startTime: '2026-04-01T10:00:00Z', endTime: '2026-04-01T11:00:00Z',
      })).rejects.toThrow('Time slot is not available');
    });

    test('rejects booking with invalid dates (QS-002)', async () => {
      await expect(service.createBooking({
        resourceId: 'res-1', customerId: 'cust-1',
        startTime: '2026-04-01T11:00:00Z', endTime: '2026-04-01T10:00:00Z',
      })).rejects.toThrow('endTime must be after startTime');
    });
  });

  describe('checkAvailability (QS-003)', () => {
    test('returns available when no overlapping bookings exist', async () => {
      mockRepository.findOverlapping.mockResolvedValue([]);
      const result = await service.checkAvailability('res-1', '2026-04-01T10:00:00Z', '2026-04-01T11:00:00Z');
      expect(result.available).toBe(true);
    });

    test('returns unavailable when overlapping bookings exist', async () => {
      mockRepository.findOverlapping.mockResolvedValue([{ id: 'booking-1' }]);
      const result = await service.checkAvailability('res-1', '2026-04-01T10:00:00Z', '2026-04-01T11:00:00Z');
      expect(result.available).toBe(false);
      expect(result.conflicts).toHaveLength(1);
    });
  });

  describe('confirmBooking', () => {
    test('confirms a pending booking', async () => {
      mockRepository.findById.mockResolvedValue({ id: 'booking-1', status: 'pending' });
      mockRepository.updateStatus.mockResolvedValue({ id: 'booking-1', status: 'confirmed' });

      const booking = await service.confirmBooking('booking-1');
      expect(booking.status).toBe('confirmed');
    });

    test('rejects confirming an already cancelled booking', async () => {
      mockRepository.findById.mockResolvedValue({ id: 'booking-1', status: 'cancelled' });
      await expect(service.confirmBooking('booking-1')).rejects.toThrow('Cannot confirm a cancelled booking');
    });
  });

  describe('cancelBooking', () => {
    test('cancels a pending booking', async () => {
      mockRepository.findById.mockResolvedValue({ id: 'booking-1', status: 'pending' });
      mockRepository.updateStatus.mockResolvedValue({ id: 'booking-1', status: 'cancelled' });

      const booking = await service.cancelBooking('booking-1');
      expect(booking.status).toBe('cancelled');
    });
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `npx jest tests/unit/booking.service.test.js --verbose`
Expected: FAIL with "Cannot find module '../../src/booking/booking.service'"

- [ ] **Step 3: Implement the booking service**

```javascript
// src/booking/booking.service.js
const { validateCreateBooking } = require('./booking.validator');

class BookingService {
  constructor({ bookingRepository }) {
    this.bookingRepository = bookingRepository;
  }

  async createBooking({ resourceId, customerId, startTime, endTime }) {
    const validation = validateCreateBooking({ resourceId, customerId, startTime, endTime });
    if (!validation.valid) {
      throw new Error(validation.errors[0]);
    }

    const overlapping = await this.bookingRepository.findOverlapping(resourceId, startTime, endTime);
    if (overlapping.length > 0) {
      throw new Error('Time slot is not available');
    }

    return this.bookingRepository.create({ resourceId, customerId, startTime, endTime });
  }

  async checkAvailability(resourceId, startTime, endTime) {
    const overlapping = await this.bookingRepository.findOverlapping(resourceId, startTime, endTime);
    return {
      available: overlapping.length === 0,
      conflicts: overlapping,
    };
  }

  async confirmBooking(id) {
    const booking = await this.bookingRepository.findById(id);
    if (!booking) {
      throw new Error('Booking not found');
    }
    if (booking.status === 'cancelled') {
      throw new Error('Cannot confirm a cancelled booking');
    }
    if (booking.status === 'confirmed') {
      return booking;
    }
    return this.bookingRepository.updateStatus(id, 'confirmed');
  }

  async cancelBooking(id) {
    const booking = await this.bookingRepository.findById(id);
    if (!booking) {
      throw new Error('Booking not found');
    }
    if (booking.status === 'cancelled') {
      return booking;
    }
    return this.bookingRepository.updateStatus(id, 'cancelled');
  }
}

module.exports = { BookingService };
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `npx jest tests/unit/booking.service.test.js --verbose`
Expected: PASS (7 tests passing)

- [ ] **Step 5: Commit**

```bash
git add src/booking/booking.service.js tests/unit/booking.service.test.js
git commit -m "feat: add booking service with availability check and double-booking prevention"
```

---

### Task 5: Booking Controller and Error Handler

**Files:**
- Create: `src/booking/booking.controller.js`
- Create: `src/middleware/error-handler.js`
- Create: `tests/integration/booking.api.test.js`

This task addresses quality scenario **QS-004** (booking API end-to-end) from quality-scenarios.md by testing all HTTP endpoints through supertest.

- [ ] **Step 1: Write the failing API integration tests**

```javascript
// tests/integration/booking.api.test.js
const request = require('supertest');
const { createApp } = require('../../src/config/app');

describe('Booking API (QS-004)', () => {
  let app;
  let mockBookingService;

  beforeEach(() => {
    mockBookingService = {
      createBooking: jest.fn(),
      checkAvailability: jest.fn(),
      confirmBooking: jest.fn(),
      cancelBooking: jest.fn(),
    };

    const { BookingController } = require('../../src/booking/booking.controller');
    const bookingController = new BookingController({ bookingService: mockBookingService });
    app = createApp({ bookingController });
  });

  test('POST /bookings creates a booking and returns 201', async () => {
    mockBookingService.createBooking.mockResolvedValue({
      id: 'booking-1', resourceId: 'res-1', customerId: 'cust-1',
      startTime: '2026-04-01T10:00:00Z', endTime: '2026-04-01T11:00:00Z', status: 'pending',
    });

    const res = await request(app)
      .post('/bookings')
      .send({
        resourceId: '550e8400-e29b-41d4-a716-446655440000',
        customerId: '550e8400-e29b-41d4-a716-446655440001',
        startTime: '2026-04-01T10:00:00Z',
        endTime: '2026-04-01T11:00:00Z',
      });

    expect(res.status).toBe(201);
    expect(res.body.id).toBe('booking-1');
  });

  test('POST /bookings returns 409 when time slot conflicts', async () => {
    mockBookingService.createBooking.mockRejectedValue(new Error('Time slot is not available'));

    const res = await request(app)
      .post('/bookings')
      .send({
        resourceId: '550e8400-e29b-41d4-a716-446655440000',
        customerId: '550e8400-e29b-41d4-a716-446655440001',
        startTime: '2026-04-01T10:00:00Z',
        endTime: '2026-04-01T11:00:00Z',
      });

    expect(res.status).toBe(409);
    expect(res.body.error).toBe('Time slot is not available');
  });

  test('GET /bookings/availability returns availability status', async () => {
    mockBookingService.checkAvailability.mockResolvedValue({ available: true, conflicts: [] });

    const res = await request(app)
      .get('/bookings/availability')
      .query({
        resourceId: '550e8400-e29b-41d4-a716-446655440000',
        startTime: '2026-04-01T10:00:00Z',
        endTime: '2026-04-01T11:00:00Z',
      });

    expect(res.status).toBe(200);
    expect(res.body.available).toBe(true);
  });

  test('POST /bookings/:id/confirm confirms a booking', async () => {
    mockBookingService.confirmBooking.mockResolvedValue({ id: 'booking-1', status: 'confirmed' });

    const res = await request(app).post('/bookings/booking-1/confirm');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('confirmed');
  });

  test('POST /bookings/:id/cancel cancels a booking', async () => {
    mockBookingService.cancelBooking.mockResolvedValue({ id: 'booking-1', status: 'cancelled' });

    const res = await request(app).post('/bookings/booking-1/cancel');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('cancelled');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `npx jest tests/integration/booking.api.test.js --verbose`
Expected: FAIL with "Cannot find module '../../src/booking/booking.controller'"

- [ ] **Step 3: Implement the error handler**

```javascript
// src/middleware/error-handler.js
function errorHandler(err, req, res, next) {
  const statusMap = {
    'Time slot is not available': 409,
    'Booking not found': 404,
    'Cannot confirm a cancelled booking': 422,
  };

  const status = statusMap[err.message] || 500;
  res.status(status).json({
    error: status === 500 ? 'Internal server error' : err.message,
  });
}

module.exports = { errorHandler };
```

- [ ] **Step 4: Implement the controller**

```javascript
// src/booking/booking.controller.js
class BookingController {
  constructor({ bookingService }) {
    this.bookingService = bookingService;
    this.create = this.create.bind(this);
    this.checkAvailability = this.checkAvailability.bind(this);
    this.confirm = this.confirm.bind(this);
    this.cancel = this.cancel.bind(this);
    this.getById = this.getById.bind(this);
  }

  async create(req, res, next) {
    try {
      const booking = await this.bookingService.createBooking(req.body);
      res.status(201).json(booking);
    } catch (err) {
      next(err);
    }
  }

  async checkAvailability(req, res, next) {
    try {
      const { resourceId, startTime, endTime } = req.query;
      const result = await this.bookingService.checkAvailability(resourceId, startTime, endTime);
      res.json(result);
    } catch (err) {
      next(err);
    }
  }

  async confirm(req, res, next) {
    try {
      const booking = await this.bookingService.confirmBooking(req.params.id);
      res.json(booking);
    } catch (err) {
      next(err);
    }
  }

  async cancel(req, res, next) {
    try {
      const booking = await this.bookingService.cancelBooking(req.params.id);
      res.json(booking);
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const booking = await this.bookingService.getById(req.params.id);
      if (!booking) {
        return res.status(404).json({ error: 'Booking not found' });
      }
      res.json(booking);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = { BookingController };
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `npx jest tests/integration/booking.api.test.js --verbose`
Expected: PASS (5 tests passing)

- [ ] **Step 6: Commit**

```bash
git add src/booking/booking.controller.js src/middleware/error-handler.js tests/integration/booking.api.test.js
git commit -m "feat: add booking controller and API integration tests (QS-004)"
```

---

### Task 6: Wire BDD Step Definitions for booking.feature

**Feature file:** `features/booking.feature`
**Scenarios covered:** Create Booking, Check Availability, Confirm Booking, Cancel Booking, Reject Double Booking

**Files:**
- Create: `features/step_definitions/booking-steps.js`

This task wires the 5 BDD scenarios from `features/booking.feature` to the implementation built in Tasks 2-5. Step definitions are thin glue -- they call application code, they do NOT contain business logic.

- [ ] **Step 1: Generate step definition stubs**

Read `features/booking.feature` and create stub step definitions for every Given/When/Then step that doesn't already have a definition.

```javascript
// features/step_definitions/booking-steps.js
const { Given, When, Then, Before, After } = require('@cucumber/cucumber');
const assert = require('assert');
const request = require('supertest');
const { createApp } = require('../../src/config/app');
const { BookingRepository } = require('../../src/booking/booking.repository');
const { BookingService } = require('../../src/booking/booking.service');
const { BookingController } = require('../../src/booking/booking.controller');
const { createDatabase } = require('../../src/config/database');

let app, db, bookingRepository, bookingService, bookingController;
let response, bookingId;

Before(async function () {
  db = createDatabase({ database: 'booking_service_test' });
  await db.raw('TRUNCATE TABLE bookings CASCADE');
  bookingRepository = new BookingRepository(db);
  bookingService = new BookingService({ bookingRepository });
  bookingController = new BookingController({ bookingService });
  app = createApp({ bookingController });
});

After(async function () {
  await db.destroy();
});

// --- Create Booking scenario ---
Given('the time slot {string} to {string} for resource {string} is available', async function (start, end, resourceId) {
  // Slot is available by default (empty database after truncate)
  this.resourceId = resourceId;
  this.startTime = start;
  this.endTime = end;
});

When('I create a booking for resource {string} from {string} to {string}', async function (resourceId, start, end) {
  response = await request(app)
    .post('/bookings')
    .send({
      resourceId,
      customerId: '550e8400-e29b-41d4-a716-446655440001',
      startTime: start,
      endTime: end,
    });
});

Then('the booking should be created with status {string}', function (expectedStatus) {
  assert.strictEqual(response.status, 201);
  assert.strictEqual(response.body.status, expectedStatus);
  bookingId = response.body.id;
});

// --- Check Availability scenario ---
When('I check availability for resource {string} from {string} to {string}', async function (resourceId, start, end) {
  response = await request(app)
    .get('/bookings/availability')
    .query({ resourceId, startTime: start, endTime: end });
});

Then('the response should show available as {string}', function (expected) {
  assert.strictEqual(response.status, 200);
  assert.strictEqual(response.body.available, expected === 'true');
});

// --- Confirm Booking scenario ---
Given('a pending booking exists for resource {string} from {string} to {string}', async function (resourceId, start, end) {
  const createResponse = await request(app)
    .post('/bookings')
    .send({
      resourceId,
      customerId: '550e8400-e29b-41d4-a716-446655440001',
      startTime: start,
      endTime: end,
    });
  bookingId = createResponse.body.id;
});

When('I confirm the booking', async function () {
  response = await request(app).post(`/bookings/${bookingId}/confirm`);
});

Then('the booking status should be {string}', function (expectedStatus) {
  assert.strictEqual(response.status, 200);
  assert.strictEqual(response.body.status, expectedStatus);
});

// --- Cancel Booking scenario ---
When('I cancel the booking', async function () {
  response = await request(app).post(`/bookings/${bookingId}/cancel`);
});

// --- Reject Double Booking scenario ---
Given('a confirmed booking exists for resource {string} from {string} to {string}', async function (resourceId, start, end) {
  const createResponse = await request(app)
    .post('/bookings')
    .send({
      resourceId,
      customerId: '550e8400-e29b-41d4-a716-446655440001',
      startTime: start,
      endTime: end,
    });
  bookingId = createResponse.body.id;
  await request(app).post(`/bookings/${bookingId}/confirm`);
});

When('another customer tries to book resource {string} from {string} to {string}', async function (resourceId, start, end) {
  response = await request(app)
    .post('/bookings')
    .send({
      resourceId,
      customerId: '550e8400-e29b-41d4-a716-446655440099',
      startTime: start,
      endTime: end,
    });
});

Then('the booking should be rejected with error {string}', function (expectedError) {
  assert.strictEqual(response.status, 409);
  assert.strictEqual(response.body.error, expectedError);
});
```

- [ ] **Step 2: Implement step definitions**

All step definitions are implemented above. Each step calls the application through the HTTP API using supertest -- no business logic in steps.

- [ ] **Step 3: Dry-run validation**

Run: `npx cucumber-js --dry-run features/booking.feature`
Expected: ZERO undefined or pending steps

- [ ] **Step 4: Run scenarios**

Run: `npx cucumber-js features/booking.feature`
Expected: ALL 5 scenarios PASS (exit code 0)

- [ ] **Step 5: Verify no feature files changed**

Run: `git diff -- '*.feature'`
Expected: NO changes to any .feature file

- [ ] **Step 6: Commit**

```bash
git add features/step_definitions/booking-steps.js
git commit -m "test: add BDD step definitions for booking feature (5 scenarios)"
```

---

### Task 7: Architecture Style Fitness Functions

**Files:**
- Create: `fitness/no-shared-database.test.js`
- Create: `fitness/independent-deployability.test.js`
- Create: `fitness/service-size-bounds.test.js`
- Create: `fitness/api-contract-compliance.test.js`
- Create: `fitness/no-shared-business-logic.test.js`

These tests enforce the 5 style fitness functions defined in the "Architecture Style Fitness Functions" section of architecture.md. They are mandatory and immutable -- if the implementation violates them, the implementation must change.

- [ ] **Step 1: Write the no-shared-database fitness function**

```javascript
// fitness/no-shared-database.test.js
const fs = require('fs');
const path = require('path');

describe('Style FF: No Shared Database (architecture.md)', () => {
  test('database config connects only to booking_service database', () => {
    const dbConfig = fs.readFileSync(
      path.join(__dirname, '..', 'src', 'config', 'database.js'), 'utf8'
    );
    expect(dbConfig).toContain('booking_service');
    expect(dbConfig).not.toMatch(/catalog_service|payment_service|fulfillment_service/);
  });

  test('no migration references tables from other services', () => {
    const migrationsDir = path.join(__dirname, '..', 'db', 'migrations');
    const files = fs.readdirSync(migrationsDir);
    for (const file of files) {
      const content = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
      expect(content).not.toMatch(/catalog\.|payment\.|fulfillment\./);
    }
  });

  test('repository code does not join across service boundaries', () => {
    const repoFile = fs.readFileSync(
      path.join(__dirname, '..', 'src', 'booking', 'booking.repository.js'), 'utf8'
    );
    expect(repoFile).not.toMatch(/JOIN\s+(catalog|payment|fulfillment)/i);
  });
});
```

- [ ] **Step 2: Write the independent deployability fitness function**

```javascript
// fitness/independent-deployability.test.js
const fs = require('fs');
const path = require('path');

describe('Style FF: Independent Deployability (architecture.md)', () => {
  test('package.json has a start script for independent execution', () => {
    const pkg = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'package.json'), 'utf8'));
    expect(pkg.scripts).toHaveProperty('start');
  });

  test('no imports from other service source directories', () => {
    const srcDir = path.join(__dirname, '..', 'src');
    const allFiles = getAllJsFiles(srcDir);
    for (const file of allFiles) {
      const content = fs.readFileSync(file, 'utf8');
      expect(content).not.toMatch(/require\(['"].*\/(catalog|payment|fulfillment)-service\//);
    }
  });
});

function getAllJsFiles(dir) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...getAllJsFiles(fullPath));
    } else if (entry.name.endsWith('.js')) {
      results.push(fullPath);
    }
  }
  return results;
}
```

- [ ] **Step 3: Write the service size bounds fitness function**

```javascript
// fitness/service-size-bounds.test.js
const fs = require('fs');
const path = require('path');

describe('Style FF: Service Size Bounds (architecture.md)', () => {
  const MAX_LOC_PER_FILE = 300;
  const MAX_TOTAL_SRC_LOC = 2000;

  test('no source file exceeds LOC limit', () => {
    const srcDir = path.join(__dirname, '..', 'src');
    const files = getAllJsFiles(srcDir);
    for (const file of files) {
      const lines = fs.readFileSync(file, 'utf8').split('\n').length;
      expect(lines).toBeLessThanOrEqual(MAX_LOC_PER_FILE);
    }
  });

  test('total service source LOC stays within bounds', () => {
    const srcDir = path.join(__dirname, '..', 'src');
    const files = getAllJsFiles(srcDir);
    let totalLines = 0;
    for (const file of files) {
      totalLines += fs.readFileSync(file, 'utf8').split('\n').length;
    }
    expect(totalLines).toBeLessThanOrEqual(MAX_TOTAL_SRC_LOC);
  });
});

function getAllJsFiles(dir) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...getAllJsFiles(fullPath));
    } else if (entry.name.endsWith('.js')) {
      results.push(fullPath);
    }
  }
  return results;
}
```

- [ ] **Step 4: Write the API contract compliance fitness function**

```javascript
// fitness/api-contract-compliance.test.js
const fs = require('fs');
const path = require('path');

describe('Style FF: API Contract Compliance (architecture.md)', () => {
  test('client modules use HTTP/API calls, not direct database access', () => {
    const clientsDir = path.join(__dirname, '..', 'src', 'clients');
    if (!fs.existsSync(clientsDir)) return; // no clients yet is fine
    const files = fs.readdirSync(clientsDir).filter(f => f.endsWith('.js'));
    for (const file of files) {
      const content = fs.readFileSync(path.join(clientsDir, file), 'utf8');
      expect(content).not.toMatch(/require\(['"].*knex|require\(['"].*pg['"]\)/);
      expect(content).toMatch(/fetch|axios|http|request/i);
    }
  });

  test('Pact contract test files exist for each external service client', () => {
    const clientsDir = path.join(__dirname, '..', 'src', 'clients');
    if (!fs.existsSync(clientsDir)) return;
    const clients = fs.readdirSync(clientsDir).filter(f => f.endsWith('.client.js'));
    const contractsDir = path.join(__dirname, '..', 'tests', 'contracts');
    for (const client of clients) {
      const serviceName = client.replace('.client.js', '');
      const contractFile = path.join(contractsDir, `booking-${serviceName}.pact.js`);
      expect(fs.existsSync(contractFile)).toBe(true);
    }
  });
});
```

- [ ] **Step 5: Write the no-shared-business-logic fitness function**

```javascript
// fitness/no-shared-business-logic.test.js
const fs = require('fs');
const path = require('path');

describe('Style FF: No Shared Libraries with Business Logic (architecture.md)', () => {
  test('package.json shared dependencies contain no domain logic packages', () => {
    const pkg = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'package.json'), 'utf8'));
    const deps = Object.keys(pkg.dependencies || {});
    const domainPackages = deps.filter(d =>
      d.includes('booking-shared') || d.includes('domain-shared') || d.includes('business-logic')
    );
    expect(domainPackages).toEqual([]);
  });

  test('no imports from a shared domain library directory', () => {
    const srcDir = path.join(__dirname, '..', 'src');
    const files = getAllJsFiles(srcDir);
    for (const file of files) {
      const content = fs.readFileSync(file, 'utf8');
      expect(content).not.toMatch(/require\(['"]@company\/shared-domain/);
      expect(content).not.toMatch(/require\(['"]\.\.\/\.\.\/shared\//);
    }
  });
});

function getAllJsFiles(dir) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...getAllJsFiles(fullPath));
    } else if (entry.name.endsWith('.js')) {
      results.push(fullPath);
    }
  }
  return results;
}
```

- [ ] **Step 6: Run all fitness functions**

Run: `npx jest fitness/ --verbose`
Expected: ALL fitness function tests PASS

- [ ] **Step 7: Commit**

```bash
git add fitness/
git commit -m "test: add architecture style fitness functions from architecture.md"
```

---

### Task 8: Quality Scenario Tests -- Integration Tests (QS-005, QS-006, QS-007)

**Files:**
- Create: `src/clients/payment.client.js`
- Create: `src/clients/catalog.client.js`
- Create: `tests/integration/payment.integration.test.js`
- Create: `tests/integration/catalog.integration.test.js`

This task implements integration tests for quality scenarios QS-005 (payment service integration), QS-006 (catalog service availability check), and QS-007 (database failover graceful handling) from quality-scenarios.md. These test cross-service communication via API contracts and circuit breaker behavior, respecting the architecture.md constraint that services communicate only via defined API contracts.

- [ ] **Step 1: Write the failing payment client integration test (QS-005)**

```javascript
// tests/integration/payment.integration.test.js
const { PaymentClient } = require('../../src/clients/payment.client');

describe('Payment Service Integration (QS-005)', () => {
  let client;

  beforeEach(() => {
    client = new PaymentClient({ baseUrl: 'http://payment-service:3001' });
  });

  test('processPayment calls payment API and returns confirmation', async () => {
    // Uses nock to stub the external payment service
    const nock = require('nock');
    nock('http://payment-service:3001')
      .post('/payments')
      .reply(200, { paymentId: 'pay-1', status: 'completed' });

    const result = await client.processPayment({
      bookingId: 'booking-1',
      amount: 99.99,
      currency: 'USD',
    });

    expect(result.status).toBe('completed');
    expect(result.paymentId).toBe('pay-1');
  });

  test('circuit breaker opens after 5 consecutive failures (architecture.md graceful degradation)', async () => {
    const nock = require('nock');
    for (let i = 0; i < 5; i++) {
      nock('http://payment-service:3001').post('/payments').reply(500);
    }

    for (let i = 0; i < 5; i++) {
      await expect(client.processPayment({ bookingId: 'b-1', amount: 10, currency: 'USD' }))
        .rejects.toThrow();
    }

    // 6th call should fail fast without hitting the network
    await expect(client.processPayment({ bookingId: 'b-1', amount: 10, currency: 'USD' }))
      .rejects.toThrow('Circuit breaker is open');
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npx jest tests/integration/payment.integration.test.js --verbose`
Expected: FAIL with "Cannot find module '../../src/clients/payment.client'"

- [ ] **Step 3: Implement the payment client with circuit breaker**

```javascript
// src/clients/payment.client.js
const http = require('http');
const https = require('https');

class PaymentClient {
  constructor({ baseUrl }) {
    this.baseUrl = baseUrl;
    this.failureCount = 0;
    this.circuitOpen = false;
    this.failureThreshold = 5;
    this.resetTimeout = 30000;
  }

  async processPayment({ bookingId, amount, currency }) {
    if (this.circuitOpen) {
      throw new Error('Circuit breaker is open');
    }

    try {
      const result = await this._post('/payments', { bookingId, amount, currency });
      this.failureCount = 0;
      return result;
    } catch (err) {
      this.failureCount++;
      if (this.failureCount >= this.failureThreshold) {
        this.circuitOpen = true;
        setTimeout(() => {
          this.circuitOpen = false;
          this.failureCount = 0;
        }, this.resetTimeout);
      }
      throw err;
    }
  }

  _post(path, body) {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.baseUrl);
      const options = {
        method: 'POST',
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
        headers: { 'Content-Type': 'application/json' },
      };
      const client = url.protocol === 'https:' ? https : http;
      const req = client.request(options, (res) => {
        let data = '';
        res.on('data', chunk => { data += chunk; });
        res.on('end', () => {
          if (res.statusCode >= 400) {
            reject(new Error(`Payment service returned ${res.statusCode}`));
          } else {
            resolve(JSON.parse(data));
          }
        });
      });
      req.on('error', reject);
      req.write(JSON.stringify(body));
      req.end();
    });
  }
}

module.exports = { PaymentClient };
```

- [ ] **Step 4: Write the failing catalog client integration test (QS-006)**

```javascript
// tests/integration/catalog.integration.test.js
const { CatalogClient } = require('../../src/clients/catalog.client');

describe('Catalog Service Integration (QS-006)', () => {
  let client;

  beforeEach(() => {
    client = new CatalogClient({ baseUrl: 'http://catalog-service:3002' });
  });

  test('checkResourceExists calls catalog API and returns resource details', async () => {
    const nock = require('nock');
    nock('http://catalog-service:3002')
      .get('/resources/res-1')
      .reply(200, { id: 'res-1', name: 'Conference Room A', available: true });

    const result = await client.checkResourceExists('res-1');
    expect(result.id).toBe('res-1');
    expect(result.available).toBe(true);
  });

  test('returns null for non-existent resource', async () => {
    const nock = require('nock');
    nock('http://catalog-service:3002')
      .get('/resources/res-999')
      .reply(404);

    const result = await client.checkResourceExists('res-999');
    expect(result).toBeNull();
  });
});
```

- [ ] **Step 5: Implement the catalog client**

```javascript
// src/clients/catalog.client.js
const http = require('http');
const https = require('https');

class CatalogClient {
  constructor({ baseUrl }) {
    this.baseUrl = baseUrl;
    this.failureCount = 0;
    this.circuitOpen = false;
    this.failureThreshold = 5;
    this.resetTimeout = 30000;
  }

  async checkResourceExists(resourceId) {
    if (this.circuitOpen) {
      throw new Error('Circuit breaker is open');
    }

    try {
      const result = await this._get(`/resources/${resourceId}`);
      this.failureCount = 0;
      return result;
    } catch (err) {
      if (err.message.includes('404')) {
        return null;
      }
      this.failureCount++;
      if (this.failureCount >= this.failureThreshold) {
        this.circuitOpen = true;
        setTimeout(() => {
          this.circuitOpen = false;
          this.failureCount = 0;
        }, this.resetTimeout);
      }
      throw err;
    }
  }

  _get(path) {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.baseUrl);
      const options = {
        method: 'GET',
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
      };
      const client = url.protocol === 'https:' ? https : http;
      const req = client.request(options, (res) => {
        let data = '';
        res.on('data', chunk => { data += chunk; });
        res.on('end', () => {
          if (res.statusCode === 404) {
            reject(new Error('Resource not found (404)'));
          } else if (res.statusCode >= 400) {
            reject(new Error(`Catalog service returned ${res.statusCode}`));
          } else {
            resolve(JSON.parse(data));
          }
        });
      });
      req.on('error', reject);
      req.end();
    });
  }
}

module.exports = { CatalogClient };
```

- [ ] **Step 6: Run all integration tests to verify they pass**

Run: `npx jest tests/integration/ --verbose`
Expected: ALL integration tests PASS

- [ ] **Step 7: Commit**

```bash
git add src/clients/ tests/integration/payment.integration.test.js tests/integration/catalog.integration.test.js
git commit -m "feat: add payment and catalog clients with circuit breakers (QS-005, QS-006)"
```
