// Flashes every prime-th interval, based on node id.
//
// Idea: rpearl.
class PrimeVisualizer extends Visualizer {
  int mPrevBeat = 0;

  int[] PRIMES = {2, 3, 5, 7, 11}; 

  void process(BeatData bd) {
    color c = #000000;  // black
    if (mPrevBeat != bd.beatInMeasure) {
      // We haven't seen this beat yet. Flash if we are on a kth prime.
      int myPrime = PRIMES[bd.hardwareId % PRIMES.length];
      if ((bd.beats % myPrime) == 0) {
        int hue = (bd.beats * 2281) % 255;
        c = color(hue, 255, 255);
      }

      mPrevBeat = bd.beatInMeasure;
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = c;
      }
    }
  }
}