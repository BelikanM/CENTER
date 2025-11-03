import 'package:flutter/material.dart';
import '../components/futuristic_card.dart';
import '../components/employee_card.dart';
import '../components/department_chip.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = 'Tous';
  late TabController _tabController;

  final List<String> _departments = [
    'Tous',
    'IT',
    'RH',
    'Marketing',
    'Ventes',
    'Finance',
    'Design',
  ];

  final List<Map<String, dynamic>> _employees = [
    {
      'name': 'Marie Dubois',
      'role': 'Développeuse Senior',
      'department': 'IT',
      'email': 'marie.dubois@company.com',
      'phone': '+33 6 12 34 56 78',
      'status': 'online',
      'avatar': '',
    },
    {
      'name': 'Thomas Martin',
      'role': 'Chef de Projet',
      'department': 'IT',
      'email': 'thomas.martin@company.com',
      'phone': '+33 6 98 76 54 32',
      'status': 'away',
      'avatar': '',
    },
    {
      'name': 'Sophie Laurent',
      'role': 'Designer UX/UI',
      'department': 'Design',
      'email': 'sophie.laurent@company.com',
      'phone': '+33 6 11 22 33 44',
      'status': 'online',
      'avatar': '',
    },
    {
      'name': 'Pierre Dupont',
      'role': 'Responsable RH',
      'department': 'RH',
      'email': 'pierre.dupont@company.com',
      'phone': '+33 6 55 66 77 88',
      'status': 'offline',
      'avatar': '',
    },
    {
      'name': 'Emma Bernard',
      'role': 'Marketing Manager',
      'department': 'Marketing',
      'email': 'emma.bernard@company.com',
      'phone': '+33 6 99 88 77 66',
      'status': 'online',
      'avatar': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1A0033),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmployeesList(),
                    _buildDepartments(),
                    _buildStatistics(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employés',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Gestion du personnel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un employé...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Liste'),
          Tab(text: 'Départements'),
          Tab(text: 'Statistiques'),
        ],
      ),
    );
  }

  Widget _buildEmployeesList() {
    final filteredEmployees = _employees.where((employee) {
      final matchesSearch = employee['name']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchesDepartment = _selectedDepartment == 'Tous' ||
          employee['department'] == _selectedDepartment;
      return matchesSearch && matchesDepartment;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildDepartmentFilter(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: filteredEmployees.length,
            itemBuilder: (context, index) {
              final employee = filteredEmployees[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EmployeeCard(
                  name: employee['name'],
                  role: employee['role'],
                  department: employee['department'],
                  email: employee['email'],
                  phone: employee['phone'],
                  status: employee['status'],
                  avatar: employee['avatar'],
                  onTap: () => _showEmployeeDetails(employee),
                  onMessage: () => _showMessageDialog(employee),
                  onCall: () => _makeCall(employee),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final department = _departments[index];
          final isSelected = department == _selectedDepartment;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DepartmentChip(
              label: department,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedDepartment = department;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDepartments() {
    final departmentStats = <String, int>{};
    for (final employee in _employees) {
      final dept = employee['department'];
      departmentStats[dept] = (departmentStats[dept] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: departmentStats.length,
        itemBuilder: (context, index) {
          final entry = departmentStats.entries.elementAt(index);
          final colors = [
            const Color(0xFF00D4FF),
            const Color(0xFFFF6B35),
            const Color(0xFF9C27B0),
            const Color(0xFF4CAF50),
            const Color(0xFFFF9800),
            const Color(0xFFE91E63),
          ];
          
          return FuturisticCard(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors[index % colors.length].withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      _getDepartmentIcon(entry.key),
                      color: colors[index % colors.length],
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    final totalEmployees = _employees.length;
    final onlineEmployees = _employees.where((e) => e['status'] == 'online').length;
    final departmentCount = _employees.map((e) => e['department']).toSet().length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          FuturisticCard(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalEmployees.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Employés au total',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FuturisticCard(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          onlineEmployees.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'En ligne',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FuturisticCard(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.business_rounded,
                            color: Color(0xFFFF6B35),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          departmentCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Départements',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FuturisticCard(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activité récente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityItem(
                    'Marie Dubois s\'est connectée',
                    'Il y a 5 minutes',
                    Colors.green,
                  ),
                  _buildActivityItem(
                    'Thomas Martin a mis à jour son profil',
                    'Il y a 1 heure',
                    const Color(0xFF00D4FF),
                  ),
                  _buildActivityItem(
                    'Sophie Laurent a rejoint l\'équipe Design',
                    'Il y a 2 heures',
                    const Color(0xFFFF6B35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDepartmentIcon(String department) {
    switch (department) {
      case 'IT': return Icons.computer_rounded;
      case 'RH': return Icons.people_rounded;
      case 'Marketing': return Icons.campaign_rounded;
      case 'Ventes': return Icons.trending_up_rounded;
      case 'Finance': return Icons.account_balance_rounded;
      case 'Design': return Icons.palette_rounded;
      default: return Icons.business_rounded;
    }
  }

  void _showAddEmployeeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 24),
            ),
            Text(
              'Nouvel employé',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            // Formulaire d'ajout d'employé ici
            const Spacer(),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text(
                      'Ajouter l\'employé',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeDetails(Map<String, dynamic> employee) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.black,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              employee['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              employee['role'],
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  Icons.message_rounded,
                  'Message',
                  () => _showMessageDialog(employee),
                ),
                _buildActionButton(
                  Icons.call_rounded,
                  'Appeler',
                  () => _makeCall(employee),
                ),
                _buildActionButton(
                  Icons.email_rounded,
                  'Email',
                  () => _sendEmail(employee),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF6B35),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(Map<String, dynamic> employee) {
    Navigator.pop(context);
    // Implémenter la messagerie
  }

  void _makeCall(Map<String, dynamic> employee) {
    Navigator.pop(context);
    // Implémenter l'appel
  }

  void _sendEmail(Map<String, dynamic> employee) {
    Navigator.pop(context);
    // Implémenter l'envoi d'email
  }
}
