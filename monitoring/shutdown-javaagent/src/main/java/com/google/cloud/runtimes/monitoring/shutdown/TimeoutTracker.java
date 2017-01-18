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

package com.google.cloud.runtimes.monitoring.shutdown;

import com.google.cloud.runtimes.monitoring.shutdown.log.ILogging;

/** A {@code Thread} to notify shutdown reporter thread of a time out.
 **/
public class TimeoutTracker extends Thread {

  private int timeoutInMillis;
  private ILogging logging;

  /**
   * Notify shutdown hook thread that time out period has elapsed.
   *
   * <p>Note : Does not terminate shutdown logging thread.
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
