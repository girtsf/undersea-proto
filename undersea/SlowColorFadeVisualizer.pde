class SlowColorFadeVisualizer extends Visualizer {

  final static int MEASURE_MULTI = 8;

  void process(BeatData bd) {

    float ticksPerMeasure = bd.beatInterval * bd.beatsPerMeasure;
    float ticksPerHueRot = ticksPerMeasure * MEASURE_MULTI;
    float barPos = (bd.ticks % ticksPerHueRot) / ticksPerHueRot; 
    // Hue is determined by the cumulative beat counter. We increment it
    // by 4 on every beat.

    int hue = int(barPos * 255.0);

    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = color(hue, 255, 255);
    }
  }
}