// ============================================
// ANIMALS LIST PAGE - View All Animals
// ============================================
// This screen displays all animals belonging to the logged-in user.
// Users can:
// - View all their animals in a list
// - Tap on any animal to see details
// - Pull to refresh the list
// ============================================

import 'package:farm/screens/animal_details_page.dart';
import 'package:farm/services/animal_api.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/session_manager.dart';
import 'package:flutter/material.dart';

/// AnimalsListPage - Screen showing all user's animals
/// 
/// Flow:
/// 1. Screen opens → initState() calls _loadAnimals()
/// 2. Checks if user is logged in
/// 3. Calls AnimalApi.getMyAnimals() to fetch from API
/// 4. Displays animals in a scrollable list
/// 5. User can tap any animal → AnimalDetailsPage
/// 
/// Navigation:
/// - Animal card tap → AnimalDetailsPage (with animal data)
/// - Back button → Previous screen (usually DashboardPage)
/// - "Add Animal" button → AddAnimalPage
/// 
/// Accessed from:
/// - DashboardPage "View all animals" link
/// - DashboardPage Animals icon (bottom nav)
/// - Drawer "My Animals" option
class AnimalsListPage extends StatefulWidget {
  static const routeName = '/animals-list';
  const AnimalsListPage({super.key});

  @override
  State<AnimalsListPage> createState() => _AnimalsListPageState();
}

/// State class for AnimalsListPage
/// Manages animal list data and loading states
class _AnimalsListPageState extends State<AnimalsListPage> {
  // ============================================
  // API SERVICE
  // ============================================
  // Service for fetching animals from backend
  final AnimalApi _animalApi = AnimalApi(ApiClient());
  
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Shows loading spinner while fetching animals
  bool _isLoading = true;
  
  // List of animals from API
  List<Map<String, dynamic>> _animals = [];
  
  // Error message if loading fails
  String? _errorMessage;

  /// Called when screen is first created
  /// 
  /// Flow:
  /// 1. Screen initializes
  /// 2. Immediately loads animals from API
  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  /// Loads animals from the backend API
  /// 
  /// Flow:
  /// 1. Shows loading spinner
  /// 2. Checks if user is logged in (has token)
  /// 3. Calls AnimalApi.getMyAnimals() to fetch from backend
  /// 4. Updates UI with animal list
  /// 5. If error: shows error message
  /// 
  /// Called by: initState(), pull-to-refresh
  Future<void> _loadAnimals() async {
    // ============================================
    // STEP 1: Show loading state
    // ============================================
    setState(() {
      _isLoading = true; // Show spinner
      _errorMessage = null; // Clear any previous errors
    });

    try {
      // ============================================
      // STEP 2: Check authentication
      // ============================================
      // Verify user is logged in
      if (SessionManager.instance.token == null) {
        setState(() {
          _errorMessage = 'You must be logged in to view animals.';
          _isLoading = false;
        });
        return; // Stop here if not logged in
      }

      // ============================================
      // STEP 3: Fetch animals from API
      // ============================================
      // Backend returns only animals belonging to logged-in user
      final animals = await _animalApi.getMyAnimals();
      
      // Safety check - widget might be disposed during async operation
      if (!mounted) return;
      
      // ============================================
      // STEP 4: Update UI with data
      // ============================================
      setState(() {
        _animals = animals; // Store animal list
        _isLoading = false; // Hide spinner
      });
    } catch (e) {
      // ============================================
      // ERROR HANDLING
      // ============================================
      // If API call fails (network error, server error, etc.)
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false; // Hide spinner
      });
    }
  }

  /// Returns the image path for an animal type
  /// 
  /// Maps animal type names to their corresponding image assets.
  /// Used to display animal icons in the list.
  /// 
  /// Parameters:
  /// - animalType: Type of animal (e.g., 'Cow', 'Goat', 'Pig')
  /// 
  /// Returns: Path to image asset for the animal type
  String _getAnimalImage(String? animalType) {
    // If no type provided, return default "other" image
    if (animalType == null) return 'lib/resources/other.png';
    
    // Match animal type to image (case-insensitive)
    switch (animalType.toLowerCase()) {
      case 'cow':
        return 'lib/resources/cow.png';
      case 'goat':
        return 'lib/resources/goat.png';
      case 'buffalo':
        return 'lib/resources/buffalo.png';
      case 'chicken':
        return 'lib/resources/chicken.png';
      case 'pig':
        return 'lib/resources/pig.png';
      default:
        return 'lib/resources/other.png'; // Default for unknown types
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7D32),
        foregroundColor: Colors.white,
        title: const Text(
          'My Animals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F7D32)),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadAnimals,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F7D32),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _animals.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.pets_outlined,
                              size: 64,
                              color: Color(0xFF6A6F5B),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No animals yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F2F2F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your first animal to get started',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6A6F5B),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/add-animal');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Animal'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAnimals,
                      color: const Color(0xFF2F7D32),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _animals.length,
                        itemBuilder: (context, index) {
                          final animal = _animals[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AnimalDetailsPage.routeName,
                                arguments: animal,
                              );
                            },
                            child: _AnimalCard(animal: animal, getImage: _getAnimalImage),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final Map<String, dynamic> animal;
  final String Function(String?) getImage;

  const _AnimalCard({
    required this.animal,
    required this.getImage,
  });

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalType = animal['animalType']?.toString() ?? 'Unknown';
    final entryMode = animal['entryMode']?.toString() ?? 'single';
    final createdAt = animal['createdAt']?.toString();
    
    // Handle group animals
    final groupInfo = animal['groupInfo'];
    final numberOfAnimals = groupInfo != null && groupInfo is Map
        ? groupInfo['numberOfAnimals']?.toString() ?? '1'
        : '1';
    
    final purpose = groupInfo != null && groupInfo is Map
        ? groupInfo['purpose']?.toString() ?? 'N/A'
        : animal['purpose']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Animal Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  getImage(animalType),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.pets,
                      size: 40,
                      color: Color(0xFF2F7D32),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Animal Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          animalType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F2F2F),
                          ),
                        ),
                      ),
                      if (entryMode == 'group')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E7D6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$numberOfAnimals animals',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2F7D32),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: Color(0xFF6A6F5B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Purpose: $purpose',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6A6F5B),
                        ),
                      ),
                    ],
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Color(0xFF6A6F5B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Added: ${_formatDate(createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6A6F5B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF6A6F5B),
            ),
          ],
        ),
      ),
    );
  }
}

