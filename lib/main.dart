import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:another_telephony/telephony.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'imagepage.dart';
import 'location.dart';
import 'package:timeago/timeago.dart' as timeago;

// Global instance to access fetchEmergencies
_MyHomePageState? _homePageState;

@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  String messageBody = message.body.toString();
  List<String> words = messageBody.split(' ');
  final telephony = Telephony.instance;

  if (words.length > 1) {
    String firstWord = words[0];

    if (firstWord == "emer") {


      send2LocationDataToAPI(words[1], words[2], words[3], words[4], words[5],
          words[6], words[7], words[8], words[9], words[10], words[11]);


      telephony.sendSms(
          to: "${message.address}", message: "MDRRMO: Message Received!!!");

      _showNotification(flutterLocalNotificationsPlugin, 'Emergency', words[1]);
    }
  }
}

Future<void> send2LocationDataToAPI(
    emergency, lat, long, name, purok, barangay, munName, position, mobile, munId, provId) async {
  final Map<String, dynamic> requestBody = {
    "emergency": emergency,
    "lat": lat,
    "long": long,
    "name": name,
    "purok": purok,
    "barangay": barangay,
    "munName": munName,
    "position": position,
    "mobile": mobile,
    "munId": munId,
    "provId": provId
  };

  final response = await http.post(
    Uri.parse('https://qalert.uniall.tk/api/emergency?token=mySecretAlertifyToken2025'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 201) {
    print('Successfully saved emergency in background mode');
  } else {
    print(response.body);
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Notification Background message: ${message.notification?.body}");

  final notification = message.notification;

  if (notification != null) {
    await _showNotification(flutterLocalNotificationsPlugin, 'Emergency', "${message.notification?.body}");
    // Call fetchEmergencies if state exists
    if (_homePageState != null && _homePageState!.mounted) {
      await _homePageState!.fetchEmergencies();
    }
  } else {
    print("No notification or data payload received");
  }
}

Future<void> _showNotification(FlutterLocalNotificationsPlugin plugin, String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('emergency_channel','Emergency Alerts',
    channelDescription: 'Channel for emergency notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
    sound: RawResourceAndroidNotificationSound('alarm'),
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await plugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: body,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  await FirebaseMessaging.instance.requestPermission();

  if (Platform.isAndroid) {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted != true) {
        print("Notification permission not granted");
      }
    }
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");

  await FirebaseMessaging.instance.subscribeToTopic('presroxastoken2025');

  runApp(MyApp());

  setupForegroundNotifications();
}

Future<void> setupForegroundNotifications() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("Foreground message: ${message.notification?.body}");

    final notification = message.notification;

    if (notification != null) {
      await _showNotification(flutterLocalNotificationsPlugin, 'Emergency', "${message.notification?.body}");
      // Call fetchEmergencies if state exists
      if (_homePageState != null && _homePageState!.mounted) {
        await _homePageState!.fetchEmergencies();
      }
    } else {
      print("No notification or data payload received");
    }
  });
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alertify',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final telephony = Telephony.instance;
  List<Emergency> emergencies = [];
  bool isLoading = true;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _homePageState = this; // Set the global reference
    _listenForSmsMessages();
    fetchEmergencies();

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        if (mounted) {
          fetchEmergencies();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    if (_homePageState == this) {
      _homePageState = null; // Clear reference when disposing
    }
    super.dispose();
  }

  Future<void> fetchEmergencies() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://qalert.uniall.tk/api/emergency'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> emergencyData = data['emergency_data'];
      setState(() {
        emergencies = emergencyData.map((json) => Emergency.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load emergencies. Status code: ${response.statusCode}');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _listenForSmsMessages() {

    telephony.requestSmsPermissions;

    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        String messageBody = message.body.toString();
        List<String> words = messageBody.split(' ');

        if (words.length > 1 && words[0] == 'emer') {

          // print(words[1] + words[2]+ words[3] + words[4]
          //     + words[5] + words[6] + words[7] + words[8] + words[9] + words[10] + words[11]);


          await send2LocationDataToAPI(words[1], words[2], words[3], words[4],
              words[5], words[6], words[7], words[8], words[9], words[10], words[11]);

          await telephony.sendSms(to: "${message.address}", message: "MDRRMO: Message Received!");

          _showNotification(flutterLocalNotificationsPlugin, 'Emergency', words[1]);
        }
      },
      listenInBackground: true,
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Alert',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
      )
          : ListView.builder(
        itemCount: emergencies.length,
        itemBuilder: (context, index) {
          final emergency = emergencies[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LocationPage(
                      emergency: emergency.emergency,
                      latitude: emergency.lat,
                      longitude: emergency.long,
                      name: emergency.name,
                      phone: emergency.mobile,
                      purok: emergency.purok,
                      munName: emergency.munName,
                      munId: emergency.munId,
                      provId: emergency.provId,
                      photoURL: emergency.photoURL,
                      barangay: emergency.barangay,
                      position: emergency.position,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ImagePage(
                                  imageUrl: emergency.photoURL.isNotEmpty
                                      ? emergency.photoURL
                                      : 'https://example.com/default-image.jpg',
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            emergency.photoURL.isNotEmpty
                                ? emergency.photoURL
                                : 'https://example.com/default-image.jpg',
                            fit: BoxFit.cover,
                            height: 120,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 30,
                                color: Colors.grey[300],
                                child: const CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 34,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Incident: ${emergency.emergency}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.person,
                                size: 16,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Purok: ${emergency.purok}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.building,
                                size: 16,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Barangay: ${emergency.barangay}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.clock,
                                size: 16,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Time: ${timeago.format(DateTime.parse(emergency.createdAt))}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      FontAwesomeIcons.locationArrow,
                      size: 24,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Emergency {
  final String id;
  final String emergency;
  final String name;
  final String purok;
  final String barangay;
  final String lat;
  final String long;
  final String mobile;
  final String position;
  final String munName;
  final String munId;
  final String provId;
  final String photoURL;
  final String createdAt;

  Emergency({
    required this.id,
    required this.emergency,
    required this.name,
    required this.purok,
    required this.barangay,
    required this.lat,
    required this.long,
    required this.mobile,
    required this.position,
    required this.munName,
    required this.munId,
    required this.provId,
    required this.photoURL,
    required this.createdAt,
  });

  factory Emergency.fromJson(Map<String, dynamic> json) {
    return Emergency(
      id: json['id'],
      emergency: json['emergency'],
      name: json['name'],
      purok: json['purok'],
      barangay: json['barangay'],
      lat: json['lat'],
      long: json['long'],
      mobile: json['mobile'],
      position: json['position'],
      munName: json['munName'],
      munId: json['munId'],
      provId: json['provId'],
      photoURL: json['photoURL'],
      createdAt: json['createdAt'],
    );
  }
}