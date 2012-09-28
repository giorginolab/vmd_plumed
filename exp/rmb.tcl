
text .edit
pack .edit


menu .edit.popup -tearoff 0
.edit.popup add command -label Cut -command {editcut}
.edit.popup add separator
.edit.popup add command -label Copy -command {editcopy}
.edit.popup add separator
.edit.popup add command -label Paste -command {editpaste}

bind .edit <3> {tk_popup .edit.popup %X %Y} 
