// ============================================
// DASHBOARD PAGE - Main Hub After Login
// ============================================
// This is the main screen users see after logging in.
// It displays:
// - Farm overview (animal count, health status)
// - Quick actions (scan animal, upload file)
// - Today's tasks preview with statistics
// - Navigation to other sections
// ============================================

import 'package:farm/screens/animal_details_page.dart';
import 'package:farm/screens/animals_list_page.dart';
import 'package:farm/screens/edit_profile_page.dart';
import 'package:farm/screens/login_page.dart';
import 'package:farm/screens/scan_animal_page.dart';
import 'package:farm/screens/tasks_page.dart';
import 'package:farm/services/animal_api.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/session_manager.dart';
import 'package:farm/services/task_service.dart';
import 'package:flutter/material.dart';

/// DashboardPage - Main hub screen after user logs in
/// 
/// Flow:
/// 1. User logs in → Navigated to DashboardPage
/// 2. initState() calls _loadDashboardData()
/// 3. Loads animals from API
/// 4. Checks if tasks need regeneration (new day)
/// 5. Generates tasks if needed
/// 6. Loads task statistics and preview
/// 7. Displays all data in cards
/// 
/// Navigation:
/// - "View all animals" → AnimalsListPage
/// - "View all" in tasks → TasksPage
/// - Animals icon (bottom nav) → AnimalsListPage
/// - Tasks icon (bottom nav) → TasksPage
/// - Profile icon → Drawer (Edit Profile, Logout)
/// - FAB (+) → AddAnimalPage
class DashboardPage extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

/// State class for DashboardPage
/// Manages all dashboard data and UI state
class _DashboardPageState extends State<DashboardPage> {
  // Key to control the drawer (profile menu)
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // API service for animal operations
  final AnimalApi _animalApi = AnimalApi(ApiClient());

  // ============================================
  // STATE VARIABLES
  // ============================================
  // Loading state - shows spinner while fetching data
  bool _isLoading = true;
  
  // Number of animal groups user has
  int _myAnimalCount = 0;
  
  // Full list of animals (used for generating tasks and health alerts)
  List<Map<String, dynamic>> _animals = [];
  
  // Task statistics: total, completed, pending counts
  Map<String, int> _taskStats = {'total': 0, 'completed': 0, 'pending': 0};
  
  // Preview of first 3 tasks to show in dashboard card
  List<Task> _taskPreview = [];

  /// Called when screen is first created
  /// 
  /// Flow:
  /// 1. Screen initializes
  /// 2. Immediately loads dashboard data (animals, tasks)
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Loads all dashboard data from API and local storage
  /// 
  /// Flow:
  /// 1. Checks if user is logged in (has token)
  /// 2. Fetches animals from API
  /// 3. Checks if tasks need regeneration (new day check)
  /// 4. If new day AND has animals → generates new tasks
  /// 5. Loads task statistics (total, completed, pending)
  /// 6. Loads first 3 tasks for preview
  /// 7. Updates UI with all data
  /// 
  /// Called by: initState(), pull-to-refresh (if implemented)
  Future<void> _loadDashboardData() async {
    try {
      // ============================================
      // STEP 1: Check Authentication
      // ============================================
      // If user is not logged in, show empty state
      if (SessionManager.instance.token == null) {
        setState(() {
          _isLoading = false;
          _myAnimalCount = 0;
          _animals = [];
        });
        return;
      }

      // ============================================
      // STEP 2: Load Animals from API
      // ============================================
      // Fetch all animals belonging to logged-in user
      final animals = await _animalApi.getMyAnimals();
      if (!mounted) return; // Safety check - widget might be disposed
      
      // ============================================
      // STEP 3: Generate Tasks (if needed)
      // ============================================
      // Check if tasks need to be regenerated (new day)
      final shouldRegenerate = await TaskService.shouldRegenerateTasks();
      if (shouldRegenerate && animals.isNotEmpty) {
        // Generate tasks based on current animals
        final generatedTasks = TaskService.generateTasks(animals);
        // Save generated tasks to local storage
        await TaskService.saveTasks(generatedTasks);
        // Save generation date to prevent regeneration until tomorrow
        await TaskService.saveGenerationDate();
      }
      
      // ============================================
      // STEP 4: Load Task Data
      // ============================================
      // Get task statistics (total, completed, pending)
      final stats = await TaskService.getTaskStats();
      // Get all tasks for today
      final allTasks = await TaskService.getTodayTasks();
      // Take first 3 tasks for preview in dashboard card
      final preview = allTasks.take(3).toList();
      
      // ============================================
      // STEP 5: Update UI
      // ============================================
      // Update state with all loaded data
      setState(() {
        _myAnimalCount = animals.length; // Count of animal groups
        _animals = animals; // Full list (for generating alerts)
        _taskStats = stats; // Task statistics
        _taskPreview = preview; // First 3 tasks
        _isLoading = false; // Hide loading spinner
      });
    } catch (_) {
      // If error occurs (network, API, etc.), show empty state
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _animals = [];
      });
    }
  }

  /// Refreshes task data after returning from TasksPage
  /// 
  /// Flow:
  /// 1. Called when user returns from TasksPage
  /// 2. Reloads task statistics and preview
  /// 3. Updates UI with latest task data
  /// 
  /// Used by: Navigation callbacks (after TasksPage)
  Future<void> _refreshTasks() async {
    // Reload task statistics
    final stats = await TaskService.getTaskStats();
    // Reload today's tasks
    final allTasks = await TaskService.getTodayTasks();
    // Get first 3 for preview
    final preview = allTasks.take(3).toList();
    
    // Update UI if widget is still mounted
    if (mounted) {
      setState(() {
        _taskStats = stats;
        _taskPreview = preview;
      });
    }
  }

  /// Generates health alerts based on user's animals
  /// 
  /// Flow:
  /// 1. Loops through user's animals
  /// 2. Creates sample health alerts (currently mock data)
  /// 3. Returns max 2 alerts for display
  /// 
  /// Note: Currently generates mock alerts. In future, this could
  /// connect to actual health monitoring data.
  /// 
  /// Returns: List of alert objects (max 2)
  List<Map<String, dynamic>> _generateHealthAlerts() {
    // If no animals, no alerts
    if (_animals.isEmpty) return [];
    
    final alerts = <Map<String, dynamic>>[];
    int alertIndex = 0;
    
    // Loop through animals and generate alerts
    for (var animal in _animals) {
      if (alertIndex >= 2) break; // Show max 2 alerts
      
      // Extract animal information
      final animalType = animal['animalType']?.toString() ?? 'Animal';
      final groupInfo = animal['groupInfo'];
      final animalNumber = groupInfo != null && groupInfo is Map
          ? (groupInfo['numberOfAnimals'] ?? 1).toString()
          : '1';
      
      // Generate different alert types
      if (alertIndex == 0) {
        // First alert: High priority (fever risk)
        alerts.add({
          'title': '$animalType #$animalNumber - fever risk',
          'subtitle': 'Reduced activity detected in last 2 days',
          'action': 'Check today',
          'actionColor': Colors.red,
        });
      } else if (alertIndex == 1) {
        // Second alert: Medium priority (health check)
        alerts.add({
          'title': '$animalType #$animalNumber - health check',
          'subtitle': 'Regular checkup recommended',
          'action': 'Soon',
          'actionColor': Colors.amber,
        });
      }
      
      alertIndex++;
    }

    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFarmOverviewCard(),
                const SizedBox(height: 24),
                _buildQuickActionsCard(),
                const SizedBox(height: 24),
                _buildTodaysTasksCard(),
                // const SizedBox(height: 24),
                // _buildHealthAlertsCard(), // Commented out as requested
              ],
            ),
          ),
        ),
      ),
      endDrawer: _buildEndDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-animal');
        },
        backgroundColor: const Color(0xFF2F7D32),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    final user = SessionManager.instance.user;
    final name = user?['fullName']?.toString() ?? 'Farmer';
    final email = user?['email']?.toString() ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFEFF2E2),
              child:
                  Icon(Icons.eco_outlined, color: Color(0xFF4E7D44), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6A6F5B),
                    ),
                  ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            setState(() {}); // Refresh to show latest user data
            _scaffoldKey.currentState?.openEndDrawer();
          },
          icon: const Icon(Icons.person_outline, color: Color(0xFF2F2F2F), size: 28),
        ),
      ],
    );
  }

  Widget _buildFarmOverviewCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Farm overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AnimalsListPage.routeName);
                },
                child: const Text('View all animals', style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Text('Quick health and herd snapshot', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_myAnimalCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('total', style: TextStyle(color: Colors.grey)),
                    const Text('group of animal you added',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('92%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F7D32))),
                    const Text('stable', style: TextStyle(color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E7D6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('1 needs attention', style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ),
           const SizedBox(height: 16),
           const Divider(),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: const [
                Text('28°C Clear - Good for grazing', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('See weather tips', style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600)),
             ],
           )
        ],
      ),
    );
  }

   Widget _buildQuickActionsCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Use camera or add animals in seconds', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan animal',
                  subtitle: 'Use live camera to check visible signs',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanAnimalPage(isFromCamera: true),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: Icons.upload_file,
                  title: 'Upload file',
                  subtitle: 'Check a saved photo for issues',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanAnimalPage(isFromCamera: false),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ],
      )
    );
   }

  Widget _buildTodaysTasksCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, TasksPage.routeName);
                  _refreshTasks();
                },
                child: const Text(
                  'View all',
                  style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Task Statistics
          Row(
            children: [
              Expanded(
                child: _TaskStatItem(
                  label: 'Total',
                  value: '${_taskStats['total'] ?? 0}',
                  color: const Color(0xFF2F7D32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TaskStatItem(
                  label: 'Completed',
                  value: '${_taskStats['completed'] ?? 0}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TaskStatItem(
                  label: 'Pending',
                  value: '${_taskStats['pending'] ?? 0}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          if (_taskPreview.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No tasks for today',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            )
          else ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ..._taskPreview.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(context, TasksPage.routeName);
                      _refreshTasks();
                    },
                    child: _TaskPreviewTile(
                      title: task.title,
                      animalType: task.animalType,
                      isCompleted: task.isCompleted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthAlertsCard() {
    final alerts = _generateHealthAlerts();
    
    return _DashboardCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Health alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Open insights', style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600)),
            ],
          ),
          if (alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No health alerts',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            )
          else
            ...alerts.asMap().entries.map((entry) {
              final index = entry.key;
              final alert = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(),
                  _HealthAlertTile(
                    title: alert['title'] as String,
                    subtitle: alert['subtitle'] as String,
                    action: alert['action'] as String,
                    actionColor: alert['actionColor'] as Color,
                  ),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildEndDrawer() {
    final user = SessionManager.instance.user;
    final name = user?['fullName']?.toString() ?? 'Farmer';
    final email = user?['email']?.toString() ?? '';
    final farmName = user?['farmName']?.toString();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'F',
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Color(0xFF2F7D32),
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2F7D32),
            ),
          ),
          if (farmName != null && farmName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: Color(0xFF2F7D32), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      farmName,
                      style: const TextStyle(
                        color: Color(0xFF2F2F2F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF2F7D32)),
            title: const Text('Edit Profile'),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await Navigator.pushNamed(context, EditProfilePage.routeName);
              // Refresh dashboard to show updated profile
              if (mounted) {
                setState(() {});
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets, color: Color(0xFF2F7D32)),
            title: const Text('My Animals'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(context, AnimalsListPage.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF6A6F5B)),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF6A6F5B)),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF6A6F5B)),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon!')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Farm Companion'),
        content: const Text(
          'Farm Companion helps you manage your farm animals, track their health, and organize your farming tasks.\n\nVersion 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              SessionManager.instance.clear();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginPage.routeName,
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(icon: Icons.home_outlined, label: 'Home', isSelected: true),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AnimalsListPage.routeName);
            },
            child: _BottomNavItem(icon: Icons.grid_view, label: 'Animals'),
          ),
          const SizedBox(width: 40), // The gap for the FAB
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, TasksPage.routeName);
              _refreshTasks();
            },
            child: _BottomNavItem(icon: Icons.check_circle_outline, label: 'Tasks'),
          ),
          _BottomNavItem(icon: Icons.insights_outlined, label: 'Insights'),
        ],
      ),
    );
  }
}

// Helper widgets for the dashboard cards

class _DashboardCard extends StatelessWidget {
  final Widget child;
  const _DashboardCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2F7D32), size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _TaskStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TaskStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskPreviewTile extends StatelessWidget {
  final String title;
  final String animalType;
  final bool isCompleted;

  const _TaskPreviewTile({
    required this.title,
    required this.animalType,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: isCompleted,
        onChanged: null, // Disabled - tap the tile to open TasksPage
        activeColor: const Color(0xFF2F7D32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? Colors.grey[600] : const Color(0xFF2F2F2F),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE4E7D6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            animalType,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2F7D32),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}

class _HealthAlertTile extends StatelessWidget {
  final String title, subtitle, action;
  final Color actionColor;
  const _HealthAlertTile({required this.title, required this.subtitle, required this.action, required this.actionColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
       contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, height: 1.4)),
      trailing: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: actionColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {},
        child: Text(action, style: TextStyle(color: actionColor, fontWeight: FontWeight.bold)),
      )
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  const _BottomNavItem({required this.icon, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF2F7D32) : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      ],
    );
  }
}
