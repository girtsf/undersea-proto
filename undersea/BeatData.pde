// BeatData represents timing information - how many beats per measure,
// which beat we are on, where in the beat we are, etc.
//
// The BeatData object is managed by the UnderSea framework and passed to each
// visualizer every time a "frame" is drawn. The beat timing comes from the master
// node and is synchronized across all nodes.
class BeatData {
  // Unique hardware identifier, [0..65535]. Can be used to randomize the
  // patterns across the jellies.
  int hardwareId;

  // Number of beats in a measure. Most likely 4.
  int beatsPerMeasure;

  // Which beat in the measure? [0, beats_per_measure)
  int beatInMeasure;

  // The length of a single beat interval (quarter note length).
  //
  // The time units here are ticks and there are 32767 ticks in a second. This corresponds
  // to the way the microcontroller is tracking time.
  int beatInterval;

  // How many ticks have already passed in this beat interval. This will be [0, beat_interval).
  int beatTicks;

  // How many measures have passed since the start of this visualization pattern.
  int measure;

  // ---------------------------------------------------------------------------
  // Convenience fields: these can be calculated from the fields above, but are
  // provided for convenience.

  // How many beats have elapsed since the start of this pattern.
  int beats;

  // How many ticks have elapsed since the start of this pattern.
  long ticks;
  
  // ---------------------------------------------------------------------------
  // Pattern specific data: the interface for this might change, but for now, assume
  // that patternData contains 8 values, each [0, 255].
  int patternData[];
}