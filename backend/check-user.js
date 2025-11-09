// Script pour vérifier l'utilisateur dans la base de données
require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Schéma User (copié du serveur)
const userSchema = new mongoose.Schema({
  email: String,
  password: String,
  name: String,
  otp: String,
  otpExpires: Date,
  profileImage: String,
  status: { type: String, default: 'offline' }
});

const User = mongoose.model('User', userSchema);

async function checkUser() {
  try {
    console.log('🔄 Connexion à MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connecté à MongoDB\n');

    const email = 'nyundumathryme@gmail.com';
    const user = await User.findOne({ email });

    if (user) {
      console.log('✅ Utilisateur trouvé:');
      console.log('   Email:', user.email);
      console.log('   Nom:', user.name);
      console.log('   Mot de passe (hashé):', user.password);
      console.log('   Statut:', user.status);
      console.log('   Image de profil:', user.profileImage || 'Non défini');
      
      console.log('\n🔐 Test du mot de passe "admin123":');
      const isMatch = await bcrypt.compare('admin123', user.password);
      console.log('   Résultat:', isMatch ? '✅ CORRESPOND' : '❌ NE CORRESPOND PAS');
      
      if (!isMatch) {
        console.log('\n⚠️  Le mot de passe ne correspond pas.');
        console.log('   Options:');
        console.log('   1. Créer un nouvel utilisateur avec le bon mot de passe');
        console.log('   2. Mettre à jour le mot de passe de cet utilisateur');
      }
    } else {
      console.log('❌ Aucun utilisateur trouvé avec cet email');
      console.log('\n💡 Création d\'un nouvel utilisateur...');
      
      const hashedPassword = await bcrypt.hash('admin123', 10);
      const newUser = new User({
        email: 'nyundumathryme@gmail.com',
        password: hashedPassword,
        name: 'Admin User',
        status: 'online'
      });
      
      await newUser.save();
      console.log('✅ Utilisateur créé avec succès!');
      console.log('   Email: nyundumathryme@gmail.com');
      console.log('   Mot de passe: admin123');
    }

  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Déconnecté de MongoDB');
  }
}

checkUser();
