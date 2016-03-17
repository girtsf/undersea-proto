// This is a pulse visualizer that never allows the umbrella to go
// dark -- we swell into some color and then gradually fade to
// deep-ocean blue.
//
// Idea: rpearl.

class Swimming2Visualizer extends Visualizer {
  // Value of previous beat seen. Used to detect start of new beat period.
  int update_after_beat = 0;
  int internal_beat_counter = 0;
  int update_after_tick = 0;
  
  // target color for this beat
  color target = 0;
  
  // Return the labels for the visualizer. This will enable three sliders.
  String[] getParameterLabels() {
    String[] s = {"deeelay"};
    return s;
  }

  void process(BeatData bd) {
    // failsafe if bd.beats gets reset:
    if (bd.beats < update_after_beat - 20) { update_after_beat = 0; }
    if (bd.beats > update_after_beat) {
      updateOnBeat(bd);
    } else {
      if (bd.ticks > update_after_tick) {
        update(bd);
      }
    }
  }
  
  int pickColor(int select) {
    int c = select;
    c ^= (select * 1111);
    c ^= (select * 143123);
    c ^= ((select >> 3) * 1321);
    c |= 0xFF000000;  // set alpha channel to 0xFF
    return c;
  }
  
  void updateOnBeat(BeatData bd) {
    update_after_beat = bd.beats;
    if ((bd.beats % 4) == (bd.hardwareId % 4)) {
    // if (true) {
      int select = bd.beats + bd.hardwareId * 4;
      for (int i = 0; i < pixels.length; i++) {
        int j = i/2;
        pixels[i] = pickColor(select + j * 100);
      }
    }
    update_after_tick = 1000;
  }
  
  int weighted_average(color x, color y) {
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
  
  void update(BeatData bd) {
    long delay = bd.parameters[0] * 2000 / 256 + 50;
    update_after_tick += delay;
    if ((bd.hardwareId % 2) == 0) {
      for (int i = 0; i < pixels.length; i++) {
        int j = (i + 1) % pixels.length;
        pixels[i] = weighted_average(pixels[i], pixels[j]);
      }
    } else {
      for (int i = 0; i < pixels.length; i++) {
        int j = (i + 1) % pixels.length;
        pixels[7-i] = weighted_average(pixels[7-i], pixels[7-j]);
      }
    }
  }
} // visualizer