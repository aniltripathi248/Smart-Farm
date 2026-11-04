// ============================================
// SUMMARY PAGE - Final Step of Add Animal Flow
// ============================================
// This is the final step (Step 4 of 4) in adding animals.
// It shows:
// - Summary of animal details entered
// - Care recommendations
// - Save button to create the animal
// 
// After user confirms, animal is saved to backend via API.
// ============================================

import 'package:farm/screens/dashboard_page.dart';
import 'package:farm/services/animal_api.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/session_manager.dart';
import 'package:flutter/material.dart';

/// SummaryPage - Final review screen before saving animal
/// 
/// Flow:
/// 1. User reaches this page from GroupAnimalSetupPage (Step 3)
/// 2. Page receives animal data via constructor parameters
/// 3. Displays summary of all entered information
/// 4. Shows care recommendations
/// 5. User taps "Save to my farm" button
/// 6. Calls AnimalApi.createGroupFromSummary() to save to backend
/// 7. Navigates to DashboardPage
/// 8. DashboardPage reloads animals list
/// 
/// Navigation:
/// - Back button → GroupAnimalSetupPage
/// - "Save to my farm" → DashboardPage (after save)
/// 
/// Part of Add Animal Flow:
/// AddAnimalPage (Step 1) → AddAnimal2Page (Step 2) → 
/// GroupAnimalSetupPage (Step 3) → SummaryPage (Step 4) → DashboardPage
class SummaryPage extends StatelessWidget {
  static const routeName = '/summary';

  // ============================================
  // ANIMAL DATA (passed from previous step)
  // ============================================
  // All data collected from previous steps in the flow
  final String animalType; // Type of animal (Cow, Goat, etc.)
  final int numberOfAnimals; // Number of animals in group
  final String purpose; // Purpose (Dairy, Meat, etc.)
  final int monthlyCost; // Estimated monthly cost

  const SummaryPage({
    super.key,
    required this.animalType,
    required this.numberOfAnimals,
    required this.purpose,
    required this.monthlyCost,
  });

  // ============================================
  // API SERVICE
  // ============================================
  // Service for saving animal to backend
  AnimalApi get _animalApi => AnimalApi(ApiClient());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Summary',
          style: TextStyle(color: Color(0xFF2F2F2F), fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text('4 of 4', style: TextStyle(color: Color(0xFF2F2F2F), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 24),
              _buildAnimalDetailsCard(),
              const SizedBox(height: 24),
              _buildCareRecommendationsCard(),
              const SizedBox(height: 32),
              _buildSaveButton(context),
              const SizedBox(height: 12),
              _buildViewCareGuideButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 4 - Review & save', style: TextStyle(fontSize: 18, color: Color(0xFF2F2F2F), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(height: 6, width: 20, decoration: BoxDecoration(color: const Color(0xFF2F7D32).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(height: 6, width: 20, decoration: BoxDecoration(color: const Color(0xFF2F7D32).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(height: 6, width: 20, decoration: BoxDecoration(color: const Color(0xFF2F7D32).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(height: 6, width: 40, decoration: BoxDecoration(color: const Color(0xFF2F7D32), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 12),
            const Text('Check details before saving', style: TextStyle(color: Color(0xFF6A6F5B))),
          ],
        )
      ],
    );
  }

  Widget _buildAnimalDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Animal details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F))),
              const Text('Group / Farm setup', style: TextStyle(color: Color(0xFF6A6F5B), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailItem(label: 'Type', value: animalType),
              _DetailItem(label: 'Weight', value: 'N/A'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailItem(label: 'Age', value: 'N/A'),
              _DetailItem(label: 'Purpose', value: purpose),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailItem(label: 'Breed', value: 'N/A'),
              _DetailItem(label: 'Group size', value: '$numberOfAnimals animal${numberOfAnimals > 1 ? 's' : ''}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCareRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Care recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Text('Auto-generated', style: TextStyle(color: Color(0xFF6A6F5B), fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RecommendationBullet(label: 'Space', value: 'At least 8-10 m² of clean, dry area with shade per animal.'),
          _RecommendationBullet(label: 'Feeding', value: 'Balanced ration with green fodder, dry fodder and mineral mix.'),
          _RecommendationBullet(label: 'Water', value: 'Sufficient clean water per day, always accessible.'),
          _RecommendationBullet(label: 'Health', value: 'Vaccinations as per local schedule and regular deworming.'),
          _RecommendationBullet(label: 'Monitoring', value: 'Use disease scan when you notice unusual behaviour or symptoms.'),
          _RecommendationBullet(label: 'Estimated monthly cost', value: '₹ ${monthlyCost.toString()} (feed, health & maintenance).'),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7D32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: () => _handleSave(context),
        child: const Text('Save animal(s)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildViewCareGuideButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2F7D32), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: () {},
        child: const Text('View care guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F7D32))),
      ),
    );
  }

  /// Handles saving the animal to the backend
  /// 
  /// Flow:
  /// 1. Checks if user is logged in (has token)
  /// 2. Calls AnimalApi.createGroupFromSummary() with all animal data
  /// 3. Backend creates animal record in database
  /// 4. Shows success message
  /// 5. Navigates to DashboardPage
  /// 6. DashboardPage reloads animals list
  /// 
  /// Called by: "Save animal(s)" button onPressed
  Future<void> _handleSave(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    
    // ============================================
    // STEP 1: Check authentication
    // ============================================
    // Verify user is logged in before saving
    if (SessionManager.instance.token == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please log in before saving animals.')),
      );
      return; // Stop here if not logged in
    }

    try {
      // ============================================
      // STEP 2: Save animal to backend
      // ============================================
      // Send all animal data to backend API
      // Backend creates animal record in database
      await _animalApi.createGroupFromSummary(
        animalType: animalType,
        numberOfAnimals: numberOfAnimals,
        purpose: purpose,
        monthlyCost: monthlyCost,
      );

      // ============================================
      // STEP 3: Show success message
      // ============================================
      messenger.showSnackBar(
        const SnackBar(content: Text('Animals saved successfully.')),
      );

      // ============================================
      // STEP 4: Navigate to dashboard
      // ============================================
      // Clear all previous routes and go to dashboard
      // DashboardPage will reload animals list automatically
      Navigator.pushNamedAndRemoveUntil(
        context,
        DashboardPage.routeName,
        (route) => false, // Remove all previous routes from stack
      );
    } catch (e) {
      // ============================================
      // ERROR HANDLING
      // ============================================
      // If save fails (network error, validation error, etc.)
      // Show error message to user
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6A6F5B), fontSize: 13)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2F2F2F))),
      ],
    );
  }
}

class _RecommendationBullet extends StatelessWidget {
  final String label;
  final String value;

  const _RecommendationBullet({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 5, color: Color(0xFF2F7D32)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF2F2F2F), fontSize: 15, height: 1.4),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value, style: const TextStyle(color: Color(0xFF6A6F5B))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
