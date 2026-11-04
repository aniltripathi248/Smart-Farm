/// SessionManager - Singleton class for managing user session state
/// 
/// This class stores the authentication token and user data in memory.
/// It's used throughout the app to:
/// - Check if user is logged in
/// - Access user information (name, email, etc.)
/// - Get authentication token for API calls
/// 
/// Flow: After successful login, AuthApi calls setAuth() to store credentials.
/// All API services (AnimalApi, AuthApi) use this to get the token.
class SessionManager {
  // Private constructor - prevents direct instantiation
  // This ensures only one instance exists (singleton pattern)
  SessionManager._();

  // Static instance - accessed via SessionManager.instance throughout the app
  static final SessionManager instance = SessionManager._();

  // Authentication token (JWT) received from backend after login
  // Used in Authorization header for all authenticated API calls
  String? token;
  
  // User ID extracted from user data
  // Used to identify the current logged-in user
  String? userId;
  
  // Complete user data object from backend
  // Contains: fullName, email, phoneNumber, farmName, _id, etc.
  Map<String, dynamic>? user;

  /// Stores authentication credentials after successful login/signup
  /// 
  /// Called by: LoginPage, SignupPage after successful authentication
  /// 
  /// Flow:
  /// 1. User logs in → Backend returns { token, user }
  /// 2. LoginPage calls this method with token and user data
  /// 3. Token and user data stored in memory
  /// 4. All subsequent API calls use this token
  void setAuth(String newToken, Map<String, dynamic> newUser) {
    token = newToken;
    user = newUser;
    // Extract user ID from user object (handles both '_id' and 'id' formats)
    userId = newUser['_id']?.toString() ?? newUser['id']?.toString();
  }

  /// Clears all session data (logout)
  /// 
  /// Called by: DashboardPage drawer logout action
  /// 
  /// Flow:
  /// 1. User taps logout in drawer
  /// 2. This method clears all stored data
  /// 3. User redirected to LoginPage
  void clear() {
    token = null;
    userId = null;
    user = null;
  }
}


