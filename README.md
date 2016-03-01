# What?

Prototype for LED jelly visualization algorithms, written in Processing.

# Requirements

You will need Processing: https://processing.org/download/

# Hacking

Take a look at BlahVisualizer.pde files. Each Visualizer implements
a process() method that takes BeatData and updates pixels[] array.

To add a new visualizer, create a new FooVisualizer.pde file. Then
add the class to the array near the top of undersea.pde.

# Ideas

* (from rpearl) relatively-prime fades. each k-th node pulses for an interval
  of (kth prime) beats.
* manual proximity. the VJ UI would have a quick way to light up each node
  and keys to assign some sort of 1D or 2D order.
