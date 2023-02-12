
import 'dart:async';

import 'package:assistance_kit/dateSection/dateHelper.dart';
import 'package:assistance_kit/shellAssistance.dart';
import 'package:checkServerApp/rest_api/appHttpDio.dart';
import 'package:system_resources/system_resources.dart';

class appRunningChecker {
  Timer? timer;
  DateTime? lastHighLoadCpu;

  void startCheck(Duration dur){
    if(timer != null && timer!.isActive){
      return;
    }

    timer = Timer.periodic(dur, (timer) async {

      final js = <String, dynamic>{};
      js['request_zone'] = 'get_advertising_data';
      js['device_id'] = 'checker1';
      js['app_name'] = 'checker1';
      js['app_version_code'] = '20000';
      js['app_version_name'] = '2.0.0';

      final item = HttpItem();
      item.fullUrl = 'http://193.3.182.90:7436/graph-v1';
      item.method = 'POST';
      item.setResponseIsPlain();
      item.setBodyJson(js);

      final res = AppHttpDio.send(item);
      await res.response;

      if(!res.isOk){
        print('app is not correct running (REST api) :(    <---------  ${DateTime.now()}');
        restartServerApp();
        return;
      }

      _cpuLoad();
      //print('app is OK.');
    });
  }

  void restartSystem(){
    ShellAssistance.shell('reboot', []);
  }

  void restartServerApp(){
    ShellAssistance.shell('/bin/sh', ['/home/app/restart.sh']);
  }

  void _cpuLoad(){
    final cpu = SystemResources.cpuLoadAvg();

    if(cpu >= 0.7){
      if(lastHighLoadCpu == null){
        lastHighLoadCpu = DateTime.now().toUtc();
      }
      else {
        if (DateHelper.isPastOf(lastHighLoadCpu, Duration(minutes: 15))) {
          lastHighLoadCpu = null;
          print('app is not correct running (CPU load) :(    <---------  ${DateTime.now()}');
          restartServerApp();
        }
      }
    }
    else {
      lastHighLoadCpu = null;
    }
  }
}