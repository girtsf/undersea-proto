#!/usr/bin/env python
#
# Quick hack to generate MIDI clock for testing.
#
# Reqs:
# $ pip install simplecoremidi
#
# Usage:
# $ ./midi_clock_generator.py [bpm]

from __future__ import print_function

import simplecoremidi
import sys
import time


def Main(bpm):
    bps = bpm / 60
    time_per_beat = 1.0 / bps
    interval = time_per_beat / 24.0
    print('BPM: %d sleep interval: %f' % (bpm, interval))
    while True:
        d = simplecoremidi.send_midi([0xf8])
        # TODO: this should keep track of time slept to be more accurate.
        time.sleep(interval)


if __name__ == '__main__':
    bpm = 120.0
    if len(sys.argv) > 1:
        bpm = float(sys.argv[1])
    Main(bpm)
