extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

@export var npc = ""

var homeIntrojoy = [""] #1
var homeIntrojoydog = [""] #3

var homeIntrosad = [""] #2 
var homeIntrosaddog = [""] #4

var introStage = 1
var introPlaying = true

var playerChoosing = false

var playerTurn = false
var playerCombat = false

func _ready() -> void:
	player.option1.text = "(1) Return home."
	playerHide()
	continueButton.show()
	
	if SaveState.playerJoy > 70:
		if SaveState.dogFriend:
			introText(3)
		elif not SaveState.dogFriend:
			introText(1)
	elif SaveState.playerJoy <= 70:
		if SaveState.dogFriend:
			introText(4)
		elif not SaveState.dogFriend:
			introText(2)

func _process(_delta: float) -> void:
	turnHandler()
	
	if Input.is_action_just_pressed("nextDialogue") or continueButton.button_pressed == true:
		if tween.is_running():
			skipDialogue()
		elif introStage == 1 and introPlaying:
			introStage += 1
			introText(introStage)

	if (Input.is_action_just_pressed("1") or player.option1.button_pressed == true) and playerChoosing:
		c1()

func introText(introStage):
	match introStage:
		1:
			playText("".join(homeIntrojoy))
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			introPlaying = false
			playerChoosing = true
		2:
			playText("".join(homeIntrosad))
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			introPlaying = false
			playerChoosing = true
		3:
			playText("".join(homeIntrojoydog))
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			introPlaying = false
			playerChoosing = true
		4:
			playText("".join(homeIntrosaddog))
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			introPlaying = false
			playerChoosing = true

func c1():
	print("You begin the walk down the road to your home.")
	playerChoosing = false

func skipDialogue():
	continueButton.disabled = true
	tween.custom_step(60)
	continueButton.disabled = false

func playText(nextText: String):
	if tween:
		tween.kill()
	textBox.text = nextText
	textBox.visible_characters = 0
	tween = create_tween()
	tween.tween_property(textBox, "visible_characters", len(textBox.text), len(textBox.text) * SaveState.textspeed)

func playerHide():
	playerInfo.hide()
	player.option2.hide()
	player.option3.hide()
	player.option4.hide()
	player.option5.hide()

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func turnHandler():
	if not playerTurn:
		player.instructText.text = "[color=red]Not your turn[/color]"
	if playerTurn:
		player.instructText.text = "[color=white]What will you do?[/color]"
