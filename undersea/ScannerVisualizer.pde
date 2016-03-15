// Scans through all the jellies, one jelly lights up at a time.
// Node count parameter controls how many nodes there are total.

class ScannerVisualizer extends Visualizer {
  int mPrevBeat = 0;

  int[] PRIMES = {2, 3, 5, 7, 11};

  String[] getParameterLabels() {
    String[] s = {"node count"};
    return s;
  }

  int[] getParameterDefaults() {
    int[] d = {15};
    return d;
  }

  void process(BeatData bd) {
    int quarterBeats = (int)(bd.ticks / (bd.beatInterval / 4));
    int nodeCount = bd.parameters[0];
    color c = #000000;  // black
    if ((quarterBeats % nodeCount) == bd.hardwareId) {
      int hue = bd.beats % 64 * 4;
      c = color(hue, 255, 255);
    }
    setAll(c);
  }
}