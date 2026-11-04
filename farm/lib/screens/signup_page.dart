// ============================================
// SIGNUP PAGE - User Registration
// ============================================
// This screen allows new users to create an account.
// Users must fill in:
// - Full name (required)
// - Farm name (optional)
// - Email (required)
// - Phone number (required)
// - Password (required, min 8 characters)
// - Confirm password (must match)
// - Agree to Terms and Privacy Policy
// 
// After successful signup, user is redirected to LoginPage.
// ============================================

import 'package:farm/screens/login_page.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/auth_api.dart';
import 'package:flutter/material.dart';

/// SignupPage - Screen for new user registration
class SignupPage extends StatefulWidget {
  static const routeName = '/signup';
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

/// State class for SignupPage
/// Manages form state, password visibility, and signup process
class _SignupPageState extends State<SignupPage> {
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Whether user has agreed to Terms and Privacy Policy
  bool _agreed = false;
  
  // Controls password field visibility (show/hide)
  bool _obscurePassword = true;
  
  // Controls confirm password field visibility (show/hide)
  bool _obscureConfirm = true;
  
  // Shows loading spinner on submit button while API call is in progress
  bool _isSubmitting = false;

  // ============================================
  // TEXT CONTROLLERS
  // ============================================
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController(); // Optional
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _farmNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                leadingLabel: 'Back',
                trailingLabel: 'Help & Server',
                onLeadingTap: _goToLogin,
                onTrailingTap: () => _showServerSettings(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create your farm account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2C1C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your profile to start tracking animals, tasks, and health insights.',
                style: TextStyle(
                  color: Color(0xFF6A6F5B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 16),
              _buildSocialLoginButtons(),
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabeledField(
          label: 'Full name',
          hint: 'e.g. Anil Tripathi',
          controller: _fullNameController,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Farm name (optional)',
          hint: 'Name of your farm',
          controller: _farmNameController,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Email',
          hint: 'name@gmail.com',
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Phone number',
          hint: 'e.g. +977 9800000000',
          helperText: 'For alerts & WhatsApp tips',
          keyboardType: TextInputType.phone,
          controller: _phoneController,
        ),
        const SizedBox(height: 12),
        _PasswordField(
          label: 'Password',
          hint: 'Create a password (min 8 chars)',
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          controller: _passwordController,
        ),
        const SizedBox(height: 12),
        _PasswordField(
          label: 'Confirm password',
          hint: 'Re-enter your password',
          obscure: _obscureConfirm,
          onToggle: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _agreed,
              activeColor: const Color(0xFF2F7D32),
              onChanged: (value) => setState(() => _agreed = value ?? false),
            ),
            const Expanded(
              child: Text(
                'I agree to the Terms and Privacy Policy',
                style: TextStyle(color: Color(0xFF6A6F5B)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            onPressed: _isSubmitting ? null : _handleSignup,
            child: _isSubmitting
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
                    'Create account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIconButton(imageAsset: 'lib/resources/google.png', onTap: () => _showComingSoon(context)),
        const SizedBox(width: 20),
        _SocialIconButton(icon: Icons.phone_android_outlined, onTap: () => _showComingSoon(context)),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: Color(0xFF6A6F5B)),
        ),
        TextButton(
          onPressed: _goToLogin,
          child: const Text(
            'Log in',
            style: TextStyle(
              color: Color(0xFF2F7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, LoginPage.routeName);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon!')),
    );
  }

  void _showServerSettings(BuildContext context) {
    final urlController = TextEditingController(text: ApiClient.defaultBaseUrl);
    String statusText = '';
    Color statusColor = Colors.grey;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFBF5EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: const [
                  Icon(Icons.dns_outlined, color: Color(0xFF2F7D32)),
                  SizedBox(width: 8),
                  Text('Server Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configure backend server URL:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6A6F5B)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'http://192.168.1.69:5000',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          label: const Text('Localhost (PC)', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setDialogState(() {
                              urlController.text = 'http://localhost:5000';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Wi-Fi LAN', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setDialogState(() {
                              urlController.text = 'http://192.168.1.69:5000';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setDialogState(() {
                              urlController.text = 'http://10.0.2.2:5000';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2F7D32),
                        side: const BorderSide(color: Color(0xFF2F7D32)),
                      ),
                      icon: const Icon(Icons.network_check, size: 18),
                      label: const Text('Test Connection'),
                      onPressed: () async {
                        setDialogState(() {
                          statusText = 'Testing connection...';
                          statusColor = Colors.orange;
                        });
                        final ok = await ApiClient.testConnection(urlController.text.trim());
                        setDialogState(() {
                          if (ok) {
                            statusText = 'Connected to server successfully!';
                            statusColor = const Color(0xFF2F7D32);
                          } else {
                            statusText = 'Cannot reach server at this address.';
                            statusColor = Colors.red;
                          }
                        });
                      },
                    ),
                    if (statusText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF6A6F5B))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7D32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final newUrl = urlController.text.trim();
                    if (newUrl.isNotEmpty) {
                      await ApiClient.setBaseUrl(newUrl);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Server URL set to: $newUrl')),
                        );
                        Navigator.pop(dialogCtx);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Handles the signup process when user taps "Create account" button
  Future<void> _handleSignup() async {
    final messenger = ScaffoldMessenger.of(context);

    // ============================================
    // STEP 1: Get user input
    // ============================================
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ============================================
    // STEP 2: Validate required fields
    // ============================================
    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // ============================================
    // STEP 3: Validate email format
    // ============================================
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,6}$');
    if (!emailRegex.hasMatch(email)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // ============================================
    // STEP 4: Validate password length
    // ============================================
    if (password.length < 8) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters long'),
        ),
      );
      return;
    }

    // ============================================
    // STEP 5: Validate password match
    // ============================================
    if (password != confirmPassword) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // ============================================
    // STEP 6: Validate terms agreement
    // ============================================
    if (!_agreed) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Privacy Policy to continue'),
        ),
      );
      return;
    }

    // ============================================
    // STEP 7: Show loading state
    // ============================================
    setState(() => _isSubmitting = true);
    
    try {
      // Call signup API with current ApiClient (smart URL resolution)
      final client = ApiClient();
      final authApi = AuthApi(client);

      final result = await authApi.signup(
        fullName: fullName,
        farmName: _farmNameController.text.trim().isEmpty
            ? null
            : _farmNameController.text.trim(),
        email: email,
        phoneNumber: phone,
        password: password,
        confirmPassword: confirmPassword,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Account created successfully! Please log in.',
          ),
        ),
      );

      // Navigate to login screen
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      messenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          action: msg.contains('Cannot reach') || msg.contains('timed out')
              ? SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.amber,
                  onPressed: () => _showServerSettings(context),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _TopBar extends StatelessWidget {
  final String leadingLabel;
  final String trailingLabel;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onTrailingTap;

  const _TopBar({
    required this.leadingLabel,
    required this.trailingLabel,
    this.onLeadingTap,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onLeadingTap,
          icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF6A6F5B)),
          label: Text(
            leadingLabel,
            style: const TextStyle(color: Color(0xFF6A6F5B)),
          ),
        ),
        TextButton.icon(
          onPressed: onTrailingTap,
          icon: const Icon(Icons.settings_outlined, size: 16, color: Color(0xFF2F7D32)),
          label: Text(
            trailingLabel,
            style: const TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const _LabeledField({
    required this.label,
    required this.hint,
    this.helperText,
    this.keyboardType,
    this.controller,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperStyle: const TextStyle(color: Color(0xFF9AA187)),
            filled: true,
            fillColor: const Color(0xFFFBF5EC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final TextEditingController? controller;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F2F2F),
              ),
            ),
            const Text(
              'Min. 8 characters',
              style: TextStyle(color: Color(0xFF9AA187), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFBF5EC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF9AA187),
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset;
  final VoidCallback onTap;

  const _SocialIconButton({this.icon, this.imageAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: const BorderSide(color: Color(0xFFD1D7C4)),
      ),
      child: imageAsset != null
          ? Image.asset(imageAsset!, height: 28, width: 28)
          : Icon(icon, color: const Color(0xFF2F7D32), size: 28),
    );
  }
}
