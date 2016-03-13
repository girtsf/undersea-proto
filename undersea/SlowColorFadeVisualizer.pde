class SlowColorFadeVisualizer extends Visualizer {

  final static int HUE_MULTI = 8;
  final static int LIGHT_MULTI = 4;

  void process(BeatData bd) {

    float ticksPerMeasure = bd.beatInterval * bd.beatsPerMeasure;
    float ticksPerHueRot = ticksPerMeasure * HUE_MULTI;
    float ticksPerLightRot = ticksPerMeasure * LIGHT_MULTI;
    float hueCounter = (bd.ticks % ticksPerHueRot) / ticksPerHueRot; // float 0.0-1.0
    float lightCounter = (bd.ticks % ticksPerLightRot) / ticksPerLightRot; // float 0.0-1.0
    // Hue is determined by the cumulative beat counter. We increment it
    // by 4 on every beat.

    int hue = int(hueCounter * 255.0);
    

    for (int i = 0; i < pixels.length; i++) {
      int pixelLightDegs = int((lightCounter * 360.0) + ((float(i)/float(pixels.length)) * 360.0));      
      int light = int(sin(radians(pixelLightDegs)) * 64) + 64;
      pixels[i] = color(hue, 255, light);
    }
  }
}