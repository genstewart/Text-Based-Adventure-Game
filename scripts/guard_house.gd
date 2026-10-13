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
var questActive = false

var introText = ["You enter the Guard House and three guards are at a table talking over a map. You overhear part of their conversation.\"Are you sure... We really can't spare any men now.\" \"I agree, our focus should be in the city.\" ",
"One guard glances towards the door and sees you.\n\n\"", SaveState.playerName,
 "? We never thought we'd see you again. Once again, you've saved us, we couldn't be more grateful. Y'know they are taking about building statues for you and your friends in the town square.\"\n",]
var deathText = ""

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
	
	"leave": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "guard"
	groupName = "guards"

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
	if questActive == true:
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
	else:
		npcScene.playText("These guards are holdings swords as tall as you and as wide as your face. You put your sword down.")

func slashAction():
	if questActive:
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
	elif not questActive:
		npcScene.playText("These guards are holdings swords as tall as you and as wide as your face. You put your sword down.")

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
		while y <= 2 and hPool[y] > 0:
			slashTargets.append(y)
			y += 1
		return slashTargets
	elif hPool.size() == 1:
		slashTargets = [1]

func talkAction():
	if npcScene.playerCombat == false:
		var talkText = [""]
		npcScene.playText("".join(talkText))
	else:
		npcScene.playText("")
		player.playerJoy -= 30
		player.updateMood()

func recallAction():
	var recallText = [""]
	if SaveState.playerJoy <= 40:
		npcScene.playText("".join(recallText) + "")
	elif SaveState.playerJoy > 40:
		npcScene.playText("".join(recallText) + "")

func sneakAction():
	var sneakText = ["You're not sure why but you decide to crawl under the map table in the center of the room. The guards all silently watch as you crawl under.\n\n\"",
	SaveState.playerName, "? what are you doing...\"\n\nBoom, one of your classic pranks. (The guards are all shocked and in tears)",
		]
	if not questActive:
		npcScene.playText(sneakText[0]+sneakText[1]+sneakText[2])
	elif questActive:
		npcScene.playText(sneakText[3])

func lookAction():
	var lookText = [""]
	npcScene.playText("".join(lookText))

func drinkAction():
	var drinkText = ["\"Go to the taven to drink.\"", "\"We have important business to do.\"", "\"You are an alchoholic\""]
	drinks += 1
	if drinks == 1:
		npcScene.playText(drinkText[0])
	elif drinks >= 2:
		npcScene.playText(drinkText[1])
	elif drinks >= 3:
		npcScene.playText(drinkText[2])

func eatAction():
	var eatText = ["\"Go to the taven if your hungry.\"", "\"We have important business to do.\"", "\"I think your fat.\""]
	food += 1
	if food == 1:
		npcScene.playText(eatText[0])
	elif food == 2:
		npcScene.playText(eatText[1])
	elif food >= 3:
		npcScene.playText(eatText[2])

func questAction():
	var questText = ["\"\""]
	npcScene.playText("".join(questText))

func tradeAction():
	if not questActive:
		var tradeText = ["Maybe go talk to the smith, he might have something for you."]
		if SaveState.health > 100:
			npcScene.playText("They guards gather around you to admire the mail shirt you recieved.\"Is that... an admantium mail shirt... with golden rivets and diamond crusted collar... It's beautiful.\"\n\nThey appear to be salivating.")
		elif SaveState.health <= 100:
			npcScene.playText("".join(tradeText))
	elif questActive:
		npcScene.playText("This is no time to be saying nonsense.")

func exitAction():
	if not questActive:
		var leaveText = ["You say goodbye to the guards and wish them well. You are back in the town square."]
		npcScene.playText("".join(leaveText))
		npcScene.interactGuardsDone = true
		npcScene.interactOver(3)
	elif questActive:
		npcScene.playText("You duck behind a tree and decide to turn back to the city. You're not built for this kind of battle anymore. The Guards are sure to be dissapointed.")
		SaveState.playerJoy -= 20

func doNothing():
	pass

func death():
	if questActive:
		if hPool.size() == 1:
			#npcScene.playerTurn = true
			#npcScene.playerCombat = false
			npcScene.playText(deathText)
			SaveState.playerJoy += 10
			player.updateMood()
