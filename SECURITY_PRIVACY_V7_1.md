# MetriQ V7.1 – Security & Privacy Boundary

## Active today in the static PWA

- XLSX files are parsed in the browser. For `.xlsx`, V7.1 contains its own local ZIP/XML reader and does not need to upload the workbook.
- No MetriQ analytics/tracking telemetry is included.
- Local roles actually gate views/actions inside the PWA, but are not tamper-proof against a technically capable device user.
- Sites are logically separated in local state (pilot-grade multi-tenancy).
- Audit events are recorded locally for relevant actions.
- Backups may be encrypted with PBKDF2-SHA256 + AES-GCM-256 before download.
- Local data can be deleted from the app.
- Benchmark exchange contains anonymized KPIs only.

## Requires a real backend before enterprise rollout

- authenticated users and password/account lifecycle
- server-enforced role permissions
- PostgreSQL row-level security / tenant isolation
- central encrypted database and backups
- append-only server audit trail
- retention/deletion workflows across all devices
- AV/DPA, TOMs, hosting/region decision and DPO review
- monitored API gateway for WISAG and other corporate systems

`backend/supabase_schema.sql` is a blueprint for this transition; it is intentionally not auto-connected without project credentials and IT approval.
