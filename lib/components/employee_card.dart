import 'package:flutter/material.dart';
import 'futuristic_card.dart';

class EmployeeCard extends StatelessWidget {
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final String status;
  final String avatar;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  const EmployeeCard({
    super.key,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.status,
    required this.avatar,
    required this.onTap,
    required this.onMessage,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FuturisticCard(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildStatusIndicator(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      department,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.email_rounded,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
            ),
          ),
          child: avatar.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                )
              : const Icon(
                  Icons.person_rounded,
                  color: Colors.black,
                  size: 30,
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1A1A1A),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: onMessage,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.message_rounded,
              color: Color(0xFF00D4FF),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onCall,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.call_rounded,
              color: Color(0xFFFF6B35),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
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

  String _getStatusText() {
    switch (status) {
      case 'online':
        return 'En ligne';
      case 'away':
        return 'Absent';
      case 'offline':
        return 'Hors ligne';
      default:
        return 'Inconnu';
    }
  }
}
