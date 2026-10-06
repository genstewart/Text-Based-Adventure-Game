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

@export var returnScene = ""

var playerTurn = true
var playerCombat = false
var interactDone = false

func _ready() -> void:
	player.Buttons(false)
	player.inputCon(true)
	player.iContainer.show()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("nextDialogue") and interactDone == true and textBox.visible_ratio == 1.0:
		print("nextScene")
		loadNextScene()
	if npc.hPool.size() == 1:
		playerTurn = true
		playerCombat = false
		playText(npc.deathText)
		interactDone = true
	if Input.is_action_just_pressed("nextDialogue") and textBox.visible_ratio < 1.0:
		skipDialogue()
	elif Input.is_action_just_pressed("nextDialogue") and playerCombat and not playerTurn and textBox.visible_ratio == 1.0:
		npc.dealDamage()
		playerTurn = true
	elif Input.is_action_just_pressed("nextDialogue") and textBox.visible_ratio == 1.0 and playerTurn == true:
		npc.actionHandler(SaveState.prevInput)
		if SaveState.prevInput.begins_with("stab") or SaveState.prevInput.begins_with("slash"):
			playerCombat = true
			playerTurn = false
	if not playerTurn:
		player.instructText.text = "[color=red]Not your turn[/color]"
	if playerTurn:
		player.instructText.text = "[color=white]What will you do?[/color]"

func playText(nextText : String):
	if tween:
		tween.kill()
	textBox.text = nextText
	textBox.visible_characters = 0
	tween = create_tween()
	tween.tween_property(textBox, "visible_characters", len(textBox.text), len(textBox.text) * SaveState.textspeed)

func loadNextScene():
	get_tree().change_scene_to_file(returnScene)

func skipDialogue():
	continueButton.disabled = true
	tween.custom_step(60)
	continueButton.disabled = false
