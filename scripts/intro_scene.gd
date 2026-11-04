extends Node2D

@export var introNarration : RichTextLabel
@export var trans : Tween.TransitionType
@onready var tween = create_tween()

@onready var player = get_node("MarginContainer/player")
@onready var continueButton = player.get_node("view/playerArea/continueButton")
@onready var playerArea = player.get_node("view/playerArea")
@onready var playerInfo = player.get_node("view/playerArea/playerInfo")

@onready var audioManager: Control = $MarginContainer/audioManager
@onready var textLoop: AudioStreamPlayer = $MarginContainer/textLoop

var introText1 = ""
var introText2 = ""
var introText3 = ""
var introText4 = ""
var introText5 = ""
var introText6 = ""

var atb1 = ""
var atb2 = ""
var atb3 = ""
var atb4 = ""
var atb5 = ""

var introOver = false
var canSkip = false
signal cBON

var restCount = 0

func _ready() -> void:
	player.option1.text = "(1) Travel to The Gates of The Valley."
	player.option2.text = "(2) Recall the events of the battle."
	player.option3.text = "(3) Make a campfire and rest."
	player.option4.hide()
	player.option5.hide()
	loadDialogue()
	continueButton.disabled = true
	playerHide()
	introNarration.visible_characters = 0
	playintrotext()

func playerHide():
	playerInfo.hide()
	playerArea.hide()

func playintrotext():
	audioManager.introTextSound.play()
	tween = create_tween()
	introNarration.text = introText1 + introText2 + "the " + SaveState.bossSlain + "'s " + introText3 + SaveState.bossSlain + introText4 + introText5 + introText6
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(introNarration, "visible_characters", len(introNarration.text), len(introNarration.text) * SaveState.textspeed)

func playATBtext():
	audioManager.textSound.play()
	tween.kill()
	introNarration.text = atb1 + SaveState.bossSlain + atb2 + SaveState.friendThree + " and " + SaveState.friendTwo + atb3 + SaveState.bossSlain + atb4
	tween = create_tween()
	tween.tween_property(introNarration, "visible_characters", len(introNarration.text), len(introNarration.text) * SaveState.textspeed)

func _process(_delta: float) -> void:
	if not introOver:
		if not tween.is_running():
			audioManager.introTextSound.stream_paused = true
		elif tween.is_running():
			audioManager.introTextSound.stream_paused = false
		
		if introNarration.visible_characters == len(introText1):
			tween.pause()
			await wait(.9)
			tween.play()
		elif introNarration.visible_characters == len(introText1 + introText2 + " the " + SaveState.bossSlain + "'s" + "head from above, sliding your sword straight between its eyes."):
			tween.pause()
			await wait(0.7)
			tween.play()
		elif introNarration.visible_characters == len(introText1 + introText2 + " the " + SaveState.bossSlain + "'s " + introText3 + SaveState.bossSlain + introText4 + introText5):
			tween.pause()
			await wait(0.7)
			tween.play()
		elif introNarration.visible_characters == len(introNarration.text):
			playerArea.show()
			continueButton.show()
			emit_signal("cBON")

	if continueButton.button_pressed == true or Input.is_action_just_pressed("nextDialogue"):
		if introNarration.visible_characters == len(introNarration.text) and introOver == false:
			continue_button()
		elif tween.is_running() and introOver == true:
			dialogueSkip()
	
	if introNarration.visible_characters == len(introNarration.text) and introOver == true:
		playerInfo.show()
		continueButton.hide()
		continueButton.disabled = true

		if player.option1.button_pressed == true or Input.is_action_just_pressed("1"):
			get_tree().change_scene_to_file("res://Scenes/the_gates.tscn")

		if player.option2.button_pressed == true or Input.is_action_just_pressed("2"):
			audioManager.textSound.play()
			introNarration.visible_characters = 0
			introNarration.text = ("You recall the moments leading up to you killing the " + SaveState.bossSlain +
			".\n\nThe two armies met in the center of The Valley. A grueling battle resulted with the remaining enemy forces retreating to protect the " + SaveState.bossSlain + 
			".\n\nThat was when you charged forward with " + SaveState.friendTwo + ", " + SaveState.friendThree + ", and the remaining few soldiers to end the tyranny of the " + SaveState.bossSlain + ".") 
			tween = create_tween()
			tween.tween_property(introNarration, "visible_characters", len(introNarration.text), len(introNarration.text) * SaveState.textspeed)
			player.option2.disabled = true

		if player.option3.button_pressed == true or Input.is_action_just_pressed("3") and restCount < 3:
			audioManager.textSound.play()
			player.option3.disabled = true
			restButton()

func continue_button():
	continueButton.hide()
	introOver = true
	introNarration.visible_characters = 0
	playATBtext()

func restButton():
	restCount += 1
	introNarration.visible_characters = 0
	if restCount == 1:
		introNarration.text = "You spend some time digging two graves to bury the bodies of your lost friends. \n\nAfter, you rest by the fire and feel a sense of longing. You defeated the " + SaveState.bossSlain + ", \n\nbut at what cost?"
		tween = create_tween()
		tween.tween_property(introNarration, "visible_characters", len(introNarration.text), len(introNarration.text) * SaveState.textspeed)
		player.option3.disabled = false
		SaveState.playerJoy += 1
		player.updateMood()
	elif restCount >= 3:
		introNarration.text = "After a day of resting, you feel its time to begin the journey home."
		tween = create_tween()
		tween.tween_property(introNarration, "visible_characters", len(introNarration.text), len(introNarration.text) * SaveState.textspeed)
		player.option3.disabled = true
	elif restCount == 2:
		introNarration.text = "You rest by the fire and feel a sense of longing. You defeated the " + SaveState.bossSlain + ", \n\nbut at what cost?"
		tween = create_tween()
		tween.tween_property(introNarration, "visible_characters", len(introNarration.text), len(introNarration.text) * SaveState.textspeed)
		player.option3.disabled = false
		player.updateMood()


func dialogueSkip():
	audioManager.textSound.stop()
	continueButton.disabled = true
	tween.custom_step(60)
	continueButton.disabled = false

func _on_c_bon() -> void:
	continueButton.disabled = false

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func loadDialogue():
	introText1 = DialogueLoader.line["introScript"][0]["intro1"]
	introText2 = DialogueLoader.line["introScript"][0]["intro2"]
	introText3 = DialogueLoader.line["introScript"][0]["intro3"]
	introText4 = DialogueLoader.line["introScript"][0]["intro4"]
	introText5 = DialogueLoader.line["introScript"][0]["intro5"]
	introText6 = DialogueLoader.line["introScript"][0]["intro6"]
	
	atb1 = DialogueLoader.line["introScript"][1]["atb1"]
	atb2 = DialogueLoader.line["introScript"][1]["atb2"]
	atb3 = DialogueLoader.line["introScript"][1]["atb3"]
	atb4 = DialogueLoader.line["introScript"][1]["atb4"]
	atb5 = DialogueLoader.line["introScript"][1]["atb5"]
