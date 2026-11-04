# 🌱 Smart Farm (Farm Companion)

A full-stack livestock management and smart farming platform designed to help farmers track animals, monitor health insights, manage farm tasks, and maintain livestock records.

Built with a **Flutter** frontend (Mobile, Web, Desktop) and a **Node.js + Express + MongoDB** backend.

---

## 🏗️ Architecture Overview

```text
Smart Farm/
├── farm/                  # Flutter frontend application (Android, iOS, Web, Desktop)
│   ├── lib/
│   │   ├── screens/       # UI screens (Dashboard, Animals, Scanning, Tasks, Auth)
│   │   ├── services/      # API communication (ApiClient, AuthApi, AnimalApi)
│   │   └── resources/     # Assets and icons
│   └── android/           # Android native configurations & permissions
│
├── Smart_Farm_Backend/    # Node.js + Express REST API
│   ├── src/
│   │   ├── configs/       # Database & environment configurations
│   │   ├── controllers/   # Auth, Animal, and User controllers
│   │   ├── middleware/    # JWT Authentication middleware
│   │   ├── models/        # Mongoose schemas (User, Animal)
│   │   └── routes/        # Express API route endpoints
│   └── index.js           # Server entry point (Port 5000)
│
├── runner/                # Unified launcher scripts
│   ├── run.js             # Node-based dual-process runner
│   ├── start.bat          # Interactive Windows batch launcher
│   └── start.ps1          # Interactive PowerShell launcher
│
├── package.json           # Root project script runner
├── run.bat                # 1-click startup script for Windows
└── README.md
```

---

## ⚡ Quick Start

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.9+)
- [Node.js](https://nodejs.org/) (v18+)
- [MongoDB](https://www.mongodb.com/try/download/community) running locally on port `27017` (or MongoDB Atlas connection string)

### 2. Run Both Backend & Frontend Together
You can start both services with a single command from the project root:

**Using the 1-click batch script:**
Double click `run.bat` or run in terminal:
```bash
.\run.bat
```

**Or using npm:**
```bash
npm start
```
This boots:
- Backend API server on `http://localhost:5000`
- Flutter Frontend on your chosen target device (Chrome, Windows desktop, or Android)

---

## 🖥️ Running Services Individually

### Backend Only
```bash
cd Smart_Farm_Backend
npm install
npm run dev
```
Health check endpoint: `http://localhost:5000/health`

### Frontend Only
```bash
cd farm
flutter pub get
flutter run -d chrome    # For Web
# or
flutter run -d windows   # For Windows Desktop
# or
flutter run              # For Android Phone / Emulator
```

---

## 🌐 Network & Server Configuration

The app includes an **Adaptive Network Resolver** in `ApiClient`:
- **Web & Desktop**: Automatically connects to `http://localhost:5000`.
- **Android Emulator**: Automatically routes to `http://10.0.2.2:5000`.
- **Physical Android Phone**: Automatically connects to your PC's LAN IP over Wi-Fi.

### In-App Server Settings
On the **Login** and **Signup** screens, tap the **⚙️ Settings / Help** button in the top right to:
1. View the current active backend URL.
2. Test connection with one tap (**Test Connection**).
3. Easily switch between `Localhost`, `Wi-Fi LAN`, or `Emulator` if your network IP changes.

---

## 🔐 Environment Variables

In `Smart_Farm_Backend/.env`:
```env
PORT=5000
MONGODB_URI=mongodb://127.0.0.1:27017/farm_companion
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRATION=30d
```
*(A template is provided in `Smart_Farm_Backend/.env.example`)*

---

## 👥 Authors & Contributors
- **Anil Tripathi** ([@aniltripathi248](https://github.com/aniltripathi248))
