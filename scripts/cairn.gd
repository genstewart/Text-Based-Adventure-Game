extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

@export var npc = ""

var cairnIntro1 = ["You leave Eden through the mountain pass and begin the long hike over the mountains.\n\nTrailing mountainside cliffs, passing under waterfalls and camping in grasy plaeaus. You see glimpses of home from the peaks."]
var cairnIntro2 = ["After two months of hiking you finally begin to see the rolling hills of your hometown much clearer.\n\nBefore the descent, you stop at The Cairn; A tall monolothic stone spire that sits on top of a stony plateau. You can see anything from up here."]

var restText = ["You make a small campfire and rest at the top of the Cairn. You sit and stare at the view of the sun setting over the green rolling hills of your hometown.", "While staring out at the view you're reminded your journey back is almost over. It's been a long journey."]

var introStage = 1
var introPlaying = true

var playerChoosing = false

var playerTurn = false
var playerCombat = false

var interactCairnDone = false
var interactFootstepsDone = false

var restCount = 0

func _ready() -> void:
	player.option1.text = "(1) Continue down the cliffside and into the rolling fields, towards the town."
	player.option2.text = "(2) Interact with the Cairn."
	player.option3.text = "(3) Follow the footsteps leading away from The Cairn."
	player.option4.text = "(4) Rest at The Cairn."
	player.option5.hide()
	playerHide()
	introText(1)
	continueButton.show()

func _process(delta: float) -> void:
	turnHandler()

	if Input.is_action_just_pressed("nextDialogue") or continueButton.button_pressed == true:
		if tween.is_running():
			skipDialogue()
		elif introStage == 1 and introPlaying:
			introStage += 1
			introText(introStage)

		elif playerCombat and not playerTurn:
			if npc.hPool.size() > 1:
				npc.dealDamage()
				playerTurn = true
			elif npc.hPool.size() <=1:
				npc.death()
		elif playerTurn == true:
			npc.actionHandler(SaveState.prevInput)
			if (SaveState.prevInput.begins_with("stab") or SaveState.prevInput.begins_with("slash")) and npc == get_node("dialogueScreen/footsteps"):
				playerCombat = true
				playerTurn = false

	if (Input.is_action_just_pressed("1") or player.option1.button_pressed == true) and playerChoosing:
		c1()
	
	if (Input.is_action_just_pressed("2") or player.option2.button_pressed == true) and playerChoosing:
		if interactCairnDone:
			pass
		elif not interactCairnDone:
			c2()
	
	if (Input.is_action_just_pressed("3") or player.option3.button_pressed == true)  and playerChoosing:
		if interactFootstepsDone:
			pass
		elif not interactFootstepsDone:
			c3()
	
	if (Input.is_action_just_pressed("4") or player.option4.button_pressed == true)  and playerChoosing:
		restButton()

func introText(introStage):
	match introStage:
		1:
			playText("".join(cairnIntro1))
		2:
			playText("".join(cairnIntro2))
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			introPlaying = false
			playerChoosing = true
		3:
			playText("You arrive back at The Cairn after following the footsteps back the way you came.")
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			player.inputCon(false)
			playerChoosing = true
			playerTurn = false

func c1():
	print("you continue down the mountain and towrds the rolling hills")
	playerChoosing = false

func c2():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/thecairn")
	playText(npc.introText)

func c3():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/footsteps")
	playText(npc.introText)

func restButton():
	restCount += 1
	if restCount == 1:
		playText(restText[0])
		player.option4.disabled = false
	elif restCount == 2:
		playText(restText[1])
		player.option4.disabled = false
	elif restCount >=3:
		playText("You can no longer rest.")
		player.option4.disabled = true

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

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func interactOver(choice):
	match choice:
		1:
			interactCairnDone = true
			player.showButtons(true)
			player.inputCon(false)
			playerTurn = false
			playerChoosing = true
			player.option2.disabled = true
		2:
			interactFootstepsDone = true
			player.showButtons(true)
			player.inputCon(false)
			playerTurn = false
			playerChoosing = true
			player.option3.disabled = true

func turnHandler():
	if not playerTurn:
		player.instructText.text = "[color=red]Not your turn[/color]"
	if playerTurn:
		player.instructText.text = "[color=white]What will you do?[/color]"
