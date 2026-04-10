---
name: Live testing means manual interaction, not test files
description: When user says "live test" they mean manually operating the running app, not writing/running Playwright or unit test specs
type: feedback
---

"Live test" = open the browser, actually click through the app, observe behavior, report what you see. NOT writing spec files, NOT running playwright/vitest/bun test commands.

**Why:** User explicitly said "test dosyaları olmadan normal insan gibi test yapacaksın" — test like a human without test files. Writing more test automation is not what they asked for.

**How to apply:** When asked to "live test" or verify something works:
1. Ensure the app is running (web + server + daemon)
2. Use browser automation (Playwright page.goto/click/fill) OR describe manual steps to verify, OR use curl/fetch directly against the live API
3. Report observations: "navigated to X, clicked Y, saw Z"
4. Do NOT create spec files, do NOT run `npx playwright test`, do NOT run unit test suites
