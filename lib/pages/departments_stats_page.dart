import 'package:flutter/material.dart';
import '../api_service.dart';
import 'employees/department_employees_page.dart';

class DepartmentsStatsPage extends StatefulWidget {
  final String token;
  final int departmentCount;

  const DepartmentsStatsPage({
    super.key,
    required this.token,
    required this.departmentCount,
  });

  @override
  State<DepartmentsStatsPage> createState() => _DepartmentsStatsPageState();
}

class _DepartmentsStatsPageState extends State<DepartmentsStatsPage> {
  List<dynamic> _departments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final data = await ApiService().getDepartmentsDetails(widget.token);
      setState(() {
        _departments = data['departments'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Statistiques par département',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            )
          : Column(
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _departments.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Départements actifs',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des départements
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _departments.length,
                    itemBuilder: (context, index) {
                      final department = _departments[index];
                      return _buildDepartmentCard(department, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> department, int index) {
    final name = department['name'] ?? 'Non défini';
    final total = department['total'] ?? 0;
    final online = department['online'] ?? 0;
    final offline = department['offline'] ?? 0;
    
    final colors = [
      const Color(0xFF00D4FF),
      const Color(0xFFFF6B35),
      const Color(0xFF9C27B0),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFFFFC107),
      const Color(0xFF673AB7),
      const Color(0xFF009688),
      const Color(0xFFFF5722),
      const Color(0xFF3F51B5),
    ];
    
    final color = colors[index % colors.length];
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DepartmentEmployeesPage(
              token: widget.token,
              department: name,
              departmentColor: color,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getDepartmentIcon(name),
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$total employé${total > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ],
              ),
            ),
            
            // Statistiques
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('En ligne', online, Colors.green),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  _buildStatItem('Hors ligne', offline, Colors.grey),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  _buildStatItem('Absent', department['away'] ?? 0, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getDepartmentIcon(String department) {
    switch (department.toLowerCase()) {
      case 'it':
        return Icons.computer_rounded;
      case 'rh':
        return Icons.people_rounded;
      case 'marketing':
        return Icons.campaign_rounded;
      case 'ventes':
        return Icons.trending_up_rounded;
      case 'finance':
        return Icons.account_balance_rounded;
      case 'design':
        return Icons.palette_rounded;
      case 'topographie':
        return Icons.map_rounded;
      case 'geotech':
        return Icons.terrain_rounded;
      case 'bureautique':
        return Icons.desktop_windows_rounded;
      case 'production':
        return Icons.precision_manufacturing_rounded;
      case 'logistique':
        return Icons.local_shipping_rounded;
      default:
        return Icons.business_rounded;
    }
  }
}
