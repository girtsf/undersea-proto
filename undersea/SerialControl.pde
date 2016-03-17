// Class for creating radio control messages and sending them over serial to the radio.

import processing.serial.*;

class SerialControl {
  Serial serial;

  SerialControl(PApplet applet, String port, int baud) {
    // List all serial ports.
    printArray(Serial.list());

    try {
      serial = new Serial(applet, port, baud);
    } 
    catch (java.lang.RuntimeException ex) {
      println("opening serial failed: " + ex);
    }
  }

  // Escapes and sends a packet.
  void escapeAndSend(final byte[] b) {
    if (serial == null) {
      println("would have wanted to send a packet, but serial not open.");
      return;
    }
    byte[] eof = {(byte) 0xc0};
    byte[] escapedEof = {(byte) 0xdb, (byte) 0xdc};
    byte[] escapedEsc = {(byte) 0xdb, (byte) 0xdd};
    serial.write(eof);
    for (int i = 0; i < b.length; i++) {
      if (b[i] == (byte) 0xc0) {
        serial.write(escapedEof);
      } else if (b[i] == (byte) 0xdb) {
        serial.write(escapedEsc);
      } else {
        byte[] bb = {b[i]};
        serial.write(bb);
      }
    }
    serial.write(eof);
  }

  void sendPacket(float bpm, int offsetTicks, int[] parameters, int globalBrightness, int pattern) {
    int beatsPerMeasure = 4;
    int beatInterval = int(32767.0 / (bpm / 60));
    long ticks = (long) millis() * 32767 / 1000 + offsetTicks;
    int beats = (int)(ticks / beatInterval);
    // int measures = beats / beatsPerMeasure;
    int beatInMeasure = beats % beatsPerMeasure;
    long ticktimePatternStarted = 0; // XXX
    Packet p = new Packet(64);
    p.setUint16(0, 0x13d);  // magic
    p.setUint16(2, 1);  // version
    p.setUint16(3, 1);  // command=beat
    p.setUint64(4, ticks); 
    p.setUint8(12, beatsPerMeasure);
    p.setUint8(13, beatInMeasure);
    p.setUint16(14, beatInterval);
    p.setUint64(16, ticktimePatternStarted);

    for (int i = 0; i < 8; i++) {
      p.setUint8(24 + i, parameters[i]);  // 24-31
    }
    p.setUint8(32, globalBrightness);
    p.setUint8(33, pattern);
    
    escapeAndSend(p.bytes);
  }

  void handleSerialEvent() {
    byte[] bytes = serial.readBytes();
    print("serial (" + bytes.length + "): ");
    for (byte b : bytes) {
      print(String.format("%02x ", b));
    }
    println("");
  }
}

class Packet {
  byte[] bytes;

  Packet(int size) {
    bytes = new byte[size];
  }

  void setUint16(int pos, int value) {
    assert(value >= 0);
    assert(value <= 65535);
    bytes[pos] = (byte)(value & 0xff);
    bytes[pos + 1] = (byte)((value >> 8) & 0xff);
  }

  void setUint8(int pos, int value) {
    assert(value >= 0);
    assert(value <= 65535);
    bytes[pos] = (byte)(value & 0xff);
  }

  void setUint64(int pos, long value) {
    assert(value >= 0);
    for (int i = 0; i < 8; i++) {
      bytes[pos + 1] = (byte)((value >> (i*8)) & 0xff);
    }
  }
}