// Number of pixels on each jelly.
static final int PIXELS = 7;
// Number of jellies.
static final int JELLIES = 5;

// Represents a single pixel.
class Pixel {
  int r, g, b;
  Pixel(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
};

// Base class for visualizers.
abstract class Visualizer {
  color[] pixels;
  abstract void process(BeatData beatData);
}

class BlackVisualizer extends Visualizer {
  void process(BeatData beatData) {
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = color(0);
    }
  }
}

// Represents a single jelly.
class Jelly {
  // Position on the screen.
  final int mPos;
  // Color values.
  color[] mPixels;
  // Current visualizer.
  Visualizer mVisualizer;
  
  Jelly(int pos) {
    mPos = pos;    
    mPixels = new color[PIXELS];
 
    for (int i = 0; i < PIXELS; i++) {
      float h = i * 255 / PIXELS;
      mPixels[i] = color(h, 255, 255);
    }    
    setVisualizer(new RandomVisualizer());
  }
  
  void setVisualizer(Visualizer v) {
    mVisualizer = v;
    mVisualizer.pixels = mPixels;
  }
  
  // Preps beat data and calls the configured visualizer.
  BeatData prepBeatData() {
    float bpm = 120;
    int beats_per_measure = 4;
    
    int beat_interval = int(32767 / (bpm / 60));
    int ticks = millis() * 32767 / 1000;
    int beats = ticks / beat_interval;
    int measures = beats / beats_per_measure;
    
    //println(beat_interval);
    println(ticks);
    
    BeatData bd = new BeatData();
    bd.hardware_id = mPos;
    bd.beats_per_measure = beats_per_measure;
    bd.beat_in_measure = beats % beats_per_measure;
    bd.beat_interval = beat_interval;
    bd.measure = measures;
    bd.beat_ticks = ticks % beat_interval;
    return bd;
  }
  
  // Draws this jelly to screen.
  void draw() {
    BeatData bd = prepBeatData();
    mVisualizer.process(bd);
    stroke(100);
    float sliceSize = 2 * PI / mPixels.length;
    for (int i = 0; i < mPixels.length; i++) {
      fill(mPixels[i]);
      arc(70 + 100 * mPos, 70, 90, 90, sliceSize * i, sliceSize * (i + 1), PIE);
    }
  }
}

Jelly[] jellies;

void setup() {
  colorMode(HSB, 255);
  size(610, 150);
  jellies = new Jelly[JELLIES];
  for (int i = 0; i < JELLIES; i++) {
    jellies[i] = new Jelly(i);
  }
}

// Main draw function. Draws ALL the jellies.
void draw() {
  background(0);
  for (Jelly j : jellies) {
    j.draw();
  }
}