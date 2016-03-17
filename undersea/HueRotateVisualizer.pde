class HueRotateVisualizer extends Visualizer {
  static final int PATTERN_IDX = 0;
  float rotatePosition = 0;
  long lastTicks = -1;

  String[] getParameterLabels() {
    String[] s = {"rotate speed"};
    return s;
  }

  int[] getParameterDefaults() {
    int[] d = {102};  // roughly one revolution per beat
    return d;
  }

  void process(BeatData bd) {
    if (lastTicks > 0) {
      long ticksDiff = bd.ticks - lastTicks;
      float speed = 5.0 * float(bd.parameters[0] - 128) / 128;  // -5 .. 5
      float speedPart = speed * ticksDiff / bd.beatInterval;
      // println("speed: " + speed + " ticksDiff:" + ticksDiff + " speedPart:" + speedPart);
      rotatePosition = (rotatePosition + speedPart) % 1;  // rotatePosition is 0..1
      if (rotatePosition < 0) rotatePosition += 1;
      // println("rotatePos: " + rotatePosition);

      // Hue is determined by the cumulative beat counter. We increment it
      // by 4 on every beat.
      int hue = bd.beats % 64 * 4;

      for (int i = 0; i < pixels.length; i++) {
        float posThis = (rotatePosition + i * 1.0 / pixels.length) % 1;
        int b = 100 + (int)(155 * posThis);
        // println("i: " + i + " posThis:" + posThis + " b: " + b);
        pixels[i] = color(hue, 255, b);
      }
    } else {
      // Start in a random position.
      rotatePosition = random(0, 1);
    }
    lastTicks = bd.ticks;
  }
}