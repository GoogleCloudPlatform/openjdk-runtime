/*
 * Copyright 2017 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
