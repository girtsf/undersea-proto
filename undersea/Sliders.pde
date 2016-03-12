import controlP5.*;

class Sliders {
  final static int CHANNELS = 8;
  int[] values = new int[CHANNELS]; 

  Sliders(ControlP5 cp5) {
    for (int i = 0; i < CHANNELS; i++) {
      float value = 255.0 / CHANNELS * i;
      final Slider s = cp5.addSlider("" + i).setPosition(width - 145, 50 + 35 * i).setRange(0, 255).setSize(90, 30).setValue(value);
      final int idx = i;
      s.addListener(new ControlListener() {
        public void controlEvent(ControlEvent theEvent) {
          values[idx] = (int)s.getValue();
        }
      });
    }
  }
}