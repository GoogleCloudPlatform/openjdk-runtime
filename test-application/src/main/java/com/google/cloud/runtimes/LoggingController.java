package com.google.cloud.runtimes;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

import com.google.cloud.logging.GaeFlexLoggingEnhancer;
import com.google.cloud.logging.LoggingHandler;

import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.logging.Logger;

@RestController
public class LoggingController {

  private final static Logger logger = Logger.getLogger(LoggingController.class.getName());

  public static class LoggingRequest {
    public String log_name;
    public String token;
  }

  @RequestMapping(path = "/logging", method = POST)
  public void post(@RequestBody LoggingRequest payload) {

    System.out.println(System.getenv("GAE_INSTANCE"));
    System.out.println(System.getenv("GAE_SERVICE"));
    System.out.println(System.getenv("GAE_VERSION"));

    // create log handler for the given log_name
    LoggingHandler loggingHandler = new LoggingHandler(payload.log_name, null, null,
        Collections.singletonList(new GaeFlexLoggingEnhancer()));
    LoggingHandler.addHandler(logger, loggingHandler);

    // send the token to stackdriver logging
    logger.severe("payload.token: " + payload.token);

    // remove the handler
    logger.removeHandler(loggingHandler);
  }

}
