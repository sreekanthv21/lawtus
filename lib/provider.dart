import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/adapters.dart';

class generator extends ChangeNotifier{

  static generator? _instance;

  generator._internal(this._uid,this._course);

  factory generator(String uid,String course){
    if(_instance==null){
      _instance= generator._internal(uid,course);
    }
    else{
      _instance=_instance;
    }
    if(_instance!.streaminitialised==false){
      _instance!.streamgetter();
    }
    return _instance!;
  }

  final _uid;
  final _course;

  bool streaminitialised=false;
  final ValueNotifier<bool> quizUpdated = ValueNotifier(false);

  StreamSubscription? sub2;
  List gotinfo=[];
  StreamSubscription? sub1;
  List studnetsnapshots=[];
  
  
  void streamgetter(){
    try{
      sub2=FirebaseFirestore.instance.collection('tests').where('show',isEqualTo: true).orderBy('endtime',descending: true).snapshots().listen((snapshot) {

        gotinfo=[];

        for(int i=0;i<snapshot.docs.length;i++){
          if(snapshot.docs[i].data()['batch'].contains(Hive.box('user').get('batch'))){
            print(i);
            gotinfo.add(snapshot.docs[i]);
          }
        }


        quizUpdated.value = !quizUpdated.value;
        notifyListeners();
      });

      sub1=FirebaseFirestore.instance.collection('students').doc(_uid).collection('tests').snapshots().listen(
      (snapshots){
        studnetsnapshots=snapshots.docs;  
        quizUpdated.value = !quizUpdated.value;
        notifyListeners();    
      }
    );
    streaminitialised=true;
    }catch(e){
      streaminitialised=false;
    }
  }

  void reset() {
    sub1?.cancel();
    sub2?.cancel();
    streaminitialised = false;
    _instance = null;
  }
}

class generator1 extends ChangeNotifier{

  static generator1? _instance;

  generator1._internal(this._course);

  factory generator1(String course){
    if(_instance==null){
      _instance= generator1._internal(course);
    }
    else{
      _instance=_instance;
    }
    if(_instance!.streaminitialised==false){
      _instance!.streamgetter();
    }
    return _instance!;
  }


  final _course;

  bool streaminitialised=false;
  final ValueNotifier<bool> alertinfoUpdated = ValueNotifier(false);


  Map locationinfo={};
  List subjectnameinfo=[];
  Map facultyinfo={};
  StreamSubscription? sub1;

  bool get isloading{
    if(hasbatchesloaded==true && hasfacultiesloaded==true){
      return false;
    }
    return false;
  }
  bool hasbatchesloaded=false;
  bool hasfacultiesloaded=false;
  
  void streamgetter()async{
    try{
      sub1=FirebaseFirestore.instance.collection('batches').where('batch',isEqualTo: _course ).snapshots().listen((snapshot) {
        locationinfo=snapshot.docs[0].data()['matloc'];
        subjectnameinfo=snapshot.docs[0].data()['subjects'];
        alertinfoUpdated.value = !alertinfoUpdated.value;
        hasbatchesloaded=true;
        notifyListeners();
      });
      
      final facultyinforaw=await FirebaseFirestore.instance.collection('faculties').get();
      facultyinfo=facultyinforaw.docs[0].data();
      alertinfoUpdated.value = !alertinfoUpdated.value;
      hasfacultiesloaded=true;
      notifyListeners();


      

    
    streaminitialised=true;
    }catch(e){
      streaminitialised=false;
    }
  }

  void reset() {
    sub1?.cancel();

    streaminitialised = false;
    _instance = null;
  }
}

class generator2 extends ChangeNotifier{

  static generator2? _instance;

  generator2._internal();

  factory generator2(){
    if(_instance==null){
      _instance= generator2._internal();
    }
    else{
      _instance=_instance;
    }
    if(_instance!.streaminitialised==false){
      _instance!.streamgetter();
    }
    return _instance!;
  }

  bool hasLoadedVideos = false;
  bool hasLoadedRecwatched = false;

  bool get isLoading => !(hasLoadedVideos && hasLoadedRecwatched);

  bool streaminitialised=false;
  final ValueNotifier<bool> videoinfoUpdated = ValueNotifier(false);


  Map gotinfo={};
  Map recwatchedinfo={};
  StreamSubscription? sub1;
  StreamSubscription? sub2;

  
  
  void streamgetter(){
    try{
      sub1=FirebaseFirestore.instance.collection('videos').doc('lawtusvids').snapshots().listen((snapshot) {
        gotinfo=snapshot.data()!;
        videoinfoUpdated.value = !videoinfoUpdated.value;
        hasLoadedVideos=true;
        notifyListeners();
      });
      sub2=FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).snapshots().listen((snapshot){
        recwatchedinfo=snapshot.data()!;
        videoinfoUpdated.value=!videoinfoUpdated.value;
        hasLoadedRecwatched=true;
        notifyListeners();
      });

    
    streaminitialised=true;
    }catch(e){
      streaminitialised=false;
    }
  }

  void reset() {
    sub1?.cancel();
    sub2?.cancel();
    streaminitialised = false;
    _instance = null;
  }
}

class generator3 extends ChangeNotifier{

  static generator3? _instance;

  generator3._internal();

  factory generator3(){
    if(_instance==null){
      _instance= generator3._internal();
    }
    else{
      _instance=_instance;
    }
    if(_instance!.streaminitialised==false){
      _instance!.streamgetter();
    }
    return _instance!;
  }

  bool isLoading=true;

  bool streaminitialised=false;
  final ValueNotifier<bool> recdocsinfoUpdated = ValueNotifier(false);


  List recdocsinfo=[];
  StreamSubscription? sub1;

  
  
  void streamgetter(){
    try{
      sub1=FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).snapshots().listen((snapshot) {
        if (snapshot.data() != null && snapshot.data()!.containsKey('recdocs')) {
          recdocsinfo = snapshot.data()!['recdocs'];
        } else {
          recdocsinfo = []; 
        }
        isLoading=false;
        recdocsinfoUpdated.value = !recdocsinfoUpdated.value;
        notifyListeners();
      });

    
    streaminitialised=true;
    }catch(e){
      streaminitialised=false;
    }
  }

  void reset() {
    sub1?.cancel();

    streaminitialised = false;
    _instance = null;
  }
}
