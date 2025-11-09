// Script pour mettre à jour le mot de passe de l'utilisateur
require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Schéma User
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

async function updatePassword() {
  try {
    console.log('🔄 Connexion à MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connecté à MongoDB\n');

    const email = 'nyundumathryme@gmail.com';
    const newPassword = 'admin123';
    
    console.log(`🔐 Mise à jour du mot de passe pour: ${email}`);
    console.log(`   Nouveau mot de passe: ${newPassword}`);
    
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    const result = await User.updateOne(
      { email },
      { $set: { password: hashedPassword } }
    );

    if (result.modifiedCount > 0) {
      console.log('\n✅ Mot de passe mis à jour avec succès!');
      console.log('   Email: nyundumathryme@gmail.com');
      console.log('   Mot de passe: admin123');
      
      // Vérifier que ça fonctionne
      const user = await User.findOne({ email });
      const isMatch = await bcrypt.compare(newPassword, user.password);
      console.log('\n🔍 Vérification:');
      console.log('   Test du mot de passe:', isMatch ? '✅ OK' : '❌ ERREUR');
    } else {
      console.log('\n⚠️  Aucune modification effectuée');
    }

  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Déconnecté de MongoDB');
  }
}

updatePassword();
