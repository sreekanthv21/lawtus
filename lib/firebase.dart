import 'package:cloud_firestore/cloud_firestore.dart';


Future addtorecwatched({required String uid,required String videoid,required String field,required data,})async{
  try{
    print(uid);
    await FirebaseFirestore.instance.collection('students').doc(uid).collection('recwatched').doc(videoid).set({field:data});
  }catch(e){
    print(e);
  }
}
Stream getdataforrecwatched({required uid, required stream})async*{
  
}