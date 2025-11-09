import 'package:flutter/material.dart';
import '../api_service.dart';
import 'employees/employee_detail_page.dart';

class GeolocationStatsPage extends StatefulWidget {
  final String token;
  final int totalWithLocation;

  const GeolocationStatsPage({
    super.key,
    required this.token,
    required this.totalWithLocation,
  });

  @override
  State<GeolocationStatsPage> createState() => _GeolocationStatsPageState();
}

class _GeolocationStatsPageState extends State<GeolocationStatsPage> {
  List<dynamic> _locations = [];
  bool _isLoading = true;
  String _viewMode = 'list'; // 'list' or 'map'

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final data = await ApiService().getGeolocationData(widget.token);
      setState(() {
        _locations = data['locations'] ?? [];
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
          'Géolocalisation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == 'list' ? Icons.map_rounded : Icons.list_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'list' ? 'map' : 'list';
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
            )
          : Column(
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
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
                          Icons.location_on_rounded,
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
                              _locations.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Employés géolocalisés',
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

                // Contenu
                Expanded(
                  child: _viewMode == 'list'
                      ? _buildListView()
                      : _buildMapView(),
                ),
              ],
            ),
    );
  }

  Widget _buildListView() {
    if (_locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée de géolocalisation',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations[index];
        return _buildLocationItem(location);
      },
    );
  }

  Widget _buildMapView() {
    // Vue carte simple avec liste de coordonnées
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Simulateur de carte
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF9C27B0).withValues(alpha: 0.3),
                  const Color(0xFF7B1FA2).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_locations.length} positions actives',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Liste des positions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                final loc = location['location'] ?? {};
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9C27B0),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location['name'] ?? 'Non défini',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${loc['latitude']?.toStringAsFixed(6) ?? '0'}, ${loc['longitude']?.toStringAsFixed(6) ?? '0'}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.my_location,
                        color: const Color(0xFF9C27B0).withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> locationData) {
    final location = locationData['location'] ?? {};
    final address = location['address'] ?? 'Adresse non disponible';
    final lat = location['latitude'] ?? 0.0;
    final lng = location['longitude'] ?? 0.0;
    final status = locationData['status'] ?? 'offline';
    
    Color statusColor = Colors.grey;
    if (status == 'online') statusColor = Colors.green;
    if (status == 'away') statusColor = Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailPage(
              employee: {
                '_id': locationData['id'],
                'firstName': locationData['name']?.split(' ')[0] ?? '',
                'lastName': locationData['name']?.split(' ').skip(1).join(' ') ?? '',
                'department': locationData['department'],
                'role': locationData['role'],
                'faceImage': locationData['image'],
                'status': status,
                'location': location,
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
            color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                    backgroundImage: locationData['image'] != null && locationData['image'].isNotEmpty
                        ? NetworkImage(locationData['image'])
                        : null,
                    child: locationData['image'] == null || locationData['image'].isEmpty
                        ? Text(
                            locationData['name']?[0]?.toUpperCase() ?? 'E',
                            style: const TextStyle(
                              color: Color(0xFF9C27B0),
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
                locationData['name'] ?? 'Non défini',
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
                    locationData['department'] ?? 'Non défini',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
            ),
            
            // Informations de localisation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Lat: ${lat.toStringAsFixed(6)} | Lng: ${lng.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
