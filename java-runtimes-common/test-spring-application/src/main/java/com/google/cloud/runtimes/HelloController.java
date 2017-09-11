package com.google.cloud.runtimes;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.web.bind.annotation.RequestMethod.GET;

@RestController
public class HelloController {

  @RequestMapping(path = "/", method = GET)
  public String hello() {
    return "Hello World!";
  }


}
