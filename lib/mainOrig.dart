// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:another_telephony/telephony.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background/flutter_background.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:http/http.dart' as http;
//
// import 'location.dart';
//
//
//
// @pragma('vm:entry-point')
// void backgroundMessageHandler(SmsMessage message) async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//
//
//   //////////////////////////////////////////////////////////////////////////
//
//   String messageBody = message.body.toString();
//
//   List<String> words = messageBody.split(' ');
//
//   print(words);
//
//   if (words.length > 1) {
//     String firstWord = words[0];
//
//     if (firstWord == "emer") {
//
//       // await Future.delayed(Duration(seconds: 5));
//       //
//       // await AwesomeNotifications().createNotification(
//       //   content: NotificationContent(
//       //     id: 10, // Unique ID for the notification.  Change if you have multiple alarms.
//       //     channelKey: 'alarm_channel', // Make sure to match the channel key defined earlier
//       //     title: 'Emergency!', // Your alarm title
//       //     body: 'Emergency Alert!', // Your alarm body
//       //     category: NotificationCategory.Alarm, // Critical for Android full screen intent.
//       //     // wakeUpScreen: true, //  Critical for Android full screen intent.
//       //     // fullScreenIntent: true, // Critical for Android full screen intent.
//       //     // criticalAlert: true, //  Shows over DND.  Needs permission.
//       //     payload: {'navigate': 'LocationPage'}, // Add payload to indicate navigation
//       //   ),
//       // );
//
//       final telephony = Telephony.instance;
//
//       telephony.sendSms(to: "${message.address}", message: "MDRRMO: Message Received!!!");
//
//       sendLocationDataToAPI(words[1], words[2], words[3], words[4], words[5], words[6], words[7], words[8]);
//
//     }
//   }
//
//
//
// }
// ///////////////////////////////////////////////////////////////////////////////////////////
//
// Future<void> sendLocationDataToAPI(
//     emergency, lat, long, name, purok, barangay, mobile, position) async {
//   final Map<String, dynamic> requestBody = {
//     "emergency": emergency,
//     "lat": lat,
//     "long": long,
//     "purok": purok,
//     "barangay": barangay,
//     "name": name,
//     "mobile": mobile,
//     "position": position,
//   };
//
//   final response = await http.post(
//     Uri.parse('http://47.129.250.250/api/emergency?token=mySecretAlertifyToken2025'),
//     headers: {
//       "Content-Type": "application/json",
//     },
//     body: jsonEncode(requestBody),
//   );
//
//   if (response.statusCode == 201) {
//
//
//
//     print('Location back data sent to API successfully');
//
//
//
//   } else {
//     print(response.body);
//   }
// }
//
//
// /////////////////////////////////////////////////////////////////////////////////////
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//
//   // Initialize Awesome Notifications
//   AwesomeNotifications().initialize(
//       null, // App icon - replace with your actual icon.  `null` will use default app icon.
//       [
//         NotificationChannel(
//           channelKey: 'alarm_channel',
//           channelName: 'Emergency Notifications',
//           channelDescription: 'Notifications triggered by SMS',
//           defaultColor: const Color(0xFF9D50DD),
//           ledColor: Colors.white,
//           importance: NotificationImportance.Max,
//           locked: false, // Prevent swipe to dismiss when in foreground
//           defaultRingtoneType: DefaultRingtoneType.Notification,
//           playSound: true, // Ensure sound is enabled for the channel
//           soundSource: 'resource://raw/alarm', //Channel default sound
//           channelShowBadge: false,
//         )
//       ],
//       // Set right hand side icon
//       debug: true
//   );
//
//
//   // Request notification permissions (important!)
//   await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//     if (!isAllowed) {
//       AwesomeNotifications().requestPermissionToSendNotifications();
//     }
//   });
//
//
//   const androidConfig = FlutterBackgroundAndroidConfig(
//     notificationTitle: "Emergency App is running in background",
//     notificationText: "To ensure the alarm rings, please keep this notification enabled.",
//     notificationImportance: AndroidNotificationImportance.max,
//     notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'), // Use the app's launcher icon
//   );
//
//
//   final success = await FlutterBackground.initialize(androidConfig: androidConfig);
//   if (success) {
//     print('Flutter background service initialized successfully.');
//   } else {
//     print('Flutter background service initialization failed.');
//   }
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Alertify',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   bool _isRunningInBackground = false;
//   final telephony = Telephony.instance;
//   List<Emergency> emergencies = [];
//   bool isLoading = true;
//
//   late final AppLifecycleListener _lifecycleListener;
//
//   final ChangeStreamService _streamService = ChangeStreamService();
//   StreamSubscription? _streamSubscription;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     _listenForSmsMessages();
//
//     fetchEmergencies();
//     //
//     // AwesomeNotifications().setListeners(
//     //   onActionReceivedMethod: onActionReceivedMethod,
//     //   onNotificationCreatedMethod: onNotificationCreatedMethod,
//     //   onNotificationDisplayedMethod: onNotificationDisplayedMethod,
//     //   onDismissActionReceivedMethod: onDismissActionReceivedMethod,
//     // );
//
//     _lifecycleListener = AppLifecycleListener(
//       onResume: () {
//         if (mounted) {
//           fetchEmergencies();
//
//           _streamSubscription = _streamService.startListening().listen(
//                 (data) {
//               checkAndDisplayEmergency(data);
//
//             },
//
//           );
//         }
//       },
//     );
//
//
//     _streamSubscription = _streamService.startListening().listen(
//           (data) {
//
//         checkAndDisplayEmergency(data);
//
//       },
//       onError: (error) {
//         print('Stream error: $error');
//       },
//       onDone: () {
//         print('Stream closed');
//       },
//     );
//
//
//   }
//
//
//
//
//   @override
//   void dispose() {
//     _lifecycleListener.dispose(); // Properly dispose of the listener
//     // _streamService.stopListening(); // Clean up
//     super.dispose();
//   }
//
//
//   void checkAndDisplayEmergency(dynamic data) {
//     try {
//       // Always update state with new data
//       // if (mounted) {
//       //   setState(() {
//       //     fetchEmergencies();
//       //     _startAlarm();
//       //     debugPrint('Received data: $data');
//       //   });
//       // }
//
//       Map<String, dynamic> parsedData;
//       if (data is String) {
//         parsedData = jsonDecode(data) as Map<String, dynamic>;
//       } else {
//         parsedData = data as Map<String, dynamic>;
//       }
//
//       if (parsedData['fullDocument'] != null) {
//         String? emergencyType = parsedData['fullDocument']['emergency'] as String?;
//         if (emergencyType != null) {
//           print('Hello - Emergency type: $emergencyType');
//           switch (emergencyType) {
//
//             case 'Medical':
//               fetchEmergencies();
//               _startAlarm();
//
//               break;
//
//             case 'Flood':
//
//               fetchEmergencies();
//               _startAlarm();
//
//               break;
//
//             case 'Landslide':
//
//               fetchEmergencies();
//               _startAlarm();
//
//               break;
//
//             case 'Fire':
//
//               fetchEmergencies();
//               _startAlarm();
//
//               break;
//
//
//
//             default:
//               print('Unknown emergency type: $emergencyType');
//           }
//         }
//       }
//
//     } catch (e) {
//       print('Error processing emergency data: $e');
//     }
//   }
//
//
//   /// Called when the notification is created.  Useful for debugging.
//   static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
//     debugPrint('onNotificationCreatedMethod');
//   }
//
//   /// Called when a notification is displayed. Useful for debugging.
//   static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
//     debugPrint('onNotificationDisplayedMethod');
//   }
//
//   /// Called when user taps a notification or presses an action button.  Crucial logic!
//   static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
//     debugPrint('onActionReceivedMethod');
//     // Navigate to the NotificationPage using Navigator.pushNamed
//     MyApp.navigatorKey.currentState?.pushNamed('/notification_page', arguments: receivedAction);
//   }
//
//   /// Called when user dismisses a notification. Useful for analytics and optional actions.
//   static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
//     debugPrint('onDismissActionReceivedMethod');
//   }
//
//   Future<void> _startAlarm() async {
//
//     await Future.delayed(Duration(seconds: 5));
//
//     //  Schedule a notification with full screen intent and other configurations.  This is how you make it an alarm.
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 10, // Unique ID for the notification.  Change if you have multiple alarms.
//         channelKey: 'alarm_channel', // Make sure to match the channel key defined earlier
//         title: 'Emergency!', // Your alarm title
//         body: 'Emergency Alert!', // Your alarm body
//         category: NotificationCategory.Message, // Critical for Android full screen intent.
//         wakeUpScreen: true, //  Critical for Android full screen intent.
//         fullScreenIntent: true, // Critical for Android full screen intent.
//         criticalAlert: true, //  Shows over DND.  Needs permission.
//         payload: {'navigate': 'LocationPage'}, // Add payload to indicate navigation
//       ),
//     );
//     //
//     // Start background service (Android only) - to keep the alarm going.
//     if (Platform.isAndroid && !_isRunningInBackground) {
//       bool started = await FlutterBackground.enableBackgroundExecution();
//       if (started) {
//         setState(() {
//           _isRunningInBackground = true;
//         });
//         print('Background execution enabled.');
//       } else {
//         print('Failed to enable background execution.');
//       }
//     }
//   }
//
//
//
//   Future<void> _stopAlarm() async {
//     // Cancel the notification
//     await AwesomeNotifications().cancel(10); // Cancel notification with ID 10
//
//     // Stop the background service (Android only)
//     if (Platform.isAndroid && _isRunningInBackground) {
//       FlutterBackground.disableBackgroundExecution();
//       setState(() {
//         _isRunningInBackground = false;
//       });
//       print('Background execution disabled.');
//     }
//   }
//
//   Future<void> send2LocationDataToAPI(
//       emergency, lat, long, name, purok, barangay, mobile, position) async {
//     final Map<String, dynamic> requestBody = {
//       "emergency": emergency,
//       "lat": lat,
//       "long": long,
//       "purok": purok,
//       "barangay": barangay,
//       "name": name,
//       "mobile": mobile,
//       "position": position,
//     };
//
//     final response = await http.post(
//       Uri.parse('http://47.129.250.250/api/emergency?token=mySecretAlertifyToken2025'),
//       headers: {
//         "Content-Type": "application/json",
//       },
//       body: jsonEncode(requestBody),
//     );
//
//     if (response.statusCode == 201) {
//
//       fetchEmergencies();
//
//       print('successfully save emergency');
//
//     } else {
//       print(response.body);
//     }
//   }
//
//
//   Future<void> fetchEmergencies() async {
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final response = await http.get(Uri.parse('http://47.129.250.250/api/emergency'));
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> emergencyData = data['emergency_data'];
//       setState(() {
//         emergencies = emergencyData.map((json) => Emergency.fromJson(json)).toList();
//
//       });
//     } else {
//       throw Exception('Failed to load emergencies. Status code: ${response.statusCode}');
//     }
//     isLoading = false;
//   }
//
//
//
//
//   void _listenForSmsMessages() {
//
//     telephony.requestSmsPermissions;
//
//     telephony.listenIncomingSms(
//
//       onNewMessage: (SmsMessage message) {
//
//         String messageBody = message.body.toString();
//         List<String> words = messageBody.split(' ');
//
//         if (words.length > 1 && words[0] == 'emer') {
//
//           telephony.sendSms(to: "${message.address}", message: "MDRRMO: Message Received!");
//
//           _startAlarm();
//           send2LocationDataToAPI(words[1], words[2], words[3], words[4], words[5], words[6], words[7], words[8]);
//
//         }
//       },
//       listenInBackground: true,
//       onBackgroundMessage: backgroundMessageHandler,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Emergency Alert',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           backgroundColor: Colors.red,
//           actions: [
//             // IconButton(
//             //   icon: Icon(Icons.logout),
//             //   onPressed: () => _logout(context),
//             //   tooltip: 'Logout',
//             // ),
//           ],
//         ),
//         body: isLoading
//             ? const Center(
//           child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
//         )
//             : ListView.builder(
//           itemCount: emergencies.length,
//           itemBuilder: (context, index) {
//             final emergency = emergencies[index];
//             return Card(
//               elevation: 4.0,
//               margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//               child: InkWell(
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => LocationPage(
//                         emergency: emergency.emergency,
//                         latitude: emergency.lat,
//                         longitude: emergency.long,
//                         name: emergency.name,
//                         phone: emergency.mobile,
//                         purok: emergency.purok,
//                         barangay: emergency.barangay,
//                         position: emergency.position,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.red.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: const Icon(
//                           FontAwesomeIcons.circleInfo,
//                           size: 30,
//                           color: Colors.red,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Emergency: ${emergency.emergency}',
//                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
//                             ),
//                             const SizedBox(height: 8), // Add spacing
//                             Row(
//                               children: [
//                                 const Icon(
//                                   FontAwesomeIcons.person,
//                                   size: 16,
//                                   color: Colors.black45,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Purok: ${emergency.purok}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8), // Add spacing
//                             Row(
//                               children: [
//                                 const Icon(
//                                   FontAwesomeIcons.building,
//                                   size: 16,
//                                   color: Colors.black45,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Barangay: ${emergency.barangay}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//
//
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Icon(
//                         FontAwesomeIcons.locationArrow,
//                         size: 24,
//                         color: Colors.redAccent,
//                       ),
//
//
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),bottomNavigationBar: Container (
//       child: ElevatedButton(onPressed: () {
//
//       },child: Text('Powered by:'),),
//     )
//     );
//   }
// }
//
//
//
// class ChangeStreamService {
//   final String backendUrl = 'http://47.129.250.250/api/stream';
//   StreamSubscription? _subscription;
//
//   Stream<String> startListening() async* {
//     final request = http.Request('GET', Uri.parse(backendUrl));
//     request.headers['Accept'] = 'text/event-stream';
//     request.headers['Cache-Control'] = 'no-cache';
//
//     final response = await request.send();
//
//     if (response.statusCode == 200) {
//       print('Stream connected successfully');
//       // Convert the response stream to a String stream
//       await for (final data in response.stream.transform(utf8.decoder)) {
//         // Split the SSE data by newlines and process each event
//         final lines = data.split('\n');
//         for (final line in lines) {
//           if (line.startsWith('data: ')) {
//             yield line.substring(6); // Remove 'data: ' prefix
//           }
//         }
//       }
//     } else {
//       throw Exception('Failed to connect: ${response.statusCode}');
//     }
//   }
//
//   void stopListening() {
//     _subscription?.cancel();
//   }
// }
//
//
//
//
//
// class Emergency {
//   final String id;
//   final String emergency;
//   final String name;
//   final String purok;
//   final String barangay;
//   final String lat;
//   final String long;
//   final String mobile;
//   final String position;
//
//   Emergency({
//     required this.id,
//     required this.emergency,
//     required this.name,
//     required this.purok,
//     required this.barangay,
//     required this.lat,
//     required this.long,
//     required this.mobile,
//     required this.position,
//   });
//
//   factory Emergency.fromJson(Map<String, dynamic> json) {
//     return Emergency(
//       id: json['id'],
//       emergency: json['emergency'],
//       name: json['name'],
//       purok: json['purok'],
//       barangay: json['barangay'],
//       lat: json['lat'],
//       long: json['long'],
//       mobile: json['mobile'],
//       position: json['position'],
//     );
//   }
// }