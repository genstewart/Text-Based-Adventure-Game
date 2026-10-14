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
var questAccept = false

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
	"map": questAction,
	
	"trade": tradeAction,
	"armor": tradeAction,
	
	"yes": acceptAction,
	"no": acceptAction,
	
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
		npcScene.playerCombat = false

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
		npcScene.playerCombat = false

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
		if not npcScene.interactGuardDone and questActive:
			var attackDialogue = ["The ", npcName, " Orcs slash you with their scimtars."]
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
	if not questActive:
		if npcScene.playerCombat == false:
			var talkText = [""]
			npcScene.playText("".join(talkText))
		else:
			npcScene.playText("")
			player.playerJoy -= 30
			player.updateMood()
	if questActive:
		if npcScene.playerCombat == false:
			npcScene.playText("The orcs don't even speak the same language.")
		else:
			npcScene.playText("It's far too late to try talking with them.")

func questAction():
	var questText = ["You ask the Guards about what has happend and glance at the map.",
	"\"There's been a report that some Orcs are camping by the road leading into town. We were just deciding whether we should investigate.\"",
	"\n\nDo you want to offer your help?"]
	if not questActive:
		npcScene.playText("".join(questText))
		questAccept = true
	else:
		doNothing()

func acceptAction():
	var questAcceptText = ["You decide to check out the reports for the guards and leave the city while the sun is still setting",
	" It's night time by the time you are near the spot marked on the map. Through the trees you can see the light of a campfire and some muffled voices.",
	" As you approach you see two orcs by the fire clad in heavy armor. They look like soldiers that ran during the siege."]
	if not questActive and questAccept:
		if SaveState.prevInput == "yes":
			npcScene.playText("".join(questAcceptText))
			hPool[0] = 0
			hPool[1] = 100
			hPool[2] = 100
			aClass[1] = 3
			aClass[2] = 3
			npcDamage = 40
			groupName = "orcs"
			npcName = "orc"
		if SaveState.prevInput == "no":
			npcScene.playText("You wish the guards the best of luck. That life of fighting is behind you.")
			questAccept = false
	else:
		doNothing()

func recallAction():
	var recallText = [""]
	if SaveState.playerJoy <= 40:
		npcScene.playText("".join(recallText) + "")
	elif SaveState.playerJoy > 40:
		npcScene.playText("".join(recallText) + "")

func sneakAction():
	var sneakText = ["You're not sure why but you decide to crawl under the map table in the center of the room. The guards all silently watch as you crawl under.\n\n\"",
	SaveState.playerName, "? what are you doing...\"\n\nBoom, one of your classic pranks. (The guards are all shocked and in tears)",
	"You decide to do a suprise attack on the orcs. Creeping up through the bushed you grab one of the orcs from behind and stab your sword through his chest. The other jumps up in response ready to attack you."]
	if not questActive:
		npcScene.playText(sneakText[0]+sneakText[1]+sneakText[2])
	elif questActive:
		npcScene.playText(sneakText[3])

func lookAction():
	var lookText = ["The three guards are standing beside a map table. On the map there is a large red X in the forest you traveled through to enter the city.",
	 "Two orcs stand by a fire speaking in tongues to eachother. It sounds like they might be having an argument."]
	if not questActive:
		npcScene.playText(lookText[0])
	if questActive:
		npcScene.playText(lookText[1])

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
		SaveState.updateMood()

func doNothing():
	pass

func death():
	if questActive:
		if hPool.size() == 1:
			npcScene.playerTurn = true
			npcScene.playerCombat = false
			npcScene.playText(deathText)
			SaveState.playerJoy += 10
			player.updateMood()
