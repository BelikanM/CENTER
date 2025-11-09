require('dotenv').config();
const mongoose = require('mongoose');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const BASE_URL = 'http://192.168.1.66:5000/api';

// Modèles
const userSchema = new mongoose.Schema({
  email: String,
  password: String,
  name: String,
  role: { type: String, default: 'user' },
  profileImage: String,
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

async function testUploadProfileImage() {
  try {
    console.log('\n========================================');
    console.log('TEST UPLOAD PROFILE IMAGE');
    console.log('========================================\n');

    // 1. Connexion à MongoDB
    console.log('1️⃣ Connexion à MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB connecté\n');

    // 2. Récupérer un utilisateur existant
    console.log('2️⃣ Recherche d\'un utilisateur...');
    let user = await User.findOne();
    
    if (!user) {
      console.log('❌ Aucun utilisateur trouvé dans la base de données');
      console.log('Création d\'un utilisateur de test...');
      user = await User.create({
        email: 'test@center.com',
        password: 'hashed_password',
        name: 'Utilisateur Test',
        role: 'user'
      });
      console.log('✅ Utilisateur créé');
    }
    
    console.log(`✅ Utilisateur trouvé: ${user.email} (${user.name})`);
    console.log(`   ID: ${user._id}\n`);

    // 3. Générer un token JWT
    console.log('3️⃣ Génération du token JWT...');
    const jwt = require('jsonwebtoken');
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
    console.log(`✅ Token généré: ${token.substring(0, 30)}...\n`);

    // 4. Créer une image de test
    console.log('4️⃣ Création d\'une image de test...');
    const testImagePath = path.join(__dirname, 'test-profile.jpg');
    
    // Créer un fichier image simple (1x1 pixel JPEG)
    const imageBuffer = Buffer.from([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
      0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
      0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
      0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
      0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x03, 0xFF, 0xC4, 0x00, 0x14, 0x10, 0x01, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00,
      0x37, 0xFF, 0xD9
    ]);
    
    fs.writeFileSync(testImagePath, imageBuffer);
    console.log(`✅ Image créée: ${testImagePath}\n`);

    // 5. Test upload avec FormData
    console.log('5️⃣ Upload de l\'image...');
    console.log(`   URL: ${BASE_URL}/user/upload-profile-image`);
    console.log(`   Token: Bearer ${token.substring(0, 30)}...`);
    console.log(`   File: ${testImagePath}\n`);

    const formData = new FormData();
    formData.append('profileImage', fs.createReadStream(testImagePath));

    const response = await axios.post(
      `${BASE_URL}/user/upload-profile-image`,
      formData,
      {
        headers: {
          ...formData.getHeaders(),
          'Authorization': `Bearer ${token}`
        },
        maxContentLength: Infinity,
        maxBodyLength: Infinity
      }
    );

    console.log('\n✅ UPLOAD RÉUSSI !');
    console.log('========================================');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    console.log('========================================\n');

    // 6. Vérifier dans la base de données
    console.log('6️⃣ Vérification dans la base de données...');
    const updatedUser = await User.findById(user._id);
    console.log(`✅ Image mise à jour: ${updatedUser.profileImage}\n`);

    // Nettoyage
    fs.unlinkSync(testImagePath);
    console.log('✅ Fichier de test supprimé\n');

  } catch (error) {
    console.error('\n❌ ERREUR:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
      console.error('Headers:', error.response.headers);
    }
  } finally {
    await mongoose.disconnect();
    console.log('✅ Déconnexion MongoDB\n');
  }
}

// Exécuter le test
testUploadProfileImage();
