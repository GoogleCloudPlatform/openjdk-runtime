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

import com.google.cloud.logging.Severity;

import java.util.HashMap;
import java.util.Map;

/** Logging {@code Configuration} for {@code CloudLogging}.
 **/
public class LogConfig {

  private final String gaeInstanceEnvVar = "GAE_INSTANCE";
  private final String gaeServiceEnvVar = "GAE_SERVICE";
  private final String gaeVersionEnvVar = "GAE_VERSION";
  private final String shutdownLogName = "app.shutdown";
  private final String logPrefix = "App Engine Flex VM Shutdown";
  private final String loggingResourceType = "gae_app";
  private final Severity loggingSeverity = Severity.DEBUG;
  private final SysEnvironment env;

  public LogConfig(SysEnvironment env) {
    this.env = env;
  }

  public String getLogName() {
    return shutdownLogName;
  }

  /**
   * Constructs mandatory agent log prefix.
   *
   * @return log prefix string
   */
  public String getLogPrefix() {
    StringBuilder sb = new StringBuilder(logPrefix).append(" ");
    String instanceId = getInstanceId();
    if (instanceId != null) {
      sb.append("vm : ").append(instanceId).append(" ");
    }
    return sb.toString();
  }

  public String getLoggingResourceType() {
    return loggingResourceType;
  }

  /**
   * Returns log labels.
   *
   * @return labels (name -> value) map
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

  // 100kb proto serialized metadata + payload -> assume 5kb meta, 2 bytes per char.
  public int getMaxLogPayloadSize() {
    return 1024 * 95 / 2;
  }

  public Severity getLogSeverity() {
    return loggingSeverity;
  }

  private String getInstanceId() {
    return env.get(gaeInstanceEnvVar);
  }

  private Map<String, String> getLogToEnvVar() {
    Map<String, String> logLabelsToEnvVar = new HashMap<>();
    logLabelsToEnvVar.put("instance_id", gaeInstanceEnvVar);
    logLabelsToEnvVar.put("service_id", gaeServiceEnvVar);
    logLabelsToEnvVar.put("version_id", gaeVersionEnvVar);
    return logLabelsToEnvVar;
  }
}
