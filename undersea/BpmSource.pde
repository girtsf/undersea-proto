// Class that handles generating timing data, from either manual input
// or MIDI data.

import java.util.List;
import java.util.LinkedList;

class BpmSource {
  // Midi reference:
  // https://www.nyu.edu/classes/bello/FMT_files/9_MIDI_code.pdf
  final static byte TIMING_CLOCK = (byte) 0xf8;
  final static byte NOTE_ON_START = (byte) 0x80;
  final static byte NOTE_ON_END = (byte) 0x8f;

  final static int MESSAGES_PER_BEAT = 24;

  // Whether clock is coming from MIDI or manual. First time we see MIDI clock
  // signal, we enable midi clock, unless it gets manually disabled.
  boolean clockFromMidi = false;
  boolean manuallyDisabled = false;

  int lastTap = 0;
  int firstTap = 0;
  int tapCount = 0;

  // Constant for now.
  int beatsPerMeasure = 4;
  float bpm = 120;

  // Keep track of number of timing.
  long ticks = 0;
  int beats = 0;
  int beatTicks = 0;
  long lastUpdateTicks = 0;

  byte bpmTapNote;

  LinkedList<Integer> clockTimings = new LinkedList<Integer>();

  Textfield bpmField;
  Toggle bpmToggle;

  BpmSource(ControlP5 cp5, int x, int y, byte bpmTapNote) {
    bpmField = cp5.addTextfield("bpm")
      .setPosition(x, y)
      .setSize(50, 30)
      .setText("" + bpm)
      .setAutoClear(false);
    bpmField.addListener(new ControlListener() {
      void controlEvent(ControlEvent theEvent) {
        try {
          bpm = Float.parseFloat(bpmField.getText());
          if (bpm < 10) bpm = 10;
          if (bpm > 999) bpm = 999;
        } 
        catch (NumberFormatException ex) {
          println("can't parse BPM");
        }
        println("got BPM from field: " + bpm);
        setBpm(bpm);
      }
    }
    );

    bpmToggle = cp5.addToggle("MIDI BPM").setPosition(x + 100, y).setValue(false);
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

  int beatInterval() {
    return int(32767.0 / (bpm / 60));
  }

  BeatData buildBeatData(int[] parameters) {
    int beatInterval = beatInterval();
    int measures = beats / beatsPerMeasure;

    BeatData bd = new BeatData();
    bd.beatsPerMeasure = beatsPerMeasure;
    bd.beatInMeasure = beats % beatsPerMeasure;
    bd.beatInterval = beatInterval;
    bd.measure = measures;
    bd.beatTicks = beatTicks;
    bd.beats = beats;
    bd.ticks = ticks;
    bd.parameters = parameters.clone();

    return bd;
  }

  void updateTime() {
    int now = millis();  
    ticks = (long) now * 32767 / 1000;
    long ticksDiff = ticks - lastUpdateTicks;
    int beatInterval = beatInterval();
    beatTicks += ticksDiff;
    int newBeats = (int)(beatTicks / beatInterval);
    beatTicks = beatTicks % beatInterval;
    beats += newBeats;
    lastUpdateTicks = ticks;
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
      float beatPeriod = (float)(delta) * (MESSAGES_PER_BEAT + 1) / 1000.0 / count;
      float newBpm = 60.0 / beatPeriod;
      float gradual = bpm + (newBpm - bpm) * 0.05;
      // println("now: ", now, " delta: ", delta, " beatPeriod: ", beatPeriod);
      setBpm(gradual);
    } else {
      setBpm(120.0);
    }
    // XXX: handle offset + downbeat (start of measure).
  }

  void setBpm(float bpm) {
    this.bpm = bpm;
    bpmField.setText(nf(bpm, 3, 2));
  }

  void adjustBpm(float amount) {
    bpm += amount;
  }

  void handleBpmTap() {
    // Don't allow setting BPM when running on MIDI clock, set only downbeat.
    if (clockFromMidi) {
      beatTicks = 0;
      beats++;
      while ((beats % beatsPerMeasure) != 0) {
        beats++;
      }
      return;
    }   
    int now = millis();

    if ((lastTap == 0) || ((now - lastTap) > 2000)) {
      // If the last taps were more than 2s apart, reset the timer.
      println("reset BPM tap");
      firstTap = now;
      tapCount = 1;
      // Set downbeat. Allow setting downbeat even when running on midi clock.
      beatTicks = 0;
      beats++;
      while ((beats % beatsPerMeasure) != 0) {
        beats++;
      }
    } else {
      tapCount++;
    }

    if (tapCount > 1) {
      int delta = now - firstTap;
      println("delta: " + delta + "  tapcount: " + tapCount);
      float msPerTap = float(delta) / (tapCount - 1);
      setBpm(60.0 * 1000.0 / msPerTap);
      beatTicks = 0;
      beats += 1;
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
}