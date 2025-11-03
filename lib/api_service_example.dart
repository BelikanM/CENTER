import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String _message = '';
  String? _accessToken;

  // ========================================
  // AUTHENTIFICATION
  // ========================================

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _message = 'Veuillez remplir tous les champs');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        'Utilisateur', // Nom par défaut pour l'exemple
      );

      setState(() {
        _message = result['message'] ?? 'Inscription réussie ! Vérifiez votre email.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty) {
      setState(() => _message = 'Veuillez saisir votre email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(_emailController.text.trim());

      setState(() {
        _message = result['message'] ?? 'OTP envoyé !';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_emailController.text.isEmpty || _otpController.text.isEmpty) {
      setState(() => _message = 'Veuillez saisir email et OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.verifyOtp(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );

      setState(() {
        _accessToken = result['accessToken'];
        _message = 'Connexion réussie !';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  // ========================================
  // PUBLICATIONS
  // ========================================

  Future<void> _loadPublications() async {
    if (_accessToken == null) {
      setState(() => _message = 'Veuillez vous connecter d\'abord');
      return;
    }

    try {
      final result = await ApiService.getPublications(_accessToken!);
      final publications = result['publications'] as List;

      setState(() => _message = '${publications.length} publications chargées');
    } catch (e) {
      setState(() => _message = 'Erreur: $e');
    }
  }

  // ========================================
  // MARQUEURS
  // ========================================

  Future<void> _loadMarkers() async {
    if (_accessToken == null) {
      setState(() => _message = 'Veuillez vous connecter d\'abord');
      return;
    }

    try {
      final result = await ApiService.getMarkers(_accessToken!);
      final markers = result['markers'] as List;

      setState(() => _message = '${markers.length} marqueurs chargés');
    } catch (e) {
      setState(() => _message = 'Erreur: $e');
    }
  }

  // ========================================
  // GESTION DES EMPLOYÉS (ADMIN)
  // ========================================

  Future<void> _loadEmployees() async {
    if (_accessToken == null) {
      setState(() => _message = 'Veuillez vous connecter d\'abord');
      return;
    }

    try {
      final result = await ApiService.getEmployees(_accessToken!);
      final employees = result['employees'] as List;

      setState(() => _message = '${employees.length} employés chargés');
    } catch (e) {
      setState(() => _message = 'Erreur: $e');
    }
  }

  // ========================================
  // GESTION DES UTILISATEURS (ADMIN)
  // ========================================

  Future<void> _loadUsers() async {
    if (_accessToken == null) {
      setState(() => _message = 'Veuillez vous connecter d\'abord');
      return;
    }

    try {
      final result = await ApiService.getUsers(_accessToken!);
      final users = result['users'] as List;

      setState(() => _message = '${users.length} utilisateurs chargés');
    } catch (e) {
      setState(() => _message = 'Erreur: $e');
    }
  }

  // ========================================
  // INFORMATIONS SERVEUR
  // ========================================

  Future<void> _getServerInfo() async {
    try {
      final result = await ApiService.getServerInfo();

      setState(() {
        _message = 'Serveur: ${result['baseUrl']} (IP: ${result['serverIp']})';
      });
    } catch (e) {
      setState(() => _message = 'Erreur serveur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Dynamique - Authentification'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _getServerInfo,
            tooltip: 'Info serveur',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champs de saisie
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),

            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Code OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),

            // Boutons d'action
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _register,
                              child: Text('S\'inscrire'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _login,
                              child: Text('Se connecter'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                        ),
                        child: Text('Vérifier OTP'),
                      ),
                    ],
                  ),

            SizedBox(height: 24),

            // Actions supplémentaires (nécessitent une connexion)
            if (_accessToken != null) ...[
              Text(
                'Actions disponibles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _loadPublications,
                    child: Text('Publications'),
                  ),
                  ElevatedButton(
                    onPressed: _loadMarkers,
                    child: Text('Marqueurs'),
                  ),
                  ElevatedButton(
                    onPressed: _loadEmployees,
                    child: Text('Employés'),
                  ),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: Text('Utilisateurs'),
                  ),
                ],
              ),
            ],

            SizedBox(height: 24),

            // Message de statut
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _message,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            // Token info
            if (_accessToken != null) ...[
              SizedBox(height: 16),
              Text(
                '✅ Connecté',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}

///
/// EXEMPLE D'UTILISATION AVANCÉE
///
/// Voici comment intégrer le service dans un Provider ou un BLoC
///

class ApiProvider extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;

  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _accessToken != null;

  // Authentification
  Future<bool> login(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.verifyOtp(email, otp);
      _accessToken = result['accessToken'];
      _refreshToken = result['refreshToken'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  void logout() {
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  // Rafraîchir le token
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final result = await ApiService.refreshToken(_refreshToken!);
      _accessToken = result['accessToken'];
      notifyListeners();
      return true;
    } catch (e) {
      logout();
      return false;
    }
  }

  // Wrapper pour les appels API avec gestion automatique des tokens
  Future<T> _authenticatedCall<T>(Future<T> Function(String token) apiCall) async {
    if (!isAuthenticated) {
      throw Exception('Non authentifié');
    }

    try {
      return await apiCall(_accessToken!);
    } catch (e) {
      // Si erreur 403 (token expiré), essayer de rafraîchir
      if (e.toString().contains('403') || e.toString().contains('expiré')) {
        if (await refreshToken()) {
          return await apiCall(_accessToken!);
        }
      }
      rethrow;
    }
  }

  // Exemples d'utilisation
  Future<List<dynamic>> getPublications() async {
    return await _authenticatedCall((token) async {
      final result = await ApiService.getPublications(token);
      return result['publications'];
    });
  }

  Future<void> createPublication(String content) async {
    return await _authenticatedCall((token) async {
      await ApiService.createPublication(token, content: content);
    });
  }
}
