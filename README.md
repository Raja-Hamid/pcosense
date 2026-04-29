# PCOSense

PCOS screening and management Flutter app. Combines a clinically-grounded weighted questionnaire with a VGG19 ultrasound classifier served from a local Flask backend, fuses the two signals, and produces a personalised lifestyle plan + a downloadable PDF report.

This repo contains only the Flutter client. The matching Python backend lives at `../backend/api/`.

## Run the demo end-to-end

### 1. Start the Flask inference backend

The backend is in `../backend/api/`. See its README for full details.

```bash
# from repo root
cd ../backend/api
# activate the existing pcos_env (Windows: ..\PCOS-NEW\pcos_env\Scripts\activate)
source ../PCOS-NEW/pcos_env/bin/activate
pip install -r requirements.txt
python run.py
```

You should see `PCOSense API listening on http://0.0.0.0:5000` and the model load log. Verify with `curl http://localhost:5000/health`.

### 2. Run the Flutter app

```bash
flutter pub get
flutter run
```

The app defaults to `http://10.0.2.2:5000` for the Android emulator. For a real phone on the same Wi-Fi, override the URL at launch:

```bash
flutter run --dart-define=BACKEND_URL=http://192.168.1.42:5000
```

(replace `192.168.1.42` with your computer's LAN IP — find it with `ipconfig` on Windows or `ifconfig`/`ipconfig getifaddr en0` on macOS).

### 3. Smoke test the full flow

1. Sign up with a fresh account (Firebase Auth must be configured — `firebase_options.dart` is already in the repo).
2. Take the questionnaire end to end. Result should be saved under `users/{uid}/questionnaire_history/`.
3. Open **Scan**, pick an ultrasound image from the gallery. Watch the upload progress, then the AI analysis. The fused result card should appear with the image label, confidence, and combined risk tier.
4. Open **Recommendations** — the plan should reflect your questionnaire signals (BMI band, hyperandrogenism, etc.) and image result.
5. Open **Report** — confirm the image analysis card is populated. Tap **Download PDF** — a system print/preview sheet should appear.
6. Open **Tracker**, log a few symptoms, then re-open the app — they should reload from cache instantly and re-sync from Firestore.

## Architecture (post-completion)

```
┌─────────────────────────────────────┐
│ Flutter app (this repo)             │
│  ├─ Welcome / Auth (Firebase)       │
│  ├─ Questionnaire → rule-based      │
│  │   risk score (low/mod/high/      │
│  │   urgent)                        │
│  ├─ Scan → image picker → Storage   │
│  │       → POST /predict (Flask)    │
│  ├─ RiskFusion (Dart) combines      │
│  │   questionnaire + image          │
│  ├─ RecommendationEngine (Dart)     │
│  │   produces personalized plan     │
│  ├─ ReportPdfService (pdf package)  │
│  └─ Offline-first caches            │
│      (assessments, predictions,     │
│       plans, symptom logs)          │
└─────────────────────────────────────┘
              │
              ├──── Firebase ───────┐
              │   Auth · Firestore  │
              │   Storage           │
              │                     │
              └──── HTTP ────┐      │
                            ▼      ▼
                  ┌────────────────────────┐
                  │ Flask backend          │
                  │ (../backend/api)       │
                  │ /predict → VGG19 H5    │
                  │ /health                │
                  └────────────────────────┘
```

## Firestore data model

```
users/{uid}                                  ← user profile
  └── questionnaire_history/{assessmentId}   ← AssessmentModel
  └── uploads/{uploadId}                     ← UploadModel
  └── predictions/{predictionId}             ← PredictionModel (linked to upload + assessment)
  └── recommendations/{assessmentId}         ← PersonalizedPlan (one per assessment)
  └── symptom_logs/{logId}                   ← SymptomLogModel
```

Security rules in `firestore.rules` enforce `request.auth.uid == uid` on every path.

Firebase Storage rules in `storage.rules` restrict ultrasound uploads to the owning user, image-only, max 10 MB.

Apply both:

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

## Configuration

| Setting | Where | Default |
|--------|-------|---------|
| Backend URL | `--dart-define=BACKEND_URL=...` | `http://10.0.2.2:5000` (Android emulator) |
| Cleartext HTTP | `android/app/src/main/AndroidManifest.xml` (`usesCleartextTraffic="true"`) | enabled — **disable before any release** |
| Max upload size | `lib/src/features/content/services/upload_service.dart` (10 MB) and `backend/api/config.py` | 10 MB |

### iOS note

iOS App Transport Security blocks plain-HTTP traffic. For iOS development against a localhost backend, add a temporary ATS exception in `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
```

## Project structure

```
lib/src/
├── core/
│   ├── cache/local_json_cache.dart
│   ├── di/initial_binding.dart
│   ├── network/{api_client,api_endpoints}.dart
│   ├── routing/{app_routes,app_pages}.dart
│   └── theme/, widgets/
├── features/
│   ├── auth/                                — Firebase email/password
│   ├── onboarding/
│   ├── questionnaire/                       — 18-rule weighted scoring
│   ├── assessment/                          — saves results, fuses with image, PDF report
│   │   ├── logic/risk_fusion.dart
│   │   └── services/{assessment_service,report_pdf_service}.dart
│   ├── content/                             — scan, predict, recommend
│   │   ├── controllers/{scan,prediction,recommendation}_controller.dart
│   │   ├── logic/recommendation_engine.dart
│   │   ├── services/{upload,prediction,recommendation}_service.dart
│   │   └── views/{scan,recommendations,...}_view.dart
│   ├── tracker/                             — Firestore-synced symptom logs
│   ├── home/, profile/
```

## Disclaimer

PCOSense is a screening and educational tool. It is not a medical device, not a diagnostic tool, and not a replacement for qualified clinical advice. The CNN test accuracy (≈95.8% on the held-out set) does not generalise to all imaging conditions — use clinician review for any consequential decision.
