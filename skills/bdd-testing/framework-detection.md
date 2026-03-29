# BDD Framework Detection & Configuration

## Detection Algorithm

```
1. Check for existing BDD config files → use existing framework
2. If none found: detect primary language from project files
3. Select default BDD framework for that language
4. Check for existing test infrastructure (runner, directories)
5. If language undetectable: report NEEDS_CONTEXT
```

### Existing Config Detection (Priority)

| Config File | Framework |
|------------|-----------|
| `jest-cucumber` in `package.json` dependencies | jest-cucumber |
| `cucumber.js` / `cucumber.mjs` / `.cucumber.yaml` | cucumber-js |
| `behave.ini` / `setup.cfg [behave]` / `.behaverc` | behave |
| `conftest.py` with `pytest-bdd` imports | pytest-bdd |
| `cucumber.properties` / `@CucumberOptions` in Java | cucumber-jvm |
| `.godog.yml` | godog |
| `reqnroll.json` / `specflow.json` | Reqnroll/SpecFlow |

If found: use existing framework, do not reconfigure.

---

## Per-Framework Configuration

### JavaScript / TypeScript — @cucumber/cucumber

**Detection:** `package.json` exists

**Install:**
```bash
npm install --save-dev @cucumber/cucumber
# For TypeScript:
npm install --save-dev @cucumber/cucumber ts-node @types/node
```

**Config file** (`cucumber.js`):
```javascript
module.exports = {
  default: {
    paths: ['features/**/*.feature'],
    require: ['features/step_definitions/**/*.js'],
    // For TypeScript:
    // requireModule: ['ts-node/register'],
    // require: ['features/step_definitions/**/*.ts'],
    format: ['progress-bar', 'html:reports/cucumber-report.html'],
  }
};
```

**Directory structure:**
```
features/
  *.feature
  step_definitions/
    *.js (or *.ts)
  support/
    world.js
```

**Run:** `npx cucumber-js`

---

### JavaScript / TypeScript — jest-cucumber

**Detection:** `package.json` with `jest-cucumber` in dependencies/devDependencies

**When to use instead of @cucumber/cucumber:** When the project already uses Jest as its test runner. jest-cucumber integrates Gherkin feature files with Jest's test infrastructure, avoiding a separate test runner.

**Install:**
```bash
npm install --save-dev jest-cucumber
```

**Jest config** (in `package.json` or `jest.config.js`):
```json
{
  "jest": {
    "testMatch": ["**/test/**/*.steps.js", "**/step-definitions/**/*.steps.js"]
  }
}
```

**Step definition pattern:**
```javascript
const { defineFeature, loadFeature } = require('jest-cucumber');
const feature = loadFeature('./features/example.feature');

defineFeature(feature, test => {
  test('Scenario name', ({ given, when, then }) => {
    given('some precondition', () => { /* ... */ });
    when('an action occurs', () => { /* ... */ });
    then('expected outcome', () => { /* ... */ });
  });
});
```

**Directory structure:**
```
features/
  *.feature
test/
  step-definitions/
    *.steps.js
```

**Run:** `npx jest --testMatch='**/*.steps.js'`

**Key differences from @cucumber/cucumber:**
- Steps are defined inline within each scenario (not shared globally via regex)
- Each `.steps.js` file imports and binds to a specific `.feature` file
- Verification command: `npx jest --testMatch='**/*.steps.js'` (NOT `npx cucumber-js`)
- Dry-run equivalent: `npx jest --testMatch='**/*.steps.js' --listTests`

---

### Python — behave

**Detection:** `pyproject.toml`, `setup.py`, `setup.cfg`, or `*.py` files (and pytest-bdd NOT in use)

**Install:**
```bash
pip install behave
# or
poetry add --group dev behave
```

**Config file** (`behave.ini` or `setup.cfg [behave]`):
```ini
[behave]
paths = features
format = progress
```

**Directory structure:**
```
features/
  *.feature
  steps/
    *.py
  environment.py
```

**Run:** `behave`

---

### Python — pytest-bdd

**Detection:** `pytest` already in project dependencies

**Install:**
```bash
pip install pytest-bdd
# or
poetry add --group dev pytest-bdd
```

**Directory structure:**
```
tests/
  features/
    *.feature
  test_*.py (step definitions alongside test files)
```

**Run:** `pytest`

---

### Java / Kotlin — cucumber-jvm

**Detection:** `pom.xml` or `build.gradle` / `build.gradle.kts`

**Install (Maven):**
```xml
<dependency>
    <groupId>io.cucumber</groupId>
    <artifactId>cucumber-java</artifactId>
    <version>7.x.x</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>io.cucumber</groupId>
    <artifactId>cucumber-junit-platform-engine</artifactId>
    <version>7.x.x</version>
    <scope>test</scope>
</dependency>
```

**Install (Gradle):**
```groovy
testImplementation 'io.cucumber:cucumber-java:7.+'
testImplementation 'io.cucumber:cucumber-junit-platform-engine:7.+'
```

**Directory structure:**
```
src/test/
  resources/features/
    *.feature
  java/com/example/steps/
    *Steps.java
```

**Run:** `mvn test` or `gradle test`

---

### Go — godog

**Detection:** `go.mod` exists

**Install:**
```bash
go install github.com/cucumber/godog/cmd/godog@latest
```

**Directory structure:**
```
features/
  *.feature
*_test.go (step definitions in test files)
```

**Run:** `godog` or `go test -v --godog.format=pretty`

---

### Ruby — cucumber-ruby

**Detection:** `Gemfile` exists

**Install:**
```ruby
# Gemfile
group :test do
  gem 'cucumber'
  gem 'rspec-expectations'
end
```

```bash
bundle install
```

**Directory structure:**
```
features/
  *.feature
  step_definitions/
    *_steps.rb
  support/
    env.rb
```

**Run:** `bundle exec cucumber`

---

### C# / .NET — Reqnroll

**Detection:** `*.csproj` exists

**Install:**
```bash
dotnet add package Reqnroll
dotnet add package Reqnroll.NUnit  # or Reqnroll.xUnit
```

**Directory structure:**
```
Features/
  *.feature
Steps/
  *StepDefinitions.cs
```

**Run:** `dotnet test`

---

### Rust — cucumber-rs

**Detection:** `Cargo.toml` exists

**Install** (add to `Cargo.toml`):
```toml
[dev-dependencies]
cucumber = "0.21"
```

**Directory structure:**
```
features/
  *.feature
tests/
  features.rs
```

**Run:** `cargo test --test features`

---

## Fallback

If the primary language cannot be determined from project files:

1. Check if a `Makefile`, `Dockerfile`, or CI config reveals the language
2. Check file extensions in `src/` or `lib/` directories
3. If still unclear: report **NEEDS_CONTEXT** with the message:
   "Cannot detect project language. Please specify the primary language and preferred BDD framework."
