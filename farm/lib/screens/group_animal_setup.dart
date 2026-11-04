// ============================================
// GROUP ANIMAL SETUP PAGE - Step 3 of Add Animal Flow
// ============================================
// This is the third step in adding animals (for group mode).
// User enters:
// - Number of animals
// - Purpose (Dairy, Meat, Breeding, etc.)
// 
// The page automatically calculates:
// - Shelter area needed
// - Water requirement per day
// - Estimated monthly cost
// 
// Flow: AddAnimalPage (Step 1) → AddAnimal2Page (Step 2) → 
//       GroupAnimalSetupPage (Step 3) → SummaryPage (Step 4)
// ============================================

import 'package:farm/screens/summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// GroupAnimalSetupPage - Third step in adding animals (group setup)
/// 
/// Flow:
/// 1. Receives animal type from AddAnimal2Page (Step 2)
/// 2. User enters number of animals
/// 3. User selects purpose (Dairy, Meat, etc.)
/// 4. Page automatically calculates recommendations (area, water, cost)
/// 5. User taps "Continue" button
/// 6. Navigates to SummaryPage with all data
/// 
/// Navigation:
/// - Back button → AddAnimal2Page
/// - "Continue" → SummaryPage (with all entered data)
/// 
/// Part of Add Animal Flow:
/// AddAnimalPage (Step 1) → AddAnimal2Page (Step 2) → 
/// GroupAnimalSetupPage (Step 3) → SummaryPage (Step 4)
class GroupAnimalSetupPage extends StatefulWidget {
  static const routeName = '/group-animal-setup';
  
  /// Animal type selected in Step 1 (Cow, Goat, etc.)
  final String animalType;

  const GroupAnimalSetupPage({super.key, required this.animalType});

  @override
  State<GroupAnimalSetupPage> createState() => _GroupAnimalSetupPageState();
}

/// State class for GroupAnimalSetupPage
/// Manages form state and automatic calculations
class _GroupAnimalSetupPageState extends State<GroupAnimalSetupPage> {
  // ============================================
  // TEXT CONTROLLERS
  // ============================================
  // Controller for number of animals input field
  final _numberController = TextEditingController();
  
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Selected purpose (Dairy, Meat, Breeding, etc.)
  String _selectedPurpose = '';

  // ============================================
  // CALCULATED RECOMMENDATIONS
  // ============================================
  // These values are automatically calculated based on:
  // - Number of animals entered
  // - Animal type
  // Updated in real-time as user types
  double _shelterArea = 0; // Square meters needed
  double _waterPerDay = 0; // Liters per day
  int _monthlyCost = 0; // Estimated monthly cost

  // ============================================
  // PURPOSE OPTIONS
  // ============================================
  // Available purpose options for each animal type
  // Different animals have different purpose options
  final Map<String, List<String>> _purposeOptions = {
    'Cow': ['Dairy', 'Meat', 'Breeding', 'Mixed'],
    'Goat': ['Dairy', 'Meat', 'Breeding', 'Mixed'],
    'Buffalo': ['Dairy', 'Meat', 'Breeding', 'Mixed'],
    'Chicken': ['Eggs', 'Meat', 'Breeding', 'Mixed'],
    'Pig': ['Meat', 'Breeding', 'Mixed'],
    'Other': ['Mixed'],
  };

  /// Called when screen is first created
  /// 
  /// Flow:
  /// 1. Sets default purpose based on animal type
  /// 2. Adds listener to number controller for real-time calculations
  @override
  void initState() {
    super.initState();
    // Set default purpose to first option for this animal type
    _selectedPurpose = (_purposeOptions[widget.animalType] ?? ['Mixed']).first;
    // Listen to number input changes to recalculate recommendations
    _numberController.addListener(_calculateRecommendations);
  }

  @override
  void dispose() {
    _numberController.removeListener(_calculateRecommendations);
    _numberController.dispose();
    super.dispose();
  }

  /// Calculates recommendations based on number of animals
  /// 
  /// Flow:
  /// 1. Gets number of animals from text field
  /// 2. Looks up base values for animal type (per animal)
  /// 3. Multiplies by number of animals
  /// 4. Updates UI with calculated values
  /// 
  /// Called by: _numberController listener (real-time as user types)
  /// 
  /// Calculations:
  /// - Shelter Area = number × area per animal
  /// - Water per Day = number × water per animal
  /// - Monthly Cost = number × cost per animal
  void _calculateRecommendations() {
    // Parse number of animals from text field
    final int numAnimals = int.tryParse(_numberController.text) ?? 0;

    // If invalid or zero, reset all values
    if (numAnimals <= 0) {
      setState(() {
        _shelterArea = 0;
        _waterPerDay = 0;
        _monthlyCost = 0;
      });
      return;
    }

    // ============================================
    // BASE VALUES (per animal)
    // ============================================
    // These are the requirements per single animal
    // Values vary by animal type
    double shelterPerAnimal = 0; // Square meters per animal
    double waterPerAnimal = 0; // Liters per day per animal
    int costPerAnimal = 0; // Monthly cost per animal

    // ============================================
    // ANIMAL-SPECIFIC VALUES
    // ============================================
    // Set base values based on animal type
    // Different animals have different space, water, and cost requirements
    switch (widget.animalType) {
      case 'Cow':
        shelterPerAnimal = 10; // m² per cow
        waterPerAnimal = 65; // Liters per day per cow
        costPerAnimal = 35000; // NPR per month per cow
        break;
      case 'Goat':
        shelterPerAnimal = 2; // m² per goat
        waterPerAnimal = 10; // Liters per day per goat
        costPerAnimal = 7000; // NPR per month per goat
        break;
      // Default values for other animals (can be expanded)
      default:
        shelterPerAnimal = 5;
        waterPerAnimal = 30;
        costPerAnimal = 800;
        break;
    }

    setState(() {
      _shelterArea = numAnimals * shelterPerAnimal;
      _waterPerDay = numAnimals * waterPerAnimal;
      _monthlyCost = numAnimals * costPerAnimal;
    });
  }

  void _onContinue() {
    if (_numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the number of animals.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int numberOfAnimals = int.parse(_numberController.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPage(
          animalType: widget.animalType,
          numberOfAnimals: numberOfAnimals,
          purpose: _selectedPurpose,
          monthlyCost: _monthlyCost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Farm group',
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
            child: const Text('3 of 4', style: TextStyle(color: Color(0xFF2F2F2F), fontWeight: FontWeight.w600)),
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
              _buildGroupDetailsCard(),
              const SizedBox(height: 24),
              _buildSmartRecommendationsCard(),
              const SizedBox(height: 32),
              _buildContinueButton(),
              const SizedBox(height: 12),
              _buildSkipButton(),
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
        const Text('Step 3 - Farm setup', style: TextStyle(fontSize: 18, color: Color(0xFF2F2F2F), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(height: 6, width: 20, decoration: BoxDecoration(color: const Color(0xFF2F7D32).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(height: 6, width: 20, decoration: BoxDecoration(color: const Color(0xFF2F7D32).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(height: 6, width: 40, decoration: BoxDecoration(color: const Color(0xFF2F7D32), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 12),
            const Text('Plan land, shelter & feeding', style: TextStyle(color: Color(0xFF6A6F5B))),
          ],
        )
      ],
    );
  }

  Widget _buildGroupDetailsCard() {
    List<String> purposes = _purposeOptions[widget.animalType] ?? ['Mixed'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Group details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F))),
          const SizedBox(height: 16),
          _buildTextField(label: 'Number of animals', hint: 'e.g. 12', controller: _numberController, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(label: 'Land available', hint: 'e.g. 1.5 acres', optional: true, icon: Icons.straighten),
          const SizedBox(height: 16),
          const Text('Purpose', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: purposes.map((purpose) {
              return ChoiceChip(
                label: Text(purpose),
                selected: _selectedPurpose == purpose,
                onSelected: (selected) {
                  setState(() {
                    if (selected) _selectedPurpose = purpose;
                  });
                },
                selectedColor: const Color(0xFF2F7D32),
                labelStyle: TextStyle(color: _selectedPurpose == purpose ? Colors.white : const Color(0xFF2F2F2F), fontWeight: FontWeight.w600),
                backgroundColor: const Color(0xFFF8F7F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide.none),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Smart recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF2F7D32), borderRadius: BorderRadius.circular(16)),
                child: const Text('Auto-calculated', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _RecommendationTile(label: 'Shelter area', value: '~ ${_shelterArea.toStringAsFixed(0)} m²')),
              const SizedBox(width: 12),
              const Expanded(child: _RecommendationTile(label: 'Feeding system', value: 'Semi-intensive')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _RecommendationTile(label: 'Water per day', value: '~ ${_waterPerDay.toStringAsFixed(0)} L')),
              const SizedBox(width: 12),
              const Expanded(child: _RecommendationTile(label: 'Cleaning frequency', value: 'Daily')),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Adjust the numbers above and we will refine these recommendations.', style: TextStyle(color: Color(0xFF6A6F5B), height: 1.4)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFDCCAB5), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated monthly cost', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF433B30))),
                Text(' ₹ ${_monthlyCost.toString()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF433B30))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, TextEditingController? controller, bool optional = false, IconData? icon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), fontSize: 16)),
            if (optional) const Text('   Optional', style: TextStyle(color: Color(0xFF6A6F5B))), 
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B4A3)),
            filled: true,
            fillColor: const Color(0xFFF8F7F4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF6A6F5B)) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7D32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: _onContinue,
        child: const Text('Continue to summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text('Skip recommendations', style: TextStyle(color: Color(0xFF6A6F5B), fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isAction;

  const _RecommendationTile({required this.label, required this.value, this.isAction = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6A6F5B), fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isAction ? const Color(0xFF2F7D32) : const Color(0xFF2F2F2F))),
        ],
      ),
    );
  }
}
