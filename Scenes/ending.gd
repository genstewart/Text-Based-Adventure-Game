extends Control

@export var npcScene : Node2D
@export var player : Control

var introText = "You enter your home to finally sit down and rest."

var restText = ["You sit down to rest at last, finally your journey has come to an end. You "]

var mercifulText = []
var generousText = []
var selflessText = []
var honestText = []

var leaveText = ["You can't leave."]

var actionMap = {
	"rest": restAction,
	
	"leave": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	if SaveState.dogFriend:
		introText = "You and the dog enter your home to finally sit down and rest."
	elif not SaveState.dogFriend:
		introText = "You enter your home to finally sit down and rest."

func actionHandler(playerChoice):
	var findAction = playerChoice
	var action = findAction["action"]
	
	if not actionMap.has(action):
		npcScene.playText("You can't do that.")
		return

	actionMap[action].call()

func restAction():
	npcScene.playText("")

func exitAction():
	npcScene.playText("".join(leaveText))
	npcScene.interactHouseDone = true
	npcScene.interactOver(1)

func doNothing():
	pass
