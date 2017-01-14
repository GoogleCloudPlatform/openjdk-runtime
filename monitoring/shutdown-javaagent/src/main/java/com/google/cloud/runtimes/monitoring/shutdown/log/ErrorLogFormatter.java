package com.google.cloud.runtimes.monitoring.shutdown.log;

import com.google.cloud.logging.Payload.JsonPayload;
import com.google.cloud.runtimes.monitoring.shutdown.ShutdownReporter;
import com.google.cloud.runtimes.monitoring.shutdown.config.AgentConfig;
import com.google.common.collect.ImmutableMap;

import java.util.HashMap;
import java.util.Map;

public class ErrorLogFormatter {

  private final ImmutableMap<String, Object> defaultMapEntries;

  public ErrorLogFormatter(AgentConfig config) {
    this.defaultMapEntries = initializeDefaultEntries(config);
  }

  /**
   * Construct json payload with default service and context.reportLocation
   * @param text Message string
   * @return json payload
   */
  public JsonPayload getJsonPayload(String text) {
    Map<String, Object> json = new HashMap<String, Object>();
    json.putAll(defaultMapEntries);
    json.put("message", text);
    return JsonPayload.of(json);
  }

  private Map<String, String> getServiceContext(AgentConfig config) {
    Map<String, String> serviceContext = new HashMap<>();
    serviceContext.put("service", config.getService());
    serviceContext.put("version", config.getVersion());
    return serviceContext;
  }

  private Map<String, String> getDefaultReportLocation() {
    Map<String, String> reportLocation = new HashMap<>();
    reportLocation.put("functionName", ShutdownReporter.class.getName());
    return reportLocation;
  }

  private ImmutableMap<String, Object> initializeDefaultEntries(AgentConfig config) {
    Map<String, Object> map = new HashMap<>();
    map.put("serviceContext", getServiceContext(config));
    Map<String, Object> context = new HashMap<>();
    context.put("reportLocation", getDefaultReportLocation());
    map.put("context", context);
    return ImmutableMap.copyOf(map);
  }
}
