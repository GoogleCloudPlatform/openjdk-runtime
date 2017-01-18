/*
 * Copyright 2017 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.cloud.runtimes.monitoring.shutdown;

import com.google.cloud.runtimes.monitoring.shutdown.log.ILogging;

import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;
import java.util.List;

/** A {@code Thread} to log heap info, thread dump.
 **/
public class ShutdownReporter extends Thread {

  private static volatile boolean stopFlag;
  private static final int THREAD_INFO_AS_STR_STACK_TRACE_DEPTH = 8;
  private final boolean threadDumpEnabled;
  private final boolean heapInfoEnabled;
  private final TimeoutTracker timeOutTracker;
  private final ILogging logging;

  ShutdownReporter(
      boolean threadDumpEnabled, boolean heapInfoEnabled, int timeOutInMillis, ILogging logging) {
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
   * Logs usage stats of memory pools : Code Cache, Metaspace, Compressed Class Space, PS Eden Space
   * ,PS Survivor Space, PS Old Gen.
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

  /** Logs stack trace of all threads currently in the JVM. */
  public void logThreadDump() {
    try {
      ThreadMXBean threadMxBean = ManagementFactory.getThreadMXBean();
      StringBuilder sb = new StringBuilder("Thread dump\n");
      for (ThreadInfo ti : threadMxBean.dumpAllThreads(true, true)) {
        if (stopFlag) {
          logging.log(sb.toString());
          logging.flush();
          return;
        }
        getStackTraceLog(sb, ti);
        logging.log(sb.toString());
        sb.setLength(0);
      }
    } catch (Exception e) {
      logging.logImmediately("Thread dump error " + e.getMessage());
    }
  }

  public void startTimeTracker() {
    this.timeOutTracker.start();
  }

  /** Shutdown timeout tracker once shutdown tasks are complete. */
  public void interruptTimeTracker() {
    if (timeOutTracker.isAlive()) {
      timeOutTracker.interrupt();
    }
  }

  /** Set by timeout tracker : once set, shutdown reporter will try to exit as soon as possible. */
  public static void setStopFlag() {
    ShutdownReporter.stopFlag = true;
  }

  public static boolean getStopFlag() {
    return ShutdownReporter.stopFlag;
  }

  private void getStackTraceLog(StringBuilder sb, ThreadInfo threadInfo) {
    sb.append(threadInfo.toString());
    //ThreadInfo toString is limited to top 8 elements of stack trace
    StackTraceElement[] ste = threadInfo.getStackTrace();
    if (ste.length > THREAD_INFO_AS_STR_STACK_TRACE_DEPTH) {
      for (int element = THREAD_INFO_AS_STR_STACK_TRACE_DEPTH; element < ste.length; element++) {
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
