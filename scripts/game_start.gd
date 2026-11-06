extends Control

@export var qBox : RichTextLabel
@export var pInput : TextEdit
@export var eBox : RichTextLabel
@export var gBox : RichTextLabel

@onready var error: AudioStreamPlayer = $error
@onready var input: AudioStreamPlayer = $input
@onready var audioManager: Control = $audioManager

var badWords = ["the ", "The ", "a ", "A "]

var qArray = ["What is your name?"
, "What is your favourite food?"
, "What is the name of one of your friends?"
, "Name another friend."
, "Name another friend."
, "What monster scares you the most?"] 

var gArray = ["Any name works", "Any food, singular. For example: Hamburger", "Any name that is not your own", "Any name that is not your own or the previous","Any name that is not your own or the previous","Name any monster, singular without any indefinite or definite article. For example: use 'Dragon' not 'The Dragon'"]

var iGood = false

var aArray : Array[String] = ["", "", "", "", "", ""]

var textspeed = .04
var currQ = 0

@onready var tween = create_tween()

func _ready() -> void:
	audioManager.introTextSound.playing = true
	SaveState.savePlayerStart()
	currQ = 0
	qBox.visible_characters = 0
	pInput.text = ""
	qBox.text = qArray[currQ]
	gBox.text = gArray[currQ]
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(qBox, "visible_characters", len(qArray[currQ]), len(qArray[currQ]) * textspeed)

func _process(_delta: float) -> void:
	if tween.is_running():
		audioManager.introTextSound.stream_paused = false
	elif tween.finished:
		audioManager.introTextSound.stream_paused = true

	if pInput.text.begins_with(" "):
		pInput.clear()

	if 1 < len(pInput.text) and len(pInput.text) <= 15:
		iGood = true
		eBox.text = ""
	if len(pInput.text) <= 1 or len(pInput.text) > 15:
		iGood = false
	if Input.is_action_just_pressed("nextDialogue") and iGood == false:
		error.play()
		eBox.text = "Your input is too long or too short"
	if Input.is_action_just_pressed("nextDialogue") and iGood == true:
		input.play()
		if currQ <= 5:
			aArray[currQ] = pInput.text
			aArray[currQ] = aArray[currQ].remove_chars(" ,./;'<>?:}[{]=-+_)(*&^%$#@!)")
			pInput.clear()
			nextQ()
		if len(aArray[5]) > 0:
			qBox.text = "Done!"
			saveEnd()

func nextQ():
	currQ = currQ + 1
	qBox.visible_characters = 0
	if currQ <= 5:
		qBox.text = qArray[currQ]
		gBox.text = gArray[currQ]
		tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(qBox, "visible_characters", len(qArray[currQ]), len(qArray[currQ]) * textspeed)

func saveEnd():
	SaveState.playerName = aArray[0]
	SaveState.playerFood = aArray[1]
	SaveState.friendOne = aArray[2]
	SaveState.friendTwo = aArray[3]
	SaveState.friendThree = aArray[4]
	SaveState.bossSlain = aArray[5]
	get_tree().change_scene_to_file("res://Scenes/introScene.tscn")
