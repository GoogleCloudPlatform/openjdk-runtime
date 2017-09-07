package com.google.cloud.runtimes;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.web.bind.annotation.RequestMethod.GET;

@RestController
public class DeploymentTokenController {

  @Value("${deployment.token}")
  private String deploymentToken;

  @RequestMapping(path = "/deployment.token", method = GET)
  public String deploymentToken() {
    return deploymentToken;
  }


}
