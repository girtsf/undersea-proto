class RandomVisualizer extends Visualizer {
  int mPrevBeat = 0;
  int hue = 0;

  void process(BeatData bd) {
    if (bd.beatInMeasure == mPrevBeat) {
      // Only change the color once per beat. If we
      // are still on same beat, then return.
      return;
    }

    hue = int(random(0, 255));
    mPrevBeat = bd.beatInMeasure;
    for (int i = 0; i < pixels.length; i++) {
      // Assign random brightness to each pixel. Keep the random
      // range constrained to medium to bright.
      int brightness = int(random(150, 255));
      pixels[i] = color(hue, 255, brightness);
    }
  }
}