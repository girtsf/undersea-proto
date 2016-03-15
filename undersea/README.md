# What?

Prototype for LED jelly visualization algorithms, written in Processing.

# Requirements

You will need:
* Processing: https://processing.org/download/
* controlP5 library: http://www.sojamo.de/libraries/controlP5/
* MidiBus library: http://www.smallbutdigital.com/themidibus.php

You can install the libraries by clicking Sketch > Import Library > Add Library
and searching by name.

# Hacking

Take a look at BlahVisualizer.pde files. Each Visualizer implements
a process() method that takes BeatData and updates pixels[] array.

To add a new visualizer, create a new FooVisualizer.pde file. Then
add the class to the array near the top of undersea.pde.

# Ideas

* manual proximity. the VJ UI would have a quick way to light up each node
  and keys to assign some sort of 1D or 2D order.

# TODO

* Implement node id
* Implement bitfields for node ids
* Frequency chooser (+scanner on nodes?)
* Rate limit radio messages
* Global brightness slider
