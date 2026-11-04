import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Task Model - Represents a single farm task
/// 
/// Tasks are generated automatically from animals and stored locally.
/// Each task has:
/// - id: Unique identifier
/// - title: Task description (e.g., "Feeding cows")
/// - animalType: Type of animal (e.g., "Cow", "Goat")
/// - quantity: Number of animals this task applies to
/// - isCompleted: Whether task is done
/// - date: Date when task should be performed
/// 
/// Tasks are NOT stored in backend - they're local only (SharedPreferences)
class Task {
  /// Unique identifier for the task
  final String id;
  
  /// Task description (e.g., "Feeding cows (morning/evening)")
  final String title;
  
  /// Type of animal this task is for (e.g., "Cow", "Goat", "Pig")
  final String animalType;
  
  /// Number of animals this task applies to
  final int quantity;
  
  /// Whether the task has been completed
  final bool isCompleted;
  
  /// Date when the task should be performed
  final DateTime date;

  Task({
    required this.id,
    required this.title,
    required this.animalType,
    required this.quantity,
    this.isCompleted = false,
    required this.date,
  });

  /// Converts Task object to JSON Map for storage
  /// Used when saving tasks to SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'animalType': animalType,
      'quantity': quantity,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(), // Convert DateTime to ISO string
    };
  }

  /// Creates Task object from JSON Map
  /// Used when loading tasks from SharedPreferences
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      animalType: json['animalType'] as String,
      quantity: json['quantity'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Creates a copy of this task with optional modifications
  /// Used when updating task completion status
  Task copyWith({bool? isCompleted}) {
    return Task(
      id: id,
      title: title,
      animalType: animalType,
      quantity: quantity,
      isCompleted: isCompleted ?? this.isCompleted, // Use new value or keep existing
      date: date,
    );
  }
}

/// TaskService - Service for managing tasks locally
/// 
/// This service handles all task operations:
/// - Generate tasks from animals
/// - Store/load tasks from SharedPreferences (local storage)
/// - Check if tasks need regeneration (new day)
/// - Update task completion status
/// - Get task statistics
/// 
/// IMPORTANT: Tasks are NOT stored in backend - they're local only!
/// Tasks are auto-generated daily from the user's animals.
/// 
/// Flow:
/// 1. DashboardPage loads animals from API
/// 2. Checks if tasks need regeneration (new day)
/// 3. If yes, generates tasks from animals
/// 4. Saves tasks to SharedPreferences
/// 5. Loads tasks for display
/// 
/// Used by: DashboardPage, TasksPage
class TaskService {
  // SharedPreferences keys for storing task data
  static const String _tasksKey = 'daily_tasks'; // Stores all tasks
  static const String _lastGenerationDateKey = 'last_task_generation_date'; // Stores when tasks were last generated

  /// Generates tasks automatically based on user's animals
  /// 
  /// Flow:
  /// 1. Receives list of animals from API
  /// 2. Counts animals by type (Cow, Goat, Pig, etc.)
  /// 3. For each animal type, generates type-specific tasks:
  ///    - Cows: Feeding, Cleaning, Milking, Watering, Health check
  ///    - Goats: Feeding, Cleaning, Watering, Health check, Activity check
  ///    - Pigs: Feeding, Cleaning, Watering, Hygiene, Temperature check
  /// 4. Returns list of tasks for today
  /// 
  /// Parameters:
  /// - animals: List of animal objects from API
  /// 
  /// Returns: List of Task objects for today
  static List<Task> generateTasks(List<Map<String, dynamic>> animals) {
    // List to store generated tasks
    final tasks = <Task>[];
    
    // Map to count animals by type (e.g., {'cow': 5, 'goat': 3})
    final animalCounts = <String, int>{};

    // ============================================
    // STEP 1: Count animals by type
    // ============================================
    // Loop through all animals and count how many of each type
    for (var animal in animals) {
      // Get animal type and convert to lowercase for consistency
      final type = animal['animalType']?.toString().toLowerCase() ?? 'unknown';
      
      // Get groupInfo to find number of animals
      // Animals are stored as groups, so we need to get numberOfAnimals
      final groupInfo = animal['groupInfo'];
      final count = groupInfo != null && groupInfo is Map
          ? (groupInfo['numberOfAnimals'] ?? 1) as int
          : 1;
      
      // Add to count (if type already exists, add to existing count)
      animalCounts[type] = (animalCounts[type] ?? 0) + count;
    }

    // Get today's date - all tasks will be for today
    final today = DateTime.now();
    
    // Counter for generating unique task IDs
    int taskIdCounter = 0;

    // ============================================
    // STEP 2: Generate tasks for each animal type
    // ============================================
    // For each animal type, create type-specific tasks
    for (var entry in animalCounts.entries) {
      final type = entry.key;
      final quantity = entry.value;
      final typeCapitalized = type.substring(0, 1).toUpperCase() + type.substring(1);

      // Generate tasks based on animal type
      // Each animal type has specific tasks that need to be done
      
      if (type == 'cow') {
        // Cows require: feeding, cleaning, milking, watering, health checks
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Feeding cows (morning/evening)',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Cleaning the cow shed',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Milking',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Watering',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Basic health observation',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
      } else if (type == 'goat') {
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Feeding goats',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Cleaning the goat shed',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Watering',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Injury/health check',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Checking movement/activity',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
      } else if (type == 'pig') {
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Feeding pigs',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Cleaning the pigsty',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Watering',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Hygiene and waste cleaning',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
        tasks.add(Task(
          id: 'task_${taskIdCounter++}',
          title: 'Temperature/health check',
          animalType: typeCapitalized,
          quantity: quantity,
          date: today,
        ));
      }
    }

    // Return all generated tasks
    return tasks;
  }

  /// Loads all tasks from local storage (SharedPreferences)
  /// 
  /// Flow:
  /// 1. Gets SharedPreferences instance
  /// 2. Reads tasks JSON string from storage
  /// 3. Parses JSON to List of Task objects
  /// 4. Returns list of tasks
  /// 
  /// Returns: List of all stored tasks (from all days)
  /// Returns empty list if no tasks found or error occurs
  static Future<List<Task>> loadTasks() async {
    try {
      // Get SharedPreferences instance (local device storage)
      final prefs = await SharedPreferences.getInstance();
      
      // Read tasks JSON string from storage
      final tasksJson = prefs.getString(_tasksKey);
      if (tasksJson == null) return []; // No tasks stored yet

      // Parse JSON string to List
      final List<dynamic> decoded = jsonDecode(tasksJson);
      
      // Convert each JSON object to Task object
      return decoded.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // If error occurs (corrupted data, etc.), return empty list
      return [];
    }
  }

  /// Saves tasks to local storage (SharedPreferences)
  /// 
  /// Flow:
  /// 1. Converts List of Task objects to JSON string
  /// 2. Gets SharedPreferences instance
  /// 3. Saves JSON string to storage
  /// 
  /// Parameters:
  /// - tasks: List of Task objects to save
  /// 
  /// Used by: DashboardPage (after generating tasks), TasksPage (after updating completion)
  static Future<void> saveTasks(List<Task> tasks) async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      
      // Convert List of Task objects to JSON string
      // Each task is converted to JSON using toJson() method
      final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
      
      // Save JSON string to storage
      await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      // Handle error silently - if save fails, tasks just won't be stored
      // This prevents app crashes
    }
  }

  /// Checks if tasks need to be regenerated (new day check)
  /// 
  /// Flow:
  /// 1. Gets last generation date from SharedPreferences
  /// 2. Compares with today's date
  /// 3. Returns true if it's a new day (tasks need regeneration)
  /// 
  /// This ensures tasks are regenerated daily based on current animals.
  /// 
  /// Returns: true if tasks should be regenerated, false otherwise
  static Future<bool> shouldRegenerateTasks() async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      
      // Read last generation date from storage
      final lastDateStr = prefs.getString(_lastGenerationDateKey);
      if (lastDateStr == null) return true; // No date stored = first time = regenerate

      // Parse stored date string to DateTime
      final lastDate = DateTime.parse(lastDateStr);
      final today = DateTime.now();
      
      // Check if it's a new day (year, month, or day changed)
      // If any date component changed, it's a new day
      return today.year != lastDate.year ||
          today.month != lastDate.month ||
          today.day != lastDate.day;
    } catch (e) {
      // If error occurs, return true to be safe (regenerate tasks)
      return true;
    }
  }

  /// Saves the current date as the last generation date
  /// 
  /// Called after tasks are generated to track when they were created.
  /// This is used by shouldRegenerateTasks() to check if it's a new day.
  /// 
  /// Flow:
  /// 1. Gets current date/time
  /// 2. Converts to ISO string
  /// 3. Saves to SharedPreferences
  static Future<void> saveGenerationDate() async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      
      // Save current date/time as ISO string
      await prefs.setString(_lastGenerationDateKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Handle error silently - if save fails, tasks will regenerate next time
    }
  }

  /// Gets only today's tasks from all stored tasks
  /// 
  /// Flow:
  /// 1. Loads all tasks from storage
  /// 2. Filters tasks to only include today's date
  /// 3. Returns filtered list
  /// 
  /// Used by: DashboardPage (to show today's tasks), TasksPage (to display tasks)
  /// 
  /// Returns: List of tasks for today only
  static Future<List<Task>> getTodayTasks() async {
    // Load all tasks from storage (includes tasks from all days)
    final allTasks = await loadTasks();
    final today = DateTime.now();
    
    // Filter tasks to only include today's tasks
    // Compare year, month, and day to match today
    return allTasks.where((task) {
      return task.date.year == today.year &&
          task.date.month == today.month &&
          task.date.day == today.day;
    }).toList();
  }

  /// Updates a task's completion status
  /// 
  /// Flow:
  /// 1. Loads all tasks from storage
  /// 2. Finds task by ID
  /// 3. Updates completion status
  /// 4. Saves updated tasks back to storage
  /// 
  /// Used by: TasksPage (when user checks/unchecks a task)
  /// 
  /// Parameters:
  /// - taskId: ID of the task to update
  /// - isCompleted: New completion status (true = done, false = not done)
  static Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    // Load all tasks from storage
    final tasks = await loadTasks();
    
    // Find task by ID
    final index = tasks.indexWhere((task) => task.id == taskId);
    
    // If task found, update it and save
    if (index != -1) {
      // Create new task with updated completion status
      tasks[index] = tasks[index].copyWith(isCompleted: isCompleted);
      
      // Save updated tasks back to storage
      await saveTasks(tasks);
    }
  }

  /// Gets task statistics for today
  /// 
  /// Flow:
  /// 1. Gets today's tasks
  /// 2. Counts total tasks
  /// 3. Counts completed tasks
  /// 4. Calculates pending tasks (total - completed)
  /// 5. Returns statistics map
  /// 
  /// Used by: DashboardPage (to show stats: Total, Completed, Pending)
  /// 
  /// Returns: Map with { total, completed, pending } counts
  static Future<Map<String, int>> getTaskStats() async {
    // Get today's tasks only
    final tasks = await getTodayTasks();
    
    // Count total tasks
    final total = tasks.length;
    
    // Count completed tasks (filter by isCompleted == true)
    final completed = tasks.where((task) => task.isCompleted).length;
    
    // Calculate pending tasks (total - completed)
    final pending = total - completed;
    
    // Return statistics map
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }
}

