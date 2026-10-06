extends Control

@export var npcScene : Node2D

@export var npcName = ""
@export var groupName = ""
@export var hPool = [0,0,0,0,0]
@export var aClass = [1,1,1,1,1]
@export var npcDamage : int

var targetNum = 1
var slashTargets = []
var z = 1
var stabDmg = SaveState.playerStab * 5 * aClass[targetNum]
var slashDmg = SaveState.playerSlash - 10 * aClass[z]
@export var targetName = ["","first ", "second ", "third ", "fourth "]
var enemiesLeft
@export var takeDamageDialogue = []
@export var dealDamageDialogue = []

var deathText = "You finish off the last scavenger, your sword glistening with blood, your conscious heavy with what you've done."

@export var npcAttackDial = []

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	"talk": talkAction,
	"sneak": sneakAction,
	"": doNothing,
}

func _ready() -> void:
	npcName = "scavenger"
	groupName = "scavengers"

func _process(delta: float) -> void:
	enemiesLeft = ["There are ", str(hPool.size() - 1)," ", groupName, " left."]

func actionHandler(playerChoice):
	var findAction = findTargetStab(playerChoice)
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

	if hPool[targetNum] - stabDmg <= 0:
		takeDamage(SaveState.playerStab)
		hPool.remove_at(targetNum)
		print(hPool.size() -1)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		print(hPool)
	elif hPool[targetNum] - stabDmg >= 0:
		takeDamage(SaveState.playerStab)
		print(hPool)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func slashAction():
	slashTargetFinder()
	print(slashTargets)
	if slashTargets.size() == 1:
		var damageText = ["You slash in a large arc, hitting one of the ", groupName, " cutting them."]
		if hPool[slashTargets[0]] - slashDmg < 0:
			takeDamage(SaveState.playerSlash)
			hPool.remove_at(slashTargets[0])
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
			print(hPool)
		else:
			takeDamage(SaveState.playerSlash)
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue))
			print(hPool)
	elif hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg <= 0:
		takeDamage(SaveState.playerSlash)
		hPool.remove_at(slashTargets[0])
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nBoth fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		print(hPool)
	elif (hPool[slashTargets[0]] - slashDmg >= 0 and hPool[slashTargets[1]] - slashDmg <= 0) or (hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg >= 0):
		takeDamage(SaveState.playerSlash)
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
	elif hPool[slashTargets[0]] - slashDmg >=0:
		takeDamage(SaveState.playerSlash)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func takeDamage(damage):
	if damage == SaveState.playerStab:
		dealDamageDialogue = ["You stab the ", targetName[targetNum], npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", targetName[targetNum], npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == SaveState.playerSlash:
		dealDamageDialogue = ["You slash in a large arc, hitting two of the ", groupName, " cutting them both."]
		takeDamageDialogue = ["The ", groupName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg
			print(hPool)

func dealDamage():
	if not npcScene.interactDone:
		var attackDialogue = ["The ", groupName, " lunge at you with their knives. Some of their blades getting past your armor."]
		dealDamageDialogue = ["The ", groupName, " dealt ", str(npcDamage), " damage!"]
		npcScene.playText("".join(attackDialogue) + "\n\n" +"".join(dealDamageDialogue))
		SaveState.health -= npcDamage
	else:
		pass

func findTargetStab(playerChoice : String) -> Dictionary:
	var x = 0
	while x < len(playerChoice) and not playerChoice[x].is_valid_int():
		x += 1
	var action = playerChoice.substr(0, x)
	var targetStr = playerChoice.substr(x)
	var target = targetStr.to_int() if targetStr.is_valid_int() else -1
	return {"action": action, "target": target}

func slashTargetFinder():
	slashTargets = []
	var y = 1
	if hPool.size() >= 2:
		while y <= 2 and hPool[y] > 0:
			slashTargets.append(y)
			y += 1
		return slashTargets
	elif hPool.size() == 1:
		slashTargets = [1]

func talkAction():
	if npcScene.playerCombat == false:
		var talkText = ["You walk up to talk to the scavengers.",
		 " They are just some young boys from the village a month's walk away.",
		 " You ask them what they are doing here and the oldest boy replies,", "\n\n\"Are you ", SaveState.playerName, "? The city watch told us we might meet you out here...\"",
		 "\"Are you the only survivor? We were just looking for our Dad...\"", "\n\nYou explain to the orphan boys what happend to their father.",
		 " The guilt of the battle weighs heavy on your mind, but you feel better that you didn't resort to killing the boys immediately."]
		npcScene.playText("".join(talkText))
		SaveState.playerJoy += 10
		print(SaveState.playerJoy)
		npcScene.interactDone = true
	else:
		npcScene.playText("You try to talk to the scavengers and lock eyes with one. These are no 'bandits', these are just some boys from the village! But they're no longer willing to listen to you. \n\nNow they're fighting for their lives.")
		groupName = "boys"
		npcName = "boy"

func sneakAction():
	var sneakText = ["You wait for a while until the sun begins to set behind you.",
"\n\nEventually, the scavengers walk into the northern watchtower to camp for the night.",
" While they are staying in the tower you sneak through the gate, onto the forest trail."]
	npcScene.playText("".join(sneakText))
	npcScene.interactDone = true

func doNothing():
	pass
