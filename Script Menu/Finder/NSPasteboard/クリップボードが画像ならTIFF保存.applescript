#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

################################
##### �p�X�֘A
################################
###�t�@�C�����p�Ɏ��Ԃ��擾����
set strDateno to doGetDateNo("yyyyMMddhhmmss") as text
###�ۑ���
set strFilePath to "~/Desktop/image-" & strDateno & ".tiff" as text
set ocidFilePathStr to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false

################################
######�y�[�X�g�{�[�h���擾
################################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
####�^�C�v���擾
set ocidPastBoardTypeArray to ocidPasteboard's types
log ocidPastBoardTypeArray as list
#####�C���[�W�������
set boolContain to ocidPastBoardTypeArray's containsObject:"public.tiff"
if boolContain is true then
	set ocidTiffData to ocidPasteboard's dataForType:(refMe's NSPasteboardTypeTIFF)
else
	return "�C���[�W�ȊO�Ȃ̂Œ��~"
end if
################################
#####NSimage�ɂ���
################################
set ocidImageData to refMe's NSImage's alloc()'s initWithData:ocidTiffData
set ocidTffRep to ocidImageData's TIFFRepresentation
################################
##### �ۑ�
################################
#####TIFF����Ȃ�dataForType�Ŏ擾�����f�[�^�����̂܂ܕۑ��ł�OK
## set boolFileWrite to (ocidTiffData's writeToURL:ocidFilePathURL atomically:true)
#####�ۑ�(PNG�ϊ������l���č����NSImage�o�R�ɂ��Ă݂�)
set boolFileWrite to (ocidTffRep's writeToURL:ocidFilePathURL atomically:true)

################################
##### �t�@�C�����p�̎���
################################
to doGetDateNo(strDateFormat)
	####���t���̎擾
	set ocidDate to current application's NSDate's |date|()
	###���t�̃t�H�[�}�b�g���`
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo