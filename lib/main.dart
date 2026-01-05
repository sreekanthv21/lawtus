import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lawtus/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lawtus/signinpage.dart';
import 'firebase_options.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  try
{  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  
  
}catch(e){
  return;
}
  await Hive.initFlutter();
  await Hive.openBox('user');
  await Hive.openBox('answers');
  await Hive.openBox('time');

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        fontFamily: 'rubik',
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16,
            color: const Color.fromARGB(255, 0, 0, 0)
          ),
          bodyLarge: TextStyle(
            color: Colors.black
          )
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Color(0xFF7A0045),
          selectionColor: Color.fromARGB(255, 255, 208, 174)
        )
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.idTokenChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting)
          return Scaffold(body: Container(child: CircularProgressIndicator(),));
          if(snapshot.hasData)
          return Homepage();
          return Signinpage();
        },
      ),
    );
  }
}