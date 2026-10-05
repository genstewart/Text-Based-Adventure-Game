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

#player's stats
##var playerName = "Gen"
##var health = 100
##var healthPotion = 5
##var playerStatus = "Exhausted"
##var playerJoy = 0

func _ready() -> void:
	nameTag.text = SaveState.playerName
	healthBar.value = SaveState.health
	potionButton.text = str(SaveState.healthPotion)
	Status.text = SaveState.playerStatus

func _process(delta: float) -> void:
	healthBar.value = SaveState.health
	if Input.is_action_just_pressed("heal") or potionButton.button_pressed == true:
		healPlayer()

func disableButtons():
	optContainer.hide()
	option1.disabled = true
	option2.disabled = true
	option3.disabled = true
	option4.disabled = true
	option5.disabled = true

func _on_player_action_text_changed() -> void:
	if Input.is_action_just_pressed("nextDialogue"):
		SaveState.prevInput = playerInput.text.replace(" ", "")
		playerInput.clear()


func healPlayer():
	if SaveState.healthPotion >= 0:
		potionButton.disabled = true
		print("healing")
		SaveState.health += 50
		SaveState.healthPotion -= 1
		potionButton.text = str(SaveState.healthPotion)
		potionButton.disabled = false
	else:
		null
