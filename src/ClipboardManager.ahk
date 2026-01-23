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
            ; Check if the copied content is a Windows file path
            ; Pattern: starts with drive letter (C:\) or UNC path (\\)
            isFilePath := RegExMatch(trimmedClipboard, "^[A-Za-z]:\\|^\\\\")
            
            if (isFilePath && OldClipboard != "") {
                ; File path detected, fallback to old clipboard content and restore clipboard
                text := OldClipboard
                A_Clipboard := OldClipboard
            } else {
                ; Normal selection, keep it (don't restore old clipboard)
                text := A_Clipboard
            }
        } else {
            text := OldClipboard
            A_Clipboard := OldClipboard
        }
        return text
    }
}
