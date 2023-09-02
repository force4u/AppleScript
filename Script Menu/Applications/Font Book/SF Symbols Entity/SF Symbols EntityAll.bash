#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#
#################################################

mkdir -p ~/Desktop/SFSymbols

STR_START=0x100000
STR_END=0x100FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/0Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x101000
STR_END=0x101FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/1Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


STR_START=0x102000
STR_END=0x102FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/2Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


STR_START=0x103000
STR_END=0x103FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/3Entity.txt
      printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x104000
STR_END=0x104FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/4Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x105000
STR_END=0x105FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/5Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x106000
STR_END=0x106FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/6Entity.txt
      printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x107000
STR_END=0x107FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/7Entity.txt
     printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x108000
STR_END=0x108FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/8Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


STR_START=0x109000
STR_END=0x109FFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/9Entity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


STR_START=0x10A000
STR_END=0x10AFFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/AEntity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x10B000
STR_END=0x10BFFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/BEntity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


STR_START=0x10C000
STR_END=0x10CFFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/CEntity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


STR_START=0x10D000
STR_END=0x10DFFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/DEntity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done

STR_START=0x10E000
STR_END=0x10EFFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/EEntity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


STR_START=0x10F000
STR_END=0x10FFFF
for ((i=STR_START; i<=STR_END; i++)); do
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i >> ~/Desktop/SFSymbols/FEntity.txt
    printf "U+%06X\t&amp;#x%08X;\t&#x%08X;\n" $i $i $i
done


exit 0
