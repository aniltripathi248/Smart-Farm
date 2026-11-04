// ============================================
// ADD ANIMAL PAGE 2 - Step 2 of Add Animal Flow
// ============================================
// This is the second step in adding animals.
// User chooses entry mode: Single animal or Group of animals.
// 
// Flow: AddAnimalPage (Step 1) → AddAnimal2Page (Step 2) → 
//       GroupAnimalSetupPage (Step 3) OR SingleSmallAnimalPage → SummaryPage
// ============================================

import 'package:farm/screens/group_animal_setup.dart';
import 'package:farm/screens/single_small_animal.dart';
import 'package:flutter/material.dart';

/// AddAnimalPage2 - Second step in adding animals (entry mode selection)
/// 
/// Flow:
/// 1. Receives animal type from AddAnimalPage (Step 1)
/// 2. User selects entry mode: "Single" or "Group"
/// 3. User taps "Continue" button
/// 4. Navigates to:
///    - GroupAnimalSetupPage if "Group" selected
///    - SingleSmallAnimalPage if "Single" selected
/// 
/// Navigation:
/// - Back button → AddAnimalPage
/// - "Continue" → GroupAnimalSetupPage or SingleSmallAnimalPage
/// 
/// Part of Add Animal Flow:
/// AddAnimalPage (Step 1) → AddAnimal2Page (Step 2) → Next step
class AddAnimalPage2 extends StatefulWidget {
  static const routeName = '/add-animal-2';
  
  /// Animal type selected in Step 1 (Cow, Goat, etc.)
  final String animalType;

  const AddAnimalPage2({super.key, required this.animalType});

  @override
  State<AddAnimalPage2> createState() => _AddAnimalPage2State();
}

/// State class for AddAnimalPage2
/// Manages entry mode selection
class _AddAnimalPage2State extends State<AddAnimalPage2> {
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Selected entry mode: 'Single' or 'Group'
  // Default: 'Single'
  String _selectedQuantity = 'Single';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add animals',
          style: TextStyle(
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.w700,
          ),
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
            child: const Text(
              '2 of 4',
              style: TextStyle(
                color: Color(0xFF2F2F2F),
                fontWeight: FontWeight.w600,
              ),
            ),
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
              _buildQuantityCard(),
              const SizedBox(height: 24),
              _buildContinueButton(),
              const SizedBox(height: 12),
              _buildBackButton(),
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
        const Text(
          'Step 2 - Select quantity',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 20,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF2F7D32).withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF2F7D32),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 20,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Helps tailor care suggestions',
              style: TextStyle(color: Color(0xFF6A6F5B)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildQuantityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How many are you adding?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Are you adding 1-2 animals, or a larger group for farming?',
            style: TextStyle(color: Color(0xFF6A6F5B), fontSize: 16),
          ),
          const SizedBox(height: 20),
          _QuantityOption(
            icon: Icons.person_outline,
            label: 'Single / Small',
            description: '1-2 animals with simple care tips',
            tag: 'Recommended for\nbeginners',
            isSelected: _selectedQuantity == 'Single',
            onTap: () => setState(() => _selectedQuantity = 'Single'),
          ),
          const SizedBox(height: 12),
          _QuantityOption(
            icon: Icons.people_outline,
            label: 'Group / Farm setup',
            description: '3 or more animals with farm planning',
            tag: '',
            isSelected: _selectedQuantity == 'Group',
            onTap: () => setState(() => _selectedQuantity = 'Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        onPressed: () {
          if (_selectedQuantity == 'Single') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleSmallAnimalPage(animalType: widget.animalType),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupAnimalSetupPage(animalType: widget.animalType),
              ),
            );
          }
        },
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(
          'Back to animal type',
          style: TextStyle(
            color: Color(0xFF6A6F5B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _QuantityOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuantityOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F7D32) : const Color(0xFFF8F7F4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 16),
              child: Icon(icon, size: 28, color: isSelected ? Colors.white70 : Colors.black54),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF2F2F2F),
                          ),
                        ),
                      ),
                      if (tag.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black.withOpacity(0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF6A6F5B),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF6A6F5B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
