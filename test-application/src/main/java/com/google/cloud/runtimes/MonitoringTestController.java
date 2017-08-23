package com.google.cloud.runtimes;

import com.google.cloud.runtimes.stackdriver.StackDriverMonitoringService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Lazy;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.logging.Logger;

import static org.springframework.web.bind.annotation.RequestMethod.POST;

@RestController
public class MonitoringTestController {

    @Autowired
    @Lazy
    private StackDriverMonitoringService stackDriverMonitoringService;

    @Autowired
    @Qualifier("projectId")
    private String projectId;

    private static Logger LOG = Logger.getLogger(MonitoringTestController.class.getName());

    public static class MonitoringTestRequest {
        private String name;
        private Long token;

        public void setToken(Long token) {
            this.token = token;
        }

        public void setName(String name) {
            this.name = name;
        }

        @Override
        public String toString() {
            return "MonitoringTestRequest{" +
                    "name='" + name + '\'' +
                    ", token=" + token +
                    '}';
        }
    }

    @RequestMapping(path = "/monitoring", method = POST)
    public String handleMonitoringRequest(@RequestBody MonitoringTestRequest monitoringTestRequest) throws IOException, InterruptedException {
        LOG.info(String.valueOf(monitoringTestRequest));

        stackDriverMonitoringService.createMetricAndInsertTestToken(projectId,
                monitoringTestRequest.name,
                monitoringTestRequest.token);

        return "OK";
    }


}
