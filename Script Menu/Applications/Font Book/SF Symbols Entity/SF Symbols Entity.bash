#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#
#################################################

mkdir -p ~/Desktop/SFSymbols

STR_START=0x100000
STR_END=0x102FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done
