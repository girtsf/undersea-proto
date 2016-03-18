// This is a pulse visualizer that never allows the umbrella to go
// dark -- we swell into some color and then gradually fade to
// deep-ocean blue.
//
// Idea: rpearl.

class OscillateVisualizer extends Visualizer {
  // Value of previous beat seen. Used to detect start of new beat period.
  int update_after_beat = 0;
  int internal_beat_counter = 0;
  int update_after_tick = 0;
  
  // target color for this beat
  color target = 0;
  int counter = 0;
  
  // Return the labels for the visualizer. This will enable three sliders.
  String[] getParameterLabels() {
    String[] s = {"hue-zero", "hue-uno"};
    return s;
  }

  
  void process(BeatData bd) {
    // failsafe:
    if (bd.beats < (update_after_beat - 20)) { update_after_beat = bd.beats; }
    if (bd.beats > update_after_beat) {
      updateOnBeat(bd);
    } else {
      if (bd.ticks > update_after_tick) {
        update(bd);
      }
    }
  }
  
  void updateOnBeat(BeatData bd) {
    update_after_beat = bd.beats + 1;
    counter++;
    if (counter > 1) { counter = 0; }
    if (counter == 0) {
      target = color(bd.parameters[0], 255, 255);
    } else {
      target = color(bd.parameters[1], 255, 255);
    }
    int select = bd.beats + bd.hardwareId * 4;
    update(bd);
    update_after_tick = 1000;
  }
  
  int weighted_average(color x, color y) {
    int r = 0xFF & (x >> 16);
    int g = 0xFF & (x >> 8);
    int b = 0xFF & (x >> 0);
    r *= 7;
    g *= 7;
    b *= 7;
    r += 0xFF & (y >> 16);
    g += 0xFF & (y >> 8);
    b += 0xFF & (y >> 0);
    r >>= 3;
    g >>= 3;
    b >>= 3;
    return 0xFF000000 + (r << 16) + (g << 8) + b;
  }
  
  void update(BeatData bd) {
    update_after_tick += 1000;
    int rotation = (bd.beats * 2341) ^ (bd.hardwareId * 7);
    for (int i = 0; i < 4; i++) {
      int ii = (i + rotation) & 0x7;
      int jj = (ii + 1) & 0x7;
      pixels[ii] = weighted_average(pixels[ii], pixels[jj]);
    }
    for (int i = 0; i < 3; i++) {
      int ii = (7 - i + rotation) & 0x7;
      int jj = (7 - ii - 1) & 0x7;
      pixels[ii] = weighted_average(pixels[ii], pixels[jj]);
    }
    pixels[4] = weighted_average(pixels[4], target);
  }
} // visualizer