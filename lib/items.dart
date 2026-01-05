
import 'package:intl/intl.dart';
List filter=['Upcoming','Submitted','Missed'];

String convertteddate({required DateTime timestamp}){
  
  return '${timestamp.day}-${timestamp.month}-${timestamp.year}';
}
String converttedtime({required DateTime timestamp}){
  
  return DateFormat('hh:mm a').format(timestamp);
}

List icons=['lib/assets/icons/Home.svg','lib/assets/icons/Vector.svg','lib/assets/icons/library.svg','lib/assets/icons/Profile.svg'];
List buttonsinlecturepage=['Course','Materials'];
List optionabcd=['A','B','C','D'];

