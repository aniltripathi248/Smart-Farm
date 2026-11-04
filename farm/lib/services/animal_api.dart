import 'api_client.dart';
import 'session_manager.dart';

/// AnimalApi - Service for animal-related API operations
/// 
/// This service handles all animal CRUD operations:
/// - Create: Add new animal groups
/// - Read: Get all animals, get single animal
/// - Update: Modify animal details
/// - Delete: Remove animals
/// 
/// Flow: Screen → AnimalApi → ApiClient → Backend API
/// 
/// Used by: DashboardPage, AnimalsListPage, AnimalDetailsPage, 
///          EditAnimalPage, SummaryPage
class AnimalApi {
  /// Constructor - requires ApiClient instance for HTTP communication
  AnimalApi(this._client);

  /// HTTP client instance for making API calls
  final ApiClient _client;

  /// Creates a new animal group (adds animals to farm)
  /// 
  /// Flow:
  /// 1. User goes through AddAnimal flow (AddAnimalPage → GroupAnimalSetupPage → SummaryPage)
  /// 2. SummaryPage collects all data (type, number, purpose, cost)
  /// 3. Calls this method with animal data
  /// 4. Gets token from SessionManager (required for authenticated requests)
  /// 5. ApiClient sends POST /api/animals/addanimal with token
  /// 6. Backend saves animal to database
  /// 7. User redirected to DashboardPage
  /// 8. DashboardPage reloads animals list
  /// 
  /// Parameters:
  /// - animalType: Type of animal (e.g., 'Cow', 'Goat', 'Pig')
  /// - numberOfAnimals: Number of animals in the group
  /// - purpose: Purpose of animals (e.g., 'Dairy', 'Meat', 'Breeding')
  /// - monthlyCost: Estimated monthly cost for the group
  /// 
  /// Returns: Map with success message and created animal data
  /// Throws: Exception if creation fails (not logged in, validation error, etc.)
  Future<Map<String, dynamic>> createGroupFromSummary({
    required String animalType,
    required int numberOfAnimals,
    required String purpose,
    required int monthlyCost,
  }) async {
    // Get authentication token from SessionManager
    // This is required because adding animals is an authenticated operation
    final token = SessionManager.instance.token;
    if (token == null) {
      throw Exception('You must be logged in to save animals.');
    }

    // Prepare request body with animal data
    // entryMode: 'group' indicates this is a group of animals (not single)
    final body = {
      'animalType': animalType,
      'entryMode': 'group', // Always 'group' for this flow
      'groupInfo': {
        'numberOfAnimals': numberOfAnimals,
        'purpose': purpose,
        'monthlyCost': monthlyCost,
      },
      'summary': {
        'purpose': purpose,
        'monthlyCost': monthlyCost,
      },
    };

    // Send POST request to addanimal endpoint
    // Token is required - this is an authenticated endpoint
    return _client.postJson('/api/animals/addanimal', body, token: token);
  }

  /// Fetches all animals that belong to the logged-in user
  /// 
  /// Flow:
  /// 1. DashboardPage or AnimalsListPage calls this method
  /// 2. Gets token from SessionManager
  /// 3. ApiClient sends GET /api/animals/mine with token
  /// 4. Backend queries database for user's animals
  /// 5. Returns list of animals
  /// 6. Screen displays animals in UI
  /// 
  /// Used by: DashboardPage (to count animals), AnimalsListPage (to display list)
  /// 
  /// Returns: List of animal objects (each is a Map with animal data)
  /// Throws: Exception if fetch fails (not logged in, network error, etc.)
  Future<List<Map<String, dynamic>>> getMyAnimals() async {
    // Get authentication token from SessionManager
    final token = SessionManager.instance.token;
    if (token == null) {
      throw Exception('You must be logged in to view animals.');
    }

    // Send GET request to /api/animals/mine endpoint
    // Backend returns only animals belonging to the logged-in user
    final result = await _client.getJson('/api/animals/mine', token: token);
    
    // Extract data array from response
    // Backend returns: { success: true, data: [animal1, animal2, ...] }
    final data = result['data'];
    
    // Verify data is a List and convert to List<Map<String, dynamic>>
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    // Return empty list if data is not a List (safety check)
    return const [];
  }

  /// Fetches a single animal by its ID
  /// 
  /// Flow:
  /// 1. AnimalDetailsPage or EditAnimalPage calls this method with animal ID
  /// 2. Gets token from SessionManager
  /// 3. ApiClient sends GET /api/animals/:id with token
  /// 4. Backend queries database for specific animal
  /// 5. Returns animal data
  /// 6. Screen displays animal details
  /// 
  /// Used by: AnimalDetailsPage (to refresh after edit), EditAnimalPage
  /// 
  /// Parameters:
  /// - animalId: The unique ID of the animal to fetch
  /// 
  /// Returns: Map with complete animal data
  /// Throws: Exception if fetch fails (not logged in, animal not found, etc.)
  Future<Map<String, dynamic>> getAnimalById(String animalId) async {
    // Get authentication token from SessionManager
    final token = SessionManager.instance.token;
    if (token == null) {
      throw Exception('You must be logged in to view animals.');
    }

    // Send GET request to /api/animals/:id endpoint
    // Backend returns the specific animal (if user owns it)
    final result = await _client.getJson('/api/animals/$animalId', token: token);
    
    // Extract and return animal data from response
    return result['data'] as Map<String, dynamic>;
  }

  /// Updates an existing animal's information
  /// 
  /// Flow:
  /// 1. EditAnimalPage loads current animal data
  /// 2. User modifies number, purpose, or cost
  /// 3. Calls this method with updated data
  /// 4. Gets token from SessionManager
  /// 5. ApiClient sends POST /api/animals/:id/update with token
  /// 6. Backend updates animal in database
  /// 7. Returns updated animal data
  /// 8. AnimalDetailsPage refreshes with new data
  /// 
  /// Used by: EditAnimalPage
  /// 
  /// Parameters:
  /// - animalId: The unique ID of the animal to update
  /// - numberOfAnimals: Updated number of animals
  /// - purpose: Updated purpose
  /// - monthlyCost: Updated monthly cost
  /// 
  /// Returns: Map with updated animal data
  /// Throws: Exception if update fails (not logged in, animal not found, etc.)
  Future<Map<String, dynamic>> updateAnimal({
    required String animalId,
    required int numberOfAnimals,
    required String purpose,
    required int monthlyCost,
  }) async {
    // Get authentication token from SessionManager
    final token = SessionManager.instance.token;
    if (token == null) {
      throw Exception('You must be logged in to update animals.');
    }

    // Prepare request body with updated groupInfo
    // Only groupInfo is updated (number, purpose, cost)
    final body = {
      'groupInfo': {
        'numberOfAnimals': numberOfAnimals,
        'purpose': purpose,
        'monthlyCost': monthlyCost,
      },
    };

    // Send POST request to /api/animals/:id/update endpoint
    // Token is required - this is an authenticated endpoint
    return _client.postJson('/api/animals/$animalId/update', body, token: token);
  }

  /// Deletes an animal from the user's farm
  /// 
  /// Flow:
  /// 1. AnimalDetailsPage shows delete button
  /// 2. User confirms deletion in dialog
  /// 3. Calls this method with animal ID
  /// 4. Gets token from SessionManager
  /// 5. ApiClient sends DELETE /api/animals/:id with token
  /// 6. Backend deletes animal from database
  /// 7. User redirected back to AnimalsListPage
  /// 
  /// Used by: AnimalDetailsPage
  /// 
  /// Parameters:
  /// - animalId: The unique ID of the animal to delete
  /// 
  /// Returns: void (nothing)
  /// Throws: Exception if deletion fails (not logged in, animal not found, etc.)
  Future<void> deleteAnimal(String animalId) async {
    // Get authentication token from SessionManager
    final token = SessionManager.instance.token;
    if (token == null) {
      throw Exception('You must be logged in to delete animals.');
    }

    // Send DELETE request to /api/animals/:id endpoint
    // Token is required - this is an authenticated endpoint
    // Backend verifies user owns the animal before deleting
    await _client.deleteJson('/api/animals/$animalId', token: token);
  }
}


