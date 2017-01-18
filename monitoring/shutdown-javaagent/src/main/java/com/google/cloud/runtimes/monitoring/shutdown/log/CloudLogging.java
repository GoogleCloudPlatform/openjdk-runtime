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

package com.google.cloud.runtimes.monitoring.shutdown.log;

import com.google.cloud.MonitoredResource;
import com.google.cloud.logging.LogEntry;
import com.google.cloud.logging.Logging;
import com.google.cloud.logging.LoggingException;
import com.google.cloud.logging.LoggingOptions;
import com.google.cloud.logging.Payload.StringPayload;
import com.google.cloud.logging.Severity;
import com.google.cloud.runtimes.monitoring.shutdown.config.LogConfig;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/** {@code logging} via Cloud logging : logs are buffered until flushed.
 **/
public class CloudLogging implements ILogging {

  private boolean initialized;
  private Logging logging;
  private final String logName;
  private final MonitoredResource monitoredResource;
  private final String logPrefix;
  private final Map<String, String> logLabels;
  private final LogBuffer logBuffer;
  private final Severity severity;

  /**
   * Configured using {@code LogConfig}.
   * @param config logging configuration
   */
  public CloudLogging(LogConfig config) {
    this.logName = config.getLogName();
    this.monitoredResource = MonitoredResource.newBuilder(config.getLoggingResourceType()).build();
    this.initialized = false;
    this.logPrefix = config.getLogPrefix();
    this.logLabels = config.getLogLabels();
    int maxLogBufferSize = config.getMaxLogPayloadSize();
    this.logBuffer = new LogBuffer(maxLogBufferSize);
    this.severity = config.getLogSeverity();
  }

  @Override
  public void initialize() {
    try {
      logging = LoggingOptions.getDefaultInstance().getService();
    } catch (Exception e) {
      logToStdErr(this.logPrefix + "Error initializing cloud logging service : " + e.getMessage());
    }
    initialized = (logging != null);
  }

  @Override
  public void log(String text) {
    if (validate(text)) {
      logBuffer.addLog(addPrefix(text));
    }
  }

  @Override
  public void flush() {
    List<LogEntry> logEntries = getLogEntries();
    if (!logEntries.isEmpty()) {
      if (!initialized) {
        logToStdErr(logEntries);
      } else {
        try {
          logging.write(logEntries);
        } catch (Exception e) {
          logToStdErr(logEntries);
        }
      }
      logEntries.clear();
    }
  }

  @Override
  public void logImmediately(String text) {
    if (validate(text)) {
      String logTextWithPrefix = addPrefix(text);
      if (!initialized) {
        logToStdErr(logTextWithPrefix);
        return;
      }
      LogEntry logEntry = createLogEntry(logTextWithPrefix);
      try {
        logging.write(Collections.singleton(logEntry));
      } catch (LoggingException e) {
        logToStdErr(text);
      }
    }
  }

  private LogEntry createLogEntry(String text) {
    return LogEntry.newBuilder(StringPayload.of(text))
        .setLogName(logName)
        .setResource(monitoredResource)
        .setLabels(logLabels)
        .setSeverity(severity)
        .build();
  }

  public void setLoggingAgent(Logging loggingAgent) {
    logging = loggingAgent;
    initialized = (logging != null);
  }

  public Logging getLoggingAgent() {
    return logging;
  }

  /** Log to standard err if logging service is not initialized. */
  public void logToStdErr(Collection<LogEntry> logEntries) {
    for (LogEntry logEntry : logEntries) {
      System.err.println(logEntry.getPayload().getData());
    }
  }

  public void logToStdErr(String text) {
    System.err.println(text);
  }

  private List<LogEntry> getLogEntries() {
    List<String> logChunks = logBuffer.getAndClearChunks();
    return logChunks.stream().map(this::createLogEntry).collect(Collectors.toList());
  }

  private String addPrefix(String text) {
    return logPrefix.concat(text);
  }

  private boolean validate(String text) {
    return (text != null && text.length() > 0);
  }
}
