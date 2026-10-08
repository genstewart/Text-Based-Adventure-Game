extends Node2D

@export var textBox : RichTextLabel
@onready var tween = create_tween()

@onready var player = get_node("dialogueScreen/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

var edenIntro = ["After a month of walking through the forest you finally notice a clearing appear in the trail. The city of Eden. Often seen as the last hearth of humanity before the " +
 SaveState.bossSlain + " was defeated.\n\nYou were here nearly half a year ago now with " + SaveState.friendTwo + ", " + SaveState.friendOne + " and, " + SaveState.friendThree + 
". It was already ten months after your quest had started that you all arrived in Eden. Back then, the city was under constant siege from the The Valley. Goblins, orcs and even trolls marched on the castle gates in order to gain access to the mountain pass and expand their conquest."
+ " And it was you who helped Eden end the siege after slaying the Orc Commander at last. Now the city has seen better days." + 

"When you first arrived here half a year ago, Eden was one with the moutnains. The castle walls appeared to tower higher than the mountains they were built from and cascading rows of houses desceded from the peaks of the mountains surrounding." + 
" The vibrant and bustling city was full of thousands of humans, elves and dwarves with wildlife that coexisted, breathing life into every street and alleyway. And the carefully guarded mountain pass was a common path for traders and travellers alike."+ 
"\n\nNow the city looks like a shell of its former self, the towering watchtowers have crumbled to all but ruin, and the housing is mostly burned down."

+ "However, upon entering the city, you notice the inside is not as dreary as the view from the forest. Within the walls of ruin are children playing, and people beginning the construction of their new homes." + 
"As soon as you step into the town square three children run up to you.\n\nA young girl stares at the sword around your waist and asks, \"Are you the hero who slayed the " + SaveState.bossSlain + "? my mum told me all about you y'know, shes the tavernkeeper.\"" + 
" You not along and tell her the bravery of the combined armies that came to your aid, and of course your dearest friends. You look up and see the Tavern, Stables and Guard House nearby. Maybe it will be good to visit again."]

var recallMemory = [""]

var restText = [""]

var introPlaying = true
var playerPlaying = false
var memoryPlaying = false

var restCount = 0

func _ready() -> void:
	player.option1.text = "(1) Continue down the path into the mountains."
	player.option2.text = "(2) Go to the Tavern."
	player.option3.text = "(3) Go to the Stables."
	player.option4.text = "(4) Go to the Guard House."
	player.option5.text = "(5) Rest in the Inn."
	playerHide()
	continueButton.show()
	#playText(gatesIntro[0] + gatesIntro[1])

func _process(delta: float) -> void:
	if introPlaying and textBox.visible_characters == len(edenIntro[0]):
		tween.pause()
		await wait(0.3)
		tween.play()
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
	if Input.is_action_just_pressed("5") and playerPlaying or player.option1.button_pressed == true and playerPlaying:
		restButton()

func c1():
	print("you continue on the path home")

func c2():
	player.option2.disabled = true
	get_tree().change_scene_to_file("res://Scenes/npc_scene.tscn")

func c3(memoryPart):
	if memoryPart == 1:
		playText(recallMemory[0] + recallMemory[1] + recallMemory[2] + recallMemory[3] + recallMemory[4])
	elif memoryPart == 2:
		playText(recallMemory[5] + recallMemory[6] + recallMemory[7] + recallMemory[8] + recallMemory[9])
		memoryPlaying = false
		playerPlaying = true
		player.option3.disabled = true

func restButton():
	restCount += 1
	if restCount == 1:
		playText(restText[0])
		player.option4.disabled = false
		SaveState.playerJoy += 2
	elif restCount == 3:
		playText(restText[2] + SaveState.friendTwo + ", and " + SaveState.friendThree + restText[3] + SaveState.friendOne 
		+  ". " + SaveState.friendTwo + restText[4] + SaveState.bossSlain + restText[5] + SaveState.friendOne + restText[6])
		player.option4.disabled = true
		SaveState.playerJoy += 1
		print(SaveState.playerJoy)
	elif restCount > 1 and restCount < 3:
		playText(restText[1])
		player.option4.disabled = false
		SaveState.playerJoy += 1

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
