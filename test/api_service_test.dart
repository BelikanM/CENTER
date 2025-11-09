// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:center/api_service.dart';

void main() {
  group('API Service Tests', () {
    test('Test 1: Initialize API', () async {
      print('\n🔄 TEST 1: Initialisation de l\'API...');
      try {
        await ApiService.initialize();
        print('✅ API initialisée avec succès');
        print('   Base URL: ${ApiService.baseUrl}');
      } catch (e) {
        print('❌ Erreur d\'initialisation: $e');
        fail('Initialisation échouée: $e');
      }
    });

    test('Test 2: Get Server Info', () async {
      print('\n📋 TEST 2: Récupération des infos serveur...');
      try {
        final serverInfo = await ApiService.getServerInfo();
        print('✅ Infos serveur récupérées');
        print('   Server IP: ${serverInfo['serverIp']}');
        print('   Base URL: ${serverInfo['baseUrl']}');
        print('   Port: ${serverInfo['port']}');
      } catch (e) {
        print('❌ Erreur: $e');
        fail('Récupération des infos échouée: $e');
      }
    });

    test('Test 3: Admin Login', () async {
      print('\n🔐 TEST 3: Connexion admin...');
      try {
        final result = await ApiService.adminLogin(
          'nyundumathryme@gmail.com',
          'admin123',
        );
        
        expect(result.containsKey('accessToken'), true, reason: 'accessToken doit être présent');
        expect(result['accessToken'], isNotNull, reason: 'accessToken ne doit pas être null');
        
        print('✅ Connexion réussie');
        print('   Access Token: ${result['accessToken']?.substring(0, 30)}...');
        print('   User: ${result['user']?['email']}');
        
        // Sauvegarder le token pour les tests suivants
        _testToken = result['accessToken'];
      } catch (e) {
        print('❌ Erreur de connexion: $e');
        fail('Connexion échouée: $e');
      }
    });

    test('Test 4: Get Employees', () async {
      print('\n👥 TEST 4: Récupération des employés...');
      
      if (_testToken == null) {
        print('⚠️  Connexion d\'abord...');
        final loginResult = await ApiService.adminLogin(
          'nyundumathryme@gmail.com',
          'admin123',
        );
        _testToken = loginResult['accessToken'];
      }
      
      try {
        final result = await ApiService.getEmployees(_testToken!);
        
        print('✅ Employés récupérés');
        print('   Success: ${result['success']}');
        print('   Nombre: ${result['employees']?.length ?? 0}');
        
        if (result['employees'] != null && result['employees'].isNotEmpty) {
          final firstEmployee = result['employees'][0];
          print('   Premier employé:');
          print('      - Nom: ${firstEmployee['name']}');
          print('      - Email: ${firstEmployee['email']}');
        }
      } catch (e) {
        print('❌ Erreur de récupération: $e');
        fail('Récupération des employés échouée: $e');
      }
    });
  });
}

String? _testToken;
