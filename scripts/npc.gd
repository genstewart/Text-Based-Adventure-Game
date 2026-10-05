extends Control

@export var npcScene : Node2D

@export var npcName = ""
@export var groupName = ""
@export var hPool = [0,0,0,0,0]
@export var aClass = [1,1,1,1,1]
@export var npcDamage : int

var targetNum = 1
@export var targetName = ["","first ", "second ", "third ", "fourth "]

@export var takeDamageDialogue = []
@export var dealDamageDialogue = []
var fullDamageText

@export var npcAttackDial = []

var actionMap = {
	"stab": stabAction,
	"talk": talkAction,
	"slash": slashAction,
	"": doNothing,
}

var stabDialogue = []

func actionHandler(playerChoice):
	var findAction = findTarget(playerChoice)
	var action = findAction["action"]
	targetNum = findAction["target"]
	
	if not actionMap.has(action):
		npcScene.playText("You can't do that.")
		return

	actionMap[action].call()

func stabAction():
	if targetNum == 0:
		npcScene.playText("You thrust forwards stabbing, but no one is there...")
		return
	if targetNum < 0 or targetNum >= hPool.size():
		npcScene.playText("There's no target there.")
		return
	if hPool[targetNum] <= 0:
		npcScene.playText("That target is dead!")
		return

	if hPool[targetNum] - SaveState.playerStab <= 0:
		takeDamage(SaveState.playerStab)
		print(hPool)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey fall to the ground, dead.")
	elif hPool[targetNum] - SaveState.playerStab >= 0:
		takeDamage(SaveState.playerStab)
		print(hPool)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func slashAction(playerChoice : String):
	var x
	var target1
	var target2 


func talkAction():
	return

func takeDamage(damage):
	if damage == SaveState.playerStab:
		dealDamageDialogue = ["You stab the ", targetName[targetNum], npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", targetName[targetNum], npcName, " took ", str(SaveState.playerStab), " damage!"]
		hPool[targetNum] -= SaveState.playerStab

func dealDamage():
	var attackDialogue = ["The ", groupName, " lunge at you with their knives. Some of their blades getting past your armor."]
	dealDamageDialogue = ["The ", groupName, " dealt ", str(npcDamage), " damage!"]
	npcScene.playText("".join(attackDialogue) + "\n\n" +"".join(dealDamageDialogue))
	SaveState.health -= npcDamage

func findTarget(playerChoice : String) -> Dictionary:
	var x = 0
	while x < len(playerChoice) and not playerChoice[x].is_valid_int():
		x += 1
	var action = playerChoice.substr(0, x)
	var targetStr = playerChoice.substr(x)
	var target = targetStr.to_int() if targetStr.is_valid_int() else -1
	return {"action": action, "target": target}

func doNothing():
	null
