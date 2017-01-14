package com.google.cloud.runtimes.monitoring.shutdown;

import com.google.cloud.runtimes.monitoring.shutdown.log.ILogging;

import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;
import java.util.List;

public class ShutdownReporter extends Thread {

  private static volatile boolean stopFlag;
  private boolean threadDumpEnabled;
  private boolean heapInfoEnabled;
  private TimeoutTracker timeOutTracker;
  private ILogging logging;

  ShutdownReporter(boolean threadDumpEnabled, boolean heapInfoEnabled, int timeOutInMillis,
      ILogging logging) {
    this.threadDumpEnabled = threadDumpEnabled;
    this.heapInfoEnabled = heapInfoEnabled;
    this.timeOutTracker = new TimeoutTracker(timeOutInMillis, logging);
    this.logging = logging;
    stopFlag = false;
    this.setName(this.getClass().getName());
  }

  @Override
  public void run() {
    if (!(heapInfoEnabled || threadDumpEnabled)) {
      return;
    }
    initializeLogger();
    startTimeTracker();

    if (heapInfoEnabled) {
      logHeapInfo();
    }
    if (threadDumpEnabled) {
      logThreadDump();
    }
    logging.flush();
    interruptTimeTracker();
  }

  public void initializeLogger() {
    logging.initialize();
  }

  /**
   * Logs usage stats of memory pools :
   * Code Cache, Metaspace, Compressed Class Space,
   * PS Eden Space ,PS Survivor Space, PS Old Gen.
   */
  public void logHeapInfo() {
    StringBuilder stringBuilder = new StringBuilder("Heap info\n");
    List<MemoryPoolMXBean> pools = ManagementFactory.getMemoryPoolMXBeans();
    for (MemoryPoolMXBean pool : pools) {
      if (stopFlag) {
        logging.flush();
        return;
      }
      stringBuilder.append(pool.getName());
      stringBuilder.append(" : ");
      stringBuilder.append(pool.getUsage());
      stringBuilder.append("\n");
    }
    logging.log(stringBuilder.toString());
  }

  /**
   * Logs stack trace of all threads currently in the JVM.
   */
  public void logThreadDump() {
    try {
      ThreadMXBean threadMxBean = ManagementFactory.getThreadMXBean();
      StringBuilder sb = new StringBuilder("Thread dump\n");
      int threadCounter = 0;
      for (ThreadInfo ti : threadMxBean.dumpAllThreads(true, true)) {
        if (stopFlag) {
          logging.log(sb.toString());
          logging.flush();
          return;
        }
        getStackTraceLog(sb, ti);
        //batching up 128 threads (ad-hoc measure to batch without exceeding 100KB
        //logging meta+payload limit)
        if (++threadCounter % 128 == 0) {
          logging.log(sb.toString());
          sb.setLength(0);
        }
      }
      logging.log(sb.toString());
    } catch (Exception e) {
      logging.logImmediately("Thread dump error " + e.getMessage());
    }
  }

  public void startTimeTracker() {
    this.timeOutTracker.start();
  }

  /**
   * Shutdown timeout tracker once shutdown tasks are complete.
   */
  public void interruptTimeTracker() {
    if (timeOutTracker.isAlive()) {
      timeOutTracker.interrupt();
    }
  }

  public static void setStopFlag() {
    stopFlag = true;
  }

  public static boolean getStopFlag() {
    return stopFlag;
  }

  private void getStackTraceLog(StringBuilder sb, ThreadInfo threadInfo) {
    sb.append(threadInfo.toString());
    //ThreadInfo toString is limited to top 8 elements of stack trace
    StackTraceElement[] ste = threadInfo.getStackTrace();
    if (ste.length > 8) {
      for (int element = 8; element < ste.length; element++) {
        if (stopFlag) {
          logging.flush();
          return;
        }
        sb.append('\n');
        sb.append(ste[element].toString());
        sb.append('\n');
      }
    }
  }
}
