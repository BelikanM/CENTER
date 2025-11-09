import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../main.dart';
import '../../api_service.dart';

class CreateEmployeePage extends StatefulWidget {
  const CreateEmployeePage({super.key});

  @override
  State<CreateEmployeePage> createState() => _CreateEmployeePageState();
}

class _CreateEmployeePageState extends State<CreateEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  
  String _selectedDepartment = 'IT';
  File? _faceImage;
  File? _certificateFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _departments = [
    'IT',
    'RH',
    'Marketing',
    'Ventes',
    'Finance',
    'Design',
    'Production',
    'Support',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFace) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        setState(() {
          if (isFace) {
            _faceImage = File(image.path);
          } else {
            _certificateFile = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken;

      if (token == null) {
        throw Exception('Token manquant');
      }

      await ApiService.createEmployee(
        token,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        department: _selectedDepartment,
        role: _roleController.text.trim(),
        faceImage: _faceImage,
        certificate: _certificateFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employé créé avec succès !'),
            backgroundColor: Color(0xFF25D366),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF25D366),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nouvel Employé',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createEmployee,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Créer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo de profil
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(true),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF25D366), width: 3),
                    image: _faceImage != null
                        ? DecorationImage(
                            image: FileImage(_faceImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _faceImage == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Ajouter une photo',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nom
            _buildSectionTitle('Nom complet'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Ex: Jean Dupont',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email
            _buildSectionTitle('Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'Ex: jean.dupont@entreprise.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est requis';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Téléphone
            _buildSectionTitle('Téléphone'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: 'Ex: +33 6 12 34 56 78',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le téléphone est requis';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Rôle
            _buildSectionTitle('Rôle / Poste'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _roleController,
              hint: 'Ex: Développeur Senior',
              icon: Icons.work,
            ),
            
            const SizedBox(height: 16),
            
            // Département
            _buildSectionTitle('Département'),
            const SizedBox(height: 8),
            _buildDepartmentDropdown(),
            
            const SizedBox(height: 16),
            
            // Certificat
            _buildSectionTitle('Certificat (optionnel)'),
            const SizedBox(height: 8),
            _buildCertificateSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF25D366)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedDepartment,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.business, color: Color(0xFF25D366)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _departments.map((dept) {
          return DropdownMenuItem(
            value: dept,
            child: Text(dept),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedDepartment = value);
          }
        },
      ),
    );
  }

  Widget _buildCertificateSection() {
    return GestureDetector(
      onTap: () => _pickImage(false),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _certificateFile == null
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file, color: Color(0xFF25D366)),
                  SizedBox(width: 8),
                  Text(
                    'Joindre un certificat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _certificateFile!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Certificat joint',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() => _certificateFile = null);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
