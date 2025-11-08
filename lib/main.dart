import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pages/main_page.dart';
import 'api_service.dart';

// Data Models
class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  String status; // 'active', 'inactive', 'banned'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'status': status,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    avatar: json['avatar'],
    status: json['status'] ?? 'active',
  );
}

class Employee {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String position;
  final String department;
  String status; // 'active', 'on_leave', 'terminated'

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.position,
    required this.department,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'position': position,
    'department': department,
    'status': status,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    avatar: json['avatar'],
    position: json['position'],
    department: json['department'],
    status: json['status'] ?? 'active',
  );
}

class Post {
  final String id;
  final String userId;
  final String content;
  final String imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.comments,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'content': content,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
    'likes': likes,
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    userId: json['userId'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    createdAt: DateTime.parse(json['createdAt']),
    likes: List<String>.from(json['likes']),
    comments: (json['comments'] as List).map((c) => Comment.fromJson(c)).toList(),
  );
}

class Comment {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    userId: json['userId'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Forcer l'utilisation de l'adresse par défaut (192.168.1.66:5000)
  // Évite les problèmes de détection automatique
  ApiService.useDefaultUrl();
  
  runApp(const CenterApp());
}

class CenterApp extends StatelessWidget {
  const CenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Center - Personnel & Social',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const MainPage(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF00FF88), // Bright green
        secondary: Color(0xFF00CC66), // Medium green
        tertiary: Color(0xFF009944), // Dark green
        surface: Colors.white,
        onSurface: Colors.black,
        outline: Color(0xFF00FF88), // Green borders
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FF88), // Bright green
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: const Color(0xFF00FF88).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFF00FF88),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF00FF88),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00FF88),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00FF88),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00FF88),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF00FF88),
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF00FF88),
        unselectedItemColor: Colors.black54,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isAuthenticated = false;
  String? _accessToken;
  Map<String, dynamic>? _currentUser;

  // Mock data
  final List<User> _users = [
    User(
      id: '1',
      name: 'Alice Dupont',
      email: 'alice@example.com',
      avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      status: 'active',
    ),
    User(
      id: '2',
      name: 'Bob Martin',
      email: 'bob@example.com',
      avatar: 'https://randomuser.me/api/portraits/men/2.jpg',
      status: 'active',
    ),
    User(
      id: '3',
      name: 'nyundumathryme@gmail.com',
      email: 'nyundumathryme@gmail.com',
      avatar: 'https://randomuser.me/api/portraits/men/3.jpg',
      status: 'active',
    ),
  ];

  final List<Employee> _employees = [
    Employee(
      id: '1',
      name: 'Alice Dupont',
      email: 'alice@example.com',
      avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      position: 'Développeur Senior',
      department: 'IT',
      status: 'active',
    ),
    Employee(
      id: '2',
      name: 'Bob Martin',
      email: 'bob@example.com',
      avatar: 'https://randomuser.me/api/portraits/men/2.jpg',
      position: 'Designer UX',
      department: 'Design',
      status: 'active',
    ),
  ];

  final List<Post> _posts = [
    Post(
      id: '1',
      userId: '1',
      content: 'Bienvenue sur Center !',
      imageUrl: '',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: ['2'],
      comments: [],
    ),
  ];

  int get currentIndex => _currentIndex;
  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  List<User> get users => _users;
  List<Employee> get employees => _employees;
  List<Post> get posts => _posts;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setAuthenticated(bool authenticated, {String? token, Map<String, dynamic>? user}) {
    _isAuthenticated = authenticated;
    _accessToken = token;
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _accessToken = null;
    _currentUser = null;
    _currentIndex = 0;
    notifyListeners();
  }

  // User management methods
  void updateUserStatus(String userId, String status) {
    final user = _users.firstWhere((u) => u.id == userId);
    user.status = status;
    notifyListeners();
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  // Employee management methods
  void updateEmployeeStatus(String employeeId, String status) {
    final employee = _employees.firstWhere((e) => e.id == employeeId);
    employee.status = status;
    notifyListeners();
  }

  void deleteEmployee(String employeeId) {
    _employees.removeWhere((e) => e.id == employeeId);
    notifyListeners();
  }
}
