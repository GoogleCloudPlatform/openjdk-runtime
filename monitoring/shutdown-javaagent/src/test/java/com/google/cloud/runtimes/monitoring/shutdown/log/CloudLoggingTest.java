package com.google.cloud.runtimes.monitoring.shutdown.log;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import com.google.cloud.logging.Logging;
import com.google.cloud.runtimes.monitoring.shutdown.config.LogConfig;
import com.google.cloud.runtimes.monitoring.shutdown.config.TestSysEnvironment;

import org.junit.Test;
import org.mockito.ArgumentMatchers;

public class CloudLoggingTest {

  private Logging logging = mock(Logging.class);
  private LogConfig logConfig = new LogConfig(new TestSysEnvironment());
  private CloudLogging cloudLogging = spy(new CloudLogging(logConfig));

  @Test
  public void logToStdErrIfCloudLoggingNotInitialized() {
    doNothing().when(cloudLogging).initialize();
    cloudLogging.logImmediately("text");
    assertEquals(cloudLogging.getLoggingAgent(), null);
    verify(cloudLogging, times(1)).logToStdErr(ArgumentMatchers.anyString());
  }

  @Test
  public void logMethodDoesNotImmediatelyWrite() {
    cloudLogging.setLoggingAgent(logging);
    cloudLogging.log("text");
    verify(logging, times(0)).write(any());
  }

  @Test
  public void logImmediatelyMethodImmediatelyWrites() {
    cloudLogging.setLoggingAgent(logging);
    cloudLogging.logImmediately("text");
    verify(logging, times(1)).write(any());
    verify(cloudLogging, times(0)).logToStdErr(ArgumentMatchers.anyString());
  }

  @Test
  public void flushWritesOutPendingLogsInSingleWrite() {
    cloudLogging.setLoggingAgent(logging);
    cloudLogging.log("text1");
    cloudLogging.log("text2");
    cloudLogging.flush();
    verify(logging, times(1)).write(ArgumentMatchers.anyList());
  }
}
