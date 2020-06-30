
make clean; make
python parse.py $1 "$1.syn"
./sequencer "$1.syn"
rm "$1.syn"
make clean;
