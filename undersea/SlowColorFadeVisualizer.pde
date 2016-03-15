class SlowColorFadeVisualizer extends Visualizer {

  final static int HUE_MULTI = 8;
  final static int LIGHT_MULTI = 4;
  final static int LIGHT_PERIOD_MULTI = 5;

  void process(BeatData bd) {

    float ticksPerMeasure = bd.beatInterval * bd.beatsPerMeasure;
    float ticksPerHueRot = ticksPerMeasure * HUE_MULTI;
    float ticksPerLightRot = ticksPerMeasure * LIGHT_MULTI;
    float ticksPerLightPeriod = ticksPerMeasure * LIGHT_PERIOD_MULTI;
    float hueCounter = (bd.ticks % ticksPerHueRot) / ticksPerHueRot; // float 0.0-1.0
    float lightCounter = (bd.ticks % ticksPerLightRot) / ticksPerLightRot; // float 0.0-1.0
    float lightPeriodCounter = (bd.ticks % ticksPerLightPeriod) / ticksPerLightPeriod; // float 0.0-1.0
    // Hue is determined by the cumulative beat counter. We increment it
    // by 4 on every beat.

    int hue = int(hueCounter * 255.0);
    int lightPeriodDegs = int(
      lightPeriodCounter * 360.0
    );
    float lightPeriod = (sin(radians(lightPeriodDegs)) * 360.0) + 360.0;
    
    for (int i = 0; i < pixels.length; i++) {
      
      int pixelLightDegs = int(
        (lightCounter * lightPeriod) + 
        ((float(i)/float(pixels.length)) * lightPeriod)
      );      
      int light = int(sin(radians(pixelLightDegs)) * 64.0) + 64;
      pixels[i] = color(hue, 255, light);
    }
  }
}