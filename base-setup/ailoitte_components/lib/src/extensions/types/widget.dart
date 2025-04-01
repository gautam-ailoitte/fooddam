// import 'package:flutter/material.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:medguru/core/utils/app_colors.dart';

// extension WidgetFunction on Widget {
//   void dismissKeyboard() {
//     FocusManager.instance.primaryFocus?.unfocus();
//   }

//   void showSuccessToast({
//     required final BuildContext context,
//     required final String message,
//   }) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       // backgroundColor: AppColors.blackColor.withOpacity(.85),
//       fontSize: 14.0,
//     );
//   }

//   void showErrorToast({
//     required final BuildContext context,
//     required final String message,
//   }) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       // backgroundColor: AppColors.blackColor.withOpacity(.85),
//       fontSize: 14.0,
//     );
//   }

//   // void showProgressDialog(BuildContext context) {
//   //   showDialog(
//   //     barrierDismissible: false,
//   //     context: context,
//   //     builder: (context) {
//   //       return WillPopScope(
//   //           child: Center(
//   //             child: Container(
//   //               padding: const EdgeInsets.all(10),
//   //               decoration: BoxDecoration(
//   //                 //color: AppColors.white,
//   //                 borderRadius: BorderRadius.circular(4),
//   //               ),
//   //               height: 60,
//   //               width: 60,
//   //               child: const CircularProgressIndicator(
//   //                 strokeWidth: 2,
//   //               ),
//   //             ),
//   //           ),
//   //           onWillPop: () {
//   //             return Future.value(false);
//   //           });
//   //     },
//   //   );
//   // }

//   // void showDebugToast(
//   //     {required final BuildContext context, required final String message}) {
//   //   Fluttertoast.showToast(
//   //     msg: message,
//   //     //textColor: AppColors.white,
//   //     //backgroundColor: AppColors.app_color,
//   //     toastLength: Toast.LENGTH_LONG,
//   //     gravity: ToastGravity.BOTTOM,
//   //     fontSize: 16.0,
//   //   );
//   // }
// }
