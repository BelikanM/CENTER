// Script de test des routes Employee
const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'http://localhost:5000/api';
let TOKEN = '';
let EMPLOYEE_ID = '';

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

// 1. Connexion (obtenir le token)
async function login() {
  try {
    log('\n🔐 TEST 1: Connexion...', 'blue');
    
    // Étape 1: Demander l'OTP
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'nyundumathryme@gmail.com',
      password: 'admin123'
    });
    log('📧 OTP envoyé par email', 'yellow');
    
    // Pour les tests, on utilise un utilisateur admin qui peut avoir un OTP fixe
    // Ou on peut créer une route de test qui retourne directement un token
    // Pour simplifier, testons avec un token admin existant
    log('⚠️  Pour les tests automatiques, utilisons une route alternative', 'yellow');
    
    // Alternative: utiliser une route de login direct pour les tests
    const testLoginResponse = await axios.post(`${BASE_URL}/auth/admin-login`, {
      email: 'nyundumathryme@gmail.com',
      password: 'admin123'
    });
    
    TOKEN = testLoginResponse.data.accessToken;
    log(`✅ Connexion réussie - Token obtenu`, 'green');
    return true;
  } catch (error) {
    log(`❌ Erreur de connexion: ${error.response?.data?.message || error.message}`, 'red');
    console.error('Détails:', error.response?.data || error.message);
    return false;
  }
}

// 2. Lister les employés (GET)
async function getEmployees() {
  try {
    log('\n📋 TEST 2: Récupération des employés...', 'blue');
    const response = await axios.get(`${BASE_URL}/employees`, {
      headers: { Authorization: `Bearer ${TOKEN}` }
    });
    
    log(`✅ ${response.data.employees?.length || 0} employé(s) trouvé(s)`, 'green');
    if (response.data.employees?.length > 0) {
      log(`   Premier employé: ${response.data.employees[0].name}`, 'yellow');
    }
    return true;
  } catch (error) {
    log(`❌ Erreur: ${error.response?.data?.message || error.message}`, 'red');
    return false;
  }
}

// 3. Créer un employé (POST)
async function createEmployee() {
  try {
    log('\n➕ TEST 3: Création d\'un employé...', 'blue');
    
    const formData = new FormData();
    formData.append('name', 'Jean Dupont TEST');
    formData.append('email', `test${Date.now()}@example.com`);
    formData.append('phone', '+243 999 999 999');
    
    const response = await axios.post(`${BASE_URL}/employees`, formData, {
      headers: {
        Authorization: `Bearer ${TOKEN}`,
        ...formData.getHeaders()
      }
    });
    
    EMPLOYEE_ID = response.data.employee._id;
    log(`✅ Employé créé avec succès - ID: ${EMPLOYEE_ID}`, 'green');
    log(`   Nom: ${response.data.employee.name}`, 'yellow');
    log(`   Email: ${response.data.employee.email}`, 'yellow');
    return true;
  } catch (error) {
    log(`❌ Erreur: ${error.response?.data?.message || error.message}`, 'red');
    return false;
  }
}

// 4. Modifier un employé (PUT)
async function updateEmployee() {
  try {
    log('\n✏️  TEST 4: Modification de l\'employé...', 'blue');
    
    const formData = new FormData();
    formData.append('name', 'Jean Dupont MODIFIÉ');
    formData.append('phone', '+243 888 888 888');
    
    const response = await axios.put(`${BASE_URL}/employees/${EMPLOYEE_ID}`, formData, {
      headers: {
        Authorization: `Bearer ${TOKEN}`,
        ...formData.getHeaders()
      }
    });
    
    log(`✅ Employé modifié avec succès`, 'green');
    log(`   Nouveau nom: ${response.data.employee.name}`, 'yellow');
    log(`   Nouveau téléphone: ${response.data.employee.phone}`, 'yellow');
    return true;
  } catch (error) {
    log(`❌ Erreur: ${error.response?.data?.message || error.message}`, 'red');
    return false;
  }
}

// 5. Supprimer un employé (DELETE)
async function deleteEmployee() {
  try {
    log('\n🗑️  TEST 5: Suppression de l\'employé...', 'blue');
    
    const response = await axios.delete(`${BASE_URL}/employees/${EMPLOYEE_ID}`, {
      headers: { Authorization: `Bearer ${TOKEN}` }
    });
    
    log(`✅ Employé supprimé avec succès`, 'green');
    return true;
  } catch (error) {
    log(`❌ Erreur: ${error.response?.data?.message || error.message}`, 'red');
    return false;
  }
}

// 6. Vérifier que l'employé est bien supprimé
async function verifyDeletion() {
  try {
    log('\n🔍 TEST 6: Vérification de la suppression...', 'blue');
    const response = await axios.get(`${BASE_URL}/employees`, {
      headers: { Authorization: `Bearer ${TOKEN}` }
    });
    
    const exists = response.data.employees?.some(emp => emp._id === EMPLOYEE_ID);
    if (!exists) {
      log(`✅ Confirmation: l'employé a bien été supprimé`, 'green');
      return true;
    } else {
      log(`❌ L'employé existe encore!`, 'red');
      return false;
    }
  } catch (error) {
    log(`❌ Erreur: ${error.response?.data?.message || error.message}`, 'red');
    return false;
  }
}

// Exécution des tests
async function runTests() {
  log('\n' + '='.repeat(60), 'blue');
  log('🧪 TESTS DES ROUTES EMPLOYEES', 'blue');
  log('='.repeat(60), 'blue');
  
  const results = {
    total: 6,
    passed: 0,
    failed: 0
  };
  
  // Test 1: Login
  if (await login()) results.passed++; else results.failed++;
  
  // Test 2: Get Employees
  if (await getEmployees()) results.passed++; else results.failed++;
  
  // Test 3: Create Employee
  if (await createEmployee()) results.passed++; else results.failed++;
  
  // Test 4: Update Employee
  if (await updateEmployee()) results.passed++; else results.failed++;
  
  // Test 5: Delete Employee
  if (await deleteEmployee()) results.passed++; else results.failed++;
  
  // Test 6: Verify Deletion
  if (await verifyDeletion()) results.passed++; else results.failed++;
  
  // Résumé
  log('\n' + '='.repeat(60), 'blue');
  log('📊 RÉSULTATS DES TESTS', 'blue');
  log('='.repeat(60), 'blue');
  log(`✅ Tests réussis: ${results.passed}/${results.total}`, 'green');
  log(`❌ Tests échoués: ${results.failed}/${results.total}`, results.failed > 0 ? 'red' : 'green');
  log('='.repeat(60) + '\n', 'blue');
  
  if (results.failed === 0) {
    log('🎉 TOUS LES TESTS SONT PASSÉS !', 'green');
  } else {
    log('⚠️  CERTAINS TESTS ONT ÉCHOUÉ', 'yellow');
  }
}

// Lancer les tests
runTests().catch(err => {
  log(`\n❌ Erreur fatale: ${err.message}`, 'red');
  process.exit(1);
});
