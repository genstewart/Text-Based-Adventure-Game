extends Control

@export var continueB : Button

@export var playerArea : MarginContainer

#player sounds
@onready var heal: AudioStreamPlayer = $playerSoundEffects/heal
@onready var attack: AudioStreamPlayer = $playerSoundEffects/attack
@onready var input: AudioStreamPlayer = $playerSoundEffects/input

#player's stats view
@export var nameTag : Label
@export var healthBar : TextureProgressBar
@export var potionButton : Button
@onready var potionSprite: Sprite2D = $view/playerArea/playerInfo/playerStats/healthPotion/potionSprite
@export var Status : RichTextLabel

#player's options
@export var optContainer : VBoxContainer
@export var option1 : Button
@export var option2 : Button
@export var option3 : Button
@export var option4 : Button
@export var option5 : Button

#player's input
@export var iContainer : VBoxContainer
@export var instructText : RichTextLabel
@export var playerInput : TextEdit
@export var playerChoice = ""

#death screen stuff
@export var dContainer : MarginContainer
@export var deathText : RichTextLabel
@export var restartButton : Button

@onready var tween = create_tween()
var dText = []
var playerDead

func _ready() -> void:
	healthBar.max_value = SaveState.maxHealth
	nameTag.text = SaveState.playerName
	healthBar.value = SaveState.health
	potionButton.text = str(SaveState.healthPotion)
	Status.text = SaveState.playerStatus
	hPotAnim()
	playerArea.show()
	dContainer.hide()

func _process(_delta: float) -> void:
	healthBar.value = SaveState.health
	potionButton.text = str(SaveState.healthPotion)
	if healthBar.value <= 0 and not playerDead:
		playerDeath()
		playerDead = true
	
	if Input.is_action_just_pressed("heal") or potionButton.button_pressed == true:
		healPlayer()

func showButtons(state : bool):
	if not state:
		optContainer.hide()
		option1.disabled = true
		option2.disabled = true
		option3.disabled = true
		option4.disabled = true
		option5.disabled = true
	elif state:
		optContainer.show()
		option1.disabled = false
		option2.disabled = false
		option3.disabled = false
		option4.disabled = false
		option5.disabled = false

func inputCon(state : bool):
	if not state:
		iContainer.hide()
	elif state:
		iContainer.show()

func _on_player_action_text_changed() -> void:
	if Input.is_action_just_pressed("nextDialogue"):
		SaveState.prevInput = playerInput.text.replace(" ", "")
		if SaveState.prevInput.begins_with("stab") or SaveState.prevInput  == "slash":
			attack.play()
		else:
			input.play()
		playerInput.clear()

func playerDeath():
	if SaveState.playerJoy <= 0:
		dText = ["You died a bitter hero, unable to move on from the past."]
	elif SaveState.playerJoy <= 25:
		dText = ["You died a regretful hero who was just trying to return\nhome."]
	elif SaveState.playerJoy <= 50:
		dText = ["You died a hero still trying to help and protect others.\nThose you knew personally will remember you."]
	elif SaveState.playerJoy <= 75:
		dText = ["You died, as more than a hero but a good person,\nwho will be remembered by some for years to come."]
	elif SaveState.playerJoy > 75:
		dText = ["You died, as more than a hero but a good person,\nwho will be remembered by all for generations to come."]
	dContainer.show()
	playerArea.hide()
	playText("".join(dText))

func _on_restart_button_pressed() -> void:
	playerDead = false
	get_tree().change_scene_to_file("res://Scenes/game_start.tscn")

func playText(nextText: String):
	if tween:
		tween.kill()
	deathText.text = nextText
	deathText.visible_characters = 0
	tween = create_tween()
	tween.tween_property(deathText, "visible_characters", len(deathText.text), len(deathText.text) * SaveState.textspeed)

func updateMood():
	if SaveState.playerJoy < 0:
		SaveState.playerStatus = "[color=purple]Depressed[/color]"
	elif SaveState.playerJoy >= 0 and SaveState.playerJoy <= 5:
		SaveState.playerStatus = "[color=red]Exhausted[/color]"
	elif SaveState.playerJoy > 5 and SaveState.playerJoy <= 30:
		SaveState.playerStatus = "[color=orange]Tired[/color]"
	elif SaveState.playerJoy > 30 and SaveState.playerJoy <= 60:
		SaveState.playerStatus = "[color=yellow]Optimistic[/color]"
	elif SaveState.playerJoy > 60 and SaveState.playerJoy <= 90:
		SaveState.playerStatus = "[color=white]Hopeful[/color]"
	elif SaveState.playerJoy > 90 and SaveState.playerJoy <= 130:
		SaveState.playerStatus = "[color=lime]Nostalgic[/color]"
	elif SaveState.playerJoy > 130:
		SaveState.playerStatus = "[color=lightblue]At Peace[/color]"
	Status.text = SaveState.playerStatus

func healPlayer():
	if SaveState.healthPotion > 0:
		heal.play()
		potionButton.disabled = true
		SaveState.health += 50
		SaveState.healthPotion -= 1
		potionButton.text = str(SaveState.healthPotion)
		potionButton.disabled = false
		hPotAnim()
	else:
		pass

func hPotAnim():
	match SaveState.healthPotion:
		0:
			potionSprite.frame = 5
		1:
			potionSprite.frame = 4
		2:
			potionSprite.frame = 3
		3:
			potionSprite.frame = 2
		4:
			potionSprite.frame = 1
		5:
			potionSprite.frame = 0
		6:
			potionSprite.frame = 6
		7:
			potionSprite.frame = 6
