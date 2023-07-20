#!/usr/bin/env /usr/bin/osascript -l JavaScript
//----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
//
//com.cocolog-nifty.quicktimer.icefloe
//----+----1----+----2----+-----3----+----4----+----5----+----6----+----7


ObjC.import('Foundation'); 


var capp = Application.currentApplication(),
cApp = (capp.includeStandardAdditions = true, capp);

var sapp = Application("System Events");
sApp = (sapp.includeStandardAdditions = true, sapp);

var fapp = Application("Finder");
fApp = (fapp.includeStandardAdditions = true, fapp);

var cLib = Library("Configuration Utility")

cLib.cNFGshowHelp();


