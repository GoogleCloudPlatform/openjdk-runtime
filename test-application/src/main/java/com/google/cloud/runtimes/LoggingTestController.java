package com.google.cloud.runtimes;

import com.google.cloud.MonitoredResource;
import com.google.cloud.logging.LogEntry;
import com.google.cloud.logging.Logging;
import com.google.cloud.logging.Payload;
import com.google.cloud.logging.Severity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

@RestController
public class LoggingTestController {

    @Autowired
    private Logging logging;
    @Autowired
    @Qualifier("projectId")
    private String projectId;

    private static Logger LOG = Logger.getLogger(LoggingTestController.class.getName());

    public static class LoggingTestRequest {
        private String level;
        private String log_name;
        private String token;

        public void setLevel(String level) {
            this.level = level;
        }

        public void setLog_name(String log_name) {
            this.log_name = log_name;
        }

        public void setToken(String token) {
            this.token = token;
        }


        @Override
        public String toString() {
            return "LoggingTestRequest{" +
                    "level='" + level + '\'' +
                    ", log_name='" + log_name + '\'' +
                    ", token='" + token + '\'' +
                    '}';
        }
    }

    @RequestMapping(path = "/logging_custom", method = POST)
    public String handleLoggingTestRequest(@RequestBody LoggingTestRequest loggingTestRequest) throws IOException, InterruptedException {
        LOG.info(String.valueOf(loggingTestRequest));

        List<LogEntry> entries = new ArrayList<>();
        Payload.StringPayload payload = Payload.StringPayload.of(loggingTestRequest.token);
        Severity severity = Severity.valueOf(loggingTestRequest.level);
        LogEntry entry = LogEntry.newBuilder(payload)
                .setSeverity(severity)
                .setLogName(loggingTestRequest.log_name)
                .setResource(MonitoredResource.newBuilder("global").build())
                .build();
        entries.add(entry);
        logging.write(entries);
        LOG.info("Log written to StackDriver: " + entries);
        return "OK";
    }


}
