#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetTitleMatchMode 2
SendMode, Input
SetWorkingDir, %A_ScriptDir%
#Include ../Chrome.ahk
 
; run chrome.exe "--remote-debugging-port=9222"

url := "https://chat.openai.com/"
 
if WinExist("ahk_exe chrome.exe") {
   ; Chrome is running, activate the window
   WinActivate, ahk_exe chrome.exe
}else  {
   ; Chrome is not running, start it with the remote debugging flag
   Run, chrome.exe --remote-debugging-port=9222
   ; Wait for Chrome to start
   Sleep, 5000
}
 
 
if (Chromes := Chrome.FindInstances())
ChromeInst := {"base": Chrome, "DebugPort": Chromes.MinIndex()} ; or if you know the port:  ChromeInst := {"base": Chrome, "DebugPort": 9222}
else
   msgbox That didn't work. Please check if Chrome is running in debug mode.`n(use, for example, http://localhost:9222/json/version )
 
 
; --- Connect to the page ---
if !(Page := ChromeInst.GetPage( ))     
{
   MsgBox, Could not retrieve page!
   ChromeInst.Kill()
}
else
   Page.WaitForLoad()
 
 
Page.Call("Page.navigate", {"url": url})   
Page.WaitForLoad()

^F2:: ; ^ is the equivalent on autohotkey to pressing the crtl key + F2 change this to whatever suits you

; Send Ctrl+C to copy the selected text
SendInput, {Ctrl Down}c{Ctrl Up}

; Execute a JavaScript code snippet to retrieve the text box element with the specified class name
Page.Evaluate("var textBox = document.getElementsByClassName('m-0 w-full resize-none border-0 bg-transparent p-0 pl-2 pr-7 focus:ring-0 focus-visible:ring-0 dark:bg-transparent md:pl-0')[0];")

; Set the value of the text box to the clipboard text
Page.Evaluate("textBox.value = '" Clipboard "';")


; Execute a JavaScript code snippet to submit the form
Page.Evaluate("var event = new KeyboardEvent('keydown', {key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true, cancelable: true});")
Page.Evaluate("textBox.dispatchEvent(event);")

MsgBox, 0, Generating response, Press Esc or Enter when done
IfMsgBox OK
{
    ;code here when pressing enter
    ;holding the code here till the response is complete
    ;otherwise the div has no text
}

; Execute a JavaScript code snippet to retrieve the elements with the specified class name
Page.Evaluate("var divs = document.getElementsByClassName('markdown prose w-full break-words dark:prose-invert light');")
 
; Get the last div element in the array
Page.Evaluate("var lastDiv = divs[divs.length - 1];")
 
; Get the inner text of the last div element
lastDivText := Page.Evaluate("lastDiv.innerText").value

Clipboard:= lastDivText
 
; Display the inner text of the last div element in a message box
; MsgBox, % "The text inside the last div element is: " lastDivText
 
return

