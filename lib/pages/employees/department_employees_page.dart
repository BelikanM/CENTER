import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../components/futuristic_card.dart';
import 'employee_detail_page.dart';

class DepartmentEmployeesPage extends StatefulWidget {
  final String token;
  final String department;
  final Color departmentColor;

  const DepartmentEmployeesPage({
    super.key,
    required this.token,
    required this.department,
    required this.departmentColor,
  });

  @override
  State<DepartmentEmployeesPage> createState() => _DepartmentEmployeesPageState();
}

class _DepartmentEmployeesPageState extends State<DepartmentEmployeesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getEmployees(
        widget.token,
        department: widget.department,
      );

      if (result.containsKey('employees')) {
        setState(() {
          _employees = List<Map<String, dynamic>>.from(result['employees'] ?? []);
          _filteredEmployees = _employees;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((employee) {
          final name = (employee['name'] ?? '').toLowerCase();
          final email = (employee['email'] ?? '').toLowerCase();
          final role = (employee['role'] ?? '').toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) ||
                 email.contains(searchQuery) ||
                 role.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToEmployeeDetail(Map<String, dynamic> employee) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailPage(
          token: widget.token,
          employee: employee,
        ),
      ),
    );

    if (result == true) {
      _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              widget.departmentColor.withValues(alpha: 0.1),
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00FF88),
                        ),
                      )
                    : _filteredEmployees.isEmpty
                        ? _buildEmptyState()
                        : _buildEmployeeGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.departmentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.departmentColor.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              color: widget.departmentColor,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.department,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_filteredEmployees.length} employé${_filteredEmployees.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.departmentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.departmentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              _getDepartmentIcon(widget.department),
              color: widget.departmentColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
            color: widget.departmentColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filterEmployees('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: _filterEmployees,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: widget.departmentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 50,
              color: widget.departmentColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun employé trouvé',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Ce département n\'a pas encore d\'employés'
                : 'Aucun résultat pour "${_searchController.text}"',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];
        return _buildEmployeeCard(employee);
      },
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    final imageUrl = employee['faceImage'] ?? employee['avatar'] ?? '';
    final name = employee['name'] ?? 'Sans nom';
    final role = employee['role'] ?? employee['position'] ?? 'Sans poste';
    final status = employee['status'] ?? 'offline';

    return GestureDetector(
      onTap: () => _navigateToEmployeeDetail(employee),
      child: FuturisticCard(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          widget.departmentColor.withValues(alpha: 0.3),
                          widget.departmentColor.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: widget.departmentColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person_rounded,
                                color: widget.departmentColor.withValues(alpha: 0.5),
                                size: 40,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              color: widget.departmentColor.withValues(alpha: 0.5),
                              size: 40,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(status).withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.departmentColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.departmentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Voir détails',
                      style: TextStyle(
                        color: widget.departmentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDepartmentIcon(String department) {
    switch (department.toLowerCase()) {
      case 'it':
      case 'informatique':
        return Icons.computer_rounded;
      case 'rh':
      case 'ressources humaines':
        return Icons.people_rounded;
      case 'marketing':
        return Icons.campaign_rounded;
      case 'ventes':
      case 'commercial':
        return Icons.trending_up_rounded;
      case 'finance':
        return Icons.account_balance_rounded;
      case 'design':
        return Icons.palette_rounded;
      case 'topographie':
        return Icons.terrain_rounded;
      case 'geotech':
      case 'géotechnique':
        return Icons.landscape_rounded;
      case 'bureautique':
        return Icons.desktop_windows_rounded;
      case 'production':
        return Icons.factory_rounded;
      case 'logistique':
        return Icons.local_shipping_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
