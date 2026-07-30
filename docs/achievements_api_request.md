# Achievements API — Backend Request

**Audience:** Backend team (NestJS / Fitness Day server)  
**Author:** Mobile team  
**Status:** Request — endpoint does not exist yet. The screen is built and currently runs on **mock data only**.  
**Base URL:** `https://fitnessday.tech/api`

---

## 1. What the screen needs

The achievements screen has three parts:

| # | Part | What it needs from the API |
|---|---|---|
| 1 | **Week navigator** header — "‹ 25 Jul – 31 Jul ›" | The `from` / `to` echoed back |
| 2 | **7-day calendar strip** — same widget as visit log | `days[]` with a `count` per day |
| 3 | **Achievement list** — image + title + description per row | `achievements[]` |

The user navigates one week at a time (prev/next). The app re-fetches on every week change and on every screen open. Nothing is cached across sessions.

---

## 2. Common conventions

All endpoints follow the standard envelope:

```json
{
  "success": true,
  "statusCode": 200,
  "message": "تم جلب البيانات بنجاح.",
  "data": { ... }
}
```

**Headers the app sends:**

```
Authorization: Bearer <accessToken>
Content-Type: application/json
lang: ar          // or "en"
```

**Translation rule:** `title`, `description`, and `message` must arrive **already translated** to the `lang` header value. The app stores no achievement text — new achievements added from the dashboard must appear without a mobile release.

**Empty ≠ error:** A week with no achievements returns `200` with empty `days[]` (all zeros) and `achievements: []`. Never `404`.

**Auth gate:** If the user's profile is incomplete, return the same `403 messages.dataIncomplete` used elsewhere and the app will show your message.

---

## 3. `GET /achievements`

### Request

```
GET /achievements?from=2026-07-25&to=2026-07-31
```

#### Query parameters

| Param | Required | Format | Notes |
|---|---|---|---|
| `from` | ✅ | `YYYY-MM-DD` | First day of range, **inclusive** |
| `to` | ✅ | `YYYY-MM-DD` | Last day of range, **inclusive** |
| `page` | ❌ | int ≥ 1, default `1` | For long lists |
| `limit` | ❌ | int, default `50` | For long lists |

> The app currently sends a 7-day range. **Do not hardcode 7** — the range will be widened to a month in a future screen with no backend change.  
> If you prefer `weekStartFrom` / `weekStartTo` to match the visit-log endpoint naming, say so and we will switch — the shape is identical either way.

---

### Response

```json
{
  "success": true,
  "statusCode": 200,
  "message": "تم جلب الإنجازات بنجاح.",
  "data": {
    "from": "2026-07-25",
    "to": "2026-07-31",
    "totalCount": 3,
    "days": [
      { "date": "2026-07-25", "count": 0 },
      { "date": "2026-07-26", "count": 0 },
      { "date": "2026-07-27", "count": 0 },
      { "date": "2026-07-28", "count": 1 },
      { "date": "2026-07-29", "count": 1 },
      { "date": "2026-07-30", "count": 1 },
      { "date": "2026-07-31", "count": 0 }
    ],
    "achievements": [
      {
        "id": "6a6b0e5327e5f1b3076e5911",
        "code": "HYDRATION_HERO",
        "title": "بطل الترطيب",
        "description": "التزمت بشرب كمية الماء اليومية لمدة أسبوع.",
        "imageUrl": "achievements/hydration-hero.png",
        "unlockedAt": "2026-07-30T08:41:54.403Z",
        "date": "2026-07-30"
      },
      {
        "id": "6a6b0e5327e5f1b3076e5912",
        "code": "STEPS_KING",
        "title": "ملك الخطوات",
        "description": "أكملت 10,000 خطوة في يوم واحد.",
        "imageUrl": "achievements/steps-king.png",
        "unlockedAt": "2026-07-29T19:02:11.000Z",
        "date": "2026-07-29"
      },
      {
        "id": "6a6b0e5327e5f1b3076e5913",
        "code": "CONSISTENCY",
        "title": "الاستمرارية",
        "description": "التزمت بالتمرين أو النشاط لمدة 7 أيام متتالية.",
        "imageUrl": "achievements/consistency.png",
        "unlockedAt": "2026-07-28T06:00:00.000Z",
        "date": "2026-07-28"
      }
    ]
  }
}
```

---

### `days[]` spec

Return **every calendar day** in `[from, to]`, in ascending order, including days with `count: 0`. The strip never fills gaps or guesses.

| Field | Type | Use |
|---|---|---|
| `date` | `YYYY-MM-DD` string | matched against the calendar cell |
| `count` | int ≥ 0 | `0` = plain cell; `> 0` = green tint + dot |

---

### `achievements[]` spec

| Field | Required | Type | Use |
|---|---|---|---|
| `id` | ✅ | string | list key (unique per unlock) |
| `code` | ✅ | string | stable machine name — used for analytics and local icon fallback |
| `title` | ✅ | string | row title, already translated |
| `description` | ✅ | string | row subtitle, already translated |
| `imageUrl` | ✅ | string \| null | row icon — see §4 |
| `unlockedAt` | ✅ | ISO-8601 UTC | used for sort order |
| `date` | ✅ | `YYYY-MM-DD` | which calendar day this belongs to |

**Why both `unlockedAt` and `date`?**  
The calendar strip matches on a plain date string. Deriving a local date from `unlockedAt` in the app reintroduces timezone bugs. Send both and we never need to convert.

**Sort order:** newest first (`unlockedAt` descending). Tell us if you prefer a different order.

---

## 4. Image spec

`imageUrl` may be:

- **Absolute URL** — `https://fitnessday.tech/uploads/achievements/hydration-hero.png`
- **Relative path** — `achievements/hydration-hero.png` (resolved against `https://fitnessday.tech/uploads`)

The app already handles both via `ApiEndpoints.resolveMediaUrl`. Pick one and stay consistent.

**Asset requirements:**

| Property | Requirement |
|---|---|
| Format | PNG or SVG |
| Shape | Square |
| Minimum size | 144 × 144 px (renders in a 48pt circle at 3× density) |
| Background | Transparent |
| Missing image | Send `null`, **not** an empty string or a broken path |

If `imageUrl` is `null`, the app falls back to a local icon matched on `code`. Mapping:

| `code` | Fallback icon |
|---|---|
| `HYDRATION_HERO` | water drop SVG |
| `STEPS_KING` | footsteps SVG |
| `MONTH_HERO` | trophy SVG |
| `CONSISTENCY` | target / checkmark SVG |

---

## 5. Achievement catalog (seed list)

These are the four achievements currently mocked in the app. Treat them as a starting seed — you can add more from the dashboard without a mobile release.

### `HYDRATION_HERO` — بطل الترطيب

| | Arabic | English |
|---|---|---|
| **Title** | بطل الترطيب | Hydration Hero |
| **Description** | التزمت بشرب كمية الماء اليومية لمدة أسبوع. | Committed to drinking the daily water amount for a week. |
| **Image** | `achievements/hydration-hero.png` | same file |
| **Unlock rule** | User hits their daily water goal 7 consecutive days | same |

**Suggested image:** a water droplet or glass icon on a green circular background.

---

### `STEPS_KING` — ملك الخطوات

| | Arabic | English |
|---|---|---|
| **Title** | ملك الخطوات | Steps King |
| **Description** | أكملت 10,000 خطوة في يوم واحد. | Completed 10,000 steps in a single day. |
| **Image** | `achievements/steps-king.png` | same file |
| **Unlock rule** | User logs ≥ 10,000 steps on any single day | same |

**Suggested image:** running figure or footprints icon on a green circular background.

---

### `MONTH_HERO` — بطل الشهر

| | Arabic | English |
|---|---|---|
| **Title** | بطل الشهر | Month Hero |
| **Description** | كنت من أكثر المستخدمين نشاطاً هذا الشهر. | You were the most active user this month. |
| **Image** | `achievements/month-hero.png` | same file |
| **Unlock rule** | User ranks in top-N most active users for a calendar month (define N) | same |

**Suggested image:** gold crown or medal icon on a green circular background.

---

### `CONSISTENCY` — الاستمرارية

| | Arabic | English |
|---|---|---|
| **Title** | الاستمرارية | Consistency |
| **Description** | التزمت بالتمرين أو النشاط لمدة 7 أيام متتالية. | Committed to exercise or activity for 7 consecutive days. |
| **Image** | `achievements/consistency.png` | same file |
| **Unlock rule** | User completes at least one activity or workout on 7 consecutive calendar days | same |

**Suggested image:** circular arrow or calendar checkmark icon on a green circular background.

---

## 6. Optional: `GET /achievements/catalog`

Not required for the current screen. If you want to show users locked achievements with progress, add this later:

```
GET /achievements/catalog
```

```json
{
  "data": [
    {
      "id": "...",
      "code": "STEPS_KING",
      "title": "ملك الخطوات",
      "description": "أكملت 10,000 خطوة في يوم واحد.",
      "imageUrl": "achievements/steps-king.png",
      "isUnlocked": false,
      "unlockedAt": null,
      "progressPercentage": 40
    }
  ]
}
```

**Clamp `progressPercentage` to `0–100` server-side.** We will not rebuild it on the device.  
We will not build UI for this until you confirm it exists.

---

## 7. Rules the app depends on

| Rule | Detail |
|---|---|
| **UTC day** | `date` is a plain `YYYY-MM-DD` string. A day is a UTC day, same as check-in. We parse it as a string and never convert via local timezone. |
| **No client-side logic** | The app does not evaluate unlock conditions, count steps, or decide which day an achievement belongs to. It renders `days[]` and `achievements[]` as received. |
| **No session cache** | The app refetches on every screen open and every week change. No invalidation signals needed. |
| **Empty = 200** | A range with no achievements returns `200`, not `404`. Empty `days[]` (all zeros) and `achievements: []`. |
| **Profile gate** | If profile is incomplete, return `403` with a translated `message`. The app shows it verbatim. |

---

## 8. Open questions — please answer before implementation

1. **Param naming** — `from` / `to` or `weekStartFrom` / `weekStartTo` to match visit log?
2. **Max range** — is there a server-side cap (e.g. 31 days)? If yes, what error code and message?
3. **Repeatable achievements** — can `STEPS_KING` unlock on two different days (two rows, same `code`, different `date` and `id`)? We key the list on `id` either way, but we need to know.
4. **Locked achievements in main list** — does `GET /achievements` return **only unlocked** ones, or also locked with a flag? Our assumption: **only unlocked**. §6 covers the rest.
5. **Push notification on unlock** — do you want to send one? Not required for the screen — it refetches on open regardless.

---

## 9. Endpoint summary

| Method | Path | Auth | Query | Status |
|---|---|---|---|---|
| `GET` | `/achievements` | user JWT | `from`, `to`, `page`?, `limit`? | **needed** |
| `GET` | `/achievements/catalog` | user JWT | — | optional, §6 |
