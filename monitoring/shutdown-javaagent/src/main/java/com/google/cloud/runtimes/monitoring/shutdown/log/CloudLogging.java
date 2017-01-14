package com.google.cloud.runtimes.monitoring.shutdown.log;

import com.google.cloud.MonitoredResource;
import com.google.cloud.logging.LogEntry;
import com.google.cloud.logging.Logging;
import com.google.cloud.logging.LoggingException;
import com.google.cloud.logging.LoggingOptions;
import com.google.cloud.runtimes.monitoring.shutdown.config.AgentConfig;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;


public class CloudLogging implements ILogging {

  private final ErrorLogFormatter errorLogFormatter;
  private final String logName;
  private Logging logging;
  private final MonitoredResource monitoredResource;
  private final Collection<LogEntry> logEntries;
  private boolean initialized;
  private final String logPrefix;
  private final Map<String, String> logLabels;

  /**
   * Instantiate logging via StackDriver
   * Maintains a buffered list of logEntry events till flush is called.
   */
  public CloudLogging(AgentConfig config) {
    this.errorLogFormatter = new ErrorLogFormatter(config);
    this.logName = config.getLogName();
    this.monitoredResource = MonitoredResource.newBuilder(config.getLoggingResourceType()).build();
    this.logEntries = new ArrayList<>();
    this.initialized = false;
    this.logPrefix = config.getLogPrefix();
    this.logLabels = config.getLogLabels();
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
      logEntries.add(createLogEntry(addPrefix(text)));
    }
  }

  @Override
  public void flush() {
    if (!logEntries.isEmpty()) {
      if (!initialized) {
        logToStdErr();
      } else {
        try {
          logging.write(logEntries);
        } catch (Exception e) {
          logToStdErr();
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
    return LogEntry.newBuilder(errorLogFormatter.getJsonPayload(text))
        .setLogName(logName)
        .setResource(monitoredResource)
        .setLabels(logLabels)
        .build();
  }

  public void setLoggingAgent(Logging loggingAgent) {
    logging = loggingAgent;
    initialized = (logging != null);
  }

  public Logging getLoggingAgent() {
    return logging;
  }

  /**
   * Log to standard err if logging service is not initialized.
   */
  public void logToStdErr() {
    for (LogEntry logEntry : logEntries) {
      System.err.println(logEntry.getPayload().getData());
    }
  }

  public void logToStdErr(String text) {
    System.err.println(text);
  }

  public int getLogEntriesSize() {
    return logEntries.size();
  }

  private String addPrefix(String text) {
    return logPrefix.concat(text);
  }

  private boolean validate(String text) {
    return (text != null && text.length() > 0);
  }
}
