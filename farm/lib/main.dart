// ============================================
// MAIN APPLICATION ENTRY POINT
// ============================================
// This file sets up the Flutter app with:
// - Theme configuration
// - Route definitions (navigation)
// - Initial route (where app starts)
// ============================================

// Import screen files
import 'package:farm/screens/add_animal.dart';
import 'package:farm/screens/animal_details_page.dart';
import 'package:farm/screens/animals_list_page.dart';
import 'package:farm/screens/dashboard_page.dart';
import 'package:farm/screens/edit_profile_page.dart';
import 'package:farm/screens/farm_companion_onboarding.dart';
import 'package:farm/screens/farm_companion_onboarding2.dart';
import 'package:farm/screens/farm_companion_onboarding3.dart';
import 'package:farm/screens/login_page.dart';
import 'package:farm/screens/signup_page.dart';
import 'package:farm/screens/tasks_page.dart';
import 'package:farm/services/api_client.dart';
import 'package:flutter/material.dart';

/// Main entry point of the application
/// 
/// Flow:
/// 1. App starts here
/// 2. Initializes ApiClient settings (loads saved Base URL)
/// 3. Creates MyApp widget
/// 4. MyApp sets up MaterialApp with routes
/// 5. App navigates to initialRoute (onboarding)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.init();
  runApp(const MyApp());
}

/// Root widget of the application
/// 
/// This widget configures:
/// - App theme (colors, styling)
/// - Navigation routes (all screens)
/// - Initial route (where app starts)
/// 
/// Flow:
/// 1. App starts → initialRoute is FarmCompanionOnboarding
/// 2. User goes through onboarding → Login or Signup
/// 3. After login → DashboardPage
/// 4. User navigates between screens using routes
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Companion',
      debugShowCheckedModeBanner: false, // Hide debug banner in top-right
      
      // ============================================
      // THEME CONFIGURATION
      // ============================================
      // Sets app-wide colors and styling
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7D32)), // Green color scheme
        scaffoldBackgroundColor: const Color(0xFFE4E7D6), // Light green background
        useMaterial3: true, // Use Material Design 3
      ),
      
      // ============================================
      // INITIAL ROUTE
      // ============================================
      // App starts at onboarding screen
      // User sees 3 onboarding pages, then chooses Login or Signup
      initialRoute: FarmCompanionOnboarding.routeName,
      
      // ============================================
      // ROUTE DEFINITIONS
      // ============================================
      // Maps route names to screen widgets
      // Used for navigation: Navigator.pushNamed(context, routeName)
      routes: {
        // Onboarding screens (shown when app first opens)
        FarmCompanionOnboarding.routeName: (_) => const FarmCompanionOnboarding(),
        FarmCompanionOnboarding2.routeName: (_) => const FarmCompanionOnboarding2(),
        FarmCompanionOnboarding3.routeName: (_) => const FarmCompanionOnboarding3(),
        
        // Animal management screens
        AddAnimalPage.routeName: (_) => const AddAnimalPage(), // Step 1: Select animal type
        AnimalDetailsPage.routeName: (_) => const AnimalDetailsPage(), // View animal details
        EditAnimalPage.routeName: (_) => const EditAnimalPage(), // Edit animal info
        AnimalsListPage.routeName: (_) => const AnimalsListPage(), // List all animals
        
        // Main screens
        DashboardPage.routeName: (_) => const DashboardPage(), // Main hub after login
        EditProfilePage.routeName: (_) => const EditProfilePage(), // Edit user profile
        TasksPage.routeName: (_) => const TasksPage(), // View and complete tasks
        
        // Authentication screens
        LoginPage.routeName: (_) => const LoginPage(), // User login
        SignupPage.routeName: (_) => const SignupPage(), // User registration
      },
    );
  }
}
