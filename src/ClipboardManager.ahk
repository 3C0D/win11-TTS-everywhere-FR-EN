; ClipboardManager.ahk
; Module for clipboard and selection text retrieval

getSelOrCbText() {
    OldClipboard := A_Clipboard
    A_Clipboard := ""

    Send "^c" ; Copy the selected text
    if !ClipWait(1.0) {
        ; If no selection, restore the clipboard and use it
        if (OldClipboard != "") {
            text := OldClipboard
            A_Clipboard := OldClipboard
            return text
        } else {
            MsgBox "No text selected or in the clipboard"
            return ""
        }
    } else {
        ; Use the selected text
        trimmedClipboard := RegExReplace(A_Clipboard, "[\s\r\n]+", "")
        if (trimmedClipboard != "") {
            text := A_Clipboard
        } else {
            text := OldClipboard
            A_Clipboard := OldClipboard
        }
        return text
    }
}
