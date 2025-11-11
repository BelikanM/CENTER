# 🚀 Guide de Configuration Complète - Serveur Node.js + Flutter + MongoDB

## 📋 Table des matières
1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Installation Backend (Node.js)](#installation-backend-nodejs)
4. [Configuration MongoDB](#configuration-mongodb)
5. [Configuration Flutter](#configuration-flutter)
6. [Système d'IP Automatique](#système-dip-automatique)
7. [Déploiement](#déploiement)
8. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

Ce projet utilise une architecture moderne avec :
- **Backend** : Node.js + Express avec détection automatique d'IP
- **Base de données** : MongoDB (local ou cloud)
- **Frontend** : Flutter (Android/iOS/Web)
- **Innovation** : Système de connexion automatique sans configuration manuelle

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                          │
│  (Android / iOS / Web)                                  │
│  - Détection automatique de l'IP du serveur            │
│  - Reconnexion automatique après changement d'IP       │
└───────────────────┬─────────────────────────────────────┘
                    │ HTTP/WebSocket
                    ▼
┌─────────────────────────────────────────────────────────┐
│              NODE.JS EXPRESS SERVER                     │
│  - Détection automatique de l'IP réseau                │
│  - Middleware de correction d'URLs intelligente         │
│  - WebSocket pour temps réel                            │
│  Port: 5000                                             │
└───────────────────┬─────────────────────────────────────┘
                    │ Mongoose
                    ▼
┌─────────────────────────────────────────────────────────┐
│                   MONGODB DATABASE                      │
│  - Collections : Users, Publications, Stories, etc.     │
│  Port: 27017 (défaut)                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Prérequis

### Système d'exploitation
- ✅ Windows 10/11
- ✅ macOS 10.15+
- ✅ Linux (Ubuntu 20.04+, Debian, etc.)

### Logiciels requis

#### 1. Node.js (Backend)
```bash
# Vérifier si Node.js est installé
node --version  # Requis : v16.x ou supérieur

# Installation Windows
# Télécharger depuis : https://nodejs.org/

# Installation Linux (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installation macOS
brew install node
```

#### 2. MongoDB (Base de données)
```bash
# Vérifier si MongoDB est installé
mongod --version  # Requis : v5.0 ou supérieur

# Installation Windows
# Télécharger depuis : https://www.mongodb.com/try/download/community

# Installation Linux (Ubuntu)
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Installation macOS
brew tap mongodb/brew
brew install mongodb-community
```

#### 3. Flutter (Frontend)
```bash
# Vérifier si Flutter est installé
flutter --version  # Requis : v3.0 ou supérieur

# Installation
# Télécharger depuis : https://docs.flutter.dev/get-started/install

# Après installation, vérifier
flutter doctor
```

---

## 🔧 Installation Backend (Node.js)

### Étape 1 : Cloner le projet
```bash
cd /chemin/vers/votre/projet
cd backend
```

### Étape 2 : Installer les dépendances
```bash
npm install
```

**Dépendances principales** :
- `express` : Framework web
- `mongoose` : ORM MongoDB
- `jsonwebtoken` : Authentification JWT
- `bcryptjs` : Hash des mots de passe
- `multer` : Upload de fichiers
- `nodemailer` : Envoi d'emails
- `socket.io` : Communication temps réel
- `cors` : Gestion des requêtes cross-origin

### Étape 3 : Configuration des variables d'environnement

Créer un fichier `.env` dans le dossier `backend/` :

```env
# ========================================
# CONFIGURATION SERVEUR
# ========================================
PORT=5000
NODE_ENV=development

# ========================================
# MONGODB
# ========================================
# Option 1 : MongoDB Local
MONGODB_URI=mongodb://localhost:27017/center_db

# Option 2 : MongoDB Atlas (Cloud)
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/center_db?retryWrites=true&w=majority

# ========================================
# JWT SECRETS
# ========================================
JWT_SECRET=votre_secret_jwt_tres_securise_ici_min_32_caracteres
JWT_REFRESH_SECRET=votre_refresh_secret_tres_securise_min_32_caracteres

# ========================================
# EMAIL CONFIGURATION (Nodemailer)
# ========================================
EMAIL_USER=votre.email@gmail.com
EMAIL_PASS=votre_mot_de_passe_application

# Pour Gmail, créer un mot de passe d'application :
# 1. Compte Google > Sécurité
# 2. Validation en deux étapes (activer)
# 3. Mots de passe des applications > Générer

# ========================================
# UPLOADS
# ========================================
MAX_FILE_SIZE=52428800
# 50 MB = 52428800 bytes
```

### Étape 4 : Générer des secrets JWT sécurisés

```bash
# Dans Node.js REPL
node
> require('crypto').randomBytes(64).toString('hex')
# Copier le résultat dans JWT_SECRET

> require('crypto').randomBytes(64).toString('hex')
# Copier le résultat dans JWT_REFRESH_SECRET
```

### Étape 5 : Structure des dossiers uploads

Le serveur créera automatiquement les dossiers nécessaires au démarrage :
```
backend/
  uploads/
    profile/          # Photos de profil
    publications/     # Médias des publications
    stories/          # Stories 24h
    comments/         # Médias des commentaires
    markers/          # Photos/vidéos des markers
    employees/        # Documents employés
```

---

## 🗄️ Configuration MongoDB

### Option A : MongoDB Local

#### 1. Démarrer MongoDB
```bash
# Windows (en tant qu'administrateur)
net start MongoDB

# Linux/macOS
sudo systemctl start mongod
# ou
brew services start mongodb-community

# Vérifier que MongoDB fonctionne
mongosh
# Devrait afficher : "Connecting to: mongodb://127.0.0.1:27017"
```

#### 2. Créer la base de données
```bash
mongosh

# Créer la base de données
use center_db

# Créer un utilisateur admin (optionnel mais recommandé)
db.createUser({
  user: "center_admin",
  pwd: "mot_de_passe_securise",
  roles: [{ role: "readWrite", db: "center_db" }]
})

# Sortir
exit
```

#### 3. Mettre à jour le .env
```env
MONGODB_URI=mongodb://center_admin:mot_de_passe_securise@localhost:27017/center_db
```

### Option B : MongoDB Atlas (Cloud - Gratuit)

#### 1. Créer un compte
- Aller sur : https://www.mongodb.com/cloud/atlas
- Créer un compte gratuit (M0 Sandbox - 512 MB)

#### 2. Créer un cluster
1. Choisir un provider (AWS, Google Cloud, Azure)
2. Sélectionner une région proche de vous
3. Nom du cluster : `center-cluster`
4. Créer le cluster (5-10 minutes)

#### 3. Configuration de sécurité
1. **Database Access** :
   - Add New Database User
   - Username : `center_admin`
   - Password : Générer un mot de passe fort
   - Roles : `Atlas admin` ou `Read and write to any database`

2. **Network Access** :
   - Add IP Address
   - Option 1 : `0.0.0.0/0` (Autoriser tous - développement uniquement)
   - Option 2 : Votre IP spécifique (production)

#### 4. Obtenir la chaîne de connexion
1. Cluster > Connect
2. Connect your application
3. Copier la connection string
4. Remplacer `<password>` par votre mot de passe

```env
MONGODB_URI=mongodb+srv://center_admin:MOT_DE_PASSE@center-cluster.xxxxx.mongodb.net/center_db?retryWrites=true&w=majority
```

---

## 📱 Configuration Flutter

### Étape 1 : Installer les dépendances Flutter
```bash
cd /chemin/vers/votre/projet
flutter pub get
```

### Étape 2 : Configuration de l'API Service

Le fichier `lib/api_service.dart` contient déjà le système de détection automatique d'IP.

**Pas de configuration manuelle nécessaire !** 🎉

Le système détecte automatiquement :
1. L'IP du serveur sur le réseau local (192.168.x.x)
2. Reconnecte automatiquement après changement d'IP
3. Gère les reconnexions WebSocket

### Étape 3 : Vérifier la configuration réseau

```dart
// lib/api_service.dart
class ApiService {
  // Le système détecte automatiquement l'IP
  static const String _serverPort = '5000';
  static String _baseUrl = '';
  
  // Détection automatique de l'IP du serveur
  static Future<void> detectServerIP() async {
    // Scanne automatiquement 192.168.1.1 à 192.168.1.255
    // Trouve le serveur actif sur le port 5000
  }
}
```

### Étape 4 : Build et Run

#### Android
```bash
# Connecter un appareil ou lancer un émulateur
flutter devices

# Compiler et installer
flutter run

# Build APK de production
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release
```

#### iOS (macOS uniquement)
```bash
# Ouvrir le projet iOS
cd ios
pod install
cd ..

# Compiler
flutter run

# Build pour production
flutter build ios --release
```

#### Web
```bash
# Mode développement
flutter run -d chrome

# Build pour production
flutter build web --release

# Les fichiers seront dans build/web/
```

---

## 🌐 Système d'IP Automatique

### Comment ça fonctionne ?

#### Backend : Détection automatique de l'IP

```javascript
// backend/server.js

const os = require('os');

function getLocalNetworkIP() {
  const interfaces = os.networkInterfaces();
  
  // Parcourir toutes les interfaces réseau
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      // Ignorer les interfaces internes et IPv6
      if (iface.family === 'IPv4' && !iface.internal) {
        const ip = iface.address;
        
        // Prioriser les IP de réseau privé
        if (ip.startsWith('192.168.') || 
            ip.startsWith('10.') || 
            ip.startsWith('172.')) {
          console.log(`✅ IP réseau détectée: ${ip}`);
          return ip;
        }
      }
    }
  }
  
  // Fallback sur localhost
  return 'localhost';
}

// Détection automatique au démarrage
const SERVER_IP = getLocalNetworkIP();
const BASE_URL = `http://${SERVER_IP}:5000`;

console.log(`🚀 Serveur démarré sur ${BASE_URL}`);
```

#### Frontend : Scan automatique du réseau

```dart
// lib/api_service.dart

static Future<void> detectServerIP() async {
  print('🔍 Détection de l\'IP du serveur...');
  
  // Obtenir l'IP locale de l'appareil
  String? deviceIP = await _getDeviceLocalIP();
  if (deviceIP == null) return;
  
  // Extraire le préfixe réseau (ex: 192.168.1)
  final parts = deviceIP.split('.');
  final networkPrefix = '${parts[0]}.${parts[1]}.${parts[2]}';
  
  // Scanner les 255 adresses possibles
  for (int i = 1; i <= 255; i++) {
    final testIP = '$networkPrefix.$i';
    final testUrl = 'http://$testIP:$_serverPort/api/test';
    
    try {
      final response = await http.get(
        Uri.parse(testUrl),
      ).timeout(Duration(milliseconds: 500));
      
      if (response.statusCode == 200) {
        _baseUrl = 'http://$testIP:$_serverPort';
        print('✅ Serveur trouvé: $_baseUrl');
        
        // Sauvegarder pour utilisation future
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_ip', testIP);
        
        return;
      }
    } catch (e) {
      // Continuer le scan
    }
  }
  
  print('❌ Serveur non trouvé sur le réseau');
}
```

#### Middleware : Correction automatique des URLs

```javascript
// backend/server.js

// Middleware qui corrige TOUTES les URLs dans les réponses
app.use((req, res, next) => {
  const originalJson = res.json;
  
  res.json = function(data) {
    const replaceUrls = (obj) => {
      if (typeof obj === 'string') {
        let result = obj;
        
        // 1. Remplacer les anciennes IPs par la nouvelle
        const ipUrlPattern = /http:\/\/(192\.168\.\d{1,3}\.\d{1,3}|10\.\d{1,3}\.\d{1,3}\.\d{1,3}|localhost)(?::(\d+))?/g;
        result = result.replace(ipUrlPattern, (match, ip, port) => {
          if (ip === SERVER_IP) return match;
          return `http://${SERVER_IP}:${port || '5000'}`;
        });
        
        // 2. Convertir les chemins relatifs en URLs complètes
        if (result.startsWith('uploads/')) {
          result = `${BASE_URL}/${result}`;
        }
        
        return result;
      } else if (Array.isArray(obj)) {
        return obj.map(item => replaceUrls(item));
      } else if (obj !== null && typeof obj === 'object') {
        const newObj = {};
        for (const key in obj) {
          newObj[key] = replaceUrls(obj[key]);
        }
        return newObj;
      }
      return obj;
    };
    
    const correctedData = replaceUrls(data);
    return originalJson.call(this, correctedData);
  };
  
  next();
});
```

### Avantages du système

✅ **Aucune configuration manuelle** - Le serveur et l'app se trouvent automatiquement
✅ **Résilience** - Reconnexion automatique après changement d'IP
✅ **Migration facile** - Déplacer l'app sur un nouveau réseau sans modification
✅ **Développement rapide** - Testez sur plusieurs appareils sans configuration
✅ **Production ready** - Fonctionne aussi avec IP fixe ou nom de domaine

---

## 🚀 Déploiement

### Développement Local

```bash
# Terminal 1 : Démarrer MongoDB
mongod

# Terminal 2 : Démarrer le backend
cd backend
npm start
# Serveur sur http://192.168.1.x:5000

# Terminal 3 : Démarrer Flutter
cd ..
flutter run
```

### Production

#### Backend (Serveur VPS/Cloud)

1. **Choisir un hébergeur** :
   - DigitalOcean (5$/mois)
   - AWS EC2
   - Google Cloud
   - Heroku
   - Railway

2. **Configuration serveur** :
```bash
# Connexion SSH
ssh root@votre-serveur-ip

# Installation Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installation MongoDB
# (voir section Configuration MongoDB)

# Cloner le projet
git clone https://github.com/votre-repo/center.git
cd center/backend

# Installer les dépendances
npm install --production

# Configurer les variables d'environnement
nano .env
# Mettre NODE_ENV=production

# Installer PM2 (gestionnaire de processus)
npm install -g pm2

# Démarrer le serveur
pm2 start server.js --name center-backend

# Configurer le démarrage automatique
pm2 startup
pm2 save
```

3. **Configuration NGINX (Reverse Proxy)** :
```nginx
server {
    listen 80;
    server_name votre-domaine.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

4. **SSL/HTTPS avec Let's Encrypt** :
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com
```

#### Flutter App

1. **Android (Google Play)** :
```bash
# Créer un keystore
keytool -genkey -v -keystore ~/center-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias center

# Configurer android/key.properties
storePassword=votre_mot_de_passe
keyPassword=votre_mot_de_passe
keyAlias=center
storeFile=/chemin/vers/center-key.jks

# Build
flutter build appbundle --release

# Upload sur Google Play Console
```

2. **iOS (App Store)** :
```bash
# Ouvrir dans Xcode
open ios/Runner.xcworkspace

# Configuration :
# - Bundle Identifier
# - Signing & Capabilities
# - Version et Build Number

# Build depuis Xcode
# Product > Archive
# Distribute App > App Store Connect
```

---

## 🔍 Dépannage

### Backend ne démarre pas

#### Problème : "Error: Cannot find module 'express'"
```bash
# Solution : Réinstaller les dépendances
cd backend
rm -rf node_modules package-lock.json
npm install
```

#### Problème : "MongooseError: Operation timed out"
```bash
# Solution : Vérifier que MongoDB fonctionne
mongosh
# Si échec, démarrer MongoDB :
sudo systemctl start mongod  # Linux
net start MongoDB  # Windows
```

#### Problème : "Error: listen EADDRINUSE :::5000"
```bash
# Solution : Port 5000 déjà utilisé
# Trouver le processus
lsof -ti:5000  # Linux/macOS
netstat -ano | findstr :5000  # Windows

# Tuer le processus
kill -9 <PID>  # Linux/macOS
taskkill /PID <PID> /F  # Windows

# Ou changer le port dans .env
PORT=5001
```

### Flutter ne se connecte pas

#### Problème : "SocketException: Connection refused"
```dart
// Solution 1 : Vérifier l'IP du serveur
// Sur le serveur, afficher l'IP :
ipconfig  // Windows
ifconfig  // Linux/macOS

// Solution 2 : Vérifier le pare-feu
// Windows : Autoriser le port 5000
// Linux : sudo ufw allow 5000
```

#### Problème : "Invalid argument(s): No host specified in URI"
```dart
// Solution : Le middleware n'a pas converti l'URL
// Vérifier que le backend a bien le middleware de correction d'URLs
// Redémarrer le serveur backend
```

#### Problème : Images ne se chargent pas
```dart
// Solution 1 : Vérifier les permissions réseau
// Android : AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>

// Solution 2 : Vérifier le dossier uploads/
// Sur le serveur, les fichiers doivent être accessibles :
ls -la backend/uploads/

// Solution 3 : Relancer la détection d'IP
await ApiService.detectServerIP();
```

### MongoDB

#### Problème : "Authentication failed"
```bash
# Solution : Vérifier les credentials dans .env
# Recréer l'utilisateur
mongosh
use center_db
db.dropUser("center_admin")
db.createUser({
  user: "center_admin",
  pwd: "nouveau_mot_de_passe",
  roles: [{ role: "readWrite", db: "center_db" }]
})
```

#### Problème : Base de données vide après redémarrage
```bash
# Solution : Vérifier le chemin de données MongoDB
# Linux : /var/lib/mongodb
# macOS : /usr/local/var/mongodb
# Windows : C:\Program Files\MongoDB\Server\6.0\data

# Vérifier les logs
# Linux : /var/log/mongodb/mongod.log
# macOS : /usr/local/var/log/mongodb/mongo.log
```

---

## 📚 Ressources supplémentaires

### Documentation officielle
- **Node.js** : https://nodejs.org/docs/
- **Express** : https://expressjs.com/
- **MongoDB** : https://docs.mongodb.com/
- **Mongoose** : https://mongoosejs.com/docs/
- **Flutter** : https://docs.flutter.dev/

### Tutoriels recommandés
- Node.js REST API : https://www.youtube.com/watch?v=fgTGADljAeg
- MongoDB Crash Course : https://www.youtube.com/watch?v=-56x56UppqQ
- Flutter HTTP Requests : https://docs.flutter.dev/cookbook/networking/fetch-data

### Outils utiles
- **Postman** : Tester les API - https://www.postman.com/
- **MongoDB Compass** : Interface graphique MongoDB - https://www.mongodb.com/products/compass
- **VSCode Extensions** :
  - MongoDB for VS Code
  - Thunder Client (alternative Postman)
  - Flutter
  - Dart

---

## 🤝 Support

Pour toute question ou problème :
1. Vérifier la section [Dépannage](#dépannage)
2. Consulter les logs du serveur : `backend/logs/`
3. Activer le mode debug :
   ```env
   NODE_ENV=development
   DEBUG=true
   ```

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**Développé avec ❤️ par l'équipe CENTER**

🎉 **Félicitations !** Vous avez maintenant un système complet avec détection automatique d'IP, backend Node.js robuste, et application Flutter moderne.
