# FitPilot AI — Android MVP starter

This is a runnable starter project, not a finished production SaaS or signed APK.

## Included
- Flutter Android app shell with Home, Profile, Food AI and Coach tabs
- Profile form and API request
- Gallery photo selection for food images
- FastAPI backend with health, plan and chat demo endpoints
- Dark green fitness UI

## Run the backend
```bash
cd backend
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Open http://127.0.0.1:8000/health

## Run Android app
Install Flutter and Android Studio, then:
```bash
cd flutter_app
flutter pub get
flutter run
```
Android emulator reaches host machine at `10.0.2.2`. For a physical phone, set the backend URL to your computer's LAN IP:
```bash
flutter run --dart-define=FITPILOT_API=http://192.168.1.10:8000
```

## Build APK
```bash
flutter build apk --release
```
This requires a local Flutter/Android SDK setup and signing configuration for Play Store release.

## Important next steps before public launch
1. Add real AI provider integration on the server. Keep API keys server-side.
2. Add vision model endpoint and upload validation for food photos.
3. Add authentication, user consent, deletion/export, rate limits and secure database.
4. Add food database and nutrition-source citations; treat photo calorie values as estimates.
5. Add qualified review of exercise content and safeguards for minors, injuries, eating disorders and medical conditions.
6. Add privacy policy, terms, Play Store data safety disclosures, monitoring and backups.

## Low-budget deployment suggestion
Start with local development and free-tier hosting where available. Free tiers can change and may sleep or have usage limits. Do not collect sensitive photos or health-related data until privacy, access control and deletion flows are implemented.
