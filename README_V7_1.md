# MetriQ GL V7.1 – Enterprise Foundation

This build upgrades the V6.2 prototype without pretending that a static GitHub Pages app is already an enterprise cloud service.

## Implemented

- Deep Scan V7.1 scans all worksheets and creates a cross-sheet evidence chain.
- Critical contradictions block verification.
- Native local `.xlsx` parser: the main WISAG scan no longer depends on an external JS library/CDN.
- Site/tenant model and role-gated views/actions.
- Local audit trail.
- Versioned data history by site/month.
- FLOSIQ local bridge.
- Integration contract for future cloud/WISAG adapters.
- Password-encrypted backup export/import (AES-GCM-256, PBKDF2-SHA256).
- Local data deletion.
- Real-data benchmark exchange: anonymized KPI export/import, minimum cohort gate and median comparison.
- Pilot evidence log for measured time savings and user feedback.
- Backend SQL/RLS blueprint.

## Regression test with real February 2026 workbook

Regression source: real February 2026 workbook (not included in this package).

- 26 / 26 worksheets read
- 21 evidence checks passed
- 0 critical contradictions
- 98% scan confidence
- Revenue confirmed by Quick Numbers, Part Operations, Faktura and Cost-plus budget control
- Own personnel confirmed by Personalkosten and Part Operations
- External personnel confirmed by REB and Part Operations
- Total costs confirmed by cost blocks and Cost-plus budget control
- DB1 confirmed mathematically and by Cost-plus management fee

## Still external by definition

A real cloud login/database cannot be activated without a backend project and credentials. A real WISAG connector cannot be activated without an approved WISAG data source/API. Real benchmark power and commercial validation require additional pilot sites. The code paths and exchange formats are now prepared for those steps.
