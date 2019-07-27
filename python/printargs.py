#!/usr/bin/env python3

import sys

print("printargs: Got {0} args".format(len(sys.argv)))
i = 1
for arg in sys.argv:
    print("arg {0}:{1}".format(i, arg))
    i = i + 1