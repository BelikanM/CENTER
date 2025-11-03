require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const os = require('os');

const app = express();

// ========================================
// DÉTECTION AUTOMATIQUE DE L'IP
// ========================================

function getLocalNetworkIP() {
  const interfaces = os.networkInterfaces();
  console.log('\n=== DÉTECTION AUTOMATIQUE DE L\'IP ===');
  console.log('Interfaces réseau disponibles:');
  
  for (const name of Object.keys(interfaces)) {
    const iface = interfaces[name];
    console.log(`\n${name}:`);
    
    for (const alias of iface) {
      console.log(`  - ${alias.address} (${alias.family}, internal: ${alias.internal})`);
      
      // Rechercher une adresse IPv4 non-interne (non-loopback)
      if (alias.family === 'IPv4' && !alias.internal) {
        // Priorité aux réseaux privés courants
        if (alias.address.startsWith('192.168.') || 
            alias.address.startsWith('10.') || 
            alias.address.startsWith('172.')) {
          console.log(`✅ IP sélectionnée: ${alias.address}`);
          return alias.address;
        }
      }
    }
  }
  
  // Fallback : chercher n'importe quelle IP IPv4 non-interne
  for (const name of Object.keys(interfaces)) {
    for (const alias of interfaces[name]) {
      if (alias.family === 'IPv4' && !alias.internal) {
        console.log(`⚠️ IP de fallback sélectionnée: ${alias.address}`);
        return alias.address;
      }
    }
  }
  
  console.log('❌ Aucune IP réseau trouvée, utilisation de localhost');
  return '127.0.0.1';
}

// Obtenir l'IP automatiquement
const SERVER_IP = getLocalNetworkIP();
const BASE_URL = `http://${SERVER_IP}:${process.env.PORT || 5000}`;

console.log(`🌐 URL de base du serveur: ${BASE_URL}`);

// ========================================
// CONFIGURATION GÉNÉRALE
// ========================================

app.use(cors());
app.use(express.json());

// Servir les fichiers statiques (uploads)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ========================================
// CONFIGURATION MULTER - UPLOAD D'IMAGES
// ========================================

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedMimes = [
      'image/jpeg', 'image/jpg', 'image/png', 'image/gif',
      'image/webp', 'image/bmp', 'image/tiff', 'image/svg+xml'
    ];
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tiff', '.svg'];
    const ext = path.extname(file.originalname).toLowerCase();

    if (allowedMimes.includes(file.mimetype) || allowedExtensions.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Format image non supporté'), false);
    }
  }
});

// ========================================
// CONNEXION À MONGODB
// ========================================

const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB connecté'))
  .catch(err => console.error('Erreur MongoDB:', err));

// ========================================
// MODÈLES (SCHÉMAS)
// ========================================

// Modèle Utilisateur
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  name: { type: String, default: '' },
  password: { type: String, required: true },
  profileImage: { type: String, default: '' },
  isVerified: { type: Boolean, default: false },
  status: { type: String, enum: ['active', 'blocked', 'admin'], default: 'active' },
  otp: { type: String },
  otpExpires: { type: Date }
});
const User = mongoose.model('User', userSchema);

// Modèle Employé
const employeeSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  faceImage: { type: String, default: '' },
  certificate: { type: String, default: '' },
  startDate: { type: Date },
  endDate: { type: Date },
  certificateStartDate: { type: Date },
  certificateEndDate: { type: Date },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});
const Employee = mongoose.model('Employee', employeeSchema);

// Modèle Publication
const publicationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, required: true },
  type: { type: String, enum: ['text', 'photo', 'video', 'article', 'event'], default: 'text' },
  media: [{
    type: { type: String, enum: ['image', 'video'], required: true },
    url: { type: String, required: true },
    filename: { type: String, required: true }
  }],
  location: {
    latitude: { type: Number },
    longitude: { type: Number },
    address: { type: String },
    placeName: { type: String }
  },
  tags: [{ type: String }],
  category: { type: String },
  visibility: { type: String, enum: ['public', 'friends', 'private'], default: 'public' },
  likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  comments: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    content: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
  }],
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});
const Publication = mongoose.model('Publication', publicationSchema);

// Modèle Marqueur
const markerSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  title: { type: String, required: true },
  comment: { type: String, default: '' },
  color: { type: String, default: '#FF0000' },
  photos: [{ type: String }], // URLs des photos
  videos: [{ type: String }], // URLs des vidéos
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});
const Marker = mongoose.model('Marker', markerSchema);

// ========================================
// CONFIGURATION UPLOADS SPÉCIFIQUES
// ========================================

// Upload pour employés (images + PDF)
const employeeUpload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'application/pdf'];
    const ext = path.extname(file.originalname).toLowerCase();
    if (allowed.includes(file.mimetype) || ['.pdf', '.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Seules les images et PDFs sont autorisés'), false);
    }
  }
});

// Upload pour publications (images + vidéos)
const publicationStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = 'uploads/publications/';
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'pub-' + unique + path.extname(file.originalname));
  }
});

const publicationUpload = multer({
  storage: publicationStorage,
  limits: { fileSize: 50 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = [
      'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp',
      'video/mp4', 'video/avi', 'video/mov', 'video/wmv', 'video/flv', 'video/webm', 'video/mkv'
    ];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Seules les images et vidéos sont autorisées'), false);
    }
  }
});

// Upload pour marqueurs (images + vidéos)
const markerStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = 'uploads/markers/';
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'marker-' + unique + path.extname(file.originalname));
  }
});

const markerUpload = multer({
  storage: markerStorage,
  limits: { fileSize: 50 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = [
      'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp',
      'video/mp4', 'video/avi', 'video/mov', 'video/wmv', 'video/flv', 'video/webm', 'video/mkv'
    ];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Seules les images et vidéos sont autorisées'), false);
    }
  }
});

// ========================================
// CONFIGURATION EMAIL (NODEMAILER)
// ========================================

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

const generateOTP = () => crypto.randomInt(100000, 999999).toString();

// ========================================
// MIDDLEWARES DE SÉCURITÉ
// ========================================

const verifyToken = (req, res, next) => {
  console.log('\n=== VÉRIFICATION TOKEN ===');
  console.log('URL:', req.method, req.originalUrl);
  console.log('Headers Authorization:', req.headers['authorization']);
  
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    console.log('❌ Erreur: Header Authorization manquant');
    return res.status(401).json({ message: 'Token manquant - Header Authorization requis' });
  }

  const token = authHeader.split(' ')[1];
  if (!token || token === 'null') {
    console.log('❌ Erreur: Token manquant après "Bearer" ou égal à "null"');
    return res.status(401).json({ message: 'Token manquant ou invalide - Format: Bearer <token>' });
  }

  console.log('Token reçu (premiers 20 caractères):', token.substring(0, 20) + '...');
  console.log('JWT_SECRET défini:', !!process.env.JWT_SECRET);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      console.log('❌ Erreur JWT:', err.message);
      console.log('Type erreur:', err.name);
      if (err.name === 'TokenExpiredError') {
        return res.status(403).json({ message: 'Token expiré', expired: true });
      }
      if (err.name === 'JsonWebTokenError') {
        return res.status(403).json({ message: 'Token invalide - ' + err.message });
      }
      return res.status(403).json({ message: 'Token invalide' });
    }
    console.log('✅ Token valide pour userId:', user.userId, 'email:', user.email);
    req.user = user;
    next();
  });
};

const verifyAdmin = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user || user.status !== 'admin') {
      return res.status(403).json({ message: 'Accès refusé. Droits admin requis.' });
    }
    next();
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

const verifyCanCreateEmployees = async (req, res, next) => {
  const user = await User.findById(req.user.userId);
  const allowed = ['nyundumathryme@gmail', 'nyundumathryme@gmail.com'];
  if (!user || !allowed.includes(user.email.toLowerCase())) {
    return res.status(403).json({ message: 'Seul l\'admin principal peut créer des employés' });
  }
  next();
};

const verifyCanManageUsers = async (req, res, next) => {
  const user = await User.findById(req.user.userId);
  const allowed = ['nyundumathryme@gmail', 'nyundumathryme@gmail.com'];
  if (!user || !allowed.includes(user.email.toLowerCase())) {
    return res.status(403).json({ message: 'Seul l\'admin principal peut gérer les utilisateurs' });
  }
  next();
};

// ========================================
// ROUTES : AUTHENTIFICATION
// ========================================

// Inscription + OTP
app.post('/api/auth/register', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'Email et mot de passe requis' });
  if (password.length < 6) return res.status(400).json({ message: 'Mot de passe trop court' });

  try {
    if (await User.findOne({ email })) return res.status(400).json({ message: 'Utilisateur déjà existant' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = generateOTP();
    const otpExpires = Date.now() + 10 * 60 * 1000;

    const user = new User({ email, password: hashedPassword, otp, otpExpires });
    await user.save();

    await transporter.sendMail({
      from: `"Auth System" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Code de vérification',
      html: `<h2>Bienvenue !</h2><p>Votre code OTP : <strong>${otp}</strong></p><p>Valable 10 minutes.</p>`
    });

    res.json({ message: 'OTP envoyé à votre email' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Connexion + OTP
app.post('/api/auth/login', async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(400).json({ message: 'Utilisateur non trouvé' });

  const otp = generateOTP();
  user.otp = otp;
  user.otpExpires = Date.now() + 10 * 60 * 1000;
  await user.save();

  await transporter.sendMail({
    from: `"Auth System" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Code OTP',
    html: `<h2>Connexion</h2><p>Votre code : <strong>${otp}</strong></p>`
  });

  res.json({ message: 'OTP envoyé' });
});

// Vérification OTP + JWT
app.post('/api/auth/verify-otp', async (req, res) => {
  console.log('\n=== VÉRIFICATION OTP ===');
  const { email, otp } = req.body;
  console.log('Email:', email);
  console.log('OTP reçu:', otp);
  
  const user = await User.findOne({ email });
  if (!user) {
    console.log('❌ Utilisateur non trouvé');
    return res.status(400).json({ message: 'Utilisateur non trouvé' });
  }

  console.log('OTP stocké:', user.otp);
  console.log('OTP expire à:', user.otpExpires);
  console.log('Date actuelle:', new Date());
  console.log('OTP expiré?', Date.now() > user.otpExpires);

  if (!user || user.otp !== otp || Date.now() > user.otpExpires) {
    console.log('❌ OTP invalide ou expiré');
    return res.status(400).json({ message: 'OTP invalide ou expiré' });
  }

  console.log('✅ OTP valide, génération des tokens...');
  console.log('JWT_SECRET:', process.env.JWT_SECRET ? 'Défini (longueur: ' + process.env.JWT_SECRET.length + ')' : 'NON DÉFINI!');
  console.log('JWT_REFRESH_SECRET:', process.env.JWT_REFRESH_SECRET ? 'Défini' : 'NON DÉFINI!');

  const accessToken = jwt.sign({ userId: user._id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '15m' });
  const refreshToken = jwt.sign({ userId: user._id }, process.env.JWT_REFRESH_SECRET, { expiresIn: '7d' });

  console.log('Access Token généré (premiers 30 car):', accessToken.substring(0, 30) + '...');
  console.log('Refresh Token généré (premiers 30 car):', refreshToken.substring(0, 30) + '...');

  user.otp = undefined;
  user.otpExpires = undefined;
  user.isVerified = true;
  await user.save();

  console.log('✅ Utilisateur sauvegardé, tokens envoyés');

  res.json({
    message: 'Connexion réussie',
    accessToken,
    refreshToken,
    user: { 
      email: user.email, 
      name: user.name, 
      profileImage: user.profileImage ? `${BASE_URL}/${user.profileImage}` : '', 
      status: user.status 
    }
  });
});

// Rafraîchir le token
app.post('/api/auth/refresh-token', (req, res) => {
  console.log('\n=== RAFRAÎCHISSEMENT TOKEN ===');
  const { refreshToken } = req.body;
  
  if (!refreshToken) {
    console.log('❌ Refresh token manquant');
    return res.status(401).json({ message: 'Refresh token requis' });
  }

  console.log('Refresh token reçu (premiers 30 car):', refreshToken.substring(0, 30) + '...');

  jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET, async (err, decoded) => {
    if (err) {
      console.log('❌ Erreur vérification refresh token:', err.message);
      return res.status(403).json({ message: 'Refresh token invalide' });
    }
    
    console.log('✅ Refresh token valide, userId:', decoded.userId);
    
    const user = await User.findById(decoded.userId);
    if (!user) {
      console.log('❌ Utilisateur non trouvé');
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    const newAccessToken = jwt.sign({ userId: user._id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '15m' });
    console.log('✅ Nouveau access token généré (premiers 30 car):', newAccessToken.substring(0, 30) + '...');
    
    res.json({ accessToken: newAccessToken });
  });
});

// ========================================
// ROUTES : PROFIL UTILISATEUR
// ========================================

app.put('/api/user/update-name', verifyToken, async (req, res) => {
  const { name } = req.body;
  if (!name?.trim()) return res.status(400).json({ message: 'Nom requis' });

  const user = await User.findById(req.user.userId);
  if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

  user.name = name.trim();
  await user.save();

  res.json({ message: 'Nom mis à jour', user: { email: user.email, name: user.name } });
});

app.put('/api/user/change-password', verifyToken, async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) return res.status(400).json({ message: 'Champs requis' });
  if (newPassword.length < 6) return res.status(400).json({ message: 'Mot de passe trop court' });

  const user = await User.findById(req.user.userId);
  if (!(await bcrypt.compare(currentPassword, user.password))) {
    return res.status(400).json({ message: 'Mot de passe actuel incorrect' });
  }

  user.password = await bcrypt.hash(newPassword, 10);
  await user.save();

  res.json({ message: 'Mot de passe changé' });
});

app.post('/api/user/upload-profile-image', verifyToken, upload.single('profileImage'), async (req, res) => {
  const user = await User.findById(req.user.userId);
  if (!req.file) return res.status(400).json({ message: 'Image requise' });

  if (user.profileImage) {
    const oldPath = path.join(__dirname, user.profileImage);
    if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
  }

  user.profileImage = req.file.path.replace(/\\/g, '/');
  await user.save();

  res.json({
    message: 'Photo mise à jour',
    profileImageUrl: `${BASE_URL}/${user.profileImage}`
  });
});

app.delete('/api/user/delete-profile-image', verifyToken, async (req, res) => {
  const user = await User.findById(req.user.userId);
  if (user.profileImage) {
    const imagePath = path.join(__dirname, user.profileImage);
    if (fs.existsSync(imagePath)) fs.unlinkSync(imagePath);
    user.profileImage = '';
    await user.save();
  }
  res.json({ message: 'Photo supprimée' });
});

app.delete('/api/user/delete-account', verifyToken, async (req, res) => {
  await User.findByIdAndDelete(req.user.userId);
  res.json({ message: 'Compte supprimé' });
});

// ========================================
// ROUTES : PUBLICATIONS
// ========================================

app.post('/api/publications', verifyToken, publicationUpload.array('media', 10), async (req, res) => {
  console.log('\n=== CRÉATION PUBLICATION ===');
  console.log('User ID:', req.user.userId);
  console.log('Content:', req.body.content?.substring(0, 50) + '...');
  console.log('Type:', req.body.type);
  console.log('Fichiers uploadés:', req.files?.length || 0);
  
  const { content, type, latitude, longitude, address, placeName, tags, category, visibility } = req.body;
  if (!content?.trim()) {
    console.log('❌ Contenu manquant');
    return res.status(400).json({ message: 'Contenu requis' });
  }

  const media = req.files?.map(file => ({
    type: file.mimetype.startsWith('image/') ? 'image' : 'video',
    url: `${BASE_URL}/${file.path.replace(/\\/g, '/')}`,
    filename: file.filename
  })) || [];

  const location = latitude && longitude ? { latitude: +latitude, longitude: +longitude, address, placeName } : undefined;
  const tagsArray = tags ? tags.split(',').map(t => t.trim()).filter(Boolean) : [];

  console.log('Médias:', media.length);
  console.log('Localisation:', location ? 'Oui' : 'Non');
  console.log('Tags:', tagsArray.length);

  const pub = new Publication({
    userId: req.user.userId,
    content: content.trim(),
    type: type || 'text',
    media,
    location,
    tags: tagsArray,
    category,
    visibility: visibility || 'public'
  });

  await pub.save();
  await pub.populate('userId', 'name email profileImage');

  console.log('✅ Publication créée, ID:', pub._id);
  res.status(201).json({ message: 'Publication créée', publication: pub });
});

app.get('/api/publications', verifyToken, async (req, res) => {
  console.log('\n=== RÉCUPÉRATION PUBLICATIONS ===');
  console.log('User ID:', req.user.userId);
  const page = +req.query.page || 1;
  const limit = +req.query.limit || 20;
  const skip = (page - 1) * limit;
  console.log('Page:', page, 'Limit:', limit);

  const publications = await Publication.find({ isActive: true })
    .populate('userId', 'name email profileImage')
    .populate('comments.userId', 'name email profileImage')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

  const total = await Publication.countDocuments({ isActive: true });

  console.log('✅ Publications trouvées:', publications.length, '/', total);
  res.json({
    publications,
    pagination: { currentPage: page, totalPages: Math.ceil(total / limit), total }
  });
});

app.get('/api/publications/user/:userId', verifyToken, async (req, res) => {
  const publications = await Publication.find({ userId: req.params.userId, isActive: true })
    .populate('userId', 'name email profileImage')
    .sort({ createdAt: -1 });
  res.json({ publications });
});

app.get('/api/publications/:id', verifyToken, async (req, res) => {
  const pub = await Publication.findById(req.params.id)
    .populate('userId', 'name email profileImage')
    .populate('comments.userId', 'name email profileImage');
  if (!pub || !pub.isActive) return res.status(404).json({ message: 'Non trouvée' });
  res.json({ publication: pub });
});

app.put('/api/publications/:id', verifyToken, publicationUpload.array('media', 10), async (req, res) => {
  const pub = await Publication.findById(req.params.id);
  if (!pub || pub.userId.toString() !== req.user.userId) return res.status(403).json({ message: 'Accès refusé' });

  const { content, latitude, longitude, address, placeName, tags, category, visibility } = req.body;
  if (content !== undefined) pub.content = content.trim();
  if (req.files?.length) {
    req.files.forEach(f => pub.media.push({
      type: f.mimetype.startsWith('image/') ? 'image' : 'video',
      url: `${BASE_URL}/${f.path.replace(/\\/g, '/')}`,
      filename: f.filename
    }));
  }
  if (latitude && longitude) pub.location = { latitude: +latitude, longitude: +longitude, address, placeName };
  if (tags !== undefined) pub.tags = tags.split(',').map(t => t.trim()).filter(Boolean);
  if (category !== undefined) pub.category = category;
  if (visibility !== undefined) pub.visibility = visibility;

  pub.updatedAt = new Date();
  await pub.save();
  await pub.populate('userId', 'name email profileImage');

  res.json({ message: 'Mise à jour OK', publication: pub });
});

app.delete('/api/publications/:id', verifyToken, async (req, res) => {
  const pub = await Publication.findById(req.params.id);
  if (!pub || pub.userId.toString() !== req.user.userId) return res.status(403).json({ message: 'Accès refusé' });

  pub.media.forEach(m => {
    const filePath = path.join(__dirname, 'uploads/publications/', m.filename);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
  });

  pub.isActive = false;
  await pub.save();

  res.json({ message: 'Publication supprimée' });
});

app.post('/api/publications/:id/like', verifyToken, async (req, res) => {
  const pub = await Publication.findById(req.params.id);
  const index = pub.likes.indexOf(req.user.userId);
  if (index > -1) pub.likes.splice(index, 1);
  else pub.likes.push(req.user.userId);
  await pub.save();

  res.json({ message: index > -1 ? 'Like retiré' : 'Liké', likesCount: pub.likes.length });
});

// Récupérer les commentaires d'une publication
app.get('/api/publications/:id/comments', verifyToken, async (req, res) => {
  try {
    const pub = await Publication.findById(req.params.id)
      .populate('comments.userId', 'name email profileImage');
    if (!pub || !pub.isActive) return res.status(404).json({ message: 'Publication non trouvée' });

    const commentsWithUrls = pub.comments.map(comment => ({
      ...comment.toObject(),
      userId: comment.userId ? {
        ...comment.userId.toObject(),
        profileImage: comment.userId.profileImage ? `${BASE_URL}/${comment.userId.profileImage}` : ''
      } : null
    }));

    res.json({ comments: commentsWithUrls });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Ajouter un commentaire
app.post('/api/publications/:id/comments', verifyToken, async (req, res) => {
  const { content } = req.body;
  if (!content?.trim()) return res.status(400).json({ message: 'Commentaire requis' });

  const pub = await Publication.findById(req.params.id);
  if (!pub || !pub.isActive) return res.status(404).json({ message: 'Publication non trouvée' });

  pub.comments.push({ userId: req.user.userId, content: content.trim() });
  await pub.save();

  const comment = pub.comments[pub.comments.length - 1];
  await pub.populate('comments.userId', 'name email profileImage');

  res.status(201).json({ 
    message: 'Commentaire ajouté',
    comment: {
      ...comment.toObject(),
      userId: comment.userId ? {
        ...comment.userId.toObject(),
        profileImage: comment.userId.profileImage ? `${BASE_URL}/${comment.userId.profileImage}` : ''
      } : null
    }
  });
});

app.delete('/api/publications/:id/media/:mediaIndex', verifyToken, async (req, res) => {
  const pub = await Publication.findById(req.params.id);
  if (pub.userId.toString() !== req.user.userId) return res.status(403).json({ message: 'Accès refusé' });

  const idx = +req.params.mediaIndex;
  if (idx < 0 || idx >= pub.media.length) return res.status(400).json({ message: 'Index invalide' });

  const filePath = path.join(__dirname, 'uploads/publications/', pub.media[idx].filename);
  if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

  pub.media.splice(idx, 1);
  pub.updatedAt = new Date();
  await pub.save();

  res.json({ message: 'Média supprimé', media: pub.media });
});

// ========================================
// ROUTES : MARQUEURS
// ========================================

// Créer un marqueur
app.post('/api/markers', verifyToken, markerUpload.fields([
  { name: 'photos', maxCount: 10 },
  { name: 'videos', maxCount: 5 }
]), async (req, res) => {
  console.log('\n=== CRÉATION MARQUEUR ===');
  console.log('User ID:', req.user.userId);
  console.log('Latitude:', req.body.latitude);
  console.log('Longitude:', req.body.longitude);
  console.log('Title:', req.body.title);
  console.log('Photos:', req.files?.photos?.length || 0);
  console.log('Videos:', req.files?.videos?.length || 0);

  const { latitude, longitude, title, comment, color, userId } = req.body;
  if (!latitude || !longitude || !title) {
    console.log('❌ Champs requis manquants');
    return res.status(400).json({ message: 'Latitude, longitude et titre requis' });
  }

  try {
    const photos = req.files?.photos?.map(file => 
      `${BASE_URL}/${file.path.replace(/\\/g, '/')}`
    ) || [];
    
    const videos = req.files?.videos?.map(file => 
      `${BASE_URL}/${file.path.replace(/\\/g, '/')}`
    ) || [];

    const marker = new Marker({
      userId: req.user.userId,
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      title: title.trim(),
      comment: comment?.trim() || '',
      color: color || '#FF0000',
      photos,
      videos
    });

    await marker.save();
    await marker.populate('userId', 'name email');

    console.log('✅ Marqueur créé, ID:', marker._id);
    res.status(201).json({ message: 'Marqueur créé', marker });
  } catch (err) {
    console.error('❌ Erreur création marqueur:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer tous les marqueurs
app.get('/api/markers', verifyToken, async (req, res) => {
  console.log('\n=== RÉCUPÉRATION MARQUEURS ===');
  console.log('User ID:', req.user.userId);

  try {
    const markers = await Marker.find()
      .populate('userId', 'name email')
      .sort({ createdAt: -1 });

    console.log('✅ Marqueurs trouvés:', markers.length);
    res.json({ markers });
  } catch (err) {
    console.error('❌ Erreur récupération marqueurs:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer les marqueurs d'un utilisateur
app.get('/api/markers/user/:userId', verifyToken, async (req, res) => {
  console.log('\n=== RÉCUPÉRATION MARQUEURS UTILISATEUR ===');
  console.log('User ID demandé:', req.params.userId);
  console.log('User ID connecté:', req.user.userId);

  try {
    const markers = await Marker.find({ userId: req.params.userId })
      .populate('userId', 'name email')
      .sort({ createdAt: -1 });

    console.log('✅ Marqueurs utilisateur trouvés:', markers.length);
    res.json({ markers });
  } catch (err) {
    console.error('❌ Erreur récupération marqueurs utilisateur:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un marqueur par ID
app.get('/api/markers/:id', verifyToken, async (req, res) => {
  console.log('\n=== RÉCUPÉRATION MARQUEUR PAR ID ===');
  console.log('Marker ID:', req.params.id);

  try {
    const marker = await Marker.findById(req.params.id)
      .populate('userId', 'name email');

    if (!marker) {
      console.log('❌ Marqueur non trouvé');
      return res.status(404).json({ message: 'Marqueur non trouvé' });
    }

    console.log('✅ Marqueur trouvé');
    res.json({ marker });
  } catch (err) {
    console.error('❌ Erreur récupération marqueur:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Mettre à jour un marqueur
app.put('/api/markers/:id', verifyToken, markerUpload.fields([
  { name: 'photos', maxCount: 10 },
  { name: 'videos', maxCount: 5 }
]), async (req, res) => {
  console.log('\n=== MISE À JOUR MARQUEUR ===');
  console.log('Marker ID:', req.params.id);
  console.log('User ID:', req.user.userId);

  try {
    const marker = await Marker.findById(req.params.id);
    if (!marker) {
      console.log('❌ Marqueur non trouvé');
      return res.status(404).json({ message: 'Marqueur non trouvé' });
    }

    if (marker.userId.toString() !== req.user.userId) {
      console.log('❌ Accès refusé');
      return res.status(403).json({ message: 'Accès refusé' });
    }

    const { title, comment, color } = req.body;
    
    if (title !== undefined) marker.title = title.trim();
    if (comment !== undefined) marker.comment = comment.trim();
    if (color !== undefined) marker.color = color;

    // Ajouter de nouveaux fichiers si fournis
    if (req.files?.photos?.length) {
      const newPhotos = req.files.photos.map(file => 
        `${BASE_URL}/${file.path.replace(/\\/g, '/')}`
      );
      marker.photos.push(...newPhotos);
    }

    if (req.files?.videos?.length) {
      const newVideos = req.files.videos.map(file => 
        `${BASE_URL}/${file.path.replace(/\\/g, '/')}`
      );
      marker.videos.push(...newVideos);
    }

    marker.updatedAt = new Date();
    await marker.save();
    await marker.populate('userId', 'name email');

    console.log('✅ Marqueur mis à jour');
    res.json({ message: 'Marqueur mis à jour', marker });
  } catch (err) {
    console.error('❌ Erreur mise à jour marqueur:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Supprimer un marqueur
app.delete('/api/markers/:id', verifyToken, async (req, res) => {
  console.log('\n=== SUPPRESSION MARQUEUR ===');
  console.log('Marker ID:', req.params.id);
  console.log('User ID:', req.user.userId);

  try {
    const marker = await Marker.findById(req.params.id);
    if (!marker) {
      console.log('❌ Marqueur non trouvé');
      return res.status(404).json({ message: 'Marqueur non trouvé' });
    }

    if (marker.userId.toString() !== req.user.userId) {
      console.log('❌ Accès refusé');
      return res.status(403).json({ message: 'Accès refusé' });
    }

    // Supprimer les fichiers associés
    marker.photos.forEach(photoUrl => {
      try {
        const photoPath = photoUrl.replace(`${BASE_URL}/`, '');
        const fullPath = path.join(__dirname, photoPath);
        if (fs.existsSync(fullPath)) {
          fs.unlinkSync(fullPath);
          console.log('Photo supprimée:', fullPath);
        }
      } catch (err) {
        console.error('Erreur suppression photo:', err);
      }
    });

    marker.videos.forEach(videoUrl => {
      try {
        const videoPath = videoUrl.replace(`${BASE_URL}/`, '');
        const fullPath = path.join(__dirname, videoPath);
        if (fs.existsSync(fullPath)) {
          fs.unlinkSync(fullPath);
          console.log('Vidéo supprimée:', fullPath);
        }
      } catch (err) {
        console.error('Erreur suppression vidéo:', err);
      }
    });

    await Marker.findByIdAndDelete(req.params.id);
    console.log('✅ Marqueur supprimé');
    res.json({ message: 'Marqueur supprimé' });
  } catch (err) {
    console.error('❌ Erreur suppression marqueur:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Supprimer un média d'un marqueur
app.delete('/api/markers/:id/media/:type/:index', verifyToken, async (req, res) => {
  console.log('\n=== SUPPRESSION MÉDIA MARQUEUR ===');
  console.log('Marker ID:', req.params.id);
  console.log('Type:', req.params.type);
  console.log('Index:', req.params.index);

  try {
    const marker = await Marker.findById(req.params.id);
    if (!marker) {
      console.log('❌ Marqueur non trouvé');
      return res.status(404).json({ message: 'Marqueur non trouvé' });
    }

    if (marker.userId.toString() !== req.user.userId) {
      console.log('❌ Accès refusé');
      return res.status(403).json({ message: 'Accès refusé' });
    }

    const { type, index } = req.params;
    const idx = parseInt(index);

    if (type === 'photo' && idx >= 0 && idx < marker.photos.length) {
      const photoUrl = marker.photos[idx];
      const photoPath = photoUrl.replace(`${BASE_URL}/`, '');
      const fullPath = path.join(__dirname, photoPath);
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
        console.log('Photo supprimée:', fullPath);
      }
      marker.photos.splice(idx, 1);
    } else if (type === 'video' && idx >= 0 && idx < marker.videos.length) {
      const videoUrl = marker.videos[idx];
      const videoPath = videoUrl.replace(`${BASE_URL}/`, '');
      const fullPath = path.join(__dirname, videoPath);
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
        console.log('Vidéo supprimée:', fullPath);
      }
      marker.videos.splice(idx, 1);
    } else {
      console.log('❌ Type ou index invalide');
      return res.status(400).json({ message: 'Type ou index invalide' });
    }

    marker.updatedAt = new Date();
    await marker.save();

    console.log('✅ Média supprimé');
    res.json({ message: 'Média supprimé', marker });
  } catch (err) {
    console.error('❌ Erreur suppression média:', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// ========================================
// ROUTES : GESTION DES EMPLOYÉS (ADMIN) - COMPLÈTES
// ========================================

// Lister les employés (GET)
app.get('/api/employees', verifyToken, verifyCanCreateEmployees, async (req, res) => {
  try {
    const employees = await Employee.find().sort({ createdAt: -1 });
    const employeesWithUrls = employees.map(emp => ({
      ...emp.toObject(),
      faceImage: emp.faceImage ? `${BASE_URL}/${emp.faceImage}` : '',
      certificate: emp.certificate ? `${BASE_URL}/${emp.certificate}` : ''
    }));
    res.json({ employees: employeesWithUrls });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur lors du listage des employés' });
  }
});

// Créer un employé (déjà présent)
app.post('/api/employees', verifyToken, verifyCanCreateEmployees, employeeUpload.fields([
  { name: 'faceImage', maxCount: 1 },
  { name: 'certificate', maxCount: 1 }
]), async (req, res) => {
  const { name, email, phone, startDate, endDate, certificateStartDate, certificateEndDate } = req.body;
  if (!name || !email || !phone) return res.status(400).json({ message: 'Champs requis' });

  try {
    if (await Employee.findOne({ email })) return res.status(400).json({ message: 'Email déjà utilisé' });

    const employee = new Employee({
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      faceImage: req.files.faceImage?.[0]?.path.replace(/\\/g, '/') || '',
      certificate: req.files.certificate?.[0]?.path.replace(/\\/g, '/') || '',
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      certificateStartDate: certificateStartDate ? new Date(certificateStartDate) : undefined,
      certificateEndDate: certificateEndDate ? new Date(certificateEndDate) : undefined
    });

    await employee.save();
    const employeeWithUrls = {
      ...employee.toObject(),
      faceImage: employee.faceImage ? `${BASE_URL}/${employee.faceImage}` : '',
      certificate: employee.certificate ? `${BASE_URL}/${employee.certificate}` : ''
    };
    res.json({ message: 'Employé créé', employee: employeeWithUrls });

    // Notification admin (asynchrone)
    (async () => {
      const admins = await User.find({ $or: [{ status: 'admin' }, { email: { $in: ['nyundumathryme@gmail', 'nyundumathryme@gmail.com'] } }] });
      const emails = [...new Set(admins.map(a => a.email))].filter(Boolean);
      if (!emails.length) return;

      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: emails.join(','),
        subject: `Nouvel employé: ${employee.name}`,
        html: `<h2>Nouvel employé</h2><p>${employee.name} (${employee.email})</p>`
      });
    })();
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur lors de la création' });
  }
});

// Modifier un employé (PUT)
app.put('/api/employees/:id', verifyToken, verifyCanCreateEmployees, employeeUpload.fields([
  { name: 'faceImage', maxCount: 1 },
  { name: 'certificate', maxCount: 1 }
]), async (req, res) => {
  const { name, email, phone, startDate, endDate, certificateStartDate, certificateEndDate } = req.body;
  const id = req.params.id;

  try {
    const employee = await Employee.findById(id);
    if (!employee) return res.status(404).json({ message: 'Employé non trouvé' });

    if (name) employee.name = name.trim();
    if (email) employee.email = email.trim();
    if (phone) employee.phone = phone.trim();
    if (startDate) employee.startDate = new Date(startDate);
    if (endDate) employee.endDate = new Date(endDate);
    if (certificateStartDate) employee.certificateStartDate = new Date(certificateStartDate);
    if (certificateEndDate) employee.certificateEndDate = new Date(certificateEndDate);

    // Mise à jour des fichiers si fournis
    if (req.files.faceImage?.[0]) {
      if (employee.faceImage) {
        const oldFacePath = path.join(__dirname, employee.faceImage);
        if (fs.existsSync(oldFacePath)) fs.unlinkSync(oldFacePath);
      }
      employee.faceImage = req.files.faceImage[0].path.replace(/\\/g, '/');
    }
    if (req.files.certificate?.[0]) {
      if (employee.certificate) {
        const oldCertPath = path.join(__dirname, employee.certificate);
        if (fs.existsSync(oldCertPath)) fs.unlinkSync(oldCertPath);
      }
      employee.certificate = req.files.certificate[0].path.replace(/\\/g, '/');
    }

    employee.updatedAt = new Date();
    await employee.save();

    const employeeWithUrls = {
      ...employee.toObject(),
      faceImage: employee.faceImage ? `${BASE_URL}/${employee.faceImage}` : '',
      certificate: employee.certificate ? `${BASE_URL}/${employee.certificate}` : ''
    };
    res.json({ message: 'Employé mis à jour', employee: employeeWithUrls });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur lors de la mise à jour' });
  }
});

// Supprimer un employé (DELETE)
app.delete('/api/employees/:id', verifyToken, verifyCanCreateEmployees, async (req, res) => {
  const id = req.params.id;

  try {
    const employee = await Employee.findById(id);
    if (!employee) return res.status(404).json({ message: 'Employé non trouvé' });

    // Supprimer les fichiers associés
    if (employee.faceImage) {
      const facePath = path.join(__dirname, employee.faceImage);
      if (fs.existsSync(facePath)) fs.unlinkSync(facePath);
    }
    if (employee.certificate) {
      const certPath = path.join(__dirname, employee.certificate);
      if (fs.existsSync(certPath)) fs.unlinkSync(certPath);
    }

    await Employee.findByIdAndDelete(id);
    res.json({ message: 'Employé supprimé' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur lors de la suppression' });
  }
});

// ========================================
// ROUTES : GESTION DES UTILISATEURS (ADMIN)
// ========================================

app.get('/api/users', verifyToken, verifyCanManageUsers, async (req, res) => {
  const users = await User.find().select('-password -otp -otpExpires');
  const usersWithUrls = users.map(user => ({
    ...user.toObject(),
    profileImage: user.profileImage ? `${BASE_URL}/${user.profileImage}` : ''
  }));
  res.json({ users: usersWithUrls });
});

app.put('/api/users/:id/status', verifyToken, verifyCanManageUsers, async (req, res) => {
  const { status } = req.body;
  if (!['active', 'blocked', 'admin'].includes(status)) return res.status(400).json({ message: 'Statut invalide' });

  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

  const mainAdmin = ['nyundumathryme@gmail', 'nyundumathryme@gmail.com'].includes(user.email.toLowerCase());
  if (mainAdmin) return res.status(403).json({ message: 'Impossible de modifier l\'admin principal' });

  user.status = status;
  await user.save();

  res.json({ message: 'Statut mis à jour', user });
});

app.delete('/api/users/:id', verifyToken, verifyCanManageUsers, async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

  if (['nyundumathryme@gmail', 'nyundumathryme@gmail.com'].includes(user.email.toLowerCase())) {
    return res.status(403).json({ message: 'Impossible de supprimer l\'admin principal' });
  }

  if (user.profileImage) {
    const imgPath = path.join(__dirname, user.profileImage);
    if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
  }

  await User.findByIdAndDelete(req.params.id);
  res.json({ message: 'Utilisateur supprimé' });
});

// ========================================
// ROUTES : UTILITAIRES
// ========================================

// Route pour obtenir l'IP et l'URL de base du serveur
app.get('/api/server-info', (req, res) => {
  console.log('\n=== INFO SERVEUR DEMANDÉE ===');
  console.log('IP du serveur:', SERVER_IP);
  console.log('URL de base:', BASE_URL);
  
  res.json({
    serverIp: SERVER_IP,
    baseUrl: BASE_URL,
    port: process.env.PORT || 5000,
    timestamp: new Date().toISOString()
  });
});

// ========================================
// DÉMARRAGE DU SERVEUR
// ========================================

const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log('\n========================================');
  console.log('🚀 SERVEUR DÉMARRÉ');
  console.log('========================================');
  console.log(`📍 Local: http://localhost:${PORT}`);
  console.log(`🌐 Réseau: ${BASE_URL}`);
  console.log(`🔗 IP détectée automatiquement: ${SERVER_IP}`);
  console.log('========================================');
  console.log('🔐 CONFIGURATION SÉCURITÉ:');
  console.log('   JWT_SECRET:', process.env.JWT_SECRET ? '✅ Défini (' + process.env.JWT_SECRET.length + ' caractères)' : '❌ NON DÉFINI');
  console.log('   JWT_REFRESH_SECRET:', process.env.JWT_REFRESH_SECRET ? '✅ Défini' : '❌ NON DÉFINI');
  console.log('========================================');
  console.log('📧 CONFIGURATION EMAIL:');
  console.log('   EMAIL_USER:', process.env.EMAIL_USER ? '✅ ' + process.env.EMAIL_USER : '❌ NON DÉFINI');
  console.log('   EMAIL_PASS:', process.env.EMAIL_PASS ? '✅ Défini' : '❌ NON DÉFINI');
  console.log('========================================');
  console.log('💾 CONFIGURATION DATABASE:');
  console.log('   MONGO_URI:', process.env.MONGO_URI ? '✅ Défini' : '❌ NON DÉFINI');
  console.log('========================================\n');
});