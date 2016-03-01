// Simple example visualizer that flashes once per beat.
class FlashVisualizer extends Visualizer {
  int mPrevBeat = 0;

  void process(BeatData bd) {
    color c;
    if (mPrevBeat != bd.beat_in_measure) {
      // We haven't seen this beat yet. Flash!
      c = #ffffff;  // white
    } else {
      c = #000000;  // black
    }
    mPrevBeat = bd.beat_in_measure;
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = c;
    }
  }
}