# 🚀 Smart Farm - Unified One-Command Launchers

This folder (`runner/`) provides scripts to launch both the **Backend API** (Node.js/Express) and **Frontend** (Flutter) with a single command.

---

## ⚡ Quick Options to Run

### Option 1: Root NPM command (Single Terminal)
From the root directory:
```bash
npm start
```
Or target a specific device:
```bash
npm run dev:windows   # Windows desktop app
npm run dev:chrome    # Chrome web browser (default)
npm run dev:edge      # Microsoft Edge browser
npm run dev:android   # Android emulator or connected device
```
* **Hot-Reload**: Press `r` in the terminal to hot-reload Flutter.
* **Hot-Restart**: Press `R` to hot-restart Flutter.
* **Quit**: Press `Ctrl+C` to cleanly exit both services.

---

### Option 2: Windows Batch Script (Two Interactive Windows)
Double-click [run.bat](../run.bat) at the root, or run:
```cmd
.\run.bat
```
*(or from this folder: `.\runner\start.bat`)*

* Opens Backend in one labeled command window.
* Prompts you to pick your target device (Chrome, Windows desktop, Edge, Android).
* Opens Flutter in a second window with full interactive support.

---

### Option 3: PowerShell Script
From PowerShell:
```powershell
.\runner\start.ps1
```

---

## 🌐 URLs
- **Backend API**: `http://localhost:5000`
- **Health Check**: `http://localhost:5000/health`
