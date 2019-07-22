TARGET=~/git/dotfiles/files
OUTPUT=~/Downloads/dotfiles.7z
TESTEXTRACT=~/Downloads/test
PASSWORD=TestPassword

rm -f $OUTPUT
rm -rf $TESTEXTRACT
mkdir $TESTEXTRACT

7z a -mhe=on -p$PASSWORD -t7z $OUTPUT $TARGET
7z l -p$PASSWORD $OUTPUT
#7z l -slt $OUTPUT
7z x -p$PASSWORD -o$TESTEXTRACT $OUTPUT

