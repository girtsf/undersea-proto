class HueRotateVisualizer extends Visualizer {
  int mPrevBeat = 0;
  int hue = 0;
  int randomRotate = -1;
  
  void process(BeatData bd) {
    if (randomRotate == -1) {
      randomRotate = int(random(0, 256));
    }
    mPrevBeat = bd.beat_in_measure;
    
    int beat = bd.measure * bd.beats_per_measure + bd.beat_in_measure;
    // Hue is determined by the cumulative beat counter. We increment it
    // by 4 on every beat.
    hue = beat % 64 * 4;
     
    for (int i = 0; i < pixels.length; i++) {
      int within_beat = pixels.length * bd.beat_ticks / bd.beat_interval;
      // println("wb: " + within_beat + " bt: " + bd.beat_ticks + " bi: " + bd.beat_interval);
      int r = (i + within_beat + randomRotate) % pixels.length;
      int b = 155 + 100 * r / pixels.length;
      pixels[i] = color(hue, 255, b);
    }
  }
}