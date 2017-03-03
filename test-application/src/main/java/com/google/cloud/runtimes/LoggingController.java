package com.google.cloud.runtimes;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

import com.google.cloud.MonitoredResource;
import com.google.cloud.logging.GaeFlexLoggingEnhancer;
import com.google.cloud.logging.LoggingHandler;
import com.google.cloud.logging.LoggingHandler.Enhancer;
import java.util.Collections;
import java.util.logging.Logger;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LoggingController {

  private final static Logger logger = Logger.getLogger(LoggingController.class.getName());

  static class LoggingRequest {
    public String log_name;
    public String token;
  }

  @RequestMapping(path = "/logging", method = POST)
  public void logging(@RequestBody LoggingRequest request) {

    // Explicitly create and enhance the monitored resource. This is necessary because the
    // LoggingHandler does not do this automatically for non-default resourceTypes
    Enhancer gaeFlexEnhancer = new GaeFlexLoggingEnhancer();
    MonitoredResource.Builder resourceBuilder = MonitoredResource.newBuilder("gae_app");
    gaeFlexEnhancer.enhanceMonitoredResource(resourceBuilder);

    // create log handler for the given log_name
    LoggingHandler loggingHandler = new LoggingHandler(request.log_name, null,
        resourceBuilder.build(),
        Collections.singletonList(gaeFlexEnhancer));
    LoggingHandler.addHandler(logger, loggingHandler);

    // write the log message
    logger.info("payload.token from request: " + request.token);

    // remove the handler
    logger.removeHandler(loggingHandler);
  }

}
