;;;;;;;;;;;;;LICENSE;;;;;;;;;;;;;;;;;;;;;
;
;see LICENSE file
;
;;;;;;;;;;;DOCUMENTATION;;;;;;;;;;;;;;;;;
;
;This is an Autohotkey script which add hotkey's for easy
;writing markdown text.
;
;|----------+-------------------------------+-------------------+-----------------------------------+
;| shortcut	| description					| markdown syntax	| HTML Syntax						|
;|----------+-------------------------------+-------------------+-----------------------------------+	
;| alt + i	| emphatic text					| *text*			| <em>text</em>						|
;| alt + b	| strong text 					| **text**			| <strong>text</strong>				|
;| alt + c	| source code					| `int main()`		| <code>int main ()</code>			|
;| alt + q	| quote 						| > cite			| <blockquote>cite</blockquote>		|
;| alt + n	| new line						| __ Enter			| <br />							|
;| alt + .	| start unordered list			| * first point		| <ul><li>first point</li></ul>		|
;| alt + ,	| start ordered list			| 1. first point	| <ol><li>first point</li></ol>		|
;| alt + t	| insert 4 tabs (as list indent)| ____(_ mean blank)| ____(_ mean blank)				|
;| alt + l	| start "link wizard"			| [text](url)		| <a href="url">text</a>			|
;| alt + p	| start "image wizard"			| ![alt_text](url)	| <img src="url" alt="alt_text" />	|
;| alt + -	| horizontal line				| - - - -			| <hr />							|
;|----------+-------------------------------+-------------------+-----------------------------------+
;
; Special Feature:
; # code beautifier
; Script will let you browse for HTML file (e.g. generated HTML from 
; markdown) and copy the content to a second file, same name like 
; selected file but "_converted" will be added.
; If there are <code></code> sections within the HTML, some
; transformation (see list below) will be happen. This lead to
; easier to read source code within HTML.
;
;|----------+-------------------------------+-------------------+-----------------------------------+
;| alt + #	| blank replacement				| _ (_ mean blank)	| &nbsp;							|
;|			| tabulator replacement			| Tab-Key			| &nbsp;&nbsp;&nbsp;&nbsp;			|
;|			| new line replacement			| Enter-Key			| <br />							|
;|----------+-------------------------------+-------------------+-----------------------------------+
;
;;;;;;;;;;GENERAL SETTINGS;;;;;;;;;;;;;;;
;;reload script automatic 
#SingleInstance force

IME_SET(SetSts, WinTitle="A")    {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  Int, SetSts) ;lParam  : 0 or 1
}
;;;;;;;;;;SCRIPTS;;;;;;;;;;;;;;;;;;;;;;;;
;Markdown *text* will show text italic <em></em>
!i::
IME_SET(0)
Send {* 2}
Send {Left} ;send the cursor position inside
return

;Markdown **text** will show text bold <strong></strong>
!b:: 
IME_SET(0)
Send {* 4}
Send {Left 2}
return 

;Markdown `int main ()` will shown as code <code></code>
!c::
IME_SET(0)
Send {`` 2}
Send {Left}
return

;Markdown > text will shown as quote <blockquote></blockquote>
!q::
IME_SET(0)
Send {Enter}
Send {>}
Send {space}
return

;Markdown line break are equal to two blanks
!n::
IME_SET(0)
Send {space 2}{Enter}
return

;Markdown 1. text will shown as bullet list <ol><li></li></ol>
!,::
IME_SET(0)
;start new line, some markdown scripts need it explicit
Send {Enter}{space 2}{Enter}
Send {1}{.}
Send {space}
return

;Markdown uses 4 spaces to indent the level
!t::
IME_SET(0)
Send {space 4}
return

;Markdown [text](http://example.com) will translate into <a href="http://example.com>text</a>
!l::
Gui Add, Text,, Please enter the URL:
Gui Add, Edit, vUrl				;variable name should start with small v
GuiControl,, Edit1, http://		;set default text to http://
Gui Add, Text,, Please enter the Text to show:
Gui Add, Edit, vText
Gui Add, Button, default ys, &OK
Gui Add, Button, default, &Cancel
Gui Show
return

ButtonOK:
Gui, Submit		;Save control content into variables
Send {[}
Send %Text%
Send {]}{(}
Send %Url%
Send {)}
Gui, Destroy 	;close all handles
return

ButtonCancel:
GuiClose:		;other label which closes the GUI
GuiEscape:		;other label which closes the GUI
Gui, Destroy 	;close all handles
return

;Markdown ![text](http://example.com/pic.jpg) will translate into <img src="http://example.com/pic.jpg" alt="text" />
;offer preview dialog, to see the picture which should included
!p::
pictureLabel:
Gui 2:Add, Text,, Please enter URL to the Picture:
Gui 2:Add, Edit, vPicUrl
Gui 2:Add, Text,, Please enter alternative text for the Picture:
Gui 2:Add, Edit, vPicAlt
Gui 2:Add, Button, default ys, &Preview
Gui 2:Add, Button,, &OK
Gui 2:Add, Button,, &Cancel
Gui 2:Show
return

2ButtonOK:
Gui, 2:Submit
Send {!}{[}
Send %PicAlt%
Send {]}{(}
Send %PicUrl%
Send {)}
Gui, 2:Destroy
return

2ButtonCancel:
2GuiClose:
2GuiEscape:
Gui, 2:Destroy
return

2ButtonPreview:
Gui, 2:Submit, NoHide							;NoHide prevent GUI 1 for being closed
UrlDownloadToFile, %PicUrl%, %temp%\foobar		;download file local, to show preview
Gui, 3:Add, Picture, w300 h300, %temp%\foobar	;2:Foo access the second window, up to 99 windows are possible
Gui, 3:Add, Button,, Close
Gui, 3:Show
return

3ButtonClose:
3GuiClose:
3GuiEscape:
Gui, 3:Destroy
return

;Markdown - - - - on a single line insert a horizontal line
!-::
IME_SET(0)
Send {space 2}{Enter}{-}{space}{-}{space}{-}{space}{-}{space 2}{Enter}
return

;;;;;;;;;;;;;; SPECIALS ;;;;;;;;;;;
; code beautifier
;; select HTML file
;; looking for <code></code> areas
;; within code areas replace
;;; tab with 4 spaces
;;; space with &nbsp;
;;; newline with <br>
!#::
FileSelectFile, SourceFile, 3,, Pick a HTML file to convert.
if SourceFile =
    return  ; This will exit in this case.

SplitPath, SourceFile,, SourceFilePath,, SourceFileNoExt
DestFile = %SourceFilePath%\%SourceFileNoExt%_converted.html

; ask to override existing file
IfExist, %DestFile%
{
    MsgBox, 4,, Overwrite the existing links file? Press No to append to it.`n`nFILE: %DestFile%
    IfMsgBox, Yes
        FileDelete, %DestFile%
}
; variable stores if there is actual a open code section
inCodeSection := 0
; for each line within source and destination
Loop, read, %SourceFile%, %DestFile%
{
	line := A_LoopReadLine
	; look for start of code section
	IfInString, line, <code>
	{
		inCodeSection := 1
	}
	; replace tabs with spaces
	; and spaces with &nbsp;
	; add <br /> at the end 
	; and write to destination
	if inCodeSection = 1
	{
		StringReplace, line, line, %A_Tab%, %A_Space%%A_Space%%A_Space%%A_Space%, All
		StringReplace, line, line, %A_Space%, &nbsp`;, All
		FileAppend, %line% <br /> `n
	}	
	; write to destination without modifications
	else
	{
		FileAppend, %line% `n
	}
	; look for end of code section
	IfInString, line, </code>
	{
		inCodeSection := 0
	}
}
return

^!t::
; Prompt the user for the number of rows and columns.
InputBox, rows, Number of Rows, Enter the number of rows for the table., , 150, 150
InputBox, cols, Number of Columns, Enter the number of columns for the table., , 150, 150

; Prompt the user for the alignment of the separator row.
InputBox, alignment, Separator Alignment, Enter the alignment of the separator row (left/center/right)., , 150, 150

; Build the table header.
header := ""
Loop, %cols%
{
    header .= "| Column " A_Index " "
}
header .= "|`n"

; Build the separator row.
separator := ""
Loop, %cols%
{
    if (alignment = "left" or alignment = "l")
    {
        separator .= "|:---"
    }
    else if (alignment = "center" or alignment = "c")
    {
        separator .= "|:---:"
    }
    else if (alignment = "right" or alignment = "r")
    {
        separator .= "|---:"
    }
}
separator .= "|`n"

; Build the table body.
table := ""
Loop, %rows%
{
    row := ""
    Loop, %cols%
    {
        row .= "| Cell " A_Index " "
    }
    row .= "|`n"
    table .= row
}

; Combine the header, separator, and table body into the final table.
table := header . separator . table

; Paste the table into the active window.
ClipBoard := table
Send ^v
Return

;;;;;;;;;;Numpad;;;;;;;;;;;;;;;;;;;;;;;;
Numpad0:: 
IME_SET(0)
Send {-}{space}{[}{space}{]}{space}
return

Numpad1:: 
IME_SET(0)
Send {#}{space}
return

Numpad2:: 
IME_SET(0)
Send {# 2}{space}
return

Numpad3:: 
IME_SET(0)
Send {# 3}{space}
return

Numpad4:: 
IME_SET(0)
Send {# 4}{space}
return

Numpad9:: 
IME_SET(0)
Send {[}{^}{1}{]}{:}{space}
return

NumpadMult::
IME_SET(0)
Send {* 4}
Send {Left 2} ;send the cursor position inside
return

NumpadDiv::
IME_SET(0)
Send {* 2}
Send {Left} ;send the cursor position inside
return

NumpadSub::
IME_SET(0)
Send {-}
Send {space}
return

NumpadAdd::
IME_SET(0)
;start new line, some markdown scripts need it explicit
Send {Enter}
Send {Left 2}
Send {space 2}
Send {End}
return

;Ctrl + Alt + gでGoogle Apps Scriptを実行する。
;押下したホットキーをp1パラメータに渡す。
^!g::
url = https://script.google.com/macros/s/AKfycbyO6i01u_w-W7zlSbNwPzr4O5ihbNpZ2YzXelQ1Y3UfyJBU2rhe2DgF35e6CzdYzurx/exec
req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
req.Open("GET",url, true)
req.Send(null)
req.WaitForResponse()
MsgBox % req.ResponseText
return

!Space::
Send {Right}
return

;;;無変換＆変換キー
sc07B & sc079::
Reload
return

sc079::
IME_SET(1)
return

sc07B::
IME_SET(0)
return

