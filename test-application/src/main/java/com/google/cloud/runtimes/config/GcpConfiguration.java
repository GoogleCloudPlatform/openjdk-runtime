package com.google.cloud.runtimes.config;

import com.google.cloud.logging.Logging;
import com.google.cloud.logging.LoggingOptions;
import com.google.cloud.monitoring.v3.MetricServiceClient;
import com.google.cloud.monitoring.v3.MetricServiceSettings;
import com.google.cloud.monitoring.v3.stub.MetricServiceStub;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;

import java.io.IOException;

import static com.google.cloud.ServiceOptions.getDefaultProjectId;

@Configuration
public class GcpConfiguration {

    @Bean
    @Lazy
    public Logging getLogging() {
        LoggingOptions options = LoggingOptions.getDefaultInstance();
        return options.getService();
    }

    @Bean(name = "metricServiceClient")
    @Lazy
    public MetricServiceClient getMetricServiceClient() throws IOException {
        return MetricServiceClient.create();
    }

    @Qualifier("projectId")
    @Bean
    public String getProjectId() {
        return getDefaultProjectId();
    }
}
