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

package com.google.cloud.runtimes.monitoring.shutdown.config;

import java.util.HashMap;
import java.util.Map;

public class TestSysEnvironment extends SysEnvironment {

  private Map<String, String> env;

  public TestSysEnvironment() {
    env = new HashMap<>();
  }

  /**
   * Test environment : set environment variable values.
   *
   * @param prop Environment variable
   * @param value Value
   */
  public void set(String prop, String value) {
    env.put(prop, value);
  }

  /**
   * Test environment : remove environment variable.
   *
   * @param prop Property name
   */
  public void clear(String prop) {
    if (env.containsKey(prop)) {
      env.remove(prop);
    }
  }

  @Override
  public String get(String prop) {
    return env.get(prop);
  }
}
