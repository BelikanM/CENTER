import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../api_service.dart';

class GPSTrackingDialog extends StatefulWidget {
  final String token;
  final String? userId;
  final VoidCallback? onSuccess;

  const GPSTrackingDialog({
    super.key,
    required this.token,
    this.userId,
    this.onSuccess,
  });

  @override
  State<GPSTrackingDialog> createState() => _GPSTrackingDialogState();
}

class _GPSTrackingDialogState extends State<GPSTrackingDialog> {
  bool _isTracking = false;
  String _status = 'GPS Inactif';
  String _errorMessage = '';
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _checkGPSStatus();
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }

  Future<void> _checkGPSStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _status = 'GPS Inactif';
          _errorMessage = 'Le service de localisation est désactivé';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'GPS Inactif';
          _errorMessage = 'Aucune permission partagée';
        });
      } else if (permission == LocationPermission.deniedForever) {
        setState(() {
          _status = 'GPS Inactif';
          _errorMessage = 'Permission refusée définitivement';
        });
      } else {
        setState(() {
          _status = 'GPS Prêt';
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  Future<void> _startTracking() async {
    try {
      // Vérifier l'ID utilisateur
      if (widget.userId == null || widget.userId!.isEmpty) {
        setState(() {
          _errorMessage = 'Exception: ID utilisateur introuvable';
        });
        return;
      }

      // Demander la permission
      PermissionStatus status = await Permission.location.request();
      
      if (!status.isGranted) {
        setState(() {
          _errorMessage = 'Permission de localisation refusée';
        });
        return;
      }

      // Vérifier si le service est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Service de localisation désactivé';
        });
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _isTracking = true;
        _status = 'GPS Actif';
        _errorMessage = '';
      });

      // Démarrer le suivi en temps réel
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mise à jour tous les 10 mètres
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
        });
        debugPrint('📍 Position mise à jour: ${position.latitude}, ${position.longitude}');
      });

      // Mettre à jour la position sur le serveur toutes les 30 secondes
      _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_currentPosition != null) {
          _updateServerPosition();
        }
      });

      // Première mise à jour immédiate
      _updateServerPosition();

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }

      debugPrint('✅ Suivi GPS démarré');
    } catch (e) {
      debugPrint('❌ Erreur démarrage GPS: $e');
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isTracking = false;
      });
    }
  }

  Future<void> _updateServerPosition() async {
    if (_currentPosition == null || widget.userId == null) return;

    try {
      await ApiService().updateEmployeeLocation(
        token: widget.token,
        employeeId: widget.userId!,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: 'Position en temps réel',
      );
      debugPrint('✅ Position envoyée au serveur');
    } catch (e) {
      debugPrint('❌ Erreur envoi position: $e');
    }
  }

  void _stopTracking() {
    _positionStream?.cancel();
    _updateTimer?.cancel();
    setState(() {
      _isTracking = false;
      _status = 'GPS Inactif';
    });
    debugPrint('⏸️ Suivi GPS arrêté');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône GPS
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isTracking 
                    ? const Color(0xFF9C27B0).withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTracking ? Icons.gps_fixed : Icons.gps_off,
                size: 40,
                color: _isTracking ? const Color(0xFF9C27B0) : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            const Text(
              'Suivi GPS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'Activez le suivi GPS pour partager votre position en temps réel avec l\'équipe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isTracking ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _status,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Position actuelle
            if (_currentPosition != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Message d'erreur
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF00D4FF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '💡 Le suivi fonctionne en arrière-plan même quand l\'app est minimisée',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTracking ? _stopTracking : _startTracking,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isTracking 
                          ? Colors.grey[700]
                          : const Color(0xFF9C27B0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isTracking ? 'Arrêter' : 'Activer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
