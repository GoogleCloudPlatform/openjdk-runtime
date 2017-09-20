package com.google.cloud.runtimes;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

@RestController
public class StandardLoggingTestController {

    private final static Logger LOG = LoggerFactory.getLogger(StandardLoggingTestController.class);

    private final static Map<String, Consumer<String>> LOG_MAP =
            new HashMap<String, Consumer<String>>() {{
                put("DEFAULT", LOG::info);
                put("DEBUG", LOG::debug);
                put("INFO", LOG::info);
                put("NOTICE", LOG::info);
                put("WARNING", LOG::warn);
                put("ERROR", LOG::error);
                put("CRITICAL", LOG::error);
                put("ALERT", LOG::error);
                put("EMERGENCY", LOG::error);
            }};


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
        LOG_MAP.get(standardLoggingTestRequest.level).accept(standardLoggingTestRequest.token);
        return "java.log";
    }



}
