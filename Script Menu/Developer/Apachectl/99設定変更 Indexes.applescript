#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

####WebServer�f�B���N�g���A�N�Z�X��
set strCommandText to "/usr/bin/sudo /bin/chmod 777 �"/Library/WebServer/Documents�""
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/bin/chgrp www �"/Library/WebServer/Documents�""
do shell script strCommandText with administrator privileges
### Indexes MultiViews�p��index�����l�[��
try
	set strCommandText to "/usr/bin/sudo /bin/mv -f �"/Library/WebServer/Documents/index.html.en�" �"/Library/WebServer/Documents/index.backup.html.en�""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /bin/rm -f �"/Library/WebServer/Documents/index.html.en�""
	do shell script strCommandText with administrator privileges
end try
####���L�T�C�g�t�H���_�쐬
set strCommandText to "/usr/bin/sudo /bin/mkdir -p /Users/Shared/Sites"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod -Rf 755 /Users/Shared/Sites"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/bin/chgrp -Rf www /Users/Shared/Sites"
do shell script strCommandText with administrator privileges

set strCommandText to "[[ -e �"/Library/WebServer/Documents/Shared�" ]] && /bin/echo true  || /bin/echo false "
set boolFileExist to (do shell script strCommandText) as boolean
if boolFileExist is false then
	set strCommandText to "/usr/bin/sudo /bin/ln -s �"/Users/Shared/Sites�" �"/Library/WebServer/Documents/Shared�""
	do shell script strCommandText with administrator privileges
end if
########���[�J�����[�U�[���擾
set strCommandText to "/usr/bin/dscl . list /Users | grep -v '^_' | grep -v 'admin' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'"
set strCommandText to "/usr/bin/dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'"
set strLocalUser to do shell script strCommandText
set AppleScript's text item delimiters to "�r"
set listLocalUser to every text item of strLocalUser
set AppleScript's text item delimiters to ""
########���[�U�[�T�C�g�t�H���_�쐬
repeat with itemLocalUser in listLocalUser
	set strLocalUser to itemLocalUser as text
	set strCommandText to "/usr/bin/sudo /bin/mkdir -p �"/Users/" & strLocalUser & "/Sites�""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /usr/bin/touch �"/Users/" & strLocalUser & "/Sites/.localized�""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /usr/sbin/chown -Rf " & strLocalUser & " �"/Users/" & strLocalUser & "/Sites�""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /usr/bin/chgrp -Rf www �"/Users/" & strLocalUser & "/Sites�""
	do shell script strCommandText with administrator privileges
	set strCommandText to "/usr/bin/sudo /bin/chmod 755 �"/Users/" & strLocalUser & "/Sites�""
	do shell script strCommandText with administrator privileges
	
	set strCommandText to "[[ -e �"/Library/WebServer/Documents/" & strLocalUser & "�" ]] && /bin/echo true  || /bin/echo false "
	set boolFileExist to (do shell script strCommandText) as boolean
	if boolFileExist is false then
	set strCommandText to "/usr/bin/sudo /bin/ln -s �"/Users/" & strLocalUser & "/Sites�" �"/Library/WebServer/Documents/" & strLocalUser & "�""
	do shell script strCommandText with administrator privileges
	end if
end repeat


####���O�t�@�C��
set strCommandText to "/usr/bin/sudo /bin/mkdir -p /private/var/log/apache2"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/bin/touch /private/var/log/apache2/error_log"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/bin/touch /private/var/log/apache2/access_log"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/bin/touch /private/var/log/apache2/combined_log"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /usr/sbin/chown -Rf www /private/var/log/apache2"
do shell script strCommandText with administrator privileges

###�A�p�b�`��~
set strCommandText to "/usr/bin/sudo /usr/sbin/apachectl stop"
do shell script strCommandText with administrator privileges
try
	set strCommandText to "/usr/bin/sudo /usr/sbin/apachectl stop -w /System/Library/LaunchDaemons/org.apache.httpd.plist"
	do shell script strCommandText with administrator privileges
end try
try
	set strCommandText to "/usr/bin/sudo /usr/sbin/apachectl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist"
	do shell script strCommandText with administrator privileges
end try

###�ݒ�ύX�̒l��ۑ��ł���悤�Ɉꎞ�I�ȃA�N�Z�X��
set strCommandText to "/usr/bin/sudo /bin/chmod 777 /private/etc/apache2"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 777 /private/etc/apache2/httpd.conf"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 777 /private/etc/apache2/extra"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 777 /private/etc/apache2/extra/httpd-userdir.conf"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 777 /private/etc/apache2/users"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 777 /private/etc/apache2/users/*conf"
do shell script strCommandText with administrator privileges



#############################
##�ݒ�ύX
#############################
####�ǂݍ��ރt�@�C��
set ocidFilePath to refMe's NSString's stringWithString:"/private/etc/apache2/httpd.conf"
###�t�@�C���̓��e��ǂݍ���
set listReadFile to refMe's NSString's stringWithContentsOfFile:ocidFilePath encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

set ocidReadFile to item 1 of listReadFile

###�σe�L�X�g�i�u���������邽�߁j
set ocidMutableString to refMe's NSMutableString's stringWithCapacity:0
ocidMutableString's setString:ocidReadFile


#########################
###���������𐔂���
set numCntNSMutableString to ocidMutableString's |length|()
###���������S���Ń����W�ɂ���
set ocidNsRange to {location:0, |length|:numCntNSMutableString}
###���s����
ocidMutableString's replaceOccurrencesOfString:("Options FollowSymLinks Multiviews�n") withString:("Options FollowSymLinks Multiviews Indexes�n") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange

#########################
###���������𐔂���
set numCntNSMutableString to ocidMutableString's |length|()
###���������S���Ń����W�ɂ���
set ocidNsRange to {location:0, |length|:numCntNSMutableString}
###���s����
ocidMutableString's replaceOccurrencesOfString:("#LoadModule userdir_module libexec/apache2/mod_userdir.so") withString:("LoadModule userdir_module libexec/apache2/mod_userdir.so") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange

#########################
###���������𐔂���
set numCntNSMutableString to ocidMutableString's |length|()
###���������S���Ń����W�ɂ���
set ocidNsRange to {location:0, |length|:numCntNSMutableString}
###���s����
ocidMutableString's replaceOccurrencesOfString:("#LoadModule include_module libexec/apache2/mod_include.so") withString:("LoadModule include_module libexec/apache2/mod_include.so") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange
log ocidMutableString as text


#########################
###���������𐔂���
set numCntNSMutableString to ocidMutableString's |length|()
###���������S���Ń����W�ɂ���
set ocidNsRange to {location:0, |length|:numCntNSMutableString}
###���s����
ocidMutableString's replaceOccurrencesOfString:("#LoadModule rewrite_module libexec/apache2/mod_rewrite.so") withString:("LoadModule rewrite_module libexec/apache2/mod_rewrite.so") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange
log ocidMutableString as text

#########################
###���������𐔂���
set numCntNSMutableString to ocidMutableString's |length|()
###���������S���Ń����W�ɂ���
set ocidNsRange to {location:0, |length|:numCntNSMutableString}
###���s����
ocidMutableString's replaceOccurrencesOfString:("#LoadModule rewrite_module libexec/apache2/mod_rewrite.so") withString:("LoadModule rewrite_module libexec/apache2/mod_rewrite.so") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange
log ocidMutableString as text


#########################
###���������𐔂���
set numCntNSMutableString to ocidMutableString's |length|()
###���������S���Ń����W�ɂ���
set ocidNsRange to {location:0, |length|:numCntNSMutableString}
###���s����
ocidMutableString's replaceOccurrencesOfString:("#CustomLog �"/private/var/log/apache2/combined_log�" combined") withString:("#CustomLog �"/private/var/log/apache2/combined_log�" combined") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange
log ocidMutableString as text



#########################
####���e���������ށ@UTF8�ŏ�������
set boolFileWrite to (ocidMutableString's writeToFile:ocidFilePath atomically:false encoding:(refMe's NSUTF8StringEncoding) |error|:(missing value))



set ocidReadFile to ""
set ocidMutableString to ""
#############################
#############################
####�ǂݍ��ރt�@�C��
set ocidFilePath to refMe's NSString's stringWithString:"/etc/apache2/extra/httpd-userdir.conf"
###�t�@�C���̓��e��ǂݍ���
set listReadFile to refMe's NSString's stringWithContentsOfFile:ocidFilePath encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidReadFile to item 1 of listReadFile
###�σe�L�X�g�i�u���������邽�߁j
set ocidMutableString to refMe's NSMutableString's stringWithCapacity:0
ocidMutableString's setString:ocidReadFile


#########################
###���������𐔂���
set numCntNSMutableString to ocidMutableString's |length|()
###���������S���Ń����W�ɂ���
set ocidNsRange to {location:0, |length|:numCntNSMutableString}
####����
ocidMutableString's replaceOccurrencesOfString:("#Include /private/etc/apache2/users") withString:("Include /private/etc/apache2/users") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange

#########################
####���e���������ށ@UTF8�ŏ�������
set boolFileWrite to (ocidMutableString's writeToFile:ocidFilePath atomically:false encoding:(refMe's NSUTF8StringEncoding) |error|:(missing value))


####################################
####���[�U�[�T�C�g
####################################

set objFileManager to refMe's NSFileManager's defaultManager()
set strDirPath to "/private/etc/apache2/users"
set ocidNSString to refMe's NSString's stringWithString:strDirPath
set ocidURLPath to refMe's NSURL's fileURLWithPath:ocidNSString
set ocidFileList to objFileManager's contentsOfDirectoryAtURL:ocidURLPath includingPropertiesForKeys:{refMe's NSURLNameKey} options:(refMe's NSDirectoryEnumerationSkipsHiddenFiles) |error|:(missing value)


repeat with objFiles in ocidFileList
	set ocidReadFile to ""
	set strFilePath to objFiles's |path|() as text
	
	#############################
	#############################
	####�ǂݍ��ރt�@�C��
	set ocidFilePath to (refMe's NSString's stringWithString:strFilePath)
	###�t�@�C���̓��e��ǂݍ���
	set listReadFile to (refMe's NSString's stringWithContentsOfFile:ocidFilePath encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
	set ocidReadFile to item 1 of listReadFile
	###�σe�L�X�g�i�u���������邽�߁j
	set ocidMutableString to (refMe's NSMutableString's stringWithCapacity:0)
	(ocidMutableString's setString:ocidReadFile)
	
	
	#########################
	###���������𐔂���
	set numCntNSMutableString to ocidMutableString's |length|()
	###���������S���Ń����W�ɂ���
	set ocidNsRange to {location:0, |length|:numCntNSMutableString}
	###���s����
	(ocidMutableString's replaceOccurrencesOfString:("Options Indexes MultiViews�n") withString:("Options Indexes MultiViews FollowSymLinks�n") options:(refMe's NSRegularExpressionSearch) range:ocidNsRange)
	
	#########################
	####���e���������ށ@UTF8�ŏ�������
	set boolFileWrite to (ocidMutableString's writeToFile:ocidFilePath atomically:false encoding:(refMe's NSUTF8StringEncoding) |error|:(missing value))
	
	
end repeat



###�ݒ�ύX�̒l��ۑ��ł���悤�Ɉꎞ�I�ȃA�N�Z�X���@��߂�
set strCommandText to "/usr/bin/sudo /bin/chmod 755 /private/etc/apache2"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 755 /private/etc/apache2/httpd.conf"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 755 /private/etc/apache2/extra"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 755 /private/etc/apache2/extra/httpd-userdir.conf"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 755 /private/etc/apache2/users"
do shell script strCommandText with administrator privileges
set strCommandText to "/usr/bin/sudo /bin/chmod 755 /private/etc/apache2/users/*conf"
do shell script strCommandText with administrator privileges

###�ݒ�ǂݍ����launchctl
set strCommandText to "/usr/bin/sudo launchctl load -w /System/Library/LaunchDaemons/org.apache.httpd.plist"
do shell script strCommandText with administrator privileges
###�X�^�[�g
set strCommandText to "/usr/bin/sudo /usr/sbin/apachectl graceful"
do shell script strCommandText with administrator privileges
delay 1
tell application "Safari"
	activate
	make new document with properties {name:"localhost"}
	tell front window
		open location "http://localhost"
	end tell
	delay 1
	tell front window
		open location "http://localhost"
	end tell
end tell