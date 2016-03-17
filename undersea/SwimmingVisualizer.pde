// This is a pulse visualizer that never allows the umbrella to go
// dark -- we swell into some color and then gradually fade to
// deep-ocean blue.
//
// Idea: rpearl.

class SwimmingVisualizer extends Visualizer {
  // Value of previous beat seen. Used to detect start of new beat period.
  int update_after_beat = 0;
  int internal_beat_counter = 0;
  int update_after_tick = 0;
  
  // target color for this beat
  color target = 0;
  
  void process(BeatData bd) {
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
    int select = bd.beats + bd.hardwareId * 4;
    // beat boundary
    target = (select * 13413213) % 0xFFFFFF;
    target ^= (select * 7642124) % 0xFFFFFF;  // this is a bs generator
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
    for (int i = 0; i < 4; i++) {
      pixels[i] = weighted_average(pixels[i], pixels[i+1]);
    }
    for (int i = 0; i < 3; i++) {
      pixels[7-i] = weighted_average(pixels[7-i], pixels[7-i-1]);
    }
    pixels[4] = weighted_average(pixels[4], target);
  }
} // visualizer