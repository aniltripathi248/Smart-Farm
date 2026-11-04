// ============================================
// ANIMAL DETAILS PAGE - View Animal Information
// ============================================
// This screen displays detailed information about a single animal.
// Users can:
// - View all animal details (type, purpose, number, cost, dates)
// - Edit animal information
// - Delete animal (with confirmation)
// ============================================

import 'package:farm/services/animal_api.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/session_manager.dart';
import 'package:flutter/material.dart';

/// AnimalDetailsPage - Screen showing detailed information about a single animal
/// 
/// Flow:
/// 1. Screen opens with animal data passed as route argument
/// 2. didChangeDependencies() extracts animal data from arguments
/// 3. Displays animal information in detail cards
/// 4. User can tap Edit button → EditAnimalPage
/// 5. User can tap Delete button → Confirmation dialog → Delete from API
/// 
/// Navigation:
/// - Back button → AnimalsListPage
/// - Edit button → EditAnimalPage
/// - Delete button → Confirmation → AnimalsListPage (after delete)
/// 
/// Accessed from: AnimalsListPage (when user taps animal card)
/// 
/// Data: Animal data passed via route arguments (not fetched from API initially)
class AnimalDetailsPage extends StatefulWidget {
  static const routeName = '/animal-details';
  const AnimalDetailsPage({super.key});

  @override
  State<AnimalDetailsPage> createState() => _AnimalDetailsPageState();
}

/// State class for AnimalDetailsPage
/// Manages animal data display and edit/delete operations
class _AnimalDetailsPageState extends State<AnimalDetailsPage> {
  // ============================================
  // API SERVICE
  // ============================================
  // Service for animal operations (get, update, delete)
  final AnimalApi _animalApi = AnimalApi(ApiClient());
  
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Animal data object (passed from AnimalsListPage)
  Map<String, dynamic>? _animal;
  
  // Shows loading spinner while processing
  bool _isLoading = true;
  
  // Shows loading spinner on delete button while deleting
  bool _isDeleting = false;
  
  // Error message if animal data not found
  String? _errorMessage;

  /// Called when screen dependencies are available
  /// 
  /// Flow:
  /// 1. Screen is ready to receive route arguments
  /// 2. Extracts animal data from route arguments
  /// 3. Stores animal data in state
  /// 4. If no data found, shows error
  /// 
  /// Note: Uses didChangeDependencies instead of initState because
  /// route arguments are only available after dependencies are set
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get animal data passed from AnimalsListPage via route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      // Animal data found - store it and hide loading
      _animal = args;
      _isLoading = false;
    } else {
      // No animal data - show error
      _errorMessage = 'Animal data not found';
      _isLoading = false;
    }
  }

  /// Returns the image path for an animal type
  /// 
  /// Maps animal type names to their corresponding image assets.
  /// Used to display animal icon in details page.
  /// 
  /// Parameters:
  /// - animalType: Type of animal (e.g., 'Cow', 'Goat', 'Pig')
  /// 
  /// Returns: Path to image asset for the animal type
  String _getAnimalImage(String? animalType) {
    if (animalType == null) return 'lib/resources/other.png';
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
        return 'lib/resources/other.png';
    }
  }

  /// Formats a date string to readable format
  /// 
  /// Converts ISO date string (e.g., "2024-01-15T10:30:00Z") 
  /// to readable format (e.g., "15/1/2024")
  /// 
  /// Parameters:
  /// - dateString: ISO date string from API
  /// 
  /// Returns: Formatted date string or 'N/A' if invalid
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      // Parse ISO date string to DateTime
      final date = DateTime.parse(dateString);
      // Format as DD/MM/YYYY
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      // If parsing fails, return original string
      return dateString;
    }
  }

  /// Deletes the animal from the user's farm
  /// 
  /// Flow:
  /// 1. Shows confirmation dialog
  /// 2. If user confirms:
  ///    - Shows loading spinner on delete button
  ///    - Extracts animal ID
  ///    - Calls AnimalApi.deleteAnimal() to delete from backend
  ///    - Shows success message
  ///    - Navigates back to AnimalsListPage
  /// 3. If user cancels: Does nothing
  /// 
  /// Called by: Delete button in app bar
  Future<void> _deleteAnimal() async {
    // Safety check - ensure animal data exists
    if (_animal == null) return;

    // ============================================
    // STEP 1: Show confirmation dialog
    // ============================================
    // Ask user to confirm deletion (destructive action)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Animal'),
        content: const Text(
          'Are you sure you want to delete this animal? This action cannot be undone.',
        ),
        actions: [
          // Cancel button - returns false
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          // Delete button - returns true
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If user cancelled, stop here
    if (confirmed != true) return;

    // ============================================
    // STEP 2: Show loading state
    // ============================================
    setState(() => _isDeleting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // ============================================
      // STEP 3: Extract animal ID
      // ============================================
      // Get animal ID from animal data (handles both '_id' and 'id' formats)
      final animalId = _animal!['_id']?.toString() ?? _animal!['id']?.toString();
      if (animalId == null) {
        throw Exception('Animal ID not found');
      }

      // ============================================
      // STEP 4: Call delete API
      // ============================================
      // Send DELETE request to backend
      // Backend verifies user owns the animal before deleting
      await _animalApi.deleteAnimal(animalId);
      
      // ============================================
      // STEP 5: Show success message
      // ============================================
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Animal deleted successfully'),
          backgroundColor: Color(0xFF2F7D32),
        ),
      );

      // ============================================
      // STEP 6: Navigate back
      // ============================================
      // Return to AnimalsListPage
      // Pass true to indicate deletion occurred (list can refresh)
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    } catch (e) {
      // ============================================
      // ERROR HANDLING
      // ============================================
      // If deletion fails (network error, animal not found, etc.)
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // ============================================
      // CLEANUP
      // ============================================
      // Always hide loading spinner
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  /// Opens EditAnimalPage to edit animal information
  /// 
  /// Flow:
  /// 1. Navigates to EditAnimalPage with animal data
  /// 2. User edits animal information
  /// 3. After save, returns to this page
  /// 4. If animal was updated, refreshes data from API
  /// 5. Updates UI with new data
  /// 
  /// Called by: Edit button in app bar
  Future<void> _editAnimal() async {
    // Safety check - ensure animal data exists
    if (_animal == null) return;

    // ============================================
    // STEP 1: Navigate to EditAnimalPage
    // ============================================
    // Pass current animal data as argument
    // EditAnimalPage will pre-fill form with this data
    final result = await Navigator.pushNamed(
      context,
      EditAnimalPage.routeName,
      arguments: _animal,
    );

    // ============================================
    // STEP 2: Refresh data if animal was updated
    // ============================================
    // If EditAnimalPage returns true, animal was updated
    // Fetch fresh data from API to show latest information
    if (result == true && mounted) {
      try {
        // Get animal ID
        final animalId = _animal!['_id']?.toString() ?? _animal!['id']?.toString();
        if (animalId != null) {
          // Fetch updated animal data from API
          final updatedAnimal = await _animalApi.getAnimalById(animalId);
          // Update UI with fresh data
          setState(() {
            _animal = updatedAnimal;
          });
        }
      } catch (e) {
        // If refresh fails, just show the existing data
        // User can manually refresh by going back and tapping animal again
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFE4E7D6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F7D32),
          foregroundColor: Colors.white,
          title: const Text('Animal Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F7D32)),
          ),
        ),
      );
    }

    if (_errorMessage != null || _animal == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE4E7D6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F7D32),
          foregroundColor: Colors.white,
          title: const Text('Animal Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Animal not found',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final animalType = _animal!['animalType']?.toString() ?? 'Unknown';
    final entryMode = _animal!['entryMode']?.toString() ?? 'single';
    final groupInfo = _animal!['groupInfo'];
    final numberOfAnimals = groupInfo != null && groupInfo is Map
        ? groupInfo['numberOfAnimals'] ?? 1
        : 1;
    final purpose = groupInfo != null && groupInfo is Map
        ? groupInfo['purpose']?.toString() ?? 'N/A'
        : _animal!['purpose']?.toString() ?? 'N/A';
    final monthlyCost = groupInfo != null && groupInfo is Map
        ? groupInfo['monthlyCost']?.toString() ?? 'N/A'
        : 'N/A';
    final createdAt = _animal!['createdAt']?.toString();
    final updatedAt = _animal!['updatedAt']?.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7D32),
        foregroundColor: Colors.white,
        title: const Text('Animal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editAnimal,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteAnimal,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal Image Card
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    _getAnimalImage(animalType),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.pets,
                        size: 60,
                        color: Color(0xFF2F7D32),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Animal Type
            _DetailCard(
              title: 'Animal Type',
              value: animalType,
              icon: Icons.pets,
            ),
            const SizedBox(height: 12),
            // Entry Mode
            _DetailCard(
              title: 'Entry Mode',
              value: entryMode == 'group' ? 'Group' : 'Single',
              icon: Icons.group,
            ),
            const SizedBox(height: 12),
            // Number of Animals (if group)
            if (entryMode == 'group')
              _DetailCard(
                title: 'Number of Animals',
                value: numberOfAnimals.toString(),
                icon: Icons.numbers,
              ),
            if (entryMode == 'group') const SizedBox(height: 12),
            // Purpose
            _DetailCard(
              title: 'Purpose',
              value: purpose,
              icon: Icons.category,
            ),
            const SizedBox(height: 12),
            // Monthly Cost (if available)
            if (monthlyCost != 'N/A')
              _DetailCard(
                title: 'Monthly Cost',
                value: '\$$monthlyCost',
                icon: Icons.attach_money,
              ),
            if (monthlyCost != 'N/A') const SizedBox(height: 12),
            // Created Date
            if (createdAt != null)
              _DetailCard(
                title: 'Added On',
                value: _formatDate(createdAt),
                icon: Icons.calendar_today,
              ),
            if (createdAt != null) const SizedBox(height: 12),
            // Updated Date
            if (updatedAt != null)
              _DetailCard(
                title: 'Last Updated',
                value: _formatDate(updatedAt),
                icon: Icons.update,
              ),
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editAnimal,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDeleting ? null : _deleteAnimal,
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE4E7D6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2F7D32), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A6F5B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Edit Animal Page
class EditAnimalPage extends StatefulWidget {
  static const routeName = '/edit-animal';
  const EditAnimalPage({super.key});

  @override
  State<EditAnimalPage> createState() => _EditAnimalPageState();
}

class _EditAnimalPageState extends State<EditAnimalPage> {
  final AnimalApi _animalApi = AnimalApi(ApiClient());
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _animal;
  bool _isLoading = true;
  bool _isSaving = false;

  final _numberOfAnimalsController = TextEditingController();
  final _purposeController = TextEditingController();
  final _monthlyCostController = TextEditingController();
  String? _selectedPurpose;

  final List<String> _purposeOptions = [
    'Dairy',
    'Meat',
    'Breeding',
    'Mixed',
    'Eggs',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _animal = args;
      _loadAnimalData();
    } else {
      _isLoading = false;
    }
  }

  void _loadAnimalData() {
    if (_animal == null) return;

    final groupInfo = _animal!['groupInfo'];
    if (groupInfo != null && groupInfo is Map) {
      _numberOfAnimalsController.text =
          (groupInfo['numberOfAnimals'] ?? 1).toString();
      _purposeController.text = groupInfo['purpose']?.toString() ?? '';
      _selectedPurpose = groupInfo['purpose']?.toString();
      _monthlyCostController.text =
          (groupInfo['monthlyCost'] ?? 0).toString();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _numberOfAnimalsController.dispose();
    _purposeController.dispose();
    _monthlyCostController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _animal == null) return;

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final animalId = _animal!['_id']?.toString() ?? _animal!['id']?.toString();
      if (animalId == null) {
        throw Exception('Animal ID not found');
      }

      await _animalApi.updateAnimal(
        animalId: animalId,
        numberOfAnimals: int.tryParse(_numberOfAnimalsController.text) ?? 1,
        purpose: _selectedPurpose ?? _purposeController.text,
        monthlyCost: int.tryParse(_monthlyCostController.text) ?? 0,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Animal updated successfully'),
          backgroundColor: Color(0xFF2F7D32),
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _animal == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE4E7D6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F7D32),
          foregroundColor: Colors.white,
          title: const Text('Edit Animal'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F7D32)),
          ),
        ),
      );
    }

    final animalType = _animal!['animalType']?.toString() ?? 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7D32),
        foregroundColor: Colors.white,
        title: const Text('Edit Animal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editing: $animalType',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 24),
              _LabeledField(
                label: 'Number of Animals',
                hint: 'Enter number',
                controller: _numberOfAnimalsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of animals';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 1) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                decoration: InputDecoration(
                  labelText: 'Purpose',
                  filled: true,
                  fillColor: const Color(0xFFFBF5EC),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _purposeOptions.map((purpose) {
                  return DropdownMenuItem(
                    value: purpose,
                    child: Text(purpose),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPurpose = value;
                    _purposeController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a purpose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Monthly Cost',
                hint: 'Enter cost',
                controller: _monthlyCostController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly cost';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFBF5EC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

