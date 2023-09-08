#!/usr/bin/env python3

from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF, renderPM
import sys
import os

args = sys.argv

strFilePath = args[1]
strFileDir = os.path.dirname(strFilePath)
strFileName = os.path.basename(strFilePath)
strBaseFileName = os.path.splitext(os.path.basename(strFilePath))[0]


print("strFilePath:" + strFilePath)
print("strFileDir:" + strFileDir)
print("strFileName:" + strFileName)
print("strBaseFileName:" + strBaseFileName)


drawing = svg2rlg(strFilePath)
renderPDF.drawToFile(drawing, strFileDir + "/" + strBaseFileName + ".pdf")
