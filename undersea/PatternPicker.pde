class PatternPicker {
  ScrollableList mPatternList;
  Runnable mCallback;

  // Toggle for the visualizer.
  Toggle mSimToggle;
  // Input for autoswitch timing.
  Textfield mAutoSwitch;

  int mAutoSwitchSeconds = 0;
  int mNextSwitchAt = -1;


  PatternPicker(ControlP5 cp5, int x, int y, int width, int height) {
    mPatternList = cp5
      .addScrollableList("pattern")
      .setPosition(x, y + 50)
      .setSize(width, height)
      .setType(ControlP5.LIST)
      //.setBarVisible(false)
      .setItemHeight(30);

    mSimToggle = cp5.addToggle("show sim").setPosition(x, y).setValue(true);

    mAutoSwitch = cp5.addTextfield("autoswitch seconds")
      .setPosition(x + 60, y)
      .setSize(50, 30)
      .setText("0")
      .setAutoClear(false);
    mAutoSwitch.addListener(new ControlListener() {
      void controlEvent(ControlEvent theEvent) {
        try {
          mAutoSwitchSeconds = Integer.parseInt(mAutoSwitch.getText());
          if (mAutoSwitchSeconds < 0) mAutoSwitchSeconds = 0;
        } 
        catch (NumberFormatException ex) {
          println("can't parse seconds");
        }
        mAutoSwitch.setText("" + mAutoSwitchSeconds);
        if (mAutoSwitchSeconds > 0) {
          mNextSwitchAt = millis() + mAutoSwitchSeconds * 1000;
        }
      }
    }    
    );

    for (int i = 0; i < VISUALIZERS.length; i++) {
      Class c = VISUALIZERS[i];
      String n = getPatternNameFromClass(c);
      Integer pat = PATTERN_INDICES.get(n);
      if (pat == null) pat = -1;
      String label = "[" + i + "] " + n;
      mPatternList.addItem(label, Integer.valueOf(pat));
      if (pat < 0) {
        // Pattern that is not yet implemented on the jelly.
        CColor col = new CColor();
        col.setBackground(#555555);     
        mPatternList.getItem(i).put("color", col);
      }
    }
    mPatternList.addListener(changeListener);
  }

  void maybeAutoSwitch() {
    if (mAutoSwitchSeconds <= 0) return;
    if (millis() > mNextSwitchAt) {
      mNextSwitchAt = millis() + mAutoSwitchSeconds * 1000;
      nextVisualizer(1);
    }
  }

  boolean showSim() {
    return mSimToggle.getBooleanValue();
  }

  void setShowSim(boolean value) {
    mSimToggle.setValue(value);
  }

  ControlListener changeListener = new ControlListener() {
    public void controlEvent(ControlEvent theEvent) {
      switchVisualizer();
    }
  };

  void setChangeCallback(Runnable c) {
    mCallback = c;
  }

  // Picks next visualizer in the given direction (1: next, -1: prev).
  void nextVisualizer(int dir) {
    int visualizerIdx = idx() + dir;
    if (visualizerIdx < 0) {
      visualizerIdx = VISUALIZERS.length - 1;
    }
    if (visualizerIdx >= VISUALIZERS.length) {
      visualizerIdx = 0;
    }
    mPatternList.setValue(visualizerIdx);
    switchVisualizer();
  }

  void switchVisualizer() {
    Class v = VISUALIZERS[idx()];
    setVisualizer(v);
    if (mCallback != null) mCallback.run();
  }

  int idx() {
    return (int) mPatternList.getValue();
  }

  int patternNum() {
    return (int) mPatternList.getItem(idx()).get("value");
  }

  String name() {
    return (String) mPatternList.getItem(idx()).get("text");
  }
}