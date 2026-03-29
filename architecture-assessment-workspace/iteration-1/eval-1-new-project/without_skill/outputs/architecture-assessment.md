# Architecture Assessment: Project Management Web App

**Project:** Project Management Platform (Kanban Boards, Time Tracking, Team Chat)
**Date:** 2026-03-28
**Status:** Initial Assessment Complete

---

## 1. Executive Summary

This document presents the architecture for a web-based project management application featuring Kanban boards, time tracking, and real-time team chat. The architecture prioritizes team familiarity (TypeScript end-to-end), operational simplicity (managed cloud services), and GDPR compliance. It is designed for small-to-medium teams (5-50 users per workspace) with a growth target of 10,000 workspaces within 18 months.

---

## 2. System Context

### Target Users
- Small-to-medium teams (5-50 members per workspace)
- Initial capacity: 100 workspaces, scaling to 10,000
- ~30% concurrent users during business hours

### Core Features
1. **Kanban Boards** -- drag-and-drop, customizable columns, card assignments, labels, due dates
2. **Time Tracking** -- per-task tracking with daily/weekly/monthly reporting
3. **Team Chat** -- channels, DMs, threads, file sharing, real-time delivery
4. **User Management** -- roles (admin, member, viewer), workspace-scoped
5. **Dashboard** -- project overview, analytics, activity feed

### Non-Functional Requirements
| Requirement | Target |
|---|---|
| Real-time latency | < 500ms |
| Uptime | 99.9% |
| Page load | < 2 seconds |
| Compliance | GDPR |
| Mobile | Responsive web (no native app) |
| Data export | CSV, PDF |

---

## 3. Architecture Overview

### High-Level Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      Clients                             │
│              (Browser, Mobile Browser)                    │
└──────────────┬──────────────────┬───────────────────────┘
               │ HTTPS            │ WSS
               ▼                  ▼
┌──────────────────┐  ┌──────────────────────┐
│   Next.js App    │  │   Fastify API        │
│   (Vercel)       │  │   + Socket.IO        │
│                  │  │   (Railway)          │
│  - SSR/SSG pages │  │                      │
│  - React 19 UI   │  │  - REST endpoints    │
│  - Client state  │  │  - WebSocket events  │
└──────────────────┘  │  - Auth middleware    │
                      └──────────┬───────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
            ┌────────────┐ ┌─────────┐ ┌──────────┐
            │ PostgreSQL │ │  Redis  │ │  AWS S3  │
            │  (Neon)    │ │(Upstash)│ │  (Files) │
            │            │ │         │ │          │
            │ - Users    │ │ - Cache │ │ - Uploads│
            │ - Boards   │ │ - PubSub│ │ - Avatars│
            │ - Cards    │ │ - Queue │ │          │
            │ - Chat     │ │         │ │          │
            │ - Time     │ │         │ │          │
            └────────────┘ └─────────┘ └──────────┘
```

### Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Frontend | Next.js 15 (App Router), React 19, TypeScript | Team expertise, SSR for SEO/perf, excellent DX |
| Backend | Fastify, TypeScript | High performance, schema validation, plugin system |
| Real-time | Socket.IO with Redis adapter | Reliable WebSockets, reconnection, room-based broadcasting |
| Database | PostgreSQL (Neon) | Relational integrity, JSON support, managed scaling |
| Cache | Redis (Upstash) | Session storage, real-time pub/sub, response caching |
| ORM | Drizzle ORM | Type-safe, lightweight, close to SQL |
| Auth | Lucia + Arctic (OAuth) | Self-hosted for GDPR, lightweight, flexible |
| File Storage | AWS S3 | Pre-signed URLs, cost-effective, S3-compatible abstraction |
| Monorepo | pnpm workspaces + Turborepo | Shared types, efficient builds |
| Testing | Vitest, Playwright, Testing Library | Fast unit tests, reliable E2E |
| CI/CD | GitHub Actions | Standard, integrates with Vercel and Railway |
| Hosting | Vercel (frontend), Railway (backend) | Low-ops, auto-scaling, easy deployments |

---

## 4. Project Structure

```
project-root/
├── apps/
│   ├── web/                    # Next.js frontend
│   │   ├── app/                # App Router pages
│   │   │   ├── (auth)/         # Login, register, OAuth callbacks
│   │   │   ├── (dashboard)/    # Main app layout
│   │   │   │   ├── boards/     # Kanban board views
│   │   │   │   ├── time/       # Time tracking views
│   │   │   │   ├── chat/       # Chat interface
│   │   │   │   └── settings/   # Workspace and user settings
│   │   │   └── layout.tsx
│   │   ├── components/         # React components
│   │   │   ├── board/          # Kanban-specific components
│   │   │   ├── chat/           # Chat-specific components
│   │   │   ├── time/           # Time tracking components
│   │   │   └── ui/             # Shared UI primitives
│   │   ├── hooks/              # Custom React hooks
│   │   ├── lib/                # Client utilities, API client, socket client
│   │   └── stores/             # Client state (Zustand)
│   │
│   └── api/                    # Fastify backend
│       ├── src/
│       │   ├── routes/         # Route handlers
│       │   │   ├── auth/
│       │   │   ├── boards/
│       │   │   ├── cards/
│       │   │   ├── chat/
│       │   │   ├── time/
│       │   │   └── users/
│       │   ├── services/       # Business logic
│       │   ├── socket/         # Socket.IO event handlers
│       │   │   ├── board.ts
│       │   │   ├── chat.ts
│       │   │   └── presence.ts
│       │   ├── middleware/      # Auth, rate limiting, validation
│       │   ├── plugins/        # Fastify plugins (db, redis, auth)
│       │   └── server.ts       # Entry point
│       └── Dockerfile
│
├── packages/
│   ├── shared/                 # Shared between frontend and backend
│   │   ├── types/              # TypeScript type definitions
│   │   ├── schemas/            # Zod validation schemas
│   │   └── constants/          # Shared constants and enums
│   │
│   └── db/                     # Database package
│       ├── schema/             # Drizzle schema definitions
│       ├── migrations/         # SQL migrations
│       ├── seed/               # Seed data for development
│       └── drizzle.config.ts
│
├── docker-compose.yml          # Local dev: PostgreSQL, Redis, MinIO
├── turbo.json                  # Turborepo configuration
├── pnpm-workspace.yaml
└── package.json
```

---

## 5. Data Model

### Core Entities

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Workspace  │────<│    Member    │>────│     User     │
│              │     │              │     │              │
│ id           │     │ workspace_id │     │ id           │
│ name         │     │ user_id      │     │ email        │
│ slug         │     │ role         │     │ name         │
│ created_at   │     │ joined_at    │     │ avatar_url   │
└──────┬───────┘     └──────────────┘     │ password_hash│
       │                                   │ created_at   │
       │                                   └──────────────┘
       │
       ├─────────────────┐─────────────────┐
       ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Project    │  │   Channel    │  │  TimeEntry   │
│              │  │              │  │              │
│ id           │  │ id           │  │ id           │
│ workspace_id │  │ workspace_id │  │ user_id      │
│ name         │  │ name         │  │ card_id (opt)│
│ description  │  │ type (chan/dm)│  │ project_id   │
│ created_at   │  │ created_at   │  │ start_time   │
└──────┬───────┘  └──────┬───────┘  │ end_time     │
       │                 │          │ description  │
       ▼                 ▼          └──────────────┘
┌──────────────┐  ┌──────────────┐
│    Board     │  │   Message    │
│              │  │              │
│ id           │  │ id           │
│ project_id   │  │ channel_id   │
│ name         │  │ user_id      │
│ created_at   │  │ content      │
└──────┬───────┘  │ thread_id    │
       │          │ created_at   │
       ▼          └──────────────┘
┌──────────────┐
│    Column    │
│              │
│ id           │
│ board_id     │
│ name         │
│ position     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     Card     │
│              │
│ id           │
│ column_id    │
│ title        │
│ description  │
│ position     │
│ assignee_id  │
│ due_date     │
│ labels       │
│ created_at   │
└──────────────┘
```

### Key Indexes
- `cards(column_id, position)` -- for ordered card retrieval
- `messages(channel_id, created_at)` -- for paginated chat history
- `time_entries(user_id, start_time)` -- for time reports
- `members(workspace_id, user_id)` -- unique constraint, fast lookups

---

## 6. API Design

### REST Endpoints (Fastify)

```
Authentication:
  POST   /api/auth/register
  POST   /api/auth/login
  POST   /api/auth/logout
  GET    /api/auth/oauth/:provider
  GET    /api/auth/oauth/:provider/callback

Workspaces:
  GET    /api/workspaces
  POST   /api/workspaces
  PATCH  /api/workspaces/:id
  DELETE /api/workspaces/:id

Projects:
  GET    /api/workspaces/:wid/projects
  POST   /api/workspaces/:wid/projects
  PATCH  /api/projects/:id
  DELETE /api/projects/:id

Boards & Cards:
  GET    /api/projects/:pid/boards
  POST   /api/projects/:pid/boards
  GET    /api/boards/:id (includes columns and cards)
  POST   /api/boards/:bid/columns
  PATCH  /api/columns/:id
  POST   /api/columns/:cid/cards
  PATCH  /api/cards/:id
  POST   /api/cards/:id/move  (column_id, position)

Time Tracking:
  POST   /api/time/start
  POST   /api/time/stop
  GET    /api/time/entries?from=&to=&user_id=&project_id=
  GET    /api/time/reports?period=weekly&project_id=

Chat:
  GET    /api/workspaces/:wid/channels
  POST   /api/workspaces/:wid/channels
  GET    /api/channels/:id/messages?cursor=&limit=
  POST   /api/channels/:id/messages

Users:
  GET    /api/users/me
  PATCH  /api/users/me
  GET    /api/workspaces/:wid/members

Files:
  POST   /api/files/upload-url  (returns pre-signed S3 URL)
  GET    /api/files/:id
```

### WebSocket Events (Socket.IO)

```
Client -> Server:
  board:join        { boardId }
  board:leave       { boardId }
  card:move         { cardId, columnId, position }
  card:update       { cardId, changes }
  chat:join         { channelId }
  chat:leave        { channelId }
  chat:message      { channelId, content, threadId? }
  chat:typing       { channelId }
  presence:status   { status: 'online' | 'away' }

Server -> Client:
  board:card-moved     { cardId, columnId, position, userId }
  board:card-updated   { cardId, changes, userId }
  board:column-updated { columnId, changes }
  chat:new-message     { message }
  chat:user-typing     { channelId, userId }
  presence:update      { userId, status }
  notification:new     { type, payload }
```

---

## 7. Security Architecture

### Authentication Flow
1. Email/password registration with bcrypt hashing (cost factor 12)
2. Session-based auth with HTTP-only, secure, SameSite cookies
3. Sessions stored in PostgreSQL with 30-day expiry
4. OAuth 2.0 via Arctic (Google, GitHub providers)
5. CSRF protection via double-submit cookie pattern

### Authorization Model
- **Workspace-scoped RBAC**: admin, member, viewer
- Admin: full workspace management, member invitations, project CRUD
- Member: project participation, card CRUD, chat, time tracking
- Viewer: read-only access to boards and chat
- All API endpoints verify workspace membership and role

### GDPR Compliance
- EU-region deployment (Vercel EU, Railway EU, Neon EU)
- User data export endpoint (JSON format)
- Account deletion with cascading data removal (30-day grace period)
- Cookie consent banner with granular controls
- Data Processing Agreements with all third-party providers
- Encryption at rest (managed by cloud providers) and in transit (TLS)

### Rate Limiting
- API: 100 requests/minute per user (general), 10/minute for auth endpoints
- WebSocket: 50 messages/minute per connection
- File uploads: 10/minute, 25MB max per file
- Implemented via Redis-backed sliding window

---

## 8. Performance Strategy

### Frontend
- Next.js App Router with server components for initial page load
- Client-side state management with Zustand (lightweight, no boilerplate)
- Optimistic updates for card moves and chat messages
- Virtual scrolling for long card lists and chat history
- Image lazy loading and responsive images via Next.js Image

### Backend
- Connection pooling for PostgreSQL (pgBouncer via Neon)
- Redis caching for frequently accessed data (board state, user profiles)
- Pagination with cursor-based pagination for chat messages
- Database query optimization with proper indexes
- Fastify's built-in schema validation (compiled with fast-json-stringify)

### Real-time
- Socket.IO rooms for scoped broadcasting (one room per board, one per channel)
- Redis pub/sub for cross-instance event distribution
- Debounced typing indicators (500ms)
- Reconnection with exponential backoff

---

## 9. Monitoring and Observability

| Concern | Tool | Notes |
|---|---|---|
| Error tracking | Sentry | Frontend and backend error capture |
| Uptime monitoring | BetterStack or Checkly | HTTP and WebSocket health checks |
| Application logs | Railway built-in + structured JSON logs | Searchable, retention 30 days |
| Performance | Vercel Analytics (frontend), custom metrics | Core Web Vitals, API response times |
| Database | Neon dashboard | Query performance, connection metrics |

---

## 10. Development Workflow

1. **Local development:** `docker-compose up` for PostgreSQL, Redis, MinIO; `pnpm dev` for all apps via Turborepo
2. **Branching:** trunk-based development with short-lived feature branches
3. **CI pipeline:** lint, type-check, unit tests, integration tests on every PR
4. **E2E tests:** Playwright against staging on merge to main
5. **Deployment:** automatic preview deployments on PR (Vercel), production deploy on merge to main
6. **Database migrations:** Drizzle Kit for schema changes, applied automatically in CI

---

## 11. Risk Register

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| 1 | Socket.IO scaling bottleneck | Medium | High | Redis adapter, horizontal scaling, load testing at 1000 concurrent connections |
| 2 | Chat storage growth | High | Medium | Message partitioning by date, archival policy, pagination |
| 3 | No DevOps expertise | Medium | Medium | Fully managed services, IaC with SST or Pulumi, runbooks |
| 4 | GDPR non-compliance | Low | Critical | Privacy-by-design, DPAs, EU hosting, data deletion workflows |
| 5 | Vendor lock-in (Vercel/Railway) | Medium | Low | Docker-based backend, standard PostgreSQL, S3-compatible storage |
| 6 | Real-time conflict resolution (concurrent card edits) | Medium | Medium | Last-write-wins with optimistic UI, conflict notification to users |

---

## 12. Phased Delivery Roadmap

### Phase 1 (Weeks 1-4): Foundation
- Monorepo setup, CI/CD pipeline
- Database schema and migrations
- Authentication (email/password + Google OAuth)
- Basic workspace and project management

### Phase 2 (Weeks 5-8): Kanban
- Board, column, card CRUD
- Drag-and-drop with real-time sync
- Card details (assignments, labels, due dates)
- Activity feed per card

### Phase 3 (Weeks 9-11): Time Tracking
- Start/stop timer per task
- Manual time entry
- Reporting views (daily, weekly, monthly)
- CSV export

### Phase 4 (Weeks 12-15): Team Chat
- Channels and direct messages
- Real-time messaging with Socket.IO
- Thread replies
- File sharing (S3 uploads)
- Typing indicators and presence

### Phase 5 (Weeks 16-18): Polish and Launch
- Dashboard and analytics
- Email notifications
- Mobile responsiveness polish
- Performance optimization
- Security audit
- Production deployment and monitoring

---

## 13. Decision Log

| # | Decision | Alternatives Considered | Rationale |
|---|----------|------------------------|-----------|
| 1 | Next.js 15 (App Router) | SvelteKit, Remix | Team expertise with React, SSR capabilities, Vercel integration |
| 2 | Fastify backend | Express, Next.js API routes, tRPC | Performance, schema validation, better separation for real-time + future public API |
| 3 | PostgreSQL | MySQL, MongoDB | Relational integrity for project data, JSON support, team experience |
| 4 | Redis (Upstash) | Memcached, in-memory | Pub/sub for real-time, session storage, caching -- all in one |
| 5 | Drizzle ORM | Prisma, Kysely, raw SQL | Type-safe, lightweight, close to SQL, good migration tooling |
| 6 | Socket.IO | ws, Ably, Pusher | Self-hosted (GDPR), reconnection handling, room abstraction, team familiarity |
| 7 | Lucia Auth | NextAuth, Auth0, Clerk | Self-hosted for GDPR control, lightweight, session-based |
| 8 | pnpm + Turborepo | npm workspaces, Nx | Fast, simple configuration, good monorepo support |
| 9 | Railway + Vercel | AWS ECS, Fly.io, Render | Low operational overhead, auto-scaling, easy deployment |
| 10 | Vitest + Playwright | Jest, Cypress | Fast execution, native ESM support, reliable E2E |
