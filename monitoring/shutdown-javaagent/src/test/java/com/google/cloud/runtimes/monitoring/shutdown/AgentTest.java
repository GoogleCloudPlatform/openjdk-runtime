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

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import java.lang.reflect.Field;
import java.util.Map;

public class AgentTest {

  @Test
  public void shutdownReporterHookIsRegisteredAndIsSuccessfullyDeleted()
      throws NoSuchFieldException, ClassNotFoundException, IllegalAccessException {
    Class clazz = Class.forName("java.lang.ApplicationShutdownHooks");
    Field field = clazz.getDeclaredField("hooks");
    field.setAccessible(true);
    Thread shutdownLoggerHook = null;
    boolean removedHookStatus = false;

    @SuppressWarnings("unchecked")
    Map<Thread, Thread> hooks = (Map<Thread, Thread>) field.get(null);
    for (Thread hook : hooks.keySet()) {
      if (hook.getName().equals("com.google.cloud.runtimes.monitoring.shutdown.ShutdownReporter")) {
        shutdownLoggerHook = hook;
        removedHookStatus = Runtime.getRuntime().removeShutdownHook(shutdownLoggerHook);
        break;
      }
    }

    assertEquals(shutdownLoggerHook != null, true);
    assertEquals(removedHookStatus, true);
  }
}
