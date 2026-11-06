extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

@onready var audioManager: Control = $dialogueScreen/audioManager

@export var npc = ""

var edenIntro1 = ["After a month of walking through the forest you see a clearing appear in the trail.\nThe city of Eden.\n\nYou left here nearly four months ago with " + SaveState.friendTwo + ", " + SaveState.friendOne + ", " + SaveState.friendThree + 
" and the army of Eden to kill the ",SaveState.bossSlain, ".\n\nBefore that, it was half a year after your quest had started that you arrived to help defend Eden. Back then, the walls appeared to tower higher than the mountains they were built from and rows of houses desceded from the surrounding peaks."]

var edenIntro2 = ["You came to defend the city from the siege of the ", SaveState.bossSlain, "'s army, who wanted to access the mountain pass and expand their conquest. After months of a bloody siege, you killed the Orc Commander to end it all.
\nNow the city is a shell of its former self, the towering watchtowers have crumbled to all but ruin, and many houses have burned down."]

var edenIntro3 = ["Upon entering the city, you can see children playing and people beginning the construction of their new homes." + 
"\n\nAs you walk into the town square you can smell the smell of " + SaveState.playerFood + " coming from the Tavern. You can also see the Smith and Guard House nearby. Visiting again might spark some old memories."]

var restText = ["You rest in the local inn and recover fully."]

var introStage = 1
var introPlaying = true

var playerChoosing = false

var playerTurn = false
var playerCombat = false

var interactTavernDone = false
var interactSmithDone = false
var interactGuardsDone = false

var restCount = 0

func _ready() -> void:
	player.option1.text = "(1) Continue down the path into the mountains."
	player.option2.text = "(2) Go to the Tavern."
	player.option3.text = "(3) Go to the Blacksmith."
	player.option4.text = "(4) Go to the Guard House."
	player.option5.text = "(5) Rest and heal fully at the Inn."
	playerHide()
	introText(1)
	continueButton.show()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("nextDialogue") and interactGuardsDone and npc == get_node("dialogueScreen/guardHouse"):
		interactOver(3)

	if Input.is_action_just_pressed("nextDialogue") or continueButton.button_pressed == true:
		if tween.is_running():
			skipDialogue()
		elif (introStage == 1 or introStage == 2) and introPlaying:
			introStage += 1
			introText(introStage)

		elif playerCombat and not playerTurn:
			if npc.hPool.size() > 1:
				npc.dealDamage()
				playerTurn = true
				player.instructText.text = "[color=white]What will you do?[/color]"
			elif npc.hPool.size() <= 1:
				npc.death()
		elif playerTurn == true:
			npc.actionHandler(SaveState.prevInput)
			if (SaveState.prevInput.begins_with("stab") or SaveState.prevInput.begins_with("slash")) and not npc.dead:
				playerCombat = true
				playerTurn = false
				player.instructText.text = "[color=red]Not your turn[/color]"

	if playerChoosing:
		if Input.is_action_just_pressed("1") or player.option1.button_pressed:
			c1()
		
		if Input.is_action_just_pressed("2") or player.option2.button_pressed:
			if interactTavernDone:
				pass
			elif not interactTavernDone:
				c2()
		
		if Input.is_action_just_pressed("3") or player.option3.button_pressed:
			if interactSmithDone:
				pass
			elif not interactSmithDone:
				c3()

		if Input.is_action_just_pressed("4") or player.option4.button_pressed:
			if interactGuardsDone:
				pass
			elif not interactGuardsDone:
				c4()

	if Input.is_action_just_pressed("5") or player.option5.button_pressed:
		restButton()

func introText(introStage):
	match introStage:
		1:
			playText("".join(edenIntro1))
		2:
			playText("".join(edenIntro2))
		3:
			playText("".join(edenIntro3))
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			introPlaying = false
			playerChoosing = true
		4:
			playText("You arrive back in Eden the following morning after camping a night in the woods. You stand in the town square.")
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			player.inputCon(false)
			playerChoosing = true
			playerTurn = false

func c1():
	get_tree().change_scene_to_file("res://Scenes/cairn.tscn")
	playerChoosing = false

func c2():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/tavernKeeper")
	playText(npc.introText)

func c3():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/blacksmith")
	playText(npc.introText)

func c4():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/guardHouse")
	if not npc.questActive:
		if SaveState.playerJoy >= 30:
			playText("".join(npc.introText) + "None of you imagined things ending like this. All you ever wanted was to offer your help. Now you'll be remembered for exactly that.")
		elif SaveState.playerJoy < 30:
			playText("".join(npc.introText) + "It hardly feels earned. You're at a loss for words.")
	if npc.questActive:
		playText("".join(npc.afterQuestText))

func restButton():
	restCount += 1
	if restCount <= 1:
		playText(restText[0])
		player.option5.disabled = false
		SaveState.health = player.healthBar.max_value
	elif restCount >=2:
		playText("You can no longer rest in the inn.")
		player.option5.disabled = true

func skipDialogue():
	audioManager.textSound.stop()
	continueButton.disabled = true
	tween.custom_step(60)
	continueButton.disabled = false

func playText(nextText: String):
	audioManager.textSound.play()
	if tween:
		tween.kill()
	textBox.text = nextText
	textBox.visible_characters = 0
	tween = create_tween()
	tween.tween_property(textBox, "visible_characters", len(textBox.text), len(textBox.text) * SaveState.textspeed)

func playerHide():
	playerInfo.hide()

func interactOver(choice):
	SaveState.prevInput = ""
	match choice:
		1:
			interactTavernDone = true
			player.showButtons(true)
			player.inputCon(false)
			playerTurn = false
			playerChoosing = true
			player.option2.disabled = true
		2:
			interactSmithDone = true
			player.showButtons(true)
			player.inputCon(false)
			playerTurn = false
			playerChoosing = true
			player.option3.disabled = true
		3:
			interactGuardsDone = true
			player.showButtons(true)
			player.inputCon(false)
			playerTurn = false
			playerChoosing = true
			player.option4.disabled = true
	if interactTavernDone:
		player.option2.disabled = true
	if interactSmithDone:
		player.option3.disabled = true
	if interactGuardsDone:
		player.option4.disabled = true
	if restCount >=2:
		player.option5.disabled = true
