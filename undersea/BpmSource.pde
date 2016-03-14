// Class that handles generating timing data, from either manual input
// or MIDI data.

import java.util.List;
import java.util.LinkedList;

class BpmSource {
  // Midi reference:
  // https://www.nyu.edu/classes/bello/FMT_files/9_MIDI_code.pdf
  final static byte TIMING_CLOCK = (byte)0xf8;
  final static byte NOTE_ON_START = (byte)0x80;
  final static byte NOTE_ON_END = (byte)0x8f;

  final static int MESSAGES_PER_BEAT = 24;

  // Whether clock is coming from MIDI or manual. First time we see MIDI clock
  // signal, we enable midi clock, unless it gets manually disabled.
  boolean clockFromMidi = false;
  boolean manuallyDisabled = false;

  int lastTap = 0;
  int firstTap = 0;
  int tapCount = 0;

  float bpm = 120;
  int offset = 0;

  byte bpmTapNote;

  LinkedList<Integer> clockTimings = new LinkedList<Integer>();

  Toggle bpmToggle;

  BpmSource(ControlP5 cp5, int toggleX, int toggleY, byte bpmTapNote) {
    bpmToggle = cp5.addToggle("MIDI BPM").setPosition(toggleX, toggleY).setValue(false);
    bpmToggle.addListener(new ControlListener() {
      void controlEvent(ControlEvent theEvent) {
        clockFromMidi = bpmToggle.getBooleanValue();
        if (!clockFromMidi) {
          manuallyDisabled = true;
        }
      }
    }
    );
    this.bpmTapNote = bpmTapNote;
  }

  // XXX: this is not super reliable and should be rewritten.
  void handleMidiClockMessage() {
    if (!clockFromMidi) {
      if (manuallyDisabled) {
        return;
      }
      clockFromMidi = true;
      bpmToggle.setValue(true);
    }
    int now = millis();
    clockTimings.addLast(now);
    while (clockTimings.size() > MESSAGES_PER_BEAT) {
      clockTimings.removeFirst();
    }
    int count = clockTimings.size();
    if (count > 1) {
      int delta = now - clockTimings.getFirst();
      float beatPeriod = (float)(delta) * MESSAGES_PER_BEAT / 1000.0 / count;
      // println("now: ", now, " delta: ", delta, " beatPeriod: ", beatPeriod);
      bpm = 60.0 / beatPeriod;
    } else {
      bpm = 120.0;
    }
    // XXX: handle offset + downbeat (start of measure).
  }

  void adjustBpm(float amount) {
    bpm += amount;
  }

  void handleBpmTap() {
    int now = millis();

    if ((lastTap == 0) || ((now - lastTap) > 2000)) {
      // If the last taps were more than 2s apart, reset the timer.
      println("reset BPM tap");
      firstTap = now;
      tapCount = 1;
    } else {
      tapCount++;
    }

    if (tapCount > 1) {
      int delta = now - firstTap;
      println("delta: " + delta + "  tapcount: " + tapCount);
      float msPerTap = float(delta) / (tapCount - 1);
      bpm = 60.0 * 1000.0 / msPerTap;
      offset = 0;
      BeatData bd = buildGlobalBeatData(0);
      offset = -bd.beatTicks;
      println("offset: " + offset);
    }

    lastTap = now;
  }

  StandardMidiListener clockListener = new StandardMidiListener() {
    void midiMessage(javax.sound.midi.MidiMessage message, long timeStamp) {
      byte[] bytes = message.getMessage();
      for (byte b : bytes) {
        if (b == TIMING_CLOCK) {
          handleMidiClockMessage();
        }
      }
    }
  };

  boolean isNoteOnCommand(byte note) {
    return (note >= NOTE_ON_START) && (note <= NOTE_ON_END);
  }

  StandardMidiListener tapListener = new StandardMidiListener() {
    void midiMessage(javax.sound.midi.MidiMessage message, long timeStamp) {
      byte[] bytes = message.getMessage();
      if (bytes.length == 3 && isNoteOnCommand(bytes[0]) && (bytes[1] == bpmTapNote)) {
        handleBpmTap();
      }
    }
  };

  void hexdump(byte[] bytes) {
    print("(" + bytes.length + "): ");
    for (byte b : bytes) {
      print(String.format("%02x ", b));
    }
    println("");
  }
}