package com.google.cloud.runtimes;

import com.google.api.Metric;
import com.google.cloud.monitoring.v3.MetricServiceClient;
import com.google.monitoring.v3.*;
import com.google.protobuf.util.Timestamps;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

import static com.google.cloud.ServiceOptions.getDefaultProjectId;
import static org.springframework.web.bind.annotation.RequestMethod.POST;

@RestController
public class MonitoringTestController {

    public static class MonitoringTestRequest {
        private String name;
        private Long token;

        public void setToken(Long token) {
            this.token = token;
        }

        public void setName(String name) {
            this.name = name;
        }
    }

    @RequestMapping(path = "/monitoring", method = POST)
    public String handleMonitoringRequest(@RequestBody MonitoringTestRequest monitoringTestRequest) throws IOException {
        MetricServiceClient.create()
                .createTimeSeries(
                        createTimeSeriesRequest(
                                getDefaultProjectId(),
                                monitoringTestRequest.name,
                                monitoringTestRequest.token));
        return "OK";
    }

    private CreateTimeSeriesRequest createTimeSeriesRequest(String projectId, String metricType, Long metricValue) {
        ProjectName projectName = ProjectName.create(projectId);
        Metric metric = Metric.newBuilder()
                .setType(metricType)
                .build();
        TimeInterval interval = TimeInterval.newBuilder()
                .setEndTime(Timestamps.fromMillis(System.currentTimeMillis()))
                .build();
        TypedValue pointValue = TypedValue.newBuilder()
                .setInt64Value(metricValue)
                .build();
        Point point = Point.newBuilder()
                .setInterval(interval)
                .setValue(pointValue)
                .build();
        TimeSeries timeSeries = TimeSeries.newBuilder()
                .setMetric(metric)
                .addPoints(point)
                .build();
        return CreateTimeSeriesRequest.newBuilder()
                .setNameWithProjectName(projectName)
                .addTimeSeries(timeSeries)
                .build();
    }

}
