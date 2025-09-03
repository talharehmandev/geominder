import 'package:fluttertoast/fluttertoast.dart';
import '../utils/constants.dart';

class Utils {
  /// isError false means it is a normal message and isError true means it is a error message
  void toastmessage({required String message,required bool isError}) {
    if (isError == false) {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: kToastColor,
          textColor:kTextWhiteColor,
          fontSize: 12.0);
    } else if (isError == true) {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: kErrorColor,
          textColor: kTextWhiteColor,
          fontSize: 12.0);
    }
  }
}
