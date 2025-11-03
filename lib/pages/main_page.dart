import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'home_page.dart';
import 'social_page.dart';
import 'employees_page.dart';
import 'profile_page.dart';
import 'auth_page.dart';
import 'admin_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (!appProvider.isAuthenticated) {
          return const AuthPage();
        }

        return Scaffold(
          body: IndexedStack(
            index: appProvider.currentIndex,
            children: [
              const HomePage(),
              const SocialPage(),
              const EmployeesPage(),
              const ProfilePage(),
              const AdminPage(),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(context, appProvider),
          // Use centerFloat - no docking since we removed the gap completely
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: _buildBottomNavigationBar(context, appProvider),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, AppProvider appProvider) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, AppProvider appProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF25D366),
        unselectedItemColor: Colors.black54,
        currentIndex: appProvider.currentIndex,
        onTap: appProvider.setCurrentIndex,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center_rounded),
            label: 'Employés',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_rounded),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Créer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCreateOption(
                  context,
                  icon: Icons.edit_rounded,
                  label: 'Publication',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(context);
                    // Naviguer vers création de publication
                  },
                ),
                _buildCreateOption(
                  context,
                  icon: Icons.person_add_rounded,
                  label: 'Employé',
                  color: const Color(0xFF128C7E),
                  onTap: () {
                    Navigator.pop(context);
                    // Naviguer vers création d'employé
                  },
                ),
                _buildCreateOption(
                  context,
                  icon: Icons.location_on_rounded,
                  label: 'Marqueur',
                  color: const Color(0xFF075E54),
                  onTap: () {
                    Navigator.pop(context);
                    // Naviguer vers création de marqueur
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
