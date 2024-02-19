import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBacgroundMessage(RemoteMessage message) async {
    print('${message.notification?.title}');
    print('${message.notification?.body}');
  }

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    _firebaseMessaging.subscribeToTopic('MainFeedPL');
    print('token: ${token}'); // This needs to be stored
    FirebaseMessaging.onBackgroundMessage(handleBacgroundMessage);
    FirebaseMessaging.onMessage.listen(handleBacgroundMessage);
  }
}