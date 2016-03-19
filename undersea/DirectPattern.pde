class DirectPatternVisualizer extends Visualizer {
  
  // Return the labels for the visualizer. This will enable three sliders.
  String[] getParameterLabels() {
    String[] s = {"red", "green", "blue", "led", "node"};
    return s;
  }
 
  int[] getParameterDefaults() {
    int[] r = {0, 0, 35, 0, 0};
    return r;
  }
  
  void process(BeatData bd) {
    // By default, visualizers will use HSB, but we use RGB for this one.
    if (bd.hardwareId == bd.parameters[4] || bd.parameters[4] == 0) {
      colorMode(RGB, 255);   
      pixels[bd.parameters[3] % pixels.length] = color(bd.parameters[0], bd.parameters[1], bd.parameters[2]);
    }
  }
}