// Example of handling parameters.
//
// Parameters 0-2 are R, G, B channels respectively.
class SingleColorVisualizer extends Visualizer {
  void process(BeatData bd) {
    // By default, visualizers will use HSB, but we use RGB for this one.
    colorMode(RGB, 255);
    setAll(color(bd.patternData[0], bd.patternData[1], bd.patternData[2]));
  }
}