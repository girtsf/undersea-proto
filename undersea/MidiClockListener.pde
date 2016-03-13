int numPulses = 0;
final static int pulsesPerBar = 24 * 4;
float barClock = 0.0;

void midiMessage(MidiMessage message) {
  if (message.getStatus() == 0xF2) {
    //0xF2 is the status byte for SONG_POSITION_POINTER

    /**
     byte[] data = message.getMessage();
     
     println("Pointer LSB: "+(int)(data[1] & 0xFF));
     println("Pointer MSB: "+(int)(data[2] & 0xFF));
     */
  } else if (message.getStatus() == 0xF8) {
    //0xF8 is the status byte for TIMING_CLOCK

    //println("There was a timing tick");
    numPulses++;
    if (numPulses > pulsesPerBar) {
      numPulses -= pulsesPerBar;
      println("Downbeat");
    }

    barClock = numPulses / (pulsesPerBar * 1.0);    
  }
}