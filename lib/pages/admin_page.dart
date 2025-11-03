import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../components/futuristic_card.dart';
import '../components/gradient_button.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Check if user is admin (mock check - in real app, check from backend)
        final isAdmin = appProvider.currentUser?['email'] == 'nyundumathryme@gmail.com';

        if (!isAdmin) {
          return _buildAccessDenied(context);
        }

        return Scaffold(
        backgroundColor: Colors.white,
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
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
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
        );
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: Colors.white,
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
                  value: '${appProvider.users.length}',
                  icon: Icons.people_rounded,
                  color: const Color(0xFF00D4FF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Employés',
                  value: '${appProvider.employees.length}',
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
                  value: '${appProvider.posts.length}',
                  icon: Icons.article_rounded,
                  color: const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Actifs',
                  value: '${appProvider.users.where((u) => u.status == 'active').length}',
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...appProvider.users.map((user) => _buildUserItem(context, user, appProvider)),
        ],
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, User user, AppProvider appProvider) {
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
            backgroundImage: NetworkImage(user.avatar),
            radius: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleUserAction(context, user, value, appProvider),
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
                color: _getStatusColor(user.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: _getStatusColor(user.status),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeManagement(BuildContext context, AppProvider appProvider) {
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
          ...appProvider.employees.map((employee) => _buildEmployeeItem(context, employee, appProvider)),
        ],
      ),
    );
  }

  Widget _buildEmployeeItem(BuildContext context, Employee employee, AppProvider appProvider) {
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
            backgroundImage: NetworkImage(employee.avatar),
            radius: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  employee.position,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                Text(
                  employee.department,
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
                color: _getEmployeeStatusColor(employee.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: _getEmployeeStatusColor(employee.status),
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

  void _handleUserAction(BuildContext context, User user, String action, AppProvider appProvider) {
    switch (action) {
      case 'activate':
        appProvider.updateUserStatus(user.id, 'active');
        _showMessage(context, 'Utilisateur activé');
        break;
      case 'deactivate':
        appProvider.updateUserStatus(user.id, 'inactive');
        _showMessage(context, 'Utilisateur désactivé');
        break;
      case 'delete':
        appProvider.deleteUser(user.id);
        _showMessage(context, 'Utilisateur supprimé');
        break;
    }
  }

  void _handleEmployeeAction(BuildContext context, Employee employee, String action, AppProvider appProvider) {
    switch (action) {
      case 'promote':
        // Implement promotion logic
        _showMessage(context, 'Employé promu');
        break;
      case 'demote':
        // Implement demotion logic
        _showMessage(context, 'Employé rétrogradé');
        break;
      case 'transfer':
        // Implement transfer logic
        _showMessage(context, 'Employé transféré');
        break;
      case 'terminate':
        appProvider.updateEmployeeStatus(employee.id, 'terminated');
        _showMessage(context, 'Employé licencié');
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
