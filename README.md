# What?

Prototype for LED jelly visualization algorithms, written in Processing.

# Requirements

You will need Processing: https://processing.org/download/

# Hacking

Take a look at BlahVisualizer.pde files. Each Visualizer implements
a process() method that takes BeatData and updates pixels[] array.

To add a new visualizer, create a new FooVisualizer.pde file. Then
add the class to the array in undersea.pde:setup().
