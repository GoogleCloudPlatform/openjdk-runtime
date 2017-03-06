package com.google.cloud.runtimes;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

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
    // write the log message
    logger.info("payload.token from request: " + request.token);
  }

}
