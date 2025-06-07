import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future addtorecwatched({required String uid,required String videoid,required String field,required data,})async{
  try{
    print(uid);
    await FirebaseFirestore.instance.collection('students').doc(uid).collection('recwatched').doc(videoid).set({field:data});
  }catch(e){
    print(e);
  }
}
Stream getdataforrecwatched({required uid})async*{
  List itembuilded=[];
  List newbuilded=[];
  final createdinstance=FirebaseFirestore.instance;
  try{
    final items= await createdinstance.collection('students').doc(uid).collection('recwatched').get();
    
    itembuilded=items.docs.toList();
  }catch(e){
    print(e);
  }
  try{
    for(var item in itembuilded){
      newbuilded.add(item.id);

    }
    yield* createdinstance.collection('videos').where(FieldPath.documentId, whereIn: newbuilded).snapshots();
  }catch(e){
    print(e);
  }
}