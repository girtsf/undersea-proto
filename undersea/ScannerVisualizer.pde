// Scans through all the jellies, one jelly lights up at a time.
// Node count parameter controls how many nodes there are total.

class ScannerVisualizer extends Visualizer {
  String[] getParameterLabels() {
    String[] s = {"node count"};
    return s;
  }

  int[] getParameterDefaults() {
    int[] d = {15};
    return d;
  }

  void process(BeatData bd) {
    int quarterBeats = 4 * bd.beats + (int)(4 * bd.beatTicks / bd.beatInterval);
    int nodeCount = bd.parameters[0];
    color c = #000000;  // black
    if (nodeCount == 0) nodeCount = 1;
    if ((quarterBeats % nodeCount) == bd.hardwareId) {
      int hue = bd.beats % 64 * 4;
      c = color(hue, 255, 255);
    }
    setAll(c);
  }
}