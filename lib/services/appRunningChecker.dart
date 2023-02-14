
import 'dart:async';

import 'package:assistance_kit/dateSection/dateHelper.dart';
import 'package:assistance_kit/shellAssistance.dart';
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
      js['app_name'] = 'checker1';
      js['app_version_code'] = '10000';
      js['app_version_name'] = '1.0.0';

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
      if(_lastHighLoadCpu == null){
        _lastHighLoadCpu = DateTime.now().toUtc();
      }
      else {
        if (DateHelper.isPastOf(_lastHighLoadCpu, Duration(minutes: 10))) {
          if(restartCounter > 2){
            restartSystem();
          }
          else {
            _lastHighLoadCpu = null;
            restartCounter++;
            print('app is not correct running (CPU load) $restartCounter  :(    <---------  ${DateTime.now()}');
            restartServerApp();
          }
        }
      }
    }
    else {
      _lastHighLoadCpu = null;
    }
  }
}