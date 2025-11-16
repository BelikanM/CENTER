import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; // ✅ AJOUT - Pour la géolocalisation réelle
import 'package:permission_handler/permission_handler.dart'; // ✅ AJOUT - Pour les permissions
import 'dart:io';
import '../../main.dart';
import '../../api_service.dart';

class CreateMarkerPage extends StatefulWidget {
  const CreateMarkerPage({super.key});

  @override
  State<CreateMarkerPage> createState() => _CreateMarkerPageState();
}

class _CreateMarkerPageState extends State<CreateMarkerPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  final MapController _mapController = MapController();
  
  LatLng? _selectedPosition; // ✅ MODIFIÉ - null par défaut
  Color _selectedColor = Colors.red;
  final List<File> _selectedPhotos = [];
  bool _isLoading = false;
  bool _isLoadingLocation = true; // ✅ AJOUT - Indicateur de chargement GPS
  String _locationStatus = 'Recherche de votre position...'; // ✅ AJOUT - Statut GPS

  final ImagePicker _picker = ImagePicker();

  final List<Color> _markerColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationAndGetPosition(); // ✅ AJOUT - Demander la position GPS au démarrage
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // ✅ NOUVELLE MÉTHODE - Demander la permission et obtenir la position GPS réelle
  Future<void> _requestLocationAndGetPosition() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Vérification des permissions...';
    });

    try {
      // 1. Vérifier la permission de localisation
      PermissionStatus permission = await Permission.location.status;
      
      if (permission.isDenied) {
        setState(() => _locationStatus = 'Demande d\'autorisation...');
        permission = await Permission.location.request();
      }

      if (permission.isPermanentlyDenied) {
        setState(() {
          _locationStatus = '❌ Permission refusée. Activez la dans les paramètres.';
          _isLoadingLocation = false;
        });
        _showLocationSettingsDialog();
        return;
      }

      if (permission.isDenied) {
        setState(() {
          _locationStatus = '❌ Permission de localisation refusée';
          _isLoadingLocation = false;
        });
        return;
      }

      // 2. Vérifier si le service de localisation est activé
      setState(() => _locationStatus = 'Vérification du GPS...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = '❌ GPS désactivé. Activez-le dans les paramètres.';
          _isLoadingLocation = false;
        });
        _showEnableLocationDialog();
        return;
      }

      // 3. Obtenir la position GPS réelle
      setState(() => _locationStatus = 'Obtention de votre position GPS...');
      
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, // ✅ Haute précision
          distanceFilter: 10, // Mise à jour tous les 10 mètres
        ),
      );

      // 4. Mettre à jour la position sur la carte
      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _locationStatus = '✅ Position GPS obtenue';
        _isLoadingLocation = false;
      });

      // 5. Centrer la carte sur la position réelle (après le setState)
      // Attendre que le widget soit reconstruit avant de bouger la carte
      if (_selectedPosition != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(_selectedPosition!, 15.0);
          } catch (e) {
            debugPrint('⚠️ Impossible de centrer la carte: $e');
          }
        });
      }

      debugPrint('✅ Position GPS: ${position.latitude}, ${position.longitude}');
      debugPrint('📍 Précision: ${position.accuracy}m');
      
    } catch (e) {
      debugPrint('❌ Erreur géolocalisation: $e');
      setState(() {
        _locationStatus = '❌ Erreur: $e';
        _isLoadingLocation = false;
      });
      
      _showSnackBar('Erreur de géolocalisation: $e', isError: true);
    }
  }

  // ✅ NOUVELLE MÉTHODE - Dialogue pour activer le GPS
  void _showEnableLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GPS désactivé'),
        content: const Text('Veuillez activer le GPS pour utiliser cette fonctionnalité.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Ouvrir paramètres'),
          ),
        ],
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE - Dialogue pour activer les permissions
  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission refusée'),
        content: const Text('Veuillez autoriser l\'accès à la localisation dans les paramètres de l\'application.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Ouvrir paramètres'),
          ),
        ],
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE - Afficher snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF25D366),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _pickPhotos() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedPhotos.addAll(images.map((img) => File(img.path)));
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

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _createMarker() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPosition == null) { // ✅ Vérification GPS
      _showSnackBar('❌ Veuillez attendre que la position GPS soit obtenue', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken;

      if (token == null) {
        throw Exception('Token manquant');
      }

      await ApiService.createMarker(
        token,
        latitude: _selectedPosition!.latitude, // ✅ Ajout ! car déjà vérifié
        longitude: _selectedPosition!.longitude, // ✅ Ajout ! car déjà vérifié
        title: _titleController.text.trim(),
        comment: _commentController.text.trim(),
        color: '#${_selectedColor.toARGB32().toRadixString(16).substring(2, 8).toUpperCase()}',
        photos: _selectedPhotos,
      );

      if (mounted) {
        _showSnackBar('✅ Marqueur créé avec succès !');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Erreur: $e', isError: true);
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
          'Nouveau Marqueur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createMarker,
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
        child: Column(
          children: [
            // Carte
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPosition ?? LatLng(48.8566, 2.3522), // ✅ Fallback si null
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedPosition = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', // ✅ CHANGÉ - Carto au lieu de OpenStreetMap
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (_selectedPosition != null) // ✅ Vérification null
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPosition!, // ✅ Ajout ! car déjà vérifié
                              width: 40.0,
                              height: 40.0,
                              child: Icon(
                                Icons.location_on,
                                color: _selectedColor,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📍 Appuyez sur la carte pour positionner le marqueur',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedPosition != null // ✅ Vérification null
                                ? 'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                                  'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}'
                                : 'Position GPS non disponible',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Formulaire
            Expanded(
              flex: 3,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ✅ AJOUT - Statut GPS
                  if (_isLoadingLocation)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _locationStatus,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _locationStatus,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _requestLocationAndGetPosition,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Actualiser', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Titre
                  _buildSectionTitle('Titre du marqueur'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'Ex: Bureau principal',
                    icon: Icons.title,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le titre est requis';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Commentaire
                  _buildSectionTitle('Commentaire (optionnel)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _commentController,
                    hint: 'Ajouter une description...',
                    icon: Icons.comment,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Couleur du marqueur
                  _buildSectionTitle('Couleur du marqueur'),
                  const SizedBox(height: 8),
                  _buildColorPicker(),
                  
                  const SizedBox(height: 16),
                  
                  // Photos
                  _buildSectionTitle('Photos (optionnel)'),
                  const SizedBox(height: 8),
                  _buildPhotoSection(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
    int maxLines = 1,
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
        maxLines: maxLines,
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

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _markerColors.map((color) {
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickPhotos,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, color: Color(0xFF25D366)),
                SizedBox(width: 8),
                Text(
                  'Ajouter des photos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_selectedPhotos.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedPhotos[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
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
}
