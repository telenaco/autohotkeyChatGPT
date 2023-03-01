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

^F2::

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



; ^F3::
; Page := ChromeInst.GetPage( )
; Page.WaitForLoad()

; js = 
; (
; (function() {
;     // Create an array to store the 'id' attributes
;     const ids = [];

;     // Get all the elements in the page with an 'id' attribute
;     const elements = document.querySelectorAll('[id]');

;     // Loop through each element and add its 'id' attribute to the 'ids' array
;     elements.forEach(element => {
;         ids.push(element.getAttribute('id'));
;     });

;     // Return the 'ids' array
;     return ids.join('\n');})()
;     )


; ; Call the JavaScript function and store the result in the 'ids' variable
; ids := Page.Evaluate(js).Value
; idLines := StrReplace(ids, "\\n", Chr(10))

; ; Check if the GUI window already exists
; if (WinExist("IDs") = 0) {
;     ; Create a GUI window to display the IDs
;     Gui, Add, Text, w600 h600, % "IDs:"
;     Gui, Font, s10
;     Gui, Add, Edit, x5 y25 w590 h570 vIDs ReadOnly
;     Gui, Show, x100 y100 w600 h600, IDs
; }

; ; Update the 'IDs' edit control with the latest IDs
; GuiControl, , IDs, %idLines%
; Clipboard := idLines

; return


; ^F4::
; Page := ChromeInst.GetPage()
; Page.WaitForLoad()

; js = 
; (
; (function(){
;     // Create an array to store the class names
;   const classNames = [];

;   // Get all the elements in the page
;   const elements = document.getElementsByTagName('*');

;   // Loop through each element and add its class names to the 'classNames' array
;   for (let i = 0; i < elements.length; i++) {
;     const classList = elements[i].classList;
;     for (let j = 0; j < classList.length; j++) {
;       if (!classNames.includes(classList[j])) {
;         classNames.push(classList[j]);
;       }
;     }
;   }

;   // Return the 'classNames' array
;   return classNames.join('\n');
; })()
; )

; classNames := Page.Evaluate(js).Value
; classNameLines := StrReplace(classNames, "\\n", "`n")

; ; Check if the GUI window already exists
; if WinExist("Class Names") {
;     ; Update the class names in the existing window
;     GuiControl, , classNames, %classNameLines%
; } else {
;     ; Create a new GUI window to display the class names
;     Gui, Add, Text, w600 h600, % "Class Names:"
;     Gui, Font, s10
;     Gui, Add, Edit, x5 y25 w590 h570 vclassNames ReadOnly, %classNameLines%
;     Gui, Show, x100 y100 w600 h600, % "Class Names"
; }

; return

; ;input fields 
; ^F5::
; Page := ChromeInst.GetPage()
; Page.WaitForLoad()

; js = 
; (
; (function(){
;     // Create an array to store the input element names
;     const inputNames = [];

;     // Get all the input elements in the page
;     const inputElements = document.querySelectorAll('input[type="text"], input[type="password"], textarea');

;     // Loop through each input element and add its name to the 'inputNames' array
;     for (let i = 0; i < inputElements.length; i++) {
;         const inputName = inputElements[i].getAttribute('name') || '';
;         inputNames.push(inputName);
;     }

;     // Return the 'inputNames' array
;     return inputNames.join('\n');
; })()
; )

; ; Clear the inputNames variable
; inputNames := ""

; inputNames := Page.Evaluate(js).Value
; inputNameLines := StrReplace(inputNames, "\\n", "`n")

; ; Show the input names in a message box
; MsgBox, % "Names of input fields:`n" inputNameLines "`n"
; Clipboard := inputNameLines

; return


; ; clickable items 
; ^F6::
; Page := ChromeInst.GetPage()
; Page.WaitForLoad()

; js =
; (
; (function() {
;     // Create an array to store the clickable items
;     const clickableItems = [];

;     // Get all the clickable elements in the page
;     const elements = document.querySelectorAll("a, button, input[type='submit'], input[type='button']");

;     // Loop through each element and add its 'id' attribute to the 'clickableItems' array
;     elements.forEach(element => {
;         clickableItems.push(element.getAttribute('id') || element.getAttribute('class') || element.getAttribute('name') || element.getAttribute('value') || element.innerText);
;     });

;     // Return the 'clickableItems' array
;     return clickableItems.join('\n');
; })()
; )

; clickableItems := Page.Evaluate(js).Value
; clickableItemLines := StrReplace(clickableItems, "\\n", "`n")

; ; Display the clickable items in a message box
; MsgBox, % "Clickable Items:`n`n" clickableItemLines

; return





; js = 
; (
; (function(){
;     // your JavaScript code goes here
;     // ...
; })()
; )