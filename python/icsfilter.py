#!/usr/bin/env python3

import sys
import time
import re
import filehelper

argc = len(sys.argv)
argv = sys.argv

if argc != 4:
    print("Filters ICS files for events based on regex")
    print("Usage: %s <input> <output> <matchregex>" % argv[0])
    exit()

bVeventString = "BEGIN:VEVENT"
eVeventString = "END:VEVENT"

matchRegex = re.compile(argv[3])
inValidSection=True
currentSection=[]
def filterIcsFunc(lineIn):
    global inValidSection
    global currentSection
    if lineIn.startswith(bVeventString):
        inValidSection = False
    elif lineIn.startswith(eVeventString):
        shouldIgnore = not inValidSection
        inValidSection = True
        currentSection = []
        if shouldIgnore:
            # ignore end tags if they are not part of VEVENT being printed.
            return None
    elif lineIn.startswith("SUMMARY"):
        val = lineIn.split(":", 1)
        inValidSection = matchRegex.match(val[1]) is not None

    if not inValidSection:
        currentSection.append(lineIn)
        return None
    else:
        if len(currentSection) > 0:
            currentSection.append(lineIn)
            currentSectionTemp = currentSection
            currentSection = []
            return currentSectionTemp
        else:
            return lineIn

filehelper.lineByLine(argv[1], argv[2], filterIcsFunc)
