import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/internet_check_provider.dart';
import '../utils/Primary_text.dart';
import '../utils/constants.dart';
import 'customButton_white.dart';

class InternetChecker extends StatefulWidget {
  final Widget child;

  InternetChecker({required this.child});

  @override
  _InternetCheckerState createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listenToInternet(context);
  }

  void _listenToInternet(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InternetProvider>(context, listen: false);

      provider.addListener(() {
        if (!provider.isConnected && !provider.isDialogShown) {
          _showNoInternetDialog(context, provider);
        }
      });

    });
  }

  void _showNoInternetDialog(BuildContext context, InternetProvider provider) {
    provider.setDialogShown(true); // Mark dialog as shown

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kdialogColor,
          title: Column(
            children: [
              Icon(Icons.warning,color: kErrorColor,size: 50,),
              Text("No Internet Connection",style: CustomTextStyle.headingStyle(fontWeight: FontWeight.bold),),
            ],
          ),
          content: Text("Oops! It looks like you're offline. Please check your internet connection.",style:  CustomTextStyle.GeneralStyle(),),
          actions: [
            CustomButton_White(text: 'Retry', onTap: (){
              provider.setDialogShown(false); // Allow new dialogs
              Navigator.of(context).pop();
            })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // Return the original screen UI
  }
}
