
text .edit
pack .edit
.edit insert 1.0 " Adjust the index forward by count characters, moving to later lines in the text if necessary. If there are fewer than count characters in the text after the current index, then set the index to the last character in the text. Spaces on either side of count are optional. "

global word

menu .edit.popup -tearoff 0
.edit.popup add command -label Cut -command {editcut}
.edit.popup add separator
.edit.popup add command -label Copy -command {editcopy}
.edit.popup add separator
.edit.popup add command -label Paste -command {editpaste}

bind .edit <3> {
    global word
    set word [.edit get {@%x,%y wordstart} {@%x,%y wordend}]
    set word [string trim $word]
    puts "Got $word at %x,%y"
    tk_popup .edit.popup %X %Y
} 

proc editcut { } {
    global word
    if { $word != ""} {
	puts "Word was $word"
    } else {
	puts "ND"
    }
}
