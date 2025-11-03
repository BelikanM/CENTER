import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;

///
/// SERVICE API DYNAMIQUE POUR FLUTTER
///
/// Ce service s'adapte automatiquement à n'importe quelle adresse IP réseau.
/// Il détecte automatiquement l'adresse IP du serveur backend au premier appel.
///
/// UTILISATION :
/// 1. Appelez n'importe quelle méthode API - l'initialisation se fait automatiquement
/// 2. Le service scanne d'abord l'adresse par défaut, puis le réseau local si nécessaire
/// 3. Toutes les URLs sont mises à jour dynamiquement
///
/// EXEMPLE :
/// ```dart
/// // Première utilisation - détection automatique
/// final result = await ApiService.login('email@example.com');
///
/// // Toutes les autres méthodes utilisent automatiquement l'IP détectée
/// final publications = await ApiService.getPublications(token);
/// ```
///
class ApiService {
  // Configuration dynamique
  static String? _dynamicBaseUrl;
  static bool _isInitialized = false;

  // URL de base par défaut (pour la première connexion)
  static const String _defaultBaseUrl = 'http://192.168.1.98:5000'; // Adresse par défaut pour l'initialisation
  static const String apiPrefix = '/api';

  // Getter pour l'URL de base (dynamique ou par défaut)
  static String get baseUrl => _dynamicBaseUrl ?? _defaultBaseUrl;

  // Headers par défaut
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers avec token d'authentification
  static Map<String, String> _authHeaders(String token) => {
    ..._defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  // ========================================
  // INITIALISATION DYNAMIQUE
  // ========================================

  // Initialiser l'API avec l'adresse IP détectée automatiquement
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
    developer.log('🔄 Initialisation de l\'API - Détection automatique de l\'IP...', name: 'ApiService');

      // Essayer d'abord avec l'adresse par défaut
      final serverInfo = await _getServerInfo(_defaultBaseUrl);

      if (serverInfo != null) {
        _dynamicBaseUrl = serverInfo['baseUrl'];
        _isInitialized = true;
        developer.log('✅ API initialisée avec l\'IP: $_dynamicBaseUrl', name: 'ApiService');
        return;
      }
    } catch (e) {
      developer.log('⚠️ Impossible de contacter le serveur par défaut: $e', name: 'ApiService');
    }

    // Si l'adresse par défaut ne fonctionne pas, essayer de scanner le réseau local
    try {
      final detectedUrl = await _scanLocalNetwork();
      if (detectedUrl != null) {
        _dynamicBaseUrl = detectedUrl;
        _isInitialized = true;
        developer.log('✅ API initialisée avec l\'IP détectée: $_dynamicBaseUrl', name: 'ApiService');
        return;
      }
    } catch (e) {
      developer.log('⚠️ Échec du scan réseau: $e', name: 'ApiService');
    }

    // En dernier recours, garder l'adresse par défaut
    developer.log('⚠️ Utilisation de l\'adresse par défaut: $_defaultBaseUrl', name: 'ApiService');
    _dynamicBaseUrl = _defaultBaseUrl;
    _isInitialized = true;
  }

  // Scanner le réseau local pour trouver le serveur
  static Future<String?> _scanLocalNetwork() async {
    // Adresses IP communes à tester (réseau local typique)
    final commonIPs = [
      '192.168.1.1', '192.168.1.100', '192.168.1.101', '192.168.1.102',
      '192.168.1.103', '192.168.1.104', '192.168.1.105', '192.168.1.106',
      '192.168.0.1', '192.168.0.100', '192.168.0.101', '192.168.0.102',
      '10.0.0.1', '10.0.0.100', '10.0.0.101', '10.0.0.102',
      '172.16.0.1', '172.16.0.100', '172.16.0.101', '172.16.0.102',
    ];

    for (final ip in commonIPs) {
      try {
        final testUrl = 'http://$ip:5000';
        final serverInfo = await _getServerInfo(testUrl);
        if (serverInfo != null) {
          return serverInfo['baseUrl'];
        }
      } catch (e) {
        // Continuer avec l'IP suivante
        continue;
      }
    }

    return null;
  }

  // Récupérer les informations du serveur (méthode privée)
  static Future<Map<String, dynamic>?> _getServerInfo(String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/server-info'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // Timeout ou erreur de connexion
    }
    return null;
  }

  // Forcer la réinitialisation (utile pour les tests ou changement de réseau)
  static void reset() {
    _dynamicBaseUrl = null;
    _isInitialized = false;
  }

  // ========================================
  // AUTHENTIFICATION
  // ========================================

  // Inscription
  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    await _ensureInitialized();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/auth/register'),
        headers: _defaultHeaders,
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Connexion (envoi OTP)
  static Future<Map<String, dynamic>> login(String email) async {
    await _ensureInitialized();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/auth/login'),
        headers: _defaultHeaders,
        body: json.encode({'email': email}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Vérification OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    await _ensureInitialized();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/auth/verify-otp'),
        headers: _defaultHeaders,
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'OTP invalide');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Rafraîchir le token
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/auth/refresh-token'),
        headers: _defaultHeaders,
        body: json.encode({'refreshToken': refreshToken}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de rafraîchissement');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========================================
  // PROFIL UTILISATEUR
  // ========================================

  // Mettre à jour le nom
  static Future<Map<String, dynamic>> updateUserName(String token, String name) async {
    await initialize();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$apiPrefix/user/update-name'),
        headers: _authHeaders(token),
        body: json.encode({'name': name}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Changer le mot de passe
  static Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$apiPrefix/user/change-password'),
        headers: _authHeaders(token),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de changement de mot de passe');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Upload photo de profil
  static Future<Map<String, dynamic>> uploadProfileImage(String token, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$apiPrefix/user/upload-profile-image'),
      );

      request.headers.addAll(_authHeaders(token));
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imageFile.path,
          filename: path.basename(imageFile.path),
          contentType: MediaType('image', path.extension(imageFile.path).substring(1)),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur d\'upload');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer photo de profil
  static Future<Map<String, dynamic>> deleteProfileImage(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/user/delete-profile-image'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer compte
  static Future<Map<String, dynamic>> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/user/delete-account'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========================================
  // PUBLICATIONS
  // ========================================

  // Créer une publication
  static Future<Map<String, dynamic>> createPublication(
    String token, {
    required String content,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    String? placeName,
    List<String>? tags,
    String? category,
    String? visibility,
    List<File>? mediaFiles,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$apiPrefix/publications'),
      );

      request.headers.addAll(_authHeaders(token));

      // Champs texte
      request.fields['content'] = content;
      if (type != null) request.fields['type'] = type;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();
      if (address != null) request.fields['address'] = address;
      if (placeName != null) request.fields['placeName'] = placeName;
      if (tags != null && tags.isNotEmpty) request.fields['tags'] = tags.join(',');
      if (category != null) request.fields['category'] = category;
      if (visibility != null) request.fields['visibility'] = visibility;

      // Fichiers média
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (var i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          request.files.add(
            await http.MultipartFile.fromPath(
              'media',
              file.path,
              filename: path.basename(file.path),
              contentType: _getMediaType(file.path),
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de création');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les publications
  static Future<Map<String, dynamic>> getPublications(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/publications?page=$page&limit=$limit'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de récupération');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les publications d'un utilisateur
  static Future<Map<String, dynamic>> getUserPublications(String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/publications/user/$userId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de récupération');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer une publication par ID
  static Future<Map<String, dynamic>> getPublication(String token, String publicationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/publications/$publicationId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Publication non trouvée');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour une publication
  static Future<Map<String, dynamic>> updatePublication(
    String token,
    String publicationId, {
    String? content,
    double? latitude,
    double? longitude,
    String? address,
    String? placeName,
    List<String>? tags,
    String? category,
    String? visibility,
    List<File>? mediaFiles,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl$apiPrefix/publications/$publicationId'),
      );

      request.headers.addAll(_authHeaders(token));

      if (content != null) request.fields['content'] = content;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();
      if (address != null) request.fields['address'] = address;
      if (placeName != null) request.fields['placeName'] = placeName;
      if (tags != null && tags.isNotEmpty) request.fields['tags'] = tags.join(',');
      if (category != null) request.fields['category'] = category;
      if (visibility != null) request.fields['visibility'] = visibility;

      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (var file in mediaFiles) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'media',
              file.path,
              filename: path.basename(file.path),
              contentType: _getMediaType(file.path),
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer une publication
  static Future<Map<String, dynamic>> deletePublication(String token, String publicationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/publications/$publicationId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Liker/Disliker une publication
  static Future<Map<String, dynamic>> toggleLike(String token, String publicationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/publications/$publicationId/like'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de like');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les commentaires d'une publication
  static Future<Map<String, dynamic>> getPublicationComments(String token, String publicationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/publications/$publicationId/comments'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de récupération');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Ajouter un commentaire
  static Future<Map<String, dynamic>> addComment(String token, String publicationId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiPrefix/publications/$publicationId/comments'),
        headers: _authHeaders(token),
        body: json.encode({'content': content}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur d\'ajout de commentaire');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer un média d'une publication
  static Future<Map<String, dynamic>> deletePublicationMedia(
    String token,
    String publicationId,
    int mediaIndex,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/publications/$publicationId/media/$mediaIndex'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========================================
  // MARQUEURS
  // ========================================

  // Créer un marqueur
  static Future<Map<String, dynamic>> createMarker(
    String token, {
    required double latitude,
    required double longitude,
    required String title,
    String? comment,
    String? color,
    List<File>? photos,
    List<File>? videos,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$apiPrefix/markers'),
      );

      request.headers.addAll(_authHeaders(token));

      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['title'] = title;
      if (comment != null) request.fields['comment'] = comment;
      if (color != null) request.fields['color'] = color;

      // Photos
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'photos',
              photo.path,
              filename: path.basename(photo.path),
              contentType: MediaType('image', path.extension(photo.path).substring(1)),
            ),
          );
        }
      }

      // Vidéos
      if (videos != null && videos.isNotEmpty) {
        for (var video in videos) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'videos',
              video.path,
              filename: path.basename(video.path),
              contentType: MediaType('video', path.extension(video.path).substring(1)),
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de création');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer tous les marqueurs
  static Future<Map<String, dynamic>> getMarkers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/markers'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de récupération');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les marqueurs d'un utilisateur
  static Future<Map<String, dynamic>> getUserMarkers(String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/markers/user/$userId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de récupération');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer un marqueur par ID
  static Future<Map<String, dynamic>> getMarker(String token, String markerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/markers/$markerId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Marqueur non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour un marqueur
  static Future<Map<String, dynamic>> updateMarker(
    String token,
    String markerId, {
    String? title,
    String? comment,
    String? color,
    List<File>? photos,
    List<File>? videos,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl$apiPrefix/markers/$markerId'),
      );

      request.headers.addAll(_authHeaders(token));

      if (title != null) request.fields['title'] = title;
      if (comment != null) request.fields['comment'] = comment;
      if (color != null) request.fields['color'] = color;

      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'photos',
              photo.path,
              filename: path.basename(photo.path),
              contentType: MediaType('image', path.extension(photo.path).substring(1)),
            ),
          );
        }
      }

      if (videos != null && videos.isNotEmpty) {
        for (var video in videos) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'videos',
              video.path,
              filename: path.basename(video.path),
              contentType: MediaType('video', path.extension(video.path).substring(1)),
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer un marqueur
  static Future<Map<String, dynamic>> deleteMarker(String token, String markerId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/markers/$markerId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer un média d'un marqueur
  static Future<Map<String, dynamic>> deleteMarkerMedia(
    String token,
    String markerId,
    String type,
    int index,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/markers/$markerId/media/$type/$index'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========================================
  // GESTION DES EMPLOYÉS (ADMIN)
  // ========================================

  // Lister les employés
  static Future<Map<String, dynamic>> getEmployees(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/employees'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de récupération');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Créer un employé
  static Future<Map<String, dynamic>> createEmployee(
    String token, {
    required String name,
    required String email,
    required String phone,
    File? faceImage,
    File? certificate,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? certificateStartDate,
    DateTime? certificateEndDate,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$apiPrefix/employees'),
      );

      request.headers.addAll(_authHeaders(token));

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;

      if (startDate != null) request.fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) request.fields['endDate'] = endDate.toIso8601String();
      if (certificateStartDate != null) request.fields['certificateStartDate'] = certificateStartDate.toIso8601String();
      if (certificateEndDate != null) request.fields['certificateEndDate'] = certificateEndDate.toIso8601String();

      if (faceImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'faceImage',
            faceImage.path,
            filename: path.basename(faceImage.path),
            contentType: MediaType('image', path.extension(faceImage.path).substring(1)),
          ),
        );
      }

      if (certificate != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'certificate',
            certificate.path,
            filename: path.basename(certificate.path),
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de création');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour un employé
  static Future<Map<String, dynamic>> updateEmployee(
    String token,
    String employeeId, {
    String? name,
    String? email,
    String? phone,
    File? faceImage,
    File? certificate,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? certificateStartDate,
    DateTime? certificateEndDate,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl$apiPrefix/employees/$employeeId'),
      );

      request.headers.addAll(_authHeaders(token));

      if (name != null) request.fields['name'] = name;
      if (email != null) request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (startDate != null) request.fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) request.fields['endDate'] = endDate.toIso8601String();
      if (certificateStartDate != null) request.fields['certificateStartDate'] = certificateStartDate.toIso8601String();
      if (certificateEndDate != null) request.fields['certificateEndDate'] = certificateEndDate.toIso8601String();

      if (faceImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'faceImage',
            faceImage.path,
            filename: path.basename(faceImage.path),
            contentType: MediaType('image', path.extension(faceImage.path).substring(1)),
          ),
        );
      }

      if (certificate != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'certificate',
            certificate.path,
            filename: path.basename(certificate.path),
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer un employé
  static Future<Map<String, dynamic>> deleteEmployee(String token, String employeeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/employees/$employeeId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========================================
  // GESTION DES UTILISATEURS (ADMIN)
  // ========================================

  // Lister les utilisateurs
  static Future<Map<String, dynamic>> getUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/users'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de récupération');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Changer le statut d'un utilisateur
  static Future<Map<String, dynamic>> updateUserStatus(
    String token,
    String userId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$apiPrefix/users/$userId/status'),
        headers: _authHeaders(token),
        body: json.encode({'status': status}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer un utilisateur
  static Future<Map<String, dynamic>> deleteUser(String token, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$apiPrefix/users/$userId'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========================================
  // MÉTHODES UTILITAIRES PRIVÉES
  // ========================================

  // Méthode helper pour s'assurer que l'API est initialisée
  static Future<void> _ensureInitialized() async {
    await initialize();
  }

  // Obtenir les informations du serveur (utilise l'URL dynamique)
  static Future<Map<String, dynamic>> getServerInfo() async {
    await _ensureInitialized();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiPrefix/server-info'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Déterminer le type MIME d'un fichier média
  static MediaType _getMediaType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      case '.mp4':
        return MediaType('video', 'mp4');
      case '.avi':
        return MediaType('video', 'avi');
      case '.mov':
        return MediaType('video', 'mov');
      case '.wmv':
        return MediaType('video', 'wmv');
      case '.flv':
        return MediaType('video', 'flv');
      case '.webm':
        return MediaType('video', 'webm');
      case '.mkv':
        return MediaType('video', 'mkv');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
