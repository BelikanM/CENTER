# 🔔 Guide du Système de Badges de Notification

## Vue d'ensemble

Le système de badges de notification affiche le nombre de messages non lus à la fois dans l'application et sur l'icône de l'application sur l'écran d'accueil du téléphone.

## Fonctionnalités Implémentées

### 1. Badge sur l'Icône de Navigation (In-App)
- **Position** : Sur l'icône "Social" dans la barre de navigation en bas
- **Affichage** : Badge rouge animé avec effet de pulsation
- **Compteur** : Affiche le nombre exact jusqu'à 99, puis "99+" au-delà
- **Animation** : Effet de pulsation avec échelle 1.0→1.2

### 2. Badge sur l'Icône de l'Application (Écran d'accueil)
- **Position** : Sur l'icône de l'app parmi les autres applications du téléphone
- **Affichage** : Badge natif du système d'exploitation
- **Compteur** : Nombre de messages non lus
- **Persistance** : Le badge reste même quand l'app est fermée

### 3. Effet de Bordure Scintillante
- **Position** : Autour de tout l'écran de l'application
- **Affichage** : Bordure cyan brillante (#00D4FF)
- **Animation** : Effet de scintillement avec opacité 0.3→1.0
- **Condition** : Activé uniquement quand il y a des notifications non lues

## Flux de Fonctionnement

### Réception d'un Message
1. WebSocket reçoit un message `new_message` ou `new_group_message`
2. `NotificationWrapper` écoute le stream WebSocket
3. `AppProvider.incrementUnreadMessages()` est appelé
4. `NotificationService.updateAppBadge(count)` met à jour le badge de l'icône
5. Le badge in-app et la bordure scintillante s'affichent automatiquement

### Lecture des Messages
1. L'utilisateur ouvre la page Social
2. `SocialPage._markNotificationsAsRead()` est appelé dans `initState()`
3. `AppProvider.clearUnreadMessages()` réinitialise le compteur
4. `NotificationService.clearAppBadge()` retire le badge de l'icône
5. Le badge in-app et la bordure scintillante disparaissent

## Composants Techniques

### Fichiers Modifiés/Créés

#### 1. `lib/services/notification_service.dart`
- **Package** : `flutter_app_badger: ^1.5.0`
- **Méthodes clés** :
  - `updateAppBadge(int count)` : Met à jour le badge sur l'icône
  - `clearAppBadge()` : Retire le badge de l'icône
  - `initialize()` : Configure les notifications locales
  - `_checkNewNotifications()` : Polling des notifications serveur

#### 2. `lib/components/notification_badge.dart`
- Composant réutilisable pour afficher un badge avec animation
- Affiche le compteur avec "99+" pour valeurs >99
- Animation de pulsation (scale 1.0→1.2, 800ms)

#### 3. `lib/components/notification_wrapper.dart`
- Écoute le stream WebSocket pour les nouveaux messages
- Appelle `NotificationService` pour mettre à jour le badge natif
- Applique l'effet de bordure scintillante quand notifications présentes

#### 4. `lib/main.dart` - AppProvider
- **Champs ajoutés** :
  - `_unreadMessagesCount` : Compteur de messages non lus
  - `_hasUnreadNotifications` : Boolean pour état de notification
- **Méthodes ajoutées** :
  - `incrementUnreadMessages()` : Incrémente le compteur
  - `setUnreadMessagesCount(int count)` : Définit le compteur
  - `clearUnreadMessages()` : Réinitialise à 0

#### 5. `lib/pages/main_page.dart`
- Intégration de `NotificationBadge` sur l'icône Social
- Badge visible pour admin et non-admin

#### 6. `lib/pages/social_page.dart`
- Appelle `_markNotificationsAsRead()` à l'ouverture
- Efface le badge natif via `NotificationService`

### Packages Ajoutés

```yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  flutter_app_badger: ^1.5.0
```

### Permissions Android

Ajouté dans `android/app/src/main/AndroidManifest.xml` :
```xml
<!-- Permissions pour les badges d'icône (Samsung, HTC, Sony, Huawei, OPPO, etc.) -->
<uses-permission android:name="com.sec.android.provider.badge.permission.READ" />
<uses-permission android:name="com.sec.android.provider.badge.permission.WRITE" />
<uses-permission android:name="com.htc.launcher.permission.READ_SETTINGS" />
<uses-permission android:name="com.htc.launcher.permission.UPDATE_SHORTCUT" />
<uses-permission android:name="com.sonyericsson.home.permission.BROADCAST_BADGE" />
<uses-permission android:name="com.sonymobile.home.permission.PROVIDER_INSERT_BADGE" />
<uses-permission android:name="com.anddoes.launcher.permission.UPDATE_COUNT" />
<uses-permission android:name="com.majeur.launcher.permission.UPDATE_BADGE" />
<uses-permission android:name="com.huawei.android.launcher.permission.CHANGE_BADGE" />
<uses-permission android:name="com.oppo.launcher.permission.READ_SETTINGS" />
<uses-permission android:name="com.oppo.launcher.permission.WRITE_SETTINGS" />
<uses-permission android:name="android.permission.READ_APP_BADGE" />
```

## Compatibilité des Launchers

Le système est compatible avec :
- ✅ **Stock Android** (Pixel, Android One)
- ✅ **Samsung One UI** (Galaxy S, Note, A)
- ✅ **Xiaomi MIUI**
- ✅ **Huawei EMUI**
- ✅ **OPPO ColorOS**
- ✅ **Vivo FuntouchOS**
- ✅ **OnePlus OxygenOS**
- ✅ **Sony Xperia**
- ✅ **HTC Sense**
- ⚠️ **iOS** (nécessite configuration supplémentaire dans Info.plist)

**Note** : Sur certains launchers Android personnalisés, l'utilisateur peut devoir activer les badges dans les paramètres du launcher.

## Test de l'Implémentation

### Test sur Émulateur Android
```bash
cd "c:\Users\Admin\Pictures\DAT.ERT\ERT\flutterAPP\CENTER"
flutter run
```

### Test sur Appareil Physique
```bash
flutter run -d <device-id>
```

### Vérifier les Badges
1. Ouvrir l'application
2. Recevoir un nouveau message (via WebSocket)
3. **Vérifier in-app** : Badge rouge sur l'icône Social
4. **Mettre l'app en arrière-plan** (bouton Home)
5. **Vérifier l'écran d'accueil** : Badge rouge sur l'icône de l'app
6. Ouvrir l'app et aller sur Social
7. **Vérifier** : Badge disparu de l'icône de l'app

### Logs de Débogage
```
🔔 Message WebSocket reçu: new_message
📬 Nouveau message - Total non lus: 1
🔴 Badge mis à jour sur l'icône de l'app: 1
✅ Notifications marquées comme lues et badge effacé
✅ Badge effacé de l'icône de l'app
```

## Limitations Connues

### Package Discontinué
- `flutter_app_badger` est marqué comme "discontinued" mais reste fonctionnel
- Alternatives futures : Package natif ou implémentation platform-specific

### Émulateurs
- Les badges d'icône ne fonctionnent pas toujours correctement sur émulateurs
- **Recommandation** : Tester sur appareil physique réel

### Launchers Non-Standards
- Certains launchers tiers peuvent ne pas supporter les badges
- L'utilisateur peut devoir activer manuellement dans les paramètres

### iOS
- Configuration supplémentaire requise dans `ios/Runner/Info.plist`
- Doit être testé sur appareil iOS physique (pas simulateur)

## Dépannage

### Le Badge n'Apparaît Pas sur l'Icône

1. **Vérifier les permissions** : AndroidManifest.xml contient toutes les permissions
2. **Vérifier le launcher** : Certains launchers nécessitent activation manuelle
3. **Vérifier les logs** :
   ```
   🔴 Badge mis à jour sur l'icône de l'app: X
   ```
4. **Tester sur appareil réel** : Les émulateurs ont un support limité

### Le Badge ne Disparaît Pas

1. **Vérifier l'appel** : `clearAppBadge()` est appelé dans `social_page.dart`
2. **Vérifier les logs** :
   ```
   ✅ Badge effacé de l'icône de l'app
   ```
3. **Forcer l'effacement** :
   ```dart
   await FlutterAppBadger.removeBadge();
   ```

### Badge Non Supporté

Si `FlutterAppBadger.isAppBadgeSupported()` retourne `false` :
```
⚠️ Badges non supportés sur cet appareil
```
- Vérifier le modèle de téléphone et le launcher
- Consulter la documentation du launcher pour activer les badges

## Améliorations Futures

1. **Notifications Push Natives** :
   - Intégrer Firebase Cloud Messaging (FCM)
   - Envoyer notifications même quand l'app est fermée

2. **Badges par Catégorie** :
   - Badge séparé pour messages, likes, commentaires
   - Couleurs différentes selon le type

3. **Paramètres Utilisateur** :
   - Permettre désactivation des badges
   - Choisir les types de notifications à afficher

4. **Support iOS Complet** :
   - Configuration Info.plist
   - Test sur appareils iOS

5. **Alternative au Package Discontinué** :
   - Implémentation native via MethodChannel
   - Package communautaire plus récent

## Références

- [flutter_app_badger Documentation](https://pub.dev/packages/flutter_app_badger)
- [flutter_local_notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Android App Badges Guide](https://developer.android.com/develop/ui/views/notifications/badges)
