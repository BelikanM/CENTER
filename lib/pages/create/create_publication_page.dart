import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../main.dart';
import '../../api_service.dart';

class CreatePublicationPage extends StatefulWidget {
  const CreatePublicationPage({super.key});

  @override
  State<CreatePublicationPage> createState() => _CreatePublicationPageState();
}

class _CreatePublicationPageState extends State<CreatePublicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String _selectedType = 'text';
  String _selectedVisibility = 'public';
  final List<File> _selectedMedia = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      if (isVideo) {
        final XFile? video = await _picker.pickVideo(source: source);
        if (video != null && mounted) {
          setState(() {
            _selectedMedia.add(File(video.path));
            _selectedType = 'video';
          });
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty && mounted) {
          setState(() {
            _selectedMedia.addAll(images.map((img) => File(img.path)));
            _selectedType = 'photo';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
      if (_selectedMedia.isEmpty) {
        _selectedType = 'text';
      }
    });
  }

  Future<void> _createPublication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken;

      if (token == null) {
        throw Exception('Token manquant');
      }

      await ApiService.createPublication(
        token,
        content: _contentController.text.trim(),
        type: _selectedType,
        visibility: _selectedVisibility,
        tags: _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        mediaFiles: _selectedMedia,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publication créée avec succès !'),
            backgroundColor: Color(0xFF25D366),
          ),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer le succès
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
          'Nouvelle Publication',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPublication,
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
                    'Publier',
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
            // Type de publication
            _buildSectionTitle('Type de publication'),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            
            const SizedBox(height: 20),
            
            // Contenu
            _buildSectionTitle('Contenu'),
            const SizedBox(height: 8),
            _buildContentField(),
            
            const SizedBox(height: 20),
            
            // Médias
            _buildSectionTitle('Médias'),
            const SizedBox(height: 8),
            _buildMediaSection(),
            
            const SizedBox(height: 20),
            
            // Tags
            _buildSectionTitle('Tags (séparés par des virgules)'),
            const SizedBox(height: 8),
            _buildTagsField(),
            
            const SizedBox(height: 20),
            
            // Visibilité
            _buildSectionTitle('Visibilité'),
            const SizedBox(height: 8),
            _buildVisibilitySelector(),
            
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

  Widget _buildTypeSelector() {
    final types = [
      {'value': 'text', 'icon': Icons.text_fields, 'label': 'Texte'},
      {'value': 'photo', 'icon': Icons.photo, 'label': 'Photo'},
      {'value': 'video', 'icon': Icons.video_library, 'label': 'Vidéo'},
      {'value': 'article', 'icon': Icons.article, 'label': 'Article'},
      {'value': 'event', 'icon': Icons.event, 'label': 'Événement'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type['value'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF25D366) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF25D366) : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentField() {
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
        controller: _contentController,
        maxLines: 8,
        decoration: InputDecoration(
          hintText: 'Que voulez-vous partager ?',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Le contenu est requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Boutons d'ajout de média
        Row(
          children: [
            Expanded(
              child: _buildMediaButton(
                icon: Icons.photo_library,
                label: 'Ajouter des photos',
                onTap: () => _pickMedia(ImageSource.gallery, false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMediaButton(
                icon: Icons.videocam,
                label: 'Ajouter une vidéo',
                onTap: () => _pickMedia(ImageSource.gallery, true),
              ),
            ),
          ],
        ),
        
        if (_selectedMedia.isNotEmpty) ...[
          const SizedBox(height: 16),
          // Prévisualisation des médias
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedMedia.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedMedia[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeMedia(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF25D366)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsField() {
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
        controller: _tagsController,
        decoration: InputDecoration(
          hintText: 'Ex: technologie, innovation, entreprise',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.tag, color: Color(0xFF25D366)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildVisibilitySelector() {
    final options = [
      {'value': 'public', 'icon': Icons.public, 'label': 'Public'},
      {'value': 'friends', 'icon': Icons.people, 'label': 'Amis'},
      {'value': 'private', 'icon': Icons.lock, 'label': 'Privé'},
    ];

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
      child: Column(
        children: options.map((option) {
          final isSelected = _selectedVisibility == option['value'];
          final isLast = option == options.last;
          
          return InkWell(
            onTap: () => setState(() => _selectedVisibility = option['value'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    option['icon'] as IconData,
                    color: isSelected ? const Color(0xFF25D366) : Colors.black54,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option['label'] as String,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF25D366),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
