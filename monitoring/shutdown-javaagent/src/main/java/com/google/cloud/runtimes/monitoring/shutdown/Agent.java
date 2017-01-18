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

import com.google.cloud.runtimes.monitoring.shutdown.config.AgentConfig;
import com.google.cloud.runtimes.monitoring.shutdown.log.CloudLogging;
import com.google.cloud.runtimes.monitoring.shutdown.log.ILogging;

import java.lang.instrument.Instrumentation;
import java.security.AccessControlException;

/** A {@code Java agent} to log heap information and thread dump at JVM shutdown. Consumers must add
 * the shutdown-javaagent.jar to their classpath.
 */
public class Agent {

  public static volatile ShutdownReporter shutdownReporter;

  /**
   * Adds shutdown hook to java runtime to log heap info and stack trace.
   *
   * @param agentArgs : heap_info : true/false (default : true) stack_trace : true/false (default :
   *     false) time_out : integer (in seconds) (min : 1, max : 60, default : 30)
   */
  public static void premain(String agentArgs, Instrumentation instrumentation) {
    AgentConfig agentConfig = new AgentConfig(agentArgs);

    boolean isThreadDumpEnabled = agentConfig.isThreadDumpEnabled();

    boolean isHeapInfoEnabled = agentConfig.isHeapInfoEnabled();

    if (isThreadDumpEnabled || isHeapInfoEnabled) {
      int timeOutInSeconds = agentConfig.getTimeOutInSeconds();
      ILogging logging = new CloudLogging(agentConfig.getLogConfig());
      try {
        shutdownReporter =
            new ShutdownReporter(
                isThreadDumpEnabled, isHeapInfoEnabled, timeOutInSeconds * 1000, logging);
        Runtime.getRuntime().addShutdownHook(shutdownReporter);
        logging.logImmediately(
            getShutdownHookAddedMessage(isThreadDumpEnabled, isHeapInfoEnabled, timeOutInSeconds));
      } catch (AccessControlException e) {
        logging.logImmediately("JVM Shutdownhook blocked :" + e.getMessage());
      }
    }
  }

  private static String getShutdownHookAddedMessage(
      boolean isThreadDumpEnabled, boolean isHeapInfoEnabled, int timeOutInSeconds) {
    return "JVM shutdown hook added. Thread dump : "
        + isThreadDumpEnabled
        + ", Heap info : "
        + isHeapInfoEnabled
        + ", Time out in seconds : "
        + timeOutInSeconds
        + "\n";
  }
}
