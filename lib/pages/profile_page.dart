import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../components/futuristic_card.dart';
import '../components/gradient_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final user = appProvider.currentUser;

        return Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 24),
              _buildQuickStats(context, appProvider),
              const SizedBox(height: 24),
              _buildSettings(context, appProvider),
              const SizedBox(height: 24),
              _buildLogoutButton(context, appProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic>? user) {
    return FuturisticCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.black,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?['name'] ?? 'Utilisateur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?['email'] ?? 'email@example.com',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                'Membre Actif',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, AppProvider appProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Publications',
            value: '${appProvider.posts.where((p) => p.userId == appProvider.currentUser?['id']).length}',
            icon: Icons.article_rounded,
            color: const Color(0xFF00D4FF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Amis',
            value: '42',
            icon: Icons.people_rounded,
            color: const Color(0xFFFF6B35),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return FuturisticCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context, AppProvider appProvider) {
    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Paramètres',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Gérer les notifications push',
            onTap: () => _showMessage(context, 'Notifications - Fonctionnalité à venir'),
          ),
          _buildSettingItem(
            context,
            icon: Icons.security_rounded,
            title: 'Sécurité',
            subtitle: 'Changer le mot de passe',
            onTap: () => _showMessage(context, 'Sécurité - Fonctionnalité à venir'),
          ),
          _buildSettingItem(
            context,
            icon: Icons.palette_rounded,
            title: 'Thème',
            subtitle: 'Personnaliser l\'apparence',
            onTap: () => _showMessage(context, 'Thème - Fonctionnalité à venir'),
          ),
          _buildSettingItem(
            context,
            icon: Icons.help_rounded,
            title: 'Aide & Support',
            subtitle: 'Obtenir de l\'aide',
            onTap: () => _showMessage(context, 'Aide - Fonctionnalité à venir'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00D4FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppProvider appProvider) {
    return GradientButton(
      onPressed: () => _showLogoutDialog(context, appProvider),
      gradientColors: const [Color(0xFFFF6B35), Color(0xFFE55A2B)],
      child: const Text(
        'Se Déconnecter',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

  void _showLogoutDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Se Déconnecter',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              appProvider.logout();
            },
            child: const Text(
              'Se Déconnecter',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }
}
