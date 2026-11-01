extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

@onready var textSound: AudioStreamPlayer = $dialogueScreen/textSound

var gatesIntro = ["You arrive at a large opened steel gate with towering watchtowers made of basalt on either side. You stormed these gates after marching for a month with the army of Eden. Now all that remains is the casualties of the bloody siege.",
"\n\nComing from the forest through the gates, four hooded people walk through and begin searching through the corpses.
\nThey begin pocketing smaller trinkets and grabbing the swords of the fallen soldiers.", "You are standing at the gates. The young boys are still looking for their father.",
"You are standing at the gates. The young boys lie with the other corpses on the ground.", "You are standing at the gates. A faint light is burning from inside the watchtower, you can here the scavengers talking inside."]

var recallMemory = ["You recall the night of the siege. After marching for a month, the armies made camp in the forest outside the gates to prepare for the siege.\n\nThe plan was simple.",
" In the dead of night, ", SaveState.friendOne,
" and a group of knights would climb the southern tower, sneak inside, and open the gate for the rest of the army to charge through.",
"\n\nAfter waiting at the edge of the forest watching the gate, it began to open. You rushed through the gates to suprise the garrisoned army.", 
"The resulting battle was a decisive but hard-fought victory.\n\nOnce day-break had come, some remaining goblins ran for the hills to join the rest of the "
, SaveState.bossSlain,"'s army.\n\n", SaveState.friendOne, " was found dead a few hours later inside the southern tower lying against the lever used to open the gates. Their body was covered in wounds from the goblins."]

var restText = ["You gather some firewood nearby and rest by a small fire in a nearby cave. You feel a sense of longing.",
 "As you sit by the fire; your empty mind wanders to the memories of your fallen friends.", 
"Sitting by the fire reminds you of the night after you sieged the gates. The loss of one of your closest friends made it hard to stay hopeful.\n\nYou, ", " shared stories about the heroism of ",
" couldn't wait to return home after slaying the ", " and share the stories with ", "'s mom. \n\nNow it's up to you."]

var introPlaying = true
var playerPlaying = false
var memoryPlaying = false

var restCount = 0

func _ready() -> void:
	textSound.play()
	player.option1.text = "(1) Walk by the scavengers and through the gate, into the forest."
	player.option2.text = "(2) Approach the four scavengers."
	player.option3.text = "(3) Recall what happened during the siege."
	player.option4.text = "(4) Make a campfire and rest."
	player.option5.hide()
	playerHide()
	continueButton.show()
	if SaveState.daveDeath:
		player.option3.disabled = true
	if SaveState.restDone:
		player.option4.disabled = true
	if not SaveState.scavengersDone:
		playText(gatesIntro[0] + gatesIntro[1])
	elif SaveState.scavengersDone:
		player.option2.disabled = true
		if SaveState.boysTalked:
			playText(gatesIntro[2])
		elif SaveState.boysKilled:
			playText(gatesIntro[3])
		else:
			playText(gatesIntro[4])

func _process(_delta: float) -> void:
	if tween.is_running():
		textSound.stream_paused = false
	elif not tween.is_running():
		textSound.stream_paused = true

	if introPlaying and textBox.visible_characters == len(gatesIntro[0]):
		tween.pause()
		await wait(0.3)
		tween.play()
	if Input.is_action_just_pressed("nextDialogue") or continueButton.button_pressed:
		if introPlaying:
			skipDialogue()
			playerInfo.show()
			continueButton.hide()
			introPlaying = false
			playerPlaying = true
		elif playerPlaying:
			skipDialogue()
		elif memoryPlaying:
			if textBox.visible_ratio == 1:
				playerInfo.show()
				continueButton.hide()
				c3(2)
			else:
				skipDialogue()

	if playerPlaying:
		if Input.is_action_just_pressed("1") or player.option1.button_pressed:
			c1()
		if Input.is_action_just_pressed("2") or player.option2.button_pressed:
			c2()
		if Input.is_action_just_pressed("3") or player.option3.button_pressed:
			playerHide()
			memoryPlaying = true
			playerPlaying = false
			continueButton.show()
			c3(1)
		if Input.is_action_just_pressed("4") or player.option4.button_pressed:
			restButton()

func c1():
	if not SaveState.scavengersDone:
		playText("The scavengers are in your way.")
	else:
		get_tree().change_scene_to_file("res://Scenes/eden.tscn")

func c2():
	player.option2.disabled = true
	get_tree().change_scene_to_file("res://Scenes/npc_scene.tscn")

func c3(memoryPart):
	if memoryPart == 1:
		playText(recallMemory[0] + recallMemory[1] + recallMemory[2] + recallMemory[3] + recallMemory[4])
	elif memoryPart == 2:
		playText(recallMemory[5] + recallMemory[6] + recallMemory[7] + recallMemory[8] + recallMemory[9])
		SaveState.daveDeath = true
		SaveState.playerJoy += 10
		player.updateMood()
		memoryPlaying = false
		playerPlaying = true
		player.option3.disabled = true

func restButton():
	restCount += 1
	if restCount == 1:
		playText(restText[0])
		player.option4.disabled = false
		SaveState.playerJoy += 1
		player.updateMood()
	elif restCount == 4:
		playText(restText[2] + SaveState.friendTwo + ", and " + SaveState.friendThree + restText[3] + SaveState.friendOne 
		+  ". " + SaveState.friendTwo + restText[4] + SaveState.bossSlain + restText[5] + SaveState.friendOne + restText[6])
		player.option4.disabled = true
		SaveState.restDone = true
		SaveState.playerJoy += 1
		player.updateMood()
	elif restCount > 1 and restCount < 4:
		playText(restText[1])
		player.option4.disabled = false
		SaveState.playerJoy += 1
		player.updateMood()

func skipDialogue():
	continueButton.disabled = true
	tween.kill()
	textBox.visible_ratio = 1.0
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
