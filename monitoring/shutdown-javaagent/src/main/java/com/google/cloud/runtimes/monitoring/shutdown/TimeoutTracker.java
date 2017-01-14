package com.google.cloud.runtimes.monitoring.shutdown;

import com.google.cloud.runtimes.monitoring.shutdown.log.ILogging;

public class TimeoutTracker extends Thread {

  private int timeoutInMillis;
  private ILogging logging;

  /**
   * Notify shutdown hook thread that time out period has elapsed.
   * Note : Does not terminate shutdown logging thread.
   */
  public TimeoutTracker(int timeoutInMillis, ILogging logging) {
    this.timeoutInMillis = timeoutInMillis;
    this.logging = logging;
    this.setName(this.getClass().getName());
  }

  @Override
  public void run() {
    boolean isInterrupted = false;
    try {
      Thread.sleep(timeoutInMillis);
    } catch (InterruptedException ex) {
      isInterrupted = true;
    } finally {
      ShutdownReporter.setStopFlag();
      if (!isInterrupted) {
        logging.logImmediately("Shutdown agent timed out");
      }
    }
  }
}

