const axios = require('axios');
const colors = require('colors');

const API_BASE = 'http://192.168.1.66:5000/api';
const TEST_EMAIL = 'nyundumathryme@gmail.com';
const TEST_PASSWORD = 'admin123';

let authToken = '';

async function testAdminLogin() {
  console.log('\n' + '='.repeat(60).cyan);
  console.log('Test 1: Admin Login'.yellow.bold);
  console.log('='.repeat(60).cyan);
  
  try {
    const response = await axios.post(`${API_BASE}/auth/admin-login`, {
      email: TEST_EMAIL,
      password: TEST_PASSWORD
    });

    if (response.data.accessToken) {
      authToken = response.data.accessToken;
      console.log('✓ Admin login successful'.green);
      console.log(`Token: ${authToken.substring(0, 50)}...`.gray);
      return true;
    }
  } catch (error) {
    console.log('✗ Admin login failed'.red);
    console.log(`Error: ${error.response?.data?.message || error.message}`.red);
    return false;
  }
}

async function testCreateEmployee() {
  console.log('\n' + '='.repeat(60).cyan);
  console.log('Test 2: Create Employee'.yellow.bold);
  console.log('='.repeat(60).cyan);
  
  try {
    const timestamp = Date.now();
    const employeeData = {
      name: `Test Employee ${timestamp}`,
      email: `test.employee.${timestamp}@example.com`,
      phone: `+1234567${timestamp.toString().slice(-3)}`
    };

    console.log(`Creating employee: ${employeeData.name}`.gray);
    console.log(`Email: ${employeeData.email}`.gray);
    console.log(`Phone: ${employeeData.phone}`.gray);

    const response = await axios.post(
      `${API_BASE}/employees`,
      employeeData,
      {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('\n' + 'Response Data:'.yellow);
    console.log(JSON.stringify(response.data, null, 2).gray);

    if (response.data.employee) {
      console.log('\n✓ Employee created successfully'.green);
      console.log(`Employee ID: ${response.data.employee._id}`.gray);
      console.log(`Name: ${response.data.employee.name}`.gray);
      console.log(`Email: ${response.data.employee.email}`.gray);
      console.log(`Phone: ${response.data.employee.phone}`.gray);
      
      // Verify response structure
      console.log('\n' + 'Response Structure Check:'.yellow);
      console.log(`  - Has 'employee' field: ${!!response.data.employee}`.gray);
      console.log(`  - Has 'message' field: ${!!response.data.message}`.gray);
      console.log(`  - Has 'success' field: ${!!response.data.success}`.gray);
      
      return response.data.employee._id;
    } else {
      console.log('✗ Employee creation failed - No employee in response'.red);
      return null;
    }
  } catch (error) {
    console.log('✗ Employee creation failed'.red);
    console.log(`Error: ${error.response?.data?.message || error.message}`.red);
    if (error.response?.data) {
      console.log('Response data:'.yellow);
      console.log(JSON.stringify(error.response.data, null, 2).gray);
    }
    return null;
  }
}

async function testGetEmployees() {
  console.log('\n' + '='.repeat(60).cyan);
  console.log('Test 3: Get Employees'.yellow.bold);
  console.log('='.repeat(60).cyan);
  
  try {
    const response = await axios.get(`${API_BASE}/employees`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    console.log('\n' + 'Response Data:'.yellow);
    console.log(JSON.stringify(response.data, null, 2).gray);

    if (response.data.employees) {
      console.log('\n✓ Employees retrieved successfully'.green);
      console.log(`Total employees: ${response.data.employees.length}`.gray);
      
      // Verify response structure
      console.log('\n' + 'Response Structure Check:'.yellow);
      console.log(`  - Has 'employees' field: ${!!response.data.employees}`.gray);
      console.log(`  - Has 'success' field: ${!!response.data.success}`.gray);
      
      return true;
    } else {
      console.log('✗ Get employees failed - No employees in response'.red);
      return false;
    }
  } catch (error) {
    console.log('✗ Get employees failed'.red);
    console.log(`Error: ${error.response?.data?.message || error.message}`.red);
    return false;
  }
}

async function runAllTests() {
  console.log('\n' + '╔═══════════════════════════════════════════════════════════╗'.cyan.bold);
  console.log('║     Employee Creation End-to-End Test Suite             ║'.cyan.bold);
  console.log('╚═══════════════════════════════════════════════════════════╝'.cyan.bold);

  let passed = 0;
  let total = 3;

  // Test 1: Admin Login
  if (await testAdminLogin()) {
    passed++;
  } else {
    console.log('\n✗ Cannot continue without authentication'.red.bold);
    process.exit(1);
  }

  // Test 2: Create Employee
  const employeeId = await testCreateEmployee();
  if (employeeId) {
    passed++;
  }

  // Test 3: Get Employees
  if (await testGetEmployees()) {
    passed++;
  }

  // Summary
  console.log('\n' + '═'.repeat(60).cyan);
  console.log('TEST SUMMARY'.yellow.bold);
  console.log('═'.repeat(60).cyan);
  console.log(`Total Tests: ${total}`.white);
  console.log(`Passed: ${passed}`.green.bold);
  console.log(`Failed: ${total - passed}`.red.bold);
  console.log('═'.repeat(60).cyan + '\n');

  process.exit(passed === total ? 0 : 1);
}

runAllTests();
