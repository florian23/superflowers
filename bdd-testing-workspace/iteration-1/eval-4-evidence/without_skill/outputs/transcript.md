# BDD Test Verification - /tmp/bdd-eval-4/

## Project Overview

- **Framework:** @cucumber/cucumber v10.x (Node.js)
- **Feature file:** `features/gruss.feature`
- **Step definitions:** `features/step_definitions/gruss-steps.js`

## Feature: Begruessung

The feature tests a greeting function that returns different greetings based on the time of day:

```gherkin
Feature: Begruessung
  Scenario: Morgens gruessen
    Given es ist 8 Uhr
    When ich jemanden begruesse
    Then sage ich "Guten Morgen"

  Scenario: Abends gruessen
    Given es ist 20 Uhr
    When ich jemanden begruesse
    Then sage ich "Guten Abend"
```

## Step Definitions

```javascript
const { Given, When, Then } = require('@cucumber/cucumber');
let hour, greeting;
Given('es ist {int} Uhr', function(h) { hour = h; });
When('ich jemanden begruesse', function() { greeting = hour < 12 ? 'Guten Morgen' : 'Guten Abend'; });
Then('sage ich {string}', function(expected) { if(greeting !== expected) throw new Error(`Expected '${expected}' but got '${greeting}'`); });
```

## Test Execution

```
$ npx cucumber-js

......

2 scenarios (2 passed)
6 steps (6 passed)
0m00.016s (executing steps: 0m00.005s)
```

## Result

All 2 scenarios and 6 steps passed successfully.
