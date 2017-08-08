package com.google.cloud.runtimes;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ExceptionController {

  static class ExceptionRequest {
    public String token;
  }

  @RequestMapping(path = "/exception", method = POST)
  public void exception(@RequestBody ExceptionRequest request) {
    // Print a stack trace to stdout. This should be automatically registered to stackdriver error
    // reporting.
    new RuntimeException("Sample runtime exception for testing. Token from test driver request: "
        + request.token).printStackTrace();
  }
}
