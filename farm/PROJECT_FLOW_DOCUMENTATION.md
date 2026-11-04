# Farm Companion - Project Flow & Architecture Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture Layers](#architecture-layers)
3. [Application Flow](#application-flow)
4. [Service Layer Details](#service-layer-details)
5. [Screen Navigation Flow](#screen-navigation-flow)
6. [Data Flow](#data-flow)
7. [Key Components Usage](#key-components-usage)

---

## 🎯 Project Overview

**Farm Companion** is a Flutter mobile application for managing farm animals, tracking tasks, and monitoring livestock health. The app follows a clean architecture pattern with separation of concerns.

### Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend API**: REST API (hosted on Render.com)
- **Local Storage**: SharedPreferences (for tasks)
- **State Management**: StatefulWidget (setState)

---

## 🏗️ Architecture Layers

```
┌─────────────────────────────────────────┐
│         UI Layer (Screens)              │
│  - Login, Signup, Dashboard, etc.      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      Service Layer (Business Logic)     │
│  - AuthApi, AnimalApi, TaskService     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      API Client (HTTP Communication)    │
│  - ApiClient (GET, POST, DELETE)       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      Session Manager (State)            │
│  - Token, User Data Storage             │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      Backend API (Render.com)           │
│  - Authentication, Animal CRUD          │
└─────────────────────────────────────────┘
```

---

## 🔄 Application Flow

### 1. **App Initialization Flow**

```
main.dart
  ↓
MyApp (MaterialApp)
  ↓
initialRoute: FarmCompanionOnboarding
  ↓
User sees onboarding screens (3 pages)
  ↓
User chooses: Login or Signup
```

### 2. **Authentication Flow**

#### **Signup Flow:**
```
SignupPage
  ↓
User fills form (name, email, phone, password)
  ↓
AuthApi.signup() → ApiClient.postJson()
  ↓
POST /api/auth/signup
  ↓
Backend creates user account
  ↓
Navigate to LoginPage
```

#### **Login Flow:**
```
LoginPage
  ↓
User enters email/phone + password
  ↓
AuthApi.login() → ApiClient.postJson()
  ↓
POST /api/auth/login
  ↓
Backend validates credentials
  ↓
Returns: { token, user }
  ↓
SessionManager.setAuth(token, user)
  ↓
Navigate to DashboardPage
```

### 3. **Dashboard Flow**

```
DashboardPage (initState)
  ↓
_loadDashboardData()
  ↓
├─ AnimalApi.getMyAnimals() → GET /api/animals/mine
│  └─ Returns: List of animals
│
├─ TaskService.shouldRegenerateTasks()
│  └─ Checks if new day (compares dates)
│
├─ If new day:
│  └─ TaskService.generateTasks(animals)
│     └─ Creates tasks based on animal types
│     └─ Saves to SharedPreferences
│
├─ TaskService.getTaskStats()
│  └─ Returns: { total, completed, pending }
│
└─ TaskService.getTodayTasks()
   └─ Returns: List of today's tasks
```

**Dashboard Displays:**
- Farm Overview Card (animal count, health status)
- Quick Actions (Scan, Upload)
- Today's Tasks (with stats: Total, Completed, Pending)
- Bottom Navigation (Home, Animals, Tasks, Insights)

### 4. **Animal Management Flow**

#### **Adding Animals:**
```
Dashboard → FAB (+) or "Add Animal"
  ↓
AddAnimalPage (Step 1: Select animal type)
  ↓
AddAnimal2Page (Step 2: Choose entry mode)
  ↓
GroupAnimalSetupPage (Step 3: Enter details)
  ├─ Number of animals
  ├─ Purpose (Dairy, Meat, etc.)
  └─ Calculates: shelter area, water, cost
  ↓
SummaryPage (Step 4: Review)
  ↓
User confirms
  ↓
AnimalApi.createGroupFromSummary()
  ↓
POST /api/animals/addanimal
  ↓
Backend saves animal
  ↓
Navigate to Dashboard
  ↓
Dashboard refreshes (loads new animals)
  ↓
Tasks auto-regenerate if new day
```

#### **Viewing Animals:**
```
Dashboard → "View all animals" or Animals icon
  ↓
AnimalsListPage
  ↓
AnimalApi.getMyAnimals()
  ↓
GET /api/animals/mine
  ↓
Displays list of animals
  ↓
User taps animal card
  ↓
AnimalDetailsPage (shows full details)
```

#### **Editing Animals:**
```
AnimalDetailsPage → Edit button
  ↓
EditAnimalPage
  ↓
User modifies: number, purpose, cost
  ↓
AnimalApi.updateAnimal()
  ↓
POST /api/animals/:id/update
  ↓
Backend updates animal
  ↓
Returns updated data
  ↓
SessionManager updates
  ↓
Navigate back to AnimalDetailsPage
```

#### **Deleting Animals:**
```
AnimalDetailsPage → Delete button
  ↓
Confirmation dialog
  ↓
AnimalApi.deleteAnimal(animalId)
  ↓
DELETE /api/animals/:id
  ↓
Backend deletes animal
  ↓
Navigate back to AnimalsListPage
```

### 5. **Task Management Flow**

#### **Task Generation:**
```
Dashboard loads
  ↓
Checks: TaskService.shouldRegenerateTasks()
  ↓
If new day AND animals exist:
  ↓
TaskService.generateTasks(animals)
  ↓
For each animal type:
  ├─ Count animals by type
  ├─ Generate type-specific tasks
  │  ├─ Cows: Feeding, Cleaning, Milking, Watering, Health check
  │  ├─ Goats: Feeding, Cleaning, Watering, Health check, Activity check
  │  └─ Pigs: Feeding, Cleaning, Watering, Hygiene, Temperature check
  └─ Save to SharedPreferences
```

#### **Viewing Tasks:**
```
Dashboard → "View all" in Tasks card OR Tasks icon
  ↓
TasksPage
  ↓
TaskService.getTodayTasks()
  ↓
Loads from SharedPreferences
  ↓
Filters by today's date
  ↓
Displays list with checkboxes
```

#### **Completing Tasks:**
```
TasksPage → User checks/unchecks task
  ↓
TaskService.updateTaskCompletion(taskId, isCompleted)
  ↓
Loads all tasks from SharedPreferences
  ↓
Finds task by ID
  ↓
Updates completion status
  ↓
Saves back to SharedPreferences
  ↓
UI refreshes
```

### 6. **Profile Management Flow**

```
Dashboard → Profile icon (top right)
  ↓
Drawer opens
  ↓
User taps "Edit Profile"
  ↓
EditProfilePage
  ↓
User modifies: name, farm name, email, phone
  ↓
AuthApi.updateProfile()
  ↓
POST /api/auth/update-profile
  ↓
Backend updates user
  ↓
Returns updated user data
  ↓
SessionManager.setAuth(token, updatedUser)
  ↓
Navigate back to Dashboard
  ↓
Drawer refreshes with new data
```

---

## 🔧 Service Layer Details

### 1. **ApiClient** (`lib/services/api_client.dart`)
**Purpose**: Low-level HTTP communication with backend

**Methods:**
- `postJson(path, body, {token})` - POST requests
- `getJson(path, {token})` - GET requests
- `deleteJson(path, {token})` - DELETE requests

**Features:**
- Automatic token injection (Bearer token)
- Error handling (503, JSON parsing errors)
- User-friendly error messages

**Used by:**
- AuthApi
- AnimalApi

---

### 2. **SessionManager** (`lib/services/session_manager.dart`)
**Purpose**: Singleton for managing user session state

**Properties:**
- `token` - JWT authentication token
- `userId` - Current user's ID
- `user` - User data (name, email, farm name, etc.)

**Methods:**
- `setAuth(token, user)` - Store login credentials
- `clear()` - Logout (clear all data)

**Used by:**
- All screens that need user info
- All API services (for token)

---

### 3. **AuthApi** (`lib/services/auth_api.dart`)
**Purpose**: Authentication-related API calls

**Methods:**
- `signup()` - Create new account
- `login()` - Authenticate user
- `updateProfile()` - Update user profile

**Flow:**
```
AuthApi → ApiClient → Backend API
```

**Used by:**
- LoginPage
- SignupPage
- EditProfilePage

---

### 4. **AnimalApi** (`lib/services/animal_api.dart`)
**Purpose**: Animal-related API calls

**Methods:**
- `createGroupFromSummary()` - Add new animal group
- `getMyAnimals()` - Get all user's animals
- `getAnimalById(id)` - Get single animal
- `updateAnimal()` - Update animal details
- `deleteAnimal(id)` - Delete animal

**Flow:**
```
AnimalApi → ApiClient → Backend API
```

**Used by:**
- DashboardPage (to load animals)
- AnimalsListPage
- AnimalDetailsPage
- EditAnimalPage
- SummaryPage (to save animal)

---

### 5. **TaskService** (`lib/services/task_service.dart`)
**Purpose**: Local task management (uses SharedPreferences)

**Key Features:**
- **No backend API** - Tasks are stored locally
- Auto-generates tasks based on animals
- Regenerates daily

**Methods:**
- `generateTasks(animals)` - Create tasks from animals
- `loadTasks()` - Load from SharedPreferences
- `saveTasks(tasks)` - Save to SharedPreferences
- `shouldRegenerateTasks()` - Check if new day
- `getTodayTasks()` - Filter today's tasks
- `updateTaskCompletion(id, completed)` - Toggle completion
- `getTaskStats()` - Get statistics

**Data Storage:**
- Uses SharedPreferences (local device storage)
- Keys: `'daily_tasks'`, `'last_task_generation_date'`

**Used by:**
- DashboardPage (to generate and display tasks)
- TasksPage (to view and complete tasks)

---

## 📱 Screen Navigation Flow

### Navigation Map:

```
┌─────────────────────────────────────────────────────────┐
│                    App Start                            │
│              FarmCompanionOnboarding                    │
└─────────────────────────────────────────────────────────┘
                        ↓
        ┌───────────────┴───────────────┐
        ↓                               ↓
┌───────────────┐              ┌───────────────┐
│  LoginPage    │              │  SignupPage   │
└───────────────┘              └───────────────┘
        ↓                               ↓
        └───────────────┬───────────────┘
                        ↓
              ┌─────────────────┐
              │ DashboardPage    │ ◄─── Main Hub
              └─────────────────┘
                        │
        ┌───────────────┼───────────────┬───────────────┐
        ↓               ↓               ↓               ↓
┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│AnimalsListPage│ │  TasksPage    │ │EditProfilePage│ │ScanAnimalPage │
└───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘
        ↓
┌───────────────┐
│AnimalDetails  │
│    Page       │
└───────────────┘
        │
        ├──→ EditAnimalPage
        └──→ (Delete action)
```

### Detailed Navigation:

1. **Onboarding → Auth:**
   - `FarmCompanionOnboarding` → `LoginPage` or `SignupPage`

2. **Auth → Dashboard:**
   - `LoginPage` → `DashboardPage` (after successful login)
   - `SignupPage` → `LoginPage` (after signup)

3. **Dashboard → Animals:**
   - "View all animals" → `AnimalsListPage`
   - Animals icon (bottom nav) → `AnimalsListPage`
   - FAB (+) → `AddAnimalPage`

4. **Animals → Details:**
   - Animal card tap → `AnimalDetailsPage`
   - Edit button → `EditAnimalPage`

5. **Dashboard → Tasks:**
   - "View all" in Tasks card → `TasksPage`
   - Tasks icon (bottom nav) → `TasksPage`

6. **Dashboard → Profile:**
   - Profile icon → Drawer opens
   - "Edit Profile" → `EditProfilePage`

7. **Add Animal Flow:**
   - `AddAnimalPage` → `AddAnimal2Page` → `GroupAnimalSetupPage` → `SummaryPage` → `DashboardPage`

---

## 💾 Data Flow

### 1. **Authentication Data Flow:**

```
User Input (Login/Signup)
  ↓
AuthApi (validates, formats)
  ↓
ApiClient (adds headers, sends HTTP)
  ↓
Backend API (validates, processes)
  ↓
Returns: { token, user }
  ↓
SessionManager.setAuth()
  ↓
Stored in memory (app session)
```

### 2. **Animal Data Flow:**

#### **Creating:**
```
User fills form (SummaryPage)
  ↓
AnimalApi.createGroupFromSummary()
  ↓
ApiClient.postJson('/api/animals/addanimal')
  ↓
Backend saves to database
  ↓
Returns: { success, data }
  ↓
Navigate to Dashboard
  ↓
Dashboard reloads animals
```

#### **Reading:**
```
Dashboard/AnimalsListPage
  ↓
AnimalApi.getMyAnimals()
  ↓
ApiClient.getJson('/api/animals/mine')
  ↓
Backend queries database
  ↓
Returns: List of animals
  ↓
Displayed in UI
```

#### **Updating:**
```
EditAnimalPage
  ↓
AnimalApi.updateAnimal()
  ↓
ApiClient.postJson('/api/animals/:id/update')
  ↓
Backend updates database
  ↓
Returns: Updated animal
  ↓
UI refreshes
```

#### **Deleting:**
```
AnimalDetailsPage
  ↓
AnimalApi.deleteAnimal()
  ↓
ApiClient.deleteJson('/api/animals/:id')
  ↓
Backend deletes from database
  ↓
Returns: Success
  ↓
Navigate back to list
```

### 3. **Task Data Flow:**

```
Dashboard loads
  ↓
Checks: shouldRegenerateTasks()
  ↓
If new day:
  ├─ Loads animals from API
  ├─ Generates tasks locally
  └─ Saves to SharedPreferences
  ↓
Loads tasks from SharedPreferences
  ↓
Filters by today's date
  ↓
Displays in UI
  ↓
User completes task
  ↓
Updates SharedPreferences
  ↓
UI refreshes
```

**Note:** Tasks are **NOT** stored in backend - they're local only!

---

## 🎯 Key Components Usage

### **When to Use Each Service:**

1. **ApiClient:**
   - Direct HTTP communication
   - Used by AuthApi and AnimalApi
   - Never used directly by screens

2. **SessionManager:**
   - Access user data: `SessionManager.instance.user`
   - Access token: `SessionManager.instance.token`
   - Check if logged in: `SessionManager.instance.token != null`
   - Used by: All screens that need user info, all API services

3. **AuthApi:**
   - User authentication (login, signup)
   - Profile updates
   - Used by: LoginPage, SignupPage, EditProfilePage

4. **AnimalApi:**
   - All animal CRUD operations
   - Used by: DashboardPage, AnimalsListPage, AnimalDetailsPage, EditAnimalPage, SummaryPage

5. **TaskService:**
   - Local task management
   - Task generation from animals
   - Used by: DashboardPage, TasksPage

### **State Management Pattern:**

- **StatefulWidget + setState()** - Used throughout
- **No global state management library** (Redux, Bloc, Provider)
- **SessionManager** - Singleton for session state
- **SharedPreferences** - Local storage for tasks

### **Error Handling:**

- All API calls wrapped in try-catch
- User-friendly error messages via SnackBar
- ApiClient handles HTTP errors (503, JSON parsing)
- Services throw exceptions that screens catch

---

## 🔐 Security & Authentication

1. **Token Storage:**
   - Stored in `SessionManager` (in-memory)
   - Sent in `Authorization: Bearer <token>` header
   - Cleared on logout

2. **API Security:**
   - All animal operations require token
   - Backend validates token
   - Users can only access their own animals

3. **Local Storage:**
   - Tasks stored in SharedPreferences (device-only)
   - No sensitive data in local storage

---

## 📊 Data Models

### **Animal Model (from API):**
```dart
{
  '_id': String,
  'animalType': String,  // 'Cow', 'Goat', 'Pig', etc.
  'entryMode': String,   // 'group' or 'single'
  'groupInfo': {
    'numberOfAnimals': int,
    'purpose': String,   // 'Dairy', 'Meat', etc.
    'monthlyCost': int
  },
  'userId': String,
  'createdAt': String,   // ISO date
  'updatedAt': String    // ISO date
}
```

### **Task Model (local):**
```dart
Task {
  id: String,
  title: String,
  animalType: String,
  quantity: int,
  isCompleted: bool,
  date: DateTime
}
```

### **User Model (from API):**
```dart
{
  '_id': String,
  'fullName': String,
  'farmName': String?,
  'email': String,
  'phoneNumber': String
}
```

---

## 🚀 Key Features Summary

1. **Authentication:**
   - Signup, Login, Profile editing
   - Session management

2. **Animal Management:**
   - Add animals (group mode)
   - View all animals
   - View animal details
   - Edit animals
   - Delete animals

3. **Task Management:**
   - Auto-generate tasks from animals
   - Daily task regeneration
   - Task completion tracking
   - Task statistics

4. **Dashboard:**
   - Farm overview
   - Quick actions (scan, upload)
   - Today's tasks preview
   - Navigation hub

---

## 📝 Important Notes

1. **Tasks are Local Only:**
   - Generated from animals
   - Stored in SharedPreferences
   - Not synced with backend
   - Regenerate daily

2. **Animal Operations Require Auth:**
   - All API calls include token
   - Backend validates ownership

3. **Error Handling:**
   - All API errors caught and displayed
   - User-friendly messages
   - Network errors handled gracefully

4. **Navigation:**
   - Named routes in main.dart
   - Arguments passed via route settings
   - Back navigation preserves state

---

This documentation provides a complete overview of your Farm Companion app's architecture and flow. Each component has a specific role and follows a clear pattern for maintainability and scalability.

