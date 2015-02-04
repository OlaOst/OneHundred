module eventhandlers.editabletext;

import std.range;

import components.input;
import entity;


void handleEditableText(Input textInput, Entity editableText)
{
  if (editableText !is null && 
      editableText.has("inputType") && editableText.get!string("inputType") == "textInput")
  {
    // TODO: make sure text changes are reflected to relevant components
    if (textInput.actionState["backspace"] == Input.ActionState.Pressed && 
        editableText.get!string("text").length > 0)
        editableText["text"] = editableText.get!string("text")[0..$-2];
    
    if (textInput.actionState["newline"] == Input.ActionState.Pressed)
        editableText["text"] = editableText.get!string("text") ~ "\n";
    
    if (editableText.has("editText"))
      editableText["text"] = editableText["text"] ~ editableText["editText"];
  }
}
