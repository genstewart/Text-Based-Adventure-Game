extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

@export var npc = ""

var homeIntrojoy = ["You walk down the country road alone towards your home. The orchards and lush green meadows remind you of the times you walked this same road with your friends.\n\nThey live forever in your memories.\n\nAfter a day of walking you arrive back home."] #1
var homeIntrojoydog = ["You and the dog walk down the country road towards home. The dog runs circles around you as you walk the familiar meadows of your home.\n\nThe dog is happy to have a friend.\n\nAfter a day of walking you arrive back home."] #3

var homeIntrosad = ["You walk down the country road alone towards your home. The familiar roads remind you of nothing but the times you walked here with your friends so long ago, now you have to walk here alone.\n\nAfter a day of walking you arrive back home."] #2 
var homeIntrosaddog = ["You and the dog walk down the country road towards home. The memories of times you walked the same roads with your friends fill your mind, at least now you don't have to walk alone.\n\nAfter a day of walking you arrive back home."] #4

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
		elif playerTurn == true:
			npc.actionHandler(SaveState.prevInput)

	if (Input.is_action_just_pressed("1") or player.option1.button_pressed == true) and playerChoosing:
		c1()

func introText(introStage):
	continueButton.hide()
	playerInfo.show()
	player.showButtons(true)
	playerChoosing = true
	match introStage:
		1:
			playText("".join(homeIntrojoy))
		2:
			playText("".join(homeIntrosad))
		3:
			playText("".join(homeIntrojoydog))
		4:
			playText("".join(homeIntrosaddog))

func c1():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/ending")
	playText(npc.introText)

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
