extends Node

const path := "res://gameDialogue/narration.json"
var text = FileAccess.get_file_as_string(path)
var line = JSON.parse_string(text)
