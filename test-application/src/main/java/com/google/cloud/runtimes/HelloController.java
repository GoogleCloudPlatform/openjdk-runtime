package com.google.cloud.runtimes;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  @RequestMapping("/")
  public String get() {
    return "Hello, world!";
  }


}
