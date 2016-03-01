// Base class for visualizers.
abstract class Visualizer {
  // Contains pixels for the jelly.
  color[] pixels;
  // Method to be implemented by each visualizer. Takes beat data and
  // modifies pixels.
  abstract void process(BeatData beatData);
}