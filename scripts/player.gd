extends Control

@export var continueB : Button

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

func _ready() -> void:
	healthBar.max_value = SaveState.maxHealth
	nameTag.text = SaveState.playerName
	healthBar.value = SaveState.health
	potionButton.text = str(SaveState.healthPotion)
	Status.text = SaveState.playerStatus

func _process(_delta: float) -> void:
	healthBar.value = SaveState.health
	potionButton.text = str(SaveState.healthPotion)
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
	pass

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
		SaveState.health += 50
		SaveState.healthPotion -= 1
		potionButton.text = str(SaveState.healthPotion)
		potionButton.disabled = false
	else:
		pass
