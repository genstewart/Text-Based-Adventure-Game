extends Control

@export var npcScene : Node2D
@export var player : Control

@export var npcName = ""
@export var groupName = ""
@export var hPool = [0,0,0,0,0]
@export var aClass = [1,1,1,1,1]
@export var npcDamage : int
var npcTotalDamage = (npcDamage * (hPool.size()-1))

var targetNum = 1
var slashTargets = []
var z = 1
var stabDmg = SaveState.playerStab + 10 * aClass[targetNum]
var slashDmg = SaveState.playerSlash - 10 * aClass[z]
@export var targetName = ["","first ", "second ", "third ", "fourth "]
var enemiesLeft
@export var takeDamageDialogue = []
@export var dealDamageDialogue = []

var drinks = 0
var food = 0

var introText = "You walk across the town square and arrive in front of the smithy. There is a large open forge and slanted roof over a large work area. The blacksmith is busy at work and hasn't looked up for some time."
var deathText = "Why would you try that?"

@export var npcAttackDial = []

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	
	"talk": talkAction,
	
	"reminisce": recallAction,
	"recall": recallAction,
	"remember": recallAction,
	
	"sneak": sneakAction,
	"stalk": sneakAction,
	"creep": sneakAction,
	"hide": sneakAction,
	
	"look": lookAction,
	"spy": lookAction,
	"watch": lookAction,
	
	"drink": drinkAction,
	"thirsty": drinkAction,
	"ale": drinkAction,
	
	"eat": eatAction,
	"hungry": eatAction,
	"food": eatAction,
	
	"quest": questAction,
	"work": questAction,
	
	"trade": tradeAction,
	"armor": tradeAction,
	"buy": tradeAction,
	
	"leave": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "blacksmith"
	groupName = "blacksmith"

func _process(_delta: float) -> void:
	if hPool.size() == 2:
		enemiesLeft = ["There is one ", npcName, " left."]
	elif hPool.size() >=2:
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
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey both fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
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
		var attackDialogue = ["The ", npcName, " hits you across the face with the hammer. You go flying to the side."]
		npcTotalDamage = (npcDamage * (hPool.size()-1))
		dealDamageDialogue = ["The ", npcName, " dealt ", str(npcTotalDamage), " damage!"]
		npcScene.playText("".join(attackDialogue) + "\n\n" +"".join(dealDamageDialogue))
		SaveState.health -= npcTotalDamage
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
		while y < 2 and hPool[y] > 0:
			slashTargets.append(y)
			y += 1
		return slashTargets
	elif hPool.size() == 1:
		slashTargets = [1]

func talkAction():
	if npcScene.playerCombat == false:
		var talkText = ["You approach the blacksmith and say hello, he looks up for a brief moment and nods to welcome you."]
		npcScene.playText("".join(talkText))
	else:
		npcScene.playText("It's too late for talking now. Why would you attack the blacksmith?")
		player.playerJoy -= 10
		player.updateMood()

func recallAction():
	var recallText = ["The banging of the hammer takes you back to the nights standing on the wall during the siege. You sat with ", SaveState.friendOne ,
	" on top of the wall looking out for any full scale attacks. From atop the wall you could always hear the hammer of the blacksmith until late at night.",
	" It was constantly interupting your conversation and ", SaveState.friendOne, " would eventually just give up and wait for the blacksmith to go to bed."]
	if SaveState.playerJoy <= 40:
		npcScene.playText("".join(recallText) + "\n\nYou always felt frustrated by those long quiet moments, and now that " + SaveState.friendOne +
		 " is gone, you can't help but feel like the blacksmith took some of those conversations away from you.")
	elif SaveState.playerJoy > 40:
		npcScene.playText("".join(recallText) + "\n\nYou always hated those long quiet moments listening to the banging from the wall. Now, there isn't anything you wouldn't give to sit in silence with " +
		 SaveState.friendOne + " one last time.")

func sneakAction():
	var sneakText = ["You struggle to see anything to hide behind. In a frantic scramble you duck behind the anvil while he is still forging a sword. The blacksmith looks down at you and away from his hammer.\n\n\"" + SaveState.playerName + "? what are you doing...\"\n\nYou stand back up."]
	npcScene.playText("".join(sneakText))

func lookAction():
	var lookText = ["The blacksmith is hard at work to help people repair their homes. Crates full of nails and some mallets are on display for cheap." +
	"On the back wall of the shop there are some assorted weapons and armor for sale, it looks expensive."]
	npcScene.playText("".join(lookText))

func drinkAction():
	var drinkText = ["You ask the blacksmith for a drink. \"This is a smithy, not a tavern bud.\" he grunts, and continues to hammer away.",
	"Thats enough of bothering the busy blacksmith."]
	drinks += 1
	if drinks == 1:
		npcScene.playText(drinkText[0])
	elif drinks >= 2:
		npcScene.playText(drinkText[1])

func eatAction():
	var eatText = ["You ask the blacksmith for some food. \"Where do you think you are... this is a blacksmith\" he is not happy with you wasting his time.",
	"You beg the blacksmith and cry about how hungry you are. \"I can tell.\" he is glancing at your belly.",
	"Okay I don't want to write anymore pointless dialogue."]
	food += 1
	if food == 1:
		npcScene.playText(eatText[0])
	elif food == 2:
		npcScene.playText(eatText[1])
	elif food >= 3:
		npcScene.playText(eatText[2])

func questAction():
	var questText = ["\"Maybe try asking the others in the town, they might have something for you.\""]
	npcScene.playText("".join(questText))

func tradeAction():
	var tradeText = ["You ask the blacksmith to trade.\n\n\"I heard what you did for Eden when it was under siege. I made this for you.\" He walks to the back of his store and pulls out a mail shirt.",
	"\n\nThe mail shirt glitters in the sun and is made with unmatched expertise. You wear the mail shirt under your coat and thank the blacksmith.\n\n"]
	var trades = 0
	if trades == 0:
		npcScene.playText("".join(tradeText))
		player.healthBar.max_value = 175
		SaveState.maxHealth = 175
		SaveState.health += 75
		SaveState.playerJoy += 10
		player.updateMood()
		trades += 1
	elif trades >= 1:
		npcScene.playText("He has nothing left to give you.")

func exitAction():
	var leaveText = ["You say goodbye to the smith and walk back to the town square. \"Have a safe journey home bud.\" \n\nYou are back in the town square."]
	npcScene.playText("".join(leaveText))
	npcScene.interactSmithDone = true
	npcScene.interactOver(2)

func doNothing():
	pass

func death():
	if hPool.size() == 1:
		npcScene.playerTurn = true
		npcScene.playerCombat = false
		npcScene.playText(deathText)
		npcScene.interactDone = true
		SaveState.playerJoy -= 10
		player.updateMood()
