extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

@export var npc = ""

var havenIntro1 = ["You descend the Cairn and begin the walk to Haven, " + SaveState.friendOne + "'s home.\n\nYou stroll through the rolling green fields and camp under trees while fishing in nearby ponds."]

var havenIntro2 = ["After a week of walking you arrive in the small township of Haven. A humble town at a crossroads, there can't be more than four buildings.\n\nYou stand at the cross roads in front of " + SaveState.friendOne + "'s house. A dog sits beside the house, wagging it's tail."]

var restText = ["You walk over to the hills beside Haven and sit in the tall green grass.\n\nThe rolling green hills smell like home.","You stroll around and end up sitting by a nearby pond.\n\nYou relax while watching the fish swim around."]

var introStage = 1
var introPlaying = true

var playerChoosing = false

var playerTurn = false
var playerCombat = false

var interactHouseDone = false
var interactDogDone = false

var restCount = 0

func _ready() -> void:
	player.option1.text = "(1) Continue home."
	player.option2.text = "(2) Knock on the door of "+ SaveState.friendOne + "'s house."
	player.option3.text = "(3) Approach the dog."
	player.option4.text = "(4) Rest in the town."
	player.option5.hide()
	playerHide()
	introText(1)
	continueButton.show()

func _process(_delta: float) -> void:
	turnHandler()
	
	if Input.is_action_just_pressed("nextDialogue") or continueButton.button_pressed == true:
		if tween.is_running():
			skipDialogue()
		elif introStage == 1 and introPlaying:
			introStage += 1
			introText(introStage)
		elif playerTurn and (interactHouseDone or interactDogDone):
			npc.exitAction()
	
		elif playerCombat and not playerTurn:
			if npc.hPool.size() > 1:
				npc.dealDamage()
				playerTurn = true
			elif npc.hPool.size() <=1:
				npc.death()
		elif playerTurn == true:
			npc.actionHandler(SaveState.prevInput)
			if SaveState.prevInput.begins_with("stab") or SaveState.prevInput.begins_with("slash"):
				playerCombat = true
				playerTurn = false

	if (Input.is_action_just_pressed("1") or player.option1.button_pressed == true) and playerChoosing:
		c1()
	
	if (Input.is_action_just_pressed("2") or player.option2.button_pressed == true) and playerChoosing:
		if interactHouseDone:
			pass
		elif not interactHouseDone:
			c2()
	
	if (Input.is_action_just_pressed("3") or player.option3.button_pressed == true)  and playerChoosing:
		if interactDogDone:
			pass
		elif not interactDogDone:
			c3()
	
	if (Input.is_action_just_pressed("4") or player.option4.button_pressed == true)  and playerChoosing:
		restButton()
	
	

func introText(introStage):
	match introStage:
		1:
			playText("".join(havenIntro1))
		2:
			playText("".join(havenIntro2))
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			introPlaying = false
			playerChoosing = true
		3:
			playText("quest finish")
			continueButton.hide()
			playerInfo.show()
			player.showButtons(true)
			player.inputCon(false)
			playerChoosing = true
			playerTurn = false

func c1():
	print("You begin the walk down the road to your home.")
	playerChoosing = false

func c2():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/house")
	playText(npc.introText)

func c3():
	player.showButtons(false)
	player.inputCon(true)
	playerTurn = true
	playerChoosing = false
	npc = get_node("dialogueScreen/dog")
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
		playText("After a day of resting by the pond, you feels it's time to move on.")
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

##Maybe make the mothers house accessible even after one conversation.
func interactOver(choice):
	match choice:
		1:
			interactHouseDone = true
			player.showButtons(true)
			player.inputCon(false)
			playerTurn = false
			playerChoosing = true
			player.option2.disabled = true
		2:
			interactDogDone = true
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
