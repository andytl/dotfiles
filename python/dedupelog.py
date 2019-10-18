import io
import time
import re

#TODO: Parameterize in/out.
inf = "input.txt"
outf = "output.txt"


#TODO use filehelper.lineByLine
linesProcessed = 0
linesProcessedPrev = 0
lastReportTime = time.time()
previousLine = None
REPORT_INTERVAL = 5
ignoreRegex = re.compile("^\\s+$")
dedupeCount = 0
with open(inf, "r") as r, open(outf, "w") as w:
    for line in r:
        if line == previousLine and not ignoreRegex.match(line): # don't dedupe whitespace.
            dedupeCount += 1
        else:
            if dedupeCount > 0:
                w.write("DEDUPED %d instances of-> %s\r\n" % (dedupeCount, previousLine))
                dedupeCount = 0
            w.write(line)
        previousLine = line
        linesProcessed += 1
        if time.time() > lastReportTime + REPORT_INTERVAL:
            print("Processed %d lines, rate %d lines/sec" % (linesProcessed, (linesProcessed - linesProcessedPrev) / REPORT_INTERVAL))
            lastReportTime = time.time()
            linesProcessedPrev = linesProcessed
