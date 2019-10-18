
import utils
import io

def lineByLine (inf, outf, lineProcessFn):
    with open(inf, "rt", encoding="utf8") as r, open(outf, "wt", encoding="utf8") as w:
        for lineIn in r:
            lineOut = lineProcessFn(lineIn)
            if lineOut and utils.isIterable(lineOut):
                w.writelines(lineOut)
            elif lineOut:
                w.write(lineOut)
