import controlP5.*;

class Sliders {
  final static int CHANNELS = 9;  // 8 params + global brightness
  final static byte CONTROL_CHANGE_START = (byte)0xb0;
  final static byte CONTROL_CHANGE_END = (byte)0xbf;

  int[] values = new int[CHANNELS];
  Slider[] sliders = new Slider[CHANNELS];
  // Mapping from MIDI control addresses to parametrs. E.g., index 0 describes the MIDI
  // address for parameter 0, etc.
  byte[] midiAddresses;
  // Callback to run when values have changed.
  Runnable callback;

  Sliders(ControlP5 cp5, byte[] midiAddresses, int x, int y) {
    for (int i = 0; i < CHANNELS; i++) {
      int value = 255;
      values[i] = value;
      final Slider s = cp5.addSlider("" + i).setPosition(x, y + 35 * i).setRange(0, 255).setSize(90, 30).setValue(value);
      sliders[i] = s;
      final int idx = i;
      s.addListener(new ControlListener() {
        public void controlEvent(ControlEvent theEvent) {
          values[idx] = (int)s.getValue();
          if (callback != null) callback.run();
        }
      }
      );
    }
    this.midiAddresses = midiAddresses;
  }
  
  void setChangeCallback(Runnable c) {
    callback = c;
  }

  int globalBrightness() {
    return values[CHANNELS - 1];
  }

  // Sets parameter labels, disables parameters with no labels.
  // Accepts null for no parameters.
  void setNames(String[] names) {
    if (names == null) {
      names = new String[0];
    }
    for (int i = 0; i < CHANNELS; i++) {
      if (i >= names.length || names[i] == null) {
        sliders[i].setVisible(false);
      } else {
        sliders[i].setVisible(true);
        sliders[i].setLabel(names[i]);
      }
    }
  }

  // Sets parameter values. Accepts null for no defaults.
  void setValues(int[] values) {
    if (values == null) {
      return;
    }
    for (int i = 0; i < values.length; i++) {
      sliders[i].setValue(values[i]);
    }
  }

  boolean isControlChangeCommand(byte note) {
    return (note >= CONTROL_CHANGE_START) && (note <= CONTROL_CHANGE_END);
  }

  StandardMidiListener midiListener = new StandardMidiListener() {
    void midiMessage(javax.sound.midi.MidiMessage message, long timeStamp) {
      byte[] bytes = message.getMessage();
      if (bytes.length == 3 && isControlChangeCommand(bytes[0])) {
        byte address = bytes[1];
        int value = (int)bytes[2] * 2;
        if (value == 254) value = 255;
        for (int i = 0; i < midiAddresses.length; i++) {
          if (midiAddresses[i] == address) {
            sliders[i].setValue(value);
            if (callback != null) callback.run();
            return;
          }
        }
      }
    }
  };
}