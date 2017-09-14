package com.google.cloud.runtimes;

import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

@RestController
public class StandardLoggingTestController {

    private static Logger LOG = Logger.getLogger(StandardLoggingTestController.class.getName());

    public static class StandardLoggingTestRequest {
        private String level;
        private String token;

        public void setLevel(String level) {
            this.level = level;
        }

        public void setToken(String token) {
            this.token = token;
        }

        @Override
        public String toString() {
            return "StandardLoggingTestRequest{" +
                    "level='" + level + '\'' +
                    ", token='" + token + '\'' +
                    '}';
        }
    }

    @RequestMapping(path = "/logging_standard", method = POST)
    public String handleStandardLoggingTestRequest(@RequestBody StandardLoggingTestRequest standardLoggingTestRequest) throws IOException, InterruptedException {
        LOG.info("Received: " + String.valueOf(standardLoggingTestRequest));
        LOG.log(Level.parse(standardLoggingTestRequest.level), standardLoggingTestRequest.token);
        return "appengine.googleapis.com%2Fstdout";
    }


}
