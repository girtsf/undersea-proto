import controlP5.*;
import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;
import java.util.Map;

// Number of pixels on each jelly.
static final int PIXELS = 10;
// Number of jellies.
static final int JELLIES = 15;
// How big each jelly is.
static final int JELLY_RADIUS = 70;

// MIDI note to use for BPM tap / downbeat sync.
static final byte BPM_TAP_NOTE = (byte) 0x24;
// MIDI clock device name.
static final String MIDI_CLOCK_DEVICE = "simple core midi source";
// MIDI input device name.
static final String MIDI_INPUT_DEVICE = "Oxygen 49";
// Whether to show all MIDI input messages.
static final boolean MIDI_DEBUG = true;
// Addresses for the first eight sliders on the Oxygen 49 keyboard + MOD wheel.
static final byte[] PARAMETER_KNOB_MIDI_ADDRESSES = {0x14, 0x15, 0x47, 0x48, 0x19, 0x49, 0x4a, 0x46, 0x01};

// Serial port config.
final static String SERIAL_PORT = "/dev/tty.usbserial-AI02BBCZ";
final static int SERIAL_BAUD = 115200;

// Add the visualizers/patterns here.
static final Class[] VISUALIZERS = {
  HueRotateVisualizer.class, 
  PulseVisualizer.class, 
  RandomVisualizer.class, 
  FlashVisualizer.class, 
  PrimeVisualizer.class, 
  SingleColorVisualizer.class, 
  SlowColorFadeVisualizer.class, 
  ScannerVisualizer.class, 
  // add new visualizers here
};

// Patterns that are defined here can be selected for radio output.
static final HashMap<String, Integer> PATTERN_INDICES = new HashMap<String, Integer>();
static {
  PATTERN_INDICES.put("HueRotate", 0);
}

// Represents a single pixel.
class Pixel {
  int r, g, b;
  Pixel(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
};

BeatData buildGlobalBeatData(int jitterTicks) {
  int beatsPerMeasure = 4;
  int beatInterval = int(32767 / (bpmSource.bpm / 60));
  long ticks = (long) millis() * 32767 / 1000 + jitterTicks + bpmSource.offset;
  int beats = (int)(ticks / beatInterval);
  int measures = beats / beatsPerMeasure;

  BeatData bd = new BeatData();
  bd.beatsPerMeasure = beatsPerMeasure;
  bd.beatInMeasure = beats % beatsPerMeasure;
  bd.beatInterval = beatInterval;
  bd.measure = measures;
  bd.beatTicks = (int)(ticks % beatInterval);
  bd.beats = beats;
  bd.ticks = ticks;
  bd.parameters = sliders.values.clone();

  return bd;
}

class Placer {
  ArrayList<Integer> mPosX = new ArrayList<Integer>();
  ArrayList<Integer> mPosY = new ArrayList<Integer>();

  int x = -1;
  int y = -1;

  final int mMinX, mMinY, mMaxX, mMaxY, mRadius;

  Placer(int minX, int minY, int maxX, int maxY, int radius) {
    mMinX = minX;
    mMinY = minY;
    mMaxX = maxX;
    mMaxY = maxY;
    mRadius = radius;
  }

  float dist(int x, int y, int i) {
    return sqrt(sq(x - mPosX.get(i)) + sq(y - mPosY.get(i)));
  }

  boolean placeNext() {
    for (int attempt = 0; attempt < 500; attempt++) {
      x = int(random(mMinX + mRadius, mMaxX - mRadius - 5));
      y = int(random(mMinY + mRadius, mMaxY - mRadius - 5));
      boolean ok = true;
      for (int i = 0; i < mPosX.size(); i++) {
        if (dist(x, y, i) < (mRadius + 5)) {
          ok = false;
          break;
        }
      }
      if (ok) {
        mPosX.add(x);
        mPosY.add(y);
        return true;
      }
    }
    return false;
  }
}

// Represents a single jelly.
class Jelly {
  // Unique id.
  final int mId;
  // Position on the screen.
  final int mPosX, mPosY;

  // Emulated communication jitter in ticks.
  final int mJitter;

  // Color values.
  color[] mPixels;
  // Current visualizer.
  Visualizer mVisualizer;

  Jelly(int id, int x, int y) {
    mId = id;
    mPosX = x;
    mPosY = y;
    mJitter = int(random(-500, 500));  // ~15ms
    mPixels = new color[PIXELS];

    for (int i = 0; i < PIXELS; i++) {
      mPixels[i] = #000000;  // black
    }
  }

  void setVisualizer(Visualizer v) {
    mVisualizer = v;
    mVisualizer.pixels = mPixels;
  }

  // Preps beat data and calls the configured visualizer.
  BeatData prepBeatData() {
    BeatData bd = buildGlobalBeatData(mJitter);
    bd.hardwareId = mId;
    return bd;
  }

  // Draws this jelly to screen.
  void draw() {
    BeatData bd = prepBeatData();
    // By default use HSB model, but visualizers can switch to RGB if needed.
    colorMode(HSB, 255);
    mVisualizer.process(bd);
    colorMode(HSB, 255);
    stroke(100);
    // How big each slice is (in radians).
    float sliceSize = 2 * PI / mPixels.length;
    // Rotate each jelly slightly.
    float offset = sliceSize / 3 * mId;
    for (int i = 0; i < mPixels.length; i++) {
      fill(mPixels[i]);
      arc(mPosX, mPosY, JELLY_RADIUS, JELLY_RADIUS, 
        offset + sliceSize * i, offset + sliceSize * (i + 1), PIE);
    }
  }
}

Jelly[] jellies;

String[] addGlobalBrightnessLabel(String[] labels) {
  String[] out = new String[Sliders.CHANNELS];
  if (labels != null) {
    for (int i = 0; i < labels.length; i++) {
      out[i] = labels[i];
    }
  }
  out[Sliders.CHANNELS - 1] = "Global brightness";
  return out;
}

String getPatternNameFromClass(Class visClass) {
  String name = visClass.getName();
  int i = name.indexOf("$");
  if (i >= 0) {
    name = name.substring(i + 1);
  }
  name = name.replaceAll("Visualizer", "");
  return name;
}

void setVisualizer(Class visClass) {
  for (Jelly j : jellies) {
    Visualizer v = null;
    try {
      // fsck processing and its class mangling.
      // hackery from http://stackoverflow.com/questions/31150337/
      java.lang.reflect.Constructor c = visClass.getDeclaredConstructor(Class.forName("undersea"));
      v = (Visualizer)c.newInstance(this);
      sliders.setNames(addGlobalBrightnessLabel(v.getParameterLabels()));
      sliders.setValues(v.getParameterDefaults());
    }
    catch (Exception ex) {
      println("bleh");
    }
    if (v != null) {
      j.setVisualizer(v);
    }
  }
}

class PatternPicker {
  ScrollableList mPatternList;

  PatternPicker(ControlP5 cp5, int x, int y, int width, int height) {
    mPatternList = cp5
      .addScrollableList("pattern")
      .setPosition(x, y)
      .setSize(width, height)
      .setType(ControlP5.LIST)
      //.setBarVisible(false)
      .setItemHeight(30);
    for (Class c : VISUALIZERS) {
      String n = getPatternNameFromClass(c);
      Integer idx = PATTERN_INDICES.get(n);
      if (idx == null) idx = -1;
      mPatternList.addItem(n, Integer.valueOf(idx));
      if (idx < 0) {
        CColor col = new CColor();
        col.setBackground(#555555);     
        mPatternList.getItem(n).put("color", col);
      }
    }
    mPatternList.addListener(changeListener);
  }

  ControlListener changeListener = new ControlListener() {
    public void controlEvent(ControlEvent theEvent) {
      switchVisualizer();
    }
  };

  // Picks next visualizer in the given direction (1: next, -1: prev).
  void nextVisualizer(int dir) {
    int visualizerIdx = idx() + dir;
    if (visualizerIdx < 0) {
      visualizerIdx = VISUALIZERS.length - 1;
    }
    if (visualizerIdx >= VISUALIZERS.length) {
      visualizerIdx = 0;
    }
    mPatternList.setValue(visualizerIdx);
    switchVisualizer();
  }

  void switchVisualizer() {
    Class v = VISUALIZERS[idx()];
    setVisualizer(v);
  }

  int idx() {
    return (int) mPatternList.getValue();
  }

  String name() {
    return (String) mPatternList.getItem(idx()).get("text");
  }
}

// Class that hexdumps received MIDI messages.
class MidiDumper {
  LinkedList<StandardMidiListener> listeners = new LinkedList<StandardMidiListener>();

  StandardMidiListener getDumper(final String name) {
    StandardMidiListener listener = new StandardMidiListener() {
      public void midiMessage(javax.sound.midi.MidiMessage message, long timeStamp) {
        byte[] bytes = message.getMessage();

        print(name + " (" + bytes.length + "): ");
        for (byte b : bytes) {
          print(String.format("%02x ", b));
        }
        println("");
      }
    };
    listeners.addLast(listener);
    return listener;
  }
}


// Main GUI control object.
ControlP5 cp5;
// Parameter input sliders.
Sliders sliders;
// Pattern selector.
PatternPicker patternPicker;
// MIDI buses:
MidiBus midiClockBus;
MidiBus midiInputBus;
// MIDI / keyboard BPM source.
BpmSource bpmSource;
// BPM toggle.
Toggle bpmToggle;

SerialControl serialControl;

MidiDumper midiDumper = new MidiDumper();

void setup() {
  colorMode(HSB, 255);
  size(1000, 600);

  cp5 = new ControlP5(this);

  // List all available Midi devices on STDOUT. This will show each device's index and name.
  MidiBus.list();
  midiClockBus = new MidiBus(this);
  if (!midiClockBus.addInput(MIDI_CLOCK_DEVICE)) {
    println("failed to add MIDI clock input");
  }
  midiInputBus = new MidiBus(this);
  if (!midiInputBus.addInput(MIDI_INPUT_DEVICE)) {
    println("failed to add MIDI control input");
  }
  if (MIDI_DEBUG) {
    // don't dump clock, it's spammy.
    // midiClockBus.addMidiListener(midiDumper.getDumper("clock"));
    StandardMidiListener m = midiDumper.getDumper("input");
    midiInputBus.addMidiListener(m);
  }

  bpmSource = new BpmSource(cp5, width - 170, 10, BPM_TAP_NOTE);

  sliders = new Sliders(cp5, PARAMETER_KNOB_MIDI_ADDRESSES);

  patternPicker = new PatternPicker(cp5, 5, 5, 200, height - 100);

  midiClockBus.addMidiListener(bpmSource.clockListener);
  midiInputBus.addMidiListener(bpmSource.tapListener);
  midiInputBus.addMidiListener(sliders.midiListener);

  serialControl = new SerialControl(this, SERIAL_PORT, SERIAL_BAUD);

  Placer placer = new Placer(205, 5, width - 175, height - 50, JELLY_RADIUS);
  jellies = new Jelly[JELLIES];
  for (int i = 0; i < JELLIES; i++) {
    if (!placer.placeNext()) {
      throw new RuntimeException("failed to place jelly. reduce count?");
    }
    jellies[i] = new Jelly(i, placer.x, placer.y);
  }

  frameRate(50);

  patternPicker.nextVisualizer(0);
}

// Handle keypresses.
void keyPressed() {
  if (key == ' ') {
    bpmSource.handleBpmTap();
  } else if (key == ',') {
    bpmSource.adjustBpm(0.25);
  } else if (key == '.') {
    bpmSource.adjustBpm(-0.25);
  } else if (keyCode == UP) {
    patternPicker.nextVisualizer(-1);
  } else if (keyCode == DOWN) {
    patternPicker.nextVisualizer(1);
  } else {
    // XXX: make periodic and on changes.
    int[] parameters = sliders.values.clone();
    int globalBrightness = sliders.values[sliders.CHANNELS - 1];
    int pattern = patternPicker.idx(); // XXX: only if defined.
    serialControl.sendPacket(bpmSource.bpm, bpmSource.offset, parameters, globalBrightness, pattern);
  }
}

// Draws a status string. Or something.
void drawStatus(BeatData bd) {
  textSize(14);

  fill(0, 0, 255);
  text("[SPACE] tap for bpm [,.] bpm up/down [↑↓] change visualizers", 10, height - 40);

  fill(0, 255, 255);
  String status = "BPM: " + nf(bpmSource.bpm, 3, 1);
  status += " measure: " + bd.measure;
  status += " beat: " + bd.beatInMeasure;
  status += " visualizer: " + patternPicker.name();
  status += " beat ticks: " + bd.beatTicks + "/" + bd.beatInterval;
  status += " fps: " + nf(frameRate, 3, 1);
  text(status, 10, height - 20);
}

// Draws a spinning beat indicator.
void drawBeatIndicator(BeatData bd, int x, int y, int radius) {
  stroke(0, 0, 255);
  fill(0, 0, 0);
  // Draw a circle.
  arc(x, y, radius, radius, 0, 2 * PI);
  // Draw a line at 12 o'clock.
  arc(x, y, radius, radius, - PI / 2 - PI / 10, - PI / 2 - PI / 10, PIE);
  fill(0, 0, 255);
  float percentage = (float) bd.beatTicks / bd.beatInterval;
  float loc = - PI / 2 + percentage * 2 * PI;
  arc(x, y, radius, radius, loc, loc + PI/10, PIE);
}

// Main draw function. Draws ALL the jellies.
void draw() {
  // Clear the display.
  background(0);
  // Jellies. Yum.
  for (Jelly j : jellies) {
    j.draw();
  }
  // Status text and beat indicator.
  BeatData bd = buildGlobalBeatData(0);
  drawStatus(bd);
  drawBeatIndicator(bd, width - 100, height - 100, 100);
}

void serialEvent(Serial p) {
  serialControl.handleSerialEvent();
}