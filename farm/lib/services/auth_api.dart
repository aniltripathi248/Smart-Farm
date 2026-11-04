import 'api_client.dart';
import 'session_manager.dart';

/// AuthApi - Service for authentication-related API operations
/// 
/// This service handles all user authentication operations:
/// - User registration (signup)
/// - User login
/// - Profile updates
/// 
/// Flow: Screen (SignupPage/LoginPage) → AuthApi → ApiClient → Backend
/// 
/// Used by: SignupPage, LoginPage, EditProfilePage
class AuthApi {
  /// Constructor - requires ApiClient instance for HTTP communication
  AuthApi(this._client);

  /// HTTP client instance for making API calls
  final ApiClient _client;

  /// Creates a new user account (signup)
  /// 
  /// Flow:
  /// 1. SignupPage collects user data (name, email, phone, password)
  /// 2. Calls this method with user data
  /// 3. ApiClient sends POST /api/auth/signup to backend
  /// 4. Backend creates account and returns success message
  /// 5. User redirected to LoginPage
  /// 
  /// Parameters:
  /// - fullName: User's full name
  /// - farmName: Optional farm name
  /// - email: User's email address
  /// - phoneNumber: User's phone number
  /// - password: User's password
  /// - confirmPassword: Password confirmation (must match)
  /// 
  /// Returns: Map with success message from backend
  /// Throws: Exception if signup fails (email exists, validation error, etc.)
  Future<Map<String, dynamic>> signup({
    required String fullName,
    String? farmName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    // Prepare request body with user registration data
    final body = {
      'fullName': fullName,
      'farmName': farmName, // Optional - can be null
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword,
    };

    // Send POST request to signup endpoint
    // No token needed - this is a public endpoint
    return _client.postJson('/api/auth/signup', body);
  }

  /// Authenticates an existing user (login)
  /// 
  /// Flow:
  /// 1. LoginPage collects identifier (email/phone) and password
  /// 2. Calls this method with credentials
  /// 3. ApiClient sends POST /api/auth/login to backend
  /// 4. Backend validates credentials and returns { token, user }
  /// 5. LoginPage stores token and user in SessionManager
  /// 6. User redirected to DashboardPage
  /// 
  /// Parameters:
  /// - identifier: User's email OR phone number (backend accepts both)
  /// - password: User's password
  /// 
  /// Returns: Map with { token, user } from backend
  /// Throws: Exception if login fails (wrong password, user not found, etc.)
  Future<Map<String, dynamic>> login({
    required String identifier, // email or phone
    required String password,
  }) {
    // Prepare request body with login credentials
    final body = {
      'identifier': identifier, // Can be email or phone number
      'password': password,
    };

    // Send POST request to login endpoint
    // No token needed - this is a public endpoint
    return _client.postJson('/api/auth/login', body);
  }

  /// Updates the current user's profile information
  /// 
  /// Flow:
  /// 1. EditProfilePage loads current user data from SessionManager
  /// 2. User modifies name, farm name, email, or phone
  /// 3. Calls this method with updated data
  /// 4. Gets token from SessionManager (required for authenticated requests)
  /// 5. ApiClient sends POST /api/auth/update-profile with token
  /// 6. Backend updates user and returns updated user data
  /// 7. SessionManager updated with new user data
  /// 8. User redirected back to DashboardPage
  /// 
  /// Parameters:
  /// - fullName: Updated full name
  /// - farmName: Updated farm name (optional)
  /// - email: Updated email address
  /// - phoneNumber: Updated phone number
  /// 
  /// Returns: Map with updated user data from backend
  /// Throws: Exception if update fails (not logged in, validation error, etc.)
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? farmName,
    required String email,
    required String phoneNumber,
  }) {
    // Get authentication token from SessionManager
    // This is required because profile updates are authenticated operations
    final token = SessionManager.instance.token;
    if (token == null) {
      throw Exception('You must be logged in to update your profile.');
    }

    // Prepare request body with updated profile data
    final body = {
      'fullName': fullName,
      // Only include farmName if it's not null (optional field)
      if (farmName != null) 'farmName': farmName,
      'email': email,
      'phoneNumber': phoneNumber,
    };

    // Send POST request to update-profile endpoint
    // Token is required - this is an authenticated endpoint
    return _client.postJson('/api/auth/update-profile', body, token: token);
  }
}


