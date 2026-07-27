# 🔌 دليل ربط الشات المباشر عبر Socket.IO و REST API في Flutter

دليل مرجعي شامل لتطبيق **Fitness Day Flutter** يبسط ويشرح كل ما يتعلق بتقنية **Socket.IO**، هندسة الشات (Clean Architecture)، وطريقة الربط بين الـ REST APIs والـ Real-time Events.

---

## 📚 فهرس المحتويات
1. [مقدمة: إيه هو Socket.IO وليه بنستخدمه؟](#1-مقدمة-إيه-هو-socketio-وليه-بنستخدمه)
2. [هيكلية المشروع (Clean Architecture)](#2-هيكلية-المشروع-clean-architecture)
3. [الـ REST APIs والـ Socket Events](#3-الـ-rest-apis-والـ-socket-events)
4. [شرح الطبقات والمكونات بالتفصيل](#4-شرح-الطبقات-والمكونات-بالتفصيل)
   - [أولاً: SocketService (الـ Core)](#أولاً-socketservice-الـ-core)
   - [ثانياً: الـ Models والـ Entities](#ثانياً-الـ-models-والـ-entities)
   - [ثالثاً: الـ REST Data Source والـ Repository](#ثالثاً-الـ-rest-data-source-والـ-repository)
   - [رابعاً: إدارة الحالة (ChatCubit, ConversationsCubit, ContactUsCubit)](#رابعاً-إدارة-الحالة)
   - [خامساً: الـ UI (شاشة الشات وشاشة المحادثات وشاشة تواصل معنا)](#خامساً-الـ-ui)
5. [الاتصال التلقائي عند فتح التطبيق](#5-الاتصال-التلقائي-عند-فتح-التطبيق)
6. [الـ UI/UX وإعادة تصميم فقاعات الشات (WhatsApp Style)](#6-الـ-uiux-وإعادة-تصميم-فقاعات-الشات-whatsapp-style)
7. [دعم الـ Specialist Mode (جديد)](#7-دعم-الـ-specialist-mode)
8. [نظام الـ Shimmer Loading](#8-نظام-الـ-shimmer-loading)

---

## 1. 💡 مقدمة: إيه هو Socket.IO وليه بنستخدمه؟

### ❌ المشكلة في الـ REST API العادي (HTTP Polling):
في تطبيقات الشات التقليدية التي تعتمد على HTTP فقط:
- الكلاينت (التطبيق) يستمر في سؤال السيرفر كل 3 أو 5 ثوانٍ: *"هل هناك رسائل جديدة؟"*
- هذا يسبب استهلاكاً عالياً للبطارية والإنترنت وضغطاً كبيراً على السيرفر (Overhead).

### 🟢 الحل عبر Socket.IO (WebSocket):
- يتم فتح قناة اتصال **مزدوجة مستمرة (Full-Duplex Persistent Connection)** بين الكلاينت والسيرفر على البروتوكول `wss://` أو `https://`.
- عندما يرسل الطرف الآخر رسالة، يقوم السيرفر **بدفعها فوراً (Push)** إلى هاتفك دون أن تطلبها.

```
Client ════════════ [قناة اتصال مفتوحة ومستمرة] ════════════ Server
  │                                                              │
  ├─── إرسال حدث chat:send ─────────────────────────────────────►│
  │                                                              │
  │◄── استقبال حدث chat:message (لحظياً) ─────────────────────────┤
```

---

## 2. 🏗️ هيكلية المشروع (Clean Architecture)

تم تقسيم ميزة الشات في تطبيق **Fitness Day** باتباع مبادئ Clean Architecture:

```
lib/
├── core/
│   ├── services/
│   │   └── socket_service.dart                  ← [Singleton] خدمة اتصال الـ Socket
│   └── constant/
│       └── api_endpoints.dart                   ← العناوين والروابط (user + specialist)
│
└── features/
    ├── shared/conversations/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── chat_remote_datasource.dart  ← جلب البيانات عبر REST (user + specialist)
    │   │   └── models/
    │   │       ├── message_model.dart            ← تحويل JSON الرسائل
    │   │       └── user_conversation_model.dart  ← تحويل JSON المحادثات
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── chat_message.dart             ← كائن الرسالة النقي (Pure Dart)
    │   │   ├── repositories/
    │   │   │   └── chat_repository.dart          ← العقد Interface
    │   │   └── usecases/
    │   │       ├── — User Side —
    │   │       ├── open_chat_usecase.dart         ← POST /chat/open
    │   │       ├── get_messages_usecase.dart      ← GET /chat/:id/messages
    │   │       ├── get_user_chat_usecase.dart     ← GET /chat
    │   │       ├── send_media_usecase.dart        ← POST /chat/:id/media
    │   │       ├── — Specialist Side —
    │   │       ├── get_specialist_chats_usecase.dart    ← GET /specialist/chat
    │   │       ├── open_specialist_chat_usecase.dart    ← POST /specialist/chat/:userId/open
    │   │       ├── get_specialist_messages_usecase.dart ← GET /specialist/chat/:id/messages
    │   │       └── send_specialist_media_usecase.dart   ← POST /specialist/chat/:id/media
    │   └── presentation/
    │       ├── manager/
    │       │   ├── chat_cubit.dart               ← إدارة حالة الشات (user + specialist)
    │       │   ├── chat_state.dart               ← حالات الشات
    │       │   ├── conversations_cubit.dart       ← إدارة قائمة محادثات الـ Specialist
    │       │   └── conversations_state.dart       ← حالات قائمة المحادثات
    │       ├── pages/
    │       │   ├── chat_details_page.dart         ← واجهة الشات على نمط الواتساب
    │       │   └── conversations_page.dart        ← قائمة محادثات الـ Specialist
    │       └── widgets/
    │           ├── conversations_shimmer_loading.dart ← Shimmer لقائمة المحادثات
    │           └── contact_us_shimmer.dart            ← Shimmer لصفحة تواصل معنا
    │
    └── user/support/
        └── presentation/
            ├── manager/
            │   ├── contact_us_cubit.dart          ← إدارة حالة شاشة تواصل معنا
            │   └── contact_us_state.dart
            └── pages/
                └── contact_us_page.dart           ← شاشة تواصل معنا
```

---

## 3. 🌐 الـ REST APIs والـ Socket Events

### 📡 الـ REST API Endpoints:

#### 👤 User Side:
| الميثود | الـ Endpoint | الوصف |
|--------|-------------|-------|
| `GET` | `/api/chat` | جلب محادثة المستخدم الحالية مع بيانات الأخصائي |
| `POST` | `/api/chat/open` | فتح/إنشاء غرفة محادثة بـ `specialistId` |
| `GET` | `/api/chat/:id/messages` | جلب الرسائل السابقة |
| `POST` | `/api/chat/:id/media` | رفع ميديا (صور/صوت) |

#### 👨‍⚕️ Specialist Side:
| الميثود | الـ Endpoint | الوصف |
|--------|-------------|-------|
| `GET` | `/api/specialist/chat` | جلب كل محادثات الأخصائي مع عملائه |
| `POST` | `/api/specialist/chat/:userId/open` | فتح/إنشاء محادثة مع عميل معين |
| `GET` | `/api/specialist/chat/:id/messages` | جلب رسائل محادثة معينة |
| `POST` | `/api/specialist/chat/:id/media` | رفع ميديا (صور/صوت) |

### ⚡ الـ Socket.IO Events:
- **رابط الاتصال**: `https://fitnessday.tech` (بدون `/api`).
- **التحقق من الهوية (Authentication)**: يتم إرسال الـ JWT Token في الـ `auth` option عند الاتصال.

| الحدث | الاتجاه | البيانات |
|-------|---------|---------|
| `chat:send` | Client ➔ Server | `{ conversationId, text }` |
| `chat:message` | Server ➔ Client | كائن الرسالة الكاملة (server echo) |
| `chat:typing` | الاتجاهان | `{ conversationId, isTyping }` |
| `chat:read` | Client ➔ Server | `{ conversationId }` |
| `chat:delivered` | Server ➔ Client | `{ messageId }` — تأكيد استلام الطرف الآخر |

---

## 4. ⚙️ شرح الطبقات والمكونات بالتفصيل

### أولاً: `SocketService` (`core/services/socket_service.dart`)
تم تسجيله كـ **`LazySingleton`** ليكون هناك اتصال واحد فقط طوال فترة تشغيل التطبيق.
- `connect(token)`: تفتح الاتصال وتبث التوكن للسيرفر.
- `sendMessage()`: تبعث الحدث `chat:send`.
- `emitTyping()`: تبعث الحدث `chat:typing`.
- `emitRead()`: تبعث الحدث `chat:read`.
- `onMessageReceived()` & `onUserTyping()`: تستمع للأحداث القادمة من السيرفر.
- `onChatDelivered()`: تستمع لحدث `chat:delivered` لتحديث حالة الرسالة إلى `delivered`.

---

### ثانياً: الـ Models والـ Entities

#### `UserConversation.fromJson`:
تم تصميمه بشكل ذكي ليتعامل مع **ثلاث حالات**:
1. **محادثة مستخدم موجودة**: السيرفر يرسل الكائنات داخل كائن فرعي اسمه `"conversation"`.
2. **أخصائي مرتبط بدون محادثة**: الكائنات تأتي في الجذر مباشرة ويكون `conversationId == null`.
3. **محادثات الـ Specialist** (`GET /specialist/chat`): يعيد مصفوفة من المحادثات مباشرة في `data[]`.

#### `MessageModel.fromJson`:
يحول بيانات الرسالة من JSON إلى Entity سواء جاءت من REST API أو من Socket Event، ويحدد:
- `status`: `sent` / `delivered` / `seen` / `unknown`
- `isMine`: بناءً على حقل `senderType` (user أو specialist)
- `media`: قائمة بالملفات المرفقة (صور / صوت / ملفات)

---

### ثالثاً: الـ REST Data Source والـ Repository

`ChatRemoteDataSource` يحتوي على **8 دوال** مقسمة لـ:
- **User Side**: `getUserChat()`, `openChat()`, `getMessages()`, `sendMedia()`
- **Specialist Side**: `getSpecialistChats()`, `openSpecialistChat()`, `getSpecialistMessages()`, `sendSpecialistMedia()`

`ChatRepositoryImpl` ينفذ `ChatRepository` interface ويوفر الـ error handling الموحد عبر `ApiResult<T>`.

---

### رابعاً: إدارة الحالة

#### 🔄 سير العمل في `ChatCubit.openChat()`:

```
openChat(existingConversationId?, specialistId?, isSpecialistMode?)
         │
         ├── [conversationId موجود؟] ── نعم ──► GET messages مباشرة
         │
         └── [لا] ──► isSpecialistMode؟
                          │
                          ├── نعم ──► POST /specialist/chat/:userId/open
                          │
                          └── لا  ──► POST /chat/open
                                │
                             GET messages (specialist أو user endpoint)
                                │
                           emit ChatLoaded + connect Socket
                                │
                           emit chat:read
```

> **ملاحظة مهمة**: `isSpecialistMode` يُحدد الـ endpoint المستخدم في كل من فتح المحادثة، جلب الرسائل، ورفع الميديا.

#### `ConversationsCubit`:
مسؤول عن قائمة محادثات الـ Specialist.
- `fetchSpecialistConversations()`: يستدعي `GET /specialist/chat`.
- `searchConversations(query)`: فلترة محلية للقائمة حسب اسم العميل.
- يصدر: `ConversationsInitial` → `ConversationsLoading` → `ConversationsLoaded` / `ConversationsError`.

#### `ContactUsCubit`:
- فور فتح شاشة "تواصل معنا" يُشغّل `GET /chat`.
- لو الـ API أرجع `otherParty != null`: يظهر كارت الأخصائي.
- لو لم يرجع أي أخصائي: يختفي الكارت وتظهر بطاقة الـ AI فقط.
- عند العودة من الشات: يُعيد استدعاء `fetchUserChat()` تلقائياً لتحديث آخر رسالة.

---

### خامساً: الـ UI

#### `ChatDetailsPage`:
- الـ constructor يقبل `isSpecialistMode: bool` ويمررها لـ `ChatCubit.openChat()`.
- تُستخدم من **الطرفين** (User ومن Specialist).

#### `ConversationsPage`:
- تعرض قائمة محادثات الـ Specialist بيانات حقيقية من `GET /specialist/chat`.
- دعم **بحث** محلي في القائمة.
- تعرض **Shimmer Loading** أثناء التحميل.
- أيقونة دائرة خضراء صغيرة على الأفاتار تشير لحالة **الاتصال (online)** للعميل.
- عند الضغط على محادثة: تنتقل لـ `ChatDetailsPage` مع `isSpecialistMode: true`.

#### `ContactUsPage`:
- تعرض **Shimmer Loading** أثناء تحميل بيانات الأخصائي.

---

## 5. 🚀 الاتصال التلقائي عند فتح التطبيق

تم ربط الاتصال التلقائي للـ Socket عند إطلاق التطبيق في [main.dart](file:///d:/athr/fitness_day_flutter/lib/main.dart):

```dart
  await di.init();

  // اتصال الـ Socket فوراً إن كان المستخدم مسجلاً لدخوله بالـ Token
  _initSocketIfLoggedIn();
```

بهذا يكون الاتصال جاهزاً ومستقراً بمجرد أن يدخل المستخدم التطبيق وقبل أن يفتح شاشة الشات!

---

## 6. 🎨 الـ UI/UX وإعادة تصميم فقاعات الشات (WhatsApp Style)

تمت إعادة تصميم فقاعات الرسائل في `ChatDetailsPage` لتكون **مطابقة تماماً لأسلوب الواتساب الشهير**:

- **دعم اتجاه النص (RTL/LTR)**: يدعم اللغة العربية والإنجليزية بسلاسة.
- **التصميم المدمج (Integrated Metadata)**:
  - نص الرسالة، الوقت، وعلامات الصح موجودة **داخل نفس container الفقاعة**.
- **علامات قراءة الرسائل (WhatsApp Checkmarks)**:
  - `sent` (مرسلة): صح واحدة رمادية `✓`.
  - `delivered` (مستلمة): صحين رماديتين `✓✓`.
  - `seen` (مقروءة): صحين باللون الأزرق السماوي `✓✓` (`Color(0xFF34B7F1)`).
- **مؤشر الكتابة الحية (Typing Indicator)**:
  - ظهور عبارة **"يكتب الآن..."** في هيدر الشات باللون الأخضر عند كتابة الطرف الآخر.

---

## 7. 🧩 دعم الـ Specialist Mode

### المشكلة القديمة:
كانت `ChatCubit` تدعم فقط الـ User endpoints، مما يعني أن الـ Specialist لم يكن يستطيع فتح محادثة أو جلب رسائلها أو رفع ميديا.

### الحل (الوضع الحالي):
**`ChatCubit`** أصبح يدعم كلا الدورين عبر خاصية `_isSpecialistMode`:

```dart
// من الـ Specialist's ConversationsPage
ChatDetailsPage(
  isSpecialistMode: true,   // ← يُفعّل الـ specialist endpoints
  conversationId: '...',    // ← أو specialistId: userId للعميل
)

// من صفحة اليوزر العادية
ChatDetailsPage(
  isSpecialistMode: false,  // ← القيمة الافتراضية
  specialistId: '...',
)
```

### الـ Endpoints المستخدمة حسب الـ Mode:

| العملية | User Mode | Specialist Mode |
|---------|-----------|----------------|
| فتح محادثة | `POST /chat/open` | `POST /specialist/chat/:userId/open` |
| جلب الرسائل | `GET /chat/:id/messages` | `GET /specialist/chat/:id/messages` |
| رفع ميديا | `POST /chat/:id/media` | `POST /specialist/chat/:id/media` |

### الـ ID Matching لحدث `chat:delivered`:
تم حل مشكلة عدم تطابق الـ optimistic message ID مع الـ real ID القادم من السيرفر في `copyWithMessageDelivered`:
- إذا لم يُوجد الـ `messageId` الحقيقي في القائمة (لأن الرسالة ما زالت `optimistic_...`): يتم تحديث أحدث رسالة مؤقتة لحالة `delivered` تلقائياً.

---

## 8. ✨ نظام الـ Shimmer Loading

تم تطبيق Shimmer بدلاً من الـ Loading Spinner في كل قوائم البيانات:

| الشاشة | الـ Shimmer Widget |
|--------|-------------------|
| `ContactUsPage` | `ContactUsShimmer` |
| `ConversationsPage` | `ConversationsListShimmer` |

كلاهما يُحاكي شكل الكارت الحقيقي مع animation بيضاء/رمادية متحركة لتجربة مستخدم سلسة.

---

```
تاريخ التحديث: 2026-07-27
المشروع: Fitness Day Flutter App
التقنيات: Flutter, Socket.IO, Bloc/Cubit, Clean Architecture
```
