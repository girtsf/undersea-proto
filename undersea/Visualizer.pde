// Base class for visualizers.
abstract class Visualizer {
  // Contains pixels for the jelly.
  color[] pixels;

  // Method to be implemented by each visualizer. Takes beat data and
  // modifies pixels.
  abstract void process(BeatData beatData);

  // Override to set labels. Number of items in the array will determine
  // how many parameter knobs will be shown.
  String[] getParameterLabels() {
    return null;
  }

  // Override to set default values for each knob. Must match the count of
  // getParameterLabels array.
  int[] getParameterDefaults() {
    return null;
  }

  // Sets all pixel values to given color. 
  void setAll(color c) {
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = c;
    }
  }
}