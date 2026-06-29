# 🇪🇹 Exit Exam Ethiopia (EEE)
### AI-Powered Offline Exam Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.32.4-blue?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green?logo=supabase)](https://supabase.com)
[![Vercel](https://img.shields.io/badge/Vercel-Web%20Deploy-black?logo=vercel)](https://vercel.com)

---

## 🚀 Quick Start

### 1. Prerequisites
- Flutter SDK 3.32.4+ → installed at `C:\flutter_sdk\flutter`
- Android Studio / VS Code
- Supabase account
- OpenAI API key (for MCQ generation)

### 2. Flutter Setup (first time)
Open a **new terminal** (so PATH is updated) and run:
```cmd
flutter doctor
flutter pub get
```

### 3. Supabase Setup
1. Create a new project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** → paste contents of `supabase/migrations/001_initial_schema.sql` → Run
3. Go to **Authentication** → Settings → enable Email provider
4. Copy your project URL and anon key

### 4. Set Admin User
After your first sign-up with `milkiyaas43@gmail.com`, run in Supabase SQL editor:
```sql
UPDATE public.users SET is_admin = true WHERE email = 'milkiyaas43@gmail.com';
```

### 5. Configure .env.local
Copy `.env.example` to `.env.local` and fill in your values.
**Format is JSON** (required by `--dart-define-from-file`):
```json
{
  "SUPABASE_URL": "https://your-project-id.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key-here",
  "OPENAI_API_KEY": "sk-your-openai-key-here"
}
```
> `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` go in **GitHub Actions secrets only** — not here.

### 6. Run the App
```cmd
# Web (Chrome)
flutter run -d chrome --dart-define-from-file=.env.local

# Android
flutter run --dart-define-from-file=.env.local

# Or just press F5 in VS Code — launch.json is already configured
```

### 7. Build for Production
```cmd
# Android APK
flutter build apk --release --dart-define-from-file=.env.local

# Web (for Vercel)
flutter build web --release --dart-define-from-file=.env.local
```

---

## 🏗️ Project Structure

```
lib/
├── config/          # App configuration & constants
├── models/          # Data models (User, Exam, Question, etc.)
├── providers/       # Riverpod state providers
├── screens/
│   ├── splash/      # Splash screen
│   ├── onboarding/  # Welcome screen
│   ├── auth/        # Sign in / Sign up
│   ├── home/        # Dashboard
│   ├── department/  # Department list + lock system
│   ├── exam/        # Exam list per department
│   ├── question/    # MCQ question screen
│   ├── result/      # Score & result screen
│   ├── payment/     # Payment submission
│   ├── settings/    # Language, profile, logout
│   └── admin/       # Full admin panel
├── services/        # Supabase, AI MCQ, payment, offline
├── theme/           # Dark theme
├── utils/           # Router, security, watermark
└── widgets/         # Reusable UI components
supabase/
└── migrations/      # SQL schema
.github/workflows/   # CI/CD → Vercel + APK build
```

---

## 💳 Payment Info
- **CBE Bank:** 1000458067857
- **Telebirr:** 0943133184
- **CBE Birr:** 0991575614
- **Price:** 200 ETB per department
- **Telegram:** [@milkibn](https://t.me/milkibn)
- **Community:** [t.me/exitexamethiopia1](https://t.me/exitexamethiopia1)

---

## 🔐 Admin Credentials
- **Email:** milkiyaas43@gmail.com
- **Password:** Ayyuu@4313@
- **Admin Panel:** Click the ⚙️ gold button (bottom-right) after login

---

## 🤖 AI MCQ Generation
Set `OPENAI_API_KEY` via `--dart-define`. Supports GPT-4o-mini.
To use Gemini instead, replace `_callAI()` in `lib/services/mcq_generator_service.dart`.

---

## 🌐 Vercel Deployment
1. `flutter build web --release --dart-define=...`
2. `cd build/web && vercel --prod`
Or push to `main` branch — GitHub Actions auto-deploys.

---

## 🔒 Security Features
- Android `FLAG_SECURE` → blocks screenshots + screen recording
- One email = one account (server-side check)
- One account = one device (device session lock)
- Supabase RLS on all tables
- JWT authentication
- Encrypted local storage (flutter_secure_storage)
- Email watermark on exam screens

---

## 📡 GitHub Actions Secrets Required
Add these in your GitHub repo → Settings → Secrets:
```
SUPABASE_URL
SUPABASE_ANON_KEY
OPENAI_API_KEY
VERCEL_TOKEN
VERCEL_ORG_ID
VERCEL_PROJECT_ID
```
