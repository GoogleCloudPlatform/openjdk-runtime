package com.google.cloud.runtimes;

import static org.springframework.web.bind.annotation.RequestMethod.GET;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  @RequestMapping(path = "/", method = GET)
  public String hello() {
    return "Hello, world!";
  }


}
