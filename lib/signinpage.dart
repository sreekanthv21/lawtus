import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';


class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  TextEditingController cont1=TextEditingController();
  TextEditingController cont2=TextEditingController();
  final userbox=Hive.box('user');
  bool loading=false;

  Future signin()async{
    
    try
      {
      setState(() {
        loading=true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: '${cont1.text.trim()}@lawtus.com', password: cont2.text.trim());
      final snap= await FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).get();
      print(snap.data()!['name']);
      await userbox.put('username', snap.data()!['name']);
      await userbox.put('batch', snap.data()!['batch']);
      print('successfull ${FirebaseAuth.instance.currentUser!.uid}');
      print(userbox.get('username'));
      
      }on FirebaseAuthException catch(e){
        if(e.code=='channel-error'){
          showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              titlePadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(decoration: BoxDecoration(color: Color(0xFFFFF5EE),borderRadius: BorderRadius.vertical(top: Radius.circular(10))),padding: EdgeInsets.symmetric(vertical: 15),width: double.infinity,alignment: Alignment.center,child: Icon(Icons.error,size: 30,)),
              content: Container(padding: EdgeInsets.symmetric(vertical:10),width: double.infinity,child: Text("Can't reach servers",style: TextStyle(fontWeight: FontWeight.w600),),),

            );
          },
        );
        }
        else if(e.code=='invalid-email'){
          showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(decoration: BoxDecoration(color: Color(0xFFFFF5EE),borderRadius: BorderRadius.vertical(top: Radius.circular(10))),padding: EdgeInsets.symmetric(vertical: 15),width: double.infinity,alignment: Alignment.center,child: Icon(Icons.error,size: 30,)),
              content: Container(padding: EdgeInsets.symmetric(vertical: 10),width: double.infinity,child: Text("Invalid username",style: TextStyle(fontWeight: FontWeight.w600),),),

            );
          },
        );
        }
        else if(e.code=='wrong-password'){
          showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(decoration: BoxDecoration(color: Color(0xFFFFF5EE),borderRadius: BorderRadius.vertical(top: Radius.circular(10))),padding: EdgeInsets.symmetric(vertical: 15),width: double.infinity,alignment: Alignment.center,child: Icon(Icons.error,size: 30,)),
              content: Container(padding: EdgeInsets.symmetric(vertical:10),width: double.infinity,child: Text('Invalid password',style: TextStyle(fontWeight: FontWeight.w600),),),

            );
          },
        );
        }
        else if(e.code=='user-not-found'){
          showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(decoration: BoxDecoration(color: Color(0xFFFFF5EE),borderRadius: BorderRadius.vertical(top: Radius.circular(10))),padding: EdgeInsets.symmetric(vertical: 15),width: double.infinity,alignment: Alignment.center,child: Icon(Icons.error,size: 30,)),
              content: Container(padding: EdgeInsets.symmetric(vertical:10),width: double.infinity,child: Text('Invalid username and password',style: TextStyle(fontWeight: FontWeight.w600),),),

            );
          },
        );
        }
        else if(e.code=='invalid-credential'){
          showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Container(decoration: BoxDecoration(color: Color(0xFFFFF5EE),borderRadius: BorderRadius.vertical(top: Radius.circular(10))),padding: EdgeInsets.symmetric(vertical: 15),width: double.infinity,alignment: Alignment.center,child: Icon(Icons.error,size: 30,)),
              content: Container(padding: EdgeInsets.symmetric(vertical:10),width: double.infinity,child: Text('Invalid username and password',),),

            );
          },
        );
          
        }
        
        print(e.code);
        setState(() {
          loading=false;
          cont1.clear();
          cont2.clear();
        });
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: 500),content: Text('Error')));
      }
      finally{
        loading=false;
        
      }
  }

  

  @override
  Widget build(BuildContext context) {

    if(loading==true){
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF7A0045),

                ),
                SizedBox(height: 5,),
                Text('Signing In...')
              ],
            ),
          ),
        )
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context,constraints) {
          return ConstrainedBox(
            constraints:BoxConstraints(minHeight: constraints.minHeight),
            child: IntrinsicHeight(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF7A0045)
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              SizedBox(height: 50,),
                              Text('Sign in to your Account',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 32,color: Colors.white),),
                              SizedBox(height: 30,)
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 30,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Email',style: TextStyle(fontSize: 14,color: Color(0xFF6C7278)),)),
                            TextField(
                              cursorColor: const Color.fromARGB(255, 116, 116, 116),
                              controller: cont1,
                              decoration: InputDecoration(
                                
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Color(0xFFEDF1F3),
                                    width: 1
                                  )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 182, 183, 183),
                                    width: 1
                                  )
                                  
                                ),
                                
                                fillColor: const Color.fromARGB(255, 255, 255, 255),
                                filled: true,
                                
                              ),
                            ),
                            SizedBox(height: 20,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Password',style: TextStyle(fontSize: 14,color: Color(0xFF6C7278)))),
                            TextField(
                              cursorColor: const Color.fromARGB(255, 102, 102, 102),
                              controller: cont2,
                              obscureText: true,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Color(0xFFEDF1F3),
                                    width: 1
                                  )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 182, 183, 183),
                                    width: 1
                                  )
                                ),
                                
                              
                                fillColor: const Color.fromARGB(255, 255, 255, 255),
                                filled: true,
                                
                              ),
                            ),
                            SizedBox(height: 50,),
                            TextButton(
                              onPressed: ()async {
                                if(cont1.text==''|| cont2.text==''){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    backgroundColor: Color(0xFFFFF5EE),
                                    duration: Duration(milliseconds: 500),content: Align(alignment: Alignment.center,child: Text('Empty fields',style: TextStyle(color: Color(0xFF3C3A36)),))));
                                }
                                else
                                await signin();
                                
                              },
                              child: Text('Sign in',style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255),fontSize: 17),),
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(const Color(0xFF7A0045)),
                                minimumSize: WidgetStatePropertyAll(Size(double.infinity,60)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)))
                              ),
                                  
                            ),
                          ],
                        ),
                      ),
                    )
                    
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}