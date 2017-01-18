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

import com.google.common.collect.ImmutableList;

import java.util.ArrayList;
import java.util.List;

/** A {@code buffer} to log in chunks of under a given size. Chunk separation is done around new
 * lines when possible.
 *
 * <p>Note : not thread safe
 */
public class LogBuffer {

  private StringBuilder buffer;
  private int maxBufferSize;
  private final List<String> chunks;

  /**
   * Not thread-safe implementation to split log strings into fixed size chunks around new line.
   *
   * <p>Converts log into fixed size chunks.
   * @param maxBufferSize max buffer size
   */
  public LogBuffer(int maxBufferSize) {
    this.buffer = new StringBuilder(maxBufferSize);
    this.maxBufferSize = maxBufferSize;
    this.chunks = new ArrayList<>();
  }

  /**
   * Convert string to be logged into chunks maintaining new line boundaries.
   *
   * <p>Text in a single line is broken into chunks if the line exceeds max buffer size length.
   * @param text log string
   */
  public void addLog(String text) {
    if (text.length() + buffer.length() < maxBufferSize) {
      addLogWithNewLineToBuffer(text);
    } else {
      String[] splits = text.split("\n");
      for (String s : splits) {
        int start = 0;
        int end;
        while (start < s.length()) {
          end = Math.min(s.length(), maxBufferSize - 1);
          if (end - start + buffer.length() > maxBufferSize - 1) {
            addCurrentBufferToChunks();
          }
          addLogWithNewLineToBuffer(s.subSequence(start, end));
          start = end;
        }
      }
    }
  }

  /**
   * Adds current buffer entries as new chunk and returns list of log chunks. Clears list of chunks
   *
   * @return copy of list of chunks as strings
   */
  public List<String> getAndClearChunks() {
    addCurrentBufferToChunks();
    List<String> copy = ImmutableList.copyOf(chunks);
    chunks.clear();
    return copy;
  }

  public int getBufferSize() {
    return buffer.length();
  }

  public int getChunksSize() {
    return chunks.size();
  }

  private void addCurrentBufferToChunks() {
    if (buffer.length() > 0) {
      chunks.add(buffer.toString());
      buffer.setLength(0);
    }
  }

  private void addLogWithNewLineToBuffer(CharSequence log) {
    if (buffer.length() > 0) {
      buffer.append('\n');
    }
    buffer.append(log);
  }
}
