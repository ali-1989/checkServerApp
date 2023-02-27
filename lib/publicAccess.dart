import 'dart:io';
import 'package:assistance_kit/api/helpers/textHelper.dart';
import 'package:assistance_kit/api/logger/logger.dart';
import 'package:assistance_kit/dateSection/timeZone.dart';
import 'package:checkServerApp/app/pathNs.dart';
import 'package:checkServerApp/services/sms_kaveh.dart';

class PublicAccess {
  PublicAccess._();

  static late Logger logger;
  static final developerMobileNumber = '09139277303';
  static final adminMobileNumber = '09364299984';

  static bool isReleaseMode() {
    var isInReleaseMode = true;

    bool fn(){
      isInReleaseMode = false;
      return true;
    }

    assert(fn(), 'isInDebugMode_if_call');
    return isInReleaseMode;

    //return const bool.fromEnvironment('dart.vm.product');
  }

  static void logInDebug(dynamic txt) {
    if(!isReleaseMode()) {
      PublicAccess.logger.logToAll(txt);
    }
  }

  static Future<dynamic> loadAssets(String name, {bool asString = true}) async {
    var path = PathsNs.getAssetsDir() + Platform.pathSeparator + name;

    var file = File(path);
    var exist = await file.exists();

    if(exist){
      if(asString) {
        return file.readAsString();
      }
      else {
        return file.readAsBytes();
      }
    }
  }

  static void sendReportToDeveloper(String report) {
    try {
      report = TextHelper.subByCharCountSafe(report, 120);
      SmsKaveh.sendOtpGet(developerMobileNumber, report);
    }
    catch (e) {
      //Main.logToAll("!!! sendReportToDeveloper: " + e.toString(), true);
    }
  }

  static void sendReportToAdmin(String report) {
    try {
      report = TextHelper.subByCharCountSafe(report, 120);
      SmsKaveh.sendOtpGet(adminMobileNumber, report);
    }
    catch (e) {
      //Main.logToAll("!!! sendReportToDeveloper: " + e.toString(), true);
    }
  }

  static DateTime grtTehranTime(){
    return TimeZone.getDateTimeZoned('Asia/Tehran', dayLight: false);
  }
}