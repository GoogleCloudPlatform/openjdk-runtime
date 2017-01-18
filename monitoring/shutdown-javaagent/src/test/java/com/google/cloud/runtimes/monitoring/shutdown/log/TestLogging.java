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

public class TestLogging implements ILogging {

  private StringBuilder logBuffer;

  public TestLogging() {
    this.logBuffer = new StringBuilder();
  }

  @Override
  public void initialize() {}

  @Override
  public void log(String text) {
    this.logBuffer.append(text);
  }

  public String clear() {
    String log = logBuffer.toString();
    logBuffer.setLength(0);
    return log;
  }

  @Override
  public void flush() {}

  @Override
  public void logImmediately(String text) {
    this.logBuffer.setLength(0);
    this.logBuffer.append(text);
  }
}
