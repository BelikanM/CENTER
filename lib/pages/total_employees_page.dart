import 'package:flutter/material.dart';
import '../api_service.dart';
import 'employees/employee_detail_page.dart';

class TotalEmployeesPage extends StatefulWidget {
  final String token;
  final int totalCount;

  const TotalEmployeesPage({
    super.key,
    required this.token,
    required this.totalCount,
  });

  @override
  State<TotalEmployeesPage> createState() => _TotalEmployeesPageState();
}

class _TotalEmployeesPageState extends State<TotalEmployeesPage> {
  List<dynamic> _employees = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final data = await ApiService.getEmployees(widget.token);
      setState(() {
        _employees = data['employees'] ?? [];
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

  List<dynamic> get _filteredEmployees {
    var filtered = _employees;

    // Filtrer par statut
    if (_filterStatus != 'all') {
      filtered = filtered.where((e) => e['status'] == _filterStatus).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        final name = '${e['firstName']} ${e['lastName']}'.toLowerCase();
        final email = (e['email'] as String? ?? '').toLowerCase();
        final dept = (e['department'] as String? ?? '').toLowerCase();
        return name.contains(query) || email.contains(query) || dept.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final statusCounts = {
      'online': _employees.where((e) => e['status'] == 'online').length,
      'offline': _employees.where((e) => e['status'] == 'offline').length,
      'away': _employees.where((e) => e['status'] == 'away').length,
    };

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
          'Tous les employés',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
            )
          : Column(
              children: [
                // Stats en haut
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total', widget.totalCount, Icons.groups_rounded),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildStatItem('En ligne', statusCounts['online']!, Icons.circle, Colors.green),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildStatItem('Hors ligne', statusCounts['offline']!, Icons.circle, Colors.grey),
                    ],
                  ),
                ),

                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un employé...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF00D4FF)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Filtres par statut
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tous', 'all', _employees.length),
                        const SizedBox(width: 8),
                        _buildFilterChip('En ligne', 'online', statusCounts['online']!),
                        const SizedBox(width: 8),
                        _buildFilterChip('Absent', 'away', statusCounts['away']!),
                        const SizedBox(width: 8),
                        _buildFilterChip('Hors ligne', 'offline', statusCounts['offline']!),
                      ],
                    ),
                  ),
                ),

                // Liste des employés
                Expanded(
                  child: _filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off_rounded,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun employé trouvé',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = _filteredEmployees[index];
                            return _buildEmployeeItem(employee);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, [Color? iconColor]) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeItem(Map<String, dynamic> employee) {
    final status = employee['status'] ?? 'offline';
    Color statusColor = Colors.grey;
    if (status == 'online') statusColor = Colors.green;
    if (status == 'away') statusColor = Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailPage(
              employee: employee,
              token: widget.token,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF00D4FF).withValues(alpha: 0.2),
                backgroundImage: employee['faceImage'] != null
                    ? NetworkImage(employee['faceImage'])
                    : null,
                child: employee['faceImage'] == null
                    ? Text(
                        '${employee['firstName']?[0] ?? ''}${employee['lastName']?[0] ?? ''}',
                        style: const TextStyle(
                          color: Color(0xFF00D4FF),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0A0E21), width: 2),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            '${employee['firstName']} ${employee['lastName']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                employee['role'] ?? 'Non défini',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.business_rounded,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    employee['department'] ?? 'Non défini',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.3),
            size: 16,
          ),
        ),
      ),
    );
  }
}
