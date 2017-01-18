package com.google.cloud.runtimes.monitoring.shutdown.log;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import java.util.List;

public class LogBufferTest {

  @Test
  public void textUnderSizeLimitOnlyAddsToBuffer() {
    LogBuffer logBuffer = new LogBuffer(20);
    String log = "this is a test";
    logBuffer.addLog(log);
    assertEquals(logBuffer.getBufferSize(), log.length());
    assertEquals(logBuffer.getChunksSize(), 0);
    List<String> chunks = logBuffer.getAndClearChunks();
    assertEquals(chunks.get(0), log);
    assertEquals(logBuffer.getChunksSize(), 0);
    assertEquals(logBuffer.getBufferSize(), 0);
  }

  @Test
  public void textIsSplitAroundNewLinesWhenLargerThanBufferSize() {
    LogBuffer logBuffer = new LogBuffer(30);
    String log = "this is a logging test\nlogging works\nline 1\nline 2";
    logBuffer.addLog(log);
    assertEquals(logBuffer.getBufferSize(), "logging works\nline 1\nline 2".length());
    assertEquals(logBuffer.getChunksSize(), 1);
    List<String> chunks = logBuffer.getAndClearChunks();
    assertEquals(logBuffer.getChunksSize(), 0);
    assertEquals(chunks.size(), 2);
    assertEquals(chunks.get(0), "this is a logging test");
    assertEquals(chunks.get(1), "logging works\nline 1\nline 2");
  }
}
