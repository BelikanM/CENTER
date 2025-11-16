# Système de Notifications avec Badge et Scintillement

## Vue d'ensemble

Le système de notifications affiche le nombre de messages non lus sur l'icône de l'application avec :
- **Badge numérique** : Affiche le nombre de notifications (max 99+)
- **Effet de scintillement** : Animation pulsante sur le badge
- **Bordures lumineuses** : Scintillement des bordures de l'application tant que les messages ne sont pas lus

## Composants

### 1. AppProvider (main.dart)
Gère l'état global des notifications :
- `unreadMessagesCount` : Nombre de messages non lus
- `hasUnreadNotifications` : Boolean indiquant s'il y a des notifications
- `incrementUnreadMessages()` : Ajoute une notification
- `setUnreadMessagesCount(int count)` : Définit le nombre exact
- `clearUnreadMessages()` : Réinitialise les notifications

### 2. NotificationBadge (components/notification_badge.dart)
Widget réutilisable pour afficher un badge avec animation :
```dart
NotificationBadge(
  count: 5,
  showBadge: true,
  badgeColor: Colors.red,
  textColor: Colors.white,
  child: Icon(Icons.message),
)
```
- Animation de pulsation (scale: 1.0 → 1.2)
- Affiche "99+" si count > 99
- S'anime automatiquement quand showBadge = true

### 3. GlowingBorder (components/notification_badge.dart)
Widget pour ajouter un effet de scintillement lumineux :
```dart
GlowingBorder(
  isGlowing: true,
  glowColor: Color(0xFF00D4FF),
  borderRadius: 0,
  child: MainPage(),
)
```
- Double ombre avec effet de pulsation
- Bordure colorée animée
- Opacity variant de 0.3 à 1.0

### 4. NotificationWrapper (components/notification_wrapper.dart)
Wrapper principal qui :
- Écoute le WebSocket pour les nouveaux messages
- Met à jour automatiquement le compteur
- Applique l'effet GlowingBorder sur l'application entière

## Flux de Notifications

### Réception de messages
```
WebSocket message → NotificationWrapper
  ├─ new_message → incrementUnreadMessages()
  ├─ new_group_message → incrementUnreadMessages()
  ├─ new_comment → notification silencieuse
  ├─ new_publication → notification silencieuse
  └─ message_read → setUnreadMessagesCount(count - 1)
```

### Marquage comme lu
Quand l'utilisateur ouvre la page Social :
1. `didChangeAppLifecycleState` détecte l'entrée
2. `_markNotificationsAsRead()` est appelé
3. `clearUnreadMessages()` réinitialise le compteur
4. L'effet de scintillement s'arrête

## Intégration dans l'UI

### Barre de navigation (main_page.dart)
Le badge est appliqué sur l'icône "Social" :
```dart
BottomNavigationBarItem(
  icon: NotificationBadge(
    count: appProvider.unreadMessagesCount,
    showBadge: appProvider.hasUnreadNotifications,
    child: Icon(Icons.groups_rounded),
  ),
  label: 'Social',
),
```

### Application entière (main.dart)
Le GlowingBorder entoure toute l'application :
```dart
home: NotificationWrapper(
  child: MainPage(),
),
```

## Personnalisation

### Couleurs
- Badge : `Colors.red` (par défaut)
- Bordure : `Color(0xFF00D4FF)` (cyan)

### Animations
- Badge pulse : 800ms, scale 1.0 → 1.2
- Bordure glow : 1500ms, opacity 0.3 → 1.0

### Comportements
- Badge s'affiche si count > 0
- Animation démarre automatiquement
- S'arrête quand showBadge = false

## Tests

Pour tester le système :
1. Envoyer un message depuis un autre compte
2. Observer le badge apparaître sur l'icône Social
3. Observer les bordures de l'app scintiller
4. Ouvrir la page Social
5. Observer le badge et le scintillement disparaître

## Améliorations futures

- [ ] Notifications push natives
- [ ] Sons de notification
- [ ] Vibration
- [ ] Notifications persistantes dans la barre système
- [ ] Catégories de notifications (messages, likes, commentaires)
- [ ] Filtrage par priorité
