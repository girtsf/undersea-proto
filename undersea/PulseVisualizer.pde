// Every beat a random subset of nodes pulses up to max brightness.
//
// Idea: rpearl.

class PulseVisualizer extends Visualizer {
  static final int BEATS_UP = 1;
  static final int BEATS_DOWN = 2;

  // Value of previous beat seen. Used to detect start of new beat period.
  int mPrevBeat = 0;

  // Whether we are increasing (positive) or decreasing (negative) the brightness,
  // or remaining off (0).
  int dir = 0;
  // If we are on, what tick value to switch off or change direction.
  long endTicks = 0;
  // Hue value, set every time we pulse.
  int hue = 0;

  void process(BeatData bd) {
    if (mPrevBeat != bd.beats) {
      if ((dir == 0) && (int(random(0, 2)) == 0)) {
        // One in N chance to fire on a beat. 
        dir = 1;
        endTicks = bd.ticks + bd.beat_interval * BEATS_UP;
        // Pick a random-ish hue, synchronized to current beat value.
        hue = (bd.beats * 2281) % 255;
      }
      mPrevBeat = bd.beats;
    }
    if (dir > 0) {
      // Going up.
      if (bd.ticks > endTicks) {
        endTicks = bd.ticks + bd.beat_interval * BEATS_DOWN;
        dir = -1;
      } else {
        int b = (int)(255 * (endTicks - bd.ticks) / (bd.beat_interval * BEATS_UP)); 
        setAll(color(hue, 255, b));
      }
    }
    if (dir < 0) {
      // Going down.
      if (bd.ticks > endTicks) {
        dir = 0;
        setAll(#000000);
      } else {
        int b = (int)(255 * (endTicks - bd.ticks) / (bd.beat_interval * BEATS_DOWN)); 
        setAll(color(hue, 255, b));
      }
    }
  }
}