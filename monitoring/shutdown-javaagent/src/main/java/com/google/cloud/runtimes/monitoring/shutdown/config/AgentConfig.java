package com.google.cloud.runtimes.monitoring.shutdown.config;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class AgentConfig {

  private final Map<String, String> cliParams;
  private final SysEnvironment env;
  private final String threadDumpEnvVar = "SHUTDOWN_LOGGING_THREAD_DUMP";
  private final String heapInfoEnvVar = "SHUTDOWN_LOGGING_HEAP_INFO";
  private final String gaeInstanceEnvVar = "GAE_INSTANCE";
  private final String gaeServiceEnvVar = "GAE_SERVICE";
  private final String gaeVersionEnvVar = "GAE_VERSION";
  private final String threadDumpCliParam = "thread_dump";
  private final String heapInfoCliParam = "heap_info";
  private final String timeOutCliParam = "timeout";
  private final boolean threadDumpDefault = false;
  private final boolean heapInfoDefault = false;
  private final int timeOutDefaultInSeconds = 30;
  private final int timeOutMinInSeconds = 1;
  private final int timeOutMaxInSeconds = 60;
  private final String shutdownLogName = "app.shutdown";
  private final String logPrefix = "App Engine Flex VM Shutdown";
  private final String loggingResourceType = "gae_app";

  public AgentConfig(String agentArgs, SysEnvironment env) {
    this.cliParams = parseCliArgs(agentArgs);
    this.env = env;
  }

  public AgentConfig(String agentArgs) {
    this.cliParams = parseCliArgs(agentArgs);
    this.env = new SysEnvironment();
  }

  public boolean isHeapInfoEnabled() {
    return getEnvVarWithCliFallback(heapInfoEnvVar, heapInfoCliParam, heapInfoDefault);
  }

  public boolean isThreadDumpEnabled() {
    return getEnvVarWithCliFallback(threadDumpEnvVar, threadDumpCliParam, threadDumpDefault);
  }

  public int getTimeOutInSeconds() {
    return getIntegerCliParam(timeOutCliParam, timeOutDefaultInSeconds, timeOutMinInSeconds,
        timeOutMaxInSeconds);
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

  public String getLogName() {
    return shutdownLogName;
  }

  /**
   * Constructs mandatory agent log prefix.
   * @return log prefix string
   */
  public String getLogPrefix() {
    StringBuilder sb = new StringBuilder(logPrefix).append(" ");
    String instanceId = getInstanceId();
    if (instanceId != null) {
      sb.append("vm : ").append(instanceId).append("\n");
    }
    return sb.toString();
  }

  public String getLoggingResourceType() {
    return loggingResourceType;
  }

  /**
   * Returns log labels.
   * @return  labels (name -> value) map
   */
  public Map<String, String> getLogLabels() {
    Map<String, String> labels = new HashMap<>();
    Map<String, String> labelToEnvVar = getLogToEnvVar();
    for (Map.Entry<String, String> labelToEnvVarPair : labelToEnvVar.entrySet()) {
      String envVarValue = env.get(labelToEnvVarPair.getValue());
      if (envVarValue != null) {
        labels.put(labelToEnvVarPair.getKey(), envVarValue);
      }
    }
    return labels;
  }

  public String getInstanceId() {
    return env.get(gaeInstanceEnvVar);
  }

  public String getService() {
    return env.get(gaeServiceEnvVar);
  }

  public String getVersion() {
    return env.get(gaeVersionEnvVar);
  }

  private Map<String, String> getLogToEnvVar() {
    Map<String, String> logLabelsToEnvVar = new HashMap<>();
    logLabelsToEnvVar.put("instance_id", gaeInstanceEnvVar);
    return logLabelsToEnvVar;
  }

  private Map<String, String> parseCliArgs(String agentArgs) {

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

  private int getIntegerCliParam(String param, int defaultValue, int min, int max) {
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
    return cliParams.get(cliArgName);
  }

  private boolean getEnvVarWithCliFallback(String envVarName, String cliArgName,
      boolean defaultValue) {
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
