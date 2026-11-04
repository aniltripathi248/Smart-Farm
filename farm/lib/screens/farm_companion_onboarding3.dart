// ============================================
// FARM COMPANION ONBOARDING 3 - Page 3 of 3 (Final)
// ============================================
// This is the final onboarding screen.
// It completes the app introduction.
// 
// Users can:
// - Go back to previous onboarding page
// - Start as guest (skip login)
// - Go to login/signup
// ============================================

import 'package:farm/screens/add_animal.dart';
import 'package:farm/screens/login_page.dart';
import 'package:farm/screens/signup_page.dart';
import 'package:flutter/material.dart';

/// FarmCompanionOnboarding3 - Final onboarding screen
/// 
/// Flow:
/// 1. User reaches this page from FarmCompanionOnboarding2 (Page 2)
/// 2. User sees final app features
/// 3. User can:
///    - Tap "Back" → FarmCompanionOnboarding2
///    - Tap "Start as guest" → AddAnimalPage (without login)
///    - Tap "Log in" → LoginPage
///    - Tap "Create your account" → SignupPage
/// 
/// Navigation:
/// - "Back" → FarmCompanionOnboarding2
/// - "Start as guest" → AddAnimalPage
/// - "Log in" → LoginPage
/// - "Create your account" → SignupPage
class FarmCompanionOnboarding3 extends StatelessWidget {
  static const routeName = '/onboarding3';
  const FarmCompanionOnboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBackButton(context),
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 16),
                _buildContentCard(theme),
                const SizedBox(height: 24),
                _buildPagerDots(),
                const SizedBox(height: 16),
                _buildStartAsGuestButton(context),
                const SizedBox(height: 12),
                _buildAuthPrompts(context),
                const SizedBox(height: 24),
                _buildLegalNote(theme),
                const SizedBox(height: 16),
                _buildFooterHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A6F5B), size: 16),
          label: const Text(
            'Back',
            style: TextStyle(
              color: Color(0xFF6A6F5B),
              fontSize: 16,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFFEFF2E2),
          child: Icon(
            Icons.eco_outlined,
            color: Color(0xFF4E7D44),
            size: 32,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Farm Companion',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Livestock Assistant',
          style: TextStyle(
            color: Color(0xFF6A6F5B),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                'lib/resources/onboarding_3.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildGuestModeChip(),
          const SizedBox(height: 16),
          Text(
            'You\'re starting as a guest',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try Farm Companion with basic features first. You can create a full account anytime to sync and back up your data.',
            style: TextStyle(
              color: Color(0xFF6A6F5B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const _FeatureBullet(text: 'Animals, tasks, and scans are saved on this device.'),
          const _FeatureBullet(text: 'Switch to a full account later without losing your records.'),
          const _FeatureBullet(text: 'Some insights and multi-device sync are limited in guest mode.'),
          const SizedBox(height: 16),
          _buildTipBox(),
        ],
      ),
    );
  }

  Widget _buildGuestModeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.person_outline, size: 16, color: Color(0xFFC88A55)),
          SizedBox(width: 6),
          Text('Guest mode', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2F2F2F))),
          SizedBox(width: 12),
          Text('No sign-up needed', style: TextStyle(color: Color(0xFF6A6F5B))),
        ],
      ),
    );
  }

  Widget _buildTipBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Color(0xFF6A6F5B), height: 1.4, fontSize: 14),
          children: [
            TextSpan(text: 'Tip: ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: 'When you\'re ready, create an account from Settings to keep your herd data safely synced.'),
          ],
        ),
      ),
    );
  }

  Widget _buildPagerDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Dot(),
        SizedBox(width: 8),
        _Dot(),
        SizedBox(width: 8),
        _Dot(isActive: true),
      ],
    );
  }

  Widget _buildStartAsGuestButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, AddAnimalPage.routeName);
        },
        child: const Text(
          'Start as guest',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthPrompts(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(color: Color(0xFF6A6F5B)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, LoginPage.routeName);
              },
              child: const Text(
                'Log in',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F7D32),
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, SignupPage.routeName);
          },
          child: const Text(
            'Create your account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F7D32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalNote(ThemeData theme) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'By continuing, you agree to our ',
        style: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6A6F5B),
        ),
        children: const [
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F7D32),
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F7D32),
            ),
          ),
          TextSpan(text: ', even in guest mode.'),
        ],
      ),
    );
  }

  Widget _buildFooterHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2E2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.add_circle_outline,
            color: Color(0xFF4E7D44),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'On the dashboard, use the green “+” button to add animals, tasks, or quick health scans.',
              style: TextStyle(
                color: Color(0xFF4E7D44),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String text;

  const _FeatureBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 5,
              color: Color(0xFFC88A55),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6A6F5B),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;

  const _Dot({this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2F7D32) : const Color(0xFFD1D7C4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
