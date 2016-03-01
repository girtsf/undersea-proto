// BeatData represents timing information - how many beats per measure,
// which beat we are on, where in the beat we are, etc.
//
// The BeatData object is managed by the UnderSea framework and passed to each
// visualizer every time a "frame" is drawn. The beat timing comes from the master
// node and is synchronized across all nodes.
class BeatData {
  // Unique hardware identifier, [0..65535]. Can be used to randomize the
  // patterns across the jellies.
  int hardware_id;

  // Number of beats in a measure. Most likely 4.
  int beats_per_measure;

  // Which beat in the measure? [0, beats_per_measure)
  int beat_in_measure;

  // The length of a single beat interval (quarter note length).
  //
  // The time units here are ticks and there are 32767 ticks in a second. This corresponds
  // to the way the microcontroller is tracking time.
  int beat_interval;

  // How many ticks have already passed in this beat interval. This will be [0, beat_interval).
  int beat_ticks;

  // How many measures have passed since the start of this visualization pattern.
  int measure;
}