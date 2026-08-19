# MetriQ GL V7.1 – Regression & Security Report

Build: `7.1-enterprise-foundation`

## Verified
- JavaScript syntax: `app.js` OK
- Service worker syntax: OK
- Web app manifest JSON: OK
- Fresh install contains no embedded real site/month-close dataset
- V6 local-state migration preserves site/archive assignment
- Role gates tested for Team, GL, Regional and Admin preview
- Native `.xlsx` reader tested against a real 26-sheet month-close workbook
- Deep Scan result on regression workbook: 26/26 sheets read, 21 independent evidence checks passed, 0 critical contradictions, 98% data confidence
- Revenue, food cost, personnel, operating cost, total cost and DB1 are cross-checked across independent workbook sources where available
- Personalkosten and REB control-source extraction regression bugs fixed
- Secure backup format round-trip tested: PBKDF2-SHA256 + AES-GCM-256; wrong password rejected
- Benchmark cohort logic tested with 5 independent imported site tokens; own site excluded
- No private regression workbook or named real site/user is included in the package

## Prepared, but requires an external system before it can be live
- Server-side authentication and tamper-proof authorization/RLS
- Cloud synchronization across devices
- Approved WISAG/ERP/finance source connector credentials
- Real external benchmark cohort from participating sites
- Real pilot evidence from independent operating sites

See `docs/SECURITY_PRIVACY_V7_1.md`, `docs/INTEGRATION_CONTRACT_V1.md` and `backend/supabase_schema.sql` for the prepared production path.
