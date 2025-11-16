import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_service.dart';
import '../../components/futuristic_card.dart';

class EmployeeDetailPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> employee;

  const EmployeeDetailPage({
    super.key,
    required this.token,
    required this.employee,
  });

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _roleController;
  late String _selectedDepartment;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _newFaceImage;
  File? _newCertificate;
  final ImagePicker _picker = ImagePicker();

  final List<String> _departments = [
    'IT',
    'RH',
    'Finance',
    'Marketing',
    'Commercial',
    'Production',
  ];

  @override
  void initState() {
    super.initState();
    
    // 🔍 DEBUG: Afficher les données de l'employé reçu
    debugPrint('📋 EmployeeDetailPage - Données reçues:');
    debugPrint('   Clés disponibles: ${widget.employee.keys.toList()}');
    debugPrint('   name: ${widget.employee['name']}');
    debugPrint('   email: ${widget.employee['email']}');
    debugPrint('   phone: ${widget.employee['phone']}');
    debugPrint('   role: ${widget.employee['role']}');
    debugPrint('   position: ${widget.employee['position']}');
    debugPrint('   department: ${widget.employee['department']}');
    debugPrint('   faceImage: ${widget.employee['faceImage']}');
    debugPrint('   _id: ${widget.employee['_id']}');
    
    _nameController = TextEditingController(text: widget.employee['name'] ?? '');
    _emailController = TextEditingController(text: widget.employee['email'] ?? '');
    _phoneController = TextEditingController(text: widget.employee['phone'] ?? '');
    _roleController = TextEditingController(text: widget.employee['role'] ?? widget.employee['position'] ?? '');
    _selectedDepartment = widget.employee['department'] ?? 'IT';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
      _showErrorSnackBar('Veuillez remplir tous les champs obligatoires');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.updateEmployee(
        widget.token,
        widget.employee['_id'],
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _roleController.text,
        department: _selectedDepartment,
        faceImage: _newFaceImage,
        certificate: _newCertificate,
      );

      if (!mounted) return;

      if (result.containsKey('employee') || !result.containsKey('message')) {
        _showSuccessSnackBar('Employé mis à jour avec succès');
        setState(() => _isEditing = false);
        Navigator.pop(context, true); // Retourner true pour indiquer la mise à jour
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEmployee() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Confirmer la suppression',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cet employé ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.deleteEmployee(widget.token, widget.employee['_id']);

      if (!mounted) return;

      if (!result.containsKey('message') || result['message'].toString().contains('succès') || result['message'].toString().contains('supprimé')) {
        _showSuccessSnackBar('Employé supprimé avec succès');
        Navigator.pop(context, true); // Retourner true pour indiquer la suppression
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFaceImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _newFaceImage = File(image.path));
    }
  }

  Future<void> _pickCertificate() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _newCertificate = File(file.path));
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  // ========================================
  // MÉTHODES DE COMMUNICATION
  // ========================================

  Future<void> _sendEmail() async {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Row(
          children: [
            Icon(Icons.email_rounded, color: Color(0xFF00FF88)),
            SizedBox(width: 12),
            Text('Envoyer un email', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Sujet',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF0A0E21),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00FF88)),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF0A0E21),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00FF88)),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF88),
              foregroundColor: Colors.black,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (subjectController.text.isEmpty || messageController.text.isEmpty) {
        _showErrorSnackBar('Veuillez remplir tous les champs');
        return;
      }

      setState(() => _isLoading = true);

      try {
        await ApiService.sendEmailToEmployee(
          widget.token,
          widget.employee['_id'],
          subjectController.text,
          messageController.text,
        );
        
        if (!mounted) return;
        _showSuccessSnackBar('Email envoyé avec succès');
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('Erreur: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _openWhatsApp() async {
    setState(() => _isLoading = true);

    try {
      // 🔍 DEBUG: Vérifier les données avant l'appel API
      debugPrint('📱 WhatsApp - Données employé:');
      debugPrint('   _id: ${widget.employee['_id']}');
      debugPrint('   name: ${widget.employee['name']}');
      debugPrint('   Toutes les clés: ${widget.employee.keys.toList()}');
      
      final result = await ApiService.getWhatsAppLink(
        widget.token,
        widget.employee['_id'],
        message: 'Bonjour ${widget.employee['name'] ?? 'cher employé'}, je vous contacte depuis l\'application CENTER.',
      );

      if (!mounted) return;

      final whatsappLink = result['whatsappLink'] as String;
      final uri = Uri.parse(whatsappLink);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Impossible d\'ouvrir WhatsApp');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _makeCall() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getCallInfo(
        widget.token,
        widget.employee['_id'],
      );

      if (!mounted) return;

      final phone = result['phone'] as String;
      final uri = Uri.parse('tel:$phone');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar('Impossible d\'initier l\'appel');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails de l\'employé',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Color(0xFF00FF88)),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              onPressed: _deleteEmployee,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  if (!_isEditing) _buildContactButtons(),
                  if (!_isEditing) const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  if (_isEditing) _buildImageSection(),
                  if (_isEditing) const SizedBox(height: 24),
                  if (_isEditing) _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return FuturisticCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
                    ),
                  ),
                  child: _newFaceImage != null
                      ? ClipOval(child: Image.file(_newFaceImage!, fit: BoxFit.cover))
                      : (widget.employee['faceImage']?.toString().isNotEmpty == true
                          ? ClipOval(
                              child: Image.network(
                                widget.employee['faceImage'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.person_rounded,
                                  color: Colors.black,
                                  size: 60,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              color: Colors.black,
                              size: 60,
                            )),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickFaceImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF88),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1A1A1A), width: 3),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.employee['name'] ?? 'Sans nom',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.employee['role'] ?? widget.employee['position'] ?? 'Sans poste',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
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

  Widget _buildContactButtons() {
    return Row(
      children: [
        // Bouton Email
        Expanded(
          child: GestureDetector(
            onTap: _sendEmail,
            child: FuturisticCard(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.email_rounded,
                        color: Color(0xFF00D4FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton WhatsApp
        Expanded(
          child: GestureDetector(
            onTap: _openWhatsApp,
            child: FuturisticCard(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF25D366).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        color: Color(0xFF25D366),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'WhatsApp',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton Appel
        Expanded(
          child: GestureDetector(
            onTap: _makeCall,
            child: FuturisticCard(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Appeler',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return FuturisticCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoField(
              'Nom complet',
              _nameController,
              Icons.person_rounded,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'Email',
              _emailController,
              Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'Téléphone',
              _phoneController,
              Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'Poste',
              _roleController,
              Icons.work_rounded,
            ),
            const SizedBox(height: 16),
            _buildDepartmentDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: keyboardType,
          style: TextStyle(
            color: _isEditing ? Colors.black : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF00FF88), size: 20),
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isEditing ? const Color(0xFF00FF88).withValues(alpha: 0.3) : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00FF88), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Département',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedDepartment,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.business_rounded, color: Color(0xFF00FF88), size: 20),
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00FF88), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          items: _departments
              .map((dept) => DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  ))
              .toList(),
          onChanged: _isEditing
              ? (value) {
                  if (value != null) {
                    setState(() => _selectedDepartment = value);
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return FuturisticCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickCertificate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _newCertificate != null ? Icons.check_circle : Icons.insert_drive_file_rounded,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _newCertificate != null ? 'Nouveau certificat sélectionné' : 'Changer le certificat',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _newCertificate != null
                                ? _newCertificate!.path.split('/').last
                                : 'Tap pour sélectionner',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isEditing = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _updateEmployee,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF88),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.employee['status']) {
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
    switch (widget.employee['status']) {
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
