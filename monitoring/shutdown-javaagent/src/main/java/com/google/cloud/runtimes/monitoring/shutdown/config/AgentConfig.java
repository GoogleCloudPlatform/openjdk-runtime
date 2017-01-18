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

package com.google.cloud.runtimes.monitoring.shutdown.config;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/** {@code Configuration} for the Java agent {@code Agent}.
 **/
public class AgentConfig {

  private final String threadDumpEnvVar = "SHUTDOWN_LOGGING_THREAD_DUMP";
  private final String heapInfoEnvVar = "SHUTDOWN_LOGGING_HEAP_INFO";
  private final String threadDumpParam = "thread_dump";
  private final String heapInfoParam = "heap_info";
  private final String timeOutParam = "timeout";
  private final boolean threadDumpDefault = false;
  private final boolean heapInfoDefault = false;
  private final int timeOutDefaultInSeconds = 30;
  private final int timeOutMinInSeconds = 1;
  private final int timeOutMaxInSeconds = 60;
  private Map<String, String> params;
  private SysEnvironment env;
  private LogConfig logConfig;

  /**
   * Configure agent : environment variables override direct parameters.
   *
   * @param agentArgs direct parameters in format key1=value1;key2=value2
   * @param env Environment
   */
  public AgentConfig(String agentArgs, SysEnvironment env) {
    init(agentArgs, env);
  }

  public AgentConfig(String agentArgs) {
    this.env = new SysEnvironment();
    init(agentArgs, env);
  }

  public boolean isHeapInfoEnabled() {
    return getEnvVarWithDirectArgFallback(heapInfoEnvVar, heapInfoParam, heapInfoDefault);
  }

  public boolean isThreadDumpEnabled() {
    return getEnvVarWithDirectArgFallback(threadDumpEnvVar, threadDumpParam, threadDumpDefault);
  }

  public int getTimeOutInSeconds() {
    return getIntInRangeParam(
        timeOutParam, timeOutDefaultInSeconds, timeOutMinInSeconds, timeOutMaxInSeconds);
  }

  public boolean getHeapInfoDefault() {
    return heapInfoDefault;
  }

  public boolean getThreadDumpDefault() {
    return threadDumpDefault;
  }

  public int getTimeOutDefault() {
    return timeOutDefaultInSeconds;
  }

  public LogConfig getLogConfig() {
    return logConfig;
  }

  private void init(String agentArgs, SysEnvironment sysEnv) {
    params = parseParams(agentArgs);
    logConfig = new LogConfig(env);
    env = sysEnv;
  }

  private Map<String, String> parseParams(String agentArgs) {

    if (agentArgs == null || agentArgs.isEmpty()) {
      return Collections.emptyMap();
    }
    Map<String, String> cliArgMap = new HashMap<String, String>();
    String[] argPairs = agentArgs.split(";");
    for (String argPair : argPairs) {
      String[] keyValue = argPair.split("=");
      if (keyValue.length == 2) {
        cliArgMap.put(keyValue[0], keyValue[1]);
      }
    }
    return cliArgMap;
  }

  private int getIntInRangeParam(String param, int defaultValue, int min, int max) {
    String valueStr = getCliParam(param);
    int parsedInt;
    try {
      parsedInt = Integer.parseInt(valueStr);
      if (parsedInt < min || parsedInt > max) {
        parsedInt = defaultValue;
      }
    } catch (NumberFormatException e) {
      parsedInt = defaultValue;
    }
    return parsedInt;
  }

  private String getCliParam(String cliArgName) {
    return params.get(cliArgName);
  }

  private boolean getEnvVarWithDirectArgFallback(
      String envVarName, String cliArgName, boolean defaultValue) {
    boolean value = defaultValue;
    String valueStr = env.get(envVarName);
    if (valueStr == null) {
      valueStr = getCliParam(cliArgName);
    }
    if (valueStr != null) {
      String lowerCase = valueStr.toLowerCase();
      if (lowerCase.equals("true") || lowerCase.equals("false")) {
        value = Boolean.parseBoolean(lowerCase);
      }
    }
    return value;
  }
}
