package com.google.cloud.runtimes.config;

import com.google.api.gax.core.CredentialsProvider;
import com.google.auth.Credentials;
import com.google.cloud.logging.Logging;
import com.google.cloud.monitoring.v3.MetricServiceClient;
import com.google.cloud.monitoring.v3.MetricServiceSettings;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.io.IOException;
import java.util.logging.Logger;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;

@Configuration
@Profile("mock-gcp")
public class MockGCPConfiguration {

    private final static Logger LOG = Logger.getLogger(MockGCPConfiguration.class.getName());

    @Bean
    public Logging getLogging() {
        Logging loggingMock = mock(Logging.class);
        doAnswer(invocationOnMock -> {
            LOG.warning("Mock-GCP setup, Logging.write will result in no side-effects!");
            return null;
        }).when(loggingMock).write(any());
        return loggingMock;
    }

    @Bean
    public MetricServiceClient getMetricServiceClient() throws IOException {
        //it would be great if MetricServiceClient wouldn't have the final modifier
        //in all the public methods - it makes it impossible to mock it nicely,
        //that's why we are relying on mocking the part that breaks: authentication
        MetricServiceSettings mockSettings = MetricServiceSettings.defaultBuilder()
                .setCredentialsProvider(() -> mock(Credentials.class))
                .build();
        return MetricServiceClient.create(mockSettings);
    }

    @Qualifier("projectId")
    @Bean
    public String getProjectId() {
        return "mock-project-id";
    }
}
