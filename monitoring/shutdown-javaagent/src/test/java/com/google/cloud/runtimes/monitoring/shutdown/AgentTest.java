package com.google.cloud.runtimes.monitoring.shutdown;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import java.lang.reflect.Field;
import java.util.Map;

public class AgentTest {


  @Test
  public void hasRegisteredShutdownHook() throws NoSuchFieldException, ClassNotFoundException,
      IllegalAccessException {
    Thread shutdownLoggerHook = null;
    Class clazz = Class.forName("java.lang.ApplicationShutdownHooks");
    Field field = clazz.getDeclaredField("hooks");
    field.setAccessible(true);
    @SuppressWarnings("unchecked")
    Map<Thread, Thread> hooks = (Map<Thread, Thread>) field.get(null);
    for (Thread hook : hooks.keySet()) {
      if (hook.getName().equals("com.google.cloud.runtimes.monitoring.shutdown.ShutdownReporter")) {
        shutdownLoggerHook = hook;
        break;
      }
    }
    assertEquals(shutdownLoggerHook != null, true);
    assertEquals(Runtime.getRuntime().removeShutdownHook(shutdownLoggerHook), true);

  }
}
