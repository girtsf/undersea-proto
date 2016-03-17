// This is a pulse visualizer that never allows the umbrella to go
// dark -- we swell into some color and then gradually fade to
// deep-ocean blue.
//
// Idea: rpearl.

class SpinVisualizer extends Visualizer {
  // Value of previous beat seen. Used to detect start of new beat period.
  int update_after_beat = 0;
  int internal_beat_counter = 0;
  long update_after_tick = 0;
  
  // target color for this beat
  color target = 0;
  int counter = 0;
  
  // 8 x 8 array:
  int[] gradient = {255, 200, 150, 100, 50, 0, 0, 0,  // 0
                    0, 0, 0, 50, 100, 150, 200, 255,  // 1
                    0, 0, 100, 255, 0, 0, 100, 255,   // 2
                    255, 90, 10, 0, 255, 90, 10, 0,  // 3
                    255, 100, 0, 0, 0, 0, 0, 0,  // 4
                    0, 0, 0, 0, 0, 0, 100, 255,  // 5
                    0, 100, 200, 100, 0, 0, 0, 0,  // 6
                    0, 200, 0, 0, 0, 200, 0, 0};  // 7
  int r_rot = 0;
  int g_rot = 0;
  int b_rot = 0;
  int r_grad = 0;
  int g_grad = 0;
  int b_grad = 0;

  int lookup(int grad_select, int index) {
    return gradient[(grad_select & 0x7) * 8 + (index & 0x7)];
  }
  
  int lerp(int grad_select, int rotval) {
    int a = lookup(grad_select, (rotval >> 8)+0);
    int b = lookup(grad_select, (rotval >> 8)+1);
    int w = rotval & 0xFF;
    a *= w;
    b *= (255 - w);
    return (a + b) >> 8;
  }
  
  int colorFromRgb(int r, int g, int b) {
    return 0xFF000000 | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
  }
  
  void paint() {
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = colorFromRgb(
          lerp(r_grad, r_rot + (i << 8)),
          lerp(g_grad, g_rot + (i << 8)),
          lerp(b_grad, b_rot + (i << 8)));
    }
  }
  
  // Return the labels for the visualizer. This will enable three sliders.
  String[] getParameterLabels() {
    String[] s = {"r-spd", "g-spd", "b-spd"};
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
  
  int pseudorandom(BeatData bd, int seed) {
    int f = seed * 13;
    f ^= int(bd.beats * 111);
    f ^= int(bd.hardwareId * 5);
    f ^= int(bd.ticks);
    f += seed;
    return f;
  }
  
  void updateOnBeat(BeatData bd) {
    update_after_beat = bd.beats + 15;
    //r_grad = pseudorandom(bd, 0) & 0x7;
    //g_grad = pseudorandom(bd, 1) & 0x7;
    //b_grad = pseudorandom(bd, 2) & 0x7;
    update(bd);
    update_after_tick = bd.ticks + 1000;
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
    r_rot += bd.parameters[0] - 128;
    g_rot += bd.parameters[1] - 128;
    b_rot += bd.parameters[2] - 128;
    paint();
  }
} // visualizer