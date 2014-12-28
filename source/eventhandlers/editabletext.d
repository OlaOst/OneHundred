module eventhandlers.editabletext;

import std.range;

import components.input;
import entity;


void handleEditableText(Input textInput, Entity editableText)
{
  if (editableText !is null && 
      "inputType" in editableText.values && editableText.values["inputType"] == "textInput")
  {
    // TODO: make sure text changes are reflected to relevant components
    if (textInput.actionState["backspace"] == Input.ActionState.Pressed && 
        editableText.values["text"].length > 0)
        editableText.values["text"].popBack();
    
    if (textInput.actionState["newline"] == Input.ActionState.Pressed)
        editableText.values["text"] ~= "\n";
    
    if ("editText" in editableText.values)
      editableText.values["text"] ~= editableText.values["editText"];
  }
}
