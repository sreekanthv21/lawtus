import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawtus/provider.dart';
import 'package:lawtus/videopage.dart';
import 'package:provider/provider.dart';

class searchpage extends StatefulWidget {
  const searchpage({super.key});

  @override
  State<searchpage> createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {


  String fieldtext='';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 16,),
              TextField(
                autofocus: true,
                cursorColor: Color(0xFF7A0045),
                onChanged: (value) {
                  fieldtext=value;
                  setState(() {
                    
                  });
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 20),
                  hintText: 'Search lectures',
                  hintStyle: TextStyle(letterSpacing: 0,fontSize: 14,color: Color(0xFF78746D)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFBEBAB3)
                    ),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFBEBAB3)
                    ),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(left: 5,right: 16,),
                    child: SvgPicture.asset(
                      width: 24,
                      height: 24,
                      'lib/assets/icons/search.svg'
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              ValueListenableBuilder(
                valueListenable: context.read<generator2>().videoinfoUpdated,
                builder: (context, value, child) {
                  if(context.read<generator2>().isLoading==true){
                    return Center(child: CircularProgressIndicator());
                  }
                        
                  Map videos=context.read<generator2>().gotinfo;
                  List recwatchedinfo=context.read<generator2>().recwatchedinfo['recwatched'];
                  List filteredvids=[];
                  for(int i=0;i<videos.length;i++){
                    if((videos['${i+1}']['name'] as String).toLowerCase().contains(fieldtext.toLowerCase())||(videos['${i+1}']['subject'] as String).toLowerCase().contains(fieldtext.toLowerCase())){
                      filteredvids.add(videos['${i+1}']);
                    }
                  }
                  filteredvids=filteredvids.reversed.toList();    
                  return Expanded(
                    child: ListView.builder(
                      itemCount: filteredvids.length,
                      itemBuilder: (context, index) {
                        return LayoutBuilder(
                          builder: (context,constraints) {
                            double containerwidth=constraints.maxWidth;
                            if(fieldtext==''){
                              return SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: ()async {
                                  await Future.delayed(Duration(milliseconds: 450));
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>videopage(pathid: filteredvids[index]['pathid'], pathdir: filteredvids[index]['pathdir'], recwatchedinfo: recwatchedinfo, each: filteredvids[index])));
                                },
                                child: Container(                                      
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xFFCDCDCD)
                                    ),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:containerwidth*0.3,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: AspectRatio(
                                            aspectRatio: 16/10,
                                            child: ExtendedImage.network(
                                              
                                              fit: BoxFit.cover,
                                              'https://lawtusbackend.onrender.com/getimg?dir=${filteredvids[index]['img']}',
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(filteredvids[index]['name'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Color(0xFF3C3A36)),),
                                            SizedBox(height: 8,),
                                            Text(filteredvids[index]['subject'],style: TextStyle(color: Color(0xFF3C3A36),fontSize: 15),)
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10,)
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        );
                        
                      },
                    ),
                  );
                }
                 
              )
            ],
          ),
        ),
      ),
    );
  }
}