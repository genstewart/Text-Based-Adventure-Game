extends Control

@export var continueB : Button

@export var playerArea : MarginContainer

#player's stats view
@export var nameTag : Label
@export var healthBar : TextureProgressBar
@export var potionButton : Button
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
		playerInput.clear()

func playerDeath():
	print("died")
	if SaveState.playerJoy <= 0:
		dText = ["You died a bitter hero, unable to move on from the past."]
	elif SaveState.playerJoy <= 25:
		dText = ["You died a regretful hero who was just trying to return\nhome."]
	elif SaveState.playerJoy <= 50:
		dText = ["You died a hero still trying to help and protect others.\nThose you knew personally will remember you."]
	elif SaveState.playerJoy <= 75:
		dText = ["You died, as more than a hero but a good person,\nwho will be remembered by all for generations to come."]
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
	if SaveState.playerJoy <0:
		SaveState.playerStatus = "[color=purple]Depressed[/color]"
	elif SaveState.playerJoy >= 0 and SaveState.playerJoy <= 1:
		SaveState.playerStatus = "[color=red]Empty[/color]"
	elif SaveState.playerJoy >=1 and SaveState.playerJoy <= 20:
		SaveState.playerStatus = "[color=orange]Exhausted[/color]"
	elif SaveState.playerJoy >=20 and SaveState.playerJoy <= 40:
		SaveState.playerStatus = "[color=yellow]Optimistic[/color]"
	elif SaveState.playerJoy >=40 and SaveState.playerJoy <= 80:
		SaveState.playerStatus = "[color=white]Hopeful[/color]"
	elif SaveState.playerJoy >=80:
		SaveState.playerStatus = "[color=lime]Nostalgic[/color]"
	Status.text = SaveState.playerStatus

func healPlayer():
	if SaveState.healthPotion >= 0:
		potionButton.disabled = true
		print("healing")
		healthBar.value += 50
		SaveState.healthPotion -= 1
		potionButton.text = str(SaveState.healthPotion)
		potionButton.disabled = false
		print(healthBar.value)
	else:
		pass
