import 'package:flutter/material.dart';
import 'package:lawtus/addingpage.dart';
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
  await FirebaseAuth.instance.signInAnonymously();
}catch(e){
  print(e);
}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Samsung'
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting)
          return CircularProgressIndicator();
          if(snapshot.hasData)
          return Homepage();
          return Signinpage();
        },
      ),
    );
  }
}