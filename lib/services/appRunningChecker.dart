import 'dart:async';

import 'package:assistance_kit/shellAssistance.dart';
import 'package:checkServerApp/publicAccess.dart';
import 'package:checkServerApp/rest_api/appHttpDio.dart';
import 'package:system_resources/system_resources.dart';

class appRunningChecker {
  Timer? _timer;
  DateTime? _lastHighLoadCpu;
  int restartCounter = 0;

  void startCheck(Duration dur){
    if(_timer != null && _timer!.isActive){
      return;
    }

    _timer = Timer.periodic(dur, (timer) async {

      final js = <String, dynamic>{};
      js['request_zone'] = 'get_advertising_data';
      js['device_id'] = 'checker1';
      js['app_name'] = 'vosate_zehn';
      js['app_version_code'] = '50009';
      js['app_version_name'] = '5.2.9';

      final item = HttpItem();
      item.fullUrl = 'http://193.3.182.90:7436/graph-v1';
      item.method = 'POST';
      item.setResponseIsPlain();
      item.setBodyJson(js);

      var res = AppHttpDio.send(item);
      await res.response;

      if(!res.isOk){
        print('app is not correct running (REST api)  wait for 5 sec and try again   <---------  ${PublicAccess.grtTehranTime()}');
        await Future.delayed(Duration(seconds: 5));

        res = AppHttpDio.send(item);
        await res.response;

        if(!res.isOk){
          print('app is not correct running (REST api) :(    <---------  ${PublicAccess.grtTehranTime()}');
          restartSystem();
          return;
        }
      }

      _cpuLoad();
    });
  }

  void _cpuLoad(){
    final cpu = SystemResources.cpuLoadAvg();

    if(cpu >= 0.8){
      if(_lastHighLoadCpu == null){
        _lastHighLoadCpu = DateTime.now();
      }
      else {
        if(restartCounter > 30){
          print(' (CPU high load long time) $restartCounter  :(    <---------  ${PublicAccess.grtTehranTime()}');
          restartCounter = 0;
          //restartSystem();
        }
        else {
          restartCounter++;
          print(' (CPU high load) $restartCounter  :(    <---------  ${PublicAccess.grtTehranTime()}');
        }
      }
    }
    else {
      _lastHighLoadCpu = null;
    }
  }

  void restartSystem(){
    ShellAssistance.shell('reboot', []);
  }

  void restartServerApp(){
    ShellAssistance.shell('/bin/bash', ['/home/app/restart.sh']);
  }
}