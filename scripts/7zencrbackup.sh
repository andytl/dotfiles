#!/usr/bin/env bash

if [[ $# -lt 3 ]] || [[ $# -gt 4 ]]; then
    echo "Incorrect args"
    echo "Usage:"
    echo "  $0 <Target folder> <Output zip> <Password file> [<Folder to test extraction>]"
    exit 1
fi

TARGET=$1
OUTPUT=$2
PASSWORD="$(< $3)"

echo "[$0] Delete $OUTPUT"
rm -f $OUTPUT

echo "[$0] Zip $TARGET with $PASSWORD"
7z a -mhe=on -p$PASSWORD -t7z $OUTPUT $TARGET
echo "[$0] Listing $TARGET"
7z l -p$PASSWORD $OUTPUT
#7z l -slt $OUTPUT

if [[ -n $4 ]]; then
    TESTEXTRACT=$4
    echo "[$0] Testing extraction to $TESTEXTRACT"
    rm -rf $TESTEXTRACT
    mkdir $TESTEXTRACT
    7z x -p$PASSWORD -o$TESTEXTRACT $OUTPUT
fi

echo "[$0] Done"
