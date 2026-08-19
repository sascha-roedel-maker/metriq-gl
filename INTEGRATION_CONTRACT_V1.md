# MetriQ Integration Contract V1

MetriQ V7.1 treats every external data source as an adapter. The UI must not know whether data came from local FLOSIQ storage, a WISAG export, an API or a future cloud database.

## Standard event envelope

```json
{
  "schema": "iq-versum-event-v1",
  "source": "flosiq|wisag|safetiq|prophetiq|eventiq|teamiq",
  "organizationId": "opaque-id",
  "siteId": "opaque-id",
  "eventId": "source-unique-id",
  "occurredAt": "2026-08-19T11:00:00Z",
  "type": "meal.count|waste.entry|month.close|temperature.check|event.booking",
  "payload": {}
}
```

## FLOSIQ adapter

Minimum monthly outputs expected by MetriQ:

```json
{
  "monthKey": "2026-08",
  "meals": 812,
  "wasteKg": 61.4,
  "foodLossGramsPerMeal": 75.6,
  "rescues": 9,
  "categories": {
    "plate": 22.1,
    "prep": 8.3,
    "overproduction": 27.0,
    "storage": 4.0
  }
}
```

V7.1 already reads the known FLOSIQ browser keys when both apps share the same origin. A later cloud adapter should produce the same normalized shape, so no dashboard rewrite is required.

## WISAG / finance adapter

A connector may provide an original Excel file or an already normalized month-close payload. Original files must still pass the MetriQ Deep Scan evidence checks before a month is marked verified.

Required normalized core:

```json
{
  "monthKey": "2026-02",
  "revenue": 33957.94,
  "wareFood": 14330.25,
  "wareNonFood": 379.89,
  "personal": 14784.13,
  "sach": 2094.51,
  "totalCosts": 31588.78,
  "db1": 2369.16,
  "meals": 656
}
```

## Rules

1. External values are never considered verified merely because an API supplied them.
2. Every month-close keeps provenance (source names) and the scan version.
3. Duplicate integration events are rejected by `source + external_event_id`.
4. Customer names, suppliers and individual bookings are excluded from anonymized benchmark packages.
5. Credentials must never be hard-coded into the GitHub Pages frontend.
