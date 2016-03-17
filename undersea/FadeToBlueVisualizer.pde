// This is a pulse visualizer that never allows the umbrella to go
// dark -- we swell into some color and then gradually fade to
// deep-ocean blue.
//
// Idea: rpearl.

class FadeToBlueVisualizer extends Visualizer {
  // Value of previous beat seen. Used to detect start of new beat period.
  int next_beat = 0;

  // final color
  int final_r = 29;
  int final_g = 0;
  int final_b = 185;
  
  int[] r = new int[2];
  int[] g = new int[2];
  int[] b = new int[2];
  long next_update = 0;
  
  void updateColors() {
    for (int i = 0; i < pixels.length; i+=2) {
      pixels[i+0] = 0xFF000000 + (r[0] << 16) + (g[0] << 8) + b[0];
      pixels[i+1] = 0xFF000000 + (r[1] << 16) + (g[1] << 8) + b[1];
    }
  }

  void process(BeatData bd) {

    if ((bd.beats + (bd.hardwareId & 0x1)) > next_beat) {
      next_beat += 2;
      int select = bd.beats + bd.hardwareId * 4;
      // beat boundary
      r[0] = (select * 2281) % 255;
      g[0] = (select * 5849) % 255;
      b[0] = (select * 3041) % 255;
      r[1] = (select * 5281) % 255;
      g[1] = (select * 6849) % 255;
      b[1] = (select * 7041) % 255;
      updateColors();
      next_update = bd.ticks + 2000;
    } else {
      // there are 32k ticks per second, and we want to update
      // our colors about once per millisecond     
      if (bd.ticks > next_update) {
        next_update += 2000;
        // average us towards blue
        r[0] = ((3 * r[0]) + final_r) >> 2;
        g[0] = ((7 * g[0]) + final_g) >> 3;
        b[0] = ((15 * b[0]) + final_b) >> 4;
        r[1] = ((15 * r[1]) + final_r) >> 4;
        g[1] = ((7 * g[1]) + final_g) >> 3;
        b[1] = ((15 * b[1]) + final_b) >> 4;
        updateColors();
      }
    }
  }  // process
} // visualizer