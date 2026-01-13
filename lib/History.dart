import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lawtus/provider.dart';
import 'package:lawtus/videopage.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class historypage extends StatefulWidget {
  const historypage({super.key});

  @override
  State<historypage> createState() => _historypageState();
}

class _historypageState extends State<historypage> {

  List filtereddocs=[];
  ValueNotifier filtereddocsupdated=ValueNotifier(true);
  void initState(){
    super.initState();
    filtereddocs=[];
  }

  Future fetchurl(localdir)async{
   
    final urlbulk=await http.get(
      Uri.parse('https://lawtusbackend.onrender.com/getsignedurl?dir=${localdir}')
    );
   
    
    return urlbulk.body;
  }

  void fetchinfo(filepaths)async{

    List pathseperated=[];
    for(var i in filepaths){
      pathseperated.add(i['path']);
    }
    

    try
    {final response=await http.post(
      Uri.parse('https://lawtusbackend.onrender.com/checkforfile'),
      body: jsonEncode({'filenames':pathseperated}),
      headers: {"Content-Type": "application/json"},
      
    );

    final recdocstemp= ((jsonDecode(response.body))['result'] as List).where((element){
      return element['exists']==true;
    }).toList();


    filtereddocs=recdocstemp.map((element){
      return (filepaths as List).firstWhere((element1){
        return element1['path']==element['filename'];
      });
    }).toList();
    filtereddocsupdated.value=!filtereddocsupdated.value;
    }catch(e){
      return;
    }

  }

  IconData iconreturn(String file){
   
    if(file.endsWith('.pdf')){
      return Icons.file_copy;
    }
    else if(file.endsWith('.jpeg')||file.endsWith('.jpg')||file.endsWith('.png')){
      return Icons.image;
    }
    return Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: generator2(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context,constraints) {
              final containerwidth=constraints.maxWidth;
              return RefreshIndicator.adaptive(
                backgroundColor: Colors.white,
                color: Color(0xFF7A0045),
                elevation: 0.5,
                displacement: 10,
                onRefresh: ()async {
                  setState(() {
                    
                  });
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Recently viewed',style: TextStyle(fontSize: 32,color: Color(0xFF333333),fontWeight: FontWeight.bold,letterSpacing: -1),),
                      ),
                      SizedBox(height: 20,),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ValueListenableBuilder(
                          valueListenable: context.read<generator2>().videoinfoUpdated,
                          builder: (context, value, child) {
                        
                            if(context.read<generator2>().isLoading){
                              return Center(child: CircularProgressIndicator());
                            }
                            Map videos={};
                            List recwatched=[];
                            List recdocstemp=[];
                        
                            videos= context.read<generator2>().gotinfo;
                            recwatched=context.read<generator2>().recwatchedinfo['recwatched']??[];
                            recdocstemp=context.read<generator2>().recwatchedinfo['recdocs']??[];
                            
                            fetchinfo(recdocstemp);

                          
                        
                            if(recwatched.isEmpty && recdocstemp.isEmpty){
                              return Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.history, size: 48, color: Color(0xFFBEBAB3)),
                                      SizedBox(height: 12),
                                      Text(
                                        'Nothing viewed yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF78746D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if(recwatched.isEmpty ){
                              return SizedBox.shrink();
                            }
                            //make a new list of videos of certain batch and recwatched
                            List filteredlistvideos=[];
                            List tillwatched=[];
                            for(int i=0;i<recwatched.length;i++){
                              videos.forEach(
                                (key,value){
                                  if(value['batch'].contains(Hive.box('user').get('batch')) && value['uuid']==recwatched[i]['uuid']){
                                    tillwatched.add(recwatched[i]['time']);
                                    filteredlistvideos.add(value);
                                  }
                                }
                              );
                            }
                            
                            
                          
                            return SizedBox(
                              height: containerwidth*0.7*(10/16)+55,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredlistvideos.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: index==filteredlistvideos.length-1?EdgeInsets.symmetric(horizontal: 20):EdgeInsets.only(left: 20),
                                    width: containerwidth*0.7,
                                    
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      enableFeedback: true,
                                      splashColor: Color(0xFFFFF5EE),
                                      highlightColor: Color(0xFFFFF5EE),
                                      onTap: () async{
                                        await Future.delayed(Duration(milliseconds: 450));
                                        HapticFeedback.mediumImpact();
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>videopage(each: filteredlistvideos[index],recwatchedinfo: recwatched,pathid: (filteredlistvideos[index]['pathid']),pathdir: (filteredlistvideos[index]['pathdir']),)));
                                      },
                                      
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 16/10,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: ExtendedImage.network(
                                                  fit: BoxFit.cover,
                                                  cache: false,
                                                  'https://lawtusbackend.onrender.com/getimg?dir=${filteredlistvideos[index]['img']}',
                                                  loadStateChanged: (state) {
                                                    switch(state.extendedImageLoadState){
                                                      case LoadState.loading:
                                                      return Center(child: SizedBox(width: 30,height: 30,child: CircularProgressIndicator(color: Color(0xFF7A0045),)));
                                                      case LoadState.completed:
                                                      return null;
                                                      case LoadState.failed:
                                                      return Center(child: Icon(Icons.error),);
                                                    }
                                                  },
                                                  
                                                
                                                ),
                                              ),
                                            ),
                                            
                                            SizedBox(height: 6,),
                                            LinearPercentIndicator(
                                              padding: EdgeInsets.all(0),
                                              lineHeight: 11,
                                              progressColor: Color(0xFF7A0045),
                                              backgroundColor: Color.fromARGB(255, 255, 220, 195),
                                              percent: tillwatched[index]/filteredlistvideos[index]['duration'],
                                              barRadius: Radius.circular(10),
                                            ),
                                            SizedBox(height: 3,),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(filteredlistvideos[index]['name'],style: TextStyle(fontSize: 16,color: Color(0xFF3C3A36)),),
                                            ),
                                            
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        ),
                      ),
                      SizedBox(height: 10,),
                      ValueListenableBuilder(
                        valueListenable: filtereddocsupdated,
                        builder: (context, value, child) {
                          if(filtereddocs.isEmpty){
                            return SizedBox.shrink();
                          }
                         
                          return Column(
                            children: List.generate(
                              filtereddocs.length,
                              (index){
                                
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                                  child: InkWell(
                                    splashColor: Color(0xFFFFF5EE),
                                    highlightColor: Color(0xFFFFF5EE),
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: ()async {
                                      String url ='';
                                      try{
                                        url=await fetchurl(filtereddocs[index]['path']);
                                      }catch(e){
                                        return;
                                      }
                                      if((filtereddocs[index]['name'] as String).endsWith('pdf'))
                                      {
                                        await Future.delayed(Duration(milliseconds: 300));
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Scaffold(
                                          appBar: AppBar(
                                            surfaceTintColor: Colors.white,
                                            shape: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                                            ),
                                            elevation: 0,
                                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                            title: Text(filtereddocs[index]['displayname'], style: TextStyle(color:const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 20),),
                                          ),
                                          backgroundColor: Colors.white,
                                          body: SafeArea(child: SfPdfViewer.network(url)),
                                        )));
                                      }
                                      if((filtereddocs[index]['name'] as String).endsWith('jpg') || (filtereddocs[index]['name'] as String).endsWith('jpeg') || (filtereddocs[index]['name'] as String).endsWith('png'))
                                      {
                                        await Future.delayed(Duration(milliseconds: 300));
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Scaffold(
                                        backgroundColor: Colors.white,
                                        appBar: AppBar(
                                          surfaceTintColor: Colors.white,
                                          shape: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                                          ),
                                          elevation: 0,
                                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                          title: Text(filtereddocs[index]['displayname'], style: TextStyle(color:const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 20),),
                                        ),
                                        body: SafeArea(
                                          child: PhotoView(
                                            imageProvider: NetworkImage(url),
                                          ),
                                        ),
                                      )));
                                    }
                                      
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Color(0xFFBEBAB3)
                                        )
                                      ),
                                      
                                      padding: EdgeInsets.symmetric(horizontal:15,vertical: 18 ),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Icon(iconreturn(filtereddocs[index]['name'])),
                                          SizedBox(width: 10,),
                                          Expanded(child: Text(filtereddocs[index]['displayname']))
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            )
                          );
                        }
                      )
                        
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}