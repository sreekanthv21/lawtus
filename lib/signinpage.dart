import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  TextEditingController cont1=TextEditingController();
  TextEditingController cont2=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('lib/assets/image/2.png'),width: 150,),
              TextField(
                controller: cont1,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(255, 202, 202, 202),
                  filled: true,
                  
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none
                  )
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: cont2,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(255, 202, 202, 202),
                  filled: true,
                  
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none
                  )
                ),
              ),
              SizedBox(height: 30,),
              TextButton(
                onPressed: ()async {
                  try
                  {await FirebaseAuth.instance.signInWithEmailAndPassword(email: cont1.text, password: cont2.text);
                  cont1.clear();
                  cont2.clear();
                  }catch(e){
                    ScaffoldMessenger(child: SnackBar(content: Text('Not your brother')));
                  }
                },
                child: Text('Sign in',style: TextStyle(color: const Color.fromARGB(255, 255, 230, 0),fontWeight: FontWeight.bold,fontSize: 17),),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(183, 0, 0, 0)),
                  minimumSize: WidgetStatePropertyAll(Size(double.infinity,50)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)))
                ),

              )
              
            ],
          ),
        ),
      ),
    );
  }
}