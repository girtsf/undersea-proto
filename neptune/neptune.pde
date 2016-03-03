import processing.serial.*;

final static String SERIAL_PORT = "/dev/tty.usbserial-AI02BBCZ";
final static int SERIAL_BAUD = 115200;

// The serial port:
Serial serialPort;

void setup() {
  // List all the available serial ports:
  printArray(Serial.list());

  // Open the port you are using at the rate you want:
  serialPort = new Serial(this, SERIAL_PORT, SERIAL_BAUD);

  // Send a capital A out the serial port:
  // myPort.write(65);
}

void draw() {
}

// Escapes and sends a packet.
void escapeAndSend(final byte[] b, Serial p) {
  byte[] eof = {(byte) 0xc0};
  byte[] escapedEof = {(byte) 0xdb, (byte) 0xdc};
  byte[] escapedEsc = {(byte) 0xdb, (byte) 0xdd};
  p.write(eof);
  for (int i = 0; i < b.length; i++) {
    if (b[i] == (byte) 0xc0) {
      p.write(escapedEof);
    } else if (b[i] == (byte) 0xdb) {
      p.write(escapedEsc);
    } else {
      byte[] bb = {b[i]};
      p.write(bb);
    }
  }
  p.write(eof);
}

void keyPressed() {
  byte[] b = {0x33, 0x34, 11, (byte) 0xc0, 4, (byte) 0xdb, 5};
  escapeAndSend(b, serialPort);
}

void serialEvent(Serial p) {
  byte[] buf = p.readBytes();
  print("read (" + buf.length + "): ");
  for (int i = 0; i < buf.length; i++) {
    byte c = buf[i];
    if (c > 32 && c < 127) {
      print(char(c));
    } else {
      print("[" + nf(c, 2) + "]");
    }
  }
  println("");
} 