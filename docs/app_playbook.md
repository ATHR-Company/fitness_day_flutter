# App Playbook — Validation, Offline, and Activity Tracking

Extracted from the Fitness Day Flutter app so the same decisions can be reused
elsewhere. Every rule and number here is what the code actually does, not a
recommendation written after the fact — each section names the file it came
from so you can read the original.

Three parts:

1. [Field validation](#1-field-validation)
2. [What happens when the network drops](#2-what-happens-when-the-network-drops)
3. [Walking and running tracking](#3-walking-and-running-tracking)

---

## 1. Field validation

### 1.1 The single rule that matters

**Every rule lives in one file.** `lib/core/utils/validators.dart` holds them
all; no screen writes its own `validator:` body.

This is not tidiness. The password rule had been re-typed in five screens, and
**every copy allowed a password made entirely of spaces** — `"      "` is not
empty, so an `isEmpty` check passes it, and six spaces even clear a
six-character minimum. One shared rule can only be wrong once.

### 1.2 Password

| Check | Why it exists separately |
|---|---|
| `value == null \|\| value.isEmpty` | Nothing typed |
| `value.trim().isEmpty` | **Its own line.** Whitespace-only is not empty, and it must not reach the server |
| `value.length < minLength` (default 6) | Length is measured on the **raw** value, not the trimmed one — a password may legitimately contain spaces |

**Sign-in uses a different rule.** `AppValidators.loginPassword` deliberately
does *not* enforce the minimum length: an account created before the rule
existed still has to be able to log in, and telling someone their *existing*
password is too short helps nobody. Enforce minimums where a password is
**created**, never where one is **entered**.

```dart
static String? password(String? value, {int minLength = 6});
static String? loginPassword(String? value);      // no length check
static String? confirmPassword(String? value, String original);
```

### 1.3 Names

```dart
static const int minNameLength = 2;   // mirrors what the backend accepts
```

Trim first, then check. The constant mirrors the backend's own minimum, so a
name the server would reject never leaves the device.

### 1.4 Numbers — weight, height, and anything measured

This is the part most apps get wrong, and it has three separate problems.

**Problem 1 — Arabic keyboards.** A user typing on an Arabic keyboard produces
`٧٠٫٥`, not `70.5`. `double.tryParse` returns null for it, so the field looks
broken to exactly the users the app is built for.

`Measurement.toAscii` rewrites, in one pass:
- Arabic-Indic digits `٠١٢٣٤٥٦٧٨٩` → `0123456789`
- Extended Arabic-Indic `۰۱۲۳۴۵۶۷۸۹` → `0123456789`
- `,` and the Arabic decimal separator `٫` → `.`

> ⚠️ We have seen a **password** sent to the backend as `١٢٣٤٥٦`. Passwords are
> not run through this normaliser on purpose — but be aware that a user who
> registers with Arabic digits and later logs in with Latin ones will not match.
> Decide this deliberately for your app.

**Problem 2 — precision.** The backend echoes back whatever float it computed,
so a weight comes back as `50.066556668568886`. Two constants fix it:

```dart
static const int decimals = 2;
static double round(double value);      // what gets stored
static String format(num value);        // what gets shown
```

`format` also drops trailing zeros — `155.00 cm` reads as a measurement taken to
the hundredth of a centimetre, which it is not. So `155.0 → "155"`,
`50.066556668568886 → "50.07"`.

**Problem 3 — range.** A typo is not a person.

| Field | Min | Max |
|---|---|---|
| Weight (kg) | 20 | 200 |
| Height (cm) | 50 | 280 |

These mirror the bounds of the sign-up wheel pickers exactly, so a value the
picker can produce is never rejected by the validator on a later edit. **If you
have both a picker and a typed field, their ranges must be the same constant.**

**Parsing tolerates a trailing unit.** `parse("70.5 كجم")` works — it strips
everything that is not a digit or a dot after normalising.

### 1.5 Format on input, not after

`DecimalInputFormatter` (`lib/core/utils/decimal_input_formatter.dart`) keeps
the field in a state that is *always parseable* instead of validating later:

- Arabic digits and commas rewritten to ASCII as they are typed
- Everything that is not a digit or a dot dropped
- Only the first dot survives
- At most `decimalRange` digits after the dot (default 2), `maxIntegerDigits`
  before (default 3)
- A **leading** dot is rejected — `.5` is easier to prevent than to explain

It also preserves the caret: it counts how many characters survived *before*
the cursor and puts the cursor back there, so typing in the middle of a number
does not jump you to the end.

```dart
TextField(
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [DecimalInputFormatter()],
)
```

### 1.6 Phone numbers

Handled by `AppPhoneField`, which:
- strips leading zeros (`01014773266` → `1014773266`) so the country code is
  not doubled up
- validates against a **per-country required digit count**, not a global one
- composes with an optional caller-supplied `validator` rather than replacing it

### 1.7 Validate the whole form in one pass

`visit_details_page.dart` shows the pattern for a multi-field form. The API
reports **one** rejected field per response, so saving a form with several
blanks meant: fix one, save, be told about the next, round-trip again.

Instead, declare the fields once as data:

```dart
late final List<({String key, TextEditingController controller,
                 String? Function(String) rule})> _reportFields = [
  (key: 'WEIGHT', controller: _weightController, rule: AppValidators.weight),
  (key: 'HEIGHT', controller: _heightController, rule: AppValidators.height),
  // …
];

Map<String, String> _validateReport() {
  final errors = <String, String>{};
  for (final field in _reportFields) {
    final error = field.rule(field.controller.text);
    if (error != null) errors[field.key] = error;
  }
  return errors;   // every offending field, before anything is sent
}
```

Two more things fall out of it for free:
- **Editing a field clears its message.** A listener per controller removes the
  error on the first keystroke, so a corrected value stops showing the reason it
  was rejected.
- **The same list picks which field to scroll to.**

### 1.8 Server-side rejections belong under the field

A backend `400` that names the offending field carries it in `key`. That is
mapped to `AppErrorType.validation` with a `fieldKey`, so the screen can pin the
message **under the input** instead of in a snackbar over a screen the user has
already left.

The dialog pattern (`EditFieldDialog`, `AddGoalDialog`):

```dart
// null = it went through, close.  Anything else = pin it and stay open.
final Future<String?> Function(String) onSave;
```

Keeping the dialog open with the text still in it is the whole point — a
rejected value the user can no longer see is a value they have to retype.

---

## 2. What happens when the network drops

### 2.1 Two different questions, two different answers

This is the distinction to copy:

| Question | Answered by | Used for |
|---|---|---|
| "Does the device have a network interface?" | `ConnectivityService` (connectivity_plus) | The **banner** |
| "Did *this request* fail because of the network?" | `NetworkFailure` from `ErrorHandler` | The **screen** |

`connectivity_plus` reports the interface (wifi / mobile / none), **not whether
the internet is reachable**. A phone connected to a captive-portal wifi is
"online" and every request still fails. So the banner is a hint, and a failed
request stays the source of truth per screen.

### 2.2 The banner

`OfflineBanner` wraps the whole app once at the root
(`MaterialApp.router(builder: …)`), plus `HomeConnectivityBanner` for an inline
one inside a scroll body.

Behaviour worth copying:
- Slides down when the connection drops
- Flashes a **green "back online"** bar on reconnect, then removes itself after
  **2 seconds** — a state that fixed itself should not need dismissing
- Collapses to **zero height** when neither offline nor reconnecting, so it
  takes no space in the layout
- **Swallows platform errors.** The plugin's channel can be unavailable before a
  full rebuild, or on unsupported platforms. A connectivity hiccup must never
  crash the app — the banner just stays hidden
- `isOnline` **assumes online** when it cannot tell, so the UI is never blocked
  by a false negative

### 2.3 Typed failures

```dart
ServerFailure      // the backend answered and refused
NetworkFailure     // no connection / timeout — the request never landed
CacheFailure       // local storage
ValidationFailure  // a ServerFailure that named the field it rejected
```

`ErrorHandler.handle(dioException)` maps transport exceptions to these. Every
message is **localized at the source**, because the raw `failure.message`
reaches the screen in most places — hardcoded Arabic strings meant an
English-locale user saw Arabic error text. The backend's own `message` is never
translated: it arrives in the language named by the `lang` header.

### 2.4 How a screen presents it

Cubits carry an `AppError` alongside the message, because storing only
`failure.message` throws away the *kind* of failure and every error then looks
the same:

```dart
case FailureResult(:final failure):
  emit(XFailure(failure.message, error: AppError.from(failure)));
```

Then the screen picks the presentation:

| Situation | Widget | Behaviour |
|---|---|---|
| Screen has **no content** — first load failed | `AppErrorView` | Full-screen takeover |
| Screen **already has content** | `showAppError` | Transient message; the user keeps what they were reading |

`AppErrorView` adapts to the type:
- **Network** → offline artwork, a Retry button, and *no explanation*, because
  there is nothing to say
- **Server** → the backend's own message, which is usually the actionable part

It is built inside a `SingleChildScrollView` with
`AlwaysScrollableScrollPhysics` so it still works as a `RefreshIndicator` child
— **pull-to-refresh has to keep working on a screen that failed to load.**

### 2.5 Writes that fail must not be silently dropped

For anything that pushes a delta (activity progress, sync), a failed request is
**queued, not folded into the next payload**:

- Each attempt carries a **UUID v4 `syncId`**
- A retry resends the *same* payload with the *same* `syncId`, byte for byte
- The server recognises a repeat and applies it once

Merging two failed deltas into one loses the idempotency key, and a request that
*did* reach the server but lost its response gets counted twice. A flaky network
then silently inflates the user's numbers.

Queue rules used here:
- Serialised — one request in flight at a time, or responses arrive out of order
- Failure leaves the item at the **head** of the queue; the next delta retries it
- Bounded (200 items). When full, drop the **oldest** — recent progress is what
  the user is looking at

### 2.6 Session loss is not a network error

Worth separating: a `401` carrying `key: "session_revoked"` means the session
itself is gone (the account signed in on another device), and refreshing the
token would only ask the server to say no again. Match on the **`key`**, never
on the message — the message is localized and free to be reworded.

---

## 3. Walking and running tracking

Two cubits, deliberately different, because the two activities fail in different
ways. `walking_cubit.dart` and `running_cubit.dart`.

### 3.1 Walking: two step sources, because neither is reliable alone

| Source | Strength | Weakness |
|---|---|---|
| **Health store** (Health Connect / HealthKit) | Platform's own filtering — trustworthy counts | Writes in **batches**. On some devices (notably MIUI) it does not flush for minutes; a whole walk passes with the reading frozen |
| **Hardware pedometer** | Immediate | Unfiltered — a shaken hand counts as steps |

Both are monotonic within a session, so the session total is simply **whichever
is further along**:

```dart
int get _sessionSteps => math.max(_healthSessionSteps, _pedometerSessionSteps);
```

That keeps the count live *and* lets the health store's higher figure win once
it finally catches up.

### 3.2 The cadence filter — a token bucket

The pedometer needs filtering or a shaken phone racks up steps. A hand shaken
back and forth sits at **2–4 Hz**, which is why a naive 3.5 steps/sec ceiling
let it through untouched.

```dart
static const double _kMaxStepsPerSecond = 2.5;  // a brisk walk is ~2/s
static const double _kMaxStepBurst      = 10;   // idle time can't bank a burst
static const int    _kMaxPendingSteps   = 60;   // queue for batched events
```

How it works:
- Allowance accrues at 2.5 steps/second, capped at 10 so standing still cannot
  bank credit to spend in one burst
- Android batches step events for power, so **one event can carry twenty-odd
  steps**. Discarding the surplus lost real steps on every batch — instead the
  overflow is **queued** (`_pendingRawSteps`) and paid off by the next
  allowance tick
- The queue is capped at 60: long enough for any plausible batch, short enough
  that a backlog cannot be cashed as one implausible burst

### 3.3 Distance

**Walking** prefers the health store, but plenty of devices never write a
distance record at all — `DISTANCE_DELTA` comes back empty and the walk reports
a flat 0 no matter how far the user went. So:

```
distance = max(healthStoreDistance, steps × strideMetres)
```

with `_kStrideMetres = 0.75` for walking, `1.0` for running. Taking the larger
keeps distance moving whenever steps are being counted, and lets the health
store win once it reports.

**Running** uses GPS, with three gates:

```dart
static const double _kMaxAcceptableAccuracyMeters = 25;   // drop bad fixes
static const double _kMinMovingSpeedMps           = 0.5;  // evidence of movement
// plus: ignore any single jump > 150 m as a bad fix
LocationSettings(accuracy: high, distanceFilter: 5)
```

Two subtleties that cost real debugging:

1. **A rejected fix must not become the new anchor.** Making a fix you do not
   trust the reference point for the next measurement folds its own error
   straight into the distance.
2. **When movement is not proven, hold the anchor — do not advance it.** Each
   fix arrives ~5 m after the last, so a single hop can never exceed a 10–25 m
   accuracy circle. Re-anchoring every time meant the displacement test
   restarted forever and devices that report no speed accumulated *nothing*.
   Keeping the anchor lets successive hops add up until they clear the circle.

Movement is proven by **either** test — a reported speed above the threshold,
**or** a displacement larger than the fix's own error circle. The second covers
devices that never report a usable speed.

### 3.4 The clock is derived, never accumulated

```dart
elapsed = now - _sessionStartedAt
```

Never `elapsed++` on a timer tick. Time spent with the app backgrounded still
counts, and a missed tick cannot drift.

### 3.5 Reporting cadence

| | Walking | Running |
|---|---|---|
| Trigger | Poll every **15 s** | Every **5 m** of distance (`_kSyncThresholdKm = 0.005`) |
| Payload | Delta since last acknowledged sync | Same |

**Always send deltas, never totals.** The server applies them with `$inc`, so a
cumulative total compounds:

| Scenario | Correct | Wrong |
|---|---|---|
| 200 steps, then 300 more | send `200`, then `300` | send `200`, then `500` |

### 3.6 Baselines are session-relative

Nothing is persisted. Both cubits reset their sent-so-far counters on every
`startTracking` and re-baseline against the current health reading, so steps
already sent can never be sent again.

> ⚠️ **Know the limit of this.** It means the app only counts what happens
> **during an explicit tracking session the user starts and stops.** Steps taken
> with the tracker off are never counted. If your app needs whole-day passive
> counting — for badges like "10,000 steps in a day" — you need a persisted
> `dayKey → lastSyncedSteps` baseline and background read permissions. That is a
> different product, and a bigger one.

### 3.7 Permissions

Android needs Health Connect **installed** before permissions can even be
requested, so the flow has three states, not two:

```dart
enum HealthPermStatus { needsInstall, denied, granted }
```

Check the existing status **without prompting** when the screen opens
(`refreshPermissionStatus`), or the permission banner reappears every time for a
user who already granted access.

`minSdk = 26` — Health Connect requires API 26+.

---

## Quick checklist for the new app

- [ ] One validators file. No screen writes its own rule.
- [ ] Whitespace-only checked separately from empty.
- [ ] Minimum length enforced on **create**, not on **sign-in**.
- [ ] Arabic-Indic digits and `٫` normalised before parsing any number.
- [ ] Picker range and validator range are the same constant.
- [ ] Decimal fields use an input formatter, not after-the-fact validation.
- [ ] Whole form validated in one pass; server field errors pinned under the input.
- [ ] Banner from connectivity, per-screen errors from typed failures — not the same source.
- [ ] `AppErrorView` scrollable so pull-to-refresh survives a failed load.
- [ ] Every write delta carries a UUID; retries reuse it.
- [ ] Two step sources, `max()` of both, token-bucket cadence filter.
- [ ] GPS: reject bad fixes **without** advancing the anchor.
- [ ] Elapsed time derived from a start timestamp, never accumulated.
