// Class for creating radio control messages and sending them over serial to the radio.

import processing.serial.*;

class SerialControl {
  Serial serial;

  SerialControl(PApplet applet, String port, int baud) {
    // List all serial ports.
    println("----- Serial Ports -----");
    printArray(Serial.list());

    try {
      serial = new Serial(applet, port, baud);
    } 
    catch (java.lang.RuntimeException ex) {
      println("opening serial failed: " + ex);
    }
  }

  boolean isConnected() {
    return serial != null;
  }

  // Escapes and sends a packet.
  void escapeAndSend(final byte[] b) {
    if (serial == null) {
      print("would have wanted to send a packet, but serial not open. packet:");
      for (byte b1 : b) {
        print(String.format("%02x ", b1));
      }
      println("");
      return;
    }

    /*
    print("sending: ");
     for (byte b1 : b) {
     print(String.format("%02x ", b1));
     }
     println("");
     */

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

  void sendPacket(BeatData bd, int globalBrightness, int pattern) {
    Packet p = new Packet(64);
    p.setUint16(0, 0x13d);  // magic
    p.setUint16(2, 1);  // version
    p.setUint16(3, 1);  // command=beat
    // XXX add beats
    p.setUint64(4, bd.ticks); 
    p.setUint8(12, bd.beatsPerMeasure);
    p.setUint8(13, bd.beatInMeasure);
    p.setUint32(14, bd.beatInterval);
    p.setUint32(18, bd.beatTicks);
    p.setUint32(22, bd.measure);
    p.setUint32(26, bd.beats);
    p.setUint32(30, bd.ticks);
    for (int i = 0; i < 8; i++) {
      p.setUint8(34 + i, bd.parameters[i]);
    }
    p.setUint8(42, globalBrightness);
    p.setUint8(43, pattern);

    escapeAndSend(p.bytes);
  }

  void hexdump(byte[] bytes) {
    for (byte b : bytes) {
      print(String.format("%02x ", b));
    }
    println("");
  }

  void handleSerialEvent() {
    byte[] bytes = serial.readBytes();
    print("serial (" + bytes.length + "): ");
    hexdump(bytes);
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
      bytes[pos + i] = (byte)((value >> (i*8)) & 0xff);
    }
  }

  void setUint32(int pos, long value) {
    assert(value >= 0);
    for (int i = 0; i < 4; i++) { //<>//
      byte b = (byte)((value >> (i*8)) & 0xff);
      bytes[pos + i] = b;
    }
  }
}