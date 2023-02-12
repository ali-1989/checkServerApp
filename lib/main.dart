import 'dart:async';
import 'dart:io';
import 'package:assistance_kit/api/generator.dart';
import 'package:assistance_kit/api/logger/logger.dart';
import 'package:assistance_kit/net/netHelper.dart';
import 'package:assistance_kit/api/system.dart';
import 'package:checkServerApp/app/pathNs.dart';
import 'package:checkServerApp/constants.dart';
import 'package:checkServerApp/publicAccess.dart';
import 'package:checkServerApp/services/appRunningChecker.dart';

void main(List<String> arguments) async {
  await runZonedGuarded(() async {
    try{
      PathsNs.init();
      PublicAccess.logger = Logger(PathsNs.getLogPath());
      await PublicAccess.logger.isPrepare();

      mainApp();
    }
    catch (e){
      final finder = Generator.generateIntId(5);
      PublicAccess.logger.logToAll('UNHANDLED EXCEPTION [finder: $finder]:: $e');
      //PublicAccess.sendReportToDeveloper('unhandled exception_$finder[${Constants.appName}]');
    }
  }, zonedGuardedCatch);
}

void mainApp() async {
  var startInfo = '''\n
    ====================================================================================
    ==== Name: ${Constants.appName}
    ====================================================================================
    start at: ${DateTime.now().toUtc()}  UTC | ${DateTime.now()}  Local
    execute path: ${PathsNs.getExecutePath()}
    current path: ${PathsNs.getCurrentPath()}
    Dart path: ${Platform.executable}
    Process: ${Platform.numberOfProcessors}
    OS: ${Platform.operatingSystem}  (${Platform.operatingSystemVersion})
    Locale: ${Platform.localeName}
    IPs: ${await NetHelper.getIps()}
    *ram*
    #######################################################################''';

  if (System.isLinux()) {
    MemoryInfo.initial();
    var ramInfo = 'RAM:  all: ${MemoryInfo.mem_total_mb} MB,   free: ${MemoryInfo.mem_free_mb} MB';
    ramInfo += '\n    SWAP:  all: ${MemoryInfo.swap_total_mb} MB,   free: ${MemoryInfo.swap_free_mb} MB';
    startInfo = startInfo.replaceFirst(r'*ram*', ramInfo);
  }
  else {
    startInfo = startInfo.replaceFirst('*ram*', '');
  }

  // ignore: unawaited_futures
  PublicAccess.logger.logToAll(startInfo);

  final cc = appRunningChecker();
  cc.startCheck(Duration(minutes: 1));

  // ignore: unawaited_futures
  PublicAccess.logger.logToAll('-------------| All things is Ok');
  codes();
}
///==============================================================================================
void zonedGuardedCatch(error, sTrace) {
  final finder = Generator.generateIntId(5);
  var txt = 'ZONED-GUARDED CAUGHT AN ERROR [finder: $finder]:: ${error.toString()}';

  if(PublicAccess.isReleaseMode()) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n**************************************** [END ZONED-GUARDED]';
  PublicAccess.logger.logToAll(txt);
  //PublicAccess.sendReportToDeveloper('zonedGuardedCatch_$finder[${Constants.appName}]');

  if(!PublicAccess.isReleaseMode()) {
    throw error;
  }
}
///==============================================================================================
void codes() async {
}
