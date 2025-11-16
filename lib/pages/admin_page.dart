import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../components/futuristic_card.dart';
import '../components/gradient_button.dart';
import '../components/image_background.dart';
import '../utils/background_image_manager.dart';
import '../api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late String _selectedImage;
  final BackgroundImageManager _imageManager = BackgroundImageManager();
  bool _isLoadingStats = false;
  bool _isLoadingUsers = false;
  bool _isLoadingEmployees = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  List<dynamic> _employees = [];
  String? _error;

  // Helper pour transformer les URLs relatives en URLs complètes
  String _getFullUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // Si l'URL commence déjà par http:// ou https://, la retourner telle quelle
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // Sinon, ajouter le baseUrl
    final baseUrl = ApiService.baseUrl;
    // Enlever le slash au début de l'URL si présent
    final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    return '$baseUrl/$cleanUrl';
  }

  @override
  void initState() {
    super.initState();
    _selectedImage = _imageManager.getImageForPage('admin');
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    // Éviter les appels simultanés
    if (_isLoadingStats) {
      debugPrint('⏳ Chargement déjà en cours, ignoré');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingStats = true;
        _isLoadingUsers = true;
        _isLoadingEmployees = true;
        _error = null;
      });
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken;

    if (token == null) {
      debugPrint('⚠️ Token manquant');
      if (mounted) {
        setState(() {
          _error = 'Token manquant';
          _isLoadingStats = false;
          _isLoadingUsers = false;
          _isLoadingEmployees = false;
        });
      }
      return;
    }

    // Charger les statistiques
    try {
      final stats = await ApiService.getAdminStats(token);
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement stats: $e');
      setState(() {
        _error = 'Erreur stats: $e';
        _isLoadingStats = false;
      });
    }

    // Charger les utilisateurs
    try {
      final usersData = await ApiService.getUsers(token);
      setState(() {
        _users = usersData['users'] ?? [];
        _isLoadingUsers = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement users: $e');
      setState(() {
        _isLoadingUsers = false;
      });
    }

    // Charger les employés
    try {
      final employeesData = await ApiService.getEmployees(token);
      setState(() {
        _employees = employeesData['employees'] ?? [];
        _isLoadingEmployees = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement employees: $e');
      setState(() {
        _isLoadingEmployees = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Check if user is admin
        final isAdmin = appProvider.currentUser?['email'] == 'nyundumathryme@gmail.com';

        if (!isAdmin) {
          return _buildAccessDenied(context);
        }

        return Scaffold(
          backgroundColor: Colors.grey[50], // ✅ MODIFIÉ - Plus de blanc pur
          appBar: AppBar(
            title: const Text(
              'Administration',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadAdminData,
                tooltip: 'Rafraîchir',
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: ImageBackground(
            imagePath: _selectedImage,
            opacity: 0.25,
            child: ListView(
              padding: const EdgeInsets.only(top: kToolbarHeight + 60, left: 20, right: 20, bottom: 20),
              children: [
                _buildAdminStats(context, appProvider),
                const SizedBox(height: 24),
                _buildUserManagement(context, appProvider),
                const SizedBox(height: 24),
                _buildEmployeeManagement(context, appProvider),
                const SizedBox(height: 24),
                _buildSystemControls(context, appProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // ✅ MODIFIÉ - Plus de blanc pur
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.red,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Accès Administrateur Requis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Vous n\'avez pas les permissions nécessaires\npour accéder à cette section.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStats(BuildContext context, AppProvider appProvider) {
    if (_isLoadingStats) {
      return const FuturisticCard(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
        ),
      );
    }

    if (_error != null || _stats == null) {
      return FuturisticCard(
        child: Center(
          child: Text(
            _error ?? 'Erreur de chargement',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Statistiques Globales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Utilisateurs',
                  value: '${_stats!['users']['total']}',
                  icon: Icons.people_rounded,
                  color: const Color(0xFF00D4FF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Employés',
                  value: '${_stats!['employees']['total']}',
                  icon: Icons.business_center_rounded,
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Publications',
                  value: '${_stats!['publications']['total']}',
                  icon: Icons.article_rounded,
                  color: const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Actifs',
                  value: '${_stats!['users']['active']}',
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement(BuildContext context, AppProvider appProvider) {
    if (_isLoadingUsers) {
      return const FuturisticCard(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
        ),
      );
    }

    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.manage_accounts_rounded,
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Gestion des Utilisateurs',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_users.isEmpty)
            const Center(
              child: Text(
                'Aucun utilisateur',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ..._users.map((user) => _buildUserItem(context, user, appProvider)),
        ],
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, dynamic user, AppProvider appProvider) {
    final String userId = user['_id'] ?? user['id'] ?? '';
    final String name = user['name'] ?? 'Sans nom';
    final String email = user['email'] ?? '';
    final String status = user['status'] ?? 'active';
    final String rawProfileImage = user['profileImage'] ?? '';
    final String profileImage = _getFullUrl(rawProfileImage);

    debugPrint('👤 User: $name');
    debugPrint('   Raw image: $rawProfileImage');
    debugPrint('   Full URL: $profileImage');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: profileImage.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profileImage,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('❌ Error loading user image: $error');
                        debugPrint('   URL: $profileImage');
                        return const Icon(Icons.person, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleUserAction(context, userId, value, appProvider),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'activate',
                child: Text('Activer'),
              ),
              const PopupMenuItem(
                value: 'deactivate',
                child: Text('Désactiver'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: _getStatusColor(status),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeManagement(BuildContext context, AppProvider appProvider) {
    if (_isLoadingEmployees) {
      return const FuturisticCard(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
      );
    }

    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Color(0xFFFF6B35),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Gestion des Employés',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_employees.isEmpty)
            const Center(
              child: Text(
                'Aucun employé',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ..._employees.map((employee) => _buildEmployeeItem(context, employee, appProvider)),
        ],
      ),
    );
  }

  Widget _buildEmployeeItem(BuildContext context, dynamic employee, AppProvider appProvider) {
    // ignore: unused_local_variable
    final String employeeId = employee['_id'] ?? employee['id'] ?? '';
    final String name = employee['name'] ?? 'Sans nom';
    final String email = employee['email'] ?? '';
    final String phone = employee['phone'] ?? '';
    final String status = employee['status'] ?? 'active';
    final String rawFaceImage = employee['faceImage'] ?? '';
    final String faceImage = _getFullUrl(rawFaceImage);

    debugPrint('👷 Employee: $name');
    debugPrint('   Raw image: $rawFaceImage');
    debugPrint('   Full URL: $faceImage');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFF6B35),
            child: faceImage.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      faceImage,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('❌ Error loading employee image: $error');
                        debugPrint('   URL: $faceImage');
                        return const Icon(Icons.person, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: TextStyle(
                      color: const Color(0xFF25D366).withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleEmployeeAction(context, employee, value, appProvider),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'promote',
                child: Text('Promouvoir'),
              ),
              const PopupMenuItem(
                value: 'demote',
                child: Text('Rétrograder'),
              ),
              const PopupMenuItem(
                value: 'transfer',
                child: Text('Transférer'),
              ),
              const PopupMenuItem(
                value: 'terminate',
                child: Text('Licencier'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEmployeeStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: _getEmployeeStatusColor(status),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemControls(BuildContext context, AppProvider appProvider) {
    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_system_daydream_rounded,
                  color: Color(0xFF9C27B0),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Contrôles Système',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  onPressed: () => _showMessage(context, 'Données sauvegardées avec succès!'),
                  gradientColors: const [Color(0xFF25D366), Color(0xFF128C7E)],
                  child: const Text(
                    'Sauvegarder Données',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GradientButton(
                  onPressed: () => _showMessage(context, 'Rapports exportés avec succès!'),
                  gradientColors: const [Color(0xFF128C7E), Color(0xFF075E54)],
                  child: const Text(
                    'Exporter Rapports',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GradientButton(
            onPressed: () => _showMaintenanceDialog(context),
            gradientColors: const [Color(0xFF075E54), Color(0xFF25D366)],
            child: const Text(
              'Maintenance Système',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'banned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getEmployeeStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'on_leave':
        return Colors.orange;
      case 'terminated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleUserAction(BuildContext context, String userId, String action, AppProvider appProvider) async {
    final token = appProvider.accessToken;
    if (token == null) {
      if (!context.mounted) return;
      _showMessage(context, 'Token manquant');
      return;
    }

    try {
      switch (action) {
        case 'activate':
          await ApiService.updateUserStatus(token, userId, 'active');
          if (!context.mounted) return;
          _showMessage(context, 'Utilisateur activé');
          _loadAdminData(); // Recharger les données
          break;
        case 'deactivate':
          await ApiService.updateUserStatus(token, userId, 'blocked');
          if (!context.mounted) return;
          _showMessage(context, 'Utilisateur désactivé');
          _loadAdminData();
          break;
        case 'delete':
          await ApiService.deleteUser(token, userId);
          if (!context.mounted) return;
          _showMessage(context, 'Utilisateur supprimé');
          _loadAdminData();
          break;
      }
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, 'Erreur: $e');
    }
  }

  void _handleEmployeeAction(BuildContext context, dynamic employee, String action, AppProvider appProvider) async {
    final employeeId = employee['_id'] ?? employee['id'] ?? '';
    final employeeName = employee['name'] ?? 'Employé';
    
    // Note: Backend routes for employee actions (promote/demote/transfer/terminate) 
    // need to be implemented in server.js
    if (!context.mounted) return;
    
    switch (action) {
      case 'promote':
        debugPrint('Promote employee: $employeeId');
        _showMessage(context, '$employeeName promu (fonctionnalité à implémenter)');
        break;
      case 'demote':
        debugPrint('Demote employee: $employeeId');
        _showMessage(context, '$employeeName rétrogradé (fonctionnalité à implémenter)');
        break;
      case 'transfer':
        debugPrint('Transfer employee: $employeeId');
        _showMessage(context, '$employeeName transféré (fonctionnalité à implémenter)');
        break;
      case 'terminate':
        debugPrint('Terminate employee: $employeeId');
        // When backend route exists: await ApiService.updateEmployeeStatus(token, employeeId, 'terminated');
        _showMessage(context, '$employeeName licencié (fonctionnalité à implémenter)');
        break;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF25D366),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Maintenance Système',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          'Cette action effectuera une maintenance complète du système. Continuer?',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          GradientButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage(context, 'Maintenance effectuée avec succès!');
            },
            gradientColors: const [Color(0xFF25D366), Color(0xFF128C7E)],
            height: 36,
            child: const Text(
              'Confirmer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
