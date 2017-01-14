package com.google.cloud.runtimes.monitoring.shutdown;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import com.google.cloud.runtimes.monitoring.shutdown.log.TestLogging;

import org.junit.Test;

public class ShutdownReporterTest {

  private TestLogging logging = new TestLogging();

  @Test
  public void doesNothingIfHeapInfoOrStackTraceNotEnabled() {
    ShutdownReporter shutdownReporter = spy(new ShutdownReporter(false, false, 10, logging));
    doNothing().when(shutdownReporter).startTimeTracker();
    doNothing().when(shutdownReporter).interruptTimeTracker();
    shutdownReporter.run();
    verify(shutdownReporter, times(0)).logHeapInfo();
    verify(shutdownReporter, times(0)).logThreadDump();
    verify(shutdownReporter, times(0)).startTimeTracker();
    verify(shutdownReporter, times(0)).interruptTimeTracker();
  }

  @Test
  public void heapInfoEnabled() {
    ShutdownReporter shutdownReporter = spy(new ShutdownReporter(false, true, 1, logging));
    doNothing().when(shutdownReporter).startTimeTracker();
    doNothing().when(shutdownReporter).interruptTimeTracker();
    shutdownReporter.run();
    verify(shutdownReporter, times(1)).logHeapInfo();
    verify(shutdownReporter, times(0)).logThreadDump();
    verify(shutdownReporter, times(1)).startTimeTracker();
    verify(shutdownReporter, times(1)).interruptTimeTracker();
    assertEquals(ShutdownReporter.getStopFlag(), false);
    String log = logging.clear();
    assertEquals(log.contains("Metaspace"), true);
  }

  @Test
  public void stackTraceEnabled() {
    ShutdownReporter shutdownReporter = spy(new ShutdownReporter(true, false, 1, logging));
    doNothing().when(shutdownReporter).startTimeTracker();
    doNothing().when(shutdownReporter).interruptTimeTracker();
    shutdownReporter.run();
    verify(shutdownReporter, times(0)).logHeapInfo();
    verify(shutdownReporter, times(1)).logThreadDump();
    verify(shutdownReporter, times(1)).startTimeTracker();
    verify(shutdownReporter, times(1)).interruptTimeTracker();
    assertEquals(ShutdownReporter.getStopFlag(), false);
    String log = logging.clear();
    assertEquals(log.length() > 0, true);
  }

  @Test
  public void timeOutTriggered() {
    ShutdownReporter shutdownReporter = spy(new ShutdownReporter(true, true, 1, logging));
    shutdownReporter.run();
    assertEquals(ShutdownReporter.getStopFlag(), true);
  }
}
