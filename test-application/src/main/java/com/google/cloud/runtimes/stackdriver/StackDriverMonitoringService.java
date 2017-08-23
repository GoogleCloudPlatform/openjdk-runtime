package com.google.cloud.runtimes.stackdriver;

import com.google.api.Metric;
import com.google.api.MetricDescriptor;
import com.google.api.MonitoredResource;
import com.google.cloud.monitoring.v3.MetricServiceClient;
import com.google.cloud.monitoring.v3.stub.MetricServiceStub;
import com.google.cloud.runtimes.config.GcpConfiguration;
import com.google.monitoring.v3.*;
import com.google.protobuf.util.Timestamps;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.logging.Logger;

@Service
public class StackDriverMonitoringService {

    @Autowired
    private ApplicationContext applicationContext;

    @Value("${monitoring.write.retries}")
    private int maxRetries;
    private static Logger LOG = Logger.getLogger(StackDriverMonitoringService.class.getName());


    public void createMetricAndInsertTestToken(String projectId, String metricType, long metricValue) throws IOException {
        int retries = maxRetries;
        while (retries > 0) {
            try {
                CreateTimeSeriesRequest timeSeriesRequest = createTimeSeriesRequest(projectId, metricType, metricValue);
                getClient().createTimeSeries(timeSeriesRequest);
                LOG.info("Metric created with timeseries.");
                return;
            } catch (Exception e) {
                LOG.warning("error creating timeseries request, retrying..." + e.getClass() + ": " + e.getMessage());
                retries--;
                if (retries == 0) {
                    throw new IllegalStateException("Failed to store timeseries after " + maxRetries + " attempts! Last error:", e);
                }
            }
        }
    }

    /**
     * This pairs up with the @Lazy annotation on {@link GcpConfiguration#getMetricServiceClient()}.
     * As MetricServiceClient methods are all `final` and that breaks the "@Autowire @Lazy" combination,
     * this is the only way to wire this bean lazily.
     */
    private MetricServiceClient getClient() {
        return (MetricServiceClient) applicationContext.getBean("metricServiceClient");
    }

    private CreateTimeSeriesRequest createTimeSeriesRequest(String projectId, String metricType, Long metricValue) {
        LOG.info("Creating time series to insert token: " + metricValue);
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
                .setMetricKind(MetricDescriptor.MetricKind.GAUGE)
                .setResource(MonitoredResource.newBuilder().setType("global").build())
                .addPoints(point)
                .build();
        return CreateTimeSeriesRequest.newBuilder()
                .setNameWithProjectName(projectName)
                .addTimeSeries(timeSeries)
                .build();
    }


}
