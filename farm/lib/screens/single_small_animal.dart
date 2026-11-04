// ============================================
// SINGLE SMALL ANIMAL PAGE - Single Animal Entry
// ============================================
// This screen is for adding a single animal (1-2 animals).
// User enters:
// - Animal number (1 or 2)
// - Breed
// - Body condition
// 
// This is an alternative to GroupAnimalSetupPage for small numbers.
// ============================================

import 'package:flutter/material.dart';

/// SingleSmallAnimalPage - Screen for adding single/small number of animals
/// 
/// Flow:
/// 1. Receives animal type from AddAnimal2Page (Step 2)
/// 2. User selects animal number (1 or 2)
/// 3. User selects breed
/// 4. User selects body condition
/// 5. User taps "Continue" button
/// 6. Navigates to SummaryPage with entered data
/// 
/// Navigation:
/// - Back button → AddAnimal2Page
/// - "Continue" → SummaryPage
/// 
/// Part of Add Animal Flow (Single mode):
/// AddAnimalPage (Step 1) → AddAnimal2Page (Step 2) → 
/// SingleSmallAnimalPage → SummaryPage (Step 4)
class SingleSmallAnimalPage extends StatefulWidget {
  static const routeName = '/single-small-animal';
  
  /// Animal type selected in Step 1 (Cow, Goat, etc.)
  final String animalType;

  const SingleSmallAnimalPage({super.key, required this.animalType});

  @override
  State<SingleSmallAnimalPage> createState() => _SingleSmallAnimalPageState();
}

/// State class for SingleSmallAnimalPage
/// Manages form state for single animal entry
class _SingleSmallAnimalPageState extends State<SingleSmallAnimalPage> {
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Selected animal number (1 or 2)
  int _selectedAnimalTab = 1;
  
  // Selected breed (e.g., "Jersey", "Boer")
  String? _selectedBreed;
  
  // Selected body condition (Excellent, Good, Fair, Poor)
  String? _selectedBodyCondition;

  // ============================================
  // BREED OPTIONS
  // ============================================
  // Available breeds for each animal type
  // Different animals have different breed options
  final Map<String, List<String>> _breedOptions = {
    'Cow': ['Jersey', 'Holstein-Friesian', 'Ayrshire', 'Sahiwal', 'Gir'],
    'Goat': ['Boer', 'Saanen', 'Jamunapari', 'Barbari', 'Khari'],
    'Buffalo': ['Murrah', 'Nili-Ravi', 'Pandharpuri', 'Mehsana'],
    'Chicken': ['Giriraja', 'New Hampshire', 'Rhode Island Red', 'White Leghorn'],
    'Pig': ['Landrace', 'Duroc', 'Yorkshire', 'Hampshire'],
    'Other': [],
  };

  // ============================================
  // BODY CONDITION OPTIONS
  // ============================================
  // Health/condition rating options
  final List<String> _bodyConditionOptions = ['Excellent', 'Good', 'Fair', 'Poor'];

  List<String> _getBreedsForAnimalType() {
    return _breedOptions[widget.animalType] ?? [];
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
          'Single / Small (1-2)',
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
              '3 of 4',
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
              _buildAnimalProfileCard(),
              const SizedBox(height: 24),
              _buildSmartSuggestionsCard(),
              const SizedBox(height: 24),
              _buildSeeSuggestionsButton(),
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
          'Step 3 - Basic details for up to 2 animals',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // This would be built dynamically in a real app
            Container(height: 6, width: 20, decoration: BoxDecoration(color: const Color(0xFF2F7D32).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(height: 6, width: 20, decoration: BoxDecoration(color: const Color(0xFF2F7D32).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(height: 6, width: 40, decoration: BoxDecoration(color: const Color(0xFF2F7D32), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Perfect for 1-2 animals at home or on farm',
                style: TextStyle(color: Color(0xFF6A6F5B)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildAnimalProfileCard() {
    final List<String> breedItems = _getBreedsForAnimalType();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimalTabs(),
          const SizedBox(height: 20),
          const Text('Animal profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F))),
          const SizedBox(height: 8),
          Text(
            'You are editing Animal $_selectedAnimalTab. Fill details for this animal now, then switch to Animal 2 if you have one more.',
            style: const TextStyle(color: Color(0xFF6A6F5B), fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 20),
          _buildTextField(label: 'Age', hint: 'e.g. 2 years 3 months', icon: Icons.calendar_today_outlined),
          const SizedBox(height: 16),
          // Breed Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Breed', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBreed,
                items: breedItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedBreed = newValue;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select or type breed for this animal',
                  hintStyle: const TextStyle(color: Color(0xFFB0B4A3)),
                  filled: true,
                  fillColor: const Color(0xFFF8F7F4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Weight', hint: 'e.g. 420', suffix: 'kg')),
              const SizedBox(width: 16),
              // Body Condition Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Body condition', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), fontSize: 16)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedBodyCondition,
                      items: _bodyConditionOptions.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedBodyCondition = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Optional',
                        hintStyle: const TextStyle(color: Color(0xFFB0B4A3)),
                        filled: true,
                        fillColor: const Color(0xFFF8F7F4),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPhotoField(),
          const Divider(height: 32),
          Row(
            children: const [
              Flexible(
                child: Text('Need to add another animal?', style: TextStyle(color: Color(0xFF6A6F5B))),
              ),
              SizedBox(width: 16),
              Flexible(
                child: Text('Animal 2 - Not added yet', textAlign: TextAlign.end, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAnimalTabs() {
    return Row(
      children: [
        _AnimalTab(label: 'Animal 1', isSelected: _selectedAnimalTab == 1, onTap: () => setState(() => _selectedAnimalTab = 1)),
        const SizedBox(width: 8),
        _AnimalTab(label: 'Animal 2', isSelected: _selectedAnimalTab == 2, onTap: () => setState(() => _selectedAnimalTab = 2)),
        const Spacer(),
        const Text('Add up to 2', style: TextStyle(color: Color(0xFF6A6F5B), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, IconData? icon, String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B4A3)),
            filled: true,
            fillColor: const Color(0xFFF8F7F4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF6A6F5B)) : (suffix != null ? Padding(padding: const EdgeInsets.all(12.0), child: Text(suffix, style: const TextStyle(color: Color(0xFF6A6F5B), fontWeight: FontWeight.w500))) : null),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFE4E7D6), borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [Text('Add a photo', style: TextStyle(fontWeight: FontWeight.w600)), Text('Use camera or upload from gallery', style: TextStyle(color: Color(0xFF6A6F5B)))],
                ),
              ),
              const Icon(Icons.camera_alt_outlined, color: Color(0xFF6A6F5B)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSuggestionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F7D32).withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text('Smart suggestions for 1-2 animals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: const Text('Based on age & weight', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SuggestionBullet(text: 'Basic space requirements for 1-2 healthy, stress-free animals.'),
          const _SuggestionBullet(text: 'Daily feeding suggestions, including fodder and water for a small setup.'),
          const _SuggestionBullet(text: 'Key health care tips and early disease warning signs to watch for.'),
        ],
      ),
    );
  }

  Widget _buildSeeSuggestionsButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7D32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: () {},
        child: const Text('See suggestions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

class _AnimalTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimalTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF6A6F5B), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SuggestionBullet extends StatelessWidget {
  final String text;
  const _SuggestionBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 5, color: Colors.white70)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, height: 1.4))),
        ],
      ),
    );
  }
}
