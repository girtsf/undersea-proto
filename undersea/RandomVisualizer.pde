class RandomVisualizer extends Visualizer {
  int mPrevBeat = 0;
  
  void process(BeatData bd) {
    if (bd.beat_in_measure == mPrevBeat) return;
    mPrevBeat = bd.beat_in_measure; 
    for (int i = 0; i < pixels.length; i++) {
      // Assign random colors to the pixels.
      int hue = int(random(0, 255));
      pixels[i] = color(hue, 255, 255);
    }
  }
}