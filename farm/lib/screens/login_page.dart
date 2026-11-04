import 'package:farm/screens/dashboard_page.dart';
import 'package:farm/screens/signup_page.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/auth_api.dart';
import 'package:farm/services/session_manager.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Manages the state for the login page, including password visibility,
// loading state, and text field controllers.
class _LoginPageState extends State<LoginPage> {
  // Toggles the visibility of the password text.
  bool _obscurePassword = true;
  bool _rememberDevice = false;

  // Used to show a loading indicator on the login button while the API call is in progress.
  bool _isSubmitting = false;

  // Controllers to manage the text input for the email/phone and password fields.
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Color(0xFF2F7D32)),
                    tooltip: 'Server Settings',
                    onPressed: () => _showServerSettings(context),
                  ),
                ),
                _buildLogo(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Or log in with',
                    style: TextStyle(color: Color(0xFF6A6F5B)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSocialLoginButtons(),
                const SizedBox(height: 32),
                _buildSignupPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the top logo section with the app icon and name.
  Widget _buildLogo() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFFEFF2E2),
          child: Icon(Icons.eco_outlined, color: Color(0xFF4E7D44), size: 40),
        ),
        SizedBox(height: 16),
        Text(
          'Farm Companion',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2C1C),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Livestock Assistant',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6A6F5B),
          ),
        ),
      ],
    );
  }

  // Builds the main login form with email/phone, password fields, and the login button.
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email or phone',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _identifierController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'name@gmail.com or +977 98...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD1D7C4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2F7D32), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Password',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD1D7C4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2F7D32), width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _rememberDevice,
              activeColor: const Color(0xFF2F7D32),
              onChanged: (value) => setState(() => _rememberDevice = value ?? false),
            ),
            const Text('Remember me', style: TextStyle(color: Color(0xFF6A6F5B))),
            const Spacer(),
            TextButton(
              onPressed: () => _showComingSoon(context),
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            onPressed: _isSubmitting ? null : _handleLogin,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Log in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SocialLoginButton(
          label: 'Log in with Google',
          imageAsset: 'lib/resources/google.png',
          onTap: () => _showComingSoon(context),
        ),
        const SizedBox(height: 12),
        _SocialLoginButton(
          label: 'Log in with phone number',
          icon: Icons.phone_android_outlined,
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  Widget _buildSignupPrompt() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('New to Farm Companion?', style: TextStyle(color: Color(0xFF6A6F5B))),
        TextButton(
          onPressed: _goToSignup,
          child: const Text('Create an account', style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _goToSignup() {
    Navigator.pushReplacementNamed(context, SignupPage.routeName);
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

  /// Handles the entire login process when the user taps the 'Log in' button.
  Future<void> _handleLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter email/phone and password')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authApi = AuthApi(ApiClient());
      final result = await authApi.login(identifier: identifier, password: password);

      messenger.showSnackBar(SnackBar(content: Text(result['message'] ?? 'Login successful')));

      final token = result['token']?.toString();
      final user = result['user'] as Map<String, dynamic>?;
      if (token != null && user != null) {
        SessionManager.instance.setAuth(token, user);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, DashboardPage.routeName);
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

/// A reusable widget for the full-width social login buttons.
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? imageAsset;
  final IconData? icon;

  const _SocialLoginButton({
    required this.label,
    required this.onTap,
    this.imageAsset,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2F2F2F),
          side: const BorderSide(color: Color(0xFFE0E3D2)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: onTap,
        icon: imageAsset != null
            ? Image.asset(imageAsset!, height: 24)
            : Icon(icon, color: const Color(0xFF2F7D32)),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// A helper function to show a simple 'Coming soon' dialog.
void _showComingSoon(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Coming soon'),
      content: const Text('This option will be available shortly. Please continue with email for now.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}
