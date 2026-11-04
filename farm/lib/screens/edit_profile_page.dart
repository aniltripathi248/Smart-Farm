// ============================================
// EDIT PROFILE PAGE - Update User Information
// ============================================
// This screen allows users to edit their profile information:
// - Full name
// - Farm name (optional)
// - Email
// - Phone number
// 
// After saving, the updated data is stored in SessionManager
// and the drawer/profile displays are refreshed.
// ============================================

import 'package:farm/services/api_client.dart';
import 'package:farm/services/auth_api.dart';
import 'package:farm/services/session_manager.dart';
import 'package:flutter/material.dart';

/// EditProfilePage - Screen for editing user profile
/// 
/// Flow:
/// 1. Screen opens → initState() calls _loadUserData()
/// 2. Loads current user data from SessionManager
/// 3. Pre-fills form fields with current values
/// 4. User modifies fields
/// 5. User taps "Save Changes" button
/// 6. _saveProfile() validates and saves to backend
/// 7. SessionManager updated with new data
/// 8. User redirected back to DashboardPage
/// 
/// Navigation:
/// - Back button → DashboardPage
/// - "Save Changes" → DashboardPage (after save)
/// 
/// Accessed from: DashboardPage drawer "Edit Profile" option
class EditProfilePage extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

/// State class for EditProfilePage
/// Manages form state and profile update process
class _EditProfilePageState extends State<EditProfilePage> {
  // ============================================
  // FORM KEY
  // ============================================
  // Key for form validation
  final _formKey = GlobalKey<FormState>();
  
  // ============================================
  // TEXT CONTROLLERS
  // ============================================
  // Controllers for all form input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController(); // Optional
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // ============================================
  // API SERVICE
  // ============================================
  // Authentication API service for profile update
  final _authApi = AuthApi(ApiClient());
  
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Shows loading spinner while loading user data (if needed)
  bool _isLoading = false;
  
  // Shows loading spinner on save button while API call is in progress
  bool _isSaving = false;

  /// Called when screen is first created
  /// 
  /// Flow:
  /// 1. Screen initializes
  /// 2. Immediately loads current user data into form fields
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Loads current user data from SessionManager into form fields
  /// 
  /// Flow:
  /// 1. Gets user data from SessionManager
  /// 2. Pre-fills all text controllers with current values
  /// 3. User can then modify and save
  /// 
  /// Called by: initState()
  void _loadUserData() {
    // Get current user data from SessionManager
    final user = SessionManager.instance.user;
    if (user != null) {
      // Pre-fill form fields with current user data
      _fullNameController.text = user['fullName']?.toString() ?? '';
      _farmNameController.text = user['farmName']?.toString() ?? '';
      _emailController.text = user['email']?.toString() ?? '';
      _phoneController.text = user['phoneNumber']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _farmNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Saves the updated profile information
  /// 
  /// Flow:
  /// 1. Validates form fields (using form validators)
  /// 2. Shows loading spinner on save button
  /// 3. Calls AuthApi.updateProfile() with updated data
  /// 4. Backend updates user in database
  /// 5. Updates SessionManager with new user data
  /// 6. Shows success message
  /// 7. Navigates back to DashboardPage
  /// 8. DashboardPage drawer refreshes with new data
  /// 
  /// Called by: "Save Changes" button onPressed
  Future<void> _saveProfile() async {
    // ============================================
    // STEP 1: Validate form
    // ============================================
    // Check if all form validators pass
    if (!_formKey.currentState!.validate()) {
      return; // Stop here if validation fails
    }

    // ============================================
    // STEP 2: Show loading state
    // ============================================
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // ============================================
      // STEP 3: Call update profile API
      // ============================================
      // Send updated data to backend
      // Backend validates and updates user in database
      final result = await _authApi.updateProfile(
        fullName: _fullNameController.text.trim(),
        // Farm name is optional - send null if empty
        farmName: _farmNameController.text.trim().isEmpty
            ? null
            : _farmNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      // ============================================
      // STEP 4: Update SessionManager
      // ============================================
      // Store updated user data in SessionManager
      // This ensures drawer and profile displays show new data
      final user = SessionManager.instance.user;
      if (user != null && result['user'] != null) {
        SessionManager.instance.setAuth(
          SessionManager.instance.token!, // Keep existing token
          result['user'] as Map<String, dynamic>, // Update with new user data
        );
      }

      // ============================================
      // STEP 5: Show success message
      // ============================================
      messenger.showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Profile updated successfully'),
          backgroundColor: const Color(0xFF2F7D32), // Green for success
        ),
      );

      // ============================================
      // STEP 6: Navigate back
      // ============================================
      // Go back to DashboardPage
      // DashboardPage will refresh drawer with new data
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // ============================================
      // ERROR HANDLING
      // ============================================
      // If update fails (validation error, network error, etc.)
      // Show error message to user
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red, // Red for error
        ),
      );
    } finally {
      // ============================================
      // CLEANUP
      // ============================================
      // Always hide loading spinner, even if error occurred
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7D32),
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F7D32)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Avatar Section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              _fullNameController.text.isNotEmpty
                                  ? _fullNameController.text[0].toUpperCase()
                                  : 'F',
                              style: const TextStyle(
                                fontSize: 40,
                                color: Color(0xFF2F7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to change photo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Form Fields
                    _LabeledField(
                      label: 'Full name',
                      hint: 'e.g. Alex Mwangi',
                      controller: _fullNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Farm name (optional)',
                      hint: 'Name of your farm',
                      controller: _farmNameController,
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Email',
                      hint: 'name@farm.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Phone number',
                      hint: 'e.g. +254 712 345 678',
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFBF5EC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

