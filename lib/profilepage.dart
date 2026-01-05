import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:lawtus/card.dart';

class profilepage extends StatefulWidget {
  const profilepage({super.key});

  @override
  State<profilepage> createState() => _profilepageState();
}

class _profilepageState extends State<profilepage> {

  void signout(){
    Future.delayed(Duration(milliseconds: 1000),(){
      FirebaseAuth.instance.signOut();
    });
    
  }

  void changepassword()async{
    try{
      showDialog(
        barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(onWillPop: ()async => false,child: Center(child: SizedBox(height: 40,width: 40,child: CircularProgressIndicator(color: Colors.white,))));
          },
        );
      final response=await http.post(
        Uri.parse('https://lawtusbackend.onrender.com/reset-pass'),
        headers: {
          "Content-Type": "application/json",  // 🔹 tell backend it's JSON
        },
        body: jsonEncode({
          'user':FirebaseAuth.instance.currentUser!.uid,
          'email':FirebaseAuth.instance.currentUser!.email,
        })
      );
      Navigator.pop(context);
   
      if(response.statusCode==200){

        if(jsonDecode(response.body)['success']==true)
       { 
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(width: double.infinity,alignment: Alignment.center,child: Text('Success',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(jsonDecode(response.body)['message'],style: TextStyle(fontWeight: FontWeight.w600),),
                ],
              ),

            );
          },
        );
       }
        else{
          showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(width: double.infinity,alignment: Alignment.center,child: Text('Failed',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(jsonDecode(response.body)['message'],style: TextStyle(fontWeight: FontWeight.w600),),
                ],
              ),

            );
          },
        );
        }
      }else{
       
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(width: double.infinity,alignment: Alignment.center,child: Text('Failed',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Server error",style: TextStyle(fontWeight: FontWeight.w600),),
                ],
              ),

            );
          },
        );
      }
      
    }catch(e){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(width: double.infinity,alignment: Alignment.center,child: Text('Failed',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Your request couldn't be processed",style: TextStyle(fontWeight: FontWeight.w600),)
                ],
              ),

            );
          },
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context,constraints) {
              final containerwidth=constraints.maxWidth;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Text('Profile',style: TextStyle(fontSize: 32,color: Color(0xFF333333),fontWeight: FontWeight.bold,letterSpacing: -1),),
                  SizedBox(height: 20,),
                  Center(child: SvgPicture.asset('lib/assets/image/profile-avtar.svg',width: containerwidth*0.4,color: Color(0xFF3C3A36),)),
                  SizedBox(height: 40,),
                  Container(
                  
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: WidgetStatePropertyAll(const Color.fromARGB(162, 224, 224, 224)),
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                      foregroundColor: WidgetStatePropertyAll(Color(0xFF3C3A36)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(width: 1,color: Color(0xFFBEBAB3)))),
                      minimumSize: WidgetStatePropertyAll(Size(double.infinity,70))
                    ),
                    onPressed: ()async {
                      await Future.delayed(Duration(milliseconds: 300));
                      dialogs(
                        context,
                        title: 'Confirmation',
                        content: 'Do you want to reset your password?',
                        buttontext: 'Proceed',
                        onpressfunc: () async{
                          Navigator.pop(context);
                          changepassword();
                        },
                      );
                    
                    },
                    child: Text('Change password',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17),),
                  ),
                ),
                SizedBox(height: 16,),
                Container(
                  
                  child: TextButton(
                    style: ButtonStyle(
                      
                      overlayColor: WidgetStatePropertyAll(const Color.fromARGB(162, 224, 224, 224)),
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                      foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 39, 39)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(width: 1,color: Color(0xFFBEBAB3)))),
                      minimumSize: WidgetStatePropertyAll(Size(double.infinity,70))
                    ),
                    onPressed: ()async {
                      await Future.delayed(Duration(milliseconds: 300));
                      dialogs(
                        context,
                        title: 'Confirmation',
                        content: 'Are you sure you want to log out?',
                        buttontext: 'Confirm',
                        onpressfunc: () async{
                          Navigator.pop(context);
                          await Hive.box('user').clear();
                          await Hive.box('answers').clear();
                          await Hive.box('time').clear();
                
                          
                          
                          
                            signout();
                        },
                      );
                      
                    },
                    child: Text('Log out',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17),),
                  ),
                )
                  
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}