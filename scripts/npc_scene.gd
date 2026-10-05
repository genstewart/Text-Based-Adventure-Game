extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")
@onready var playerInput = player.playerInput
@onready var playerChoice = player.playerChoice

@export var npc : Control

var playerTurn = true
var playerCombat = false

func _ready() -> void:
	player.disableButtons()
	player.iContainer.show()
	player.grab_focus()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("nextDialogue") and textBox.visible_ratio < 1.0:
		skipDialogue()
		#turnChange(1)
	elif Input.is_action_just_pressed("nextDialogue") and playerCombat and not playerTurn and textBox.visible_ratio == 1.0:
		npc.dealDamage()
		playerTurn = true
	elif Input.is_action_just_pressed("nextDialogue") and textBox.visible_ratio == 1.0 and playerTurn == true:
		npc.actionHandler(SaveState.prevInput)
		if SaveState.prevInput.begins_with("stab") or SaveState.prevInput.begins_with("slash"):
			playerCombat = true
			playerTurn = false

func playText(nextText : String):
	if tween:
		tween.kill()
	textBox.text = nextText
	textBox.visible_characters = 0
	tween = create_tween()
	tween.tween_property(textBox, "visible_characters", len(textBox.text), len(textBox.text) * SaveState.textspeed)

func turnChange(change : float):
	if change == 1:
		player.iContainer.show()
		continueButton.hide()
		continueButton.disabled = true
		playerInput.grab_focus()
	elif change == 0:
		player.iContainer.hide()
		continueButton.show()
		continueButton.disabled = false
		playerTurn = false

func skipDialogue():
	continueButton.disabled = true
	tween.custom_step(60)
	continueButton.disabled = false
