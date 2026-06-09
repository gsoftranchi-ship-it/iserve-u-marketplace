import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';

// SCREENS
import 'screens/home/home_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/marketplace/led_display_page.dart';

// PROVIDERS / SERVICES
import 'screens/food_dining/food_services.dart';
import 'package:media_kit/media_kit.dart';
import 'features/notifications/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();


  // CLEAN WEB URLS
  usePathUrlStrategy();

  // GLOBAL ERROR HANDLER
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  try {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FCMService.initialize();



  } catch (e) {

    debugPrint(
      "Firebase Setup Error: $e",
    );
  }


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FoodService(),
        ),
      ],
      child: const IServeUApp(),
    ),
  );
}

class IServeUApp extends StatelessWidget {
  const IServeUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'iserve-u',

      // PREVENT WEB TEXT SCALING ISSUES
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A2540),
        ),

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0A2540),
        ),
      ),

      // DYNAMIC ROUTES
      onGenerateRoute: (settings) {
        final routeName = settings.name;

        if (routeName != null &&
            routeName.startsWith('/display/')) {

          final uri = Uri.parse(routeName);

          if (uri.pathSegments.length >= 2) {

            final siteName = uri.pathSegments[1];

            return MaterialPageRoute(
              builder: (_) => LEDDisplayPage(
                siteName: siteName,
              ),
            );
          }
        }

        return null;
      },

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {

  Future<DocumentSnapshot>? _userFuture;

  String _lastUserId = '';

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, authSnapshot) {

        // LOADING
        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // USER LOGGED IN
        if (authSnapshot.hasData) {

          final User user = authSnapshot.data!;
          FCMService.initialize();

          // RESET CACHE IF USER CHANGES
          if (_lastUserId != user.uid) {
            _lastUserId = user.uid;

            _userFuture = FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: _userFuture,

            builder: (context, userSnap) {

              // PROFILE LOADING
              if (userSnap.connectionState ==
                  ConnectionState.waiting) {

                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0A2540),
                    ),
                  ),
                );
              }

              // PROFILE ERROR
              if (userSnap.hasError) {

                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [

                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Unable to load profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            userSnap.error.toString(),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _userFuture = FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // DEFAULT ROLE
              String role = 'viewer';

              // USER DATA EXISTS
              if (userSnap.hasData &&
                  userSnap.data != null &&
                  userSnap.data!.exists) {

                final data = userSnap.data!.data()
                as Map<String, dynamic>?;

                role = data?['role'] ?? 'viewer';
              }

              return HomePage(
                userRole: role,
              );
            },
          );
        }

        // NOT LOGGED IN
        return const LoginPage();
      },
    );
  }
}