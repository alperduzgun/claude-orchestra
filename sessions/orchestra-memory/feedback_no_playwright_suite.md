---
name: no-playwright-suite
description: Never run the full playwright test suite — always do smoke tests instead
type: feedback
---

Playwright test suite (`npx playwright test`) ASLA çalıştırılmamalı.

**Why:** Kullanıcı full test suite çalıştırılmasını istemiyor.

**How to apply:** Doğrulama için her zaman smoke test yap:
- Curl ile API endpoint'lerini test et
- Playwright MCP araçlarıyla (browser_navigate, browser_snapshot, browser_click) manuel UI doğrulaması yap
- TypeScript: `tsc --noEmit` ile tip kontrolü yap
- Hiçbir zaman `npx playwright test` veya `pnpm test` gibi test suite komutları çalıştırma
