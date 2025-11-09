import 'package:flutter/material.dart';
import '../api_service.dart';
import 'employees/employee_detail_page.dart';

class OnlineEmployeesPage extends StatefulWidget {
  final String token;
  final int onlineCount;

  const OnlineEmployeesPage({
    super.key,
    required this.token,
    required this.onlineCount,
  });

  @override
  State<OnlineEmployeesPage> createState() => _OnlineEmployeesPageState();
}

class _OnlineEmployeesPageState extends State<OnlineEmployeesPage> {
  List<dynamic> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOnlineEmployees();
  }

  Future<void> _loadOnlineEmployees() async {
    try {
      final data = await ApiService().getOnlineEmployees(widget.token);
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
          'Employés en ligne',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOnlineEmployees,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : Column(
              children: [
                // Header avec compteur
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
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
                          Icons.circle,
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
                              _employees.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Employés connectés actuellement',
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

                // Liste des employés
                Expanded(
                  child: _employees.isEmpty
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
                                'Aucun employé en ligne',
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
                          itemCount: _employees.length,
                          itemBuilder: (context, index) {
                            final employee = _employees[index];
                            return _buildEmployeeItem(employee);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmployeeItem(Map<String, dynamic> employee) {
    final hasLocation = employee['hasLocation'] == true;
    final lastSeen = employee['lastSeen'];
    String timeAgo = 'Maintenant';
    
    if (lastSeen != null) {
      try {
        final lastSeenDate = DateTime.parse(lastSeen);
        final diff = DateTime.now().difference(lastSeenDate);
        if (diff.inMinutes < 1) {
          timeAgo = 'À l\'instant';
        } else if (diff.inMinutes < 60) {
          timeAgo = 'Il y a ${diff.inMinutes} min';
        } else if (diff.inHours < 24) {
          timeAgo = 'Il y a ${diff.inHours}h';
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailPage(
              employee: {
                '_id': employee['id'],
                'firstName': employee['name']?.split(' ')[0] ?? '',
                'lastName': employee['name']?.split(' ').skip(1).join(' ') ?? '',
                'department': employee['department'],
                'role': employee['role'],
                'email': employee['email'],
                'phone': employee['phone'],
                'faceImage': employee['image'],
                'status': 'online',
              },
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
            color: Colors.green.withValues(alpha: 0.3),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green.withValues(alpha: 0.2),
                backgroundImage: employee['image'] != null && employee['image'].isNotEmpty
                    ? NetworkImage(employee['image'])
                    : null,
                child: employee['image'] == null || employee['image'].isEmpty
                    ? Text(
                        employee['name']?[0]?.toUpperCase() ?? 'E',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0A0E21), width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            employee['name'] ?? 'Non défini',
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
              const SizedBox(height: 4),
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
                  if (hasLocation) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.green.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Localisé',
                      style: TextStyle(
                        color: Colors.green.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
