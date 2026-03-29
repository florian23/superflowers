# Architecture Assessment: JSON Validator CLI

## 1. Project Overview

A command-line application that validates JSON files for syntactic correctness and optionally against JSON Schema definitions. The tool reads one or more file paths from the command line, parses each file, and reports validation results (success or errors with line/column information).

## 2. Functional Requirements

- Accept one or more file paths as CLI arguments
- Validate JSON syntax (well-formedness)
- Optionally validate against a JSON Schema (if a `--schema` flag is provided)
- Output clear, human-readable error messages with file name, line number, and column
- Return appropriate exit codes (0 = all valid, 1 = validation errors, 2 = usage/system error)
- Support glob patterns for batch validation (e.g., `*.json`)
- Support `--quiet` mode (exit code only, no output on success)
- Read from stdin when no file path is given

## 3. Recommended Technology Stack

| Concern           | Choice         | Rationale                                                       |
| ----------------- | -------------- | --------------------------------------------------------------- |
| Language          | Node.js (TypeScript) | Widespread JSON ecosystem, strong typing, fast startup for CLI |
| CLI framework     | `commander`    | Lightweight, well-maintained, minimal overhead                  |
| JSON parsing      | Built-in `JSON.parse` + custom error enrichment | No external dependency needed for basic validation |
| JSON Schema       | `ajv`          | Industry-standard, fast, supports Draft-07 and 2020-12         |
| Testing           | `vitest`       | Fast, TypeScript-native, zero-config                            |
| Build / Bundle    | `tsup`         | Produces a single CJS/ESM binary, tree-shakes dependencies     |
| Linting           | `eslint` + `prettier` | Standard code quality tooling                            |

### Alternative: Go

If startup latency and single-binary distribution are top priorities, Go is a strong alternative. The `encoding/json` stdlib handles parsing, and `github.com/santhosh-tekuri/jsonschema` covers schema validation. The trade-off is a smaller JSON tooling ecosystem compared to Node.js.

## 4. Proposed Architecture

### 4.1 Component Diagram

```
+------------------+
|   CLI Entry      |  (src/cli.ts)
|   Point          |  - Parses arguments via commander
+--------+---------+  - Orchestrates validation flow
         |
         v
+------------------+
|   Validator      |  (src/validator.ts)
|   Module         |  - validateSyntax(content: string): ValidationResult
+--------+---------+  - validateSchema(content: unknown, schema: object): ValidationResult
         |
         v
+------------------+
|   Reporter       |  (src/reporter.ts)
|   Module         |  - Formats results for terminal output
+------------------+  - Supports text and optional JSON output (--format json)

+------------------+
|   File Reader    |  (src/reader.ts)
|   Module         |  - Reads files from disk or stdin
+------------------+  - Resolves glob patterns
```

### 4.2 Directory Structure

```
json-validator/
  src/
    cli.ts            # Entry point, argument parsing
    validator.ts      # Core validation logic
    reporter.ts       # Output formatting
    reader.ts         # File I/O and glob resolution
    types.ts          # Shared type definitions
  tests/
    validator.test.ts
    reporter.test.ts
    reader.test.ts
    cli.test.ts       # Integration / E2E tests
    fixtures/
      valid.json
      invalid-syntax.json
      schema.json
      valid-against-schema.json
      invalid-against-schema.json
  package.json
  tsconfig.json
  README.md
```

### 4.3 Key Data Types

```typescript
interface ValidationResult {
  filePath: string;
  valid: boolean;
  errors: ValidationError[];
}

interface ValidationError {
  message: string;
  line?: number;
  column?: number;
  path?: string;        // JSON pointer for schema errors
}

interface CliOptions {
  schema?: string;       // Path to JSON Schema file
  quiet: boolean;
  format: "text" | "json";
}
```

## 5. Design Decisions and Rationale

### 5.1 Separation of parsing, validation, and reporting

Keeping these in distinct modules allows each to be tested independently and replaced without affecting the others. The validator module has no I/O dependencies and is pure-functional, making it trivial to unit test.

### 5.2 Enriched error messages with line/column

`JSON.parse` in Node.js provides limited positional information. To deliver useful line/column data, a lightweight re-parse step using a streaming JSON tokenizer (e.g., `jsonparse` or a custom scanner) is used only when `JSON.parse` throws. This avoids any performance overhead on the happy path.

### 5.3 Exit codes follow Unix conventions

- `0` -- all files valid
- `1` -- one or more validation failures
- `2` -- operational error (file not found, bad arguments)

This makes the tool composable in shell scripts and CI pipelines.

### 5.4 Optional JSON Schema validation is additive

Schema validation is only loaded when `--schema` is passed. The `ajv` dependency can be marked as an optional peer dependency or lazy-loaded to keep the base install lightweight.

## 6. Risk Assessment

| Risk                                    | Likelihood | Impact | Mitigation                                               |
| --------------------------------------- | ---------- | ------ | -------------------------------------------------------- |
| Large files exhaust memory              | Medium     | High   | Stream-based reading with size limit flag (`--max-size`) |
| Inconsistent error positions across engines | Low    | Medium | Pin Node.js version in CI; add regression fixtures       |
| JSON Schema spec drift (Draft versions) | Low        | Low    | Pin `ajv` version; document supported drafts             |
| Glob expansion produces too many files  | Low        | Medium | Add `--max-files` safety limit with sensible default     |

## 7. Performance Considerations

- For a CLI tool, startup time matters more than throughput. TypeScript bundled with `tsup` into a single file minimizes module resolution overhead.
- For batch validation of many small files, parallel file reads via `Promise.all` with a concurrency limiter (e.g., `p-limit`) prevent file descriptor exhaustion while improving throughput.
- JSON Schema compilation (`ajv.compile`) should happen once and be reused across all files in a single invocation.

## 8. Testing Strategy

| Layer        | Tool    | What is tested                                        |
| ------------ | ------- | ----------------------------------------------------- |
| Unit         | vitest  | Validator logic with various malformed inputs         |
| Unit         | vitest  | Reporter output formatting                            |
| Unit         | vitest  | Reader file/glob handling with mocked fs              |
| Integration  | vitest  | CLI end-to-end with real fixture files and exit codes |
| CI           | GitHub Actions | Matrix across Node 18, 20, 22                  |

## 9. Extensibility Path

The modular architecture supports future enhancements without structural changes:

- **Custom rules**: A plugin interface in `validator.ts` could accept user-defined validation functions.
- **YAML/TOML support**: Add alternative parsers behind a file-type dispatcher in `reader.ts`.
- **Watch mode**: Wrap the validation loop with `chokidar` for re-validation on file change.
- **IDE integration**: The `validator` module can be published as a library and consumed by VS Code extensions or language servers.

## 10. Recommendation

The project is straightforward and well-suited for a single-package TypeScript CLI. The proposed architecture keeps complexity minimal while leaving clear extension points. Recommended next steps:

1. Initialize the project with `npm init` and install core dependencies (`commander`, `ajv`, `tsup`, `vitest`).
2. Implement `validator.ts` with unit tests first (test-driven).
3. Add `reader.ts` and `reporter.ts`.
4. Wire everything together in `cli.ts` with integration tests.
5. Add a `bin` field in `package.json` and test the installed CLI via `npx`.

Estimated effort for a minimal viable version (syntax validation only, no schema): **2-4 hours**.
Full version with schema support, glob handling, and CI: **1-2 days**.
