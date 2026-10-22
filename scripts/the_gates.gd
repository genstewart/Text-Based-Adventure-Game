extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

var gatesIntro = ["You arrive at a large opened steel gate with towering watchtowers made of basalt on either side. You stormed these gates after marching for a month with the northern armies. Now all that remains is the casualties of the bloody siege.",
"\n\nComing from the forest through the gates, you spot four hooded people walk through the gate and begin rummaging through the corpses.
\nThey begin pocketing smaller trinkets and grabbing the swords of the fallen knights and commanders."]

var recallMemory = ["Staring into the forest through the gates, you recall the night of the siege. After marching for a month, the armies had waited and made camp in the forest outside the gates. The plan of attack was simple.",
" In the dead of night, ", SaveState.friendOne,
" and a group of soldiers from the elven armies would climb the southern tower, sneak inside, and open the gate from the inside.",
"\n\nAfter waiting in the edge of the forest eagerly watching the gate, it began to open. Leading the charge, you rushed through the gates with the full strength of the combined armies.", 
"The goblin garrison were suprisingly prepared, and the resulting battle was a decisive but hard-fought victory.\n\nOnce day-break had come, the small remaining goblin force began running for the hills to join the rest of the "
, SaveState.bossSlain,"'s army.\n\n", SaveState.friendOne, " was found a few hours later inside the southern tower lying against the lever used to open the gates. The assorted body parts of nearly 20 goblin soldiers littered the floor. Only one elf from his squad was alive."]

var restText = ["You gather some firewood nearby and rest by a small fire in a nearby cave. You feel a sense of longing.",
 "As you sit by the fire; your empty mind wanders to the memories of your fallen friends.", 
"Sitting by the fire reminds you of the night after you defeated the goblin army at the gates. After the bitter loss of one of your closest friends, it was hard to stay hopeful. You, ", " all shared stories about the heroism of ",
" couldn't wait to return home after slaying the ", " and share the stories with ", "'s family. \n\nNow it's up to you."]

var introPlaying = true
var playerPlaying = false
var memoryPlaying = false

var restCount = 0

func _ready() -> void:
	player.option1.text = "(1) Walk by the scavengers and through the gate, into the forest."
	player.option2.text = "(2) Approach the four scavengers."
	player.option3.text = "(3) Recall what happened during the siege."
	player.option4.text = "(4) Make a campfire and rest."
	player.option5.hide()
	playerHide()
	continueButton.show()
	playText(gatesIntro[0] + gatesIntro[1])

func _process(delta: float) -> void:
	if introPlaying and textBox.visible_characters == len(gatesIntro[0]):
		tween.pause()
		await wait(0.3)
		tween.play()
	#if introPlaying and textBox.visible_characters == len(gatesIntro[0] + gatesIntro[1]):
		#introPlaying = false
		#playerPlaying = true
	if Input.is_action_just_pressed("nextDialogue") or continueButton.button_pressed == true:
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
	
	if Input.is_action_just_pressed("1") and playerPlaying or player.option1.button_pressed == true and playerPlaying:
		c1()
	if Input.is_action_just_pressed("2") and playerPlaying or player.option1.button_pressed == true and playerPlaying:
		c2()
	if Input.is_action_just_pressed("3") and playerPlaying or player.option1.button_pressed == true and playerPlaying:
		playerHide()
		memoryPlaying = true
		playerPlaying = false
		continueButton.show()
		c3(1)
	if Input.is_action_just_pressed("4") and playerPlaying or player.option1.button_pressed == true and playerPlaying:
		restButton()

func c1():
	get_tree().change_scene_to_file("res://Scenes/eden.tscn")

func c2():
	player.option2.disabled = true
	get_tree().change_scene_to_file("res://Scenes/npc_scene.tscn")

func c3(memoryPart):
	if memoryPart == 1:
		playText(recallMemory[0] + recallMemory[1] + recallMemory[2] + recallMemory[3] + recallMemory[4])
	elif memoryPart == 2:
		playText(recallMemory[5] + recallMemory[6] + recallMemory[7] + recallMemory[8] + recallMemory[9])
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
