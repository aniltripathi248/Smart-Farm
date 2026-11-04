// ============================================
// FARM COMPANION ONBOARDING - Page 1 of 3
// ============================================
// This is the first onboarding screen shown when app starts.
// It introduces the app and its features.
// 
// Users can:
// - Skip onboarding and go to login/signup
// - Continue to next onboarding page
// - Go directly to login or signup
// 
// Flow: Onboarding 1 → Onboarding 2 → Onboarding 3 → Login/Signup
// ============================================

import 'package:farm/screens/add_animal.dart';
import 'package:farm/screens/farm_companion_onboarding2.dart';
import 'package:farm/screens/login_page.dart';
import 'package:farm/screens/signup_page.dart';
import 'package:flutter/material.dart';

/// FarmCompanionOnboarding - First onboarding screen
/// 
/// Flow:
/// 1. App starts → This screen is shown (initialRoute)
/// 2. User sees app introduction
/// 3. User can:
///    - Tap "Next" → FarmCompanionOnboarding2
///    - Tap "Skip" → LoginPage
///    - Tap "Log in" → LoginPage
///    - Tap "Create your account" → SignupPage
/// 
/// Navigation:
/// - "Next" → FarmCompanionOnboarding2
/// - "Skip" → LoginPage
/// - "Log in" → LoginPage
/// - "Create your account" → SignupPage
/// 
/// This is the initial route of the app (set in main.dart)
class FarmCompanionOnboarding extends StatelessWidget {
  static const routeName = '/';
  const FarmCompanionOnboarding({super.key});

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
                _buildSkipButton(),
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 16),
                _buildContentCard(theme),
                const SizedBox(height: 24),
                _buildPager(context),
                const SizedBox(height: 16),
                _buildNextButton(context),
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

  Widget _buildSkipButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Skip',
            style: TextStyle(
              color: Color(0xFF6A6F5B),
              fontSize: 16,
            ),
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
                'lib/resources/onboarding_1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Smart livestock management',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2F2F2F),
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep all your animals, health records, and tasks organized in one simple place.',
            style: TextStyle(
              color: Color(0xFF6A6F5B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const _FeatureBullet(
            text: 'Track animals by type, age, and health status.',
          ),
          const _FeatureBullet(
            text: 'See important tasks for today at a glance.',
          ),
          const _FeatureBullet(
            text: 'Get gentle reminders before critical events.',
          ),
        ],
      ),
    );
  }

  Widget _buildPager(BuildContext context) {
    return Row(
      children: [
        const _Dot(isActive: true),
        const SizedBox(width: 8),
        const _Dot(),
        const SizedBox(width: 8),
        const _Dot(),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AddAnimalPage.routeName);
          },
          child: const Text(
            'Continue as guest',
            style: TextStyle(
              color: Color(0xFF4E7D44),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
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
          Navigator.pushNamed(context, FarmCompanionOnboarding2.routeName);
        },
        child: const Text(
          'Next',
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
              'Soon you’ll use the green “+” button to quickly add animals, tasks, or scans.',
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
