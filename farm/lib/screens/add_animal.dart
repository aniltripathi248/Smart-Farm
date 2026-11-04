import 'package:farm/screens/add_animal_2.dart';
import 'package:flutter/material.dart';

class AddAnimalPage extends StatefulWidget {
  static const routeName = '/add-animal';
  const AddAnimalPage({super.key});

  @override
  State<AddAnimalPage> createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  String _selectedAnimal = 'Cow';

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
              '1 of 4',
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
              _buildAnimalTypeCard(),
              const SizedBox(height: 24),
              _buildQuickTipCard(),
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
        const Text(
          'Step 1 - Choose animal type',
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
              'Simple step-by-step setup',
              style: TextStyle(color: Color(0xFF6A6F5B)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildAnimalTypeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Animal type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F)),
              ),
              Text(
                'Select what you are adding today',
                style: TextStyle(color: Color(0xFF6A6F5B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65, // Taller cards so Column content no longer overflows
            children: [
              _AnimalTypeOption(
                imageAsset: 'lib/resources/cow.png',
                label: 'Cow',
                description: 'Dairy',
                isSelected: _selectedAnimal == 'Cow',
                onTap: () => setState(() => _selectedAnimal = 'Cow'),
              ),
              _AnimalTypeOption(
                imageAsset: 'lib/resources/goat.png',
                label: 'Goat',
                description: 'Milk & meat',
                isSelected: _selectedAnimal == 'Goat',
                onTap: () => setState(() => _selectedAnimal = 'Goat'),
              ),
              _AnimalTypeOption(
                imageAsset: 'lib/resources/buffalo.png',
                label: 'Buffalo',
                description: 'Heavy dairy',
                isSelected: _selectedAnimal == 'Buffalo',
                onTap: () => setState(() => _selectedAnimal = 'Buffalo'),
              ),
              _AnimalTypeOption(
                imageAsset: 'lib/resources/chicken.png',
                label: 'Chicken',
                description: 'Eggs & meat',
                isSelected: _selectedAnimal == 'Chicken',
                onTap: () => setState(() => _selectedAnimal = 'Chicken'),
              ),
              _AnimalTypeOption(
                imageAsset: 'lib/resources/pig.png',
                label: 'Pig',
                description: 'Meat',
                isSelected: _selectedAnimal == 'Pig',
                onTap: () => setState(() => _selectedAnimal = 'Pig'),
              ),
              _AnimalTypeOption(
                imageAsset: 'lib/resources/other.png',
                label: 'Other',
                description: 'Custom',
                isSelected: _selectedAnimal == 'Other',
                onTap: () => setState(() => _selectedAnimal = 'Other'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline, color: Color(0xFF2F7D32)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can add more animal types later from the Animals tab.',
              style: TextStyle(color: Color(0xFF6A6F5B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAnimalPage2(animalType: _selectedAnimal),
            ),
          );
        },
        child: const Text(
          'Continue to quantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Skip for now',
          style: TextStyle(
            color: Color(0xFF6A6F5B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AnimalTypeOption extends StatelessWidget {
  final String imageAsset;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimalTypeOption({
    required this.imageAsset,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F7D32) : const Color(0xFFF8F7F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              height: 40,
              width: 40,
              color: isSelected ? Colors.white.withOpacity(0.9) : null,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF2F2F2F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF6A6F5B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
