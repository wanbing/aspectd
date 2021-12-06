import 'package:aspectd/aspectd.dart';
// import 'package:flutter_function_monitor/flutter_function_monitor.dart';

/// 开始监控时间
var startTime = 0;

/// 函数总耗时
var totalCostTime = 0;

/// 函数信息
var allFunctions = <Map<dynamic, dynamic>>[];

@Aspect()
@pragma("vm:entry-point")
class FunctionCostMonitor {
  @Execute("package:flutter/src/scheduler/binding.dart", "SchedulerBinding",
      "-handleBeginFrame")
  @pragma("vm:entry-point")
  static dynamic onInjectStart(PointCut pointcut) {
    print('👉👉👉[开始计时]: Before handleBeginFrame!!!');
    startTime = DateTime.now().millisecondsSinceEpoch;
    totalCostTime = 0;
    allFunctions.clear();
    dynamic object = pointcut.proceed();
    return object;
  }

  @Execute("package:flutter/src/scheduler/binding.dart", "SchedulerBinding",
      "-handleDrawFrame")
  @pragma("vm:entry-point")
  static dynamic onInjectEnd(PointCut pointcut) {
    dynamic object = pointcut.proceed();
    var endTime = DateTime.now().millisecondsSinceEpoch;
    var timeCost = endTime - startTime;
    // FunctionMonitorInstance.functionContainer.checkAddFunctionData(timeCost, {
    //   'timestamp': endTime,
    //   'cost': timeCost,
    //   'functions': List.from(allFunctions)
    // });
    print('👉👉👉[结束计时]]: after handleDrawFrame!!!');
    print('👏👏👏检测时间:: $timeCost ms');
    print('👆👆👆方法累加时间:: $totalCostTime ms');
    return object;
  }
}

@Aspect()
@pragma("vm:entry-point")
class FunctionHook {
  @pragma("vm:entry-point")
  FunctionHook();

  @Execute("package:example\\/.+\\.dart", ".*", "-.+", isRegex: true)
  @pragma("vm:entry-point")
  dynamic hook(PointCut pointcut) {
    var start = DateTime.now().millisecondsSinceEpoch;
    dynamic result = pointcut.proceed();
    var end = DateTime.now().millisecondsSinceEpoch;
    var timeCost = end - start;
    totalCostTime += timeCost;

    // /// 添加函数信息
    // allFunctions.add({
    //   'function': '${pointcut.target} - ${pointcut.function}',
    //   'cost': timeCost
    // });
    print('👻👻👻 ${pointcut.target}-${pointcut.function}::方法耗时::$timeCost ms');
    return result;
  }
}
