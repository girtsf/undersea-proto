// Number of pixels on each jelly.
static final int PIXELS = 10;
// Number of jellies.
static final int JELLIES = 6;

Class[] visualizers = {
  PulseVisualizer.class, 
  HueRotateVisualizer.class, 
  RandomVisualizer.class, 
  FlashVisualizer.class, 
  // add new visualizers here
};

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
  int beats_per_measure = 4;
  int beat_interval = int(32767 / (bpm / 60));
  long ticks = (long) millis() * 32767 / 1000 + jitterTicks + bpmTapOffset;
  int beats = (int)(ticks / beat_interval);
  int measures = beats / beats_per_measure;

  BeatData bd = new BeatData();
  bd.beats_per_measure = beats_per_measure;
  bd.beat_in_measure = beats % beats_per_measure;
  bd.beat_interval = beat_interval;
  bd.measure = measures;
  bd.beat_ticks = (int)(ticks % beat_interval);
  bd.beats = beats;
  bd.ticks = ticks;
  return bd;
}

// Represents a single jelly.
class Jelly {
  // Position on the screen.
  final int mPos;
  // Emulated communication jitter in ticks.
  final int mJitter;

  // Color values.
  color[] mPixels;
  // Current visualizer.
  Visualizer mVisualizer;

  Jelly(int pos) {
    mPos = pos;
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
    bd.hardware_id = mPos;
    return bd;
  }

  // Draws this jelly to screen.
  void draw() {
    BeatData bd = prepBeatData();
    mVisualizer.process(bd);
    stroke(100);
    // How big each slice is (in radians).
    float sliceSize = 2 * PI / mPixels.length;
    // Rotate each jelly slightly.
    float offset = sliceSize / 3 * mPos;
    for (int i = 0; i < mPixels.length; i++) {
      fill(mPixels[i]);
      arc(70 + 100 * mPos, 70, 90, 90, offset + sliceSize * i, offset + sliceSize * (i + 1), PIE);
    }
  }
}

Jelly[] jellies;
float bpm = 120;
int bpmTapOffset = 0;
String visualizerName;
int visualizerIdx = 0;

// Picks next visualizer in the given direction (1: next, -1: prev).
void nextVisualizer(int dir) {
  visualizerIdx += dir;
  if (visualizerIdx < 0) {
    visualizerIdx = visualizers.length - 1;
  }
  if (visualizerIdx >= visualizers.length) {
    visualizerIdx = 0;
  }
  Class v = visualizers[visualizerIdx];
  setVisualizer(v);
}

void setVisualizer(Class visClass) {
  for (Jelly j : jellies) {
    Visualizer v = null;
    try {
      // fsck processing and its class mangling.
      // hackery from http://stackoverflow.com/questions/31150337/
      java.lang.reflect.Constructor c = visClass.getDeclaredConstructor(Class.forName("undersea"));
      v = (Visualizer)c.newInstance(this);
    } 
    catch (Exception ex) {
      println("bleh");
    }
    if (v != null) {
      j.setVisualizer(v);
    }
  }
  visualizerName = visClass.getName();
  println("switched to visualizer: " + visualizerName);
}

void setup() {
  colorMode(HSB, 255);
  size(640, 300);
  jellies = new Jelly[JELLIES];
  for (int i = 0; i < JELLIES; i++) {
    jellies[i] = new Jelly(i);
  }
  frameRate(50);

  nextVisualizer(0);
}

int lastTap = 0;
int firstTap = 0;
int tapCount = 0;
void keyPressed() {
  int now = millis();
  if (key == ' ') {
    if ((lastTap == 0) || ((now - lastTap) > 2000)) {
      // If the last taps were more than 2s apart, reset the timer.
      println("reset");
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
      bpmTapOffset = 0;
      BeatData bd = buildGlobalBeatData(0);
      bpmTapOffset = -bd.beat_ticks;
      println("offset: " + bpmTapOffset);
    }

    lastTap = now;
  } else if (key == ',') {
    bpm += 0.25;
  } else if (key == '.') {
    bpm -= 0.25;
  } else if (keyCode == UP) {
    nextVisualizer(1);
  } else if (keyCode == DOWN) {
    nextVisualizer(-1);
  }
}

// Draws a status string. Or something.
void drawStatus() {
  textSize(14);

  fill(0, 0, 255);
  text("[SPACE] tap for bpm [,.] bpm up/down [↑↓] change visualizers", 10, 260);

  fill(0, 255, 255);
  BeatData bd = buildGlobalBeatData(0);
  String status = "BPM: " + nf(bpm, 3, 1);
  status += " measure: " + bd.measure;
  status += " beat: " + bd.beat_in_measure;
  status += " visualizer: " + visualizerName;
  // status += " beat ticks:" + bd.beat_ticks;
  status += " fps: " + nf(frameRate, 3, 1);
  text(status, 10, 280);
}

// Main draw function. Draws ALL the jellies.
void draw() {
  // Clear the display.
  background(0);
  // Jellies. Yum.
  for (Jelly j : jellies) {
    j.draw();
  }
  // Status text.
  drawStatus();
}