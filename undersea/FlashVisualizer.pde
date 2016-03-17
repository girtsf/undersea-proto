// Simple example visualizer that flashes once per beat.
class FlashVisualizer extends Visualizer {
  int mPrevBeat = 0;
  long next_tick = 0;

  void process(BeatData bd) {
    color c;
    if (mPrevBeat != bd.beatInMeasure) {
      // We haven't seen this beat yet. Flash!
      c = #ffffff;  // white
      next_tick = bd.ticks;
    } else {
      c = pixels[0];
      // exponential decay:
      if (bd.ticks > next_tick) {
        c = weighted_average(c, 0);
        next_tick = bd.ticks + 1000;
      }
      // c = #000000;  // black
    }
    mPrevBeat = bd.beatInMeasure;
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = c;
    }
  }
  
  color weighted_average(color x, color y) {
    int r = 0xFF & (x >> 16);
    int g = 0xFF & (x >> 8);
    int b = 0xFF & (x >> 0);
    r *= 15;
    g *= 15;
    b *= 15;
    r += 0xFF & (y >> 16);
    g += 0xFF & (y >> 8);
    b += 0xFF & (y >> 0);
    r >>= 4;
    g >>= 4;
    b >>= 4;
    return 0xFF000000 + (r << 16) + (g << 8) + b;
  }

}