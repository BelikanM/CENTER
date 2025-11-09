// Script de test de connexion
const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';
const TEST_EMAIL = 'nyundumathryme@gmail.com';
const TEST_PASSWORD = 'admin123';

// Couleurs pour le terminal
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// Test 1: Vérifier que le serveur répond
async function testServerInfo() {
  try {
    log('\n📋 TEST 1: Vérification des informations serveur...', 'blue');
    const response = await axios.get(`${BASE_URL}/server-info`);
    
    log(`✅ Serveur accessible`, 'green');
    log(`   IP: ${response.data.serverIp}`, 'reset');
    log(`   Base URL: ${response.data.baseUrl}`, 'reset');
    log(`   Port: ${response.data.port}`, 'reset');
    return true;
  } catch (error) {
    log(`❌ Erreur: ${error.message}`, 'red');
    if (error.response) {
      console.log('Réponse:', error.response.data);
    }
    return false;
  }
}

// Test 2: Tester le login (première étape - envoi OTP)
async function testLogin() {
  try {
    log('\n🔐 TEST 2: Envoi de la requête de login...', 'blue');
    const response = await axios.post(`${BASE_URL}/auth/login`, {
      email: TEST_EMAIL,
      password: TEST_PASSWORD
    });
    
    log(`✅ Login réussi - Statut: ${response.status}`, 'green');
    log(`   Message: ${response.data.message}`, 'reset');
    console.log('   Données reçues:', JSON.stringify(response.data, null, 2));
    return response.data;
  } catch (error) {
    log(`❌ Erreur de login: ${error.message}`, 'red');
    if (error.response) {
      console.log('   Statut:', error.response.status);
      console.log('   Réponse:', error.response.data);
    }
    return null;
  }
}

// Test 3: Tester admin-login (connexion directe pour tests)
async function testAdminLogin() {
  try {
    log('\n🔑 TEST 3: Connexion admin directe (pour tests)...', 'blue');
    const response = await axios.post(`${BASE_URL}/auth/admin-login`, {
      email: TEST_EMAIL,
      password: TEST_PASSWORD
    });
    
    log(`✅ Admin login réussi - Statut: ${response.status}`, 'green');
    log(`   Message: ${response.data.message}`, 'reset');
    log(`   Access Token: ${response.data.accessToken ? response.data.accessToken.substring(0, 30) + '...' : 'NON REÇU'}`, 'reset');
    log(`   Refresh Token: ${response.data.refreshToken ? response.data.refreshToken.substring(0, 30) + '...' : 'NON REÇU'}`, 'reset');
    
    if (response.data.user) {
      log(`   Utilisateur:`, 'reset');
      log(`      - Email: ${response.data.user.email}`, 'reset');
      log(`      - Nom: ${response.data.user.name}`, 'reset');
      log(`      - Statut: ${response.data.user.status}`, 'reset');
    }
    
    return response.data;
  } catch (error) {
    log(`❌ Erreur admin login: ${error.message}`, 'red');
    if (error.response) {
      console.log('   Statut:', error.response.status);
      console.log('   Réponse:', error.response.data);
    }
    return null;
  }
}

// Test 4: Tester la récupération des employés avec le token
async function testGetEmployees(token) {
  try {
    log('\n👥 TEST 4: Récupération des employés...', 'blue');
    const response = await axios.get(`${BASE_URL}/employees`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    log(`✅ Employés récupérés - Statut: ${response.status}`, 'green');
    log(`   Nombre d'employés: ${response.data.employees?.length || 0}`, 'reset');
    
    if (response.data.employees && response.data.employees.length > 0) {
      log(`   Premier employé:`, 'reset');
      const emp = response.data.employees[0];
      log(`      - Nom: ${emp.name}`, 'reset');
      log(`      - Email: ${emp.email}`, 'reset');
      log(`      - Département: ${emp.department || 'Non défini'}`, 'reset');
    }
    
    return true;
  } catch (error) {
    log(`❌ Erreur de récupération: ${error.message}`, 'red');
    if (error.response) {
      console.log('   Statut:', error.response.status);
      console.log('   Réponse:', error.response.data);
    }
    return false;
  }
}

// Exécuter tous les tests
async function runTests() {
  log('\n============================================================', 'blue');
  log('🧪 TESTS DE CONNEXION ET RÉCUPÉRATION', 'blue');
  log('============================================================', 'blue');
  
  let passed = 0;
  let failed = 0;
  
  // Test 1
  if (await testServerInfo()) {
    passed++;
  } else {
    failed++;
    log('\n⚠️  Le serveur ne répond pas. Arrêt des tests.', 'yellow');
    return;
  }
  
  // Test 2
  const loginResult = await testLogin();
  if (loginResult) {
    passed++;
  } else {
    failed++;
  }
  
  // Test 3
  const adminLoginResult = await testAdminLogin();
  if (adminLoginResult && adminLoginResult.accessToken) {
    passed++;
    
    // Test 4 - Utiliser le token obtenu
    if (await testGetEmployees(adminLoginResult.accessToken)) {
      passed++;
    } else {
      failed++;
    }
  } else {
    failed++;
    log('\n⚠️  Impossible d\'obtenir le token. Arrêt des tests.', 'yellow');
  }
  
  // Résumé
  log('\n============================================================', 'blue');
  log('📊 RÉSULTATS DES TESTS', 'blue');
  log('============================================================', 'blue');
  log(`✅ Tests réussis: ${passed}/${passed + failed}`, passed === passed + failed ? 'green' : 'yellow');
  log(`❌ Tests échoués: ${failed}/${passed + failed}`, failed > 0 ? 'red' : 'green');
  log('============================================================\n', 'blue');
  
  if (failed === 0) {
    log('🎉 TOUS LES TESTS SONT PASSÉS !', 'green');
  } else {
    log('⚠️  CERTAINS TESTS ONT ÉCHOUÉ', 'yellow');
  }
}

// Lancer les tests
runTests().catch(err => {
  log(`\n❌ Erreur fatale: ${err.message}`, 'red');
  console.error(err);
});
