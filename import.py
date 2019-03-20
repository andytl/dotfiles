#!/usr/bin/env python3

import sys
import json
import shutil
from pathlib import Path

EXPECTED_ARGS = 3

def usage(errorMsg):
    print("Usage: import.py <homedir> <dotfilerepodir> <import|backup>")
    if errorMsg:
        print("Error: " + errorMsg)

def getPlatform():
    rawPlatform = sys.platform.lower()
    if rawPlatform.startswith("win"):
        platform = "Windows"
    elif rawPlatform.startswith("darwin"):
        platform = "Mac"
    elif rawPlatform.startswith("linux"):
        platform = "Linux"
    else:
        raise Exception("Unknown platform")
    return platform

def readConfigFile(repoDir):
    platform = getPlatform()
    with Path(repoDir, "mappings.json").open() as json_file:
        mapping = json.load(json_file)
    return [x for x in mapping if platform in x["Platforms"]]

def recursiveCopyNode(srcLoc, dstLoc):
    #print("recursiveCopyNode({0},{1})".format(srcLoc, dstLoc))
    if not srcLoc.exists():
        print("{0} does not exist".format(srcLoc))
    elif srcLoc.is_dir():
        print("In Dir: {0}".format(srcLoc))
        dstLoc.mkdir(parents=True, exist_ok=True)
        for node in srcLoc.iterdir():
            fileName = node.relative_to(srcLoc);
            recursiveCopyNode(node, Path(dstLoc, fileName))
    else:
        print("File: {0} -> {1}".format(srcLoc, dstLoc))
        shutil.copy(str(srcLoc), str(dstLoc))

def processMapping(homeDir, repoDir, mode, mapping):
    repoLoc = Path(repoDir, mapping["Source"])
    homeLoc = Path(homeDir, mapping["Destination"])
    if mode == "import":
        srcLoc = repoLoc
        dstLoc = homeLoc
    else: # "backup"
        srcLoc = homeLoc
        dstLoc = repoLoc
    dstLoc.parent.mkdir(parents=True, exist_ok=True)
    recursiveCopyNode(srcLoc, dstLoc)


def importMain():
    numArgs = len(sys.argv)
    #print("{0} args: {1}".format(numArgs, sys.argv))
    if numArgs - 1 != EXPECTED_ARGS:
        usage("Expected {0} args, got {1}".format(EXPECTED_ARGS, numArgs - 1))
        return
    homeDir, repoDir, mode = sys.argv[1:]
    if mode not in ["import", "backup"]:
        usage("invalid mode: {0}".format(mode))
        return
    config = readConfigFile(repoDir)
    for mapping in config:
        processMapping(homeDir, repoDir, mode, mapping)

importMain()