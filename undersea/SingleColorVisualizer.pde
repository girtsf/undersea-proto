// Example of handling parameters.
//
// Parameters 0-2 are R, G, B channels respectively.
class SingleColorVisualizer extends Visualizer {
  
  // Return the labels for the visualizer. This will enable three sliders.
  String[] getParameterLabels() {
    String[] s = {"red", "green", "blue"};
    return s;
  }
 
  int[] getParameterDefaults() {
    int[] r = {0, 0, 35};
    return r;
  }
  
  void process(BeatData bd) {
    // By default, visualizers will use HSB, but we use RGB for this one.
    colorMode(RGB, 255);
    setAll(color(bd.parameters[0], bd.parameters[1], bd.parameters[2]));
  }
}